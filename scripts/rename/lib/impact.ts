import { Params, chunk, type Db } from "../../ingest/lib/db.ts";
import type { SourceRow } from "../../ingest/lib/stageLogic.ts";

/**
 * Everything the rename job reads: the venues it is about to touch, what a
 * rename would reach, and the publisher list.
 *
 * The plan's rule for this job is that it "shows downstream impact first", so
 * every number in here is read from the database at the top of the transaction
 * and printed before the first UPDATE. Nothing in this file writes.
 */

/**
 * The registered publishers. Only the source list, not the category
 * vocabulary the ingest job also needs: a rename carries no category.
 */
export async function loadSources(db: Db): Promise<Map<string, SourceRow>> {
  const { rows } = await db.query<SourceRow>(
    `select slug, status::text as status, price_capable, capture_permission, geo_capable
       from award_sources`,
  );
  return new Map(rows.map((r) => [r.slug, r]));
}

export interface VenueState {
  venue_id: string;
  name: string;
  city_id: string;
  city_slug: string;
  /** the canonical eats slug, or null if the venue somehow has none */
  slug: string | null;
  /** extra non-canonical slugs on the same venue, which a rename also leaves alone */
  other_slugs: number;
}

export async function loadVenueState(
  db: Db,
  venueIds: readonly string[],
): Promise<Map<string, VenueState>> {
  const out = new Map<string, VenueState>();
  if (venueIds.length === 0) return out;

  for (const part of chunk(venueIds, 20000)) {
    const p = new Params();
    const { rows } = await db.query<{
      venue_id: string;
      name: string;
      city_id: string;
      city_slug: string;
      slug: string | null;
      other_slugs: string;
    }>(
      `select v.id as venue_id, v.name, v.city_id, c.slug as city_slug,
              (select s.slug from slugs s
                where s.venue_id = v.id and s.property_id = 'eats' and s.is_canonical
                order by s.slug limit 1) as slug,
              (select count(*) from slugs s
                where s.venue_id = v.id and s.property_id = 'eats'
                  and not s.is_canonical)::text as other_slugs
         from venues v
         join cities c on c.id = v.city_id
        where v.id in (${p.list(part, "text")})`,
      p.values,
    );
    for (const r of rows) {
      out.set(r.venue_id, {
        venue_id: r.venue_id,
        name: r.name,
        city_id: r.city_id,
        city_slug: r.city_slug,
        slug: r.slug,
        other_slugs: Number(r.other_slugs),
      });
    }
  }
  return out;
}

export interface Collision {
  venue_id: string;
  other_id: string;
  other_name: string;
  /** true when the two names already share a norm_key today, rename or no rename */
  already: boolean;
  /** true when the other venue is being renamed by this same batch */
  other_in_batch: boolean;
}

/**
 * Would this rename put two venues in one city under the same `norm_key`?
 *
 * `norm_key` is the database's own dedupe gate, a generated column - never
 * written, only read. The comparison is made against the state the whole batch
 * would leave behind, not against the state today: a batch that renames A to
 * B's name while renaming B to something else creates no collision, and
 * flagging it would send Ben a question with no answer.
 *
 * A NULL norm_key never groups. That is the database's rule for names that
 * reduce to fewer than three letters or digits (every all-CJK name), and this
 * job does not invent a different one.
 */
export async function findCollisions(
  db: Db,
  renames: readonly { venue_id: string; new_name: string }[],
): Promise<Map<string, Collision>> {
  const out = new Map<string, Collision>();
  if (renames.length === 0) return out;

  for (const part of chunk(renames, 5000)) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [r.venue_id, r.new_name]),
      ["text", "text"],
    );
    const { rows } = await db.query<{
      venue_id: string;
      other_id: string;
      other_name: string;
      already: boolean;
      other_in_batch: boolean;
    }>(
      `with batch as (select venue_id, new_name from (values ${values}) as t(venue_id, new_name)),
            scope as (select distinct v.city_id from venues v join batch b on b.venue_id = v.id),
            final as (
              select v.id, v.city_id, v.name as old_name,
                     coalesce(b.new_name, v.name) as name,
                     (b.venue_id is not null) as in_batch
                from venues v
                join scope s on s.city_id = v.city_id
                left join batch b on b.venue_id = v.id
            )
       select a.id as venue_id, o.id as other_id, o.name as other_name,
              (norm_key(a.old_name) is not null
               and norm_key(a.old_name) = norm_key(o.old_name)) as already,
              o.in_batch as other_in_batch
         from final a
         join batch on batch.venue_id = a.id
         join final o
           on o.city_id = a.city_id
          and o.id <> a.id
          and norm_key(a.name) is not null
          and norm_key(o.name) = norm_key(a.name)
        order by a.id, o.id`,
      p.values,
    );
    // One collision per venue is enough to stop the batch; the first other
    // venue, ordered by id, is the one the report names.
    for (const r of rows) {
      if (!out.has(r.venue_id)) {
        out.set(r.venue_id, {
          venue_id: r.venue_id,
          other_id: r.other_id,
          other_name: r.other_name,
          already: r.already,
          other_in_batch: r.other_in_batch,
        });
      }
    }
  }
  return out;
}

export interface VenueImpact {
  venue_id: string;
  /** source_id -> how many award rows that publisher holds on this venue */
  awards: Map<string, number>;
  has_blurb: boolean;
}

export async function loadImpact(
  db: Db,
  venueIds: readonly string[],
): Promise<Map<string, VenueImpact>> {
  const out = new Map<string, VenueImpact>();
  for (const id of venueIds) out.set(id, { venue_id: id, awards: new Map(), has_blurb: false });
  if (venueIds.length === 0) return out;

  for (const part of chunk(venueIds, 20000)) {
    const p = new Params();
    const list = p.list(part, "text");
    const { rows: awards } = await db.query<{ venue_id: string; source_id: string; n: string }>(
      `select venue_id, source_id, count(*)::text as n
         from awards where venue_id in (${list})
        group by 1, 2 order by 1, 2`,
      p.values,
    );
    for (const a of awards) out.get(a.venue_id)?.awards.set(a.source_id, Number(a.n));

    const q = new Params();
    const { rows: blurbs } = await db.query<{ venue_id: string }>(
      `select venue_id from blurbs where venue_id in (${q.list(part, "text")})`,
      q.values,
    );
    for (const b of blurbs) {
      const rec = out.get(b.venue_id);
      if (rec) rec.has_blurb = true;
    }
  }
  return out;
}

export interface NameColumnHit {
  table: string;
  column: string;
  rows: number;
}

export interface NameScan {
  /** every text-shaped column in the public schema that was looked at */
  scanned: number;
  /** the ones holding at least one of these names */
  hits: NameColumnHit[];
  /** jsonb columns, named rather than scanned - see the comment below */
  notScanned: string[];
}

/** Identifiers are read back out of the catalogue, but never trusted blindly. */
const SAFE_IDENT = /^[a-z_][a-z0-9_]*$/;

/**
 * Does any other table keep a venue's name as text?
 *
 * Searched, not assumed: every text, varchar and char column of every base
 * table in `public` is read out of the catalogue and counted against the names
 * this batch is about to change. `venues.name` itself is skipped (it is the
 * column being changed) and so is `venues.norm_key` (generated from it).
 *
 * jsonb columns are named in the report and not scanned. Every one of them is
 * either history - `audit_log.old_row` / `new_row`, `ingest_rows.raw` /
 * `validation`, `rename_rows.detail` - where a name is a record of what was
 * true at the time and must not be rewritten, or a document whose shape a
 * substring match would misreport. Saying which columns were not looked at is
 * the honest half of a scan.
 */
export async function scanNameColumns(db: Db, names: readonly string[]): Promise<NameScan> {
  const { rows: columns } = await db.query<{
    table_name: string;
    column_name: string;
    data_type: string;
  }>(
    `select c.table_name, c.column_name, c.data_type
       from information_schema.columns c
       join information_schema.tables t
         on t.table_schema = c.table_schema
        and t.table_name = c.table_name
        and t.table_type = 'BASE TABLE'
      where c.table_schema = 'public'
        and c.data_type in ('text', 'character varying', 'character', 'jsonb')
      order by 1, 2`,
  );

  const textCols = columns.filter(
    (c) =>
      c.data_type !== "jsonb" &&
      SAFE_IDENT.test(c.table_name) &&
      SAFE_IDENT.test(c.column_name) &&
      !(c.table_name === "venues" && (c.column_name === "name" || c.column_name === "norm_key")),
  );
  const notScanned = columns
    .filter((c) => c.data_type === "jsonb")
    .map((c) => `${c.table_name}.${c.column_name}`);

  if (names.length === 0 || textCols.length === 0) {
    return { scanned: textCols.length, hits: [], notScanned };
  }

  await db.query(`create temp table rename_scan_names (name text) on commit drop`);
  for (const part of chunk(names, 2000)) {
    const p = new Params();
    await db.query(
      `insert into rename_scan_names (name) values ${p.rows(
        part.map((n) => [n]),
        ["text"],
      )}`,
      p.values,
    );
  }

  const hits: NameColumnHit[] = [];
  // One statement per batch of columns rather than one per column: the union
  // keeps the round trips down without making a single query the database has
  // to plan for eighty tables at once.
  for (const part of chunk(textCols, 20)) {
    const sql = part
      .map(
        (c) =>
          `select '${c.table_name}' as t, '${c.column_name}' as c, ` +
          `(select count(*) from public.${c.table_name} x ` +
          `join rename_scan_names n on x.${c.column_name} = n.name)::text as rows`,
      )
      .join(" union all ");
    const { rows } = await db.query<{ t: string; c: string; rows: string }>(sql);
    for (const r of rows) {
      if (Number(r.rows) > 0) hits.push({ table: r.t, column: r.c, rows: Number(r.rows) });
    }
  }

  hits.sort((a, b) => b.rows - a.rows || a.table.localeCompare(b.table));
  return { scanned: textCols.length, hits, notScanned };
}
