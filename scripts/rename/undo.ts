/**
 * rename-undo - put one applied rename batch back, in ONE transaction.
 *
 * The inverse of apply, and built the same way round: the exact typed
 * confirmation or nothing, every count with its population, and the whole
 * batch or none of it.
 *
 * It refuses rather than adapts. If a venue this batch renamed has been
 * renamed again since, the undo does not know whose name it would be throwing
 * away, so it stops and says which venue moved. An undo runs once: a second
 * run is an error, not a no-op.
 *
 *   bun run scripts/rename/undo.ts --batch-key <key>
 *                                  --confirm "UNDO-RENAME <key>"
 *                                  [--dry-run] [--out reports]
 */
import { join } from "node:path";

import { Args } from "../ingest/lib/args.ts";
import { Params, chunk, connect, rowsPerStatement, type Db } from "../ingest/lib/db.ts";
import { findCollisions, loadVenueState, type Collision } from "./lib/impact.ts";
import {
  RENAME_COUNTED_TABLES,
  cell,
  invariantTable,
  mdTable,
  readRenameCounts,
  tallyBy,
  writeFile,
  type Invariant,
  type RenameCounts,
} from "./lib/report.ts";

interface UndoArgs {
  batchKey: string;
  confirm: string;
  dryRun: boolean;
  out: string;
}

const USAGE =
  'usage: undo.ts --batch-key <key> --confirm "UNDO-RENAME <key>" [--dry-run] [--out <dir>]';

function parseArgs(argv: string[]): UndoArgs {
  // Args rejects a repeated flag outright: a second --confirm must never be
  // able to appear and win.
  const args = new Args(argv, ["dry-run"]);
  return {
    batchKey: args.required("batch-key", USAGE),
    confirm: args.optional("confirm"),
    dryRun: args.bool("dry-run"),
    out: args.optional("out", "reports"),
  };
}

interface Restore {
  line: number;
  venue_id: string;
  /** what the venue was called before this batch ran, and will be called again */
  expected_name: string;
  /** what this batch renamed it to, and what it must still be called now */
  new_name: string;
  source_id: string;
  source_url: string;
  live_name: string | null;
  city_slug: string | null;
}

async function readRenameRows(db: Db, batchId: string): Promise<Restore[]> {
  const { rows } = await db.query<{
    line: number;
    venue_id: string;
    expected_name: string;
    new_name: string;
    source_id: string;
    source_url: string;
  }>(
    `select line, venue_id, expected_name, new_name, source_id, source_url
       from rename_rows where batch_id = $1 and verdict = 'rename' order by line`,
    [batchId],
  );
  return rows.map((r) => ({ ...r, line: Number(r.line), live_name: null, city_slug: null }));
}

async function restoreNames(db: Db, restores: readonly Restore[]): Promise<string[]> {
  const done: string[] = [];
  for (const part of chunk(restores, rowsPerStatement(3))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [r.venue_id, r.new_name, r.expected_name]),
      ["text", "text", "text"],
    );
    const { rows } = await db.query<{ id: string }>(
      `update venues v
          set name = t.expected_name
         from (values ${values}) as t(venue_id, new_name, expected_name)
        where v.id = t.venue_id and v.name = t.new_name
      returning v.id`,
      p.values,
    );
    done.push(...rows.map((r) => r.id));
  }
  return done;
}

/* --------------------------------------------------------- invariants ---- */

async function checkInvariants(
  db: Db,
  before: RenameCounts,
  after: RenameCounts,
  restores: readonly Restore[],
  restoredIds: readonly string[],
  ledgerRows: number,
): Promise<Invariant[]> {
  const inv: Invariant[] = [];
  const delta = (t: string) => after[t] - before[t];
  const expect = (name: string, actual: number, wanted: number) =>
    inv.push({ name, ok: actual === wanted, detail: `${actual} (expected ${wanted})` });

  expect("restored venues equals the batch's rename rows", restoredIds.length, restores.length);

  let wrong = 0;
  for (const part of chunk(restores, rowsPerStatement(2))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [r.venue_id, r.expected_name]),
      ["text", "text"],
    );
    const { rows } = await db.query<{ n: string }>(
      `select count(*)::text as n
         from (values ${values}) as t(venue_id, expected_name)
         join venues v on v.id = t.venue_id
        where v.name is distinct from t.expected_name`,
      p.values,
    );
    wrong += Number(rows[0].n);
  }
  inv.push({
    name: "every venue carries the name it had before the batch",
    ok: wrong === 0,
    detail: `${wrong} of ${restores.length} disagree`,
  });

  expect("venue count unchanged", delta("venues"), 0);
  expect("award count unchanged", delta("awards"), 0);
  expect("slug count unchanged - an undo never changes a URL", delta("slugs"), 0);
  expect("blurb count unchanged", delta("blurbs"), 0);
  expect(
    "ledger rows removed equals the ones this batch wrote",
    delta("source_capture_ledger"),
    -ledgerRows,
  );
  expect("no rename_rows removed - history is never deleted", delta("rename_rows"), 0);
  expect("no rename_batches row removed", delta("rename_batches"), 0);

  // The receipt: audit_log.at is the transaction timestamp, so these are this
  // undo's own venue updates and nothing else's.
  const { rows: audit } = await db.query<{ renames: string; other: string }>(
    `select
       count(*) filter (where old_row->>'name' is distinct from new_row->>'name')::text as renames,
       count(*) filter (where old_row->>'name' is not distinct from new_row->>'name')::text as other
       from audit_log
      where table_name = 'venues' and action = 'UPDATE' and at = transaction_timestamp()`,
  );
  inv.push({
    name: "audit_log shows exactly this undo's renames for this transaction",
    ok: Number(audit[0].renames) === restores.length && Number(audit[0].other) === 0,
    detail:
      `${audit[0].renames} name changes (expected ${restores.length}), ` +
      `${audit[0].other} other venue updates (expected 0)`,
  });

  return inv;
}

/* --------------------------------------------------------------- main ---- */

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const wanted = `UNDO-RENAME ${args.batchKey}`;
  const reportPath = join(args.out, `${args.batchKey}-rename-undo.md`);

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
      applied_at: string | null;
      undone_at: string | null;
    }>(
      `select id::text, status::text, applied_at::text as applied_at, undone_at::text as undone_at
         from rename_batches where batch_key = $1`,
      [args.batchKey],
    );
    if (batches.length === 0) {
      throw new Error(`No rename batch with key "${args.batchKey}". Nothing to undo.`);
    }
    const batch = batches[0];

    if (batch.status === "undone") {
      // An undo runs once. Unlike a repeated promote in the ingest job, a
      // second undo cannot repeat the first one's work: the names are already
      // back, and running again would have to guess what to put where.
      throw new Error(
        `Batch "${args.batchKey}" is already undone (${batch.undone_at ?? "time not recorded"}). ` +
          `Nothing was changed.\n\n` +
          `An undo runs once. The batch row and every one of its rename_rows are still there ` +
          `for the history. To change these names again, build a new file and run ` +
          `**Rename - apply** under a NEW batch key.`,
      );
    }
    if (batch.status !== "applied") {
      throw new Error(
        `Batch "${args.batchKey}" is ${batch.status}, not applied. There is nothing to put back.`,
      );
    }

    /* ------------------------- one transaction ------------------------- */
    await db.query("BEGIN");

    // Lock the batch row and re-read its status inside the transaction. The
    // check above happened outside it; two undos started at once would
    // otherwise both get past it.
    const { rows: locked } = await db.query<{ status: string }>(
      `select status::text from rename_batches where id = $1 for update`,
      [batch.id],
    );
    if (locked[0]?.status !== "applied") {
      await db.query("ROLLBACK");
      throw new Error(
        `Batch "${args.batchKey}" is ${locked[0]?.status ?? "gone"}, not applied - something ` +
          `else changed it while this run was starting. Nothing was changed.`,
      );
    }

    const before = await readRenameCounts(db);
    const restores = await readRenameRows(db, batch.id);

    /* --- has anything moved since? ---------------------------------------- */
    const state = await loadVenueState(
      db,
      restores.map((r) => r.venue_id),
    );
    const problems: string[] = [];
    for (const r of restores) {
      const v = state.get(r.venue_id);
      if (!v) {
        problems.push(`${r.venue_id} ("${r.new_name}") is not there any more.`);
        continue;
      }
      r.live_name = v.name;
      r.city_slug = v.city_slug;
      if (v.name !== r.new_name) {
        problems.push(
          `${r.venue_id} is called "${v.name}" now. This batch renamed it to "${r.new_name}", ` +
            `so somebody has renamed it again since - putting "${r.expected_name}" back would ` +
            `throw that away.`,
        );
      }
    }

    const { rows: ledgerFound } = await db.query<{ n: string }>(
      `select count(*)::text as n from source_capture_ledger where job = $1`,
      [`rename-apply:${args.batchKey}`],
    );
    const ledgerRows = Number(ledgerFound[0].n);

    if (problems.length > 0) {
      const report = buildReport({
        args,
        restores,
        collisions: new Map(),
        ledgerRows,
        before,
        after: before,
        invariants: [],
        committed: false,
        problems,
      });
      await db.query("ROLLBACK");
      writeFile(reportPath, report);
      console.log(report);
      throw new Error(
        `This batch cannot be undone as it stands, so nothing was changed:\n\n` +
          problems.map((x) => `  - ${x}`).join("\n") +
          `\n\nAn undo puts back what this batch wrote and nothing else. Settle each of those ` +
          `first - decide which name is right and, if it is the old one, put it back through a ` +
          `new rename batch - and then run this undo again.`,
      );
    }

    /**
     * Restoring an old name can re-create a same-city norm_key collision if a
     * venue with that name has arrived since. That is reported, not refused:
     * the state being restored is a state the database was already in, and
     * refusing would leave the batch permanently stuck with no way back.
     */
    const collisions = await findCollisions(
      db,
      restores.map((r) => ({ venue_id: r.venue_id, new_name: r.expected_name })),
    );

    /* --- put the names back ----------------------------------------------- */
    await db.query(`set local app.allow_rename = 'on'`);
    const restoredIds = await restoreNames(db, restores);
    await db.query(`set local app.allow_rename = 'off'`);

    await db.query(`delete from source_capture_ledger where job = $1`, [
      `rename-apply:${args.batchKey}`,
    ]);

    // History is never deleted: the batch row stays, and so does every
    // rename_rows row under it. Only the status moves.
    await db.query(`update rename_batches set status = 'undone', undone_at = now() where id = $1`, [
      batch.id,
    ]);

    const after = await readRenameCounts(db);
    const invariants = await checkInvariants(db, before, after, restores, restoredIds, ledgerRows);
    const failed = invariants.filter((i) => !i.ok);
    if (failed.length > 0) {
      await db.query("ROLLBACK");
      throw new Error(
        `Invariant failure - the whole undo was rolled back and NOTHING changed:\n` +
          failed.map((f) => `  - ${f.name}: ${f.detail}`).join("\n"),
      );
    }

    if (args.dryRun) {
      await db.query("ROLLBACK");
    } else {
      await db.query("COMMIT");
      committed = true;
    }

    const actual = committed ? await readRenameCounts(db) : after;
    const report = buildReport({
      args,
      restores,
      collisions,
      ledgerRows,
      before,
      after: actual,
      invariants,
      committed,
      problems: [],
    });
    writeFile(reportPath, report);
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

/* -------------------------------------------------------------- report --- */

interface ReportInput {
  args: UndoArgs;
  restores: Restore[];
  collisions: Map<string, Collision>;
  ledgerRows: number;
  before: RenameCounts;
  after: RenameCounts;
  invariants: Invariant[];
  committed: boolean;
  problems: string[];
}

function buildReport(i: ReportInput): string {
  const { args, restores, before, after } = i;
  const refused = i.problems.length > 0;
  const publishers = tallyBy(restores, (r) => r.source_id);

  const expected: RenameCounts = {
    venues: before.venues,
    awards: before.awards,
    slugs: before.slugs,
    blurbs: before.blurbs,
    source_capture_ledger: before.source_capture_ledger - i.ledgerRows,
    rename_batches: before.rename_batches,
    rename_rows: before.rename_rows,
  };

  const out: string[] = [];
  const p = (s = "") => out.push(s);

  p(`# Rename undo - ${args.batchKey}`);
  p();
  if (refused) {
    p(`**REFUSED. Nothing was changed.**`);
    p();
    for (const x of i.problems) p(`- ${cell(x)}`);
    p();
    p(
      `An undo puts back what this batch wrote. Every line above is a venue that has moved ` +
        `since, and deciding whose name wins is not this job's call.`,
    );
  } else if (i.committed) {
    p(`Committed ${new Date().toISOString()}. One transaction, all of it or none of it.`);
  } else {
    p(`**DRY RUN - rolled back.** Everything below is what would have happened.`);
    p(`Every name in the database is exactly as it was.`);
  }
  p();

  p(
    mdTable(
      ["field", "value"],
      [
        ["batch key", `\`${args.batchKey}\``],
        ["names to put back", String(restores.length)],
        ["ledger rows to remove", String(i.ledgerRows)],
        ["job tag", `\`rename-apply:${args.batchKey}\``],
      ],
    ),
  );
  p();

  p(`## Counts`);
  p();
  p(
    `Population: whole table, read inside the transaction` +
      (refused ? ", before the refusal." : " before and after the writes."),
  );
  p();
  p(
    refused
      ? mdTable(
          ["table", "now", "after this run"],
          RENAME_COUNTED_TABLES.map((t) => [
            t,
            before[t].toLocaleString(),
            before[t].toLocaleString(),
          ]),
        )
      : mdTable(
          ["table", "before", "expected", "actual"],
          RENAME_COUNTED_TABLES.map((t) => [
            t,
            before[t].toLocaleString(),
            expected[t].toLocaleString(),
            after[t].toLocaleString(),
          ]),
        ),
  );
  p();
  p(
    `\`rename_batches\` and \`rename_rows\` do not move: the batch keeps its row, with status ` +
      `\`undone\` and \`undone_at\` set, and every row under it stays exactly as the apply ` +
      `wrote it. History is never deleted.`,
  );
  p();

  if (i.invariants.length > 0) {
    p(`## Invariants`);
    p();
    p(`All of them checked inside the transaction. One failure rolls the whole undo back.`);
    p();
    p(invariantTable(i.invariants));
    p();
  }

  p(`## Sample`);
  p();
  if (restores.length === 0) {
    p(`This batch renamed nothing, so there is nothing to put back.`);
  } else {
    p(
      `The first ${Math.min(5, restores.length)} of the ${restores.length} names going back, in ` +
        `file order. Population: the \`rename\` rows of this batch.`,
    );
    p();
    p(
      mdTable(
        ["venue id", "name now", "back to", "publisher the apply followed", "source URL"],
        restores
          .slice(0, 5)
          .map((r) => [
            `\`${r.venue_id}\``,
            cell(r.live_name ?? r.new_name),
            cell(r.expected_name),
            r.source_id,
            cell(r.source_url),
          ]),
      ),
    );
    p();
  }
  if (publishers.size > 0) {
    p(
      `Spellings being dropped: ` +
        [...publishers.entries()].map(([s, n]) => `${s} (${n})`).join(", ") +
        `.`,
    );
    p();
  }

  if (!refused) {
    p(`## Same-city name collisions this restores`);
    p();
    if (i.collisions.size === 0) {
      p(
        `None. Population: the ${restores.length} venue(s) whose names go back, checked against ` +
          `every other venue in the same city.`,
      );
    } else {
      p(
        `${i.collisions.size} of the ${restores.length} restored names share a \`norm_key\` ` +
          `with another venue in the same city. Reported, not refused: this is the state the ` +
          `database was in before the batch ran, and an undo that refused to restore it would ` +
          `leave the batch with no way back. Worth your eyes afterwards.`,
      );
      p();
      p(
        mdTable(
          ["venue id", "restored name", "shares a key with"],
          [...i.collisions.values()].map((c) => [
            `\`${c.venue_id}\``,
            cell(restores.find((r) => r.venue_id === c.venue_id)?.expected_name ?? ""),
            cell(`${c.other_id} ("${c.other_name}")`),
          ]),
        ),
      );
    }
    p();
  }

  p(`## Afterwards`);
  p();
  if (i.committed) {
    p(
      `The batch is \`undone\`, with \`undone_at\` set. It cannot be undone again - a second ` +
        `run is an error, not a no-op - and it cannot be re-applied under this key. To change ` +
        `these names again, build a new file and run **Rename - apply** under a NEW batch key.`,
    );
    p();
    p(
      `\`audit_log\` gained an UPDATE row for every name put back, carrying both the old and ` +
        `the new value. Nothing is ever deleted from the history.`,
    );
  } else if (refused) {
    p(`Nothing happened. The batch is still \`applied\`.`);
  } else {
    p(`Nothing happened: this was a dry run. Untick the box to do it for real.`);
  }
  p();
  return out.join("\n");
}

main().catch((err) => {
  console.error(`\nRename undo failed: ${err instanceof Error ? err.message : String(err)}\n`);
  process.exitCode = 1;
});
