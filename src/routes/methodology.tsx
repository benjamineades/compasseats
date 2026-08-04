import { createFileRoute, Link } from "@tanstack/react-router";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

export const Route = createFileRoute("/methodology")({
  staticData: { prerender: true },
  head: () => {
    const title = "Methodology | CompassEats";
    const description = "How CompassEats decides what qualifies — the award guides we chart from, how a venue earns a listing, and our honesty rule.";
    const url = `${SITE_URL}/methodology`;
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
  component: MethodologyPage,
});

function MethodologyPage() {
  return (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header className="mb-10 md:mb-14">
          <p className="mb-4 text-xs uppercase tracking-[0.2em]" style={{ color: BRONZE }}>
            How We Chart
          </p>
          <h1 className="font-display text-5xl md:text-6xl font-light tracking-tight" style={{ color: INK }}>
            Methodology
          </h1>
          <p className="mt-6 text-base md:text-lg leading-relaxed" style={{ color: INK_MUTED }}>
            CompassEats doesn&apos;t rate, review, or rank anything on its own. Every venue on this site is here because a real award guide, ranked list, or inspection-based authority put it there first. The full roster of who we chart from lives on the{" "}
            <Link to="/guides" className="underline underline-offset-4" style={{ color: BRONZE }}>Guides page</Link>, and it grows every time a new authority proves itself real and reputable.
          </p>
        </header>

        <div className="space-y-6 text-base leading-relaxed" style={{ color: INK_MUTED }}>
          <p>
            A venue qualifies with at least one accolade from a source we track: a Michelin star or Bib Gourmand, a place on the World&apos;s 50 Best or one of its regional editions, a James Beard award, a La Liste or Gault &amp; Millau score, a Tabelog rating past a real threshold, a spot on Top 500 Bars or the Spirited Awards, and so on. No accolade, no listing. That&apos;s the whole rule.
          </p>
          <p>
            Guides publish on their own schedules, some annually, some more often. We pull new lists as soon as they&apos;re out and recheck existing venues on a rolling basis. Every venue page shows the date it was last verified, so you&apos;re never guessing how current the information is.
          </p>
          <p>
            Everything you read on a venue page comes from the guide that honored it or from reputable press coverage. We don&apos;t invent detail to fill space, and if we&apos;re not sure about something, we leave it out rather than guess. If a venue&apos;s closed or a detail&apos;s wrong,{" "}
            <Link to="/contact" className="underline underline-offset-4" style={{ color: BRONZE }}>tell us</Link>{" "}
            and we&apos;ll fix it.
          </p>
        </div>
      </div>
    </main>
  );
}
