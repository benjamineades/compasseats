import { createHash } from "node:crypto";

/**
 * Slug and venue-id minting.
 *
 * The rule below reproduces 10,656 of the 10,899 existing canonical eats slugs
 * exactly (97.8%, measured 2026-09-10). It is NOT an attempt to reproduce the
 * Phase 1 migration's quirks — that run sent digit-leading and empty slugs to
 * an opaque "<city>-<6 chars>" fallback, and handled ß, đ and ı differently
 * from Postgres f_unaccent. New venues only need a slug that is stable,
 * readable, and unique within (property, city); they do not need to match a
 * one-off migration's edge cases.
 *
 * The one legacy behaviour kept: when a name slugifies to nothing at all
 * (CJK-only names, 101 of them today), fall back to "<city_slug>-<6 hex>".
 * The 6 hex characters are derived from the city and name, so the same input
 * always mints the same slug — no randomness anywhere in this job.
 */
export function slugify(name: string, citySlug: string): string {
  const base = name
    .normalize("NFD")
    // strip combining marks
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

  if (base !== "") return base;
  return `${citySlug}-${createHash("md5").update(`${citySlug}:${name}`).digest("hex").slice(0, 6)}`;
}

/**
 * Venue id, exactly the mint rule Batch D used (Plan §04 / handoff 2026-09-10):
 *   've_' || left(md5(city_slug || ':' || slug), 10)
 * Computed from the FINAL slug, after any -2 / -3 disambiguation.
 */
export function mintVenueId(citySlug: string, slug: string): string {
  return `ve_${createHash("md5").update(`${citySlug}:${slug}`).digest("hex").slice(0, 10)}`;
}

/**
 * Pick a free slug for a new venue in a city.
 * Plan §04: the incumbent keeps its slug; the newcomer takes -2, then -3, …
 * `taken` must hold every slug already live in that city AND every slug this
 * same batch has already claimed.
 */
export function disambiguate(base: string, taken: Set<string>): string {
  if (!taken.has(base)) return base;
  for (let n = 2; n < 1000; n += 1) {
    const candidate = `${base}-${n}`;
    if (!taken.has(candidate)) return candidate;
  }
  throw new Error(`Could not find a free slug for "${base}" after 999 attempts`);
}
