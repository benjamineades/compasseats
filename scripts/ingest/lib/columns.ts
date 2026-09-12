import type { CsvRecord } from "./csv.ts";

/**
 * The input contract, and the mapping from the Award Radar shape already in
 * this repo.
 *
 * Canonical columns (the brief):
 *   batch_key, source_id, year, rank, category, distinction, source_url,
 *   venue_name, city_label, country_label, venue_category, venue_status,
 *   price_symbol_raw, note
 *
 * Award Radar already emits a different shape — the Apps Script import
 * templates in apps-script/ ("Compasseats Bar Ingest.gs",
 * "compasseats-restaurant-ingest.gs"):
 *   source_slug, year, rank, name, city, country, category_override,
 *   [cuisine, price_band,] price_symbol_raw, price_source_url,
 *   address_raw, coords_raw, geo_source_url
 *
 * Both are accepted. The report always prints what was mapped and what was
 * ignored, so a mapping is never silent.
 */

export const CANONICAL_COLUMNS = [
  "batch_key",
  "source_id",
  "year",
  "rank",
  "category",
  "distinction",
  "source_url",
  "venue_name",
  "city_label",
  "country_label",
  "venue_category",
  "venue_status",
  "price_symbol_raw",
  "note",
] as const;

/** canonical field -> other header names that mean the same thing */
const ALIASES: Record<string, string[]> = {
  source_id: ["source_slug", "source"],
  venue_name: ["name", "venue"],
  city_label: ["city"],
  country_label: ["country"],
  category: ["category_override"],
  price_symbol_raw: ["price_symbol_raw"],
  // price_source_url is not a canonical field but the job uses it: it becomes
  // the source_url on the price row, which is not always the award's URL.
  price_source_url: ["price_source_url"],
  source_url: ["award_source_url", "list_url"],
  venue_status: ["status", "status_open_or_closed"],
  venue_category: ["category_type", "venue_type"],
};

/**
 * Columns the Award Radar shape carries that this job deliberately does not
 * write. Geo and addresses are Phase 3 work; cuisine and price_band have no
 * home in this job's scope. Present-but-ignored is reported, never silent.
 */
export const IGNORED_COLUMNS = [
  "address_raw",
  "coords_raw",
  "geo_source_url",
  "cuisine",
  "price_band",
];

export interface InputRow {
  line: number; // 1-based data line in the CSV, for the report
  batch_key: string;
  source_id: string;
  year: string;
  rank: string;
  category: string;
  distinction: string;
  source_url: string;
  venue_name: string;
  city_label: string;
  country_label: string;
  venue_category: string;
  venue_status: string;
  price_symbol_raw: string;
  price_source_url: string;
  note: string;
}

export interface ColumnMapping {
  /** canonical field -> the header it was read from */
  mapped: Record<string, string>;
  /** headers present in the file that this job does not use */
  ignored: string[];
  /** canonical fields with no column in the file */
  absent: string[];
}

const ALL_FIELDS = [...CANONICAL_COLUMNS, "price_source_url"];

export function buildMapping(header: string[]): ColumnMapping {
  const lower = new Map(header.map((h) => [h.trim().toLowerCase(), h]));
  const mapped: Record<string, string> = {};
  const absent: string[] = [];

  for (const field of ALL_FIELDS) {
    const direct = lower.get(field);
    if (direct) {
      mapped[field] = direct;
      continue;
    }
    const alias = (ALIASES[field] ?? []).map((a) => lower.get(a)).find(Boolean);
    if (alias) {
      mapped[field] = alias;
      continue;
    }
    absent.push(field);
  }

  const used = new Set(Object.values(mapped).map((h) => h.toLowerCase()));
  const ignored = header.filter((h) => !used.has(h.trim().toLowerCase()));

  return { mapped, ignored, absent };
}

/** Pull one canonical row out of a raw record using the mapping. */
export function toInputRow(
  record: CsvRecord,
  mapping: ColumnMapping,
  line: number,
  fallbackBatchKey: string,
): InputRow {
  const get = (field: string): string => {
    const header = mapping.mapped[field];
    if (!header) return "";
    return (record[header] ?? "").trim();
  };

  return {
    line,
    batch_key: get("batch_key") || fallbackBatchKey,
    source_id: get("source_id"),
    year: get("year"),
    rank: get("rank"),
    category: get("category"),
    distinction: get("distinction"),
    source_url: get("source_url"),
    // venue_name is the one field that is NEVER normalised or "corrected".
    // It is the venue's name by rule (Ruling 5). Only surrounding whitespace
    // from the spreadsheet export is removed.
    venue_name: get("venue_name"),
    city_label: get("city_label"),
    country_label: get("country_label"),
    venue_category: get("venue_category").toLowerCase(),
    venue_status: get("venue_status").toLowerCase(),
    price_symbol_raw: get("price_symbol_raw"),
    price_source_url: get("price_source_url"),
    note: get("note"),
  };
}

/**
 * When venue_category is blank, derive it from the source. Bars lists make
 * bars; everything else makes restaurants. Always reported, never silent.
 */
export function deriveVenueCategory(sourceId: string): "restaurant" | "bar" {
  const s = sourceId.toLowerCase();
  if (s.includes("bars") || s.includes("bar-") || s === "spirited-awards") return "bar";
  return "restaurant";
}
