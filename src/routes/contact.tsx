import { createFileRoute } from "@tanstack/react-router";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

export const Route = createFileRoute("/contact")({
  staticData: { prerender: true },
  head: () => {
    const title = "Contact | CompassEats";
    const description = "Get in touch with CompassEats — report a closed venue, a wrong detail, or a missed award.";
    const url = `${SITE_URL}/contact`;
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
  component: ContactPage,
});

function ContactPage() {
  return (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header className="mb-10 md:mb-14">
          <p className="mb-4 text-xs uppercase tracking-[0.2em]" style={{ color: BRONZE }}>
            Get in Touch
          </p>
          <h1 className="font-display text-5xl md:text-6xl font-light tracking-tight" style={{ color: INK }}>
            Contact
          </h1>
          <p className="mt-6 text-base md:text-lg leading-relaxed" style={{ color: INK_MUTED }}>
            Notice something off? A closed venue, a wrong address, an award we missed? Tell us and we&apos;ll fix it.
          </p>
        </header>

        <div className="space-y-6 text-base leading-relaxed" style={{ color: INK_MUTED }}>
          <p className="text-xl md:text-2xl font-medium" style={{ color: BRONZE }}>
            <a href="mailto:hello@compasseats.com" className="hover:underline underline-offset-4">hello@compasseats.com</a>
          </p>
          <p>
            We&apos;re a small team (just one person, currently), so replies take a little time, but every note gets read.
          </p>
        </div>
      </div>
    </main>
  );
}
