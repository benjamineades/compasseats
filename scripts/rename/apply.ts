/**
 * rename-apply - change the names of a batch of venues, in ONE transaction.
 *
 * The fourth button. It is the only thing in the repo that sets
 * `app.allow_rename`, the session flag `trg_venue_rename` looks for, and it
 * sets it with SET LOCAL inside its own transaction and turns it off again
 * before that transaction ends. There is no other route past the guard, and
 * this job never gives one.
 *
 * Refuses without the exact typed confirmation. Refuses if a venue's current
 * name is not the one the file expected. Refuses if a rename would put two
 * venues in one city under the same norm_key. Any refusal takes the whole
 * batch with it - nothing partial, ever.
 *
 *   bun run scripts/rename/apply.ts --csv <path> --batch-key <key>
 *                                   --confirm "RENAME <key>"
 *                                   [--dry-run] [--note <text>] [--out reports]
 */
import { readFileSync } from "node:fs";
import { join } from "node:path";

import { Args } from "../ingest/lib/args.ts";
import { Params, chunk, connect, rowsPerStatement, type Db } from "../ingest/lib/db.ts";
import {
  VENUE_SOURCE,
  checkRow,
  linesByVenue,
  loadRenameCsv,
  type RenameRow,
} from "./lib/renameCsv.ts";
import {
  findCollisions,
  loadImpact,
  loadSources,
  loadVenueState,
  scanNameColumns,
  type NameScan,
  type VenueImpact,
} from "./lib/impact.ts";
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

interface ApplyArgs {
  csv: string;
  batchKey: string;
  confirm: string;
  dryRun: boolean;
  note: string;
  out: string;
}

const USAGE =
  'usage: apply.ts --csv <path> --batch-key <key> --confirm "RENAME <key>" ' +
  "[--dry-run] [--note <text>] [--out <dir>]";

function parseArgs(argv: string[]): ApplyArgs {
  // Args rejects a repeated flag outright. That matters here as much as it does
  // in promote: a second --confirm must never be able to appear and win.
  const args = new Args(argv, ["dry-run"]);
  return {
    csv: args.required("csv", USAGE),
    batchKey: args.required("batch-key", USAGE),
    confirm: args.optional("confirm"),
    dryRun: args.bool("dry-run"),
    note: args.optional("note"),
    out: args.optional("out", "reports"),
  };
}

/** `field_type` on the ledger rows this job writes. */
const FIELD_TYPE = "name";

interface LedgerRow {
  publisher: string;
  items: number;
}

/**
 * One ledger row per publisher whose spelling this batch followed.
 *
 * `source_capture_ledger.publisher` is a foreign key to `award_sources`, and
 * `venue` - the venue's own website - is deliberately not a row there. So a
 * batch that settled some names on the venue's own site writes no ledger row
 * for those: there is no publisher to have been exposed. The report says how
 * many rows that was rather than leaving the arithmetic to look wrong.
 */
function buildLedger(renames: readonly RenameRow[], registered: Set<string>): LedgerRow[] {
  const tally = new Map<string, number>();
  for (const r of renames) {
    if (!registered.has(r.input.source_id)) continue;
    tally.set(r.input.source_id, (tally.get(r.input.source_id) ?? 0) + 1);
  }
  return [...tally.entries()]
    .map(([publisher, items]) => ({ publisher, items }))
    .sort((a, b) => a.publisher.localeCompare(b.publisher));
}

/* ------------------------------------------------------------- the write --- */

/**
 * The renames themselves.
 *
 * `where v.name = t.expected_name` is not redundant with the check that already
 * refused a moved name: it makes the statement itself incapable of renaming a
 * venue whose name is not the one the report was written about. If a row does
 * not match, the returned count falls short and the invariant below rolls the
 * whole thing back.
 */
async function applyRenames(db: Db, renames: readonly RenameRow[]): Promise<string[]> {
  const renamed: string[] = [];
  for (const part of chunk(renames, rowsPerStatement(3))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [r.input.venue_id, r.input.expected_name, r.input.new_name]),
      ["text", "text", "text"],
    );
    const { rows } = await db.query<{ id: string }>(
      `update venues v
          set name = t.new_name
         from (values ${values}) as t(venue_id, expected_name, new_name)
        where v.id = t.venue_id and v.name = t.expected_name
      returning v.id`,
      p.values,
    );
    renamed.push(...rows.map((r) => r.id));
  }
  return renamed;
}

async function insertRenameRows(
  db: Db,
  batchId: string,
  rows: readonly RenameRow[],
): Promise<void> {
  if (rows.length === 0) return;
  for (const part of chunk(rows, rowsPerStatement(9))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [
        batchId,
        r.input.line,
        r.input.venue_id,
        // By construction this is the name the venue had a moment ago: the row
        // only reached here because the live name equalled it.
        r.input.expected_name,
        r.input.new_name,
        r.input.source_id,
        r.input.source_url,
        r.verdict,
        JSON.stringify({
          note: r.input.note,
          live_name: r.live_name,
          city_id: r.city_id,
          city_slug: r.city_slug,
          slug: r.slug,
        }),
      ]),
      ["bigint", "int", "text", "text", "text", "text", "text", "text", "text::jsonb"],
    );
    await db.query(
      `insert into rename_rows
         (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
       values ${values}`,
      p.values,
    );
  }
}

async function insertLedger(db: Db, ledger: readonly LedgerRow[], batchKey: string): Promise<void> {
  if (ledger.length === 0) return;
  const p = new Params();
  const values = p.rows(
    ledger.map((l) => [l.publisher, FIELD_TYPE, l.items, `rename-apply:${batchKey}`]),
    ["text", "text", "int", "text"],
  );
  await db.query(
    `insert into source_capture_ledger (publisher, field_type, items, captured_at, job)
     select pub, f, n, now(), j from (values ${values}) as t(pub, f, n, j)`,
    p.values,
  );
}

/* --------------------------------------------------------- invariants ---- */

async function checkInvariants(
  db: Db,
  before: RenameCounts,
  after: RenameCounts,
  renames: readonly RenameRow[],
  rowCount: number,
  renamedIds: readonly string[],
  ledger: readonly LedgerRow[],
): Promise<Invariant[]> {
  const inv: Invariant[] = [];
  const delta = (t: string) => after[t] - before[t];
  const expect = (name: string, actual: number, wanted: number) =>
    inv.push({ name, ok: actual === wanted, detail: `${actual} (expected ${wanted})` });

  expect("renamed venues equals the rename rows in the file", renamedIds.length, renames.length);

  // Every renamed venue now carries its new name, read back from the table.
  let wrong = 0;
  for (const part of chunk(renames, rowsPerStatement(2))) {
    const p = new Params();
    const values = p.rows(
      part.map((r) => [r.input.venue_id, r.input.new_name]),
      ["text", "text"],
    );
    const { rows } = await db.query<{ n: string }>(
      `select count(*)::text as n
         from (values ${values}) as t(venue_id, new_name)
         join venues v on v.id = t.venue_id
        where v.name is distinct from t.new_name`,
      p.values,
    );
    wrong += Number(rows[0].n);
  }
  inv.push({
    name: "every renamed venue's live name is its new_name",
    ok: wrong === 0,
    detail: `${wrong} of ${renames.length} disagree`,
  });

  expect("venue count unchanged", delta("venues"), 0);
  expect("award count unchanged", delta("awards"), 0);
  expect("slug count unchanged - a rename never changes a URL", delta("slugs"), 0);
  expect("blurb count unchanged", delta("blurbs"), 0);
  expect(
    "ledger rows added equals the publishers in the batch",
    delta("source_capture_ledger"),
    ledger.length,
  );
  expect("rename_rows written equals the rows in the file", delta("rename_rows"), rowCount);
  expect("one rename_batches row", delta("rename_batches"), 1);

  /**
   * The receipt, read back out of audit_log.
   *
   * `audit_log.at` defaults to now(), which is the TRANSACTION timestamp, so
   * every row this transaction wrote carries the same one. Counting the venue
   * UPDATEs under it proves two things at once: that this transaction renamed
   * exactly the venues it said it would, and that nothing else slipped through
   * while `app.allow_rename` was on.
   */
  const { rows: audit } = await db.query<{ renames: string; other: string }>(
    `select
       count(*) filter (where old_row->>'name' is distinct from new_row->>'name')::text as renames,
       count(*) filter (where old_row->>'name' is not distinct from new_row->>'name')::text as other
       from audit_log
      where table_name = 'venues' and action = 'UPDATE' and at = transaction_timestamp()`,
  );
  inv.push({
    name: "audit_log shows exactly this batch's renames for this transaction",
    ok: Number(audit[0].renames) === renames.length && Number(audit[0].other) === 0,
    detail:
      `${audit[0].renames} name changes (expected ${renames.length}), ` +
      `${audit[0].other} other venue updates (expected 0)`,
  });

  return inv;
}

/* --------------------------------------------------------------- main ---- */

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const wanted = `RENAME ${args.batchKey}`;
  const reportPath = join(args.out, `${args.batchKey}-rename.md`);

  if (args.confirm !== wanted) {
    console.error(
      `\nNothing was renamed.\n\n` +
        `The confirmation field has to read exactly:\n\n    ${wanted}\n\n` +
        `It read:\n\n    ${args.confirm === "" ? "(empty)" : args.confirm}\n\n` +
        `Copy the line above, including the batch key, and run the workflow again.\n`,
    );
    process.exitCode = 1;
    return;
  }

  const inputs = loadRenameCsv(args.csv, readFileSync(args.csv, "utf8"));
  if (inputs.length === 0) {
    // Not a no-op: an empty file spends a batch key on nothing, and a key is
    // spent for ever. Far more likely, the wrong file was pointed at.
    throw new Error(
      `${args.csv} has a header row and no data rows. Nothing was renamed, and the batch key ` +
        `"${args.batchKey}" is still free.`,
    );
  }
  console.log(`read ${inputs.length} rows from ${args.csv}`);

  const { client: db, close } = await connect();
  let committed = false;

  try {
    /* ------------------------- one transaction ------------------------- */
    await db.query("BEGIN");

    /* 1. the batch key is free -------------------------------------------- */
    // Any existing key is a refusal, whatever its status. A `staged` row cannot
    // survive a failed run - the whole run is one transaction - so a key that
    // is there is a key that was used. The UNIQUE constraint on batch_key is
    // what makes this hold under two clicks at once; this check is what makes
    // it say something useful.
    const { rows: existing } = await db.query<{
      status: string;
      applied_at: string | null;
      undone_at: string | null;
    }>(
      `select status::text, applied_at::text as applied_at, undone_at::text as undone_at
         from rename_batches where batch_key = $1 for update`,
      [args.batchKey],
    );
    if (existing.length > 0) {
      const b = existing[0];
      await db.query("ROLLBACK");
      throw new Error(
        `Batch "${args.batchKey}" already exists, with status ${b.status}` +
          (b.applied_at ? ` (applied ${b.applied_at})` : "") +
          (b.undone_at ? ` (undone ${b.undone_at})` : "") +
          `. Nothing was changed.\n\n` +
          `A rename batch key is used once, for ever. To rename more venues - including ` +
          `putting back something this batch got wrong - build a new file and run it under a ` +
          `NEW key, so the report you read describes the database as it is now.`,
      );
    }

    const before = await readRenameCounts(db);

    const { rows: created } = await db.query<{ id: string }>(
      `insert into rename_batches (batch_key, status, note)
       values ($1, 'staged', $2) returning id::text`,
      [args.batchKey, args.note || null],
    );
    const batchId = created[0].id;

    /* 2. verdicts ---------------------------------------------------------- */
    const sources = await loadSources(db);
    const dupes = linesByVenue(inputs);
    const rows = inputs.map((input) => checkRow(input, args.batchKey, sources, dupes));

    const live = rows.filter((r) => r.verdict === "rename");
    const state = await loadVenueState(
      db,
      live.map((r) => r.input.venue_id),
    );

    for (const r of live) {
      const v = state.get(r.input.venue_id);
      if (!v) {
        r.verdict = "reject";
        r.reason = "venue_not_found";
        r.detail = r.input.venue_id;
        continue;
      }
      r.live_name = v.name;
      r.city_id = v.city_id;
      r.city_slug = v.city_slug;
      r.slug = v.slug;

      if (v.name === r.input.new_name) {
        // Already carries the name the file wants. Skipped, not an error: a
        // file re-run after a partial hand fix must not fail on the rows that
        // are already right.
        r.verdict = "no_change";
        r.reason = null;
        continue;
      }
      if (v.name !== r.input.expected_name) {
        r.verdict = "reject";
        r.reason = "name_moved";
        r.detail =
          `live name is "${v.name}", the file expected "${r.input.expected_name}" ` +
          `and wanted "${r.input.new_name}"`;
      }
    }

    const collisions = await findCollisions(
      db,
      rows
        .filter((r) => r.verdict === "rename")
        .map((r) => ({ venue_id: r.input.venue_id, new_name: r.input.new_name })),
    );
    for (const r of rows) {
      const c = collisions.get(r.input.venue_id);
      if (r.verdict !== "rename" || !c) continue;
      r.verdict = "review";
      r.reason = "norm_key_collision";
      r.detail =
        `"${r.input.new_name}" would share a norm_key with ${c.other_id} ("${c.other_name}") ` +
        `in the same city` +
        (c.other_in_batch ? `, which this same batch also renames` : "") +
        (c.already ? `. The two names already collide today` : "");
    }

    /* 3. downstream impact, before anything changes ------------------------ */
    const renames = rows.filter((r) => r.verdict === "rename");
    const impact = await loadImpact(
      db,
      renames.map((r) => r.input.venue_id),
    );
    const scan = await scanNameColumns(
      db,
      renames.map((r) => r.input.expected_name),
    );

    const rejects = rows.filter((r) => r.verdict === "reject");
    const reviews = rows.filter((r) => r.verdict === "review");
    const registered = new Set([...sources.keys()]);
    const ledger = buildLedger(renames, registered);

    /* 4. one bad row stops the batch --------------------------------------- */
    if (rejects.length > 0 || reviews.length > 0) {
      const report = buildReport({
        args,
        rows,
        impact,
        scan,
        ledger,
        before,
        after: before,
        invariants: [],
        committed: false,
        refused: true,
      });
      await db.query("ROLLBACK");
      writeFile(reportPath, report);
      console.log(report);
      throw new Error(
        `${rejects.length} rejected row(s) and ${reviews.length} row(s) needing your eyes. ` +
          `Nothing was renamed and no batch row was written.\n\n` +
          [...rejects, ...reviews]
            .slice(0, 20)
            .map((r) => `  - line ${r.input.line} ${r.reason}: ${r.detail ?? r.input.venue_id}`)
            .join("\n") +
          ([...rejects, ...reviews].length > 20
            ? `\n  ... and ${[...rejects, ...reviews].length - 20} more, all in the report`
            : "") +
          `\n\nFix the file and run it again under a NEW batch key. This one was never used.`,
      );
    }

    /* 5. the renames ------------------------------------------------------- */
    // The only place in this repository that sets the guard flag, and it is off
    // again on the very next statement. SET LOCAL ends with the transaction in
    // any case; turning it off here as well makes the window it is open for
    // exactly the UPDATE this job came to run, and nothing after it.
    await db.query(`set local app.allow_rename = 'on'`);
    const renamedIds = await applyRenames(db, renames);
    await db.query(`set local app.allow_rename = 'off'`);

    await insertRenameRows(db, batchId, rows);

    /* 6. the ledger -------------------------------------------------------- */
    await insertLedger(db, ledger, args.batchKey);

    /* 7. the batch is applied ---------------------------------------------- */
    await db.query(
      `update rename_batches set status = 'applied', applied_at = now() where id = $1`,
      [batchId],
    );

    /* 8. invariants -------------------------------------------------------- */
    const after = await readRenameCounts(db);
    const invariants = await checkInvariants(
      db,
      before,
      after,
      renames,
      rows.length,
      renamedIds,
      ledger,
    );
    const failed = invariants.filter((i) => !i.ok);
    if (failed.length > 0) {
      await db.query("ROLLBACK");
      throw new Error(
        `Invariant failure - the whole batch was rolled back and NOTHING changed:\n` +
          failed.map((f) => `  - ${f.name}: ${f.detail}`).join("\n"),
      );
    }

    /* 9. dry run rolls back here ------------------------------------------- */
    if (args.dryRun) {
      await db.query("ROLLBACK");
    } else {
      await db.query("COMMIT");
      committed = true;
    }

    /* 10. read the counts back and report ---------------------------------- */
    const actual = committed ? await readRenameCounts(db) : after;
    const report = buildReport({
      args,
      rows,
      impact,
      scan,
      ledger,
      before,
      after: actual,
      invariants,
      committed,
      refused: false,
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
  args: ApplyArgs;
  rows: RenameRow[];
  impact: Map<string, VenueImpact>;
  scan: NameScan;
  ledger: LedgerRow[];
  before: RenameCounts;
  after: RenameCounts;
  invariants: Invariant[];
  committed: boolean;
  refused: boolean;
}

function awardsCell(impact: VenueImpact | undefined): string {
  if (!impact || impact.awards.size === 0) return "none";
  return [...impact.awards.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
    .map(([publisher, n]) => `${publisher} ${n}`)
    .join(", ");
}

function buildReport(i: ReportInput): string {
  const { args, rows, before, after } = i;
  const renames = rows.filter((r) => r.verdict === "rename");
  const noChange = rows.filter((r) => r.verdict === "no_change");
  const rejects = rows.filter((r) => r.verdict === "reject");
  const reviews = rows.filter((r) => r.verdict === "review");
  const publishers = tallyBy(renames, (r) => r.input.source_id);

  const expected: RenameCounts = {
    venues: before.venues,
    awards: before.awards,
    slugs: before.slugs,
    blurbs: before.blurbs,
    source_capture_ledger: before.source_capture_ledger + i.ledger.length,
    rename_batches: before.rename_batches + 1,
    rename_rows: before.rename_rows + rows.length,
  };

  const out: string[] = [];
  const p = (s = "") => out.push(s);

  p(`# Rename apply - ${args.batchKey}`);
  p();
  if (i.refused) {
    p(`**REFUSED. Nothing was renamed.** No batch row was written either, so this key is`);
    p(`still free - though the fixed file should go under a new one anyway.`);
  } else if (i.committed) {
    p(`Committed ${new Date().toISOString()}. One transaction, all of it or none of it.`);
  } else {
    p(`**DRY RUN - rolled back.** Everything below is what would have happened.`);
    p(`Every name in the database is exactly as it was.`);
  }
  p();

  /* --- the headline --- */
  p(
    mdTable(
      ["field", "value"],
      [
        ["batch key", `\`${args.batchKey}\``],
        ["CSV", `\`${args.csv}\``],
        ["rows in the file", String(rows.length)],
        ["renamed", String(renames.length)],
        ["already right (`no_change`)", String(noChange.length)],
        ["refused (`reject`)", String(rejects.length)],
        ["needs your eyes (`review`)", String(reviews.length)],
        ["note", args.note || "(none)"],
      ],
    ),
  );
  p();

  /* --- verdicts --- */
  p(`## Verdicts`);
  p();
  p(`Population: all ${rows.length} data row(s) in the CSV. Every row gets exactly one.`);
  p();
  p(
    mdTable(
      ["verdict", "rows", "what it means"],
      [
        ["`rename`", String(renames.length), "the name changes"],
        [
          "`no_change`",
          String(noChange.length),
          "the venue already carries the new name; skipped, not an error",
        ],
        ["`reject`", String(rejects.length), "the row failed a check; the whole batch stops"],
        [
          "`review`",
          String(reviews.length),
          "a human has to answer this one; the whole batch stops",
        ],
      ],
    ),
  );
  p();

  if (rejects.length > 0) {
    p(`### Refused rows`);
    p();
    p(`Population: the ${rejects.length} rejected rows. Grouping key: the reason.`);
    p();
    p(
      mdTable(
        ["reason", "rows", "example"],
        [...tallyBy(rejects, (r) => r.reason ?? "?").entries()].map(([reason, n]) => {
          const ex = rejects.find((r) => r.reason === reason) as RenameRow;
          return [`\`${reason}\``, String(n), cell(`line ${ex.input.line}: ${ex.detail ?? ""}`)];
        }),
      ),
    );
    p();
    p(
      mdTable(
        ["line", "venue id", "reason", "detail"],
        rejects
          .slice(0, 50)
          .map((r) => [
            String(r.input.line),
            `\`${r.input.venue_id}\``,
            `\`${r.reason}\``,
            cell(r.detail ?? ""),
          ]),
      ),
    );
    if (rejects.length > 50) p(`\n... and ${rejects.length - 50} more.`);
    p();
  }

  if (reviews.length > 0) {
    p(`### Rows that need you`);
    p();
    p(
      `A rename that would put two venues in one city under the same \`norm_key\` is the ` +
        `same situation the ingest job sends to a human, so this job does too. One of these ` +
        `stops the batch exactly as a rejection does.`,
    );
    p();
    p(
      mdTable(
        ["line", "venue id", "from", "to", "what was found"],
        reviews.map((r) => [
          String(r.input.line),
          `\`${r.input.venue_id}\``,
          cell(r.live_name ?? r.input.expected_name),
          cell(r.input.new_name),
          cell(r.detail ?? ""),
        ]),
      ),
    );
    p();
  }

  /* --- downstream impact --- */
  p(`## Downstream impact`);
  p();
  p(
    `Population: the ${renames.length} row(s) this batch would rename, read from the database ` +
      `before a single name changed.`,
  );
  p();
  if (renames.length === 0) {
    p(`Nothing would be renamed, so nothing downstream is touched.`);
    p();
  } else {
    const withBlurb = renames.filter((r) => i.impact.get(r.input.venue_id)?.has_blurb).length;
    const withAwards = renames.filter(
      (r) => (i.impact.get(r.input.venue_id)?.awards.size ?? 0) > 0,
    ).length;
    p(
      `${withAwards} of the ${renames.length} hold at least one award. ${withBlurb} ` +
        `${withBlurb === 1 ? "has" : "have"} a \`blurbs\` row. Every one of them keeps its slug.`,
    );
    p();
    p(
      mdTable(
        ["venue id", "city", "from", "to", "awards by publisher", "blurb", "slug (unchanged)"],
        renames.map((r) => [
          `\`${r.input.venue_id}\``,
          r.city_slug ?? "?",
          cell(r.live_name ?? r.input.expected_name),
          cell(r.input.new_name),
          cell(awardsCell(i.impact.get(r.input.venue_id))),
          i.impact.get(r.input.venue_id)?.has_blurb ? "yes" : "no",
          r.slug ? `/${r.city_slug}/${r.slug}` : "**none**",
        ]),
      ),
    );
    p();
  }
  p(
    `**The slug does not change, and neither does any URL.** Every page on the site keys on ` +
      `the venue id, and the slug is minted once. Changing a slug means a redirect and a ` +
      `decision about an address people may already have; that is a separate decision and a ` +
      `separate job, and this one will not make it for you.`,
  );
  p();
  p(`Awards are not touched either. An award row keeps the publisher's own full string.`);
  p();

  /* --- where else the name lives --- */
  p(`### Where else the name is stored`);
  p();
  p(
    renames.length === 0
      ? `Nothing to search for: no row in this file would change a name.`
      : `Searched, not assumed: all ${i.scan.scanned} text columns of every table in the ` +
          `\`public\` schema were counted against the ${renames.length} name(s) about to change ` +
          `(\`venues.name\` itself and the generated \`venues.norm_key\` excluded).`,
  );
  p();
  if (renames.length > 0 && i.scan.hits.length === 0) {
    p(
      `**Nothing.** No other table in the database stores any of these names as text, so a ` +
        `rename leaves no stale copy behind.`,
    );
    p();
  } else if (renames.length > 0) {
    p(
      mdTable(
        ["table.column", "rows holding one of these names"],
        i.scan.hits.map((h) => [`\`${h.table}.${h.column}\``, String(h.rows)]),
      ),
    );
    p();
    p(
      `Those are copies this job does **not** rewrite. It changes \`venues.name\` and nothing ` +
        `else; anything above is for your list.`,
    );
    p();
  }
  p(
    `Not searched, and named so the gap is on the record: ` +
      `${i.scan.notScanned.map((c) => `\`${c}\``).join(", ")}. Every one of those is a jsonb ` +
      `document, and every one is either history - what was true when it was written, which a ` +
      `rename must never rewrite - or a provenance document a substring match would misreport.`,
  );
  p();

  /* --- counts --- */
  p(`## Counts`);
  p();
  p(
    `Population: whole table, read inside the transaction` +
      (i.refused ? ", before the refusal." : " before and after the writes."),
  );
  p();
  p(
    i.refused
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
  if (i.refused) {
    p(`Both columns are the same number on purpose: a refused batch changes nothing at all.`);
    p();
  }
  p(
    `A rename changes no count at all except this job's own two tables and the ledger. ` +
      `\`venues\`, \`awards\`, \`slugs\` and \`blurbs\` are in the table so that "it changed ` +
      `nothing else" is a measurement rather than a promise.`,
  );
  p();

  if (i.invariants.length > 0) {
    p(`## Invariants`);
    p();
    p(`All of them checked inside the transaction. One failure rolls the whole batch back.`);
    p();
    p(invariantTable(i.invariants));
    p();
  }

  /* --- sample --- */
  p(`## Sample`);
  p();
  if (renames.length === 0) {
    p(`No row in this batch would rename anything.`);
  } else {
    p(
      `The first ${Math.min(5, renames.length)} of the ${renames.length} ` +
        `${i.refused ? "renames this batch would have made" : "renames"}, in file order. ` +
        `Population: the \`rename\` rows of this batch.`,
    );
    p();
    p(
      mdTable(
        ["venue id", "old name", "new name", "publisher", "source URL"],
        renames
          .slice(0, 5)
          .map((r) => [
            `\`${r.input.venue_id}\``,
            cell(r.live_name ?? r.input.expected_name),
            cell(r.input.new_name),
            r.input.source_id,
            cell(r.input.source_url),
          ]),
      ),
    );
    p();
  }

  /* --- ledger --- */
  p(`## Exposure ledger`);
  p();
  if (i.ledger.length === 0) {
    p(`No rows. ${ledgerWhyNone(renames.length)}`);
  } else {
    p(
      `One row per publisher whose spelling this batch followed, field type \`${FIELD_TYPE}\`, ` +
        `job \`rename-apply:${args.batchKey}\`. Population: the \`rename\` rows, grouped by ` +
        `\`source_id\`.`,
    );
    p();
    p(
      mdTable(
        ["publisher", "field type", "venues renamed"],
        i.ledger.map((l) => [l.publisher, FIELD_TYPE, String(l.items)]),
      ),
    );
    const venueRows = renames.filter((r) => r.input.source_id === VENUE_SOURCE).length;
    if (venueRows > 0) {
      p();
      p(
        `${venueRows} row(s) name \`${VENUE_SOURCE}\` as their source - the venue's own website ` +
          `settled the spelling. The venue is not a publisher and holds no row in ` +
          `\`award_sources\`, which \`source_capture_ledger.publisher\` points at, so those ` +
          `rows are not in the ledger. They are in \`rename_rows\` with their URL, like every ` +
          `other row.`,
      );
    }
  }
  p();
  if (publishers.size > 0) {
    p(
      `Spellings followed: ` +
        [...publishers.entries()].map(([s, n]) => `${s} (${n})`).join(", ") +
        `.`,
    );
    p();
  }

  /* --- undo --- */
  p(`## Undo`);
  p();
  if (i.committed) {
    p(`Reversible with one button: **Rename - undo**, with the confirmation`);
    p(`\`UNDO-RENAME ${args.batchKey}\`. Dry-run it first - that box starts ticked.`);
    p();
    p(
      `The undo puts every name in this batch back to its \`expected_name\` and removes the ` +
        `ledger rows tagged \`rename-apply:${args.batchKey}\`. It refuses, rather than adapts, ` +
        `if a venue has been renamed again since. It runs once.`,
    );
  } else if (i.refused) {
    p(`Nothing to undo. Nothing happened.`);
  } else {
    p(`Nothing to undo: this was a dry run. Untick the box to do it for real.`);
  }
  p();
  return out.join("\n");
}

function ledgerWhyNone(renames: number): string {
  if (renames === 0) return `Nothing was renamed.`;
  return (
    `Every renamed venue's spelling came from the venue's own website (\`${VENUE_SOURCE}\`), ` +
    `which is not a publisher and has no row in \`award_sources\`.`
  );
}

main().catch((err) => {
  console.error(`\nRename failed: ${err instanceof Error ? err.message : String(err)}\n`);
  process.exitCode = 1;
});
