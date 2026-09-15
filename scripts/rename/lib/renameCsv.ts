import { parseCsvRecords, type CsvRecord } from "../../ingest/lib/csv.ts";
import type { SourceRow } from "../../ingest/lib/stageLogic.ts";

/**
 * The rename CSV, and every check on it that needs no database.
 *
 * One row per venue. The columns are fixed - there is no second accepted shape
 * here, unlike the ingest job, because nothing else in the world produces this
 * file. It is written by the preparation step and read by the job, and both
 * ends are in this repo.
 *
 *   batch_key, venue_id, expected_name, new_name, source_id, source_url, note
 *
 * `new_name` is used exactly as written. The job never tidies a name, never
 * trims a suffix, never changes case. The only thing it removes is whitespace
 * at the two ends of a field, which a spreadsheet export adds and nobody
 * means - the same rule the ingest job applies to venue_name.
 */

export const RENAME_COLUMNS = [
  "batch_key",
  "venue_id",
  "expected_name",
  "new_name",
  "source_id",
  "source_url",
  "note",
] as const;

const REQUIRED_COLUMNS = [
  "batch_key",
  "venue_id",
  "expected_name",
  "new_name",
  "source_id",
  "source_url",
] as const;

/**
 * Competitor sites are never a source (Ruling 5). Same three hosts the ingest
 * job refuses, and for the same reason: a name we took from a competitor's
 * page is a name with no provenance.
 */
const BANNED_HOSTS = ["joinpearl.co", "thebestrestaurantsguide.com", "beliapp.com"];

/**
 * The one source_id that is not a publisher. It means the venue's own website
 * settled the spelling, and then source_url is that website. It is deliberately
 * not a row in `award_sources`: the venue is not a guide, it holds no awards,
 * and it is not exposed in the capture ledger.
 */
export const VENUE_SOURCE = "venue";

export type RenameVerdict = "rename" | "no_change" | "reject" | "review";

export type RejectReason =
  | "venue_not_found"
  | "name_moved"
  | "missing_source_url"
  | "competitor_source_url"
  | "malformed_source_url"
  | "source_not_registered"
  | "duplicate_venue_in_file"
  | "empty_new_name"
  | "batch_key_mismatch";

export type ReviewReason = "norm_key_collision";

export interface RenameInput {
  /** 1-based data line in the CSV, for the report */
  line: number;
  batch_key: string;
  venue_id: string;
  expected_name: string;
  new_name: string;
  source_id: string;
  source_url: string;
  note: string;
}

export interface RenameRow {
  input: RenameInput;
  verdict: RenameVerdict;
  reason: RejectReason | ReviewReason | null;
  detail: string | null;
  /** the name the venue has right now, once the database has been read */
  live_name: string | null;
  city_id: string | null;
  city_slug: string | null;
  slug: string | null;
}

export function loadRenameCsv(path: string, text: string): RenameInput[] {
  const { header, records } = parseCsvRecords(text);
  if (header.length === 0) throw new Error(`${path} is empty`);

  const lower = new Map(header.map((h) => [h.trim().toLowerCase(), h]));
  const missing = REQUIRED_COLUMNS.filter((c) => !lower.has(c));
  if (missing.length > 0) {
    throw new Error(
      `${path} has no column for: ${missing.join(", ")}. Headers found: ${header.join(", ")}`,
    );
  }
  const unknown = header.filter((h) => !RENAME_COLUMNS.includes(h.trim().toLowerCase() as never));
  if (unknown.length > 0) {
    throw new Error(
      `${path} carries ${unknown.length} column(s) this job does not know: ` +
        `${unknown.join(", ")}. The rename CSV has exactly these columns: ` +
        `${RENAME_COLUMNS.join(", ")}. Nothing was renamed.`,
    );
  }
  return records.map((rec, i) => toRenameInput(rec, lower, i + 1));
}

function toRenameInput(record: CsvRecord, lower: Map<string, string>, line: number): RenameInput {
  const get = (field: string): string => {
    const header = lower.get(field);
    if (!header) return "";
    return (record[header] ?? "").trim();
  };
  return {
    line,
    batch_key: get("batch_key"),
    venue_id: get("venue_id"),
    // expected_name and new_name are taken as written. Nothing between the two
    // ends of the field is touched - not the case, not a dash, not a suffix.
    expected_name: get("expected_name"),
    new_name: get("new_name"),
    source_id: get("source_id"),
    source_url: get("source_url"),
    note: get("note"),
  };
}

function hostOf(url: string): string | null {
  try {
    return new URL(url).hostname.replace(/^www\./, "").toLowerCase();
  } catch {
    return null;
  }
}

/**
 * The checks that need nothing but the file and the source list, in a fixed
 * order. The first failure sets the verdict and no later check runs, so every
 * row has exactly one reason.
 *
 * Whether the venue exists, whether the live name is the expected one, and
 * whether the new name would collide are decided later, against the database.
 */
export function checkRow(
  input: RenameInput,
  batchKey: string,
  sources: Map<string, SourceRow>,
  duplicateLines: Map<string, number[]>,
): RenameRow {
  const row: RenameRow = {
    input,
    verdict: "rename", // provisional; the database decides
    reason: null,
    detail: null,
    live_name: null,
    city_id: null,
    city_slug: null,
    slug: null,
  };
  const reject = (reason: RejectReason, detail?: string): RenameRow => {
    row.verdict = "reject";
    row.reason = reason;
    row.detail = detail ?? null;
    return row;
  };

  // 1. every row carries this run's batch key
  if (input.batch_key !== batchKey) {
    return reject(
      "batch_key_mismatch",
      `the row says "${input.batch_key || "(blank)"}", the run says "${batchKey}"`,
    );
  }

  // 2. a venue id to rename
  if (input.venue_id === "") return reject("venue_not_found", "(blank venue_id)");

  // 3. a name to rename it to. venues.name carries CHECK (btrim(name) <> ''),
  //    so a blank one would only surface as a constraint violation mid-update.
  if (input.new_name === "") return reject("empty_new_name");

  // 4. one row per venue. Two rows naming the same venue cannot both be right,
  //    and picking one is not this job's call - both go.
  const dupes = duplicateLines.get(input.venue_id);
  if (dupes && dupes.length > 1) {
    return reject(
      "duplicate_venue_in_file",
      `lines ${dupes.join(", ")} all name ${input.venue_id}`,
    );
  }

  // 5. every row carries its source URL (Ruling 5)
  if (input.source_url === "") return reject("missing_source_url");

  const host = hostOf(input.source_url);
  if (host === null) return reject("malformed_source_url", input.source_url);
  if (BANNED_HOSTS.some((b) => host === b || host.endsWith(`.${b}`))) {
    return reject("competitor_source_url", host);
  }

  // 6. the publisher whose spelling this follows must be a registered source,
  //    or the venue's own website.
  if (input.source_id !== VENUE_SOURCE && !sources.has(input.source_id)) {
    return reject("source_not_registered", input.source_id || "(blank)");
  }

  return row;
}

/** venue_id -> every line naming it, for the duplicate check. */
export function linesByVenue(inputs: RenameInput[]): Map<string, number[]> {
  const m = new Map<string, number[]>();
  for (const r of inputs) {
    if (r.venue_id === "") continue;
    const seen = m.get(r.venue_id);
    if (seen) seen.push(r.line);
    else m.set(r.venue_id, [r.line]);
  }
  return m;
}
