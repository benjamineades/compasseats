import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

import type { Db } from "../../ingest/lib/db.ts";

/**
 * The bits both rename reports share: the tables they count, how a count is
 * printed, and where the file goes.
 *
 * Every count in a rename report states its population. That is not decoration:
 * "3 venues" and "3 of the 281 in this file" are different facts, and only one
 * of them is checkable.
 */

/**
 * The tables every rename report counts, in report order.
 *
 * `venues` and `awards` are here because a rename must not change either of
 * them; `slugs` because a rename must not change a URL; `blurbs` because the
 * incident this job exists to retire was a rename orphaning one. The last two
 * are the job's own bookkeeping.
 */
export const RENAME_COUNTED_TABLES = [
  "venues",
  "awards",
  "slugs",
  "blurbs",
  "source_capture_ledger",
  "rename_batches",
  "rename_rows",
] as const;

export type RenameCounts = Record<string, number>;

export async function readRenameCounts(db: Db): Promise<RenameCounts> {
  const { rows } = await db.query<{ k: string; n: string }>(`
    select 'venues' k, count(*)::text n from venues
    union all select 'awards', count(*)::text from awards
    union all select 'slugs', count(*)::text from slugs
    union all select 'blurbs', count(*)::text from blurbs
    union all select 'source_capture_ledger', count(*)::text from source_capture_ledger
    union all select 'rename_batches', count(*)::text from rename_batches
    union all select 'rename_rows', count(*)::text from rename_rows
  `);
  const out: RenameCounts = {};
  for (const r of rows) out[r.k] = Number(r.n);
  return out;
}

export function mdTable(headers: string[], rows: string[][]): string {
  const out = [`| ${headers.join(" | ")} |`, `|${headers.map(() => "---").join("|")}|`];
  for (const r of rows) out.push(`| ${r.join(" | ")} |`);
  return out.join("\n");
}

/** Markdown-safe: a name with a pipe in it must not break the table. */
export function cell(value: string): string {
  return value.replace(/\|/g, "\\|");
}

export function tallyBy<T>(items: readonly T[], key: (t: T) => string): Map<string, number> {
  const m = new Map<string, number>();
  for (const it of items) {
    const k = key(it);
    m.set(k, (m.get(k) ?? 0) + 1);
  }
  return new Map([...m.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])));
}

export function writeFile(path: string, body: string): void {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, body, "utf8");
}

export interface Invariant {
  name: string;
  ok: boolean;
  detail: string;
}

export function invariantTable(invariants: readonly Invariant[]): string {
  return mdTable(
    ["check", "result", "detail"],
    invariants.map((v) => [v.name, v.ok ? "pass" : "**FAIL**", v.detail]),
  );
}
