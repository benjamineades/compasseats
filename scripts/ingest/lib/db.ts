import { SQL } from "bun";

/**
 * One database connection, from SUPABASE_DB_URL, on Bun's built-in Postgres
 * client. No new package: this repo's bunfig.toml carries a deliberate
 * supply-chain guard, and the ingest job is the last place that should be
 * adding dependencies to the path between a CSV and the live tables.
 *
 * NOTE, and this differs from the brief: a Supabase *service key* cannot do
 * what this job needs. The service key talks to PostgREST, which has no
 * multi-statement transaction - and "the promote step runs in ONE transaction"
 * is non-negotiable (Plan section 03). So the workflows use a direct Postgres
 * connection string instead, held in the repo secret SUPABASE_DB_URL.
 * docs/ingest-job.md says exactly where to copy it from.
 */

export interface Db {
  query<T = Record<string, unknown>>(text: string, params?: unknown[]): Promise<{ rows: T[] }>;
}

export async function connect(): Promise<{ client: Db; close: () => Promise<void> }> {
  const url = process.env.SUPABASE_DB_URL;
  if (!url) {
    throw new Error(
      "SUPABASE_DB_URL is not set. In GitHub Actions it comes from the repo secret " +
        "of that name; locally, export it before running.",
    );
  }
  return connectTo(url);
}

export async function connectTo(url: string): Promise<{ client: Db; close: () => Promise<void> }> {
  const sql = new SQL({ url, max: 1, idleTimeout: 0, maxLifetime: 0 });
  const reserved = await sql.reserve();

  const client: Db = {
    async query<T>(text: string, params: unknown[] = []) {
      const rows = (await reserved.unsafe(text, params)) as unknown as T[];
      return { rows: Array.isArray(rows) ? rows : [] };
    },
  };

  return {
    client,
    close: async () => {
      reserved.release();
      await sql.close();
    },
  };
}

/**
 * Numbered-placeholder builder.
 *
 * Bun's client does not bind Postgres array parameters, so every bulk write in
 * this job is a numbered VALUES list instead. That is also why writes are
 * chunked: Postgres caps a statement at 65,535 parameters, and a Michelin
 * batch is thousands of rows.
 */
export class Params {
  readonly values: unknown[] = [];

  add(value: unknown): string {
    this.values.push(value === undefined ? null : value);
    return `$${this.values.length}`;
  }

  /** `($1,$2),($3,$4)` - casts is one entry per column, or null for no cast. */
  rows(rows: readonly unknown[][], casts: readonly (string | null)[] = []): string {
    return rows
      .map(
        (row) =>
          "(" +
          row
            .map((v, i) => {
              const ph = this.add(v);
              const cast = casts[i];
              return cast ? `${ph}::${cast}` : ph;
            })
            .join(",") +
          ")",
      )
      .join(",");
  }

  /** `$1,$2,$3` - for `where x in (...)`. */
  list(items: readonly unknown[], cast: string | null = null): string {
    if (items.length === 0) return "null";
    return items
      .map((v) => {
        const ph = this.add(v);
        return cast ? `${ph}::${cast}` : ph;
      })
      .join(",");
  }
}

export function chunk<T>(items: readonly T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) out.push(items.slice(i, i + size));
  return out;
}

/** Safe chunk size for a bulk insert, given how many parameters each row uses. */
export function rowsPerStatement(paramsPerRow: number): number {
  return Math.max(1, Math.floor(30000 / Math.max(1, paramsPerRow)));
}

/** The tables whose counts every report states, in report order. */
export const COUNTED_TABLES = [
  "venues",
  "awards",
  "listings",
  "slugs",
  "city_label_source",
  "price",
  "source_capture_ledger",
] as const;

export type TableCounts = Record<string, number> & { venues_active: number };

export async function readCounts(db: Db): Promise<TableCounts> {
  const { rows } = await db.query<{ k: string; n: string }>(`
    select 'venues' k, count(*)::text n from venues
    union all select 'venues_active', count(*)::text from venues where status = 'active'
    union all select 'awards', count(*)::text from awards
    union all select 'listings', count(*)::text from listings
    union all select 'slugs', count(*)::text from slugs
    union all select 'city_label_source', count(*)::text from city_label_source
    union all select 'price', count(*)::text from price
    union all select 'source_capture_ledger', count(*)::text from source_capture_ledger
  `);
  const out: Record<string, number> = {};
  for (const r of rows) out[r.k] = Number(r.n);
  return out as TableCounts;
}

/**
 * The normalisation used for city-label matching, as a SQL fragment.
 * Lowercase, fold accents with the same f_unaccent the database uses for
 * norm_key, reduce every run of non-alphanumerics to a single space, trim.
 * city_aliases.alias is already stored in exactly this shape.
 */
export function normLabel(expr: string): string {
  return `btrim(regexp_replace(lower(f_unaccent(${expr})), '[^a-z0-9]+', ' ', 'g'))`;
}

/** jsonb comes back from the driver as text; parse it once, here. */
export function asJson<T>(value: unknown, fallback: T): T {
  if (value === null || value === undefined) return fallback;
  if (typeof value === "string") {
    try {
      return JSON.parse(value) as T;
    } catch {
      return fallback;
    }
  }
  return value as T;
}
