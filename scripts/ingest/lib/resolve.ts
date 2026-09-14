import type { Db } from "./db.ts";
import { Params, chunk, normLabel, rowsPerStatement } from "./db.ts";
import type { CityCandidate, CityResolution, VenueCandidate } from "./stageLogic.ts";

/**
 * City and venue resolution, set-based.
 *
 * WHY THIS EXISTS
 *
 * The first version did the matching inside one SQL statement, joining the
 * staged rows against `cities` on `norm_label(c.slug) in (n_full, n_head)`.
 * A function on the column means no index can be used, so Postgres picks a
 * nested loop and re-normalises every city once per CSV row. Measured on a
 * live-scale copy (3,177 cities, 10,907 venues) with the 1,071-row Michelin
 * fixture: 3,402,567 join-filter evaluations on `slug` and another 3,402,533
 * on `display` - 6.8 million calls to f_unaccent + regexp_replace for a batch
 * that needs 12,700 - and 24.6s of the run's 24.8s of database time in that
 * one statement. On the live instance the same call costs about 4.6x more,
 * which is how a run came to print nothing for twelve minutes.
 *
 * WHAT CHANGED, AND WHAT DID NOT
 *
 * The normalisation is still the database's own. f_unaccent and norm_key are
 * called by Postgres here exactly as before and are never re-implemented in
 * TypeScript - that rule has not moved. What changed is how often: each side
 * is normalised ONCE (3,177 cities + 1,071 rows), and the comparison of the
 * resulting strings happens in memory, where an exact match is a hash lookup
 * rather than a scan.
 *
 * Every rule the SQL encoded is reproduced here deliberately, including the
 * parts that are easy to lose in translation:
 *
 *   - `in (n_full, n_head)` - a label is tried whole and as the part before
 *     the first comma, and a NULL key matches nothing.
 *   - `min(via)` - a city found by more than one route reports the
 *     alphabetically first: alias, then display, then slug.
 *   - three-valued logic on `country_agrees`. `normLabel(c.country) = n_country`
 *     is NULL, not false, when a city has no country, and `bool_or` ignores
 *     NULLs. A row whose only candidates have no country at all therefore kept
 *     nothing in SQL and must keep nothing here.
 *
 * The one thing not reproduced is the order of a multi-candidate list, which
 * in SQL came from `order by city_slug` under the database's collation - and
 * that already differs between the test database (C.UTF-8) and the live
 * project (en_US.UTF-8). Candidate order never reaches a verdict; it reaches
 * the review CSV's `candidates` column. This path sorts by code point, which
 * is at least the same everywhere.
 *
 * `stageLogic.ts` still carries the original SQL functions. They are the
 * reference implementation, and `ingest.test.ts` runs both paths over the
 * fixtures and diffs the results row by row.
 */

/** The database's normalisation of one staged row, computed once. */
export interface RowKeys {
  line: number;
  /** norm_label(city_label) */
  n_full: string | null;
  /** norm_label(split_part(city_label, ',', 1)) */
  n_head: string | null;
  /** norm_label of the country hint, NULL when there is no hint */
  n_country: string | null;
  /** norm_key(venue_name), NULL for keys under three characters */
  nk: string | null;
}

interface CityRow {
  city_id: string;
  city_slug: string;
  display: string;
  country: string | null;
  country_iso: string | null;
  /** norm_label(country), NULL when the city has no country */
  n_country: string | null;
  /** lower(country_iso), NULL when the city has no ISO code */
  iso_lower: string | null;
}

export interface CityIndex {
  byId: Map<string, CityRow>;
  /** norm_label(slug) -> city ids */
  bySlug: Map<string, string[]>;
  /** norm_label(display) -> city ids */
  byDisplay: Map<string, string[]>;
  /** alias -> city ids (city_aliases.alias is already stored normalised) */
  byAlias: Map<string, string[]>;
}

interface VenueRow {
  venue_id: string;
  name: string;
  city_id: string;
  city_slug: string;
  city_display: string;
  status: string;
  norm_key: string;
}

/** venue norm_key -> the venues that carry it, anywhere */
export type VenueIndex = Map<string, VenueRow[]>;

/* ------------------------------------------------------------- loading --- */

/**
 * One round trip for the whole batch's normalisation: the two city-label
 * forms, the country hint and the venue key, all computed by the database.
 *
 * The `country_hint` expression is the same one the SQL path used - an
 * explicit country_label, else the part after the first comma of the city
 * label - and it is nullif'd to '' first so that a blank column is no hint.
 */
export async function loadRowKeys(db: Db): Promise<RowKeys[]> {
  const countryHint = `nullif(btrim(coalesce(
    nullif(btrim(country_label), ''),
    nullif(btrim(split_part(city_label, ',', 2)), '')
  )), '')`;

  const { rows } = await db.query<RowKeys>(`
    select line,
           ${normLabel("city_label")}                     as n_full,
           ${normLabel("split_part(city_label, ',', 1)")}  as n_head,
           ${normLabel(countryHint)}                       as n_country,
           norm_key(venue_name)                            as nk
      from stage_rows
     order by line
  `);
  return rows.map((r) => ({
    line: Number(r.line),
    n_full: r.n_full,
    n_head: r.n_head,
    n_country: r.n_country,
    nk: r.nk,
  }));
}

function push(map: Map<string, string[]>, key: string, value: string): void {
  const at = map.get(key);
  if (at) at.push(value);
  else map.set(key, [value]);
}

/**
 * Every city any row in this batch could possibly match, in two or three
 * round trips rather than one scan per row.
 *
 * The label set is the union of every row's n_full and n_head, so the cities
 * this returns are exactly the union of every row's candidate set. Narrowing
 * back down to one row's candidates is done in memory.
 */
export async function loadCityIndex(db: Db, rows: RowKeys[]): Promise<CityIndex> {
  const labels = [
    ...new Set(rows.flatMap((r) => [r.n_full, r.n_head]).filter((s): s is string => s !== null)),
  ];

  const index: CityIndex = {
    byId: new Map(),
    bySlug: new Map(),
    byDisplay: new Map(),
    byAlias: new Map(),
  };
  if (labels.length === 0) return index;

  // Aliases first: city_aliases.alias is stored already normalised, so this is
  // a plain indexed lookup, and it tells the cities query which ids it also
  // has to fetch for a city reachable by alias alone.
  const aliasCityIds = new Set<string>();
  for (const part of chunk(labels, rowsPerStatement(1))) {
    const p = new Params();
    const { rows: found } = await db.query<{ alias: string; city_id: string }>(
      `select alias, city_id from city_aliases where alias in (${p.list(part, "text")})`,
      p.values,
    );
    for (const r of found) {
      push(index.byAlias, r.alias, r.city_id);
      aliasCityIds.add(r.city_id);
    }
  }
  const aliasIds = [...aliasCityIds];

  // One pass over `cities` per chunk. `norm_label` is evaluated per city, not
  // per city per row - that is the whole point of this file.
  // Two placeholder lists plus the alias ids share the statement's parameter
  // budget, hence rowsPerStatement(3) rather than (1).
  for (const part of chunk(labels, rowsPerStatement(3))) {
    const inChunk = new Set(part);
    const p = new Params();
    const { rows: found } = await db.query<
      CityRow & { n_slug: string | null; n_display: string | null }
    >(
      `select c.id as city_id, c.slug as city_slug, c.display, c.country, c.country_iso,
              ${normLabel("c.slug")}    as n_slug,
              ${normLabel("c.display")} as n_display,
              ${normLabel("c.country")} as n_country,
              lower(c.country_iso)      as iso_lower
         from cities c
        where ${normLabel("c.slug")} in (${p.list(part, "text")})
           or ${normLabel("c.display")} in (${p.list(part, "text")})
           or c.id in (${p.list(aliasIds, "text")})`,
      p.values,
    );
    for (const r of found) {
      index.byId.set(r.city_id, {
        city_id: r.city_id,
        city_slug: r.city_slug,
        display: r.display,
        country: r.country,
        country_iso: r.country_iso,
        n_country: r.n_country,
        iso_lower: r.iso_lower,
      });
      // A city can come back for either side, or for neither - it may be here
      // only because an alias points at it. Record the routes that matched.
      if (r.n_slug !== null && inChunk.has(r.n_slug)) push(index.bySlug, r.n_slug, r.city_id);
      if (r.n_display !== null && inChunk.has(r.n_display)) {
        push(index.byDisplay, r.n_display, r.city_id);
      }
    }
  }

  // Chunking can hand the same city back more than once.
  for (const m of [index.bySlug, index.byDisplay, index.byAlias]) {
    for (const [k, ids] of m) m.set(k, [...new Set(ids)]);
  }
  return index;
}

/**
 * Every venue that shares a norm_key with some row in this batch, city joined
 * in for the report. `venues.norm_key` is a stored generated column with an
 * index behind it, so this is a straight index lookup - the venue side was
 * never the slow half, and it stays a set-based query.
 */
export async function loadVenueIndex(db: Db, rows: RowKeys[]): Promise<VenueIndex> {
  const keys = [...new Set(rows.map((r) => r.nk).filter((s): s is string => s !== null))];
  const index: VenueIndex = new Map();
  if (keys.length === 0) return index;

  for (const part of chunk(keys, rowsPerStatement(1))) {
    const p = new Params();
    const { rows: found } = await db.query<VenueRow>(
      `select v.id as venue_id, v.name, v.city_id, v.norm_key,
              c.slug as city_slug, c.display as city_display, v.status::text as status
         from venues v
         join cities c on c.id = v.city_id
        where v.norm_key in (${p.list(part, "text")})`,
      p.values,
    );
    for (const r of found) {
      const at = index.get(r.norm_key);
      if (at) at.push(r);
      else index.set(r.norm_key, [r]);
    }
  }
  return index;
}

/* ---------------------------------------------------------- resolution --- */

/** SQL's `a OR b` over three-valued logic. */
function or3(a: boolean | null, b: boolean | null): boolean | null {
  if (a === true || b === true) return true;
  if (a === false && b === false) return false;
  return null;
}

/** SQL's `bool_or` over a group: true wins, and NULLs are not false. */
function boolOr(values: (boolean | null)[]): boolean | null {
  let sawNull = false;
  for (const v of values) {
    if (v === true) return true;
    if (v === null) sawNull = true;
  }
  return sawNull ? null : false;
}

/**
 * `h.n_country is not null and (norm_label(c.country) = h.n_country
 *                               or lower(c.country_iso) = h.n_country)`
 *
 * NULL = anything is NULL, so a city with no country gives UNKNOWN, not false.
 * That distinction decides whether a row keeps its candidates or loses them
 * all, so it is carried through rather than flattened.
 */
function countryAgrees(city: CityRow, nCountry: string | null): boolean | null {
  if (nCountry === null) return false;
  const byName = city.n_country === null ? null : city.n_country === nCountry;
  const byIso = city.iso_lower === null ? null : city.iso_lower === nCountry;
  return or3(byName, byIso);
}

/** SQL's `min(via)` over the routes one city was found by. */
const minVia = (a: string, b: string) => (a < b ? a : b);

/**
 * The in-memory equivalent of `resolveCities`, candidate for candidate.
 */
export function resolveCitiesInMemory(
  rows: RowKeys[],
  index: CityIndex,
): Map<number, CityResolution> {
  const out = new Map<number, CityResolution>();

  for (const row of rows) {
    // `in (h.n_full, h.n_head)` - both forms, nulls match nothing, and the
    // two are the same value for a label with no comma in it.
    const labels = [...new Set([row.n_full, row.n_head].filter((s): s is string => s !== null))];
    if (labels.length === 0) continue;

    // city id -> via, keeping the alphabetically first via (SQL's min(via))
    const via = new Map<string, string>();
    const route = (map: Map<string, string[]>, name: string) => {
      for (const label of labels) {
        for (const id of map.get(label) ?? []) {
          const at = via.get(id);
          via.set(id, at === undefined ? name : minVia(at, name));
        }
      }
    };
    route(index.bySlug, "slug");
    route(index.byDisplay, "display");
    route(index.byAlias, "alias");

    // No candidate at all: the SQL grouped nothing, so there is no row here
    // either, and the caller reads that back as "city_not_found".
    if (via.size === 0) continue;

    const cities = [...via.keys()]
      .map((id) => index.byId.get(id))
      .filter((c): c is CityRow => c !== undefined);

    const agrees = new Map<string, boolean | null>();
    for (const c of cities) agrees.set(c.city_id, countryAgrees(c, row.n_country));
    const anyAgrees = boolOr(cities.map((c) => agrees.get(c.city_id) ?? null));

    // `where n_country is null or not any_agrees or country_agrees` - kept
    // only when that expression is TRUE, which is where the three-valued
    // logic earns its keep.
    const kept = cities.filter((c) => {
      if (row.n_country === null) return true;
      return anyAgrees === false || agrees.get(c.city_id) === true;
    });
    if (kept.length === 0) continue;

    const candidates: CityCandidate[] = kept
      .map((c) => ({
        city_id: c.city_id,
        city_slug: c.city_slug,
        display: c.display,
        country: c.country,
        country_iso: c.country_iso,
        via: via.get(c.city_id) as string,
      }))
      .sort((a, b) => (a.city_slug < b.city_slug ? -1 : a.city_slug > b.city_slug ? 1 : 0));

    out.set(row.line, {
      candidates,
      // had_country_hint and not any_agrees, over the kept rows
      countryDisagrees: row.n_country !== null && anyAgrees === false,
    });
  }
  return out;
}

/**
 * The in-memory equivalent of `resolveVenues`.
 *
 * `cityIdByLine` is what `setResolvedCities` used to push back into the temp
 * table: the city each row resolved to, after any city decision was applied.
 * It is what makes `same_city` mean anything, and it is why venue resolution
 * still has to happen after city resolution and not beside it.
 */
export function resolveVenuesInMemory(
  rows: RowKeys[],
  cityIdByLine: Map<number, string | null>,
  index: VenueIndex,
): Map<number, VenueCandidate[]> {
  const out = new Map<number, VenueCandidate[]>();

  for (const row of rows) {
    if (row.nk === null) continue; // `where k.nk is not null`
    const found = index.get(row.nk);
    if (found === undefined || found.length === 0) continue; // an inner join

    const cityId = cityIdByLine.get(row.line) ?? null;
    const candidates: VenueCandidate[] = found
      .map((v) => ({
        venue_id: v.venue_id,
        name: v.name,
        city_id: v.city_id,
        city_slug: v.city_slug,
        city_display: v.city_display,
        status: v.status,
        same_city: cityId !== null && v.city_id === cityId,
      }))
      // `order by (v.city_id = k.city_id) desc, v.id`
      .sort(
        (a, b) =>
          Number(b.same_city) - Number(a.same_city) ||
          (a.venue_id < b.venue_id ? -1 : a.venue_id > b.venue_id ? 1 : 0),
      );

    out.set(row.line, candidates);
  }
  return out;
}
