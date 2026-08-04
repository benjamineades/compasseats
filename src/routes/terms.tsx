import { createFileRoute } from "@tanstack/react-router";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

export const Route = createFileRoute("/terms")({
  staticData: { prerender: true },
  head: () => {
    const title = "Terms of Use | CompassEats";
    const description = "CompassEats terms of use.";
    const url = `${SITE_URL}/terms`;
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
  component: TermsPage,
});

function TermsPage() {
  return (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header className="mb-10 md:mb-14">
          <p className="mb-4 text-xs uppercase tracking-[0.2em]" style={{ color: BRONZE }}>
            Legal
          </p>
          <h1 className="font-display text-5xl md:text-6xl font-light tracking-tight" style={{ color: INK }}>
            Terms of Use
          </h1>
          <p className="mt-4 text-sm" style={{ color: INK_MUTED }}>
            Last updated: July 2026
          </p>
        </header>

        <div className="space-y-6 text-base leading-relaxed" style={{ color: INK_MUTED }}>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Use of the site.</strong>{" "}
            CompassEats is an informational discovery guide, not a booking or reservation service. We link out to venues and guides for that. Using the site means you agree to these terms.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Accuracy of information.</strong>{" "}
            We do our best to keep venue details, hours, and awards current, and every venue page shows when it was last verified. Restaurants and bars change fast: menus, hours, ownership, sometimes whether they&apos;re even still open. Confirm details directly with the venue before you go.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Third-party links.</strong>{" "}
            Links to venues, guides, and award sources take you off CompassEats to sites we don&apos;t control. We aren&apos;t responsible for their content or availability.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Intellectual property.</strong>{" "}
            The CompassEats name, logo, and site design belong to CompassEats. Award and guide names belong to their respective organizations, mentioned here for identification only, not endorsement.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Limitation of liability.</strong>{" "}
            CompassEats is provided as is, without warranty of any kind. We aren&apos;t liable for decisions made based on information found here, including a bad meal.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Changes to these terms.</strong>{" "}
            We may update these terms as the site grows. Continued use after a change means you accept it.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Contact.</strong>{" "}
            Questions about these terms:{" "}
            <a href="mailto:hello@compasseats.com" className="underline underline-offset-4" style={{ color: BRONZE }}>hello@compasseats.com</a>
          </p>
        </div>
      </div>
    </main>
  );
}
