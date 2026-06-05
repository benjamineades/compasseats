/**
 * Award display helpers.
 *
 * Turns a typed Award ({source, year, category, rank?}) into a human label
 * for badges, listing rows, venue pages, and map popups. Centralised here so
 * the phrasing stays consistent everywhere — change it once, change it
 * everywhere.
 */

import type { Award } from "./schema";
import { getAwardSource } from "./venues";

/**
 * Short-form names for tight spaces (listing rows, map popups). Falls back
 * to the source's full display name when no override is registered.
 */
const SHORT_NAME_BY_SLUG: Record<string, string> = {
  "worlds-50-best-restaurants": "World's 50 Best",
  "worlds-50-best-restaurants-51-100": "World's 50 Best (51–100)",
  "worlds-50-best-bars": "50 Best Bars",
  "worlds-50-best-bars-51-100": "50 Best Bars (51–100)",
  "north-america-50-best-bars": "N.A. 50 Best Bars",
  "north-america-50-best-bars-51-100": "N.A. 50 Best Bars (51–100)",
  "asia-50-best-bars": "Asia 50 Best Bars",
  "asia-50-best-bars-51-100": "Asia 50 Best Bars (51–100)",
  "north-america-50-best-restaurants": "N.A. 50 Best",
  "asia-50-best-restaurants": "Asia 50 Best",
  "asia-50-best-restaurants-51-100": "Asia 50 Best (51–100)",
  "latin-america-50-best-restaurants": "Latin America 50 Best",
  "mena-50-best-restaurants": "MENA 50 Best",
  "africa-50-best-restaurants": "Africa 50 Best",
  "101-best-steakhouses": "101 Best Steakhouses",
  "forbes-travel-guide": "Forbes Travel",
  "james-beard": "James Beard",
  "best-chef-awards": "Best Chef",
  "spirited-awards": "Spirited Awards",
  "pinnacle-guide": "Pinnacle Guide",
  "gault-millau": "Gault & Millau",
  "la-liste": "La Liste",
  michelin: "Michelin",
  oad: "OAD",
  tabelog: "Tabelog",
};

function sourceName(slug: string): string {
  return getAwardSource(slug)?.name ?? slug;
}

function sourceNameShort(slug: string): string {
  return SHORT_NAME_BY_SLUG[slug] ?? sourceName(slug);
}

function compose(award: Award, name: string): string {
  // Ranked entries: lead with the rank.
  if (typeof award.rank === "number" && award.rank > 0) {
    return `No. ${award.rank} · ${name}`;
  }

  // Michelin: category carries the meaning ("Three Stars", "Bib Gourmand").
  // Append " · Michelin" so the badge still attributes the source.
  if (award.source === "michelin") {
    return `${award.category} · ${name}`;
  }

  // Everything else: "{category} · {source}".
  return `${award.category} · ${name}`;
}

function trim(label: string, max = 56): string {
  if (label.length <= max) return label;
  return label.slice(0, max - 1).trimEnd() + "…";
}

export function awardLabel(award: Award): string {
  return trim(compose(award, sourceName(award.source)));
}

export function awardLabelShort(award: Award): string {
  return trim(compose(award, sourceNameShort(award.source)), 40);
}