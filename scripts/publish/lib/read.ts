import type { Db } from "../../ingest/lib/db.ts";

/**
 * Everything the publish job reads, in ONE read-only transaction.
 *
 * `BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY` gives one snapshot: every
 * query below sees the database as it was at the first one, so a batch that
 * lands half way through a build cannot give the files half of itself. READ
 * ONLY makes Postgres itself refuse any write for the life of the transaction,
 * so the "no database write" rule does not rest on this code alone. The
 * snapshot records `transaction_read_only` as Postgres reports it, and the
 * manifest carries it.
 *
 * The job writes nothing to the database. Not a ledger row, not an audit row.
 */

export interface SourceRow {
  slug: string;
  display: string;
  status: string;
  attribution_required: string | null;
  render_extended_above: number | null;
}

export interface VenueRow {
  id: string;
  name: string;
  name_native: string | null;
  category: string;
  city_id: string;
  status: string;
  cuisine_tags: string[];
  cuisine_publisher: string | null;
}

export interface VenueStateRow {
  id: string;
  name: string;
  status: string;
  published: boolean;
}

export interface CityRow {
  id: string;
  slug: string;
  display: string;
  country: string | null;
  country_iso: string | null;
  kind: string;
  region_id: string | null;
  lat: number | null;
  lng: number | null;
  venues_count: number;
}

export interface RegionRow {
  id: string;
  slug: string;
  display: string;
}

export interface SlugRow {
  city_slug: string;
  slug: string;
  venue_id: string;
  is_canonical: boolean;
}

export interface AwardRow {
  id: number;
  venue_id: string;
  source_id: string;
  year: number | null;
  rank: number | null;
  category: string | null;
  distinction: string | null;
  source_url: string | null;
}

export interface PriceRow {
  venue_id: string;
  tier: number;
  symbol_raw: string | null;
  currency: string | null;
  source: string;
  publisher: string | null;
}

export interface BlurbRow {
  venue_id: string;
  short: string | null;
  long: string | null;
  version: number;
  status: string;
}

export interface RedirectRow {
  from_path: string;
  to_path: string;
}

export interface ExposureRow {
  publisher: string;
  field_type: string;
  items: number;
}

export interface EnrichmentCount {
  table: string;
  rows: number;
  on_published: number;
}

export interface Snapshot {
  readAt: string;
  transactionReadOnly: string;
  isolation: string;
  ledgerLastId: number | null;
  auditLastId: number | null;
  /** count(*) of active venues with a published eats listing - the gate's database side */
  dbPublishedActive: number;
  sources: SourceRow[];
  /** venues with a published eats listing, any status (the closed-venue gate needs to see a closed one) */
  venues: VenueRow[];
  /** every venue: id, name, status, published - for the live-site compare */
  venueStates: VenueStateRow[];
  cities: CityRow[];
  regions: RegionRow[];
  /** every eats slug row, canonical or not, for every venue */
  slugs: SlugRow[];
  /** award rows of published venues */
  awards: AwardRow[];
  /** price rows of published venues */
  prices: PriceRow[];
  /** every blurb row; the shape step decides which publish (rule Q4) */
  blurbs: BlurbRow[];
  redirects: RedirectRow[];
  exposure: ExposureRow[];
  /** geo, addresses, hours, photo_refs: read and counted, not published (shape not decided) */
  enrichment: EnrichmentCount[];
}

const PUBLISHED = `
  join listings l on l.venue_id = v.id and l.property_id = 'eats' and l.published`;

function num(v: unknown): number | null {
  if (v === null || v === undefined) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function json<T>(v: unknown, fallback: T): T {
  if (v === null || v === undefined) return fallback;
  if (typeof v === "string") return JSON.parse(v) as T;
  return v as T;
}

export async function readSnapshot(db: Db): Promise<Snapshot> {
  await db.query("begin isolation level repeatable read read only");
  try {
    const snap = await readInside(db);
    await db.query("commit");
    return snap;
  } catch (err) {
    await db.query("rollback").catch(() => undefined);
    throw err;
  }
}

async function readInside(db: Db): Promise<Snapshot> {
  const head = (
    await db.query<{
      read_at: string;
      ro: string;
      iso: string;
      ledger: string | null;
      audit: string | null;
      pub_active: string;
    }>(`
      select to_char(now() at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as read_at,
             current_setting('transaction_read_only') as ro,
             current_setting('transaction_isolation') as iso,
             (select max(id) from source_capture_ledger)::text as ledger,
             (select max(id) from audit_log)::text as audit,
             (select count(*) from venues v ${PUBLISHED} where v.status = 'active')::text as pub_active
    `)
  ).rows[0];

  const sources = (
    await db.query<SourceRow>(`
      select slug, display, status::text as status, attribution_required, render_extended_above
        from award_sources order by slug`)
  ).rows.map((r) => ({ ...r, render_extended_above: num(r.render_extended_above) }));

  const venues = (
    await db.query<VenueRow & { cuisine_json: string | null }>(`
      select v.id, v.name, v.name_native, v.category::text as category, v.city_id,
             v.status::text as status, array_to_json(v.cuisine_tags)::text as cuisine_json,
             v.cuisine_publisher
        from venues v ${PUBLISHED}
       order by v.id`)
  ).rows.map((r) => ({
    id: r.id,
    name: r.name,
    name_native: r.name_native,
    category: r.category,
    city_id: r.city_id,
    status: r.status,
    cuisine_tags: json<string[]>(r.cuisine_json, []) ?? [],
    cuisine_publisher: r.cuisine_publisher,
  }));

  const venueStates = (
    await db.query<{ id: string; name: string; status: string; published: boolean | string }>(`
      select v.id, v.name, v.status::text as status, coalesce(l.published, false) as published
        from venues v
        left join listings l on l.venue_id = v.id and l.property_id = 'eats'
       order by v.id`)
  ).rows.map((r) => ({ ...r, published: r.published === true || r.published === "t" }));

  const cities = (
    await db.query<CityRow>(`
      select id, slug, display, country, country_iso::text as country_iso, kind::text as kind,
             region_id, lat, lng, venues_count
        from cities order by id`)
  ).rows.map((r) => ({
    ...r,
    lat: num(r.lat),
    lng: num(r.lng),
    venues_count: Number(r.venues_count),
  }));

  const regions = (await db.query<RegionRow>(`select id, slug, display from regions order by id`))
    .rows;

  const slugs = (
    await db.query<Omit<SlugRow, "is_canonical"> & { is_canonical: boolean | string }>(`
      select city_slug, slug, venue_id, is_canonical
        from slugs where property_id = 'eats'
       order by city_slug, slug`)
  ).rows.map((r) => ({ ...r, is_canonical: r.is_canonical === true || r.is_canonical === "t" }));

  const awards = (
    await db.query<AwardRow>(`
      select a.id::int as id, a.venue_id, a.source_id, a.year, a.rank, a.category, a.distinction,
             a.source_url
        from awards a
        join listings l on l.venue_id = a.venue_id and l.property_id = 'eats' and l.published
       order by a.id`)
  ).rows.map((r) => ({ ...r, id: Number(r.id), year: num(r.year), rank: num(r.rank) }));

  const prices = (
    await db.query<PriceRow>(`
      select p.venue_id, p.tier::int as tier, p.symbol_raw, p.currency, p.source::text as source,
             p.publisher
        from price p
        join listings l on l.venue_id = p.venue_id and l.property_id = 'eats' and l.published
       order by p.venue_id`)
  ).rows.map((r) => ({ ...r, tier: Number(r.tier) }));

  const blurbs = (
    await db.query<BlurbRow>(`
      select venue_id, short, long, version, status from blurbs order by venue_id`)
  ).rows.map((r) => ({ ...r, version: Number(r.version) }));

  const redirects = (
    await db.query<RedirectRow>(`select from_path, to_path from redirects order by from_path`)
  ).rows;

  const exposure = (
    await db.query<ExposureRow>(`
      select publisher, field_type, items::int as items from source_exposure
       order by publisher, field_type`)
  ).rows.map((r) => ({ ...r, items: Number(r.items) }));

  const enrichment: EnrichmentCount[] = [];
  for (const table of ["geo", "addresses", "hours", "photo_refs"]) {
    const { rows } = await db.query<{ rows: string; on_published: string }>(`
      select (select count(*) from ${table})::text as rows,
             (select count(*) from ${table} t
                join listings l on l.venue_id = t.venue_id and l.property_id = 'eats' and l.published
             )::text as on_published`);
    enrichment.push({ table, rows: Number(rows[0].rows), on_published: Number(rows[0].on_published) });
  }

  return {
    readAt: head.read_at,
    transactionReadOnly: head.ro,
    isolation: head.iso,
    ledgerLastId: num(head.ledger),
    auditLastId: num(head.audit),
    dbPublishedActive: Number(head.pub_active),
    sources,
    venues,
    venueStates,
    cities,
    regions,
    slugs,
    awards,
    prices,
    blurbs,
    redirects,
    exposure,
    enrichment,
  };
}
