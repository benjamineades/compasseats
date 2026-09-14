/**
 * ingest-stage - Award Radar CSV -> staging -> validation report.
 *
 * Writes to ingest_batches and ingest_rows and NOTHING else. No live table is
 * touched here, ever. Re-running with the same batch key prints the batch's
 * status and stops.
 *
 *   bun run scripts/ingest/stage.ts --csv <path> --batch-key <key>
 *                                   [--decisions <path>] [--note <text>]
 *                                   [--out reports]
 */
import { readFileSync } from "node:fs";
import { join } from "node:path";

import { Args } from "./lib/args.ts";
import { parseCsvRecords, toCsv, type CsvRecord } from "./lib/csv.ts";
import {
  IGNORED_COLUMNS,
  buildMapping,
  toInputRow,
  type ColumnMapping,
  type InputRow,
} from "./lib/columns.ts";
import {
  COUNTED_TABLES,
  Params,
  asJson,
  chunk,
  connect,
  readCounts,
  rowsPerStatement,
  type Db,
  type TableCounts,
} from "./lib/db.ts";
import {
  applyCityResolution,
  applyDedupe,
  applyLooseReview,
  applyVenueResolution,
  createStageTemp,
  loadExistingAwards,
  loadReference,
  flagRankConflicts,
  runRowChecks,
  type RowResult,
  type Verdict,
} from "./lib/stageLogic.ts";
import { buildPlan, loadPlanState, type Plan } from "./lib/plan.ts";
import {
  loadCityIndex,
  loadLooseCandidates,
  loadRowKeys,
  loadVenueIndex,
  resolveCitiesInMemory,
  resolveVenuesInMemory,
} from "./lib/resolve.ts";
import { Progress, writeFile } from "./lib/progress.ts";

/* ---------------------------------------------------------------- args --- */

interface StageArgs {
  csv: string;
  batchKey: string;
  decisions?: string;
  note?: string;
  out: string;
}

const USAGE =
  "usage: stage.ts --csv <path> --batch-key <key> [--decisions <path>] [--note <text>] [--out <dir>]";

function parseArgs(argv: string[]): StageArgs {
  const args = new Args(argv);
  return {
    csv: args.required("csv", USAGE),
    batchKey: args.required("batch-key", USAGE),
    decisions: args.optional("decisions") || undefined,
    note: args.optional("note") || undefined,
    out: args.optional("out", "reports"),
  };
}

/* ------------------------------------------------------------- helpers --- */

const REQUIRED_COLUMNS = ["source_id", "year", "source_url", "venue_name", "city_label"];

/**
 * Bun's driver JSON-encodes a string parameter bound to jsonb, which would
 * store the document as a quoted string instead of an object. Going through
 * text first makes the cast explicit and driver-independent.
 */
const JSONB = "text::jsonb";

function tallyBy<T>(items: T[], key: (t: T) => string): Map<string, number> {
  const m = new Map<string, number>();
  for (const it of items) {
    const k = key(it);
    m.set(k, (m.get(k) ?? 0) + 1);
  }
  return new Map([...m.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])));
}

function mdTable(headers: string[], rows: string[][]): string {
  const out = [`| ${headers.join(" | ")} |`, `|${headers.map(() => "---").join("|")}|`];
  for (const r of rows) out.push(`| ${r.join(" | ")} |`);
  return out.join("\n");
}

/* ------------------------------------------------------------- reading --- */

interface LoadedCsv {
  header: string[];
  records: CsvRecord[];
  mapping: ColumnMapping;
  rows: InputRow[];
}

function loadCsv(path: string, batchKey: string): LoadedCsv {
  const { header, records } = parseCsvRecords(readFileSync(path, "utf8"));
  if (header.length === 0) throw new Error(`${path} is empty`);

  const mapping = buildMapping(header);
  const missing = REQUIRED_COLUMNS.filter((c) => !mapping.mapped[c]);
  if (missing.length > 0) {
    throw new Error(
      `${path} has no column for: ${missing.join(", ")}. ` + `Headers found: ${header.join(", ")}`,
    );
  }
  const rows = records.map((rec, i) => toInputRow(rec, mapping, i + 1, batchKey));
  return { header, records, mapping, rows };
}

/**
 * Every row must carry the same batch key. A mismatch aborts before anything
 * is staged - this is the guard against pasting two lists into one file.
 */
function assertBatchKey(rows: InputRow[], mapping: ColumnMapping, batchKey: string): string {
  if (!mapping.mapped.batch_key) {
    return `no batch_key column in the CSV; taken from the workflow input for all ${rows.length} rows`;
  }
  const wrong = rows.filter((r) => r.batch_key !== batchKey);
  if (wrong.length > 0) {
    const sample = wrong.slice(0, 5).map((r) => `line ${r.line}: "${r.batch_key}"`);
    throw new Error(
      `batch_key mismatch. The workflow was given "${batchKey}" but ${wrong.length} ` +
        `row(s) carry something else - ${sample.join("; ")}. Nothing was staged.`,
    );
  }
  return `batch_key column present and equal to "${batchKey}" on every row`;
}

/**
 * A re-stage has to be the SAME CSV the batch was built from. Matching row
 * counts is not enough: ingest_rows.raw is the record of what was reviewed, and
 * re-staging a different file would leave an approval attached to content
 * nobody looked at.
 */
function assertSameCsv(
  batchKey: string,
  staged: { line: number; raw: unknown }[],
  records: CsvRecord[],
): void {
  if (staged.length !== records.length) {
    throw new Error(
      `The CSV has ${records.length} rows but batch "${batchKey}" holds ${staged.length}. ` +
        `Re-staging decisions needs the same CSV the batch was built from.`,
    );
  }
  const canonical = (rec: Record<string, unknown>) =>
    JSON.stringify(
      Object.fromEntries(
        Object.entries(rec)
          .filter(([k]) => k !== "_line")
          .sort(([a], [b]) => a.localeCompare(b)),
      ),
    );

  for (const row of staged) {
    const raw = asJson<Record<string, unknown>>(row.raw, {});
    const fresh = records[Number(row.line) - 1];
    if (fresh === undefined || canonical(raw) !== canonical(fresh)) {
      throw new Error(
        `Line ${row.line} of the CSV does not match what was staged under ` +
          `"${batchKey}". Re-staging decisions needs the same CSV the batch was ` +
          `built from - otherwise a decision you made on one row gets applied to ` +
          `another. Nothing was changed.`,
      );
    }
  }
}

/* ----------------------------------------------------------- decisions --- */

const DECISION_COLUMN = "decision";

function loadDecisions(path: string): Map<number, string> {
  const { records } = parseCsvRecords(readFileSync(path, "utf8"));
  const out = new Map<number, string>();
  for (const rec of records) {
    const line = Number(rec.line ?? rec.row ?? "");
    const decision = (rec[DECISION_COLUMN] ?? "").trim();
    if (Number.isInteger(line) && decision !== "") out.set(line, decision);
  }
  return out;
}

/* ------------------------------------------------------------- staging --- */

async function findBatch(db: Db, batchKey: string) {
  const { rows } = await db.query<{
    id: string;
    status: string;
    source_id: string | null;
    list_year: number | null;
    created_at: string;
    n_rows: string;
  }>(
    `select b.id::text, b.status::text, b.source_id, b.list_year, b.created_at::text,
            (select count(*) from ingest_rows r where r.batch_id = b.id)::text as n_rows
       from ingest_batches b where b.batch_key = $1`,
    [batchKey],
  );
  return rows[0] ?? null;
}

async function insertBatch(
  db: Db,
  batchKey: string,
  sourceId: string | null,
  listYear: number | null,
  note: string | null,
  records: CsvRecord[],
): Promise<{ batchId: string; idByLine: Map<number, string> }> {
  const { rows } = await db.query<{ id: string }>(
    `insert into ingest_batches (batch_key, source_id, list_year, status, note)
     values ($1, $2, $3, 'staged', $4) returning id::text`,
    [batchKey, sourceId, listYear, note],
  );
  const batchId = rows[0].id;

  // raw holds the CSV record exactly as it arrived, plus the line number.
  const idByLine = new Map<number, string>();
  const raws = records.map((rec, i) => JSON.stringify({ ...rec, _line: i + 1 }));

  for (const part of chunk(raws, rowsPerStatement(2))) {
    const p = new Params();
    const values = p.rows(
      part.map((raw) => [batchId, raw]),
      ["bigint", JSONB],
    );
    const { rows: inserted } = await db.query<{ id: string; line: number }>(
      `insert into ingest_rows (batch_id, raw) values ${values}
       returning id::text, (raw->>'_line')::int as line`,
      p.values,
    );
    for (const r of inserted) idByLine.set(Number(r.line), r.id);
  }
  return { batchId, idByLine };
}

async function writeVerdicts(
  db: Db,
  idByLine: Map<number, string>,
  results: RowResult[],
): Promise<void> {
  if (results.length === 0) return;
  const ids: string[] = [];
  const validations: string[] = [];
  const verdicts: string[] = [];
  for (const r of results) {
    const id = idByLine.get(r.line);
    if (!id) continue;
    ids.push(id);
    verdicts.push(r.verdict);
    validations.push(
      JSON.stringify({
        line: r.line,
        input: r.input,
        checks: r.checks,
        reason: r.reason,
        detail: r.detail,
        city_id: r.city_id,
        city_slug: r.city_slug,
        venue_id: r.venue_id,
        new_venue_group: r.new_venue_group,
        venue_category: r.venue_category,
        venue_status: r.venue_status,
        venue_category_derived: r.venue_category_derived,
        candidates: r.candidates,
        collides_with: r.collides_with,
        supersedes: r.supersedes,
        rank_held_by: r.rank_held_by,
        decision: r.decision,
      }),
    );
  }
  const triples = ids.map((id, i) => [id, validations[i], verdicts[i]]);
  for (const part of chunk(triples, rowsPerStatement(3))) {
    const p = new Params();
    const values = p.rows(part, ["bigint", JSONB, "text"]);
    await db.query(
      `update ingest_rows r
          set validation = v.validation, verdict = v.verdict
         from (values ${values}) as v(id, validation, verdict)
        where r.id = v.id`,
      p.values,
    );
  }
}

/* ---------------------------------------------------------------- main --- */

/** The review CSV, written whenever there is anything to review. */
function writeReviewCsv(path: string, results: RowResult[]): number {
  const rows = results.filter((r) => r.verdict === "review_city" || r.verdict === "review_venue");
  if (rows.length > 0) writeFile(path, buildReviewCsv(rows));
  return rows.length;
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const reportPath = join(args.out, `${args.batchKey}-stage.md`);
  const reviewPath = join(args.out, `${args.batchKey}-review.csv`);
  const progress = new Progress(reportPath, args.batchKey);

  // A cancelled run has to leave evidence. `results` is reassigned as soon as
  // the verdicts exist, so both the signal handler and the catch below can
  // write out the review CSV for whatever was resolved before the end came.
  let results: RowResult[] = [];
  const flush = (reason: string) => {
    progress.failed(reason);
    try {
      writeReviewCsv(reviewPath, results);
    } catch {
      /* the report is the thing that matters; never fail inside a failure */
    }
  };

  // GitHub cancels a job with SIGINT, then SIGTERM. Both get the same
  // treatment, and the handler is synchronous because nothing asynchronous is
  // guaranteed to run before the process goes.
  for (const sig of ["SIGINT", "SIGTERM"] as const) {
    process.on(sig, () => {
      console.log(`\n${sig} - writing what this run knows so far to ${reportPath}`);
      flush(`cancelled (${sig})`);
      process.exit(130);
    });
  }

  // Everything from here can fail - a missing CSV, a refused connection, a
  // statement that errors mid-transaction - and every one of those has to
  // leave the same evidence behind: the report, naming the phase it stopped
  // after, and the review CSV if the verdicts had got that far.
  try {
    const loaded = loadCsv(args.csv, args.batchKey);
    progress.phase("read the CSV", `${loaded.rows.length} rows from ${args.csv}`);
    const batchKeyNote = assertBatchKey(loaded.rows, loaded.mapping, args.batchKey);

    const { client: db, close } = await connect();
    progress.phase("opened the database connection");

    try {
      const existing = await findBatch(db, args.batchKey);
      const decisions = args.decisions ? loadDecisions(args.decisions) : null;

      /* --- idempotency: same key, no decisions file => no-op ---------------- */
      if (existing && !decisions) {
        const body =
          `# Ingest stage - no-op\n\n` +
          `Batch key **${args.batchKey}** already exists.\n\n` +
          mdTable(
            ["field", "value"],
            [
              ["batch id", existing.id],
              ["status", existing.status],
              ["source", existing.source_id ?? "(multi-source)"],
              ["list year", existing.list_year?.toString() ?? "(multi-year)"],
              ["staged rows", existing.n_rows],
              ["created", existing.created_at],
            ],
          ) +
          `\n\nNothing was staged and nothing was changed. This is what idempotency ` +
          `looks like: if a run timed out, the work is already here.\n\n` +
          `To apply review decisions to this batch, re-run stage with the same CSV ` +
          `plus \`--decisions <filled review csv>\`.\n`;
        progress.done();
        writeFile(reportPath, body);
        console.log(body);
        return;
      }
      if (!existing && decisions) {
        throw new Error(
          `No batch with key "${args.batchKey}" exists, so there is nothing to apply ` +
            `decisions to. Stage the batch first.`,
        );
      }
      if (existing && decisions && existing.status !== "staged") {
        throw new Error(
          `Batch "${args.batchKey}" is ${existing.status}, not staged. Decisions can only ` +
            `be applied to a staged batch.`,
        );
      }

      /* --- one transaction: stage is atomic too --------------------------- */
      await db.query("BEGIN");

      /* --- batch + rows ----------------------------------------------------- */
      const ref = await loadReference(db);
      progress.phase("read the source vocabulary", `${ref.sources.size} sources`);

      const sourceIds = [...new Set(loaded.rows.map((r) => r.source_id))].sort();
      const years = [...new Set(loaded.rows.map((r) => r.year))].sort();
      // ingest_batches.source_id is a foreign key to award_sources. An unregistered
      // slug has to reach runRowChecks and come back as a reported reject, not
      // blow up the insert before a single row has been looked at.
      const singleSource =
        sourceIds.length === 1 && ref.sources.has(sourceIds[0]) ? sourceIds[0] : null;
      const singleYear = years.length === 1 && /^\d{4}$/.test(years[0]) ? Number(years[0]) : null;

      let batchId: string;
      let idByLine: Map<number, string>;

      if (existing) {
        batchId = existing.id;
        const { rows } = await db.query<{ id: string; line: number; raw: unknown }>(
          `select id::text, (raw->>'_line')::int as line, raw from ingest_rows where batch_id = $1`,
          [batchId],
        );
        idByLine = new Map(rows.map((r) => [Number(r.line), r.id]));
        assertSameCsv(args.batchKey, rows, loaded.records);
        progress.phase("re-read the staged rows", `batch ${batchId}, ${rows.length} rows`);
      } else {
        const created = await insertBatch(
          db,
          args.batchKey,
          singleSource,
          singleYear,
          args.note ?? null,
          loaded.records,
        );
        batchId = created.batchId;
        idByLine = created.idByLine;
        progress.phase("staged the raw rows", `batch ${batchId}, ${idByLine.size} rows`);
      }

      /* --- validate --------------------------------------------------------- */
      results = loaded.rows.map((row, i) => {
        const r = runRowChecks(row, ref);
        progress.tick("checked", i + 1, loaded.rows.length);
        return r;
      });
      const live = results.filter((r) => r.verdict !== "reject");
      progress.phase("row checks", `${live.length} of ${results.length} rows still live`);

      await createStageTemp(db, live);
      progress.phase("loaded the live rows into the resolver", `${live.length} rows`);

      const rowKeys = await loadRowKeys(db);
      progress.phase("normalised the batch", `${rowKeys.length} rows, in the database`);

      const cityIndex = await loadCityIndex(db, rowKeys);
      progress.phase("loaded the candidate cities", `${cityIndex.byId.size} cities`);

      const venueIndex = await loadVenueIndex(db, rowKeys);
      const nVenues = [...venueIndex.values()].reduce((a, v) => a + v.length, 0);
      progress.phase("loaded the candidate venues", `${nVenues} venues`);

      const keys = new Map(rowKeys.map((r) => [r.line, r.nk]));

      applyCityResolution(live, resolveCitiesInMemory(rowKeys, cityIndex), (done, total) =>
        progress.tick("cities", done, total),
      );
      progress.phase(
        "resolved cities",
        `${live.filter((r) => r.city_id).length} of ${live.length} settled on one city`,
      );

      // city decisions, applied before venue resolution: the city a row ends
      // up in is what makes a venue candidate a match
      if (decisions) await applyCityDecisions(db, live, decisions);

      const cityIdByLine = new Map(live.map((r) => [r.line, r.city_id]));
      applyVenueResolution(
        live,
        resolveVenuesInMemory(rowKeys, cityIdByLine, venueIndex),
        keys,
        (done, total) => progress.tick("venues", done, total),
      );
      progress.phase(
        "resolved venues",
        `${live.filter((r) => r.venue_id).length} matched an existing venue`,
      );

      // The loose-name pass, over the rows the exact pass would have created a
      // venue for. It can only send a row to review, never merge it - but a
      // guide that renames "Restaurant Kei" to "Kei" must not quietly land a
      // second Kei in Paris.
      const wouldCreate = live
        .filter((r) => r.verdict === "new_venue" && r.city_id)
        .map((r) => ({
          line: r.line,
          venue_name: r.input.venue_name,
          city_id: r.city_id as string,
        }));
      const loose = await loadLooseCandidates(db, wouldCreate);
      applyLooseReview(live, loose);
      progress.phase(
        "loose-name pass",
        `${wouldCreate.length} would-be new venues checked, ` +
          `${live.filter((r) => r.reason === "loose_key_candidate_in_city").length} sent to review`,
      );

      // venue decisions
      if (decisions) await applyVenueDecisions(db, live, decisions, keys);

      /* --- dedupe and subsume ----------------------------------------------- */
      const matchedIds = [
        ...new Set(live.filter((r) => r.venue_id).map((r) => r.venue_id as string)),
      ];
      applyDedupe(results, await loadExistingAwards(db, matchedIds));
      await flagRankConflicts(db, results);
      progress.phase("dedupe, subsume and rank conflicts");

      // The verdicts are final from here, so the review CSV can be written now
      // rather than after the commit. If the run dies in the next few seconds,
      // the file Ben needs is already on disk.
      const reviewCount = writeReviewCsv(reviewPath, results);

      /* --- plan and expected counts ----------------------------------------- */
      const citySlugs = [...new Set(live.map((r) => r.city_slug).filter(Boolean) as string[])];
      const planState = await loadPlanState(db, citySlugs, matchedIds);
      const plan = buildPlan({
        batchKey: args.batchKey,
        results,
        sources: ref.sources,
        ...planState,
      });
      const before = await readCounts(db);
      progress.phase(
        "built the promote plan",
        `${plan.venues.length} venues, ${plan.awards.length} awards`,
      );

      /* --- persist verdicts -------------------------------------------------- */
      await writeVerdicts(db, idByLine, results);
      progress.phase("wrote the verdicts", `${results.length} rows`);

      await db.query("COMMIT");
      progress.phase("committed");

      /* --- report and review CSV --------------------------------------------- */
      const report = buildReport({
        args,
        batchId,
        loaded,
        batchKeyNote,
        sourceIds,
        years,
        results,
        plan,
        before,
        ref,
        reviewRows: reviewCount,
        reviewPath,
        reStaged: Boolean(existing),
        decisionsApplied: decisions ? [...decisions.keys()].length : 0,
        timings: progress.timingRows(),
      });
      progress.done();
      writeFile(reportPath, report);
      console.log(report);
    } catch (err) {
      // Nothing half-staged: the batch row and its ingest_rows land together or
      // not at all.
      try {
        await db.query("ROLLBACK");
      } catch {
        /* not inside a transaction */
      }
      throw err;
    } finally {
      await close();
    }
  } catch (err) {
    flush(err instanceof Error ? err.message : String(err));
    throw err;
  }
}

/* ------------------------------------------------------------ decisions --- */

function decisionParts(raw: string): string[] {
  return raw
    .split(";")
    .map((s) => s.trim())
    .filter((s) => s !== "");
}

async function applyCityDecisions(
  db: Db,
  live: RowResult[],
  decisions: Map<number, string>,
): Promise<void> {
  const wanted = new Set<string>();
  for (const raw of decisions.values()) {
    for (const part of decisionParts(raw)) {
      if (part.startsWith("city:")) wanted.add(part.slice(5));
    }
  }
  if (wanted.size === 0) return;
  const q = new Params();
  const { rows } = await db.query<{ id: string; slug: string }>(
    `select id, slug from cities where id in (${q.list([...wanted], "text")})`,
    q.values,
  );
  const cityById = new Map(rows.map((r) => [r.id, r.slug]));

  for (const r of live) {
    const raw = decisions.get(r.line);
    if (!raw) continue;
    const part = decisionParts(raw).find((p) => p.startsWith("city:"));
    if (!part) continue;
    const cityId = part.slice(5);
    const slug = cityById.get(cityId);
    if (!slug) {
      r.verdict = "review_city";
      r.reason = "decision_city_not_found";
      r.detail = cityId;
      r.decision = raw;
      continue;
    }
    r.city_id = cityId;
    r.city_slug = slug;
    r.decision = raw;
    r.verdict = "match"; // provisional again; venue resolution decides
    r.reason = null;
    r.checks.push({ check: "city_resolved", pass: true, detail: `decision city:${cityId}` });
  }
}

async function applyVenueDecisions(
  db: Db,
  live: RowResult[],
  decisions: Map<number, string>,
  keys: Map<number, string | null>,
): Promise<void> {
  const wanted = new Set<string>();
  for (const raw of decisions.values()) {
    for (const part of decisionParts(raw)) {
      if (part.startsWith("use:")) wanted.add(part.slice(4));
    }
  }
  const venueById = new Map<string, { city_id: string }>();
  if (wanted.size > 0) {
    const q = new Params();
    const { rows } = await db.query<{ id: string; city_id: string }>(
      `select id, city_id from venues where id in (${q.list([...wanted], "text")})`,
      q.values,
    );
    for (const r of rows) venueById.set(r.id, { city_id: r.city_id });
  }

  for (const r of live) {
    const raw = decisions.get(r.line);
    if (!raw) continue;
    r.decision = raw;

    for (const part of decisionParts(raw)) {
      if (part === "skip") {
        r.verdict = "skipped";
        r.reason = "skipped_by_decision";
        r.checks.push({ check: "decision", pass: true, detail: "skip" });
      } else if (part === "new") {
        if (!r.city_id) {
          r.verdict = "review_city";
          r.reason = "decision_new_needs_city";
          continue;
        }
        const nk = keys.get(r.line) ?? null;
        r.verdict = "new_venue";
        r.reason = null;
        // a NULL norm_key still needs a group; the name itself is the identity
        r.new_venue_group = `${r.city_id}::${nk ?? r.input.venue_name.toLowerCase()}`;
        r.venue_id = null;
        r.checks.push({ check: "decision", pass: true, detail: "new" });
      } else if (part.startsWith("use:")) {
        const venueId = part.slice(4);
        const v = venueById.get(venueId);
        if (!v) {
          r.verdict = "review_venue";
          r.reason = "decision_venue_not_found";
          r.detail = venueId;
          continue;
        }
        r.verdict = "match";
        r.reason = null;
        r.venue_id = venueId;
        r.new_venue_group = null;
        r.checks.push({
          check: "decision",
          pass: true,
          detail:
            v.city_id === r.city_id
              ? `use:${venueId}`
              : `use:${venueId} - note this venue sits in ${v.city_id}, not the resolved city`,
        });
      }
    }
  }
}

/* --------------------------------------------------------- review CSV ---- */

const REVIEW_COLUMNS = [
  "line",
  "verdict",
  "reason",
  "source_id",
  "year",
  "rank",
  "category",
  "distinction",
  "venue_name",
  "city_label",
  "country_label",
  "resolved_city",
  "candidates",
  "decision",
];

function buildReviewCsv(rows: RowResult[]): string {
  const records: CsvRecord[] = rows.map((r) => ({
    line: String(r.line),
    verdict: r.verdict,
    reason: r.reason ?? "",
    source_id: r.input.source_id,
    year: r.input.year,
    rank: r.input.rank,
    category: r.input.category,
    distinction: r.input.distinction,
    venue_name: r.input.venue_name,
    city_label: r.input.city_label,
    country_label: r.input.country_label,
    resolved_city: r.city_slug ?? "",
    candidates:
      r.verdict === "review_city"
        ? r.candidates.cities
            .map((c) => `city:${c.city_id} (${c.display}, ${c.country ?? "?"})`)
            .join(" | ")
        : r.candidates.venues
            .map((v) => `use:${v.venue_id} (${v.name}, ${v.city_display}, ${v.status})`)
            .join(" | "),
    decision: "",
  }));
  return toCsv(REVIEW_COLUMNS, records);
}

/* -------------------------------------------------------------- report --- */

interface ReportInput {
  args: StageArgs;
  batchId: string;
  loaded: LoadedCsv;
  batchKeyNote: string;
  sourceIds: string[];
  years: string[];
  results: RowResult[];
  plan: Plan;
  before: TableCounts;
  ref: Awaited<ReturnType<typeof loadReference>>;
  reviewRows: number;
  reviewPath: string;
  reStaged: boolean;
  decisionsApplied: number;
  /** one row per completed phase, for the "Timings" section */
  timings: string[][];
}

export function expectedCounts(before: TableCounts, plan: Plan): Record<string, number> {
  return {
    venues: before.venues + plan.venues.length,
    awards: before.awards + plan.awards.length,
    listings: before.listings + plan.venues.length,
    slugs: before.slugs + plan.venues.length,
    city_label_source: before.city_label_source + plan.labels.length,
    price: before.price + plan.prices.length,
    source_capture_ledger: before.source_capture_ledger + plan.ledger.length,
  };
}

function buildReport(i: ReportInput): string {
  const { args, results, plan, before } = i;
  const expected = expectedCounts(before, plan);
  const verdicts = tallyBy(results, (r) => r.verdict);
  const rejects = results.filter((r) => r.verdict === "reject");
  const reviews = results.filter(
    (r) => r.verdict === "review_city" || r.verdict === "review_venue",
  );
  const derived = results.filter((r) => r.venue_category_derived && r.verdict !== "reject");
  const supersedes = results.filter((r) => r.supersedes.length > 0);

  const out: string[] = [];
  const p = (s = "") => out.push(s);

  p(`# Ingest stage - ${args.batchKey}`);
  p();
  p(`Staged ${new Date().toISOString()}. **Nothing has been promoted.** This run wrote to`);
  p(`\`ingest_batches\` and \`ingest_rows\` only; every live table is untouched.`);
  p();

  /* --- what came in --- */
  p(`## What came in`);
  p();
  p(
    mdTable(
      ["field", "value"],
      [
        ["batch key", `\`${args.batchKey}\``],
        ["batch id", i.batchId],
        ["CSV", `\`${args.csv}\``],
        ["rows in", String(results.length)],
        [
          "source(s)",
          i.sourceIds.length === 1
            ? i.sourceIds[0]
            : `${i.sourceIds.length} sources: ${i.sourceIds.join(", ")}`,
        ],
        [
          "list year(s)",
          i.years.length === 1 ? i.years[0] : `${i.years.length} years: ${i.years.join(", ")}`,
        ],
        ["batch key check", i.batchKeyNote],
        ...(i.reStaged
          ? [
              [
                "re-stage",
                `decisions re-applied to the existing batch; ${i.decisionsApplied} decision(s) read`,
              ],
            ]
          : []),
      ],
    ),
  );
  p();
  if (i.sourceIds.length > 1) {
    p(`> This batch carries more than one source, so \`ingest_batches.source_id\` is left`);
    p(`> blank rather than guessing one. Same for \`list_year\` across ${i.years.length} years.`);
    p();
  }

  /* --- column mapping --- */
  p(`## Columns`);
  p();
  const mapRows = Object.entries(i.loaded.mapping.mapped)
    .filter(([field, header]) => field !== header)
    .map(([field, header]) => [`\`${header}\``, "->", `\`${field}\``]);
  if (mapRows.length > 0) {
    p(`Read from the Award Radar shape and mapped:`);
    p();
    p(mdTable(["in the file", "", "used as"], mapRows));
  } else {
    p(`Every column was already in the canonical shape; nothing was renamed.`);
  }
  p();
  const ignored = i.loaded.mapping.ignored.filter((h) => h !== "");
  if (ignored.length > 0) {
    p(
      `Present in the file and **not used by this job**: ${ignored.map((h) => `\`${h}\``).join(", ")}.`,
    );
    const geo = ignored.filter((h) => IGNORED_COLUMNS.includes(h.toLowerCase()));
    if (geo.length > 0) {
      p(`Geo, address and cuisine columns are Phase 3 work - this job writes awards,`);
      p(`venues, listings, slugs, city labels and price, and nothing else.`);
    }
    p();
  }

  /* --- verdicts --- */
  p(`## Verdicts`);
  p();
  p(`Population: all ${results.length} data rows in the CSV. Grouping key: the row's verdict.`);
  p();
  p(
    mdTable(
      ["verdict", "rows", "what it means"],
      [...verdicts.entries()].map(([v, n]) => [v, String(n), verdictMeaning(v as Verdict)]),
    ),
  );
  p();
  if (derived.length > 0) {
    p(
      `\`venue_category\` was blank on ${derived.length} row(s) and derived from the source: ` +
        [...tallyBy(derived, (r) => `${r.input.source_id} -> ${r.venue_category}`).entries()]
          .map(([k, n]) => `${k} (${n})`)
          .join(", ") +
        `.`,
    );
    p();
  }

  if (rejects.length > 0) {
    p(`### Rejected rows`);
    p();
    p(
      mdTable(
        ["reason", "rows", "example"],
        [...tallyBy(rejects, (r) => r.reason ?? "?").entries()].map(([reason, n]) => {
          const ex = rejects.find((r) => r.reason === reason) as RowResult;
          return [
            `\`${reason}\``,
            String(n),
            `line ${ex.line}: ${ex.input.venue_name} - ${ex.detail ?? ""}`,
          ];
        }),
      ),
    );
    p();
  }

  /* --- expected live counts --- */
  p(`## What promote would do to the live tables`);
  p();
  p(`Population: whole table. Read now, before anything was promoted.`);
  p();
  p(
    mdTable(
      ["table", "before", "expected after", "delta"],
      COUNTED_TABLES.map((t) => [
        t,
        before[t].toLocaleString(),
        expected[t].toLocaleString(),
        `+${expected[t] - before[t]}`,
      ]),
    ),
  );
  p();
  p(
    `The venue delta is **${plan.venues.length}**, not the number of \`new_venue\` rows ` +
      `(${results.filter((r) => r.verdict === "new_venue").length}). Several award rows can ` +
      `name the same new venue - one venue row, one listing, one slug, several awards.`,
  );
  p();
  p(
    `Open venues now: ${before.venues_active.toLocaleString()}. Promote refuses to let that number drop.`,
  );
  p();

  if (plan.skippedPrices.length > 0) {
    p(`### Price rows not written`);
    p();
    p(
      mdTable(
        ["rows", "reason"],
        [...tallyBy(plan.skippedPrices, (s) => s.reason).entries()].map(([reason, n]) => [
          String(n),
          reason,
        ]),
      ),
    );
    p();
    const notCapable = plan.skippedPrices.filter((s) => s.reason.includes("price_capable"));
    if (notCapable.length > 0) {
      p(`> No source in \`award_sources\` has \`price_capable = true\` today, so the price`);
      p(`> branch writes nothing for any batch. Flipping that flag for a publisher is a`);
      p(`> D10 decision, not something this job does.`);
      p();
    }
  }

  if (supersedes.length > 0) {
    p(`### Existing "Listed" rows this batch outranks`);
    p();
    p(`These promote normally; the older bare "Listed" row stays where it is. The job`);
    p(`never deletes. Named here for the cleanup list.`);
    p();
    p(
      mdTable(
        ["line", "venue", "source / year", "existing awards.id"],
        supersedes
          .slice(0, 25)
          .map((r) => [
            String(r.line),
            r.input.venue_name,
            `${r.input.source_id} ${r.input.year}`,
            r.supersedes.join(", "),
          ]),
      ),
    );
    p();
  }

  const rankConflicts = results.filter((r) => r.rank_held_by.length > 0);
  if (rankConflicts.length > 0) {
    p(`### Ranks another venue already holds`);
    p();
    p(`A published rank belongs to one venue. These rows claim a rank that is already`);
    p(`on someone else. They promote normally - the job never moves or deletes an award -`);
    p(`but one of the two is wrong and only you can say which.`);
    p();
    p(
      mdTable(
        ["line", "this row", "source / year / rank", "already on"],
        rankConflicts
          .slice(0, 25)
          .map((r) => [
            String(r.line),
            r.input.venue_name,
            `${r.input.source_id} ${r.input.year} #${r.input.rank}`,
            r.rank_held_by
              .map((h) => `${h.venue_name} (\`${h.venue_id}\`, awards.id ${h.award_id})`)
              .join("; "),
          ]),
      ),
    );
    p();
  }

  /* --- sample --- */
  p(`## Sample - what promote will do, row by row`);
  p();
  const newSample = results.filter((r) => r.verdict === "new_venue").slice(0, 5);
  const matchSample = results.filter((r) => r.verdict === "match").slice(0, 5);
  const sample = [...newSample, ...matchSample];
  if (sample.length === 0) {
    p(`No row in this batch would promote.`);
  } else {
    p(
      mdTable(
        ["line", "verdict", "venue", "city", "award", "promote does"],
        sample.map((r) => {
          const venue = plan.venues.find((v) => v.group === r.new_venue_group);
          const creates = venue !== undefined && venue.lines[0] === r.line;
          const action =
            r.verdict === "new_venue" && venue
              ? creates
                ? `create ${venue.venue_id} (/${venue.city_slug}/${venue.slug}), listing published=${venue.published}, + 1 award`
                : `+ 1 award on ${venue.venue_id}, the venue line ${venue.lines[0]} creates`
              : `+ 1 award on ${r.venue_id}`;
          return [
            String(r.line),
            r.verdict,
            r.input.venue_name,
            r.city_slug ?? "?",
            `${r.input.source_id} ${r.input.year}${r.input.rank ? ` #${r.input.rank}` : ""}`,
            action,
          ];
        }),
      ),
    );
  }
  p();

  /* --- review --- */
  p(`## Review`);
  p();
  if (reviews.length === 0) {
    p(`Nothing needs your eyes. **${i.reviewRows === 0 ? "0" : i.reviewRows} rows in review.**`);
  } else {
    p(`**${reviews.length} row(s) need a decision** before this batch can promote.`);
    p();
    p(`Open \`${i.reviewPath}\` in Sheets, fill the \`decision\` column, save it as CSV,`);
    p(`and re-run the stage workflow with the same batch key plus the decisions file.`);
    p();
    p(
      mdTable(
        ["decision", "means"],
        [
          ["`use:ve_xxxxxxxxxx`", "this row is that existing venue"],
          ["`new`", "create a new venue for it"],
          ["`city:ci_xxxxxxxx`", "the city is that one"],
          ["`skip`", "leave this row out of the promote"],
          ["`city:ci_x;use:ve_y`", "both, in one cell"],
        ],
      ),
    );
    p();
    p(
      mdTable(
        ["reason", "rows"],
        [...tallyBy(reviews, (r) => r.reason ?? "?").entries()].map(([reason, n]) => [
          `\`${reason}\``,
          String(n),
        ]),
      ),
    );
  }
  p();

  /* --- next --- */
  p(`## Next`);
  p();
  if (reviews.length === 0 && plan.awards.length > 0) {
    p(`Run the **ingest-promote** workflow with:`);
    p();
    p("```");
    p(`batch_key:    ${args.batchKey}`);
    p(`confirmation: PROMOTE ${args.batchKey}`);
    p("```");
    p();
    p(`The confirmation has to be exactly that, including the batch key. Anything else stops.`);
  } else if (reviews.length > 0) {
    p(`Clear the ${reviews.length} review row(s) first. Promote refuses to run while any remain.`);
  } else {
    p(`There is nothing to promote in this batch.`);
  }
  p();

  /* --- timings --- */
  p(`## Timings`);
  p();
  p(`Where this run's wall clock went, phase by phase. The same table is written`);
  p(`to this file as each phase completes, so a run that is cancelled or fails`);
  p(`still says how far it got.`);
  p();
  p(mdTable(["#", "phase", "took", "elapsed", "detail"], i.timings));
  p();
  return out.join("\n");
}

function verdictMeaning(v: Verdict): string {
  switch (v) {
    case "match":
      return "venue already exists; promote adds the award";
    case "new_venue":
      return "promote creates the venue, listing, slug, city labels and the award";
    case "duplicate":
      return "this exact award already exists; promote skips it";
    case "subsumed":
      return "a higher distinction covers it for that source-year; promote skips it";
    case "reject":
      return "failed a check; nothing will be written for it";
    case "review_city":
      return "the city could not be resolved to exactly one row";
    case "review_venue":
      return "more than one candidate, or a same-name venue elsewhere; no auto-merge";
    case "skipped":
      return "you marked it skip in the review CSV";
    default:
      return "";
  }
}

main().catch((err) => {
  console.error(`\nStage failed: ${err instanceof Error ? err.message : String(err)}\n`);
  process.exitCode = 1;
});
