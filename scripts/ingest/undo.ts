/**
 * ingest-undo - reverse one promoted batch, in ONE transaction.
 *
 * The inverse of promote, and built the same way round: refuses without the
 * exact typed confirmation, states every count with its population, and either
 * takes the whole batch out or changes nothing at all.
 *
 * It deletes only what the promote wrote. A venue the batch matched rather than
 * created keeps its row, its URL and its other awards; it loses exactly the
 * award rows this batch added to it. If anything the batch created has been
 * changed or leant on since - an award from another batch, a redirect, a hand
 * edit - the undo refuses and says what moved. It never adapts.
 *
 *   bun run scripts/ingest/undo.ts --batch-key <key> --confirm "UNDO <key>"
 *                                  [--dry-run] [--out reports]
 */
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

import {
  Params,
  UNDO_COUNTED_TABLES,
  chunk,
  connect,
  readCounts,
  type Db,
  type TableCounts,
} from "./lib/db.ts";
import { Args } from "./lib/args.ts";
import { readStagedRows, toRowResults } from "./lib/staged.ts";
import { buildUndoPlan, type UndoPlan } from "./lib/undoPlan.ts";

interface UndoArgs {
  batchKey: string;
  confirm: string;
  dryRun: boolean;
  out: string;
}

const USAGE = 'usage: undo.ts --batch-key <key> --confirm "UNDO <key>" [--dry-run] [--out <dir>]';

function parseArgs(argv: string[]): UndoArgs {
  // Args rejects a repeated flag outright. That matters more here than anywhere
  // except promote: a second --confirm must never be able to appear and win.
  const args = new Args(argv, ["dry-run"]);
  return {
    batchKey: args.required("batch-key", USAGE),
    confirm: args.optional("confirm"),
    dryRun: args.bool("dry-run"),
    out: args.optional("out", "reports"),
  };
}

function writeFile(path: string, body: string): void {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, body, "utf8");
}

function mdTable(headers: string[], rows: string[][]): string {
  const out = [`| ${headers.join(" | ")} |`, `|${headers.map(() => "---").join("|")}|`];
  for (const r of rows) out.push(`| ${r.join(" | ")} |`);
  return out.join("\n");
}

/* ------------------------------------------------------------- deletes --- */

/**
 * The order matters, and it is the promote order read backwards: awards and
 * price hang off venues, the ledger and the labels are the batch's own keyed
 * rows, and slugs and listings have to go before the venues they reference.
 * Cities come last, because only an empty one can go at all.
 */
async function deleteAwards(db: Db, plan: UndoPlan): Promise<void> {
  for (const part of chunk(plan.awardIds, 20000)) {
    const p = new Params();
    await db.query(`delete from awards where id in (${p.list(part, "bigint")})`, p.values);
  }
}

async function deletePrice(db: Db, plan: UndoPlan): Promise<void> {
  for (const part of chunk(plan.priceVenueIds, 20000)) {
    const p = new Params();
    await db.query(`delete from price where venue_id in (${p.list(part, "text")})`, p.values);
  }
}

async function deleteLedger(db: Db, plan: UndoPlan): Promise<void> {
  for (const part of chunk(plan.ledgerIds, 20000)) {
    const p = new Params();
    await db.query(
      `delete from source_capture_ledger where id in (${p.list(part, "bigint")})`,
      p.values,
    );
  }
}

async function deleteLabels(db: Db, plan: UndoPlan): Promise<void> {
  for (const part of chunk(plan.labelIds, 20000)) {
    const p = new Params();
    await db.query(
      `delete from city_label_source where id in (${p.list(part, "bigint")})`,
      p.values,
    );
  }
}

async function deleteSlugs(db: Db, plan: UndoPlan): Promise<void> {
  for (const part of chunk(plan.slugs, 10000)) {
    const p = new Params();
    const values = p.rows(
      part.map((s) => [s.property_id, s.city_slug, s.slug]),
      ["text", "text", "text"],
    );
    await db.query(
      `delete from slugs s using (values ${values}) as t(property_id, city_slug, slug)
        where s.property_id = t.property_id and s.city_slug = t.city_slug and s.slug = t.slug`,
      p.values,
    );
  }
}

async function deleteListings(db: Db, plan: UndoPlan): Promise<void> {
  for (const part of chunk(plan.listings, 10000)) {
    const p = new Params();
    const values = p.rows(
      part.map((l) => [l.venue_id, l.property_id]),
      ["text", "text"],
    );
    await db.query(
      `delete from listings l using (values ${values}) as t(venue_id, property_id)
        where l.venue_id = t.venue_id and l.property_id = t.property_id`,
      p.values,
    );
  }
}

async function deleteVenues(db: Db, plan: UndoPlan): Promise<void> {
  const ids = plan.createdVenues.map((v) => v.venue_id);
  for (const part of chunk(ids, 20000)) {
    const p = new Params();
    await db.query(`delete from venues where id in (${p.list(part, "text")})`, p.values);
  }
}

async function deleteCities(db: Db, plan: UndoPlan): Promise<void> {
  const ids = plan.cities.filter((c) => c.deletable).map((c) => c.city_id);
  for (const part of chunk(ids, 20000)) {
    const p = new Params();
    await db.query(`delete from cities where id in (${p.list(part, "text")})`, p.values);
  }
}

/* ---------------------------------------------------------- invariants ---- */

interface Invariant {
  name: string;
  ok: boolean;
  detail: string;
}

/**
 * Read the counts back inside the transaction and compare them to the dry-run
 * numbers. Any mismatch aborts: if the deletes did not remove exactly what the
 * plan said, something was in the way and the whole thing rolls back.
 */
async function checkInvariants(
  db: Db,
  before: TableCounts,
  after: TableCounts,
  plan: UndoPlan,
): Promise<Invariant[]> {
  const inv: Invariant[] = [];

  for (const t of UNDO_COUNTED_TABLES) {
    const actual = after[t] - before[t];
    const wanted = plan.expected[t] ?? 0;
    inv.push({
      name: `${t} delta is ${wanted}`,
      ok: actual === wanted,
      detail: `${actual >= 0 ? "+" : ""}${actual} (expected ${wanted >= 0 ? "+" : ""}${wanted})`,
    });
  }

  // Nothing this batch wrote may still be there.
  const leftovers: { name: string; n: number }[] = [];

  const countIn = async (sql: (list: string) => string, ids: readonly string[], cast: string) => {
    let n = 0;
    for (const part of chunk(ids, 20000)) {
      const p = new Params();
      const { rows } = await db.query<{ n: string }>(sql(p.list(part, cast)), p.values);
      n += Number(rows[0]?.n ?? 0);
    }
    return n;
  };

  leftovers.push({
    name: "award rows this batch inserted",
    n: await countIn(
      (l) => `select count(*)::text n from awards where id in (${l})`,
      plan.awardIds,
      "bigint",
    ),
  });
  leftovers.push({
    name: "venues this batch created",
    n: await countIn(
      (l) => `select count(*)::text n from venues where id in (${l})`,
      plan.createdVenues.map((v) => v.venue_id),
      "text",
    ),
  });

  const { rows: labelLeft } = await db.query<{ n: string }>(
    `select count(*)::text n from city_label_source where note = $1`,
    [plan.batchKey],
  );
  leftovers.push({ name: "city labels carrying the batch key", n: Number(labelLeft[0].n) });

  const { rows: ledgerLeft } = await db.query<{ n: string }>(
    `select count(*)::text n from source_capture_ledger where job = $1`,
    [`ingest-promote:${plan.batchKey}`],
  );
  leftovers.push({ name: "ledger rows naming the batch", n: Number(ledgerLeft[0].n) });

  for (const l of leftovers) {
    inv.push({ name: `no ${l.name} remain`, ok: l.n === 0, detail: `${l.n} left` });
  }

  // A venue the batch matched keeps its row and its other awards.
  const kept = plan.matchedVenues.map((m) => m.venue_id);
  const stillThere = await countIn(
    (l) => `select count(*)::text n from venues where id in (${l})`,
    kept,
    "text",
  );
  inv.push({
    name: "every venue the batch matched is still there",
    ok: stillThere === kept.length,
    detail: `${stillThere} of ${kept.length}`,
  });

  const keepsWanted = plan.matchedVenues.reduce((n, m) => n + m.keeps, 0);
  const keepsActual = await countIn(
    (l) => `select count(*)::text n from awards where venue_id in (${l})`,
    kept,
    "text",
  );
  inv.push({
    name: "matched venues kept every award this batch did not add",
    ok: keepsActual === keepsWanted,
    detail: `${keepsActual} (expected ${keepsWanted})`,
  });

  return inv;
}

/* --------------------------------------------------------------- main ---- */

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const wanted = `UNDO ${args.batchKey}`;

  if (args.confirm !== wanted) {
    console.error(
      `\nNothing was undone.\n\n` +
        `The confirmation field has to read exactly:\n\n    ${wanted}\n\n` +
        `It read:\n\n    ${args.confirm === "" ? "(empty)" : args.confirm}\n\n` +
        `Copy the line above, including the batch key, and run the workflow again.\n`,
    );
    process.exitCode = 1;
    return;
  }

  const { client: db, close } = await connect();
  let committed = false;

  try {
    const { rows: batches } = await db.query<{
      id: string;
      status: string;
      approved_at: string | null;
      undone_at: string | null;
    }>(
      `select id::text, status::text, approved_at::text as approved_at,
              undone_at::text as undone_at
         from ingest_batches where batch_key = $1`,
      [args.batchKey],
    );
    if (batches.length === 0) {
      throw new Error(`No batch with key "${args.batchKey}". Nothing to undo.`);
    }
    const batch = batches[0];

    if (batch.status === "undone") {
      // Not a no-op, unlike a repeated promote. A promote run twice would do the
      // same thing twice; an undo run twice cannot, because the rows are gone and
      // a second run would have to guess what to take next. It stops loudly.
      throw new Error(
        `Batch "${args.batchKey}" is already undone (${batch.undone_at ?? "time not recorded"}). ` +
          `Nothing was changed.\n\n` +
          `An undo runs once. The batch row and all of its staged rows are still there for the ` +
          `history; the rows it wrote are not. To land this list again, stage it under a NEW ` +
          `batch key and read the fresh report.`,
      );
    }
    if (batch.status !== "promoted") {
      throw new Error(
        `Batch "${args.batchKey}" is ${batch.status}, not promoted. Undo reverses a promote, ` +
          `and there is nothing in the live tables from a batch that has not promoted.` +
          (batch.status === "staged"
            ? ` A staged batch that should not land just stays staged - promote will not run ` +
              `without the typed confirmation.`
            : ""),
      );
    }
    if (!batch.approved_at) {
      throw new Error(
        `Batch "${args.batchKey}" is promoted but has no approved_at timestamp, which is the key ` +
          `into audit_log that undo reads the batch's own writes from. Nothing was changed.`,
      );
    }

    const staged = await readStagedRows(db, batch.id);
    const results = toRowResults(staged);

    /* ------------------------- one transaction ------------------------- */
    await db.query("BEGIN");

    // Lock the batch row and re-read its status inside the transaction. The
    // check above happened outside it; two undos started at once would
    // otherwise both get past it.
    const { rows: locked } = await db.query<{ status: string }>(
      `select status::text from ingest_batches where id = $1 for update`,
      [batch.id],
    );
    if (locked[0]?.status !== "promoted") {
      await db.query("ROLLBACK");
      throw new Error(
        `Batch "${args.batchKey}" is ${locked[0]?.status ?? "gone"}, not promoted - something ` +
          `else changed it while this run was starting. Nothing was changed.`,
      );
    }

    const before = await readCounts(db);

    const { plan, problems } = await buildUndoPlan({
      db,
      batchKey: args.batchKey,
      batchId: batch.id,
      promotedAt: batch.approved_at,
      results,
    });

    // The dry run, always, and before a single delete: what would go, stated
    // with its population.
    const preview = buildReport({
      args,
      plan,
      before,
      after: before,
      invariants: [],
      committed: false,
      problems,
    });
    console.log(preview);

    if (problems.length > 0) {
      await db.query("ROLLBACK");
      writeFile(join(args.out, `${args.batchKey}-undo.md`), preview);
      throw new Error(
        `This batch cannot be undone as it stands, so nothing was changed:\n\n` +
          problems.map((x) => `  - ${x}`).join("\n") +
          `\n\nEach of those is something that happened to the batch's rows after it promoted. ` +
          `Undo reverses a promote; it will not delete somebody else's work to do it. Deal with ` +
          `what is named above - move the award, drop the redirect, unpublish by hand - and run ` +
          `the undo again.`,
      );
    }

    await deleteAwards(db, plan);
    await deletePrice(db, plan);
    await deleteLedger(db, plan);
    await deleteLabels(db, plan);
    await deleteSlugs(db, plan);
    await deleteListings(db, plan);
    await deleteVenues(db, plan);
    await deleteCities(db, plan);

    // History is never deleted: the batch row stays, and so does every
    // ingest_rows row under it. Only the status moves.
    await db.query(`update ingest_batches set status = 'undone', undone_at = now() where id = $1`, [
      batch.id,
    ]);

    const after = await readCounts(db);
    const invariants = await checkInvariants(db, before, after, plan);
    const failed = invariants.filter((i) => !i.ok);

    if (failed.length > 0) {
      await db.query("ROLLBACK");
      throw new Error(
        `Invariant failure - the whole undo was rolled back and NOTHING changed:\n` +
          failed.map((f) => `  - ${f.name}: ${f.detail}`).join("\n"),
      );
    }

    // The undo's own audit row. Every deleted row already logged itself through
    // the table triggers; this one row is the reason they all went at once.
    // `::text::jsonb`, not `::jsonb`: Bun's driver JSON-encodes a string bound
    // straight to jsonb, which would store the document as a quoted string
    // instead of an object. Same convention as stage.ts.
    await db.query(
      `insert into audit_log (table_name, row_pk, action, old_row, new_row)
       values ('ingest_batches', $1, 'UNDO', $2::text::jsonb, $3::text::jsonb)`,
      [
        batch.id,
        JSON.stringify({
          batch_key: args.batchKey,
          status: "promoted",
          promoted_at: plan.promotedAt,
        }),
        JSON.stringify({
          batch_key: args.batchKey,
          status: "undone",
          job: `ingest-undo:${args.batchKey}`,
          removed: plan.expected,
          venues_deleted: plan.createdVenues.map((v) => v.venue_id),
          awards_deleted: plan.awardIds.length,
          matched_venues_kept: plan.matchedVenues.map((m) => m.venue_id),
        }),
      ],
    );

    if (args.dryRun) {
      await db.query("ROLLBACK");
    } else {
      await db.query("COMMIT");
      committed = true;
    }

    /* ------------------------- read back, report ----------------------- */
    const actual = committed ? await readCounts(db) : after;
    const report = buildReport({
      args,
      plan,
      before,
      after: actual,
      invariants,
      committed,
      problems: [],
    });
    writeFile(join(args.out, `${args.batchKey}-undo.md`), report);
    console.log(report);
  } catch (err) {
    try {
      await db.query("ROLLBACK");
    } catch {
      /* not in a transaction */
    }
    throw err;
  } finally {
    await close();
  }
}

interface ReportInput {
  args: UndoArgs;
  plan: UndoPlan;
  before: TableCounts;
  after: TableCounts;
  invariants: Invariant[];
  committed: boolean;
  problems: string[];
}

function buildReport(i: ReportInput): string {
  const { args, plan, before, after } = i;
  const refused = i.problems.length > 0;
  // No invariants yet means this is the plan printed before any delete: either
  // the pre-write dry run, or a refusal.
  const isPreview = i.invariants.length === 0;

  const out: string[] = [];
  const p = (s = "") => out.push(s);

  p(`# Ingest undo - ${args.batchKey}`);
  p();
  if (i.problems.length > 0) {
    p(`**Refused. Nothing was changed.**`);
    p();
    for (const x of i.problems) p(`- ${x}`);
    p();
    p(
      `Undo reverses a promote. Every line above is something that happened to this batch's ` +
        `rows after it promoted, and taking it out is not this job's call.`,
    );
    p();
  } else if (isPreview) {
    p(`**Dry run.** This is what the undo would remove. Nothing has been deleted yet.`);
    p();
  } else if (i.committed) {
    p(`Committed ${new Date().toISOString()}. One transaction, all of it or none of it.`);
    p();
  } else {
    p(`**Dry run - rolled back.** Everything below is what would have happened.`);
    p(`The live tables are exactly as they were.`);
    p();
  }

  p(`Promote transaction: \`${plan.promotedAt}\` - the \`audit_log\` timestamp this undo read`);
  p(`the batch's own writes from.`);
  p();

  p(`## Counts`);
  p();
  p(
    `Population: whole table, read inside the transaction${isPreview ? "" : " before and after the deletes"}.`,
  );
  p();
  p(
    mdTable(
      refused
        ? ["table", "now", "if it ran", "delta"]
        : isPreview
          ? ["table", "now", "expected after", "delta"]
          : ["table", "before", "expected", "actual"],
      UNDO_COUNTED_TABLES.map((t) => {
        const delta = plan.expected[t] ?? 0;
        const expected = before[t] + delta;
        return isPreview
          ? [t, before[t].toLocaleString(), expected.toLocaleString(), String(delta)]
          : [t, before[t].toLocaleString(), expected.toLocaleString(), after[t].toLocaleString()];
      }),
    ),
  );
  p();
  p(
    `Active venues: ${before.venues_active.toLocaleString()}` +
      (isPreview ? "" : ` -> ${after.venues_active.toLocaleString()}`) +
      `.`,
  );
  p();
  if (refused) {
    p(
      `**Nothing was removed.** The deltas above are the plan that was refused, printed so the ` +
        `size of what is being held back is on the record.`,
    );
    p();
  }
  p(
    `\`cities.venues_count\` is maintained by its own refresh job, as it is at promote: neither ` +
      `job writes it.`,
  );
  p();

  if (!isPreview) {
    p(`## Invariants`);
    p();
    p(
      mdTable(
        ["check", "result", "detail"],
        i.invariants.map((v) => [v.name, v.ok ? "pass" : "**FAIL**", v.detail]),
      ),
    );
    p();
  }

  if (plan.createdVenues.length > 0) {
    p(`## Venues this batch created (deleted whole)`);
    p();
    p(`With their listing, their URL, their city labels and their awards.`);
    p();
    p(
      mdTable(
        ["venue id", "name", "url", "status", "awards"],
        plan.createdVenues.map((v) => [
          `\`${v.venue_id}\``,
          v.name,
          `/${v.city_slug}/${v.slug}`,
          v.status,
          String(v.lines.length),
        ]),
      ),
    );
    p();
  }

  if (plan.matchedVenues.length > 0) {
    p(`## Venues this batch matched (kept)`);
    p();
    p(`These rows were already there. They lose only the award rows this batch added.`);
    p();
    p(
      mdTable(
        ["venue id", "name", "awards removed", "awards kept"],
        plan.matchedVenues.map((m) => [
          `\`${m.venue_id}\``,
          m.name,
          String(m.awards),
          String(m.keeps),
        ]),
      ),
    );
    p();
  }

  p(`## Cities`);
  p();
  if (plan.cities.length === 0) {
    p(
      `None. The promote transaction inserted no \`cities\` row - measured from \`audit_log\`, ` +
        `not assumed - so there is no city for this undo to remove. The ingest job never ` +
        `creates a city (docs/ingest-job.md, "Things this job will never do"), so the city ` +
        `delta of a clean undo is always 0.`,
    );
  } else {
    p(
      mdTable(
        ["city id", "slug", "venues left", "action"],
        plan.cities.map((c) => [
          `\`${c.city_id}\``,
          c.slug,
          String(c.venuesLeft),
          c.deletable ? "deleted" : `kept - ${c.reason}`,
        ]),
      ),
    );
  }
  p();

  if (plan.ledgerRows.length > 0) {
    p(`## Exposure ledger rows removed`);
    p();
    p(`Job \`ingest-promote:${args.batchKey}\`.`);
    p();
    p(
      mdTable(
        ["publisher", "field type", "items"],
        plan.ledgerRows.map((l) => [l.publisher, l.field_type, String(l.items)]),
      ),
    );
    p();
  }

  p(`## History`);
  p();
  p(`\`ingest_batches\` keeps the row: status \`undone\`, with \`undone_at\` set. Every`);
  p(`\`ingest_rows\` row under it stays as it was, and \`audit_log\` gains a DELETE row for`);
  p(`every row removed plus one \`UNDO\` row naming this batch. Nothing is ever deleted from`);
  p(`the history.`);
  p();
  p(`The batch cannot be promoted again under this key - promote runs only on a \`staged\``);
  p(`batch. To land this list again, stage it under a NEW key and read the fresh report.`);
  p();
  return out.join("\n");
}

main().catch((err) => {
  console.error(`\nUndo failed: ${err instanceof Error ? err.message : String(err)}\n`);
  process.exitCode = 1;
});
