/**
 * The loose venue key.
 *
 * WHY THIS EXISTS
 *
 * The snapshot already in `venues` carries Google-style names - "Restaurant
 * Kei", "Restaurant Le Gabriel", "Restaurant Paul Bocuse". Michelin's own
 * cards carry the card name, and after a spaced dash the hotel or the chef:
 * "Kei", "Le Gabriel - La Réserve Paris", "Plénitude - Cheval Blanc Paris".
 *
 * `venues.norm_key` is the database's own signature and it is exact, so not
 * one of those pairs matches on it. Staging the 1,071-row France 2026 list
 * called 458 rows `new_venue`; measured against the live database, 152 of them
 * already exist in the resolved city under exactly that shape. A 2026 guide is
 * never mostly new venues, and every later guide - Italy, Japan, Spain - has
 * the same two name conventions meeting the same way.
 *
 * WHAT THIS IS FOR, AND WHAT IT IS NOT FOR
 *
 * This key is not a matching rule and it never produces a `match`. It is
 * allowed to do exactly one thing: turn a `new_venue` verdict into
 * `review_venue`, with the venue that is already there named, so a duplicate
 * is never created silently. Under-merge beats over-merge - the exact
 * `norm_key` in the resolved city remains the only automatic match there is,
 * and the operator still decides every one of these by hand.
 *
 * THE RULES
 *
 *   1. Cut the incoming name at the first " - ". Michelin's suffix is the
 *      hotel or the chef, not the restaurant. Only the incoming side is cut: a
 *      stored name is compared whole, because cutting both sides is a wider
 *      rule than the 2025 snapshot gives any evidence for.
 *   2. Lowercase and unaccent - the database's own f_unaccent, never a
 *      re-implementation in TypeScript, the same rule `norm_key` follows.
 *   3. Drop leading "restaurant", "le", "la", "les", "l", "hotel" / "hôtel"
 *      (which unaccents to "hotel"), repeatedly, so "Restaurant Le Gabriel"
 *      and "Le Gabriel" reduce to the same thing.
 *   4. Remove everything that is not a letter or a digit.
 *   5. Under three characters is no key at all, and neither is a name that is
 *      nothing but stop words. Both come back NULL and match nothing - the
 *      same floor `norm_key` itself applies, so an all-CJK name cannot group
 *      loosely either.
 *
 * The stripping only ever applies at the FRONT of a name. "Hôtel de Ville"
 * reduces to "deville", which is the price of the rule; "Chez Le Gabriel"
 * keeps every word it has.
 *
 * These are SQL expression builders, not TypeScript functions, for the same
 * reason `normLabel` in db.ts is: each side is then normalised once, by
 * Postgres, and the comparison of the resulting strings happens in memory.
 */

/** The leading words a name is compared without. */
export const STRIP_LEADING = ["restaurant", "le", "la", "les", "l", "hotel"];

/**
 * The loose key of a stored venue name: rules 2-5, no " - " cut.
 * `expr` is SQL, e.g. `"v.name"`.
 */
export function looseKeyStored(expr: string): string {
  const gaps = `btrim(regexp_replace(lower(f_unaccent(${expr})), '[^a-z0-9]+', ' ', 'g'))`;
  const stripped = `regexp_replace(${gaps}, '^((${STRIP_LEADING.join("|")})\\s+)+', '')`;
  const key = `regexp_replace(${stripped}, '[^a-z0-9]+', '', 'g')`;
  return `(case when length(${key}) < 3 then null else ${key} end)`;
}

/**
 * The loose key of an incoming CSV name: rule 1 first, then the rest.
 * `expr` is SQL, e.g. `"venue_name"`.
 */
export function looseKeyIncoming(expr: string): string {
  return looseKeyStored(`split_part(${expr}, ' - ', 1)`);
}
