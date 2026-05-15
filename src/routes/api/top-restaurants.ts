import "@tanstack/react-start";
import { createFileRoute } from "@tanstack/react-router";
import { generateObject } from "ai";
import { z } from "zod";
import { createLovableAiGatewayProvider } from "@/lib/ai-gateway";

const bodySchema = z.object({
  city: z.string().trim().min(1).max(100),
});

const resultsSchema = z.object({
  city: z.string(),
  country: z.string(),
  lat: z.number(),
  lng: z.number(),
  venues: z
    .array(
      z.object({
        name: z.string(),
        category: z.enum(["restaurant", "cocktail bar"]),
        cuisine: z.string(),
        priceRange: z.string(),
        description: z.string(),
        neighborhood: z.string().optional(),
        lat: z.number(),
        lng: z.number(),
      }),
    )
    .min(6)
    .max(10),
});

export const Route = createFileRoute("/api/top-restaurants")({
  server: {
    handlers: {
      POST: async ({ request }: { request: Request }) => {
        let parsed;
        try {
          const json = await request.json();
          parsed = bodySchema.parse(json);
        } catch {
          return Response.json({ error: "Invalid request" }, { status: 400 });
        }

        const apiKey = process.env.LOVABLE_API_KEY;
        if (!apiKey) {
          return Response.json(
            { error: "AI is not configured." },
            { status: 500 },
          );
        }

        const gateway = createLovableAiGatewayProvider(apiKey);
        const model = gateway("google/gemini-2.5-flash");

        try {
          const { object } = await generateObject({
            model,
            schema: resultsSchema,
            prompt: `List the 5 top restaurants AND the 5 top cocktail bars in ${parsed.city} (10 venues total). Rank restaurants strictly using World's 50 Best Restaurants, World's Best Discovery, Michelin Guide, Eater, and well-regarded local press. Rank cocktail bars strictly using World's 50 Best Bars, World's Best Discovery, Tales of the Cocktail Spirited Awards, Top 500 Bars, and well-regarded local press. Do not use Google Maps for ranking, popularity, or selection. Use Google Maps ONLY as a final filter to exclude any venue marked "Permanently closed" or otherwise known to have closed; rankings and choices must come solely from the lists above. Return JSON with: city (proper name), country, lat/lng (city center coordinates), and venues (array of 10: 5 restaurants then 5 cocktail bars). Each venue: name, category ("restaurant" or "cocktail bar"), cuisine (for restaurants: cuisine type; for bars: style/specialty like speakeasy, tiki, classic), priceRange ("$", "$$", "$$$" or "$$$$"), description (one vivid sentence, max 25 words, mention list recognition if notable), neighborhood (optional), lat and lng (precise venue coordinates). If "${parsed.city}" is ambiguous, pick the most famous match.`,
          });
          return Response.json(object);
        } catch (err: unknown) {
          const e = err as { statusCode?: number; status?: number; message?: string };
          const status = e.statusCode ?? e.status;
          if (status === 429) {
            return Response.json(
              { error: "Too many requests. Please wait a moment and try again." },
              { status: 429 },
            );
          }
          if (status === 402) {
            return Response.json(
              { error: "AI credits exhausted. Add credits in Settings → Workspace → Usage." },
              { status: 402 },
            );
          }
          console.error("top-restaurants error:", err);
          return Response.json(
            { error: "Couldn't fetch restaurants. Try a different city." },
            { status: 500 },
          );
        }
      },
    },
  },
});