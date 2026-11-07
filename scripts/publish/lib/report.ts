import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

import { toCsv } from "../../ingest/lib/csv.ts";
import { byCodePoint, canonical } from "./canonical.ts";
import type { LiveCompare } from "./compare.ts";
import type { Gate } from "./gates.ts";
import type { Snapshot } from "./read.ts";
import { BLURB_WITHHELD_STATUS, type PublishedVenue, type Shaped } from "./shape.ts";
import { versionDir } from "./tree.ts";

/* ------------------------------------------------------------- the diff --- */

export interface VersionDiff {
  against: string | null;
  added: number;
  removed: number;
  changed: number;
  same: number;
  /** venue_id, change, fields */
  rows: { venue_id: string; change: string; fields: string }[];
}

/** Every venue row of an earlier version, by id, as canonical text per top-level field. */
function loadVersionVenues(tree: string, id: string): Map<string, Record<string, string>> {
  const out = new Map<string, Record<string, string>>();
  const dir = join(versionDir(tree, id), "venues");
  if (!existsSync(dir)) return out;
  for (const name of readdirSync(dir)) {
    if (!name.endsWith(".json")) continue;
    const file = JSON.parse(readFileSync(join(dir, name), "utf8")) as { venues: Record<string, unknown>[] };
    for (const v of file.venues) out.set(String(v.id), fieldTexts(v));
  }
  return out;
}

function fieldTexts(v: object): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [k, val] of Object.entries(v)) out[k] = canonical(val);
  return out;
}

export function diffAgainst(tree: string, previous: string | null, venues: PublishedVenue[]): VersionDiff {
  if (!previous) return { against: null, added: 0, removed: 0, changed: 0, same: 0, rows: [] };
  const before = loadVersionVenues(tree, previous);
  const rows: VersionDiff["rows"] = [];
  let same = 0;
  const seen = new Set<string>();
  for (const v of venues) {
    seen.add(v.id);
    const now = fieldTexts(v);
    const was = before.get(v.id);
    if (!was) {
      rows.push({ venue_id: v.id, change: "added", fields: "" });
      continue;
    }
    const keys = [...new Set([...Object.keys(now), ...Object.keys(was)])].sort(byCodePoint);
    const fields = keys.filter((k) => now[k] !== was[k]);
    if (fields.length === 0) same += 1;
    else rows.push({ venue_id: v.id, change: "changed", fields: fields.join(" ") });
  }
  for (const id of before.keys()) {
    if (!seen.has(id)) rows.push({ venue_id: id, change: "removed", fields: "" });
  }
  rows.sort((a, b) => (a.change === b.change ? byCodePoint(a.venue_id, b.venue_id) : byCodePoint(a.change, b.change)));
  return {
    against: previous,
    added: rows.filter((r) => r.change === "added").length,
    removed: rows.filter((r) => r.change === "removed").length,
    changed: rows.filter((r) => r.change === "changed").length,
    same,
    rows,
  };
}

/* ----------------------------------------------------------- the report --- */

export interface ReportInputs {
  version: string;
  builtAt: string;
  gitSha: string;
  note: string | null;
  snap: Snapshot;
  shaped: Shaped;
  gates: Gate[];
  diff: VersionDiff;
  live: LiveCompare | null;
  liveFile: string;
  /** set after the files are hashed; absent on a failed build */
  files?: { count: number; dataFiles: number; bytes: number; contentSha256: string };
  pruned?: string[];
}

const fmt = (n: number) => n.toLocaleString("en-US");

function table(headers: string[], rows: (string | number)[][]): string {
  const out = [`| ${headers.join(" | ")} |`, `|${headers.map(() => "---").join("|")}|`];
  for (const r of rows) out.push(`| ${r.map((c) => (typeof c === "number" ? fmt(c) : c)).join(" | ")} |`);
  return out.join("\n");
}

function list(items: string[], n = 15): string {
  if (items.length === 0) return "none";
  const head = items.slice(0, n).map((i) => `\`${i}\``).join(", ");
  return items.length > n ? `${head}, and ${items.length - n} more (see report/checks.csv)` : head;
}

export function reportCsvs(r: ReportInputs): Map<string, string> {
  const out = new Map<string, string>();
  const { snap, shaped } = r;

  out.set(
    "report/gates.csv",
    toCsv(
      ["gate", "pass", "detail"],
      r.gates.map((g) => ({ gate: g.name, pass: g.pass ? "yes" : "no", detail: g.detail })),
    ),
  );

  // exposure: the database view (whole tables) next to what this version publishes
  const published = new Map<string, number>();
  const bump = (k: string) => published.set(k, (published.get(k) ?? 0) + 1);
  for (const v of shaped.venues) {
    for (const a of v.awards) bump(`${a.source}|award`);
    if (v.price?.publisher) bump(`${v.price.publisher}|price`);
  }
  const keys = new Set([...snap.exposure.map((e) => `${e.publisher}|${e.field_type}`), ...published.keys()]);
  const inDb = new Map(snap.exposure.map((e) => [`${e.publisher}|${e.field_type}`, e.items]));
  out.set(
    "report/exposure.csv",
    toCsv(
      ["publisher", "field_type", "database_items", "published_items"],
      [...keys].sort(byCodePoint).map((k) => {
        const [publisher, field_type] = k.split("|");
        return {
          publisher,
          field_type,
          database_items: String(inDb.get(k) ?? 0),
          published_items: String(published.get(k) ?? 0),
        };
      }),
    ),
  );

  const pub = new Set(shaped.venues.map((v) => v.id));
  out.set(
    "report/blurbs.csv",
    toCsv(
      ["venue_id", "status", "version", "published", "reason"],
      [...snap.blurbs]
        .sort((a, b) => byCodePoint(a.venue_id, b.venue_id))
        .map((b) => {
          const reason = !pub.has(b.venue_id)
            ? "venue not published"
            : b.status === BLURB_WITHHELD_STATUS
              ? "status needs_rewrite (rule Q4)"
              : "";
          return {
            venue_id: b.venue_id,
            status: b.status,
            version: String(b.version),
            published: reason ? "no" : "yes",
            reason,
          };
        }),
    ),
  );

  out.set("report/diff.csv", toCsv(["venue_id", "change", "fields"], r.diff.rows));

  out.set(
    "report/city-counts.csv",
    toCsv(
      ["city_slug", "stored_venues_count", "counted_by_job"],
      shaped.checks.cityCountDiffers.map((c) => ({
        city_slug: c.slug,
        stored_venues_count: String(c.stored),
        counted_by_job: String(c.counted),
      })),
    ),
  );

  const checks: { check: string; item: string }[] = [];
  for (const c of shaped.checks.pathCityDiffers) checks.push({ check: "path_city_differs", item: `${c.id} ${c.name} ${c.path} (city ${c.city})` });
  for (const id of shaped.checks.venuesWithoutAward) checks.push({ check: "venue_without_award", item: id });
  for (const f of shaped.checks.redirectShadowsPage) checks.push({ check: "redirect_from_is_a_page", item: f });
  for (const f of shaped.checks.redirectToUnknown) checks.push({ check: "redirect_to_not_a_page", item: f });
  for (const f of shaped.checks.duplicateRedirectFrom) checks.push({ check: "redirect_from_twice", item: f });
  out.set("report/checks.csv", toCsv(["check", "item"], checks));

  if (r.live) {
    out.set(
      "report/compare-live.csv",
      toCsv(
        ["group", "name_differs", "live_path", "live_name", "venue_id", "db_name", "db_path"],
        // no live_id: the live ids are Google place ids, and no Google value goes in a version folder
        r.live.rows.map((x) => ({ ...x })),
      ),
    );
  }
  return out;
}

export function reportMarkdown(r: ReportInputs): string {
  const { snap, shaped } = r;
  const ok = r.gates.every((g) => g.pass);
  const L: string[] = [];
  L.push(`# Publish build ${r.version}`);
  L.push("");
  L.push(
    ok
      ? `**Result: PASS.** All ${r.gates.length} gates passed. The version folder \`versions/${r.version}/\` is written. ` +
          `The preview does not point at it until you run **Publish — promote**.`
      : `**Result: FAIL.** ${r.gates.filter((g) => !g.pass).length} of ${r.gates.length} gates failed. ` +
          `No version folder was written. Nothing changed.`,
  );
  L.push("");
  L.push(
    table(
      ["Item", "Value"],
      [
        ["Built at (UTC)", r.builtAt],
        ["Code (git sha)", `\`${r.gitSha}\``],
        ["Database read at (UTC)", snap.readAt],
        ["Database transaction", `${snap.isolation}, read only = ${snap.transactionReadOnly}`],
        ["source_capture_ledger last id", snap.ledgerLastId === null ? "none" : String(snap.ledgerLastId)],
        ["audit_log last id", snap.auditLastId === null ? "none" : String(snap.auditLastId)],
        ["Note", r.note ?? ""],
      ],
    ),
  );
  L.push("");
  L.push("## Gates");
  L.push("");
  L.push(table(["Gate", "Result", "Detail"], r.gates.map((g) => [`\`${g.name}\``, g.pass ? "pass" : "**FAIL**", g.detail])));
  L.push("");

  L.push("## Files");
  L.push("");
  const c = shaped.counts;
  L.push(
    table(
      ["File", "Rows", "Population"],
      [
        ["`index.json`", c.venues, "1 row per venue with a published eats listing"],
        ["`venues/<city>.json`", `${fmt(c.cityFiles)} files, ${fmt(c.venues)} venue rows`, "1 file per city with a published venue"],
        ["`cities.json`", c.cities, "cities with a published venue (counts made by this job)"],
        ["`regions.json`", c.regions, "regions with a city that has a published venue"],
        ["`redirects.json`", c.redirects, `redirects table ${fmt(c.redirectsFromTable)} + old slugs of published venues ${fmt(c.redirectsFromOldSlugs)}`],
        ["`attribution.json`", shaped.files.get("attribution.json")?.rows ?? 0, "sources with at least 1 row in the files"],
      ],
    ),
  );
  L.push("");
  if (r.files) {
    L.push(
      `Data files: ${fmt(r.files.dataFiles)}, ${fmt(r.files.bytes)} bytes. The folder also holds \`report/\` and \`manifest.json\` ` +
        `(${fmt(r.files.count)} files in all). Content hash of the data files: \`${r.files.contentSha256}\`. ` +
        `\`manifest.json\` lists the sha256 of every file.`,
    );
    L.push("");
  }

  L.push("## Counts");
  L.push("");
  L.push(
    table(
      ["Item", "Count", "Population"],
      [
        ["Venues", c.venues, "venues with a published eats listing"],
        ["Restaurants / bars", `${fmt(c.restaurants)} / ${fmt(c.bars)}`, "the same venues"],
        ["Award rows", c.awards, "all years, active sources, on those venues"],
        ["Award rows with no source URL", shaped.checks.awardsWithoutUrl, "the same award rows"],
        ["Venues with a price", c.prices, "the same venues"],
        ["Venues with a blurb", c.blurbs, "the same venues (rule Q4)"],
        ["Venues with no award row", shaped.checks.venuesWithoutAward.length, "the same venues"],
        ["Cities with a published venue but no region", shaped.checks.citiesWithoutRegion, `${fmt(c.cities)} cities in cities.json`],
      ],
    ),
  );
  L.push("");

  L.push("## Left out on purpose");
  L.push("");
  const e = shaped.excluded;
  L.push(
    table(
      ["What", "Count", "Why"],
      [
        ["Award rows from a source that is not active", e.awardsSuspendedSource, "D10 suspension switch"],
        ["Price rows from a source that is not active", e.pricesSuspendedSource, "D10 suspension switch"],
        ["Cuisine tags from a source that is not active", e.cuisineSuspendedSource, "D10 suspension switch"],
        ["Blurbs with status needs_rewrite", e.blurbsNeedsRewrite, "rule Q4"],
        ["Blurbs on a venue with no published listing", e.blurbsOnUnpublishedVenue, "venue not published"],
        ["Old slugs of a venue with no published listing", e.oldSlugsOfUnpublishedVenues, "no page to send them to"],
        ["Old slugs the redirects table already sends to the same page", e.oldSlugsSameAsRedirect, "one answer, written once (the table row)"],
        ...snap.enrichment.map((x): (string | number)[] => [
          `\`${x.table}\` rows (${fmt(x.on_published)} on published venues)`,
          x.rows,
          "read and counted only; the published shape is a Phase 3 decision",
        ]),
      ],
    ),
  );
  L.push("");

  L.push("## Checks (reported, not gates)");
  L.push("");
  const k = shaped.checks;
  L.push(`- Venue address uses a city slug that is not the venue's city: ${k.pathCityDiffers.length}. ${list(k.pathCityDiffers.map((p) => `${p.id} ${p.path} (city ${p.city})`))}`);
  L.push(`- Cities where this job's count differs from \`cities.venues_count\` (population: all ${fmt(snap.cities.length)} cities): ${k.cityCountDiffers.length}. ${list(k.cityCountDiffers.map((x) => `${x.slug} ${x.stored}->${x.counted}`))}`);
  L.push(`- Venues with no award row: ${k.venuesWithoutAward.length}. ${list(k.venuesWithoutAward)}`);
  L.push(`- Redirects whose from address is also a venue page: ${k.redirectShadowsPage.length}. ${list(k.redirectShadowsPage)}`);
  L.push(`- Redirects whose to address is not a venue page in this version: ${k.redirectToUnknown.length}. ${list(k.redirectToUnknown)}`);
  L.push("");

  L.push("## Exposure (D10)");
  L.push("");
  L.push("Population: the `source_exposure` view (whole tables) and the rows in this version. No cap gate (choice 8). Full table: `report/exposure.csv`.");
  L.push("");
  const exp = parseCsvLite(reportCsvs(r).get("report/exposure.csv")!);
  L.push(table(["Publisher", "Field", "In database", "In this version"], exp.map((x) => [x[0], x[1], Number(x[2]), Number(x[3])])));
  L.push("");

  L.push("## Blurb coverage");
  L.push("");
  const statuses = new Map<string, number>();
  for (const b of snap.blurbs) statuses.set(b.status, (statuses.get(b.status) ?? 0) + 1);
  L.push(
    `Population: all ${fmt(snap.blurbs.length)} blurb rows. ` +
      [...statuses.entries()].sort((a, b) => byCodePoint(a[0], b[0])).map(([s, n]) => `${s} ${fmt(n)}`).join(", ") +
      `. Published: ${fmt(c.blurbs)}. Rule Q4: publish only blurbs whose status is not \`needs_rewrite\`. Rows: \`report/blurbs.csv\`.`,
  );
  L.push("");

  L.push("## Change from the last version");
  L.push("");
  if (!r.diff.against) {
    L.push("First version in the tree. Nothing to compare.");
  } else {
    L.push(
      `Against \`${r.diff.against}\`. Population: venues in either version. ` +
        `Added ${fmt(r.diff.added)}, removed ${fmt(r.diff.removed)}, changed ${fmt(r.diff.changed)}, same ${fmt(r.diff.same)}. Rows: \`report/diff.csv\`.`,
    );
  }
  L.push("");

  L.push("## Compare with the live site file");
  L.push("");
  if (!r.live) {
    L.push(`Not run: \`${r.liveFile}\` was not found.`);
  } else {
    const g = r.live.groups;
    L.push(
      `Population: the ${fmt(r.live.livePages)} live pages (rows with status active in \`${r.liveFile}\`, ${fmt(r.live.liveRows)} rows in all), ` +
        `and the ${fmt(c.venues)} venues in this version. Address = \`/<city_slug>/<slug>\`. Rows: \`report/compare-live.csv\`.`,
    );
    L.push("");
    L.push(
      table(
        ["Group", "Venues"],
        [
          ["Live page and published in the database, same address", g.same_address],
          ["Of those, name differs", r.live.nameDiffers],
          ["Live page, closed in the database", g.closed_in_database],
          ["Live page, address is an old (non-canonical) slug", g.old_slug],
          ["Live page, no slug row", g.no_slug_row],
          ["Live page, open in the database but not published", g.unpublished_open],
          ["Published in the database, no live page", g.no_live_page],
        ],
      ),
    );
    L.push("");
    L.push("Fields the live file has, against these files (population: live pages; venues in this version):");
    L.push("");
    L.push(table(["Field", "Live pages with it", "Venues in files with it", "Note"], r.live.fields.map((f) => [f.field, f.live, f.files, f.note])));
    L.push("");
  }

  if (r.pruned && r.pruned.length) {
    L.push("## Removed from the tree");
    L.push("");
    L.push(`Older version folders removed (they stay in git history): ${r.pruned.map((p) => `\`${p}\``).join(", ")}.`);
    L.push("");
  }

  L.push("## Weak points");
  L.push("");
  L.push("- The live compare reads the repo file, not the deployed pages.");
  L.push("- The files have no map points and no street addresses until Phase 3 fills `geo` and `addresses`.");
  L.push("");
  return L.join("\n");
}

/** Our own CSVs have no embedded newlines in the exposure file; split simply. */
function parseCsvLite(text: string): string[][] {
  return text
    .trim()
    .split("\n")
    .slice(1)
    .map((l) => l.split(",").map((x) => x.replace(/^"|"$/g, "")));
}
