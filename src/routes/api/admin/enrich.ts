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
//   This route SELF-WALKS: each request processes as many venues as fit within
//   a ~20s time budget, then returns a `nextUrl` to continue from. You click a
//   handful of times, not once per 50 rows.
//
//   1. Set a secret in your env:  ENRICH_ADMIN_TOKEN=some-long-random-string
//   2. DRY RUN (writes nothing, previews matches):
//        /api/admin/enrich?token=YOUR_TOKEN
//      Then follow the `nextUrl` it returns, repeating until "done": true.
//   3. When the previews look right, do the same starting from offset 0 but with
//      &write=true, following each `nextUrl` until "done": true:
//        /api/admin/enrich?token=YOUR_TOKEN&write=true
//      The FIRST write request creates the tab + header row automatically. Each
//      chunk is written as it completes, so progress survives a cut-off request
//      (re-running just skips venues already in the tab).
//   4. Delete this file and re-publish.
//
// Optional params:
//   &offset=N    start at venue N (the `nextUrl` sets this for you)
//   &chunk=40    venues resolved per inner chunk (default 40, max 100)
//   &maxms=20000 per-request time budget in ms (default 20000, max 25000).
//                Lower it if you see Worker timeouts; raise it cautiously.
//   &force=true  re-resolve venues even if already present in the tab
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

// JSON response that explicitly declares UTF-8, so accented / non-Latin venue
// names (e.g. "Faubourg Saint-Honoré", "Nhà hàng 1946") render correctly in the
// browser instead of as mojibake. The data itself is always UTF-8; this just
// makes sure the client decodes it that way.
const json = (body: unknown, status = 200): Response =>
  new Response(JSON.stringify(body, null, 2), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });

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
        const startedAt = Date.now();
        const url = new URL(request.url);
        const token = url.searchParams.get("token") ?? "";
        const expected = process.env.ENRICH_ADMIN_TOKEN ?? "";
        if (!expected || token !== expected) {
          return json({ error: "Unauthorized" }, 401);
        }

        const write = url.searchParams.get("write") === "true";
        const force = url.searchParams.get("force") === "true";
        const offset = Math.max(0, Number(url.searchParams.get("offset") ?? "0") || 0);
        // Venues resolved per inner chunk (each does `chunk` parallel Places
        // calls, then writes that chunk's rows before starting the next).
        const chunk = Math.min(
          100,
          Math.max(1, Number(url.searchParams.get("chunk") ?? "40") || 40),
        );
        // Wall-clock budget per REQUEST. The handler keeps processing chunks
        // until it either finishes or this budget is hit, then returns a
        // continuation URL. Kept well under the Worker CPU ceiling. Tune down
        // if you see timeouts; tune up (cautiously) to do more per click.
        const maxMs = Math.min(
          25_000,
          Math.max(3_000, Number(url.searchParams.get("maxms") ?? "20000") || 20_000),
        );

        try {
          // 1. Enumerate unique venues across all award tabs.
          const venues = await collectVenues();

          // 2. Find which venues are already in the enrichment tab (skip unless
          //    &force=true). Also tells us if the tab has been initialized yet.
          const existingHeader = await readHeaderRow(ENRICH_TAB);
          const tabInitialized = existingHeader !== null && existingHeader.length > 0;

          const alreadyDone = new Set<string>();
          if (tabInitialized && !force) {
            const rows = await readSheet(ENRICH_TAB); // A2:Z — data rows only
            for (const r of rows) {
              const k = (r[0] ?? "").trim();
              if (k) alreadyDone.add(k);
            }
          }

          // 3. Self-walking loop: process consecutive chunks starting at
          //    `offset` until we run out of venues OR exhaust the time budget.
          //    Each chunk's rows are appended as soon as the chunk resolves, so
          //    progress is durable even if the request is later cut off.
          let headerWritten = tabInitialized;
          let cursor = offset;
          let processed = 0;
          let matched = 0;
          let unmatched = 0;
          let wrote = 0;
          const now = new Date().toISOString();
          const preview: Array<Record<string, unknown>> = [];
          const PREVIEW_CAP = 30;
          let stoppedForTime = false;

          while (cursor < venues.length) {
            if (Date.now() - startedAt > maxMs) {
              stoppedForTime = true;
              break;
            }
            const slice = venues.slice(cursor, cursor + chunk);
            cursor += slice.length;
            const toProcess = force
              ? slice
              : slice.filter((v) => !alreadyDone.has(v.key));
            if (toProcess.length === 0) continue;

            const resolved = await Promise.all(
              toProcess.map(async (v) => ({ v, place: await lookupPlace(v.name, v.city, v.country) })),
            );

            const rows: string[][] = [];
            for (const { v, place } of resolved) {
              processed++;
              if (place && place.placeId) matched++;
              else unmatched++;
              rows.push([
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
              ]);
              if (preview.length < PREVIEW_CAP) {
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
            }

            // Write this chunk immediately (only if &write=true).
            if (write && rows.length > 0) {
              if (!headerWritten) {
                await ensureTabExists();
                await appendRows([[...HEADER]]);
                headerWritten = true;
              }
              await appendRows(rows);
              wrote += rows.length;
            }
          }

          const done = cursor >= venues.length;
          const carry: string[] = [];
          if (chunk !== 40) carry.push(`chunk=${chunk}`);
          if (maxMs !== 20000) carry.push(`maxms=${maxMs}`);
          const carryStr = carry.length ? `&${carry.join("&")}` : "";

          return json({
            mode: write
              ? "WRITE"
              : "DRY-RUN (nothing written — add &write=true to commit)",
            tab: ENRICH_TAB,
            tabExisted: tabInitialized,
            totalUniqueVenues: venues.length,
            startOffset: offset,
            endOffset: cursor,
            processedThisRequest: processed,
            matched,
            unmatched,
            rowsWritten: wrote,
            elapsedMs: Date.now() - startedAt,
            stoppedForTime,
            done,
            // Visit this next to continue. Stops when "done": true.
            nextUrl: done
              ? null
              : `${url.pathname}?token=YOUR_TOKEN${write ? "&write=true" : ""}${
                  force ? "&force=true" : ""
                }&offset=${cursor}${carryStr}`,
            previewNote: `showing first ${Math.min(preview.length, PREVIEW_CAP)} of ${processed} processed this request`,
            preview,
          });
        } catch (err) {
          console.error("[admin/enrich] error:", err);
          return json({ error: (err as Error).message ?? "enrichment failed" }, 500);
        }
      },
    },
  },
});
