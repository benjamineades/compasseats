import { byCodePoint, byKeys } from "./canonical.ts";
import type { AwardRow, CityRow, PriceRow, Snapshot, SourceRow } from "./read.ts";

/**
 * From one database snapshot to the files of one version.
 *
 * Pure: no database, no clock, no file system. The same snapshot always gives
 * the same values, and lib/canonical.ts turns those into the same bytes. Every
 * array is sorted here, and each sort says its key.
 *
 * What goes in, by Ben's choices of Nov 6 (1-8: A):
 *   - venues with a published `eats` listing (closed venues are unpublished, Q3)
 *   - every award row of those venues, all years, from active sources only
 *   - price: tier, symbol, currency, publisher
 *   - blurbs whose status is not `needs_rewrite` (Q4)
 *   - city and region counts made here, not read from cities.venues_count (Q5)
 *
 * What never goes in: a Google value (D4/D6), anything from a suspended source
 * (D10), and geo / address / hours / photo rows, whose published shape is a
 * Phase 3 decision. Those four are read and counted in the report only.
 */

export const BLURB_WITHHELD_STATUS = "needs_rewrite";

export interface PublishedAward {
  id: number;
  source: string;
  year: number | null;
  rank: number | null;
  category: string | null;
  distinction: string | null;
  source_url: string | null;
}

export interface PublishedVenue {
  id: string;
  name: string;
  name_native: string | null;
  category: string;
  status: string;
  slug: string | null;
  path: string | null;
  city: {
    slug: string;
    display: string;
    country: string | null;
    country_iso: string | null;
    region: string | null;
  } | null;
  cuisine: string[];
  awards: PublishedAward[];
  price: { tier: number; symbol: string | null; currency: string | null; publisher: string | null } | null;
  blurb: { short: string | null; long: string | null; version: number } | null;
}

export interface IndexRow {
  id: string;
  name: string;
  name_native: string | null;
  category: string;
  city: string | null;
  slug: string | null;
  path: string | null;
  award_count: number;
  sources: string[];
  latest_year: number | null;
  price_tier: number | null;
  has_blurb: boolean;
}

export interface FileEntry {
  value: unknown;
  rows: number;
}

export interface Shaped {
  /** published path inside the version folder -> value */
  files: Map<string, FileEntry>;
  venues: PublishedVenue[];
  index: IndexRow[];
  /** canonical slug rows per published venue id */
  canonicalCount: Map<string, number>;
  /** venue ids whose city_id is not in cities */
  missingCity: string[];
  counts: {
    venues: number;
    restaurants: number;
    bars: number;
    cityFiles: number;
    cities: number;
    regions: number;
    awards: number;
    prices: number;
    blurbs: number;
    redirects: number;
    redirectsFromTable: number;
    redirectsFromOldSlugs: number;
  };
  excluded: {
    awardsSuspendedSource: number;
    pricesSuspendedSource: number;
    cuisineSuspendedSource: number;
    blurbsNeedsRewrite: number;
    blurbsOnUnpublishedVenue: number;
    oldSlugsOfUnpublishedVenues: number;
    /** old slugs the redirects table already sends to the same page: written once */
    oldSlugsSameAsRedirect: number;
  };
  checks: {
    /** venues whose canonical slug city differs from their city's slug */
    pathCityDiffers: { id: string; name: string; path: string; city: string }[];
    /** cities whose own count differs from cities.venues_count */
    cityCountDiffers: { slug: string; stored: number; counted: number }[];
    /** published venues that hold no award row in the files */
    venuesWithoutAward: string[];
    awardsWithoutUrl: number;
    /** redirect `from` values that appear more than once (table and old slugs together) */
    duplicateRedirectFrom: string[];
    /** redirect `from` values that are also a published venue's canonical path */
    redirectShadowsPage: string[];
    /** redirect `to` values that are not a published venue's canonical path */
    redirectToUnknown: string[];
    citiesWithoutRegion: number;
  };
  /** cities with at least one published venue, in file order */
  publishedCities: CityRow[];
}

function activeSources(sources: SourceRow[]): Set<string> {
  return new Set(sources.filter((s) => s.status === "active").map((s) => s.slug));
}

/** Award order inside a venue: source, newest year first, rank, category, distinction, id. */
function awardOrder(a: PublishedAward, b: PublishedAward): number {
  return byKeys(
    [a.source, -(a.year ?? -100000), a.rank ?? 1e9, a.category, a.distinction, a.id],
    [b.source, -(b.year ?? -100000), b.rank ?? 1e9, b.category, b.distinction, b.id],
  );
}

export function cityFilePath(citySlug: string): string {
  return `venues/${citySlug}.json`;
}

export function shape(snap: Snapshot): Shaped {
  const active = activeSources(snap.sources);
  const cityById = new Map(snap.cities.map((c) => [c.id, c]));
  const regionById = new Map(snap.regions.map((r) => [r.id, r]));
  const publishedIds = new Set(snap.venues.map((v) => v.id));

  // canonical eats slugs, per venue
  const canonical = new Map<string, { city_slug: string; slug: string }[]>();
  for (const s of snap.slugs) {
    if (!s.is_canonical) continue;
    const list = canonical.get(s.venue_id) ?? [];
    list.push({ city_slug: s.city_slug, slug: s.slug });
    canonical.set(s.venue_id, list);
  }

  // awards per venue, active sources only
  const awardsByVenue = new Map<string, PublishedAward[]>();
  let awardsSuspendedSource = 0;
  for (const a of snap.awards as AwardRow[]) {
    if (!publishedIds.has(a.venue_id)) continue;
    if (!active.has(a.source_id)) {
      awardsSuspendedSource += 1;
      continue;
    }
    const list = awardsByVenue.get(a.venue_id) ?? [];
    list.push({
      id: a.id,
      source: a.source_id,
      year: a.year,
      rank: a.rank,
      category: a.category,
      distinction: a.distinction,
      source_url: a.source_url,
    });
    awardsByVenue.set(a.venue_id, list);
  }

  // price, from an active source (or none named)
  const priceByVenue = new Map<string, PriceRow>();
  let pricesSuspendedSource = 0;
  for (const p of snap.prices) {
    if (!publishedIds.has(p.venue_id)) continue;
    if (p.publisher !== null && !active.has(p.publisher)) {
      pricesSuspendedSource += 1;
      continue;
    }
    priceByVenue.set(p.venue_id, p);
  }

  // blurbs, rule Q4
  const blurbByVenue = new Map<string, { short: string | null; long: string | null; version: number }>();
  let blurbsNeedsRewrite = 0;
  let blurbsOnUnpublishedVenue = 0;
  for (const b of snap.blurbs) {
    if (!publishedIds.has(b.venue_id)) {
      blurbsOnUnpublishedVenue += 1;
      continue;
    }
    if (b.status === BLURB_WITHHELD_STATUS) {
      blurbsNeedsRewrite += 1;
      continue;
    }
    blurbByVenue.set(b.venue_id, { short: b.short, long: b.long, version: b.version });
  }

  let cuisineSuspendedSource = 0;
  const missingCity: string[] = [];
  const canonicalCount = new Map<string, number>();
  const venues: PublishedVenue[] = [];

  for (const v of snap.venues) {
    const canon = (canonical.get(v.id) ?? []).slice().sort((a, b) =>
      byKeys([a.city_slug, a.slug], [b.city_slug, b.slug]),
    );
    canonicalCount.set(v.id, canon.length);
    const c = cityById.get(v.city_id) ?? null;
    if (!c) missingCity.push(v.id);
    const region = c?.region_id ? regionById.get(c.region_id) ?? null : null;

    let cuisine = (v.cuisine_tags ?? []).slice().sort(byCodePoint);
    if (v.cuisine_publisher !== null && !active.has(v.cuisine_publisher)) {
      if (cuisine.length > 0) cuisineSuspendedSource += 1;
      cuisine = [];
    }

    const price = priceByVenue.get(v.id) ?? null;
    const first = canon[0] ?? null;
    venues.push({
      id: v.id,
      name: v.name,
      name_native: v.name_native,
      category: v.category,
      status: v.status,
      slug: first ? first.slug : null,
      path: first ? `/${first.city_slug}/${first.slug}` : null,
      city: c
        ? {
            slug: c.slug,
            display: c.display,
            country: c.country,
            country_iso: c.country_iso ? c.country_iso.trim() : null,
            region: region ? region.slug : null,
          }
        : null,
      cuisine,
      awards: (awardsByVenue.get(v.id) ?? []).sort(awardOrder),
      price: price
        ? { tier: price.tier, symbol: price.symbol_raw, currency: price.currency, publisher: price.publisher }
        : null,
      blurb: blurbByVenue.get(v.id) ?? null,
    });
  }

  // venue order everywhere: city slug, venue slug, id
  venues.sort((a, b) =>
    byKeys([a.city?.slug ?? null, a.slug, a.id], [b.city?.slug ?? null, b.slug, b.id]),
  );

  const files = new Map<string, FileEntry>();

  // index.json - one light row per published venue
  const index: IndexRow[] = venues.map((v) => {
    const years = v.awards.map((a) => a.year).filter((y): y is number => y !== null);
    return {
      id: v.id,
      name: v.name,
      name_native: v.name_native,
      category: v.category,
      city: v.city?.slug ?? null,
      slug: v.slug,
      path: v.path,
      award_count: v.awards.length,
      sources: [...new Set(v.awards.map((a) => a.source))].sort(byCodePoint),
      latest_year: years.length ? Math.max(...years) : null,
      price_tier: v.price?.tier ?? null,
      has_blurb: v.blurb !== null,
    };
  });
  files.set("index.json", { value: index, rows: index.length });

  // venues/<city>.json - one file per city with a published venue
  const byCity = new Map<string, PublishedVenue[]>();
  for (const v of venues) {
    if (!v.city) continue;
    const list = byCity.get(v.city.slug) ?? [];
    list.push(v);
    byCity.set(v.city.slug, list);
  }
  const citySlugs = [...byCity.keys()].sort(byCodePoint);
  const cityBySlug = new Map(snap.cities.map((c) => [c.slug, c]));
  const publishedCities: CityRow[] = [];
  const cityRows: unknown[] = [];
  const cityCountDiffers: Shaped["checks"]["cityCountDiffers"] = [];

  for (const slug of citySlugs) {
    const list = byCity.get(slug)!;
    const c = cityBySlug.get(slug)!;
    publishedCities.push(c);
    const region = c.region_id ? regionById.get(c.region_id) ?? null : null;
    const summary = {
      slug: c.slug,
      display: c.display,
      country: c.country,
      country_iso: c.country_iso ? c.country_iso.trim() : null,
      kind: c.kind,
      region: region ? region.slug : null,
      lat: c.lat,
      lng: c.lng,
      venue_count: list.length,
      restaurant_count: list.filter((v) => v.category === "restaurant").length,
      bar_count: list.filter((v) => v.category === "bar").length,
      file: cityFilePath(c.slug),
    };
    cityRows.push(summary);
    files.set(cityFilePath(slug), {
      value: { city: summary, venues: list },
      rows: list.length,
    });
  }

  // Q5: compare the job's own count with the stored copy, for every city
  const countedById = new Map<string, number>();
  for (const v of snap.venues) countedById.set(v.city_id, (countedById.get(v.city_id) ?? 0) + 1);
  for (const c of [...snap.cities].sort((a, b) => byCodePoint(a.slug, b.slug))) {
    const counted = countedById.get(c.id) ?? 0;
    if (counted !== c.venues_count) {
      cityCountDiffers.push({ slug: c.slug, stored: c.venues_count, counted });
    }
  }
  files.set("cities.json", { value: cityRows, rows: cityRows.length });

  // regions.json - regions that hold at least one published city
  const regionCities = new Map<string, CityRow[]>();
  for (const c of publishedCities) {
    if (!c.region_id) continue;
    const list = regionCities.get(c.region_id) ?? [];
    list.push(c);
    regionCities.set(c.region_id, list);
  }
  const regionRows = [...regionCities.entries()]
    .map(([id, list]) => {
      const r = regionById.get(id)!;
      return {
        slug: r.slug,
        display: r.display,
        city_count: list.length,
        venue_count: list.reduce((n, c) => n + (byCity.get(c.slug)?.length ?? 0), 0),
        cities: list.map((c) => c.slug).sort(byCodePoint),
      };
    })
    .sort((a, b) => byCodePoint(a.slug, b.slug));
  files.set("regions.json", { value: regionRows, rows: regionRows.length });

  // redirects.json - the redirects table plus old slugs of published venues
  const canonicalPath = new Map<string, string>();
  for (const v of venues) if (v.path) canonicalPath.set(v.id, v.path);
  const pagePaths = new Set(canonicalPath.values());

  const redirectRows: { from: string; to: string; kind: string }[] = [];
  const tableTo = new Map<string, string>();
  for (const r of snap.redirects) {
    redirectRows.push({ from: r.from_path, to: r.to_path, kind: "redirect" });
    tableTo.set(r.from_path, r.to_path);
  }
  let oldSlugsOfUnpublishedVenues = 0;
  let redirectsFromOldSlugs = 0;
  let oldSlugsSameAsRedirect = 0;
  for (const s of snap.slugs) {
    if (s.is_canonical) continue;
    const to = canonicalPath.get(s.venue_id);
    if (!publishedIds.has(s.venue_id) || !to) {
      oldSlugsOfUnpublishedVenues += 1;
      continue;
    }
    const from = `/${s.city_slug}/${s.slug}`;
    // An old slug that the redirects table already sends to the same place is
    // one answer written twice: keep the table row. A different answer stays
    // in, and the redirect_from_unique gate stops the build.
    if (tableTo.get(from) === to) {
      oldSlugsSameAsRedirect += 1;
      continue;
    }
    redirectRows.push({ from, to, kind: "old_slug" });
    redirectsFromOldSlugs += 1;
  }
  redirectRows.sort((a, b) => byKeys([a.from, a.kind, a.to], [b.from, b.kind, b.to]));
  files.set("redirects.json", { value: redirectRows, rows: redirectRows.length });

  const fromCount = new Map<string, number>();
  for (const r of redirectRows) fromCount.set(r.from, (fromCount.get(r.from) ?? 0) + 1);
  const duplicateRedirectFrom = [...fromCount.entries()]
    .filter(([, n]) => n > 1)
    .map(([f]) => f)
    .sort(byCodePoint);
  const redirectShadowsPage = redirectRows
    .filter((r) => pagePaths.has(r.from))
    .map((r) => r.from)
    .sort(byCodePoint);
  const redirectToUnknown = redirectRows
    .filter((r) => !pagePaths.has(r.to))
    .map((r) => `${r.from} -> ${r.to}`)
    .sort(byCodePoint);

  // attribution.json - each source present in the files
  const sourceBySlug = new Map(snap.sources.map((s) => [s.slug, s]));
  const perSource = new Map<string, { awards: number; venues: Set<string>; prices: number }>();
  const tally = (slug: string) => {
    let t = perSource.get(slug);
    if (!t) {
      t = { awards: 0, venues: new Set(), prices: 0 };
      perSource.set(slug, t);
    }
    return t;
  };
  for (const v of venues) {
    for (const a of v.awards) {
      const t = tally(a.source);
      t.awards += 1;
      t.venues.add(v.id);
    }
    if (v.price?.publisher) tally(v.price.publisher).prices += 1;
  }
  const attribution = [...perSource.entries()]
    .map(([slug, t]) => {
      const s = sourceBySlug.get(slug);
      return {
        source: slug,
        display: s?.display ?? null,
        attribution_required: s?.attribution_required ?? null,
        render_extended_above: s?.render_extended_above ?? null,
        awards: t.awards,
        venues: t.venues.size,
        prices: t.prices,
      };
    })
    .sort((a, b) => byCodePoint(a.source, b.source));
  files.set("attribution.json", { value: attribution, rows: attribution.length });

  // checks for the report (not gates)
  const pathCityDiffers = venues
    .filter((v) => v.path && v.city && !v.path.startsWith(`/${v.city.slug}/`))
    .map((v) => ({ id: v.id, name: v.name, path: v.path!, city: v.city!.slug }));
  const venuesWithoutAward = venues.filter((v) => v.awards.length === 0).map((v) => v.id);
  const awardsWithoutUrl = venues.reduce(
    (n, v) => n + v.awards.filter((a) => !a.source_url).length,
    0,
  );

  return {
    files,
    venues,
    index,
    canonicalCount,
    missingCity: missingCity.sort(byCodePoint),
    counts: {
      venues: venues.length,
      restaurants: venues.filter((v) => v.category === "restaurant").length,
      bars: venues.filter((v) => v.category === "bar").length,
      cityFiles: citySlugs.length,
      cities: cityRows.length,
      regions: regionRows.length,
      awards: venues.reduce((n, v) => n + v.awards.length, 0),
      prices: venues.filter((v) => v.price).length,
      blurbs: venues.filter((v) => v.blurb).length,
      redirects: redirectRows.length,
      redirectsFromTable: snap.redirects.length,
      redirectsFromOldSlugs,
    },
    excluded: {
      awardsSuspendedSource,
      pricesSuspendedSource,
      cuisineSuspendedSource,
      blurbsNeedsRewrite,
      blurbsOnUnpublishedVenue,
      oldSlugsOfUnpublishedVenues,
      oldSlugsSameAsRedirect,
    },
    checks: {
      pathCityDiffers,
      cityCountDiffers,
      venuesWithoutAward,
      awardsWithoutUrl,
      duplicateRedirectFrom,
      redirectShadowsPage,
      redirectToUnknown,
      citiesWithoutRegion: publishedCities.filter((c) => !c.region_id).length,
    },
    publishedCities,
  };
}
