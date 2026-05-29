// src/routes/venue/$city/$slug.tsx
// ─────────────────────────────────────────────────────────────────────────────
// CompassEats — Static Venue Page
// The canonical, crawlable page for a single venue.
// URL: /venue/[city]/[slug]    e.g.  /venue/tokyo/sushi-saito
//
// Reads from the static data layer (built by scripts/sync-sheet.ts):
//   - getVenue, getCity, getVenuesByCity   ← src/lib/venues.ts
//   - getVenueJsonLd                       ← src/lib/structured-data.ts
//   - AWARD_SOURCES registry               ← src/lib/schema.ts
//
// If accessor signatures in your repo differ slightly from these, just
// rename — the route component itself is the meat.
// ─────────────────────────────────────────────────────────────────────────────

import { createFileRoute, Link, notFound } from '@tanstack/react-router'
import { getVenue, getCity, getVenuesByCity } from '@/lib/venues'
import { getVenueJsonLd } from '@/lib/structured-data'
import { AWARD_SOURCES } from '@/lib/schema'

// ── Route definition ────────────────────────────────────────────────────────
export const Route = createFileRoute('/venue/$city/$slug')({
  loader: ({ params }) => {
    const venue = getVenue(params.city, params.slug)
    if (!venue) throw notFound()
    const city = getCity(params.city)
    const related = getVenuesByCity(params.city)
      .filter((v) => v.slug !== venue.slug && (v.accolades?.length ?? 0) > 0)
      .slice(0, 6)
    return { venue, city, related }
  },
  head: ({ loaderData }) => {
    if (!loaderData) return {}
    const { venue, city } = loaderData
    const cityName = city?.name ?? venue.city
    const title = `${venue.name} — ${cityName} · CompassEats`
    const description = buildMetaDescription(venue, cityName)
    const url = `https://compasseats.com/venue/${cityToSlug(venue.city)}/${venue.slug}`
    return {
      meta: [
        { title },
        { name: 'description', content: description },
        { property: 'og:title', content: title },
        { property: 'og:description', content: description },
        { property: 'og:type', content: 'article' },
        { property: 'og:url', content: url },
        ...(venue.photo_url ? [{ property: 'og:image', content: venue.photo_url }] : []),
        { name: 'twitter:card', content: venue.photo_url ? 'summary_large_image' : 'summary' },
      ],
      links: [{ rel: 'canonical', href: url }],
      scripts: [
        {
          type: 'application/ld+json',
          children: JSON.stringify(getVenueJsonLd(venue, city)),
        },
      ],
    }
  },
  component: VenuePage,
  notFoundComponent: VenueNotFound,
})

// ── Page component ──────────────────────────────────────────────────────────
function VenuePage() {
  const { venue, city, related } = Route.useLoaderData()
  const cityName = city?.name ?? venue.city
  const citySlug = cityToSlug(venue.city)
  const accolades = (venue.accolades ?? []).slice().sort(byAccoladeWeight)

  return (
    <article className="mx-auto max-w-5xl px-6 pb-24 pt-8">
      {/* Breadcrumb */}
      <nav className="mb-8 flex flex-wrap items-center gap-2 text-xs font-medium uppercase tracking-[0.18em] text-accent-strong/80">
        <Link to="/" className="transition-colors hover:text-accent-strong">Home</Link>
        <span className="opacity-50">/</span>
        <Link
          to="/city/$slug"
          params={{ slug: citySlug }}
          className="transition-colors hover:text-accent-strong"
        >
          {cityName}, charted
        </Link>
        <span className="opacity-50">/</span>
        <span className="text-fg normal-case tracking-normal">{venue.name}</span>
      </nav>

      {/* Hero */}
      <header className="grid items-center gap-10 md:grid-cols-[1.1fr_1fr]">
        <div>
          <p className="mb-3 text-xs font-semibold uppercase tracking-[0.32em] text-accent-strong">
            {venue.type === 'bar' ? 'Cocktail Bar' : 'Restaurant'}
            <span className="mx-3 opacity-40">·</span>
            {cityName}{venue.country ? `, ${venue.country}` : ''}
          </p>
          <h1 className="font-display text-5xl font-light leading-[1.02] tracking-tight text-fg md:text-6xl">
            {venue.name}
          </h1>
          {venue.description && (
            <p className="mt-5 max-w-xl font-display text-lg italic leading-relaxed text-fg-dim">
              {venue.description}
            </p>
          )}

          <div className="mt-7 flex flex-wrap gap-3">
            {venue.website && (
              <a
                href={venue.website}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-full bg-primary px-5 py-2.5 text-sm font-semibold text-bg shadow-sm transition-transform hover:-translate-y-0.5"
              >
                Visit website
                <span aria-hidden="true">→</span>
              </a>
            )}
            {venue.lat != null && venue.lng != null && (
              <a
                href={`https://www.google.com/maps/search/?api=1&query=${venue.lat},${venue.lng}`}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-full border border-line px-5 py-2.5 text-sm font-medium text-accent-strong transition-colors hover:border-accent-strong/60"
              >
                Take me there
                <span aria-hidden="true">→</span>
              </a>
            )}
          </div>
        </div>

        {venue.photo_url && (
          <figure className="overflow-hidden rounded-2xl border border-line shadow-2xl">
            <img
              src={venue.photo_url}
              alt={venue.name}
              loading="eager"
              className="aspect-[4/5] w-full object-cover"
            />
          </figure>
        )}
      </header>

      {/* Accolades */}
      {accolades.length > 0 && (
        <section className="mt-16">
          <h2 className="mb-5 text-xs font-semibold uppercase tracking-[0.28em] text-accent-strong">
            Charted by
          </h2>
          <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {accolades.map((a, i) => (
              <li key={`${a.source}-${a.year ?? i}`}>
                <AccoladeCard accolade={a} />
              </li>
            ))}
          </ul>
        </section>
      )}

      {/* Details + location */}
      <section className="mt-16 grid gap-10 md:grid-cols-2">
        <div>
          <h2 className="mb-4 text-xs font-semibold uppercase tracking-[0.28em] text-accent-strong">
            The details
          </h2>
          <dl className="space-y-5">
            <DetailRow label="Address" value={venue.address} />
            <DetailRow
              label="City"
              value={
                <Link
                  to="/city/$slug"
                  params={{ slug: citySlug }}
                  className="text-accent-strong underline-offset-4 hover:underline"
                >
                  {cityName}{venue.country ? `, ${venue.country}` : ''}
                </Link>
              }
            />
            {venue.website && (
              <DetailRow
                label="Website"
                value={
                  <a
                    href={venue.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-accent-strong underline-offset-4 hover:underline"
                  >
                    {prettyUrl(venue.website)}
                  </a>
                }
              />
            )}
          </dl>
        </div>

        {/* Find-your-way card. MapLibre embed can drop in here later; for now,
            a clean coords + action card keeps the design cohesive and avoids
            shipping an off-brand iframe. */}
        {venue.lat != null && venue.lng != null && (
          <aside className="flex flex-col justify-between rounded-2xl border border-line bg-panel/40 p-6">
            <div>
              <h2 className="mb-3 text-xs font-semibold uppercase tracking-[0.28em] text-accent-strong">
                Find your way
              </h2>
              <p className="font-display text-2xl font-light leading-snug text-fg">
                {cityName}, <em className="italic text-accent-strong">charted.</em>
              </p>
              <p className="mt-2 font-mono text-xs tabular-nums text-fg-dimmer">
                {venue.lat.toFixed(4)}, {venue.lng.toFixed(4)}
              </p>
            </div>
            <a
              href={`https://www.google.com/maps/search/?api=1&query=${venue.lat},${venue.lng}`}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-6 inline-flex w-fit items-center gap-2 rounded-full border border-line px-4 py-2 text-sm font-medium text-accent-strong transition-colors hover:border-accent-strong/60"
            >
              Open in Maps
              <span aria-hidden="true">→</span>
            </a>
          </aside>
        )}
      </section>

      {/* Related */}
      {related.length > 0 && (
        <section className="mt-20 border-t border-line pt-12">
          <h2 className="mb-1 font-display text-3xl font-light text-fg">
            More in <em className="italic font-normal text-accent-strong">{cityName}</em>
          </h2>
          <p className="mb-8 text-sm text-fg-dim">Worth the detour, all of them.</p>
          <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {related.map((v) => (
              <li key={v.slug}>
                <RelatedCard venue={v} citySlug={citySlug} />
              </li>
            ))}
          </ul>
        </section>
      )}
    </article>
  )
}

// ── Subcomponents ───────────────────────────────────────────────────────────

function AccoladeCard({ accolade }: { accolade: any }) {
  const meta = AWARD_SOURCES[accolade.source]
  const label = meta?.displayName ?? accolade.source
  return (
    <div className="group relative h-full rounded-xl border border-line bg-panel/40 p-4 transition-colors hover:border-accent-strong/40">
      <div className="flex items-baseline justify-between gap-3">
        <p className="font-display text-base leading-snug text-fg">{label}</p>
        {accolade.year && (
          <span className="shrink-0 text-xs font-medium tabular-nums text-fg-dimmer">
            {accolade.year}
          </span>
        )}
      </div>
      {(accolade.rank || accolade.note) && (
        <p className="mt-2 text-sm text-accent-strong">
          {accolade.rank ? `#${accolade.rank}` : ''}
          {accolade.rank && accolade.note ? ' · ' : ''}
          {accolade.note ?? ''}
        </p>
      )}
    </div>
  )
}

function RelatedCard({ venue, citySlug }: { venue: any; citySlug: string }) {
  const top = venue.accolades?.[0]
  const topLabel = top ? AWARD_SOURCES[top.source]?.displayName ?? top.source : null
  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: citySlug, slug: venue.slug }}
      className="group flex h-full flex-col rounded-xl border border-line bg-panel/40 p-5 transition-all hover:-translate-y-0.5 hover:border-accent-strong/40"
    >
      <p className="font-display text-lg leading-snug text-fg transition-colors group-hover:text-accent-strong">
        {venue.name}
      </p>
      {topLabel && (
        <p className="mt-2 text-xs font-medium uppercase tracking-wider text-accent-strong/80">
          {topLabel}
          {top?.rank ? ` · #${top.rank}` : ''}
        </p>
      )}
    </Link>
  )
}

function DetailRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div>
      <dt className="text-[0.65rem] font-semibold uppercase tracking-[0.22em] text-accent-strong/80">
        {label}
      </dt>
      <dd className="mt-1 text-fg">{value}</dd>
    </div>
  )
}

function VenueNotFound() {
  return (
    <div className="mx-auto max-w-xl px-6 py-32 text-center">
      <p className="mb-3 text-xs font-semibold uppercase tracking-[0.32em] text-accent-strong">
        404
      </p>
      <h1 className="font-display text-4xl font-light text-fg">
        We haven't charted this one yet.
      </h1>
      <p className="mt-4 text-fg-dim">
        Try a nearby city — we've mapped the best tables in many of them, and we're roaming further every week.
      </p>
      <Link
        to="/"
        className="mt-8 inline-flex rounded-full bg-primary px-5 py-2.5 text-sm font-semibold text-bg"
      >
        Find your bearings →
      </Link>
    </div>
  )
}

// ── Helpers ─────────────────────────────────────────────────────────────────

function buildMetaDescription(venue: any, cityName: string): string {
  const top = venue.accolades?.[0]
  if (top) {
    const label = AWARD_SOURCES[top.source]?.displayName ?? top.source
    const rankBit = top.rank ? ` (#${top.rank})` : ''
    const yearBit = top.year ? `, ${top.year}` : ''
    return `${venue.name} in ${cityName} — charted on ${label}${rankBit}${yearBit}. The world's best, wherever you are.`
  }
  return `${venue.name} in ${cityName} — charted on CompassEats. The world's best, wherever you are.`
}

function byAccoladeWeight(a: any, b: any) {
  const wa = AWARD_SOURCES[a.source]?.weight ?? 0
  const wb = AWARD_SOURCES[b.source]?.weight ?? 0
  return wb - wa
}

function cityToSlug(city: string): string {
  return city.toLowerCase().normalize('NFKD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '')
}

function prettyUrl(url: string): string {
  try {
    return new URL(url).hostname.replace(/^www\./, '')
  } catch {
    return url
  }
}
