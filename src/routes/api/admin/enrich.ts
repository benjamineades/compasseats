// TEMPORARY ADMIN ROUTE — Places enrichment for the accolades sheet.
//
// Purpose: build a separate "Places Enrichment" tab in the canonical Google
// Sheet that stores, for every UNIQUE venue across all award tabs, its Google
// Places id (place_id), current lat/lng, a photo *reference* (Places ToS-safe;
// never a raw photo URL), and the canonical Places display name. The canonical
// name doubles as a SECOND matching key so venues like the sheet's "Bar
// Benfiddich" still match what the AI/Yelp surfaces as "Ben Fiddich".
//
// Once this tab is populated, accolades.server.ts can join it into the index so
// the charted tier renders straight from the sheet with NO AI call — near
// instant everywhere, not just pre-warmed cities. (That join is a SEPARATE,
// later change; this route only POPULATES the tab.)
//
// ─────────────────────────────────────────────────────────────────────────────
// SAFETY MODEL
//   • Dry-run by DEFAULT. Nothing is written unless you pass &write=true.
//   • Writes ONLY to a brand-new tab ("Places Enrichment"). It never reads,
//     edits, reorders, or deletes any existing award tab. Your existing data
//     cannot be touched by this route.
//   • Token-gated: requires &token= to match process.env.ENRICH_ADMIN_TOKEN.
//   • Batched: Cloudflare Workers cap CPU per request, so it processes a slice
//     of venues per call. Each response tells you the next offset to visit.
//   • DELETE THIS FILE once enrichment is complete.
//
// ─────────────────────────────────────────────────────────────────────────────
// HOW TO RUN (in the browser — no terminal needed)
//   1. Set a secret in your env:  ENRICH_ADMIN_TOKEN=some-long-random-string
//   2. DRY RUN, first batch (writes nothing, shows a preview of 50 rows):
//        /api/admin/enrich?token=YOUR_TOKEN
//   3. Walk the batches using the `nextOffset` value each response returns:
//        /api/admin/enrich?token=YOUR_TOKEN&offset=50
//        /api/admin/enrich?token=YOUR_TOKEN&offset=100   ... until done:true
//   4. When the previews look right, repeat with &write=true to commit:
//        /api/admin/enrich?token=YOUR_TOKEN&write=true
//        /api/admin/enrich?token=YOUR_TOKEN&write=true&offset=50   ... etc.
//      The FIRST write call creates the tab + header row automatically.
//   5. Delete this file and re-publish.
//
// Optional params:
//   &batch=50   how many venues to process per request (default 50, max 100)
//   &force=true re-resolve venues even if already present in the tab
// ─────────────────────────────────────────────────────────────────────────────

import "@tanstack/react-start";
import { createFileRoute } from "@tanstack/react-router";

const SPREADSHEET_ID = "1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s";
const SHEETS_GATEWAY = "https://connector-gateway.lovable.dev/google_sheets/v4";
const MAPS_GATEWAY = "https://connector-gateway.lovable.dev/google_maps";
const ENRICH_TAB = "Places Enrichment";

// Header row written to the new tab on first write. Order is fixed; downstream
// code (the future accolades join) keys off `normalizedKey` (col A).
const HEADER = [
  "normalizedKey",
  "canonicalName",
  "sheetName",
  "placeId",
  "lat",
  "lng",
  "photoName",
  "formattedAddress",
  "businessStatus",
  "lastVerified",
] as const;

// ── name normalization — MUST stay identical to accolades.server.ts ──────────
const normalizeName = (raw: string): string =>
  raw
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[’'`]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();

const normalizeLocale = (raw: string | undefined): string =>
  (raw ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();

// "Chicago, IL, USA" → { city: "chicago", country: "usa" }
const splitLocation = (loc: string) => {
  const parts = (loc ?? "").split(",").map((s) => s.trim()).filter(Boolean);
  return {
    city: normalizeLocale(parts[0]),
    country: normalizeLocale(parts[parts.length - 1]),
  };
};

// ── sheet read (mirrors accolades.server.ts fetchSheet) ──────────────────────
const sheetCreds = () => {
  const apiKey = process.env.LOVABLE_API_KEY;
  const conn = process.env.GOOGLE_SHEETS_API_KEY;
  if (!apiKey || !conn) throw new Error("Google Sheets credentials missing");
  return { apiKey, conn };
};

const readSheet = async (sheetName: string): Promise<string[][]> => {
  const { apiKey, conn } = sheetCreds();
  // Don't encode the range — gateway requires raw colons in path.
  const range = `'${sheetName.replace(/'/g, "''")}'!A2:Z`;
  const url = `${SHEETS_GATEWAY}/spreadsheets/${SPREADSHEET_ID}/values/${range}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${apiKey}`, "X-Connection-Api-Key": conn },
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Sheets read ${res.status} for ${sheetName}: ${text.slice(0, 200)}`);
  }
  const data = (await res.json()) as { values?: string[][] };
  return data.values ?? [];
};

// Read just the header row (row 1) of a tab; used to detect whether the
// enrichment tab already exists and is initialized.
const readHeaderRow = async (sheetName: string): Promise<string[] | null> => {
  const { apiKey, conn } = sheetCreds();
  const range = `'${sheetName.replace(/'/g, "''")}'!A1:Z1`;
  const url = `${SHEETS_GATEWAY}/spreadsheets/${SPREADSHEET_ID}/values/${range}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${apiKey}`, "X-Connection-Api-Key": conn },
  });
  if (!res.ok) return null; // tab likely doesn't exist yet
  const data = (await res.json()) as { values?: string[][] };
  return data.values?.[0] ?? [];
};

// ── sheet write helpers ──────────────────────────────────────────────────────
// Create the enrichment tab (idempotent: ignores "already exists" errors).
const ensureTabExists = async (): Promise<void> => {
  const { apiKey, conn } = sheetCreds();
  const url = `${SHEETS_GATEWAY}/spreadsheets/${SPREADSHEET_ID}:batchUpdate`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "X-Connection-Api-Key": conn,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      requests: [{ addSheet: { properties: { title: ENRICH_TAB } } }],
    }),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    // If the tab already exists the API 400s — that's fine, swallow it.
    if (/already exists/i.test(text)) return;
    throw new Error(`addSheet failed ${res.status}: ${text.slice(0, 200)}`);
  }
};

// Append rows to the enrichment tab (never overwrites; uses values:append).
const appendRows = async (rows: string[][]): Promise<void> => {
  if (rows.length === 0) return;
  const { apiKey, conn } = sheetCreds();
  const range = `'${ENRICH_TAB}'!A1`;
  const url =
    `${SHEETS_GATEWAY}/spreadsheets/${SPREADSHEET_ID}/values/${range}:append` +
    `?valueInputOption=RAW&insertDataOption=INSERT_ROWS`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "X-Connection-Api-Key": conn,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ values: rows }),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`append failed ${res.status}: ${text.slice(0, 200)}`);
  }
};

// ── Google Places lookup (mirrors top-restaurants.ts lookupGooglePlace) ───────
type PlaceResult = {
  placeId?: string;
  canonicalName?: string;
  lat?: number;
  lng?: number;
  photoName?: string;
  formattedAddress?: string;
  businessStatus?: string;
};

const lookupPlace = async (
  name: string,
  city: string,
  country: string,
): Promise<PlaceResult | null> => {
  const lovableKey = process.env.LOVABLE_API_KEY;
  const gmapsKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!lovableKey || !gmapsKey) return null;
  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 6000);
    const res = await fetch(`${MAPS_GATEWAY}/places/v1/places:searchText`, {
      method: "POST",
      signal: ctrl.signal,
      headers: {
        Authorization: `Bearer ${lovableKey}`,
        "X-Connection-Api-Key": gmapsKey,
        "Content-Type": "application/json",
        "X-Goog-FieldMask":
          "places.id,places.displayName,places.businessStatus,places.formattedAddress,places.location,places.photos",
      },
      body: JSON.stringify({
        textQuery: [name, city, country].filter(Boolean).join(", "),
        maxResultCount: 1,
      }),
    });
    clearTimeout(timer);
    if (!res.ok) return null;
    const data = (await res.json()) as {
      places?: Array<{
        id?: string;
        displayName?: { text?: string };
        businessStatus?: string;
        formattedAddress?: string;
        location?: { latitude: number; longitude: number };
        photos?: Array<{ name?: string }>;
      }>;
    };
    const p = data.places?.[0];
    if (!p) return null;
    return {
      placeId: p.id,
      canonicalName: p.displayName?.text,
      lat: p.location?.latitude,
      lng: p.location?.longitude,
      photoName: p.photos?.[0]?.name,
      formattedAddress: p.formattedAddress,
      businessStatus: p.businessStatus,
    };
  } catch {
    return null;
  }
};

// ── venue enumeration: dedupe every unique venue across all award tabs ────────
// Column layouts copied verbatim from accolades.server.ts buildIndex(). If a
// tab's layout changes there, mirror it here.
type Venue = { key: string; name: string; sheetName: string; city: string; country: string };

const collectVenues = async (): Promise<Venue[]> => {
  const OAD_SHEETS = [
    "OAD North America 2026",
    "OAD South America 2026",
    "OAD Asia 2025",
    "OAD Europe 2025",
    "OAD Japan 2025",
    "OAD North America 2025",
    "OAD South America 2025",
  ];
  const [michelin, w50, jba, chef, pinnacle, spirited, ...oad] = await Promise.all([
    readSheet("Michelin Guide"),
    readSheet("World's 50 Best"),
    readSheet("James Beard Awards"),
    readSheet("Best Chef Awards"),
    readSheet("Pinnacle Guide"),
    readSheet("Spirited Awards"),
    ...OAD_SHEETS.map((n) => readSheet(n).catch(() => [] as string[][])),
  ]);

  // Keep the FIRST occurrence of each normalized name. We also keep its
  // city/country so the Places query is locale-biased (improves match quality).
  const seen = new Map<string, Venue>();
  const add = (name: string, sheetName: string, city: string, country: string) => {
    if (!name) return;
    const key = normalizeName(name);
    if (!key || seen.has(key)) return;
    seen.set(key, { key, name: name.trim(), sheetName, city, country });
  };

  for (const r of michelin) {
    const [, name, location] = r; // [Star Level, Name, Location, ...]
    if (!name) continue;
    const { city, country } = splitLocation(location ?? "");
    add(name, "Michelin Guide", city, country);
  }
  for (const r of w50) {
    const [, , , name, city, country] = r; // [Year, Rank, Type, Name, City, Country]
    add(name, "World's 50 Best", normalizeLocale(city), normalizeLocale(country));
  }
  for (const r of jba) {
    const [, , , restaurant, city, state] = r; // [Year, Cat, Chef, Restaurant, City, State]
    add(restaurant, "James Beard Awards", normalizeLocale(city), normalizeLocale(state));
  }
  for (const r of chef) {
    const [, , restaurant, , location] = r; // [Year, Chef, Restaurant, Knives, Location]
    if (!restaurant) continue;
    const { city, country } = splitLocation(location ?? "");
    add(restaurant, "Best Chef Awards", city, country);
  }
  for (const r of pinnacle) {
    const [, , bar, city, country] = r; // [Pins, Year, Bar, City, Country]
    add(bar, "Pinnacle Guide", normalizeLocale(city), normalizeLocale(country));
  }
  for (const r of spirited) {
    const [, , bar, city, , country] = r; // [Year, Cat, Bar, City, State, Country]
    add(bar, "Spirited Awards", normalizeLocale(city), normalizeLocale(country));
  }
  for (let s = 0; s < OAD_SHEETS.length; s++) {
    for (const r of oad[s] ?? []) {
      const [, restaurant, city, , country] = r; // [Rank, Restaurant, City, State, Country, ...]
      add(restaurant, OAD_SHEETS[s], normalizeLocale(city), normalizeLocale(country));
    }
  }

  // Stable order so batch offsets are deterministic across calls.
  return [...seen.values()].sort((a, b) => a.key.localeCompare(b.key));
};

// ── handler ──────────────────────────────────────────────────────────────────
export const Route = createFileRoute("/api/admin/enrich")({
  server: {
    handlers: {
      GET: async ({ request }: { request: Request }) => {
        const url = new URL(request.url);
        const token = url.searchParams.get("token") ?? "";
        const expected = process.env.ENRICH_ADMIN_TOKEN ?? "";
        if (!expected || token !== expected) {
          return Response.json({ error: "Unauthorized" }, { status: 401 });
        }

        const write = url.searchParams.get("write") === "true";
        const force = url.searchParams.get("force") === "true";
        const offset = Math.max(0, Number(url.searchParams.get("offset") ?? "0") || 0);
        const batch = Math.min(
          100,
          Math.max(1, Number(url.searchParams.get("batch") ?? "50") || 50),
        );

        try {
          // 1. Enumerate unique venues across all award tabs.
          const venues = await collectVenues();

          // 2. Find which venues are already in the enrichment tab (skip unless
          //    --force). Reading the existing tab also tells us if it's been
          //    initialized with a header yet.
          const existingHeader = await readHeaderRow(ENRICH_TAB);
          const tabExists = existingHeader !== null;
          const tabInitialized = tabExists && existingHeader!.length > 0;

          const alreadyDone = new Set<string>();
          if (tabInitialized && !force) {
            const rows = await readSheet(ENRICH_TAB); // A2:Z — data rows only
            for (const r of rows) {
              const k = (r[0] ?? "").trim();
              if (k) alreadyDone.add(k);
            }
          }

          // 3. Take this batch's slice.
          const slice = venues.slice(offset, offset + batch);
          const toProcess = force ? slice : slice.filter((v) => !alreadyDone.has(v.key));

          // 4. Resolve each via Places (sequentially-ish but parallel within the
          //    batch; batch is small enough to stay under the CPU limit).
          const resolved = await Promise.all(
            toProcess.map(async (v) => {
              const place = await lookupPlace(v.name, v.city, v.country);
              return { v, place };
            }),
          );

          const rows: string[][] = [];
          const preview: Array<Record<string, unknown>> = [];
          const now = new Date().toISOString();
          let matched = 0;
          let unmatched = 0;

          for (const { v, place } of resolved) {
            if (place && place.placeId) matched++;
            else unmatched++;
            const row = [
              v.key,
              place?.canonicalName ?? v.name,
              v.sheetName,
              place?.placeId ?? "",
              place?.lat != null ? String(place.lat) : "",
              place?.lng != null ? String(place.lng) : "",
              place?.photoName ?? "",
              place?.formattedAddress ?? "",
              place?.businessStatus ?? "",
              now,
            ];
            rows.push(row);
            preview.push({
              sheetName: v.name,
              canonicalName: place?.canonicalName ?? null,
              matched: Boolean(place?.placeId),
              placeId: place?.placeId ?? null,
              lat: place?.lat ?? null,
              lng: place?.lng ?? null,
              status: place?.businessStatus ?? null,
              nameDiffers:
                place?.canonicalName != null &&
                normalizeName(place.canonicalName) !== v.key,
            });
          }

          // 5. Write (only if &write=true).
          let wrote = 0;
          if (write && rows.length > 0) {
            if (!tabInitialized) {
              await ensureTabExists();
              await appendRows([[...HEADER]]); // header row first
            }
            await appendRows(rows);
            wrote = rows.length;
          }

          const nextOffset = offset + batch;
          const done = nextOffset >= venues.length;

          return Response.json({
            mode: write ? "WRITE" : "DRY-RUN (nothing written — add &write=true to commit)",
            tab: ENRICH_TAB,
            tabExisted: tabInitialized,
            totalUniqueVenues: venues.length,
            batch,
            offset,
            processedThisBatch: toProcess.length,
            skippedAlreadyDone: slice.length - toProcess.length,
            matched,
            unmatched,
            rowsWritten: wrote,
            nextOffset: done ? null : nextOffset,
            done,
            nextUrl: done
              ? null
              : `${url.pathname}?token=YOUR_TOKEN${write ? "&write=true" : ""}&offset=${nextOffset}${
                  batch !== 50 ? `&batch=${batch}` : ""
                }`,
            preview,
          });
        } catch (err) {
          console.error("[admin/enrich] error:", err);
          return Response.json(
            { error: (err as Error).message ?? "enrichment failed" },
            { status: 500 },
          );
        }
      },
    },
  },
});
