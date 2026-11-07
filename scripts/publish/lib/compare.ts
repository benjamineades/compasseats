import { byKeys } from "./canonical.ts";
import type { Snapshot } from "./read.ts";
import type { Shaped } from "./shape.ts";

/**
 * Compare the new files with what the live site builds from today.
 *
 * The live site reads `data/venues.json` on `main` (Apps Script era, Aug 2026),
 * not Supabase. Its pages are the rows with status `active`; that population
 * equals the live sitemap (10,551 on Nov 5). The groups are the ones of the
 * Nov 5 table, keyed on the page address `/<city_slug>/<slug>`:
 *
 *   same_address          the address is a published venue's canonical slug
 *     (name_differs)        ...and the live name is not the database name
 *   closed_in_database    the address is a slug of a venue that is closed
 *   old_slug              the address is a non-canonical slug of an open venue
 *   no_slug_row           no slug row has that address
 *   unpublished_open      the address is the canonical slug of an open venue with no published listing
 *   no_live_page          a published venue whose canonical address has no live page
 *
 * Weak point, stated in every report: this reads the repo file, not the
 * deployed pages.
 */

export interface LiveRow {
  id?: string;
  slug?: string;
  name?: string;
  city_slug?: string;
  status?: string;
  lat?: number | null;
  lng?: number | null;
  address?: string | null;
  price_tier?: string | null;
  blurb_short?: string | null;
  blurb_long?: string | null;
  cuisine_tags?: string[] | null;
}

export type LiveGroup =
  | "same_address"
  | "closed_in_database"
  | "old_slug"
  | "no_slug_row"
  | "unpublished_open";

export interface CompareRow {
  live_path: string;
  live_name: string;
  group: LiveGroup | "no_live_page";
  name_differs: string;
  venue_id: string;
  db_name: string;
  db_path: string;
}

export interface FieldRow {
  field: string;
  live: number;
  files: number;
  note: string;
}

export interface LiveCompare {
  liveRows: number;
  livePages: number;
  groups: Record<string, number>;
  nameDiffers: number;
  rows: CompareRow[];
  fields: FieldRow[];
}

const filled = (v: unknown) =>
  v !== null && v !== undefined && !(typeof v === "string" && v.trim() === "") &&
  !(Array.isArray(v) && v.length === 0);

export function compareLive(live: LiveRow[], snap: Snapshot, shaped: Shaped): LiveCompare {
  const pages = live.filter((r) => r.status === "active");
  const slugByPath = new Map(snap.slugs.map((s) => [`/${s.city_slug}/${s.slug}`, s]));
  const state = new Map(snap.venueStates.map((v) => [v.id, v]));
  const published = new Map(shaped.venues.map((v) => [v.id, v]));

  const groups: Record<string, number> = {
    same_address: 0,
    closed_in_database: 0,
    old_slug: 0,
    no_slug_row: 0,
    unpublished_open: 0,
    no_live_page: 0,
  };
  let nameDiffers = 0;
  const rows: CompareRow[] = [];
  const livePaths = new Set<string>();

  for (const r of pages) {
    const path = `/${r.city_slug ?? ""}/${r.slug ?? ""}`;
    livePaths.add(path);
    const s = slugByPath.get(path);
    let group: LiveGroup;
    let venueId = "";
    let dbName = "";
    let dbPath = "";
    let differs = "";
    if (!s) {
      group = "no_slug_row";
    } else {
      venueId = s.venue_id;
      const st = state.get(s.venue_id);
      dbName = st?.name ?? "";
      dbPath = published.get(s.venue_id)?.path ?? "";
      if (st?.status === "closed") group = "closed_in_database";
      else if (!s.is_canonical) group = "old_slug";
      else if (published.has(s.venue_id)) {
        group = "same_address";
        if ((r.name ?? "") !== dbName) {
          differs = "yes";
          nameDiffers += 1;
        }
      } else group = "unpublished_open";
    }
    groups[group] += 1;
    rows.push({
      live_path: path,
      live_name: r.name ?? "",
      group,
      name_differs: differs,
      venue_id: venueId,
      db_name: dbName,
      db_path: dbPath,
    });
  }

  for (const v of shaped.venues) {
    if (v.path && livePaths.has(v.path)) continue;
    groups.no_live_page += 1;
    rows.push({
      live_path: "",
      live_name: "",
      group: "no_live_page",
      name_differs: "",
      venue_id: v.id,
      db_name: v.name,
      db_path: v.path ?? "",
    });
  }

  rows.sort((a, b) =>
    byKeys([a.group, a.live_path, a.db_path, a.venue_id], [b.group, b.live_path, b.db_path, b.venue_id]),
  );

  const count = (pred: (r: LiveRow) => boolean) => pages.filter(pred).length;
  const vs = shaped.venues;
  const enrich = new Map(snap.enrichment.map((e) => [e.table, e.on_published]));
  const fields: FieldRow[] = [
    {
      field: "coordinates (lat, lng)",
      live: count((r) => filled(r.lat) && filled(r.lng)),
      files: 0,
      note: `Live values are Google (D4/D6 keep them out). geo rows on published venues: ${enrich.get("geo") ?? 0}. Phase 3.`,
    },
    {
      field: "street address",
      live: count((r) => filled(r.address)),
      files: 0,
      note: `Live values are Google. addresses rows on published venues: ${enrich.get("addresses") ?? 0}. Phase 3.`,
    },
    {
      field: "cuisine tags",
      live: count((r) => filled(r.cuisine_tags)),
      files: vs.filter((v) => v.cuisine.length > 0).length,
      note: "venues.cuisine_tags is empty on every row in the database.",
    },
    {
      field: "price",
      live: count((r) => filled(r.price_tier)),
      files: vs.filter((v) => v.price).length,
      note: "Files: price rows from the database (tier, symbol, currency, publisher).",
    },
    {
      field: "blurb",
      live: count((r) => filled(r.blurb_long) || filled(r.blurb_short)),
      files: vs.filter((v) => v.blurb).length,
      note: "Files: blurbs whose status is not needs_rewrite (rule Q4).",
    },
    {
      field: "awards (at least 1)",
      live: count((r) => Array.isArray((r as { awards?: unknown[] }).awards) && (r as { awards: unknown[] }).awards.length > 0),
      files: vs.filter((v) => v.awards.length > 0).length,
      note: "",
    },
    {
      field: "venue id is a Google place id",
      live: count((r) => typeof r.id === "string" && !r.id.startsWith("ve_")),
      files: vs.filter((v) => !v.id.startsWith("ve_")).length,
      note: "Files use ve_ ids only.",
    },
  ];

  return {
    liveRows: live.length,
    livePages: pages.length,
    groups,
    nameDiffers,
    rows,
    fields,
  };
}
