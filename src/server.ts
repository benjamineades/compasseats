import "./lib/error-capture";

import { consumeLastCapturedError } from "./lib/error-capture";
import { renderErrorPage } from "./lib/error-page";

type ServerEntry = {
  fetch: (request: Request, env: unknown, ctx: unknown) => Promise<Response> | Response;
};

let serverEntryPromise: Promise<ServerEntry> | undefined;

async function getServerEntry(): Promise<ServerEntry> {
  if (!serverEntryPromise) {
    serverEntryPromise = import("@tanstack/react-start/server-entry").then(
      (m) => ((m as { default?: ServerEntry }).default ?? (m as unknown as ServerEntry)),
    );
  }
  return serverEntryPromise;
}

function brandedErrorResponse(): Response {
  return new Response(renderErrorPage(), {
    status: 500,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function isCatastrophicSsrErrorBody(body: string, responseStatus: number): boolean {
  let payload: unknown;
  try {
    payload = JSON.parse(body);
  } catch {
    return false;
  }

  if (!payload || Array.isArray(payload) || typeof payload !== "object") {
    return false;
  }

  const fields = payload as Record<string, unknown>;
  const expectedKeys = new Set(["message", "status", "unhandled"]);
  if (!Object.keys(fields).every((key) => expectedKeys.has(key))) {
    return false;
  }

  return (
    fields.unhandled === true &&
    fields.message === "HTTPError" &&
    (fields.status === undefined || fields.status === responseStatus)
  );
}

// h3 swallows in-handler throws into a normal 500 Response with body
// {"unhandled":true,"message":"HTTPError"} — try/catch alone never fires for those.
async function normalizeCatastrophicSsrResponse(response: Response): Promise<Response> {
  if (response.status < 500) return response;
  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) return response;

  const body = await response.clone().text();
  if (!isCatastrophicSsrErrorBody(body, response.status)) {
    return response;
  }

  console.error(consumeLastCapturedError() ?? new Error(`h3 swallowed SSR error: ${body}`));
  return brandedErrorResponse();
}


// --- Cache pre-warming -------------------------------------------------------
// Cities warmed on a schedule so the first real visitor gets the (already
// cached) instant response instead of a ~20s cold AI generation. Must mirror
// TOP_CITIES in src/lib/cities.ts. Body shape MUST match an initial city
// search (city/region/country, NO exclude) so the warmed cache key lines up
// exactly with what the city page requests.
const CITIES_TO_WARM: Array<{ city: string; region?: string; country: string }> = [
  { city: "Paris", country: "France" },
  { city: "Tokyo", country: "Japan" },
  { city: "London", country: "United Kingdom" },
  { city: "New York", region: "New York", country: "United States" },
  { city: "Barcelona", country: "Spain" },
  { city: "Madrid", country: "Spain" },
  { city: "Rome", country: "Italy" },
  { city: "Copenhagen", country: "Denmark" },
  { city: "Mexico City", country: "Mexico" },
  { city: "Lima", country: "Peru" },
  { city: "Bangkok", country: "Thailand" },
  { city: "Singapore", country: "Singapore" },
  { city: "Hong Kong", country: "Hong Kong" },
  { city: "Seoul", country: "South Korea" },
  { city: "Lisbon", country: "Portugal" },
  { city: "Berlin", country: "Germany" },
  { city: "Istanbul", country: "Turkey" },
  { city: "Dubai", country: "United Arab Emirates" },
  { city: "Sydney", country: "Australia" },
  { city: "Buenos Aires", country: "Argentina" },
];

const WARM_ORIGIN = "https://www.compasseats.com";

async function warmCity(c: { city: string; region?: string; country: string }) {
  try {
    const res = await fetch(`${WARM_ORIGIN}/api/top-restaurants`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ city: c.city, region: c.region, country: c.country }),
    });
    console.log(`[warm] ${c.city}: ${res.status}`);
  } catch (e) {
    console.log(`[warm] ${c.city} failed:`, (e as Error).message);
  }
}

export default {
  async fetch(request: Request, env: unknown, ctx: unknown) {
    try {
      const handler = await getServerEntry();
      const response = await handler.fetch(request, env, ctx);
      return await normalizeCatastrophicSsrResponse(response);
    } catch (error) {
      console.error(error);
      return brandedErrorResponse();
    }
  },

  // Cloudflare cron entry point. Warms the edge cache for popular cities so
  // real users hit a warm (instant) cache instead of a cold generation.
  // Cities are warmed sequentially to avoid hammering the AI gateway /
  // Firecrawl all at once. ctx.waitUntil keeps the worker alive for the loop.
  async scheduled(_event: unknown, _env: unknown, ctx: { waitUntil: (p: Promise<unknown>) => void }) {
    const run = async () => {
      for (const c of CITIES_TO_WARM) {
        await warmCity(c);
      }
      console.log(`[warm] done: ${CITIES_TO_WARM.length} cities`);
    };
    ctx.waitUntil(run());
  },
};
