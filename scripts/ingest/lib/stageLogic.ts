import type { Db } from "./db.ts";
import { Params, asJson, chunk, normLabel, rowsPerStatement } from "./db.ts";
import type { InputRow } from "./columns.ts";
import { deriveVenueCategory } from "./columns.ts";

export type Verdict =
  | "match"
  | "new_venue"
  | "duplicate"
  | "subsumed"
  | "reject"
  | "review_city"
  | "review_venue"
  | "skipped";

export const REVIEW_VERDICTS: Verdict[] = ["review_city", "review_venue"];
/** Verdicts that put an award row into the live table at promote. */
export const PROMOTING_VERDICTS: Verdict[] = ["match", "new_venue"];

/** Field separator for composite in-memory keys. Never appears in the data. */
const SEP = "\u0001";

export interface Check {
  check: string;
  pass: boolean;
  reason?: string;
  detail?: string;
}

export interface CityCandidate {
  city_id: string;
  city_slug: string;
  display: string;
  country: string | null;
  country_iso: string | null;
  via: string;
}

export interface CityResolution {
  candidates: CityCandidate[];
  /** a country_label was given and no candidate city agrees with it */
  countryDisagrees: boolean;
}

export interface VenueCandidate {
  venue_id: string;
  name: string;
  city_id: string;
  city_slug: string;
  city_display: string;
  status: string;
  same_city: boolean;
}

export interface RowResult {
  line: number;
  input: InputRow;
  checks: Check[];
  verdict: Verdict;
  reason: string | null;
  detail: string | null;
  city_id: string | null;
  city_slug: string | null;
  venue_id: string | null;
  /** identity for a venue this batch will create; several rows may share one */
  new_venue_group: string | null;
  venue_category: "restaurant" | "bar" | null;
  venue_status: "active" | "closed" | null;
  venue_category_derived: boolean;
  candidates: { cities: CityCandidate[]; venues: VenueCandidate[] };
  /** award ids this row would duplicate, or the distinctions that subsume it */
  collides_with: number[];
  /** existing bare-"Listed" rows this row now outranks - Ben's cleanup list */
  supersedes: number[];
  /** another venue already holds this exact source/year/rank - reported, never blocking */
  rank_held_by: { award_id: number; venue_id: string; venue_name: string }[];
  decision: string | null;
}

export interface SourceRow {
  slug: string;
  status: string;
  price_capable: boolean;
  capture_permission: boolean;
  geo_capable: boolean;
}

export interface Reference {
  sources: Map<string, SourceRow>;
  categories: Map<string, Set<string>>;
}

/**
 * Competitor sites are never a source (Ruling 5) - for accuracy and for
 * provenance. A source_url on one of these hosts fails the row.
 */
const BANNED_HOSTS = ["joinpearl.co", "thebestrestaurantsguide.com", "beliapp.com"];

const RANK_ECHO = /^No\.\s*(\d+)$/i;

export async function loadReference(db: Db): Promise<Reference> {
  const sources = new Map<string, SourceRow>();
  const { rows: srcRows } = await db.query<SourceRow>(
    `select slug, status::text as status, price_capable, capture_permission, geo_capable
       from award_sources`,
  );
  for (const r of srcRows) sources.set(r.slug, r);

  const categories = new Map<string, Set<string>>();
  const { rows: catRows } = await db.query<{ source_id: string; category: string }>(
    `select source_id, category from award_categories`,
  );
  for (const r of catRows) {
    let set = categories.get(r.source_id);
    if (!set) {
      set = new Set();
      categories.set(r.source_id, set);
    }
    set.add(r.category);
  }
  return { sources, categories };
}

function hostOf(url: string): string | null {
  try {
    return new URL(url).hostname.replace(/^www\./, "").toLowerCase();
  } catch {
    return null;
  }
}

/** Combined award label, used by the Batch A subsume rule. */
function labelOf(category: string, distinction: string): string {
  return [category, distinction]
    .filter((s) => s.trim() !== "")
    .join(" ")
    .trim()
    .toLowerCase();
}

function isBareListed(category: string, distinction: string): boolean {
  return labelOf(category, distinction) === "listed";
}

/**
 * Row-level checks, in the order the brief fixes. The first failure sets the
 * verdict and no later check runs.
 */
export function runRowChecks(row: InputRow, ref: Reference): RowResult {
  const checks: Check[] = [];
  const result: RowResult = {
    line: row.line,
    input: row,
    checks,
    verdict: "match", // provisional; resolution decides
    reason: null,
    detail: null,
    city_id: null,
    city_slug: null,
    venue_id: null,
    new_venue_group: null,
    venue_category: null,
    venue_status: null,
    venue_category_derived: false,
    candidates: { cities: [], venues: [] },
    collides_with: [],
    supersedes: [],
    rank_held_by: [],
    decision: null,
  };

  const fail = (check: string, reason: string, detail?: string): RowResult => {
    checks.push({ check, pass: false, reason, detail });
    result.verdict = "reject";
    result.reason = reason;
    result.detail = detail ?? null;
    return result;
  };
  const pass = (check: string, detail?: string) => checks.push({ check, pass: true, detail });

  // 1. the source must be registered
  const src = ref.sources.get(row.source_id);
  if (!src) {
    return fail("source_registered", "source_not_registered", row.source_id || "(blank)");
  }
  pass("source_registered");

  // 2. and active
  if (src.status !== "active") {
    return fail("source_active", "source_suspended", `${row.source_id} is ${src.status}`);
  }
  pass("source_active");

  // 3. every new award row carries a source_url (Ruling 5)
  if (row.source_url.trim() === "") {
    return fail("source_url_present", "missing_source_url");
  }
  pass("source_url_present");

  // 4. competitor sites are never a source (Ruling 5)
  const host = hostOf(row.source_url);
  if (host === null) {
    return fail("source_url_wellformed", "malformed_source_url", row.source_url);
  }
  if (BANNED_HOSTS.some((b) => host === b || host.endsWith(`.${b}`))) {
    return fail("source_url_not_competitor", "competitor_source_url", host);
  }
  pass("source_url_not_competitor", host);

  // 5. year
  const year = Number(row.year);
  if (row.year.trim() === "" || !Number.isInteger(year) || year < 1900 || year > 2100) {
    return fail("year_in_range", "year_out_of_range", row.year || "(blank)");
  }
  pass("year_in_range");

  // 6. rank - blank is allowed (unranked lists)
  let rank: number | null = null;
  if (row.rank.trim() !== "") {
    rank = Number(row.rank);
    if (!Number.isInteger(rank) || rank <= 0) {
      return fail("rank_positive", "rank_not_positive", row.rank);
    }
  }
  pass("rank_positive");

  // 7. category must be in this source's controlled vocabulary.
  //    Exception, documented in the award_categories migration: a category of
  //    the exact form "No. <n>" is accepted when <n> is this row's own rank.
  //    A typo cannot get through - the number has to match the rank.
  if (row.category.trim() !== "") {
    const known = ref.categories.get(row.source_id)?.has(row.category) ?? false;
    const echo = RANK_ECHO.exec(row.category.trim());
    const echoOk = echo !== null && rank !== null && Number(echo[1]) === rank;
    if (!known && !echoOk) {
      return fail("category_known", "unknown_category", row.category);
    }
    pass("category_known", known ? "in vocabulary" : "rank echo");
  } else {
    pass("category_known", "blank");
  }

  // 8. the venue must have a name. venues.name carries CHECK (btrim(name) <> ''),
  //    so a blank one would only surface as a constraint violation inside the
  //    promote transaction, taking every other row in the batch down with it.
  if (row.venue_name.trim() === "") {
    return fail("venue_name_present", "missing_venue_name");
  }
  pass("venue_name_present");

  // 9. venue_category
  if (row.venue_category === "") {
    result.venue_category = deriveVenueCategory(row.source_id);
    result.venue_category_derived = true;
    pass("venue_category_valid", `blank, derived ${result.venue_category} from source`);
  } else if (row.venue_category === "restaurant" || row.venue_category === "bar") {
    result.venue_category = row.venue_category;
    pass("venue_category_valid");
  } else {
    return fail("venue_category_valid", "bad_venue_category", row.venue_category);
  }

  // 10. venue_status - blank means active
  if (row.venue_status === "" || row.venue_status === "active") {
    result.venue_status = "active";
    pass("venue_status_valid");
  } else if (row.venue_status === "closed") {
    result.venue_status = "closed";
    pass("venue_status_valid");
  } else {
    return fail("venue_status_valid", "bad_venue_status", row.venue_status);
  }

  return result;
}

/* ------------------------------------------------------------------------ */
/* City and venue resolution - done in SQL so the normalisation is the       */
/* database's own (f_unaccent, norm_key), never a re-implementation.         */
/* ------------------------------------------------------------------------ */

export async function createStageTemp(db: Db, results: RowResult[]): Promise<void> {
  await db.query(`
    create temp table stage_rows (
      line          int primary key,
      source_id     text,
      venue_name    text,
      city_label    text,
      country_label text,
      city_id       text
    ) on commit drop
  `);
  if (results.length === 0) return;

  for (const part of chunk(results, rowsPerStatement(5))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [
        r.line,
        r.input.source_id,
        r.input.venue_name,
        r.input.city_label,
        r.input.country_label,
      ]),
      ["int", "text", "text", "text", "text"],
    );
    await db.query(
      `insert into stage_rows (line, source_id, venue_name, city_label, country_label)
       values ${values}`,
      p.values,
    );
  }
}

/**
 * Match city_label (+ country_label when present) against cities.slug,
 * cities.display, then city_aliases. The job never creates a city.
 *
 * A label like "London, UK" or "Paris, France" is also tried as just the part
 * before the first comma, with the part after it treated as a country hint -
 * the Award Radar exports use both shapes.
 */
export async function resolveCities(db: Db): Promise<Map<number, CityResolution>> {
  const { rows } = await db.query<{
    line: number;
    cands: CityCandidate[];
    country_disagrees: boolean;
  }>(`
    with lab as (
      select line,
             ${normLabel("city_label")}                    as n_full,
             ${normLabel("split_part(city_label, ',', 1)")} as n_head,
             nullif(btrim(coalesce(
               nullif(btrim(country_label), ''),
               nullif(btrim(split_part(city_label, ',', 2)), '')
             )), '')                                        as country_hint
        from stage_rows
    ),
    hint as (
      select line, n_full, n_head, ${normLabel("country_hint")} as n_country from lab
    ),
    cand as (
      select h.line, c.id as city_id, 'slug' as via from hint h
        join cities c on ${normLabel("c.slug")} in (h.n_full, h.n_head)
      union
      select h.line, c.id, 'display' from hint h
        join cities c on ${normLabel("c.display")} in (h.n_full, h.n_head)
      union
      select h.line, a.city_id, 'alias' from hint h
        join city_aliases a on a.alias in (h.n_full, h.n_head)
    ),
    joined as (
      select cand.line, cand.via, c.id as city_id, c.slug as city_slug,
             c.display, c.country, c.country_iso, h.n_country,
             (h.n_country is not null and (
                ${normLabel("c.country")} = h.n_country
                or lower(c.country_iso) = h.n_country
             )) as country_agrees
        from cand
        join cities c on c.id = cand.city_id
        join hint  h on h.line = cand.line
    ),
    ranked as (
      select j.*, bool_or(country_agrees) over (partition by line) as any_agrees from joined j
    ),
    kept as (
      select line, city_id, city_slug, display, country, country_iso,
             min(via) as via, bool_or(any_agrees) as any_agrees,
             bool_or(n_country is not null) as had_country_hint
        from ranked
       -- A country hint narrows the candidates only when some candidate agrees
       -- with it. When none does, every candidate is kept and the row is
       -- flagged: a label that says London, France is a disagreement to look
       -- at, not a detail to drop.
       where n_country is null or not any_agrees or country_agrees
       group by line, city_id, city_slug, display, country, country_iso
    )
    select line,
           bool_or(had_country_hint and not any_agrees) as country_disagrees,
           jsonb_agg(jsonb_build_object(
             'city_id', city_id, 'city_slug', city_slug, 'display', display,
             'country', country, 'country_iso', country_iso, 'via', via
           ) order by city_slug) as cands
      from kept
     group by line
  `);
  const out = new Map<number, CityResolution>();
  for (const r of rows) {
    out.set(r.line, {
      candidates: asJson<CityCandidate[]>(r.cands, []),
      countryDisagrees: Boolean(r.country_disagrees),
    });
  }
  return out;
}

/**
 * The venue signature ALWAYS includes the city - the Top 500 Bars branch
 * collapse must not recur. The only automatic match is exact norm_key in the
 * resolved city. A norm_key that is NULL (the database's own rule: keys under
 * three characters, which is every all-CJK name) can never auto-match.
 */
export async function resolveVenues(db: Db): Promise<Map<number, VenueCandidate[]>> {
  const { rows } = await db.query<{ line: number; cands: VenueCandidate[] }>(`
    with keyed as (
      select line, city_id, norm_key(venue_name) as nk from stage_rows
    )
    select k.line,
           jsonb_agg(jsonb_build_object(
             'venue_id', v.id, 'name', v.name, 'city_id', v.city_id,
             'city_slug', c.slug, 'city_display', c.display,
             'status', v.status::text,
             'same_city', (v.city_id = k.city_id)
           ) order by (v.city_id = k.city_id) desc, v.id) as cands
      from keyed k
      join venues v on v.norm_key = k.nk
      join cities c on c.id = v.city_id
     where k.nk is not null
     group by k.line
  `);
  const out = new Map<number, VenueCandidate[]>();
  for (const r of rows) out.set(r.line, asJson<VenueCandidate[]>(r.cands, []));
  return out;
}

export async function setResolvedCities(db: Db, results: RowResult[]): Promise<void> {
  const withCity = results.filter((r) => r.city_id);
  if (withCity.length === 0) return;
  for (const part of chunk(withCity, rowsPerStatement(2))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [r.line, r.city_id]),
      ["int", "text"],
    );
    await db.query(
      `update stage_rows s set city_id = v.city_id
         from (values ${values}) as v(line, city_id)
        where s.line = v.line`,
      p.values,
    );
  }
}

/** norm_key for each row, computed by the database's own function. */
export async function normKeys(db: Db): Promise<Map<number, string | null>> {
  const { rows } = await db.query<{ line: number; nk: string | null }>(
    `select line, norm_key(venue_name) as nk from stage_rows`,
  );
  return new Map(rows.map((r) => [r.line, r.nk]));
}

export interface ExistingAward {
  id: number;
  venue_id: string;
  source_id: string;
  year: number | null;
  rank: number | null;
  category: string | null;
  distinction: string | null;
}

export async function loadExistingAwards(db: Db, venueIds: string[]): Promise<ExistingAward[]> {
  if (venueIds.length === 0) return [];
  const out: ExistingAward[] = [];
  for (const part of chunk(venueIds, 5000)) {
    const p = new Params();
    const { rows } = await db.query<ExistingAward>(
      `select id, venue_id, source_id, year, rank, category, distinction
         from awards where venue_id in (${p.list(part, "text")})`,
      p.values,
    );
    out.push(...rows);
  }
  return out;
}

const dedupeKey = (
  venue: string,
  source: string,
  year: number | null,
  rank: number | null,
  category: string | null,
  distinction: string | null,
) => [venue, source, year ?? "", rank ?? "", category ?? "", distinction ?? ""].join(SEP);

/**
 * Award dedupe, the Batch A subsume rule, and within-batch duplicates.
 *
 * The within-batch pass is an addition to the brief and a necessary one: two
 * identical rows in the same CSV would both look new, pass every check, and
 * then collide on awards_no_dupes inside the promote transaction - rolling
 * back the whole batch for a reason nobody could see in the report.
 */
export function applyDedupe(results: RowResult[], existing: ExistingAward[]): void {
  const byKey = new Map<string, number[]>();
  for (const a of existing) {
    const k = dedupeKey(a.venue_id, a.source_id, a.year, a.rank, a.category, a.distinction);
    byKey.set(k, [...(byKey.get(k) ?? []), a.id]);
  }
  const bySourceYear = new Map<string, ExistingAward[]>();
  for (const a of existing) {
    const k = [a.venue_id, a.source_id, a.year ?? ""].join(SEP);
    bySourceYear.set(k, [...(bySourceYear.get(k) ?? []), a]);
  }

  const identity = (r: RowResult) => r.venue_id ?? r.new_venue_group ?? `line:${r.line}`;

  const batchGroups = new Map<string, RowResult[]>();
  for (const r of results) {
    if (!PROMOTING_VERDICTS.includes(r.verdict)) continue;
    const k = [identity(r), r.input.source_id, r.input.year].join(SEP);
    batchGroups.set(k, [...(batchGroups.get(k) ?? []), r]);
  }

  const seenInBatch = new Set<string>();

  for (const r of results) {
    if (!PROMOTING_VERDICTS.includes(r.verdict)) continue;

    const category = r.input.category.trim() === "" ? null : r.input.category;
    const distinction = r.input.distinction.trim() === "" ? null : r.input.distinction;
    const year = r.input.year.trim() === "" ? null : Number(r.input.year);
    const rank = r.input.rank.trim() === "" ? null : Number(r.input.rank);

    // (a) an identical row earlier in this same CSV
    const selfKey = dedupeKey(identity(r), r.input.source_id, year, rank, category, distinction);
    if (seenInBatch.has(selfKey)) {
      r.verdict = "duplicate";
      r.reason = "duplicate_in_batch";
      r.checks.push({ check: "award_dedupe", pass: false, reason: "duplicate_in_batch" });
      continue;
    }
    seenInBatch.add(selfKey);

    // (b) an identical row already live
    if (r.verdict === "match" && r.venue_id) {
      const hits = byKey.get(
        dedupeKey(r.venue_id, r.input.source_id, year, rank, category, distinction),
      );
      if (hits && hits.length > 0) {
        r.verdict = "duplicate";
        r.reason = "duplicate_of_existing_award";
        r.collides_with = hits;
        r.checks.push({
          check: "award_dedupe",
          pass: false,
          reason: "duplicate_of_existing_award",
          detail: `awards.id ${hits.join(", ")}`,
        });
        continue;
      }
    }
    r.checks.push({ check: "award_dedupe", pass: true });

    // (c) Batch A: within one source-year a real distinction subsumes a bare
    //     "Listed". The lower one is skipped; the job never deletes.
    const bare = isBareListed(r.input.category, r.input.distinction);
    const liveGroup = r.venue_id
      ? (bySourceYear.get([r.venue_id, r.input.source_id, year ?? ""].join(SEP)) ?? [])
      : [];
    const batchGroup = (
      batchGroups.get([identity(r), r.input.source_id, r.input.year].join(SEP)) ?? []
    ).filter((o) => o !== r);

    const higherLive = liveGroup.filter(
      (a) => !isBareListed(a.category ?? "", a.distinction ?? ""),
    );
    const higherBatch = batchGroup.filter(
      (o) => !isBareListed(o.input.category, o.input.distinction),
    );

    if (bare && (higherLive.length > 0 || higherBatch.length > 0)) {
      r.verdict = "subsumed";
      r.reason = "subsumed_by_higher_distinction";
      r.collides_with = higherLive.map((a) => a.id);
      r.checks.push({
        check: "batch_a_subsume",
        pass: false,
        reason: "subsumed_by_higher_distinction",
        detail:
          higherLive.length > 0
            ? `venue already holds awards.id ${higherLive.map((a) => a.id).join(", ")}`
            : `this batch carries a higher distinction on line ${higherBatch
                .map((o) => o.line)
                .join(", ")}`,
      });
      continue;
    }

    // The reverse: this row outranks a bare "Listed" already live. It promotes;
    // the existing row is named in the report for Ben's cleanup list.
    if (!bare) {
      const lowerLive = liveGroup.filter((a) =>
        isBareListed(a.category ?? "", a.distinction ?? ""),
      );
      if (lowerLive.length > 0) {
        r.supersedes = lowerLive.map((a) => a.id);
        r.checks.push({
          check: "batch_a_subsume",
          pass: true,
          detail: `outranks existing bare "Listed" awards.id ${r.supersedes.join(", ")} - not deleted`,
        });
        continue;
      }
    }
    r.checks.push({ check: "batch_a_subsume", pass: true });
  }
}

/**
 * A published rank belongs to one venue. If a promoting row claims a
 * (source, year, rank) some other venue already holds, that is worth Ben's
 * eyes - it is exactly the shape of the La Cupula / Bodega El Capricho fix,
 * where an award sits on the wrong venue and has to be moved by hand.
 *
 * This never changes a verdict and never blocks a promote. The job does not
 * move or delete awards. It reports, and Ben decides.
 */
export async function flagRankConflicts(db: Db, results: RowResult[]): Promise<void> {
  const candidates = results.filter(
    (r) => PROMOTING_VERDICTS.includes(r.verdict) && r.input.rank.trim() !== "",
  );
  if (candidates.length === 0) return;

  const triples = [
    ...new Set(candidates.map((r) => [r.input.source_id, r.input.year, r.input.rank].join(SEP))),
  ].map((k) => k.split(SEP));

  const held = new Map<string, { award_id: number; venue_id: string; venue_name: string }[]>();
  for (const part of chunk(triples, rowsPerStatement(3))) {
    const p = new Params();
    const values = p.rows(part, ["text", "int", "int"]);
    const { rows } = await db.query<{
      source_id: string;
      year: number;
      rank: number;
      award_id: number;
      venue_id: string;
      venue_name: string;
    }>(
      `select a.source_id, a.year, a.rank, a.id as award_id, a.venue_id, v.name as venue_name
         from (values ${values}) as t(source_id, year, rank)
         join awards a on a.source_id = t.source_id and a.year = t.year and a.rank = t.rank
         join venues v on v.id = a.venue_id`,
      p.values,
    );
    for (const r of rows) {
      const k = [r.source_id, String(r.year), String(r.rank)].join(SEP);
      held.set(k, [
        ...(held.get(k) ?? []),
        { award_id: Number(r.award_id), venue_id: r.venue_id, venue_name: r.venue_name },
      ]);
    }
  }

  for (const r of candidates) {
    const k = [r.input.source_id, r.input.year, r.input.rank].join(SEP);
    const hits = (held.get(k) ?? []).filter((h) => h.venue_id !== r.venue_id);
    if (hits.length > 0) {
      r.rank_held_by = hits;
      r.checks.push({
        check: "rank_held_elsewhere",
        pass: true,
        detail: `${r.input.source_id} ${r.input.year} #${r.input.rank} is also on ${hits
          .map((h) => `${h.venue_name} (${h.venue_id}, awards.id ${h.award_id})`)
          .join("; ")}`,
      });
    }
  }
}
