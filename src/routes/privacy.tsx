import { createFileRoute } from "@tanstack/react-router";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

export const Route = createFileRoute("/privacy")({
  staticData: { prerender: true },
  head: () => {
    const title = "Privacy Policy | CompassEats";
    const description = "CompassEats privacy policy — what we collect, cookies, and third-party services.";
    const url = `${SITE_URL}/privacy`;
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
  component: PrivacyPage,
});

function PrivacyPage() {
  return (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header className="mb-10 md:mb-14">
          <p className="mb-4 text-xs uppercase tracking-[0.2em]" style={{ color: BRONZE }}>
            Legal
          </p>
          <h1 className="font-display text-5xl md:text-6xl font-light tracking-tight" style={{ color: INK }}>
            Privacy Policy
          </h1>
          <p className="mt-4 text-sm" style={{ color: INK_MUTED }}>
            Last updated: July 2026
          </p>
        </header>

        <div className="space-y-6 text-base leading-relaxed" style={{ color: INK_MUTED }}>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>What we collect.</strong>{" "}
            CompassEats doesn&apos;t require an account, and we don&apos;t collect names, emails, or payment details from people browsing the site. We use standard web analytics (page views, general location, device type) to understand how the site&apos;s used and to fix what&apos;s broken.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Cookies.</strong>{" "}
            We use minimal cookies needed to run the site, like remembering your light or dark mode preference. We don&apos;t use cookies to build advertising profiles, and we don&apos;t sell or share visitor data with advertisers.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Third-party services.</strong>{" "}
            CompassEats uses mapping and location services (MapTiler, Google Places) to show venue locations. These providers may process technical data like IP address as part of delivering maps. Their own privacy policies apply to that processing.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Your rights.</strong>{" "}
            Questions about your data, or want something removed? Contact us at{" "}
            <a href="mailto:hello@compasseats.com" className="underline underline-offset-4" style={{ color: BRONZE }}>hello@compasseats.com</a>.
          </p>
          <p>
            <strong className="font-semibold" style={{ color: INK }}>Changes.</strong>{" "}
            We&apos;ll update this page if our practices change and note the new date at the top.
          </p>
        </div>
      </div>
    </main>
  );
}
