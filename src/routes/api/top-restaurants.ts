import "@tanstack/react-start";
import { createFileRoute } from "@tanstack/react-router";
import { generateText, Output } from "ai";
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
        priceRange: z.enum(["$", "$$", "$$$", "$$$$"]),
        description: z.string(),
        neighborhood: z.string().optional(),
      }),
    )
    .length(5),
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
        const model = gateway("google/gemini-3-flash-preview");

        try {
          const { output } = await generateText({
            model,
            output: Output.object({ schema: restaurantsSchema }),
            prompt: `List the top 5 most acclaimed and beloved restaurants in ${parsed.city}. Mix iconic must-visit spots with locally celebrated favorites. For each: short, vivid one-sentence description (max 25 words) of what makes it special. Use the city's actual name and country. If "${parsed.city}" is not a recognizable city, still attempt your best interpretation.`,
          });
          return Response.json(output);
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