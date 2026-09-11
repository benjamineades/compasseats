/**
 * ingest-promote - move a staged batch into the live tables, in ONE transaction.
 *
 * Refuses to run without the exact typed confirmation. Refuses to run while any
 * review row remains. Every invariant is checked before the commit, so a batch
 * either lands whole or changes nothing at all.
 *
 *   bun run scripts/ingest/promote.ts --batch-key <key> --confirm "PROMOTE <key>"
 *                                     [--dry-run] [--out reports]
 */
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

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
import { Args } from "./lib/args.ts";
import { loadReference, type Reference, type RowResult } from "./lib/stageLogic.ts";
import { buildPlan, loadPlanState, type Plan } from "./lib/plan.ts";

interface PromoteArgs {
  batchKey: string;
  confirm: string;
  dryRun: boolean;
  out: string;
}

const USAGE =
  'usage: promote.ts --batch-key <key> --confirm "PROMOTE <key>" [--dry-run] [--out <dir>]';

function parseArgs(argv: string[]): PromoteArgs {
  // Args rejects a repeated flag outright. That matters here more than
  // anywhere: a second --confirm must never be able to appear and win.
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

/* ------------------------------------------------------- staged rows ----- */

interface StagedRow {
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

/**
 * Rebuild the promote plan from what stage wrote. Promote re-resolves nothing:
 * the verdicts Ben approved are the verdicts that run.
 */
function toRowResults(rows: StagedRow[]): RowResult[] {
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

/* ---------------------------------------------------------- the writes --- */

async function insertVenues(db: Db, plan: Plan, batchKey: string): Promise<void> {
  if (plan.venues.length === 0) return;

  // venues - name, category, city_id, status and nothing else.
  // norm_key is GENERATED: never insert it.
  for (const part of chunk(plan.venues, rowsPerStatement(5))) {
    const p = new Params();
    const values = p.rows(
      part.map((v) => [v.venue_id, v.name, v.category, v.city_id, v.status]),
      ["text", "text", "venue_category", "text", "venue_status"],
    );
    await db.query(
      `insert into venues (id, name, category, city_id, status) values ${values}`,
      p.values,
    );
  }

  for (const part of chunk(plan.venues, rowsPerStatement(3))) {
    const p = new Params();
    const values = p.rows(
      part.map((v) => [v.venue_id, "eats", v.published]),
      ["text", "text", "boolean"],
    );
    await db.query(
      `insert into listings (venue_id, property_id, published) values ${values}`,
      p.values,
    );
  }

  for (const part of chunk(plan.venues, rowsPerStatement(5))) {
    const p = new Params();
    const values = p.rows(
      part.map((v) => ["eats", v.city_slug, v.slug, v.venue_id, true]),
      ["text", "text", "text", "text", "boolean"],
    );
    await db.query(
      `insert into slugs (property_id, city_slug, slug, venue_id, is_canonical) values ${values}`,
      p.values,
    );
  }

  for (const part of chunk(plan.labels, rowsPerStatement(5))) {
    const p = new Params();
    const values = p.rows(
      part.map((l) => [l.venue_id, l.label, l.from_column, l.publisher, batchKey]),
      ["text", "text", "label_column_t", "text", "text"],
    );
    await db.query(
      `insert into city_label_source (venue_id, label, from_column, publisher, note) values ${values}`,
      p.values,
    );
  }
}

async function insertAwards(db: Db, plan: Plan): Promise<string[]> {
  const ids: string[] = [];
  for (const part of chunk(plan.awards, rowsPerStatement(7))) {
    const p = new Params();
    const values = p.rows(
      part.map((a) => [
        a.venue_id,
        a.source_id,
        a.year,
        a.rank,
        a.category,
        a.distinction,
        a.source_url,
      ]),
      ["text", "text", "int", "int", "text", "text", "text"],
    );
    const { rows } = await db.query<{ id: string }>(
      `insert into awards (venue_id, source_id, year, rank, category, distinction, source_url)
       values ${values} returning id::text`,
      p.values,
    );
    ids.push(...rows.map((r) => String(r.id)));
  }
  return ids;
}

async function insertPrices(db: Db, plan: Plan): Promise<void> {
  for (const part of chunk(plan.prices, rowsPerStatement(5))) {
    const p = new Params();
    const values = p.rows(
      part.map((x) => [x.venue_id, x.tier, x.symbol_raw, x.publisher, x.source_url]),
      ["text", "smallint", "text", "text", "text"],
    );
    await db.query(
      `insert into price (venue_id, tier, symbol_raw, source, method, publisher, source_url, captured_at)
       select v, t, s, 'guide_ingest'::price_source_t, 'published_symbol'::price_method_t, pub, u, now()
         from (values ${values}) as x(v, t, s, pub, u)`,
      p.values,
    );
  }
}

async function insertLedger(db: Db, plan: Plan, batchKey: string): Promise<void> {
  if (plan.ledger.length === 0) return;
  const p = new Params();
  const values = p.rows(
    plan.ledger.map((l) => [l.publisher, l.field_type, l.items, `ingest-promote:${batchKey}`]),
    ["text", "text", "int", "text"],
  );
  await db.query(
    `insert into source_capture_ledger (publisher, field_type, items, captured_at, job)
     select pub, f, n, now(), j from (values ${values}) as t(pub, f, n, j)`,
    p.values,
  );
}

/* ---------------------------------------------------------- pre-flight --- */

/**
 * Stage looked at the database as it was when it ran. Promote runs later, and
 * in between another batch may have been promoted, or a publisher suspended.
 *
 * These checks run inside the transaction, before a single row is written, and
 * they refuse rather than adapt. Adapting would mean either silently creating a
 * second venue for a restaurant that now exists - the duplication this whole
 * design exists to prevent - or quietly merging into it, which is the
 * auto-merge the design equally forbids. Refusing sends Ben back to stage,
 * where the same rules get applied with his eyes on the result.
 */
async function preflight(db: Db, plan: Plan, ref: Reference): Promise<string[]> {
  const problems: string[] = [];

  // 1. a venue this batch means to create may have appeared since staging
  for (const part of chunk(plan.venues, rowsPerStatement(3))) {
    const p = new Params();
    const values = p.rows(
      part.map((v) => [v.venue_id, v.name, v.city_id]),
      ["text", "text", "text"],
    );
    const { rows } = await db.query<{ planned: string; existing: string; name: string }>(
      `select t.planned_id as planned, v.id as existing, v.name
         from (values ${values}) as t(planned_id, name, city_id)
         join venues v
           on v.city_id = t.city_id
          and v.norm_key is not distinct from norm_key(t.name)
          and v.norm_key is not null`,
      p.values,
    );
    const known = new Map(part.map((v) => [v.venue_id, v.knownVenueIds]));
    for (const r of rows) {
      // A venue the operator was shown as a candidate and still answered "new"
      // to is a decision, not a collision.
      if ((known.get(r.planned) ?? []).includes(r.existing)) continue;
      problems.push(
        `"${r.name}" now already exists as ${r.existing} in that city - it was not there ` +
          `when this batch was staged. Re-stage under a new batch key so it resolves as a match.`,
      );
    }
  }

  // 2. the slug this batch means to mint may have been taken since staging
  for (const part of chunk(plan.venues, rowsPerStatement(2))) {
    const p = new Params();
    const values = p.rows(
      part.map((v) => [v.city_slug, v.slug]),
      ["text", "text"],
    );
    const { rows } = await db.query<{ city_slug: string; slug: string; venue_id: string }>(
      `select s.city_slug, s.slug, s.venue_id
         from (values ${values}) as t(city_slug, slug)
         join slugs s on s.property_id = 'eats' and s.city_slug = t.city_slug and s.slug = t.slug`,
      p.values,
    );
    for (const r of rows) {
      problems.push(
        `the URL /${r.city_slug}/${r.slug} was taken by ${r.venue_id} after this batch was ` +
          `staged. Re-stage under a new batch key.`,
      );
    }
  }

  // 3. an award this batch means to insert may already be live
  for (const part of chunk(plan.awards, rowsPerStatement(7))) {
    const p = new Params();
    const values = p.rows(
      part.map((a) => [a.line, a.venue_id, a.source_id, a.year, a.rank, a.category, a.distinction]),
      ["int", "text", "text", "int", "int", "text", "text"],
    );
    const { rows } = await db.query<{ line: number; id: string }>(
      `select t.line, a.id::text as id
         from (values ${values}) as t(line, venue_id, source_id, year, rank, category, distinction)
         join awards a
           on a.venue_id = t.venue_id
          and a.source_id = t.source_id
          and a.year is not distinct from t.year
          and a.rank is not distinct from t.rank
          and a.category is not distinct from t.category
          and a.distinction is not distinct from t.distinction`,
      p.values,
    );
    for (const r of rows) {
      problems.push(
        `line ${r.line}'s award already exists as awards.id ${r.id} - it was not there when ` +
          `this batch was staged. Re-stage under a new batch key so it resolves as a duplicate.`,
      );
    }
  }

  // 4. a publisher may have been suspended since staging (the D10 switch)
  const suspended = [...new Set(plan.awards.map((a) => a.source_id))].filter(
    (slug) => ref.sources.get(slug)?.status !== "active",
  );
  for (const slug of suspended) {
    problems.push(`${slug} is no longer an active source. Its rows cannot promote.`);
  }

  // 5. a category may have left the vocabulary since staging
  for (const a of plan.awards) {
    if (a.category === null) continue;
    const known = ref.categories.get(a.source_id)?.has(a.category) ?? false;
    const echo = /^No\.\s*(\d+)$/i.exec(a.category.trim());
    const echoOk = echo !== null && a.rank !== null && Number(echo[1]) === a.rank;
    if (!known && !echoOk) {
      problems.push(
        `line ${a.line}: "${a.category}" is no longer in ${a.source_id}'s category vocabulary.`,
      );
    }
  }

  return problems;
}

/* --------------------------------------------------------- invariants ---- */

interface Invariant {
  name: string;
  ok: boolean;
  detail: string;
}

async function checkInvariants(
  db: Db,
  before: TableCounts,
  after: TableCounts,
  plan: Plan,
  awardIds: string[],
): Promise<Invariant[]> {
  const inv: Invariant[] = [];
  const delta = (t: keyof TableCounts) => after[t] - before[t];

  const expect = (name: string, actual: number, wanted: number) =>
    inv.push({
      name,
      ok: actual === wanted,
      detail: `${actual} (expected ${wanted})`,
    });

  expect("awards delta equals promoted award rows", delta("awards"), plan.awards.length);
  expect("venues delta equals new venues", delta("venues"), plan.venues.length);
  expect("listings delta equals new venues", delta("listings"), plan.venues.length);
  expect("slugs delta equals new venues", delta("slugs"), plan.venues.length);
  expect(
    "city_label_source delta equals planned labels",
    delta("city_label_source"),
    plan.labels.length,
  );
  expect("price delta equals planned price rows", delta("price"), plan.prices.length);
  expect(
    "ledger delta equals planned ledger rows",
    delta("source_capture_ledger"),
    plan.ledger.length,
  );

  inv.push({
    name: "active venue count did not drop",
    ok: after.venues_active >= before.venues_active,
    detail: `${before.venues_active} -> ${after.venues_active}`,
  });

  if (awardIds.length > 0) {
    // Chunked like every other statement: 65,535 parameters is the hard cap,
    // and a Michelin batch is thousands of rows.
    let badUrl = 0;
    let badSource = 0;
    for (const part of chunk(awardIds, 20000)) {
      const q = new Params();
      const idList = q.list(part, "bigint");
      const { rows } = await db.query<{ bad_url: string; bad_source: string }>(
        `select
           (select count(*) from awards a
             where a.id in (${idList})
               and (a.source_url is null or btrim(a.source_url) = ''))::text as bad_url,
           (select count(*) from awards a
             left join award_sources s on s.slug = a.source_id
             where a.id in (${idList}) and s.slug is null)::text as bad_source`,
        q.values,
      );
      badUrl += Number(rows[0].bad_url);
      badSource += Number(rows[0].bad_source);
    }
    inv.push({
      name: "every inserted award carries a source_url",
      ok: badUrl === 0,
      detail: `${badUrl} without one`,
    });
    inv.push({
      name: "every inserted award names a registered source",
      ok: badSource === 0,
      detail: `${badSource} unregistered`,
    });
  } else {
    inv.push({
      name: "every inserted award carries a source_url",
      ok: true,
      detail: "0 awards inserted",
    });
    inv.push({
      name: "every inserted award names a registered source",
      ok: true,
      detail: "0 awards inserted",
    });
  }

  // Belt and braces. The enums and the foreign keys to award_sources already
  // make 'google' an impossible provenance value; this proves it for the rows
  // this batch just wrote. Provenance columns only - a venue's own NAME is not
  // a provenance claim.
  const GOOGLE_HOST = String.raw`//([a-z0-9-]+\.)*google\.`;
  let googleHits = 0;
  for (const part of chunk(awardIds.length > 0 ? awardIds : ["0"], 20000)) {
    const gq = new Params();
    const gList = gq.list(part, "bigint");
    const gPattern = gq.add(GOOGLE_HOST);
    const { rows } = await db.query<{ n: string }>(
      `select (select count(*) from awards a
                 where a.id in (${gList})
                   and (a.source_id ~* 'google'
                        or coalesce(a.source_url, '') ~* ${gPattern}))::text as n`,
      gq.values,
    );
    googleHits += Number(rows[0].n);
  }
  const googleRe = new RegExp(GOOGLE_HOST, "i");
  const inPlan =
    plan.ledger.some((l) => /google/i.test(l.publisher)) ||
    plan.labels.some((l) => /google/i.test(l.publisher)) ||
    plan.prices.some((p) => /google/i.test(p.publisher) || googleRe.test(p.source_url));
  const clean = googleHits === 0 && !inPlan;
  inv.push({
    name: "no google value anywhere in what was written",
    ok: clean,
    detail: clean ? "clean" : "FOUND - see awards.source_id/source_url and the publisher columns",
  });

  return inv;
}

/* --------------------------------------------------------------- main ---- */

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const wanted = `PROMOTE ${args.batchKey}`;

  if (args.confirm !== wanted) {
    console.error(
      `\nNothing was promoted.\n\n` +
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
    const { rows: batches } = await db.query<{ id: string; status: string; note: string | null }>(
      `select id::text, status::text, note from ingest_batches where batch_key = $1`,
      [args.batchKey],
    );
    if (batches.length === 0) {
      throw new Error(`No batch with key "${args.batchKey}". Stage it first.`);
    }
    const batch = batches[0];

    if (batch.status === "promoted") {
      const body =
        `# Ingest promote - no-op\n\n` +
        `Batch **${args.batchKey}** is already \`promoted\`. Nothing was changed.\n\n` +
        `Re-running promote with the same key is always safe: this is the guard against ` +
        `"it timed out so I ran it twice".\n`;
      writeFile(join(args.out, `${args.batchKey}-promote.md`), body);
      console.log(body);
      return;
    }
    if (batch.status !== "staged") {
      throw new Error(
        `Batch "${args.batchKey}" is ${batch.status}, not staged. Promote only runs on a staged batch.`,
      );
    }

    const { rows: rawStaged } = await db.query<{
      id: string;
      verdict: string;
      validation: unknown;
    }>(`select id::text, verdict, validation from ingest_rows where batch_id = $1 order by id`, [
      batch.id,
    ]);
    const staged: StagedRow[] = rawStaged.map((r) => ({
      id: r.id,
      verdict: r.verdict,
      validation: asJson<StagedRow["validation"]>(r.validation, null),
    }));

    const reviews = staged.filter(
      (r) => r.verdict === "review_city" || r.verdict === "review_venue",
    );
    if (reviews.length > 0) {
      const lines = reviews
        .slice(0, 50)
        .map(
          (r) =>
            `  line ${r.validation?.line}: ${r.verdict} - ${r.validation?.input.venue_name} (${r.validation?.input.city_label})`,
        )
        .join("\n");
      throw new Error(
        `${reviews.length} row(s) are still in review. Promote will not run until every one ` +
          `has a decision.\n\n${lines}${reviews.length > 50 ? `\n  ... and ${reviews.length - 50} more` : ""}\n\n` +
          `Fill the decision column in reports/${args.batchKey}-review.csv and re-run the ` +
          `stage workflow with that file.`,
      );
    }

    const results = toRowResults(staged);
    const ref = await loadReference(db);

    /* ------------------------- one transaction ------------------------- */
    await db.query("BEGIN");

    // Lock the batch row and re-read its status inside the transaction. The
    // check above happened outside it; two promotes started at once would
    // otherwise both get past it.
    const { rows: locked } = await db.query<{ status: string }>(
      `select status::text from ingest_batches where id = $1 for update`,
      [batch.id],
    );
    if (locked[0]?.status !== "staged") {
      await db.query("ROLLBACK");
      throw new Error(
        `Batch "${args.batchKey}" is ${locked[0]?.status ?? "gone"}, not staged - something ` +
          `else changed it while this run was starting. Nothing was changed.`,
      );
    }

    await db.query(
      `update ingest_batches set status = 'approved', approved_at = now() where id = $1`,
      [batch.id],
    );

    const before = await readCounts(db);

    const citySlugs = [...new Set(results.map((r) => r.city_slug).filter(Boolean) as string[])];
    const venueIds = [...new Set(results.map((r) => r.venue_id).filter(Boolean) as string[])];
    const planState = await loadPlanState(db, citySlugs, venueIds);
    const plan = buildPlan({
      batchKey: args.batchKey,
      results,
      sources: ref.sources,
      ...planState,
    });

    const problems = await preflight(db, plan, ref);
    if (problems.length > 0) {
      await db.query("ROLLBACK");
      throw new Error(
        `The database has moved on since this batch was staged, so promoting it would not do ` +
          `what the stage report said. Nothing was changed.\n\n` +
          problems.map((x) => `  - ${x}`).join("\n") +
          `\n\nRe-stage under a NEW batch key. The same rules will run again against the ` +
          `database as it is now, and you will see the new report before anything happens.`,
      );
    }

    await insertVenues(db, plan, args.batchKey);
    const awardIds = await insertAwards(db, plan);
    await insertPrices(db, plan);
    await insertLedger(db, plan, args.batchKey);

    await db.query(`update ingest_batches set status = 'promoted' where id = $1`, [batch.id]);

    const after = await readCounts(db);
    const invariants = await checkInvariants(db, before, after, plan, awardIds);
    const failed = invariants.filter((i) => !i.ok);

    if (failed.length > 0) {
      await db.query("ROLLBACK");
      throw new Error(
        `Invariant failure - the whole batch was rolled back and NOTHING changed:\n` +
          failed.map((f) => `  - ${f.name}: ${f.detail}`).join("\n"),
      );
    }

    if (args.dryRun) {
      await db.query("ROLLBACK");
    } else {
      await db.query("COMMIT");
      committed = true;
    }

    /* ------------------------- read back, report ----------------------- */
    const actual = committed ? await readCounts(db) : after;
    const report = buildReport({ args, plan, before, after: actual, invariants, committed });
    writeFile(join(args.out, `${args.batchKey}-promote.md`), report);
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
  args: PromoteArgs;
  plan: Plan;
  before: TableCounts;
  after: TableCounts;
  invariants: Invariant[];
  committed: boolean;
}

function buildReport(i: ReportInput): string {
  const { args, plan, before, after } = i;
  const expected: Record<string, number> = {
    venues: before.venues + plan.venues.length,
    awards: before.awards + plan.awards.length,
    listings: before.listings + plan.venues.length,
    slugs: before.slugs + plan.venues.length,
    city_label_source: before.city_label_source + plan.labels.length,
    price: before.price + plan.prices.length,
    source_capture_ledger: before.source_capture_ledger + plan.ledger.length,
  };

  const out: string[] = [];
  const p = (s = "") => out.push(s);

  p(`# Ingest promote - ${args.batchKey}`);
  p();
  if (i.committed) {
    p(`Committed ${new Date().toISOString()}. One transaction, all of it or none of it.`);
  } else {
    p(`**Dry run - rolled back.** Everything below is what would have happened.`);
    p(`The live tables are exactly as they were.`);
  }
  p();

  p(`## Counts`);
  p();
  p(`Population: whole table, read inside the transaction before and after the writes.`);
  p();
  p(
    mdTable(
      ["table", "before", "expected", "actual"],
      COUNTED_TABLES.map((t) => [
        t,
        before[t].toLocaleString(),
        expected[t].toLocaleString(),
        after[t].toLocaleString(),
      ]),
    ),
  );
  p();
  p(
    `Active venues: ${before.venues_active.toLocaleString()} -> ${after.venues_active.toLocaleString()}.`,
  );
  p();

  p(`## Invariants`);
  p();
  p(
    mdTable(
      ["check", "result", "detail"],
      i.invariants.map((v) => [v.name, v.ok ? "pass" : "**FAIL**", v.detail]),
    ),
  );
  p();

  if (plan.venues.length > 0) {
    p(`## Venues created`);
    p();
    p(
      mdTable(
        ["venue id", "name", "url", "status", "published", "awards"],
        plan.venues.map((v) => [
          `\`${v.venue_id}\``,
          v.name,
          `/${v.city_slug}/${v.slug}`,
          v.status,
          String(v.published),
          String((plan.linesByVenue.get(v.venue_id) ?? []).length),
        ]),
      ),
    );
    p();
  }

  if (plan.ledger.length > 0) {
    p(`## Exposure ledger`);
    p();
    p(`One row per publisher and field type, job \`ingest-promote:${args.batchKey}\`.`);
    p();
    p(
      mdTable(
        ["publisher", "field type", "items"],
        plan.ledger.map((l) => [l.publisher, l.field_type, String(l.items)]),
      ),
    );
    p();
  }

  p(`## Undo`);
  p();
  p(`This batch is keyed everywhere it wrote: \`city_label_source.note\` and`);
  p(`\`source_capture_ledger.job\` both carry \`${args.batchKey}\`, and \`audit_log\` holds`);
  p(`every row with its timestamp. A reversal job is a separate piece of work - there is`);
  p(`no undo button here.`);
  p();
  return out.join("\n");
}

main().catch((err) => {
  console.error(`\nPromote failed: ${err instanceof Error ? err.message : String(err)}\n`);
  process.exitCode = 1;
});
