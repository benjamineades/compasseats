import type { Db } from "./db.ts";
import { Params, chunk } from "./db.ts";
import type { RowResult, SourceRow } from "./stageLogic.ts";
import { PROMOTING_VERDICTS } from "./stageLogic.ts";
import { disambiguate, mintVenueId, slugify } from "./slug.ts";

/**
 * The promote plan.
 *
 * Built from the staged verdicts by this one function, and used twice: stage
 * calls it to print "before -> expected", promote calls it to do the work. One
 * code path, so the expected counts in the report and the rows that actually
 * land can never drift apart.
 */

export interface PlannedVenue {
  group: string;
  venue_id: string;
  slug: string;
  city_id: string;
  city_slug: string;
  name: string;
  category: "restaurant" | "bar";
  status: "active" | "closed";
  published: boolean;
  publisher: string;
  city_label: string;
  country_label: string;
  lines: number[];
  /**
   * Venue ids that were already on screen as candidates when this row was
   * staged. If the operator saw a venue and still said "new", that is a
   * decision, not a collision - and promote must not second-guess it.
   */
  knownVenueIds: string[];
}

export interface PlannedAward {
  line: number;
  venue_id: string;
  source_id: string;
  year: number | null;
  rank: number | null;
  category: string | null;
  distinction: string | null;
  source_url: string;
  is_new_venue: boolean;
}

export interface PlannedPrice {
  venue_id: string;
  tier: number;
  symbol_raw: string;
  publisher: string;
  source_url: string;
}

export interface PlannedLabel {
  venue_id: string;
  label: string;
  from_column: "city_display" | "country";
  publisher: string;
  note: string;
}

export interface PlannedLedger {
  publisher: string;
  field_type: "award" | "city_label" | "price";
  items: number;
}

export interface SkippedPrice {
  line: number;
  venue_name: string;
  symbol_raw: string;
  reason: string;
}

export interface Plan {
  venues: PlannedVenue[];
  awards: PlannedAward[];
  prices: PlannedPrice[];
  labels: PlannedLabel[];
  ledger: PlannedLedger[];
  skippedPrices: SkippedPrice[];
  /** venue_id -> the lines that will hang awards on it */
  linesByVenue: Map<string, number[]>;
}

export interface PlanInputs {
  batchKey: string;
  results: RowResult[];
  sources: Map<string, SourceRow>;
  /** every slug already live, per city_slug, for property 'eats' */
  takenSlugs: Map<string, Set<string>>;
  /** venues that already carry a price row - never overwritten */
  venuesWithPrice: Set<string>;
}

/** Load the slug and price state the plan needs. Cheap, city-scoped. */
export async function loadPlanState(
  db: Db,
  citySlugs: string[],
  venueIds: string[],
): Promise<{ takenSlugs: Map<string, Set<string>>; venuesWithPrice: Set<string> }> {
  const takenSlugs = new Map<string, Set<string>>();
  for (const part of chunk(citySlugs, 2000)) {
    const q = new Params();
    const { rows } = await db.query<{ city_slug: string; slug: string }>(
      `select city_slug, slug from slugs
        where property_id = 'eats' and city_slug in (${q.list(part, "text")})`,
      q.values,
    );
    for (const r of rows) {
      let set = takenSlugs.get(r.city_slug);
      if (!set) {
        set = new Set();
        takenSlugs.set(r.city_slug, set);
      }
      set.add(r.slug);
    }
  }
  for (const cs of citySlugs) if (!takenSlugs.has(cs)) takenSlugs.set(cs, new Set());

  const venuesWithPrice = new Set<string>();
  for (const part of chunk(venueIds, 5000)) {
    const q = new Params();
    const { rows } = await db.query<{ venue_id: string }>(
      `select venue_id from price where venue_id in (${q.list(part, "text")})`,
      q.values,
    );
    for (const r of rows) venuesWithPrice.add(r.venue_id);
  }
  return { takenSlugs, venuesWithPrice };
}

const SYMBOLIC = /^[^0-9]+$/;

/**
 * The tier is how many times the publisher repeated its symbol: $$$ is 3.
 * Whitespace does not count, and a string that is not one repeated character
 * is not a published price symbol at all - it gets reported, not guessed at.
 */
function priceTier(symbol: string): { tier: number; cleaned: string } | { problem: string } {
  const cleaned = symbol.replace(/\s+/g, "");
  if (cleaned === "") return { problem: "blank once whitespace is removed" };
  const chars = [...cleaned];
  if (new Set(chars).size !== 1) {
    return { problem: `"${symbol}" is not one repeated symbol` };
  }
  if (chars.length > 4) {
    return { problem: `symbol length ${chars.length} is outside the 1-4 tier range` };
  }
  return { tier: chars.length, cleaned };
}

export function buildPlan(input: PlanInputs): Plan {
  const { batchKey, results, sources, takenSlugs, venuesWithPrice } = input;

  const promoting = results.filter((r) => PROMOTING_VERDICTS.includes(r.verdict));

  /* ---- new venues, one per group (several award rows can share a venue) --- */
  const venues: PlannedVenue[] = [];
  const venueIdByGroup = new Map<string, string>();
  // a working copy, so slugs claimed by this batch cannot be handed out twice
  const claimed = new Map<string, Set<string>>();
  for (const [k, v] of takenSlugs) claimed.set(k, new Set(v));

  for (const r of promoting) {
    if (r.verdict !== "new_venue" || !r.new_venue_group) continue;
    if (venueIdByGroup.has(r.new_venue_group)) {
      const existing = venues.find((v) => v.group === r.new_venue_group);
      if (existing) {
        existing.lines.push(r.line);
        for (const c of r.candidates.venues) {
          if (!existing.knownVenueIds.includes(c.venue_id)) existing.knownVenueIds.push(c.venue_id);
        }
      }
      continue;
    }
    const citySlug = r.city_slug as string;
    const taken = claimed.get(citySlug) ?? new Set<string>();
    claimed.set(citySlug, taken);

    // Plan section 04: the incumbent keeps its slug; the newcomer takes -2, -3, ...
    const slug = disambiguate(slugify(r.input.venue_name, citySlug), taken);
    taken.add(slug);

    const venueId = mintVenueId(citySlug, slug);
    venueIdByGroup.set(r.new_venue_group, venueId);

    venues.push({
      group: r.new_venue_group,
      venue_id: venueId,
      slug,
      city_id: r.city_id as string,
      city_slug: citySlug,
      name: r.input.venue_name,
      category: r.venue_category as "restaurant" | "bar",
      status: r.venue_status as "active" | "closed",
      // Ruling 4: closed venues land unpublished. An iconic exception is a
      // per-venue call Ben makes by hand afterwards, never a job decision.
      published: r.venue_status === "active",
      publisher: r.input.source_id,
      city_label: r.input.city_label,
      country_label: r.input.country_label,
      lines: [r.line],
      knownVenueIds: r.candidates.venues.map((c) => c.venue_id),
    });
  }

  /* ---- awards ---------------------------------------------------------- */
  const awards: PlannedAward[] = [];
  const linesByVenue = new Map<string, number[]>();

  for (const r of promoting) {
    const venueId =
      r.verdict === "new_venue"
        ? (venueIdByGroup.get(r.new_venue_group as string) as string)
        : (r.venue_id as string);

    awards.push({
      line: r.line,
      venue_id: venueId,
      source_id: r.input.source_id,
      year: r.input.year.trim() === "" ? null : Number(r.input.year),
      rank: r.input.rank.trim() === "" ? null : Number(r.input.rank),
      category: r.input.category.trim() === "" ? null : r.input.category,
      distinction: r.input.distinction.trim() === "" ? null : r.input.distinction,
      source_url: r.input.source_url,
      is_new_venue: r.verdict === "new_venue",
    });
    linesByVenue.set(venueId, [...(linesByVenue.get(venueId) ?? []), r.line]);
  }

  /* ---- city_label_source, for new venues only --------------------------- */
  const labels: PlannedLabel[] = [];
  for (const v of venues) {
    if (v.city_label.trim() !== "") {
      labels.push({
        venue_id: v.venue_id,
        label: v.city_label,
        from_column: "city_display",
        publisher: v.publisher,
        note: batchKey,
      });
    }
    if (v.country_label.trim() !== "") {
      labels.push({
        venue_id: v.venue_id,
        label: v.country_label,
        from_column: "country",
        publisher: v.publisher,
        note: batchKey,
      });
    }
  }

  /* ---- price ------------------------------------------------------------ */
  const prices: PlannedPrice[] = [];
  const skippedPrices: SkippedPrice[] = [];
  const pricedThisBatch = new Set<string>();

  for (const r of promoting) {
    const symbol = r.input.price_symbol_raw.trim();
    if (symbol === "") continue;

    const venueId =
      r.verdict === "new_venue"
        ? (venueIdByGroup.get(r.new_venue_group as string) as string)
        : (r.venue_id as string);

    const skip = (reason: string) =>
      skippedPrices.push({
        line: r.line,
        venue_name: r.input.venue_name,
        symbol_raw: symbol,
        reason,
      });

    const src = sources.get(r.input.source_id);
    if (!src?.price_capable) {
      skip(`source ${r.input.source_id} is not price_capable`);
      continue;
    }
    if (venuesWithPrice.has(venueId)) {
      skip("venue already has a price row - never overwritten");
      continue;
    }
    if (pricedThisBatch.has(venueId)) {
      skip("a later row in this batch already priced this venue");
      continue;
    }
    if (!SYMBOLIC.test(symbol)) {
      // the price table's own check constraint forbids a bare integer; this
      // catches it in the report instead of inside the transaction
      skip("not a symbol - price_symbol_raw may not be a number");
      continue;
    }
    const scored = priceTier(symbol);
    if ("problem" in scored) {
      skip(scored.problem);
      continue;
    }
    pricedThisBatch.add(venueId);
    prices.push({
      venue_id: venueId,
      tier: scored.tier,
      symbol_raw: scored.cleaned,
      publisher: r.input.source_id,
      // the price's own URL when the CSV carries one, else the award's
      source_url: r.input.price_source_url.trim() || r.input.source_url,
    });
  }

  /* ---- ledger: one row per (publisher, field_type) touched --------------- */
  const tally = new Map<string, number>();
  const bump = (publisher: string, field: string, n = 1) => {
    const k = `${publisher}::${field}`;
    tally.set(k, (tally.get(k) ?? 0) + n);
  };
  for (const a of awards) bump(a.source_id, "award");
  for (const l of labels) bump(l.publisher, "city_label");
  for (const p of prices) bump(p.publisher, "price");

  const ledger: PlannedLedger[] = [...tally.entries()]
    .map(([k, items]) => {
      const [publisher, field_type] = k.split("::");
      return { publisher, field_type: field_type as PlannedLedger["field_type"], items };
    })
    .sort(
      (a, b) => a.publisher.localeCompare(b.publisher) || a.field_type.localeCompare(b.field_type),
    );

  return { venues, awards, prices, labels, ledger, skippedPrices, linesByVenue };
}
