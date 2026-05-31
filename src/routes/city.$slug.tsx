// src/routes/city/$slug.tsx
// ─────────────────────────────────────────────────────────────────────────────
// CompassEats — Static City Page
// The canonical page for a city: hero, map at the city centroid, filterable
// list of every charted venue, and a small "nearby cities" footer.
//
// URL: /city/[slug]   e.g.  /city/tokyo
//
// Reads from the static data layer (built by scripts/sync-sheet.ts):
//   - getCity, getVenuesByCity, getNearestCities  ← src/lib/venues.ts
//   - AWARD_SOURCES registry                       ← src/lib/schema.ts
//
// If `getNearestCities` doesn't exist in your repo, the Nearby block falls
// back gracefully — just remove the import and the <NearbyCities /> render.
// ─────────────────────────────────────────────────────────────────────────────

import { createFileRoute, Link, notFound } from '@tanstack/react-router'
import { useEffect, useMemo, useRef, useState } from 'react'
import { getCity, getVenuesByCity, getNearestCities } from '~/lib/venues'
import { AWARD_SOURCES } from '~/lib/schema'

// ── Route definition ────────────────────────────────────────────────────────
export const Route = createFileRoute('/city/$slug')({
  loader: ({ params }) => {
    const city = getCity(params.slug)
    if (!city) throw notFound()
    const venues = getVenuesByCity(params.slug)
      .filter((v) => (v.accolades?.length ?? 0) > 0)
      .sort(byAccoladePrestige)
    const nearby = getNearestCities ? getNearestCities(params.slug, 6) : []
    return { city, venues, nearby }
  },
  head: ({ loaderData }) => {
    if (!loaderData) return {}
    const { city, venues } = loaderData
    const title = `${city.name}, charted — ${venues.length} of the world's best · CompassEats`
    const description = buildMetaDescription(city, venues)
    const url = `https://compasseats.com/city/${city.slug}`
    return {
      meta: [
        { title },
        { name: 'description', content: description },
        { property: 'og:title', content: title },
        { property: 'og:description', content: description },
        { property: 'og:type', content: 'article' },
        { property: 'og:url', content: url },
        ...(city.hero_image_url ? [{ property: 'og:image', content: city.hero_image_url }] : []),
        { name: 'twitter:card', content: city.hero_image_url ? 'summary_large_image' : 'summary' },
      ],
      links: [{ rel: 'canonical', href: url }],
      scripts: [
        {
          type: 'application/ld+json',
          children: JSON.stringify(buildCityJsonLd(city, venues)),
        },
      ],
    }
  },
  component: CityPage,
  notFoundComponent: CityNotFound,
})

// ── Page ────────────────────────────────────────────────────────────────────
function CityPage() {
  const { city, venues, nearby } = Route.useLoaderData()
  const [filter, setFilter] = useState<'all' | 'restaurants' | 'bars'>('all')

  const counts = useMemo(
    () => ({
      all: venues.length,
      restaurants: venues.filter((v) => v.type === 'restaurant').length,
      bars: venues.filter((v) => v.type === 'bar').length,
    }),
    [venues],
  )

  const filtered = useMemo(() => {
    if (filter === 'all') return venues
    const want = filter === 'bars' ? 'bar' : 'restaurant'
    return venues.filter((v) => v.type === want)
  }, [filter, venues])

  const sourceCount = useMemo(() => {
    const sources = new Set<string>()
    venues.forEach((v) =>
      v.accolades?.forEach((a: any) => a?.source && sources.add(a.source)),
    )
    return sources.size
  }, [venues])

  return (
    <article className="mx-auto max-w-6xl px-6 pb-24 pt-8">
      {/* Breadcrumb */}
      <nav className="mb-8 flex flex-wrap items-center gap-2 text-xs font-medium uppercase tracking-[0.18em] text-accent-strong/80">
        <Link to="/" className="transition-colors hover:text-accent-strong">Home</Link>
        <span className="opacity-50">/</span>
        <span className="text-fg normal-case tracking-normal">{city.name}, charted</span>
      </nav>

      {/* Hero */}
      <header
        className={`relative overflow-hidden rounded-3xl border border-line ${
          city.hero_image_url ? 'min-h-[360px]' : 'p-10 md:p-12'
        }`}
      >
        {city.hero_image_url && (
          <>
            <img
              src={city.hero_image_url}
              alt={city.name}
              loading="eager"
              className="absolute inset-0 h-full w-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-bg via-bg/60 to-bg/10" />
          </>
        )}
        <div className={`relative ${city.hero_image_url ? 'p-10 pt-32 md:p-14 md:pt-44' : ''}`}>
          <p className="mb-3 text-xs font-semibold uppercase tracking-[0.32em] text-accent-strong">
            {city.country ?? ''}
          </p>
          <h1 className="font-display text-5xl font-light leading-[1.02] tracking-tight text-fg md:text-7xl">
            {city.name}, <em className="italic text-accent-strong">charted.</em>
          </h1>
          {city.blurb && (
            <p className="mt-5 max-w-2xl font-display text-lg italic leading-relaxed text-fg-dim md:text-xl">
              {city.blurb}
            </p>
          )}
        </div>
      </header>

      {/* Stats strip */}
      <section className="mt-8 grid grid-cols-2 gap-3 md:grid-cols-4">
        <Stat label="Charted spots" value={venues.length} />
        <Stat label="Restaurants" value={counts.restaurants} />
        <Stat label="Cocktail bars" value={counts.bars} />
        <Stat label="Award sources" value={sourceCount} />
      </section>

      {/* Map */}
      {city.lat != null && city.lng != null && (
        <section className="mt-12">
          <h2 className="mb-4 text-xs font-semibold uppercase tracking-[0.28em] text-accent-strong">
            On the map
          </h2>
          <CityMap
            center={{ lat: city.lat, lng: city.lng }}
            venues={venues}
            cityName={city.name}
          />
        </section>
      )}

      {/* Filter + grid */}
      <section className="mt-16">
        <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
          <h2 className="font-display text-3xl font-light text-fg md:text-4xl">
            The list
          </h2>
          <FilterPills value={filter} onChange={setFilter} counts={counts} />
        </div>

        {filtered.length === 0 ? (
          <p className="rounded-2xl border border-line bg-panel/40 p-8 text-center text-fg-dim">
            We haven't charted any {filter === 'bars' ? 'bars' : 'restaurants'} here yet.
          </p>
        ) : (
          <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {filtered.map((v) => (
              <li key={v.slug}>
                <VenueCard venue={v} citySlug={city.slug} />
              </li>
            ))}
          </ul>
        )}
      </section>

      {/* Nearby */}
      {nearby && nearby.length > 0 && (
        <section className="mt-20 border-t border-line pt-12">
          <h2 className="mb-1 font-display text-3xl font-light text-fg">
            Wherever you land — <em className="italic text-accent-strong">nearby</em>
          </h2>
          <p className="mb-8 text-sm text-fg-dim">A few more places worth pointing you to.</p>
          <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {nearby.map((c: any) => (
              <li key={c.slug}>
                <NearbyCityCard city={c} />
              </li>
            ))}
          </ul>
        </section>
      )}
    </article>
  )
}

// ── Subcomponents ───────────────────────────────────────────────────────────

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-2xl border border-line bg-panel/40 px-5 py-4">
      <p className="font-display text-3xl font-light tabular-nums text-fg">
        {value.toLocaleString()}
      </p>
      <p className="mt-1 text-[0.62rem] font-semibold uppercase tracking-[0.22em] text-accent-strong/80">
        {label}
      </p>
    </div>
  )
}

function FilterPills({
  value,
  onChange,
  counts,
}: {
  value: 'all' | 'restaurants' | 'bars'
  onChange: (v: 'all' | 'restaurants' | 'bars') => void
  counts: { all: number; restaurants: number; bars: number }
}) {
  const items: Array<{ key: 'all' | 'restaurants' | 'bars'; label: string }> = [
    { key: 'all', label: 'All' },
    { key: 'restaurants', label: 'Restaurants' },
    { key: 'bars', label: 'Bars' },
  ]
  return (
    <div role="tablist" className="flex flex-wrap gap-2">
      {items.map((it) => {
        const active = value === it.key
        return (
          <button
            key={it.key}
            role="tab"
            aria-selected={active}
            onClick={() => onChange(it.key)}
            className={`inline-flex items-center gap-2 rounded-full border px-4 py-2 text-sm font-medium transition-colors ${
              active
                ? 'border-primary bg-primary text-bg'
                : 'border-line text-fg-dim hover:border-accent-strong/40 hover:text-accent-strong'
            }`}
          >
            <span>{it.label}</span>
            <span
              className={`text-[0.65rem] tabular-nums ${
                active ? 'text-bg/70' : 'text-fg-dimmer'
              }`}
            >
              {counts[it.key]}
            </span>
          </button>
        )
      })}
    </div>
  )
}

function VenueCard({ venue, citySlug }: { venue: any; citySlug: string }) {
  const top = venue.accolades?.[0]
  const topLabel = top
    ? AWARD_SOURCES[top.source]?.displayName ?? top.source
    : null
  const extraAccolades = (venue.accolades?.length ?? 0) - 1

  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: citySlug, slug: venue.slug }}
      className="group flex h-full flex-col rounded-xl border border-line bg-panel/40 p-5 transition-all hover:-translate-y-0.5 hover:border-accent-strong/40"
    >
      <div className="mb-2 flex items-center gap-2 text-[0.62rem] font-semibold uppercase tracking-[0.2em] text-accent-strong/70">
        <span>{venue.type === 'bar' ? 'Bar' : 'Restaurant'}</span>
        {venue.neighborhood && (
          <>
            <span className="opacity-40">·</span>
            <span className="normal-case tracking-normal text-fg-dimmer">
              {venue.neighborhood}
            </span>
          </>
        )}
      </div>
      <p className="font-display text-xl leading-snug text-fg transition-colors group-hover:text-accent-strong">
        {venue.name}
      </p>
      {topLabel && (
        <p className="mt-3 text-xs font-medium uppercase tracking-wider text-accent-strong/80">
          {topLabel}
          {top?.rank ? ` · #${top.rank}` : ''}
          {extraAccolades > 0 ? (
            <span className="text-fg-dimmer"> +{extraAccolades} more</span>
          ) : null}
        </p>
      )}
    </Link>
  )
}

function NearbyCityCard({ city }: { city: any }) {
  return (
    <Link
      to="/city/$slug"
      params={{ slug: city.slug }}
      className="group flex items-baseline justify-between gap-4 rounded-xl border border-line bg-panel/40 p-4 transition-colors hover:border-accent-strong/40"
    >
      <span className="font-display text-lg text-fg group-hover:text-accent-strong">
        {city.name}
      </span>
      <span className="text-xs tabular-nums text-fg-dimmer">
        {city.distance_km ? `${Math.round(city.distance_km)} km` : ''}
      </span>
    </Link>
  )
}

function CityNotFound() {
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

// ── Map (MapLibre, lazy-init client-side) ───────────────────────────────────
// If your repo already has a shared <Map /> component from the cost-cutting
// sprint, swap this with that — same props (center, venues). This inline
// version is a working fallback that doesn't depend on any shared file.

function CityMap({
  center,
  venues,
  cityName,
}: {
  center: { lat: number; lng: number }
  venues: any[]
  cityName: string
}) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!containerRef.current) return
    let cancelled = false
    let map: any = null

    ;(async () => {
      const maplibre = await import('maplibre-gl')
      // Optional CSS import — Vite/TanStack will hoist this.
      // If your build complains, move this import to your root layout.
      await import('maplibre-gl/dist/maplibre-gl.css' as any).catch(() => {})

      if (cancelled || !containerRef.current) return

      map = new maplibre.Map({
        container: containerRef.current,
        style:
          (import.meta as any).env?.VITE_MAPTILER_STYLE_URL ??
          'https://demotiles.maplibre.org/style.json',
        center: [center.lng, center.lat],
        zoom: 11.2,
        attributionControl: true,
      })

      map.on('load', () => {
        // Brass compass-needle pins
        const features = venues
          .filter((v) => v.lat != null && v.lng != null)
          .map((v) => ({
            type: 'Feature' as const,
            geometry: { type: 'Point' as const, coordinates: [v.lng, v.lat] },
            properties: { name: v.name, slug: v.slug, type: v.type },
          }))

        map.addSource('venues', {
          type: 'geojson',
          data: { type: 'FeatureCollection', features },
          cluster: true,
          clusterRadius: 38,
          clusterMaxZoom: 14,
        })

        // Cluster bubbles
        map.addLayer({
          id: 'clusters',
          type: 'circle',
          source: 'venues',
          filter: ['has', 'point_count'],
          paint: {
            'circle-color': '#C6A15B',
            'circle-opacity': 0.85,
            'circle-stroke-color': '#23211E',
            'circle-stroke-width': 2,
            'circle-radius': [
              'step',
              ['get', 'point_count'],
              16,
              10,
              22,
              50,
              28,
            ],
          },
        })
        map.addLayer({
          id: 'cluster-count',
          type: 'symbol',
          source: 'venues',
          filter: ['has', 'point_count'],
          layout: {
            'text-field': '{point_count_abbreviated}',
            'text-size': 12,
            'text-font': ['Noto Sans Regular'],
          },
          paint: { 'text-color': '#23211E' },
        })

        // Single venues — small brass dots
        map.addLayer({
          id: 'venue-dot',
          type: 'circle',
          source: 'venues',
          filter: ['!', ['has', 'point_count']],
          paint: {
            'circle-color': '#C6A15B',
            'circle-radius': 6,
            'circle-stroke-color': '#23211E',
            'circle-stroke-width': 1.5,
          },
        })

        // Click → navigate to venue
        map.on('click', 'venue-dot', (e: any) => {
          const f = e.features?.[0]
          if (!f) return
          const slug = f.properties.slug
          // Use a full navigation — keeps the route's data loader behavior
          window.location.href = `/venue/${slugFromCityName(cityName)}/${slug}`
        })
        map.on('mouseenter', 'venue-dot', () => {
          map.getCanvas().style.cursor = 'pointer'
        })
        map.on('mouseleave', 'venue-dot', () => {
          map.getCanvas().style.cursor = ''
        })

        // Click on a cluster → zoom in
        map.on('click', 'clusters', (e: any) => {
          const f = map.queryRenderedFeatures(e.point, { layers: ['clusters'] })[0]
          const id = f.properties.cluster_id
          map.getSource('venues').getClusterExpansionZoom(id, (err: any, zoom: number) => {
            if (err) return
            map.easeTo({ center: f.geometry.coordinates, zoom })
          })
        })
      })
    })()

    return () => {
      cancelled = true
      if (map) map.remove()
    }
  }, [center.lat, center.lng, venues, cityName])

  return (
    <div
      ref={containerRef}
      className="h-[420px] w-full overflow-hidden rounded-2xl border border-line shadow-2xl"
      aria-label={`Map of charted venues in ${cityName}`}
    />
  )
}

// ── Helpers ─────────────────────────────────────────────────────────────────

function byAccoladePrestige(a: any, b: any) {
  const wa = topAccoladeWeight(a)
  const wb = topAccoladeWeight(b)
  if (wb !== wa) return wb - wa
  return (b.accolades?.length ?? 0) - (a.accolades?.length ?? 0)
}

function topAccoladeWeight(v: any) {
  return (v.accolades ?? []).reduce((max: number, a: any) => {
    const w = AWARD_SOURCES[a?.source]?.weight ?? 0
    return w > max ? w : max
  }, 0)
}

function buildMetaDescription(city: any, venues: any[]) {
  const r = venues.filter((v) => v.type === 'restaurant').length
  const b = venues.filter((v) => v.type === 'bar').length
  const parts: string[] = []
  if (r) parts.push(`${r} restaurant${r === 1 ? '' : 's'}`)
  if (b) parts.push(`${b} bar${b === 1 ? '' : 's'}`)
  const list = parts.join(' and ')
  return `${city.name}, charted — ${list} chosen by the guides that matter, from Michelin to World's 50 Best. The world's best, wherever you are.`
}

function buildCityJsonLd(city: any, venues: any[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    name: `${city.name}, charted`,
    description: `Top restaurants and cocktail bars in ${city.name}, ranked from authoritative guides.`,
    url: `https://compasseats.com/city/${city.slug}`,
    mainEntity: {
      '@type': 'ItemList',
      numberOfItems: venues.length,
      itemListElement: venues.slice(0, 50).map((v, i) => ({
        '@type': 'ListItem',
        position: i + 1,
        url: `https://compasseats.com/venue/${city.slug}/${v.slug}`,
        name: v.name,
      })),
    },
  }
}

function slugFromCityName(name: string) {
  return name
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')
}
