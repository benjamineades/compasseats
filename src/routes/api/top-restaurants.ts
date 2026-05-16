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
        url: z.string().url().optional(),
        urlType: z.enum(["website", "instagram", "facebook"]).optional(),
        michelinStars: z.number().int().min(0).max(3).optional(),
        michelinGreenStar: z.boolean().optional(),
        bibGourmand: z.boolean().optional(),
        worldsBest50Restaurants: z
          .object({ rank: z.number().int().min(1).max(100), year: z.number().int() })
          .optional(),
        worldsBest50Bars: z
          .object({ rank: z.number().int().min(1).max(100), year: z.number().int() })
          .optional(),
        spiritedAward: z
          .object({ name: z.string(), year: z.number().int() })
          .optional(),
      }),
    )
    .min(10)
    .max(20),
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
          prompt: `List the 10 top restaurants AND the 10 top cocktail bars in ${parsed.city} (20 venues total). Rank restaurants strictly using World's 50 Best Restaurants, World's Best Discovery, Michelin Guide, Eater, and well-regarded local press. Rank cocktail bars strictly using World's 50 Best Bars, World's Best Discovery, Tales of the Cocktail Spirited Awards, Top 500 Bars, and well-regarded local press. Do not use Google Maps for ranking, popularity, or selection. Use Google Maps ONLY for two things: (1) exclude any venue marked "Permanently closed" or otherwise known to have closed, and (2) source each venue's CURRENT precise latitude and longitude from its present-day Google Maps listing — if a venue has moved, use its current address coordinates, not historical ones. Rankings and choices must come solely from the lists above. Return JSON with: city (proper name), country, lat/lng (city center coordinates), and venues (array of 20: 10 restaurants then 10 cocktail bars). Each venue: name, category ("restaurant" or "cocktail bar"), cuisine (for restaurants: cuisine type; for bars: style/specialty like speakeasy, tiki, classic), priceRange ("$", "$$", "$$$" or "$$$$"), description (one vivid sentence, max 25 words), neighborhood (optional), lat/lng (precise current venue coordinates), url (the venue's official website if it has one; otherwise the Instagram profile URL; otherwise the Facebook page URL; omit only if none exist), urlType ("website" | "instagram" | "facebook" matching the url provided). For RESTAURANTS, also include when applicable: michelinStars (1, 2, or 3 — only from the current Michelin Guide; omit or 0 if none), michelinGreenStar (true if currently awarded the Michelin Green Star for sustainability), bibGourmand (true if currently a Michelin Bib Gourmand), worldsBest50Restaurants ({rank, year} — most recent year the restaurant placed on World's 50 Best Restaurants top 50 or extended 51–100 list, with that rank and year; omit if never listed). For COCKTAIL BARS, also include when applicable: worldsBest50Bars ({rank, year} — most recent year it placed on World's 50 Best Bars top 50 or extended 51–100, with that rank and year; omit if never listed), spiritedAward ({name, year} — most notable Tales of the Cocktail Spirited Award the bar has won, e.g. "World's Best Cocktail Bar", with the year; omit if none). Only include accolade fields you are confident about; never fabricate. If "${parsed.city}" is ambiguous, pick the most famous match.`,
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