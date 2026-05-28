import { useEffect, useRef } from "react";
import maplibregl from "maplibre-gl";

export type Pin = {
  index: number;
  name: string;
  category: "restaurant" | "cocktail bar";
  lat: number;
  lng: number;
  accolade?: string;
  anchorId?: string;
  awards?: string[];
  citySlug?: string;
  slug?: string;
};

export const PIN_COLORS = {
  restaurant: "#C6A15B", // brass
  bar: "#C6A15B",
};

const MAPTILER_KEY = import.meta.env.VITE_MAPTILER_KEY as string | undefined;

if (import.meta.env.DEV && !MAPTILER_KEY) {
  throw new Error(
    "VITE_MAPTILER_KEY is missing. Add it to your .env to render the map.",
  );
}

const styleUrl = (dark: boolean) =>
  `https://api.maptiler.com/maps/dataviz-${dark ? "dark" : "light"}/style.json?key=${MAPTILER_KEY}`;

const THEME = {
  light: {
    background: "#F7F3EB",
    water: "#E1DACB",
    land: "#EFE7D5",
    road: "#D5B79A",
    text: "#895F2E",
    halo: "#F7F3EB",
    clusterStroke: "rgba(247,243,235,0.4)",
    pinBorder: "rgba(247,243,235,0.5)",
  },
  dark: {
    background: "#23211E",
    water: "#1A1815",
    land: "#2A2823",
    road: "#3A352D",
    text: "#C6A15B",
    halo: "#23211E",
    clusterStroke: "rgba(35,33,30,0.5)",
    pinBorder: "rgba(35,33,30,0.6)",
  },
};

function isDarkMode() {
  if (typeof document === "undefined") return true;
  return document.documentElement.classList.contains("dark");
}

const COMPASS_SVG = `<svg viewBox="0 0 24 24" fill="none" width="12" height="12">
  <path d="M12 3 L17 14 L12 17 L7 14 Z" fill="white"/>
  <path d="M12 21 L7 14 L12 11 L17 14 Z" fill="white" opacity="0.35"/>
  <circle cx="12" cy="14" r="1.5" fill="#23211E"/>
</svg>`;

type GeoFeature = {
  type: "Feature";
  geometry: { type: "Point"; coordinates: [number, number] };
  properties: Record<string, unknown>;
};

function toGeoJSON(pins: Pin[]) {
  return {
    type: "FeatureCollection" as const,
    features: pins.map((p, i) => ({
      type: "Feature" as const,
      geometry: { type: "Point" as const, coordinates: [p.lng, p.lat] as [number, number] },
      properties: {
        id: i,
        name: p.name,
        category: p.category,
        accolade: p.accolade ?? "",
        anchorId: p.anchorId ?? "",
        awards: JSON.stringify(p.awards ?? []),
        citySlug: p.citySlug ?? "",
        slug: p.slug ?? "",
      },
    })),
  };
}

const SOURCE_ID = "venues";
const UNCLUSTERED_LAYER = "venue-points";

export function VenueMap({
  center,
  pins,
}: {
  center: [number, number];
  pins: Pin[];
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);
  const markersRef = useRef<Map<number, maplibregl.Marker>>(new Map());
  const popupRef = useRef<maplibregl.Popup | null>(null);
  const pinsRef = useRef<Pin[]>(pins);
  const centerRef = useRef<[number, number]>(center);
  pinsRef.current = pins;
  centerRef.current = center;

  // Apply brand-warm paint overrides to the active style.
  const applyBrandOverrides = (map: maplibregl.Map) => {
    const t = isDarkMode() ? THEME.dark : THEME.light;
    const layers = map.getStyle()?.layers ?? [];
    for (const layer of layers) {
      const id = layer.id.toLowerCase();
      const type = layer.type;
      const set = (prop: string, value: unknown) => {
        try {
          map.setPaintProperty(layer.id, prop as never, value as never);
        } catch {
          /* swallow */
        }
      };
      try {
        if (type === "background") set("background-color", t.background);
        else if (id.includes("water")) set("fill-color", t.water);
        else if (id.includes("landcover") || id.includes("park") || id.includes("landuse"))
          set("fill-color", t.land);
        else if (type === "line" && (id.includes("road") || id.includes("transportation"))) {
          set("line-color", t.road);
          set("line-opacity", 0.5);
        } else if (type === "symbol") {
          set("text-color", t.text);
          set("text-halo-color", t.halo);
          set("text-halo-width", 1.5);
        }
      } catch {
        /* swallow */
      }
    }
  };

  const addPinLayers = (map: maplibregl.Map) => {
    const t = isDarkMode() ? THEME.dark : THEME.light;
    if (!map.getSource(SOURCE_ID)) {
      map.addSource(SOURCE_ID, {
        type: "geojson",
        data: toGeoJSON(pinsRef.current),
        cluster: true,
        clusterMaxZoom: 13,
        clusterRadius: 50,
      });
    } else {
      (map.getSource(SOURCE_ID) as maplibregl.GeoJSONSource).setData(
        toGeoJSON(pinsRef.current) as never,
      );
    }

    if (!map.getLayer("clusters")) {
      map.addLayer({
        id: "clusters",
        type: "circle",
        source: SOURCE_ID,
        filter: ["has", "point_count"],
        paint: {
          "circle-color": "#C6A15B",
          "circle-radius": ["step", ["get", "point_count"], 22, 10, 28, 50, 34],
          "circle-stroke-width": 2,
          "circle-stroke-color": t.clusterStroke,
        },
      });
    } else {
      map.setPaintProperty("clusters", "circle-stroke-color", t.clusterStroke);
    }

    if (!map.getLayer("cluster-count")) {
      map.addLayer({
        id: "cluster-count",
        type: "symbol",
        source: SOURCE_ID,
        filter: ["has", "point_count"],
        layout: {
          "text-field": ["get", "point_count_abbreviated"],
          "text-font": ["Open Sans Bold", "Noto Sans Bold"],
          "text-size": 13,
        },
        paint: { "text-color": "#23211E" },
      });
    }

    // Invisible circle layer for unclustered points (used for queryRenderedFeatures).
    if (!map.getLayer(UNCLUSTERED_LAYER)) {
      map.addLayer({
        id: UNCLUSTERED_LAYER,
        type: "circle",
        source: SOURCE_ID,
        filter: ["!", ["has", "point_count"]],
        paint: { "circle-radius": 1, "circle-opacity": 0 },
      });
    }

    syncMarkers(map);
  };

  // Create/update HTML markers for unclustered (visible) points.
  const syncMarkers = (map: maplibregl.Map) => {
    if (!map.getLayer(UNCLUSTERED_LAYER)) return;
    const features = map.queryRenderedFeatures({ layers: [UNCLUSTERED_LAYER] });
    const t = isDarkMode() ? THEME.dark : THEME.light;
    const seen = new Set<number>();

    for (const f of features as unknown as GeoFeature[]) {
      const id = Number(f.properties.id);
      if (Number.isNaN(id) || seen.has(id)) continue;
      seen.add(id);
      if (markersRef.current.has(id)) continue;

      const el = document.createElement("div");
      el.style.cssText = [
        "width:30px",
        "height:30px",
        "border-radius:50%",
        "background:#C6A15B",
        `border:2px solid ${t.pinBorder}`,
        "display:flex",
        "align-items:center",
        "justify-content:center",
        "box-shadow:0 2px 6px rgba(0,0,0,0.25)",
        "cursor:pointer",
        "transition:transform 150ms ease",
      ].join(";");
      el.innerHTML = COMPASS_SVG;
      el.addEventListener("mouseenter", () => (el.style.transform = "scale(1.12)"));
      el.addEventListener("mouseleave", () => (el.style.transform = "scale(1)"));
      el.addEventListener("click", (e) => {
        e.stopPropagation();
        openPopup(map, f);
      });

      const marker = new maplibregl.Marker({ element: el, anchor: "center" })
        .setLngLat(f.geometry.coordinates)
        .addTo(map);
      markersRef.current.set(id, marker);
    }

    // Remove markers that are no longer visible/unclustered.
    for (const [id, marker] of markersRef.current) {
      if (!seen.has(id)) {
        marker.remove();
        markersRef.current.delete(id);
      }
    }
  };

  const openPopup = (map: maplibregl.Map, f: GeoFeature) => {
    popupRef.current?.remove();
    const p = f.properties;
    let awards: string[] = [];
    try {
      awards = JSON.parse(String(p.awards || "[]"));
    } catch {
      /* ignore */
    }
    const accolade = String(p.accolade || "");
    const subtitle =
      awards.length > 1 ? "Multiple awards" : awards[0] || accolade || "";
    const badges = awards
      .slice(0, 3)
      .map(
        (a) =>
          `<span style="display:inline-block;border:1px solid var(--border);border-radius:999px;padding:2px 8px;font-size:0.7rem;letter-spacing:0.05em;text-transform:uppercase;color:var(--accent-strong)">${a}</span>`,
      )
      .join(" ");
    const citySlug = String(p.citySlug || "");
    const slug = String(p.slug || "");
    const anchorId = String(p.anchorId || "");
    const href = slug && citySlug ? `/venue/${citySlug}/${slug}` : anchorId ? `#${anchorId}` : "";
    const link = href
      ? `<a href="${href}" ${anchorId && !slug ? `data-anchor="${anchorId}"` : ""} style="display:inline-block;margin-top:10px;font-size:0.8rem;color:var(--accent-strong);text-decoration:none;font-weight:500">View details →</a>`
      : "";

    const html = `<div style="font-family:var(--font-serif);max-width:260px">
      <div style="font-family:'Fraunces',serif;font-weight:400;font-size:1.05rem;color:hsl(var(--foreground,0 0% 0%));color:var(--foreground)">${String(p.name || "")}</div>
      ${subtitle ? `<div style="font-family:'Fraunces',serif;font-weight:300;font-style:italic;font-size:0.85rem;margin-top:2px;color:var(--accent-strong)">${subtitle}</div>` : ""}
      ${badges ? `<div style="display:flex;flex-wrap:wrap;gap:6px;margin-top:8px">${badges}</div>` : ""}
      ${link}
    </div>`;

    popupRef.current = new maplibregl.Popup({
      closeButton: true,
      closeOnClick: true,
      maxWidth: "260px",
      offset: 18,
    })
      .setLngLat(f.geometry.coordinates)
      .setHTML(html)
      .addTo(map);
  };

  // Build (or rebuild) the map with the given theme.
  const buildMap = (dark: boolean) => {
    if (!containerRef.current) return;
    const map = new maplibregl.Map({
      container: containerRef.current,
      style: styleUrl(dark),
      center: [centerRef.current[1], centerRef.current[0]],
      zoom: 12,
      attributionControl: { compact: true },
      dragRotate: false,
      touchZoomRotate: false,
    });
    map.addControl(
      new maplibregl.NavigationControl({ showCompass: false, showZoom: true }),
      "top-right",
    );
    map.on("style.load", () => {
      applyBrandOverrides(map);
      addPinLayers(map);
      fitToPins(map);
    });
    map.on("moveend", () => syncMarkers(map));
    map.on("zoomend", () => syncMarkers(map));
    map.on("data", (e) => {
      if ((e as { sourceId?: string }).sourceId === SOURCE_ID) syncMarkers(map);
    });
    map.on("click", "clusters", (e) => {
      const feats = map.queryRenderedFeatures(e.point, { layers: ["clusters"] });
      const clusterId = feats[0]?.properties?.cluster_id;
      const src = map.getSource(SOURCE_ID) as maplibregl.GeoJSONSource;
      if (clusterId == null || !src) return;
      src.getClusterExpansionZoom(clusterId).then((zoom) => {
        const geom = feats[0].geometry as { coordinates: [number, number] };
        map.easeTo({ center: geom.coordinates, zoom: zoom + 1 });
      });
    });
    map.on("mouseenter", "clusters", () => (map.getCanvas().style.cursor = "pointer"));
    map.on("mouseleave", "clusters", () => (map.getCanvas().style.cursor = ""));
    mapRef.current = map;
  };

  const fitToPins = (map: maplibregl.Map) => {
    const pts = pinsRef.current;
    if (pts.length === 1) {
      map.jumpTo({ center: [pts[0].lng, pts[0].lat], zoom: 14 });
    } else if (pts.length > 1) {
      const b = new maplibregl.LngLatBounds();
      for (const p of pts) b.extend([p.lng, p.lat]);
      map.fitBounds(b, { padding: 48, maxZoom: 15, duration: 0 });
    }
  };

  // Initial mount.
  useEffect(() => {
    buildMap(isDarkMode());
    return () => {
      for (const m of markersRef.current.values()) m.remove();
      markersRef.current.clear();
      popupRef.current?.remove();
      mapRef.current?.remove();
      mapRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // React to theme changes: rebuild style, persist pins via style.load handler.
  useEffect(() => {
    if (typeof document === "undefined") return;
    let current = isDarkMode();
    const observer = new MutationObserver(() => {
      const next = isDarkMode();
      if (next === current) return;
      current = next;
      const map = mapRef.current;
      if (!map) return;
      for (const m of markersRef.current.values()) m.remove();
      markersRef.current.clear();
      map.setStyle(styleUrl(next));
      map.once("style.load", () => {
        applyBrandOverrides(map);
        addPinLayers(map);
      });
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class"],
    });
    return () => observer.disconnect();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update data when pins change.
  useEffect(() => {
    const map = mapRef.current;
    if (!map || !map.getSource(SOURCE_ID)) return;
    (map.getSource(SOURCE_ID) as maplibregl.GeoJSONSource).setData(
      toGeoJSON(pins) as never,
    );
    fitToPins(map);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pins]);

  // Smooth-scroll for in-page anchor links inside popups.
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      const t = e.target as HTMLElement | null;
      const a = t?.closest?.("a[data-anchor]") as HTMLAnchorElement | null;
      if (!a) return;
      const id = a.getAttribute("data-anchor");
      if (!id) return;
      const el = document.getElementById(id);
      if (!el) return;
      e.preventDefault();
      el.scrollIntoView({ behavior: "smooth", block: "center" });
      el.classList.add("ring-2", "ring-primary");
      setTimeout(() => el.classList.remove("ring-2", "ring-primary"), 2000);
    };
    document.addEventListener("click", handler);
    return () => document.removeEventListener("click", handler);
  }, []);

  return (
    <div className="relative h-72 w-full overflow-hidden rounded-xl border border-border md:h-96">
      <div ref={containerRef} className="h-full w-full" />
    </div>
  );
}
