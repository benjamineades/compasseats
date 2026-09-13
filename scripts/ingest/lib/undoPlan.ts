import { Params, asJson, chunk, type Db } from "./db.ts";
import { PROMOTING_VERDICTS, type RowResult } from "./stageLogic.ts";
import { mintVenueId } from "./slug.ts";

/**
 * The undo plan: exactly what one promoted batch wrote, and nothing else.
 *
 * The plan is derived three independent ways and they all have to agree:
 *
 *   1. the verdicts stage stored (`ingest_rows`) - the list Ben approved,
 *   2. the two columns that carry the key (`city_label_source.note` and
 *      `source_capture_ledger.job`),
 *   3. `audit_log`, filtered to the promote transaction.
 *
 * (3) is exact, and this is why. `audit_log.at` defaults to `now()`, which in
 * Postgres is the *transaction* timestamp and so is identical on every row one
 * transaction writes. Promote's own `update ingest_batches set approved_at =
 * now()` runs inside that same transaction - so `ingest_batches.approved_at` IS
 * the audit timestamp of the promote, and `audit_log where at = approved_at` is
 * the promote's row-level receipt: every venue, award, slug, listing and price
 * row it inserted, with the inserted values in `new_row`.
 *
 * So undo never re-derives an id. It does not re-run the slug mint (that would
 * hand out a different slug now that the batch's own slugs are taken), does not
 * re-resolve a city, does not re-match a venue. It reads the receipt, checks
 * that the receipt still describes the live rows byte for byte, and deletes
 * exactly those rows.
 *
 * Every disagreement is a refusal with the reason named. Nothing adapts.
 */

export interface UndoVenue {
  venue_id: string;
  name: string;
  category: string;
  status: string;
  city_id: string;
  city_slug: string;
  slug: string;
  /** CSV lines whose awards hang on this venue */
  lines: number[];
}

export interface SlugKey {
  property_id: string;
  city_slug: string;
  slug: string;
}

export interface ListingKey {
  venue_id: string;
  property_id: string;
}

export interface UndoCity {
  city_id: string;
  slug: string;
  display: string;
  venuesLeft: number;
  deletable: boolean;
  reason: string;
}

export interface MatchedVenue {
  venue_id: string;
  name: string;
  /** award rows this batch added to it, and so the only rows undo removes */
  awards: number;
  /** award rows it keeps */
  keeps: number;
}

export interface UndoPlan {
  batchKey: string;
  batchId: string;
  /** the promote transaction's timestamp - the audit_log key */
  promotedAt: string;
  /** awards.id values this batch inserted */
  awardIds: string[];
  /** venues this batch created: these go away entirely */
  createdVenues: UndoVenue[];
  /** venues the batch matched: they keep everything except the batch's awards */
  matchedVenues: MatchedVenue[];
  slugs: SlugKey[];
  listings: ListingKey[];
  labelIds: string[];
  ledgerIds: string[];
  ledgerRows: { publisher: string; field_type: string; items: number }[];
  priceVenueIds: string[];
  cities: UndoCity[];
  /** table -> the delta the undo will make to it, never above 0 */
  expected: Record<string, number>;
}

interface AuditRow {
  id: string;
  table_name: string;
  action: string;
  row_pk: string | null;
  new_row: Record<string, unknown> | null;
}

/** The only tables promote inserts into, so the only ones undo deletes from. */
const PROMOTE_TABLES = new Set(["venues", "awards", "slugs", "listings", "price"]);

/** A row in any of these means a batch-created venue has been enriched since. */
const ENRICHMENT_TABLES = ["geo", "addresses", "hours", "blurbs", "photo_refs"] as const;

/** Composite in-memory key separator. Never appears in the data. */
const SEP = "";

function jsonEq(a: unknown, b: unknown): boolean {
  return JSON.stringify(a ?? null) === JSON.stringify(b ?? null);
}

/**
 * Which keys of the receipt no longer match the live row. Keys the live row has
 * and the receipt does not are ignored on purpose: a migration that adds a
 * column between promote and undo must not make every older batch un-undoable.
 */
function changedKeys(receipt: Record<string, unknown>, live: Record<string, unknown>): string[] {
  return Object.keys(receipt)
    .filter((k) => !jsonEq(receipt[k], live[k]))
    .sort();
}

/**
 * `where <col> in (...)`, chunked into numbered placeholders. Bun's client does
 * not bind Postgres array parameters, so every list in this job is built this
 * way - see lib/db.ts.
 */
async function rowsIn<T>(
  db: Db,
  sql: (list: string) => string,
  ids: readonly string[],
  cast = "text",
): Promise<T[]> {
  const out: T[] = [];
  if (ids.length === 0) return out;
  for (const part of chunk(ids, 5000)) {
    const p = new Params();
    const list = p.list(part, cast);
    const { rows } = await db.query<T>(sql(list), p.values);
    out.push(...rows);
  }
  return out;
}

/** Every live row of `table` whose `col` is in `ids`, as plain JSON objects. */
async function liveJson(
  db: Db,
  table: string,
  col: string,
  ids: readonly string[],
  cast = "text",
): Promise<Record<string, unknown>[]> {
  const rows = await rowsIn<{ row: unknown }>(
    db,
    (list) => `select to_jsonb(t) as row from ${table} t where t.${col} in (${list})`,
    ids,
    cast,
  );
  return rows.map((r) => asJson<Record<string, unknown>>(r.row, {}));
}

export interface UndoPlanInput {
  db: Db;
  batchKey: string;
  batchId: string;
  /** ingest_batches.approved_at, as text, to the microsecond */
  promotedAt: string;
  results: RowResult[];
}

export async function buildUndoPlan(
  input: UndoPlanInput,
): Promise<{ plan: UndoPlan; problems: string[] }> {
  const { db, batchKey, batchId, promotedAt, results } = input;
  const problems: string[] = [];
  const refuse = (msg: string) => problems.push(msg);

  /* ====================================================================== */
  /* 1. what stage said this batch would write                              */
  /* ====================================================================== */

  const promoting = results.filter((r) => PROMOTING_VERDICTS.includes(r.verdict));

  interface StagedGroup {
    group: string;
    name: string;
    city_id: string;
    category: string;
    status: string;
    publisher: string;
    city_label: string;
    country_label: string;
    lines: number[];
  }

  // Grouped exactly as buildPlan groups it: the first line of a group is the
  // one whose city_label, country_label and source_id became the venue's.
  const stagedGroups = new Map<string, StagedGroup>();
  for (const r of promoting) {
    if (r.verdict !== "new_venue" || !r.new_venue_group) continue;
    const existing = stagedGroups.get(r.new_venue_group);
    if (existing) {
      existing.lines.push(r.line);
      continue;
    }
    stagedGroups.set(r.new_venue_group, {
      group: r.new_venue_group,
      name: r.input.venue_name,
      city_id: r.city_id ?? "",
      category: r.venue_category ?? "",
      status: r.venue_status ?? "",
      publisher: r.input.source_id,
      city_label: r.input.city_label,
      country_label: r.input.country_label,
      lines: [r.line],
    });
  }

  /* ====================================================================== */
  /* 2. the promote transaction's own receipt                               */
  /* ====================================================================== */

  const { rows: rawAudit } = await db.query<{
    id: string;
    table_name: string;
    action: string;
    row_pk: string | null;
    new_row: unknown;
  }>(
    `select id::text, table_name, action, row_pk, new_row
       from audit_log where at = $1::timestamptz order by id`,
    [promotedAt],
  );
  const audit: AuditRow[] = rawAudit.map((r) => ({
    id: r.id,
    table_name: r.table_name,
    action: r.action,
    row_pk: r.row_pk,
    new_row: asJson<Record<string, unknown> | null>(r.new_row, null),
  }));

  const inserted = (table: string) =>
    audit.filter((a) => a.table_name === table && a.action === "INSERT");

  if (audit.length === 0 && promoting.length > 0) {
    refuse(
      `audit_log holds nothing from the promote transaction (at ${promotedAt}). The undo is ` +
        `driven by that trail, so without it there is nothing safe to reverse. Check that the ` +
        `audit triggers from docs/compass-schema-v1.sql are still on venues, awards, slugs ` +
        `and listings.`,
    );
  }

  for (const a of audit) {
    if (a.action !== "INSERT") {
      refuse(
        `the promote transaction recorded a ${a.action} on ${a.table_name} (${a.row_pk}). ` +
          `Promote only inserts, so something else wrote under the same transaction timestamp ` +
          `and undo cannot tell the two apart.`,
      );
    } else if (!PROMOTE_TABLES.has(a.table_name)) {
      refuse(
        `the promote transaction inserted into ${a.table_name} (${a.row_pk}), which undo does ` +
          `not know how to reverse.`,
      );
    }
  }

  const auditCities = inserted("cities");
  const auditVenues = inserted("venues");
  const auditAwards = inserted("awards");
  const auditSlugs = inserted("slugs");
  const auditListings = inserted("listings");
  const auditPrices = inserted("price");

  /* ====================================================================== */
  /* 3. the receipt has to agree with the staged plan, row for row          */
  /* ====================================================================== */

  const shape = (what: string, got: number, wanted: number) => {
    if (got !== wanted) {
      refuse(
        `the promote trail says ${got} ${what}, the staged batch says ${wanted}. The trail and ` +
          `the report Ben approved do not describe the same promote.`,
      );
    }
  };
  shape("venue row(s)", auditVenues.length, stagedGroups.size);
  shape("award row(s)", auditAwards.length, promoting.length);
  shape("slug row(s)", auditSlugs.length, stagedGroups.size);
  shape("listing row(s)", auditListings.length, stagedGroups.size);

  const slugKey = (r: Record<string, unknown>) =>
    `${String(r.property_id ?? "")}/${String(r.city_slug ?? "")}/${String(r.slug ?? "")}`;
  const listingKey = (r: Record<string, unknown>) =>
    `${String(r.venue_id ?? "")}/${String(r.property_id ?? "")}`;

  const slugByVenue = new Map<string, SlugKey>();
  for (const s of auditSlugs) {
    const r = s.new_row ?? {};
    slugByVenue.set(String(r.venue_id ?? ""), {
      property_id: String(r.property_id ?? ""),
      city_slug: String(r.city_slug ?? ""),
      slug: String(r.slug ?? ""),
    });
  }

  // group -> the venue promote actually created, paired on (name, city_id).
  // new_venue_group is "<city_id>::<norm_key>", so two groups in one city can
  // never carry the same name: the pairing is one to one or it is a refusal.
  const venueIdByGroup = new Map<string, string>();
  const createdVenues: UndoVenue[] = [];
  const pairedVenues = new Set<string>();

  for (const g of stagedGroups.values()) {
    const hit = auditVenues.find(
      (a) =>
        !pairedVenues.has(String(a.row_pk)) &&
        String(a.new_row?.name ?? "") === g.name &&
        String(a.new_row?.city_id ?? "") === g.city_id,
    );
    if (!hit) {
      refuse(
        `the staged batch expected to create "${g.name}" in ${g.city_id}, and the promote ` +
          `trail holds no venue insert matching it.`,
      );
      continue;
    }
    const venueId = String(hit.row_pk);
    pairedVenues.add(venueId);
    venueIdByGroup.set(g.group, venueId);

    const slug = slugByVenue.get(venueId);
    if (!slug) {
      refuse(`the promote trail created ${venueId} ("${g.name}") with no slug row.`);
      continue;
    }
    // The id promote minted is a pure function of (city_slug, slug). Recomputing
    // it proves this venue row was minted by this promote for this slug, rather
    // than paired with it by coincidence of name.
    const minted = mintVenueId(slug.city_slug, slug.slug);
    if (minted !== venueId) {
      refuse(
        `${venueId} ("${g.name}") does not mint from /${slug.city_slug}/${slug.slug} ` +
          `(that mints ${minted}). The promote trail is not self-consistent, and undo will not ` +
          `guess which row belongs to this batch.`,
      );
      continue;
    }
    if (String(hit.new_row?.category ?? "") !== g.category) {
      refuse(
        `${venueId} ("${g.name}") was promoted as ${hit.new_row?.category}; the staged batch ` +
          `says ${g.category}.`,
      );
    }
    if (String(hit.new_row?.status ?? "") !== g.status) {
      refuse(
        `${venueId} ("${g.name}") was promoted as ${hit.new_row?.status}; the staged batch ` +
          `says ${g.status}.`,
      );
    }

    createdVenues.push({
      venue_id: venueId,
      name: g.name,
      category: g.category,
      status: g.status,
      city_id: g.city_id,
      city_slug: slug.city_slug,
      slug: slug.slug,
      lines: g.lines,
    });
  }

  for (const a of auditVenues) {
    if (!pairedVenues.has(String(a.row_pk))) {
      refuse(
        `the promote trail created venue ${a.row_pk} ("${a.new_row?.name}"), which the staged ` +
          `batch does not account for.`,
      );
    }
  }

  const createdIds = createdVenues.map((v) => v.venue_id);
  const createdSet = new Set(createdIds);

  /* ---- the awards, by natural key, against what stage approved ---------- */

  const venueFor = (r: RowResult): string =>
    r.verdict === "new_venue"
      ? (venueIdByGroup.get(r.new_venue_group ?? "") ?? "")
      : (r.venue_id ?? "");

  // The awards table's own uniqueness key. Two award rows with this tuple equal
  // cannot both exist, so matching on it is exact.
  const awardKey = (x: {
    venue_id: string;
    source_id: string;
    year: number | null;
    rank: number | null;
    category: string | null;
    distinction: string | null;
  }) => [x.venue_id, x.source_id, x.year, x.rank, x.category, x.distinction].join(SEP);

  const num = (v: unknown): number | null =>
    v === null || v === undefined || v === "" ? null : Number(v);
  const str = (v: unknown): string | null => (v === null || v === undefined ? null : String(v));

  const stagedAwards = new Map<string, number[]>();
  for (const r of promoting) {
    const k = awardKey({
      venue_id: venueFor(r),
      source_id: r.input.source_id,
      year: num(r.input.year.trim()),
      rank: num(r.input.rank.trim()),
      category: r.input.category.trim() === "" ? null : r.input.category,
      distinction: r.input.distinction.trim() === "" ? null : r.input.distinction,
    });
    stagedAwards.set(k, [...(stagedAwards.get(k) ?? []), r.line]);
  }

  const awardIds: string[] = [];
  const awardVenue = new Map<string, string>();
  const unmatched = new Map([...stagedAwards].map(([k, v]) => [k, [...v]]));
  for (const a of auditAwards) {
    const row = a.new_row ?? {};
    const k = awardKey({
      venue_id: String(row.venue_id ?? ""),
      source_id: String(row.source_id ?? ""),
      year: num(row.year),
      rank: num(row.rank),
      category: str(row.category),
      distinction: str(row.distinction),
    });
    const lines = unmatched.get(k);
    if (!lines || lines.length === 0) {
      refuse(
        `the promote trail inserted awards.id ${a.row_pk} (${row.source_id} ${row.year} on ` +
          `${row.venue_id}), which no staged row of this batch accounts for.`,
      );
      continue;
    }
    lines.shift();
    if (lines.length === 0) unmatched.delete(k);
    if (!/^[0-9]+$/.test(String(a.row_pk ?? ""))) {
      refuse(`the promote trail holds a non-numeric awards id (${a.row_pk}).`);
      continue;
    }
    awardIds.push(String(a.row_pk));
    awardVenue.set(String(a.row_pk), String(row.venue_id ?? ""));
  }
  for (const [k, lines] of unmatched) {
    const [venueId, sourceId] = k.split(SEP);
    refuse(
      `line(s) ${lines.join(", ")} were approved to promote (${sourceId} on ${venueId}) and the ` +
        `promote trail holds no matching award insert.`,
    );
  }

  /* ====================================================================== */
  /* 4. every row on the receipt still has to be the row that is live       */
  /* ====================================================================== */

  const compare = (
    label: string,
    receipts: AuditRow[],
    live: Record<string, unknown>[],
    keyOf: (row: Record<string, unknown>) => string,
  ) => {
    const byKey = new Map(live.map((r) => [keyOf(r), r]));
    for (const a of receipts) {
      const receipt = a.new_row ?? {};
      const found = byKey.get(keyOf(receipt));
      if (!found) {
        refuse(
          `the ${label} row this batch created (${keyOf(receipt)}) is not there any more. ` +
            `Something removed it after the promote, and undo will not guess what else moved.`,
        );
        continue;
      }
      const moved = changedKeys(receipt, found);
      if (moved.length > 0) {
        refuse(
          `the ${label} row ${keyOf(receipt)} has changed since the promote: ` +
            moved
              .map((k) => `${k} ${JSON.stringify(receipt[k])} -> ${JSON.stringify(found[k])}`)
              .join("; ") +
            `. Undo reverses a promote, not a promote plus a hand edit.`,
        );
      }
    }
  };

  const liveVenues = await liveJson(db, "venues", "id", createdIds);
  const liveAwards = await liveJson(db, "awards", "id", awardIds, "bigint");
  const liveSlugs = await liveJson(db, "slugs", "venue_id", createdIds);
  const liveListings = await liveJson(db, "listings", "venue_id", createdIds);
  const priceVenueIds = auditPrices.map((a) => String(a.new_row?.venue_id ?? ""));
  const livePrice = await liveJson(db, "price", "venue_id", [
    ...new Set([...createdIds, ...priceVenueIds]),
  ]);

  compare("venue", auditVenues, liveVenues, (r) => String(r.id ?? ""));
  compare("award", auditAwards, liveAwards, (r) => String(r.id ?? ""));
  compare("slug", auditSlugs, liveSlugs, slugKey);
  compare("listing", auditListings, liveListings, listingKey);
  compare("price", auditPrices, livePrice, (r) => String(r.venue_id ?? ""));

  /* ====================================================================== */
  /* 5. nothing outside the receipt may lean on a venue the batch created    */
  /* ====================================================================== */

  const auditSlugKeys = new Set(auditSlugs.map((a) => slugKey(a.new_row ?? {})));
  for (const r of liveSlugs) {
    if (!auditSlugKeys.has(slugKey(r))) {
      refuse(
        `/${r.city_slug}/${r.slug} (${r.property_id}) was added to ${r.venue_id} after the ` +
          `promote. A URL this batch's venue did not arrive with is somebody's decision, not ` +
          `this batch's to delete.`,
      );
    }
  }

  const auditListingKeys = new Set(auditListings.map((a) => listingKey(a.new_row ?? {})));
  for (const r of liveListings) {
    if (!auditListingKeys.has(listingKey(r))) {
      refuse(
        `${r.venue_id} was listed on property "${r.property_id}" after the promote. Undo ` +
          `removes only the listing the batch created.`,
      );
    }
  }

  const auditPriceSet = new Set(priceVenueIds);
  for (const r of livePrice) {
    const vid = String(r.venue_id ?? "");
    if (createdSet.has(vid) && !auditPriceSet.has(vid)) {
      refuse(`${vid} gained a price row after the promote (publisher ${r.publisher}).`);
    }
  }

  // an award added to a batch-created venue by another batch
  const awardIdSet = new Set(awardIds);
  const onCreated = await rowsIn<{
    id: string;
    venue_id: string;
    source_id: string;
    year: number | null;
  }>(
    db,
    (list) =>
      `select a.id::text as id, a.venue_id, a.source_id, a.year
         from awards a where a.venue_id in (${list})`,
    createdIds,
  );
  for (const a of onCreated) {
    if (!awardIdSet.has(String(a.id))) {
      refuse(
        `${a.venue_id} carries awards.id ${a.id} (${a.source_id} ${a.year ?? "no year"}), which ` +
          `this batch did not add. Deleting the venue would take another batch's award with it, ` +
          `so this batch cannot be undone until that award is moved or removed.`,
      );
    }
  }

  // enrichment: anything a Phase 3 job or a hand pass has attached since
  for (const table of ENRICHMENT_TABLES) {
    const hits = await rowsIn<{ venue_id: string }>(
      db,
      (list) => `select venue_id from ${table} where venue_id in (${list})`,
      createdIds,
    );
    for (const h of hits) {
      refuse(
        `${h.venue_id} has a ${table} row. The batch did not write it and deleting the venue ` +
          `would delete it, so undo refuses rather than take work that is not its own.`,
      );
    }
  }

  // a slug that gained a redirect
  if (createdVenues.length > 0) {
    const p = new Params();
    const values = p.rows(
      createdVenues.map((v) => [`%/${v.city_slug}/${v.slug}`, v.venue_id]),
      ["text", "text"],
    );
    const { rows } = await db.query<{ from_path: string; to_path: string; venue_id: string }>(
      `select r.from_path, r.to_path, t.venue_id
         from (values ${values}) as t(pattern, venue_id)
         join redirects r on r.from_path like t.pattern or r.to_path like t.pattern`,
      p.values,
    );
    for (const r of rows) {
      refuse(
        `${r.venue_id}'s URL is named by a redirect (${r.from_path} -> ${r.to_path}). A URL ` +
          `that has gained a redirect is answering for something, and undo will not delete it.`,
      );
    }
  }

  /* ====================================================================== */
  /* 6. city_label_source - the batch key's own column                      */
  /* ====================================================================== */

  const labelRows = await db.query<{
    id: string;
    venue_id: string;
    label: string;
    from_column: string;
    publisher: string | null;
    note: string | null;
  }>(
    `select id::text, venue_id, label, from_column::text as from_column, publisher, note
       from city_label_source where note = $1 order by id`,
    [batchKey],
  );
  // Labels on a batch-created venue that this batch did not write. Every value
  // is bound, never spliced: `key` is placed before the id list so the numbered
  // placeholders line up.
  const otherLabels: {
    id: string;
    venue_id: string;
    from_column: string;
    note: string | null;
  }[] = [];
  for (const part of chunk(createdIds, 5000)) {
    const p = new Params();
    const key = p.add(batchKey);
    const list = p.list(part, "text");
    const { rows } = await db.query<(typeof otherLabels)[number]>(
      `select id::text, venue_id, from_column::text as from_column, note
         from city_label_source
        where venue_id in (${list}) and (note is null or note <> ${key})
        order by id`,
      p.values,
    );
    otherLabels.push(...rows);
  }

  const labelIds: string[] = [];
  const gotLabels = new Map<string, number>();
  for (const l of labelRows.rows) {
    if (!createdSet.has(l.venue_id)) {
      refuse(
        `city_label_source ${l.id} carries this batch key but hangs on ${l.venue_id}, which the ` +
          `batch did not create.`,
      );
      continue;
    }
    labelIds.push(l.id);
    const k = [l.venue_id, l.label, l.from_column, l.publisher ?? ""].join(SEP);
    gotLabels.set(k, (gotLabels.get(k) ?? 0) + 1);
  }
  for (const l of otherLabels) {
    refuse(
      `${l.venue_id} gained a city label after the promote (note ${JSON.stringify(l.note)}, ` +
        `from ${l.from_column}).`,
    );
  }

  // and the labels there have to be the labels the approved plan called for
  const wantLabels = new Map<string, number>();
  for (const g of stagedGroups.values()) {
    const venueId = venueIdByGroup.get(g.group);
    if (!venueId) continue;
    const push = (label: string, from: string) => {
      const k = [venueId, label, from, g.publisher].join(SEP);
      wantLabels.set(k, (wantLabels.get(k) ?? 0) + 1);
    };
    if (g.city_label.trim() !== "") push(g.city_label, "city_display");
    if (g.country_label.trim() !== "") push(g.country_label, "country");
  }
  const labelMismatch = (k: string, got: number, wanted: number) => {
    const [venueId, label, from] = k.split(SEP);
    refuse(
      `city_label_source holds ${got} "${label}" (${from}) row(s) for ${venueId} under this ` +
        `batch key; the staged batch wrote ${wanted}.`,
    );
  };
  for (const [k, n] of wantLabels) {
    if ((gotLabels.get(k) ?? 0) !== n) labelMismatch(k, gotLabels.get(k) ?? 0, n);
  }
  for (const [k, n] of gotLabels) {
    if (!wantLabels.has(k)) labelMismatch(k, n, 0);
  }

  /* ====================================================================== */
  /* 7. source_capture_ledger - the other column that carries the key       */
  /* ====================================================================== */

  const job = `ingest-promote:${batchKey}`;
  const { rows: ledger } = await db.query<{
    id: string;
    publisher: string;
    field_type: string;
    items: number;
  }>(
    `select id::text, publisher, field_type, items from source_capture_ledger
      where job = $1 order by publisher, field_type`,
    [job],
  );

  const wantLedger = new Map<string, number>();
  const bump = (publisher: string, field: string) => {
    const k = `${publisher}${SEP}${field}`;
    wantLedger.set(k, (wantLedger.get(k) ?? 0) + 1);
  };
  for (const a of auditAwards) bump(String(a.new_row?.source_id ?? ""), "award");
  for (const g of stagedGroups.values()) {
    if (!venueIdByGroup.has(g.group)) continue;
    if (g.city_label.trim() !== "") bump(g.publisher, "city_label");
    if (g.country_label.trim() !== "") bump(g.publisher, "city_label");
  }
  for (const a of auditPrices) bump(String(a.new_row?.publisher ?? ""), "price");

  const gotLedger = new Map<string, number>();
  for (const l of ledger) gotLedger.set(`${l.publisher}${SEP}${l.field_type}`, Number(l.items));

  const ledgerMismatch = (k: string, got: number, wanted: number) => {
    const [publisher, field] = k.split(SEP);
    refuse(
      `the exposure ledger for ${publisher} / ${field} under job ${job} reads ${got}; this ` +
        `batch wrote ${wanted}.`,
    );
  };
  for (const [k, n] of wantLedger) {
    if ((gotLedger.get(k) ?? 0) !== n) ledgerMismatch(k, gotLedger.get(k) ?? 0, n);
  }
  for (const [k, n] of gotLedger) {
    if (!wantLedger.has(k)) ledgerMismatch(k, n, 0);
  }

  /* ====================================================================== */
  /* 8. cities                                                              */
  /* ====================================================================== */

  // Promote never creates a city - docs/ingest-job.md, "Things this job will
  // never do". This reads the receipt rather than assuming it, so the number in
  // the report is measured every time.
  const cities: UndoCity[] = [];
  const cityRows = await rowsIn<{
    id: string;
    slug: string;
    display: string;
    venues: string;
    aliases: string;
  }>(
    db,
    (list) =>
      `select c.id, c.slug, c.display,
              (select count(*)::text from venues v where v.city_id = c.id) as venues,
              (select count(*)::text from city_aliases a where a.city_id = c.id) as aliases
         from cities c where c.id in (${list}) order by c.id`,
    auditCities.map((a) => String(a.row_pk)),
  );
  for (const r of cityRows) {
    // venues this undo is about to delete no longer count against the city
    const going = createdVenues.filter((v) => v.city_id === r.id).length;
    const left = Number(r.venues) - going;
    const aliases = Number(r.aliases);
    const deletable = left === 0 && aliases === 0;
    cities.push({
      city_id: r.id,
      slug: r.slug,
      display: r.display,
      venuesLeft: left,
      deletable,
      reason: deletable
        ? "created by this batch and left holding 0 venues"
        : left > 0
          ? `still holds ${left} venue(s) this batch did not create - kept`
          : `has ${aliases} city_aliases row(s) - kept`,
    });
  }

  /* ====================================================================== */
  /* 9. matched venues keep everything but this batch's awards              */
  /* ====================================================================== */

  const matchedIds = [
    ...new Set(promoting.filter((r) => r.verdict === "match").map((r) => r.venue_id ?? "")),
  ].filter((v) => v !== "" && !createdSet.has(v));

  const matchedRows = await rowsIn<{ id: string; name: string; total: string }>(
    db,
    (list) =>
      `select v.id, v.name,
              (select count(*)::text from awards a where a.venue_id = v.id) as total
         from venues v where v.id in (${list}) order by v.id`,
    matchedIds,
  );
  const mineByVenue = new Map<string, number>();
  for (const v of awardVenue.values()) mineByVenue.set(v, (mineByVenue.get(v) ?? 0) + 1);

  const matchedVenues: MatchedVenue[] = matchedRows.map((r) => {
    const mine = mineByVenue.get(r.id) ?? 0;
    return { venue_id: r.id, name: r.name, awards: mine, keeps: Number(r.total) - mine };
  });
  for (const id of matchedIds) {
    if (!matchedRows.some((r) => r.id === id)) {
      refuse(`${id} was matched by this batch and is no longer in venues.`);
    }
  }

  const plan: UndoPlan = {
    batchKey,
    batchId,
    promotedAt,
    awardIds,
    createdVenues,
    matchedVenues,
    slugs: auditSlugs.map((a) => ({
      property_id: String(a.new_row?.property_id ?? ""),
      city_slug: String(a.new_row?.city_slug ?? ""),
      slug: String(a.new_row?.slug ?? ""),
    })),
    listings: auditListings.map((a) => ({
      venue_id: String(a.new_row?.venue_id ?? ""),
      property_id: String(a.new_row?.property_id ?? ""),
    })),
    labelIds,
    ledgerIds: ledger.map((l) => l.id),
    ledgerRows: ledger.map((l) => ({
      publisher: l.publisher,
      field_type: l.field_type,
      items: Number(l.items),
    })),
    priceVenueIds,
    cities,
    expected: {
      venues: -createdVenues.length,
      awards: -awardIds.length,
      listings: -auditListings.length,
      slugs: -auditSlugs.length,
      city_label_source: -labelIds.length,
      price: -priceVenueIds.length,
      source_capture_ledger: -ledger.length,
      cities: -cities.filter((c) => c.deletable).length,
    },
  };

  return { plan, problems };
}
