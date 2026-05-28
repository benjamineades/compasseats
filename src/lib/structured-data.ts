/**
 * src/lib/structured-data.ts
 *
 * Schema.org JSON-LD builders. This is what gets CompassEats into Google's
 * rich-result panel — restaurant cards in search, knowledge-panel-style
 * info boxes, the lot.
 *
 * Spec references:
 *   Restaurant: https://schema.org/Restaurant
 *   BarOrPub:   https://schema.org/BarOrPub
 *   Award:      https://schema.org/award
 */

import { AWARD_SOURCES, type Venue } from "./schema";

const SITE_URL = "https://compasseats.com";

const SOURCE_NAME_BY_SLUG: Record<string, string> = Object.fromEntries(
  AWARD_SOURCES.map((s) => [s.slug, s.name])
);

interface OpeningHoursSpec {
  "@type": "OpeningHoursSpecification";
  dayOfWeek: string;
  opens: string;
  closes: string;
}

const DAY_MAP: Record<string, string> = {
  mon: "Monday",
  tue: "Tuesday",
  wed: "Wednesday",
  thu: "Thursday",
  fri: "Friday",
  sat: "Saturday",
  sun: "Sunday",
};

function buildHoursSpec(hours: Venue["hours"]): OpeningHoursSpec[] {
  if (!hours) return [];
  const specs: OpeningHoursSpec[] = [];
  for (const [key, label] of Object.entries(DAY_MAP)) {
    const ranges = (hours as Record<string, { open: string; close: string }[] | undefined>)[key];
    if (!ranges) continue;
    for (const r of ranges) {
      specs.push({
        "@type": "OpeningHoursSpecification",
        dayOfWeek: label,
        opens: r.open,
        closes: r.close,
      });
    }
  }
  return specs;
}

export function buildVenueStructuredData(venue: Venue) {
  const type = venue.type === "bar" ? "BarOrPub" : "Restaurant";

  const awards = venue.awards.map((a) => {
    const source = SOURCE_NAME_BY_SLUG[a.source] ?? a.source;
    return `${source} ${a.year} — ${a.category}`;
  });

  return {
    "@context": "https://schema.org",
    "@type": type,
    name: venue.name,
    url: `${SITE_URL}/venue/${venue.city_slug}/${venue.slug}`,
    address: {
      "@type": "PostalAddress",
      streetAddress: venue.address,
      addressLocality: venue.city_display,
      addressCountry: venue.country,
    },
    geo: {
      "@type": "GeoCoordinates",
      latitude: venue.lat,
      longitude: venue.lng,
    },
    ...(venue.phone && { telephone: venue.phone }),
    ...(venue.website && { sameAs: venue.website }),
    ...(venue.reservation_url && {
      potentialAction: {
        "@type": "ReserveAction",
        target: venue.reservation_url,
      },
    }),
    ...(venue.price_tier && { priceRange: venue.price_tier }),
    ...(venue.cuisine_tags.length > 0 && {
      servesCuisine: venue.cuisine_tags,
    }),
    ...(awards.length > 0 && { award: awards }),
    ...(venue.photo_url && { image: venue.photo_url }),
    openingHoursSpecification: buildHoursSpec(venue.hours),
    ...(venue.blurb_long && { description: venue.blurb_long.slice(0, 500) }),
  };
}

/**
 * BreadcrumbList for venue pages. Helps Google understand site hierarchy
 * and shows breadcrumb trails in search results.
 */
export function buildBreadcrumbStructuredData(venue: Venue) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: [
      {
        "@type": "ListItem",
        position: 1,
        name: "Home",
        item: SITE_URL,
      },
      {
        "@type": "ListItem",
        position: 2,
        name: venue.city_display,
        item: `${SITE_URL}/city/${venue.city_slug}`,
      },
      {
        "@type": "ListItem",
        position: 3,
        name: venue.name,
        item: `${SITE_URL}/venue/${venue.city_slug}/${venue.slug}`,
      },
    ],
  };
}
