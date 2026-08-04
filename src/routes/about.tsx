import { createFileRoute, Link } from "@tanstack/react-router";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";

export const Route = createFileRoute("/about")({
  staticData: { prerender: true },
  head: () => {
    const title = "About | CompassEats";
    const description = "The idea behind CompassEats — a discovery site that only lists restaurants and cocktail bars already honored by real award guides.";
    const url = `${SITE_URL}/about`;
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: url },
        { property: "og:type", content: "website" },
        { name: "twitter:card", content: "summary_large_image" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
      ],
      links: [{ rel: "canonical", href: url }],
    };
  },
  component: AboutPage,
});

function AboutPage() {
  return (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header className="mb-10 md:mb-14">
          <p className="mb-4 text-xs uppercase tracking-[0.2em]" style={{ color: BRONZE }}>
            The Idea
          </p>
          <h1 className="font-display text-5xl md:text-6xl font-light tracking-tight" style={{ color: INK }}>
            About CompassEats
          </h1>
          <p className="mt-6 text-base md:text-lg leading-relaxed" style={{ color: INK_MUTED }}>
            Every trip hits the same moment. Flights are booked, the hotel&apos;s set, and then someone asks where to eat, and the whole group goes quiet. Twenty tabs open. A one-star review from someone who visited in 2019, mad about parking. CompassEats exists so that never happens again.
          </p>
        </header>

        <div className="space-y-6 text-base leading-relaxed" style={{ color: INK_MUTED }}>
          <p>
            We don&apos;t review anything ourselves, and we never will. Every restaurant and cocktail bar here earned its spot somewhere else first: Michelin, the World&apos;s 50 Best, James Beard, and a growing list of guides that spend their whole existence finding the best tables and bars on earth. We just gather what they&apos;ve already found and put it on one map, so you don&apos;t have to hold a spreadsheet&apos;s worth of tabs open before dinner. See the full roster on the{" "}
            <Link to="/guides" className="underline underline-offset-4" style={{ color: BRONZE }}>Guides page</Link>.
          </p>
          <p>
            CompassEats is built and run by one person who got tired of having the same argument every time a trip involved more than one meal. If something here looks off,{" "}
            <Link to="/contact" className="underline underline-offset-4" style={{ color: BRONZE }}>tell us</Link>.
          </p>
          <p>
            Think of it as the well-traveled friend who always knows the spot. Now it fits in your pocket, in more than 3,000 cities.
          </p>
        </div>
      </div>
    </main>
  );
}
