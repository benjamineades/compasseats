// src/routes/city/$slug.tsx
// ─────────────────────────────────────────────────────────────────────────────
// CompassEats — Static City Page
// ─────────────────────────────────────────────────────────────────────────────

import { createFileRoute, Link, notFound } from '@tanstack/react-router'
import { useEffect, useMemo, useRef, useState } from 'react'
import { getCity, getVenuesByCity } from '@/lib/venues'
import { AWARD_SOURCES } from '@/lib/schema'

// ── Route definition ────────────────────────────────────────────────────────
export const Route = createFileRoute('/city/$slug')({
  loader: ({ params }) => {
    const city = getCity(params.slug)
    if (!city) throw notFound()
    const venues = getVenuesByCity(params.slug)
      .filter((v: any) => (v.accolades?.length ?? 0) > 0)
      .sort(byAccoladePrestige)
    return { city, venues }
  },
  head: ({ loaderData }) => {
    if (!loaderData) return {}
    const { city, venues } = loaderData as { city: any; venues: any[] }
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
  const { city, venues } = Route.useLoaderData() as { city: any; venues: any[] }
  const [filter, setFilter] = useState<'all' | 'restaurants' | 'bars'>('all')

  const counts = useMemo(
    () => ({
      all: venues.length,
      restaurants: venues.filter((v: any) => v.type === 'restaurant').length,
      bars: venues.filter((v: any) => v.type === 'bar').length,
    }),
    [venues],
  )

  const filtered = useMemo(() => {
    if (filter === 'all') return venues
    const want = filter === 'bars' ? 'bar' : 'restaurant'
    return venues.filter((v: any) => v.type === want)
  }, [filter, venues])

  const sourceCount = useMemo(() => {
    const sources = new Set()
    venues.forEach((v: any) =>
      v.accolades?.forEach((a: any) => a?.source && sources.add(a.source)),
    )
    return sources.size
  }, [venues])

  return (
    <div>
      {/* Breadcrumb */}
      <div>
        <Link to="/">Home</Link>
        <span>/</span>
        <span>{city.name}, charted</span>
      </div>

      {/* Hero */}
      <div>
        {city.hero_image_url && (
          <>
            <img src={city.hero_image_url} alt={city.name} />
          </>
        )}
        <div>
          <div>{city.country ?? ''}</div>
          <h1>{city.name}, charted.</h1>
          {city.blurb && <p>{city.blurb}</p>}
        </div>
      </div>

      {/* Stats strip */}
      <div>
        <Stat label="Venues" value={counts.all} />
        <Stat label="Restaurants" value={counts.restaurants} />
        <Stat label="Bars" value={counts.bars} />
        <Stat label="Sources" value={sourceCount} />
      </div>

      {/* Map */}
      {city.lat != null && city.lng != null && (
        <div>
          <h2>On the map</h2>
          <CityMap center={{ lat: city.lat, lng: city.lng }} venues={venues} cityName={city.name} />
        </div>
      )}

      {/* Filter + grid */}
      <div>
        <div>
          <h2>The list</h2>
          <FilterPills value={filter} onChange={setFilter} counts={counts} />
        </div>

        {filtered.length === 0 ? (
          <p>We haven't charted any {filter === 'bars' ? 'bars' : 'restaurants'} here yet.</p>
        ) : (
          <div>
            {filtered.map((v: any) => (
              <VenueCard key={v.slug} venue={v} citySlug={city.slug} />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

// ── Subcomponents ───────────────────────────────────────────────────────────

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div>
      <div>{value.toLocaleString()}</div>
      <div>{label}</div>
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
    <div>
      {items.map((it) => {
        const active = value === it.key
        return (
          <button
            key={it.key}
            onClick={() => onChange(it.key)}
            className={`inline-flex items-center gap-2 rounded-full border px-4 py-2 text-sm font-medium transition-colors ${
              active
                ? 'border-primary bg-primary text-bg'
                : 'border-line text-fg-dim hover:border-accent-strong/40 hover:text-accent-strong'
            }`}
          >
            {it.label}
            <span>{counts[it.key]}</span>
          </button>
        )
      })}
    </div>
  )
}

function VenueCard({ venue, citySlug }: { venue: any; citySlug: string }) {
  const top = venue.accolades?.[0]
  const topLabel = top
    ? (AWARD_SOURCES as any)[top.source]?.displayName ?? top.source
    : null
  const extraAccolades = (venue.accolades?.length ?? 0) - 1

  return (
    <Link to="/venue/$city/$slug" params={{ city: citySlug, slug: venue.slug }}>
      <div>
        <span>{venue.type === 'bar' ? 'Bar' : 'Restaurant'}</span>
        {venue.neighborhood && (
          <>
            <span>·</span>
            <span>{venue.neighborhood}</span>
          </>
        )}
      </div>
      <div>{venue.name}</div>
      {topLabel && (
        <div>
          {topLabel}
          {top?.rank ? ` · #${top.rank}` : ''}
          {extraAccolades > 0 ? <span> +{extraAccolades} more</span> : null}
        </div>
      )}
    </Link>
  )
}

function CityNotFound() {
  return (
    <div>
      <div>404</div>
      <h1>We haven't charted this one yet.</h1>
      <p>Try a nearby city — we've mapped the best tables in many of them, and we're roaming further every week.</p>
      <Link to="/">Find your bearings →</Link>
    </div>
  )
}

// ── Map (MapLibre, lazy-init client-side) ───────────────────────────────────

function CityMap({
  center,
  venues,
  cityName,
}: {
  center: { lat: number; lng: number }
  venues: any[]
  cityName: string
}) {
  const containerRef = useRef<HTMLDivElement | null>(null)

  useEffect(() => {
    if (!containerRef.current) return
    let cancelled = false
    let map: any = null

    ;(async () => {
      const maplibre = await import('maplibre-gl')
      await import('maplibre-gl/dist/maplibre-gl.css' as any).catch(() => {})

      if (cancelled || !containerRef.current) return

      map = new maplibre.Map({
        container: containerRef.current,
        style:
          (import.meta as any).env?.VITE_MAPTILER_STYLE_URL ??
          'https://demotiles.maplibre.org/style.json',
        center: [center.lng, center.lat],
        zoom: 11.2,
      })

      map.on('load', () => {
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
            'circle-radius': ['step', ['get', 'point_count'], 16, 10, 22, 50, 28],
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

        map.on('click', 'venue-dot', (e: any) => {
          const f = e.features?.[0]
          if (!f) return
          const slug = f.properties.slug
          window.location.href = `/venue/${slugFromCityName(cityName)}/${slug}`
        })
        map.on('mouseenter', 'venue-dot', () => {
          map.getCanvas().style.cursor = 'pointer'
        })
        map.on('mouseleave', 'venue-dot', () => {
          map.getCanvas().style.cursor = ''
        })

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

  return <div ref={containerRef} style={{ width: '100%', height: 420 }} />
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
    const w = (AWARD_SOURCES as any)[a?.source]?.weight ?? 0
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