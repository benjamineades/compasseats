import type { Snapshot } from "./read.ts";
import type { Shaped } from "./shape.ts";

/**
 * The build gates. If a single one fails, no version folder is written.
 *
 * The first eight are the approved design (Nov 6, 1-8: A). The ninth,
 * `redirect_from_unique`, is added because a redirects file with two different
 * answers for one old address is not a file a site can serve. On the Nov 7
 * live copy it reads 0 (2 old slugs repeat a redirects-table row with the same
 * answer; lib/shape.ts writes those once).
 */

export interface Gate {
  name: string;
  pass: boolean;
  detail: string;
}

/** A Google place id: ChIJ plus its base64 tail. */
export const GOOGLE_ID = /ChIJ[0-9A-Za-z_-]{8,}/;
/** Google photo and map hosts (the same list the photo_refs CHECK uses, plus map links). */
export const GOOGLE_URL =
  /(googleusercontent|googleapis|gstatic|ggpht|maps\.google|google\.[a-z.]+\/maps|goo\.gl\/maps|maps\.app\.goo\.gl)/i;

export const MAX_DECREASE = 0.005;

export function decreaseOverrideText(newCount: number): string {
  return `ALLOW DECREASE ${newCount}`;
}

function sample(items: readonly string[], n = 10): string {
  if (items.length === 0) return "";
  const head = items.slice(0, n).join(", ");
  return items.length > n ? `${head}, and ${items.length - n} more` : head;
}

export interface GateInputs {
  snap: Snapshot;
  shaped: Shaped;
  /** published path -> exact file text */
  texts: Map<string, string>;
  /** venue count of the newest version already in the tree, or null for the first build */
  lastVenueCount: number | null;
  lastVersion: string | null;
  allowDecrease: string;
}

export function runGates(input: GateInputs): Gate[] {
  const { snap, shaped, texts, lastVenueCount, lastVersion, allowDecrease } = input;
  const gates: Gate[] = [];
  const n = shaped.counts.venues;

  // 1. venue count in the files = active published count in the database
  const cityFileRows = [...shaped.files.entries()]
    .filter(([p]) => p.startsWith("venues/"))
    .reduce((sum, [, f]) => sum + f.rows, 0);
  const indexRows = shaped.files.get("index.json")?.rows ?? -1;
  gates.push({
    name: "venue_count_matches_database",
    pass: n === snap.dbPublishedActive && indexRows === n && cityFileRows === n,
    detail:
      `files ${n} (index.json ${indexRows}, city files ${cityFileRows}); ` +
      `database active venues with a published eats listing ${snap.dbPublishedActive}`,
  });

  // 2. exactly one canonical eats slug per venue
  const zero: string[] = [];
  const many: string[] = [];
  for (const v of shaped.venues) {
    const c = shaped.canonicalCount.get(v.id) ?? 0;
    if (c === 0) zero.push(v.id);
    if (c > 1) many.push(v.id);
  }
  gates.push({
    name: "one_canonical_slug",
    pass: zero.length === 0 && many.length === 0,
    detail:
      zero.length + many.length === 0
        ? `all ${n} venues hold exactly 1 canonical eats slug`
        : `no canonical slug ${zero.length} (${sample(zero)}); more than 1 ${many.length} (${sample(many)})`,
  });

  // 3. the venue's city exists
  gates.push({
    name: "city_exists",
    pass: shaped.missingCity.length === 0,
    detail:
      shaped.missingCity.length === 0
        ? `all ${n} venues name a city that exists`
        : `${shaped.missingCity.length} venues name a missing city: ${sample(shaped.missingCity)}`,
  });

  // 4. no closed venue
  const closed = shaped.venues.filter((v) => v.status !== "active").map((v) => v.id);
  gates.push({
    name: "no_closed_venue",
    pass: closed.length === 0,
    detail:
      closed.length === 0
        ? `0 of ${n} venues in the files are closed`
        : `${closed.length} closed venues hold a published listing: ${sample(closed)}`,
  });

  // 5. no suspended (or unregistered) source in the files
  const active = new Set(snap.sources.filter((s) => s.status === "active").map((s) => s.slug));
  const badSource: string[] = [];
  for (const v of shaped.venues) {
    for (const a of v.awards) if (!active.has(a.source)) badSource.push(`${v.id}:award:${a.source}`);
    if (v.price?.publisher && !active.has(v.price.publisher)) {
      badSource.push(`${v.id}:price:${v.price.publisher}`);
    }
  }
  const attribution = (shaped.files.get("attribution.json")?.value ?? []) as { source: string }[];
  for (const a of attribution) if (!active.has(a.source)) badSource.push(`attribution:${a.source}`);
  gates.push({
    name: "no_suspended_source",
    pass: badSource.length === 0,
    detail:
      badSource.length === 0
        ? `every source in the files is active (${active.size} of ${snap.sources.length} registered sources active)`
        : `${badSource.length} values from a source that is not active: ${sample(badSource)}`,
  });

  // 6. no Google value: no ChIJ id, no Google URL, no google source, ve_ ids only
  const google: string[] = [];
  for (const [path, text] of texts) {
    const id = GOOGLE_ID.exec(text);
    if (id) google.push(`${path}: ${id[0]}`);
    const url = GOOGLE_URL.exec(text);
    if (url) google.push(`${path}: ${url[0]}`);
  }
  for (const v of shaped.venues) {
    if (!/^ve_[a-z0-9]+$/.test(v.id)) google.push(`venue id ${v.id}`);
    for (const a of v.awards) if (/google/i.test(a.source)) google.push(`${v.id}: award source ${a.source}`);
    if (v.price?.publisher && /google/i.test(v.price.publisher)) {
      google.push(`${v.id}: price publisher ${v.price.publisher}`);
    }
  }
  gates.push({
    name: "no_google_value",
    pass: google.length === 0,
    detail:
      google.length === 0
        ? `0 Google ids, URLs or sources in ${texts.size} files`
        : `${google.length} Google values: ${sample(google)}`,
  });

  // 7. no venue with 2 Michelin rows of the same year and category
  const dupes: string[] = [];
  for (const v of shaped.venues) {
    const seen = new Map<string, number>();
    for (const a of v.awards) {
      if (a.source !== "michelin") continue;
      const k = `${a.year}|${a.category}`;
      seen.set(k, (seen.get(k) ?? 0) + 1);
    }
    for (const [k, c] of seen) if (c > 1) dupes.push(`${v.id} ${k} x${c}`);
  }
  gates.push({
    name: "no_duplicate_michelin",
    pass: dupes.length === 0,
    detail:
      dupes.length === 0
        ? `0 venues hold 2 Michelin rows of one year and category`
        : `${dupes.length} groups: ${sample(dupes)}`,
  });

  // 8. a fall of more than 0.5% from the last version needs a typed override
  if (lastVenueCount === null) {
    gates.push({
      name: "no_large_decrease",
      pass: true,
      detail: "first version in the tree, nothing to compare",
    });
  } else {
    const floor = lastVenueCount * (1 - MAX_DECREASE);
    const drop = lastVenueCount - n;
    const pct = lastVenueCount > 0 ? ((drop / lastVenueCount) * 100).toFixed(2) : "0.00";
    if (n >= floor) {
      gates.push({
        name: "no_large_decrease",
        pass: true,
        detail: `${lastVersion}: ${lastVenueCount} -> ${n} (change ${-drop}, limit 0.5%)`,
      });
    } else {
      const expected = decreaseOverrideText(n);
      const ok = allowDecrease === expected;
      gates.push({
        name: "no_large_decrease",
        pass: ok,
        detail: ok
          ? `${lastVersion}: ${lastVenueCount} -> ${n} (down ${drop}, ${pct}%). Allowed by the typed override "${expected}".`
          : `${lastVersion}: ${lastVenueCount} -> ${n} (down ${drop}, ${pct}%, limit 0.5%). ` +
            `To allow it, type exactly "${expected}" in allow_decrease` +
            (allowDecrease ? ` (got "${allowDecrease}")` : ""),
      });
    }
  }

  // 9. one answer per old address (an old slug the redirects table already
  //    sends to the same page is folded into the table row in lib/shape.ts)
  const dup = shaped.checks.duplicateRedirectFrom;
  const folded = shaped.excluded.oldSlugsSameAsRedirect;
  gates.push({
    name: "redirect_from_unique",
    pass: dup.length === 0,
    detail:
      dup.length === 0
        ? `${shaped.counts.redirects} redirects, each from address once ` +
          `(${folded} old slugs already in the redirects table with the same answer, written once)`
        : `${dup.length} from addresses have 2 different answers: ${sample(dup)}`,
  });

  return gates;
}
