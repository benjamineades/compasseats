import "@tanstack/react-start";
import { createFileRoute } from "@tanstack/react-router";
import { generateObject } from "ai";
import { z } from "zod";
import { createLovableAiGatewayProvider } from "@/lib/ai-gateway";

const bodySchema = z.object({
  city: z.string().trim().min(1).max(100),
});

const restaurantsSchema = z.object({
  city: z.string(),
  country: z.string(),
  restaurants: z
    .array(
      z.object({
        name: z.string(),
        cuisine: z.string(),
        priceRange: z.string(),
        description: z.string(),
        neighborhood: z.string().optional(),
      }),
    )
    .min(3)
    .max(5),
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
            schema: restaurantsSchema,
            prompt: `List 5 top restaurants in ${parsed.city} based on widely available web reviews and rankings (Yelp, Google, Tripadvisor, Eater, Michelin). Return JSON with: city (proper name), country, and restaurants (array of 5). Each restaurant: name, cuisine, priceRange ("$", "$$", "$$$" or "$$$$"), description (one vivid sentence, max 25 words), neighborhood (optional). If "${parsed.city}" is ambiguous, pick the most famous match.`,
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