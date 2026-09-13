import { asJson, type Db } from "./db.ts";
import type { RowResult } from "./stageLogic.ts";

/**
 * Reading back what stage wrote.
 *
 * Promote and undo both start from the same place: the verdicts Ben approved,
 * exactly as `stage` stored them. Neither re-resolves anything. One reader, so
 * the rows promote wrote and the rows undo removes can never be derived from
 * two different readings of the same batch.
 */

export interface StagedRow {
  id: string;
  verdict: string;
  validation: {
    line: number;
    input: RowResult["input"];
    city_id: string | null;
    city_slug: string | null;
    venue_id: string | null;
    new_venue_group: string | null;
    venue_category: "restaurant" | "bar" | null;
    venue_status: "active" | "closed" | null;
    candidates?: RowResult["candidates"];
  } | null;
}

export async function readStagedRows(db: Db, batchId: string): Promise<StagedRow[]> {
  const { rows } = await db.query<{ id: string; verdict: string; validation: unknown }>(
    `select id::text, verdict, validation from ingest_rows where batch_id = $1 order by id`,
    [batchId],
  );
  return rows.map((r) => ({
    id: r.id,
    verdict: r.verdict,
    validation: asJson<StagedRow["validation"]>(r.validation, null),
  }));
}

/**
 * Rebuild the row results from what stage wrote. Ordered by CSV line, because
 * the promote plan's grouping took the first line of each new-venue group as
 * that venue's representative row - and undo has to reproduce that choice.
 */
export function toRowResults(rows: StagedRow[]): RowResult[] {
  return rows
    .filter((r) => r.validation !== null)
    .map((r) => {
      const v = r.validation as NonNullable<StagedRow["validation"]>;
      return {
        line: v.line,
        input: v.input,
        checks: [],
        verdict: r.verdict as RowResult["verdict"],
        reason: null,
        detail: null,
        city_id: v.city_id,
        city_slug: v.city_slug,
        venue_id: v.venue_id,
        new_venue_group: v.new_venue_group,
        venue_category: v.venue_category,
        venue_status: v.venue_status,
        venue_category_derived: false,
        candidates: v.candidates ?? { cities: [], venues: [] },
        collides_with: [],
        supersedes: [],
        rank_held_by: [],
        decision: null,
      } satisfies RowResult;
    })
    .sort((a, b) => a.line - b.line);
}
