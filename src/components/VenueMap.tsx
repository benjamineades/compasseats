/// <reference types="google.maps" />
import { useEffect, useMemo, useRef, useState } from "react";

export type Pin = {
  index: number;
  name: string;
  category: "restaurant" | "cocktail bar";
  lat: number;
  lng: number;
  accolade?: string;
  anchorId?: string;
};

export const PIN_COLORS = {
  restaurant: "#d4af37", // gold
  bar: "#1e3a8a", // navy
};

const TRACKING_ID =
  (import.meta.env.VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_TRACKING_ID as
    | string
    | undefined) ?? "";

let mapsLoader: Promise<typeof google> | null = null;

function loadGoogleMaps(): Promise<typeof google> {
  if (typeof window === "undefined") return Promise.reject(new Error("SSR"));
  if ((window as any).google?.maps) return Promise.resolve((window as any).google);
  if (mapsLoader) return mapsLoader;
  const key = import.meta.env.VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_BROWSER_KEY as
    | string
    | undefined;
  if (!key) return Promise.reject(new Error("Google Maps browser key missing"));
  mapsLoader = new Promise<typeof google>((resolve, reject) => {
    const cbName = `__initGmaps_${Math.random().toString(36).slice(2)}`;
    (window as any)[cbName] = () => {
      resolve((window as any).google);
      delete (window as any)[cbName];
    };
    const params = new URLSearchParams({
      key,
      loading: "async",
      callback: cbName,
      libraries: "marker",
    });
    if (TRACKING_ID) params.set("channel", TRACKING_ID);
    const s = document.createElement("script");
    s.src = `https://maps.googleapis.com/maps/api/js?${params.toString()}`;
    s.async = true;
    s.defer = true;
    s.onerror = () => {
      mapsLoader = null;
      reject(new Error("Failed to load Google Maps"));
    };
    document.head.appendChild(s);
  });
  return mapsLoader;
}

function pinSvg(index: number, isBar: boolean): string {
  const bg = isBar ? PIN_COLORS.bar : PIN_COLORS.restaurant;
  const text = isBar ? "#ffffff" : "#1a1a1a";
  const prefix = isBar ? "B" : "R";
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="34" height="42" viewBox="0 0 34 42">
    <path d="M17 0C7.6 0 0 6.6 0 14.7c0 11 17 27.3 17 27.3s17-16.3 17-27.3C34 6.6 26.4 0 17 0z" fill="${bg}" stroke="#fff" stroke-width="2"/>
    <text x="17" y="19" text-anchor="middle" font-family="ui-sans-serif,system-ui,-apple-system,sans-serif" font-size="11" font-weight="700" fill="${text}">${prefix}${index}</text>
  </svg>`;
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`;
}

export function VenueMap({
  center,
  pins,
}: {
  center: [number, number];
  pins: Pin[];
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<google.maps.Map | null>(null);
  const markersRef = useRef<google.maps.Marker[]>([]);
  const infoRef = useRef<google.maps.InfoWindow | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [ready, setReady] = useState(false);

  // Initial load.
  useEffect(() => {
    let cancelled = false;
    loadGoogleMaps()
      .then((g) => {
        if (cancelled || !containerRef.current) return;
        mapRef.current = new g.maps.Map(containerRef.current, {
          center: { lat: center[0], lng: center[1] },
          zoom: 13,
          scrollwheel: false,
          gestureHandling: "cooperative",
          streetViewControl: false,
          mapTypeControl: false,
          fullscreenControl: false,
        });
        infoRef.current = new g.maps.InfoWindow();
        setReady(true);
      })
      .catch((e) => setError((e as Error).message));
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update markers + bounds whenever pins change.
  const pinsKey = useMemo(
    () =>
      pins
        .map((p) => `${p.category}-${p.index}-${p.lat.toFixed(5)},${p.lng.toFixed(5)}`)
        .join("|"),
    [pins],
  );

  useEffect(() => {
    if (!ready || !mapRef.current) return;
    const g = (window as any).google as typeof google;
    // Clear existing markers.
    for (const m of markersRef.current) m.setMap(null);
    markersRef.current = [];
    const bounds = new g.maps.LatLngBounds();
    for (const p of pins) {
      const isBar = p.category === "cocktail bar";
      const prefix = isBar ? "B" : "R";
      const marker = new g.maps.Marker({
        position: { lat: p.lat, lng: p.lng },
        map: mapRef.current,
        title: `${prefix}${p.index}. ${p.name}`,
        icon: {
          url: pinSvg(p.index, isBar),
          scaledSize: new g.maps.Size(34, 42),
          anchor: new g.maps.Point(17, 40),
        },
      });
      marker.addListener("click", () => {
        const color = isBar ? PIN_COLORS.bar : PIN_COLORS.restaurant;
        const textColor = isBar ? "#fff" : "#1a1a1a";
        const accolade = p.accolade
          ? `<div style="font-size:12px;color:#b45309;margin-top:4px;font-weight:600">${p.accolade}</div>`
          : "";
        const link = p.anchorId
          ? `<a href="#${p.anchorId}" data-anchor="${p.anchorId}" style="display:inline-block;margin-top:8px;padding:4px 10px;background:${color};color:${textColor};border-radius:6px;font-size:12px;font-weight:600;text-decoration:none">View details →</a>`
          : "";
        infoRef.current?.setContent(
          `<div style="min-width:180px;font-family:ui-sans-serif,system-ui,-apple-system,sans-serif">
            <strong style="font-size:14px">${prefix}${p.index}. ${p.name}</strong>
            <div style="font-size:12px;color:#555;text-transform:capitalize;margin-top:2px">${p.category}</div>
            ${accolade}${link}
          </div>`,
        );
        infoRef.current?.open({ map: mapRef.current!, anchor: marker });
      });
      markersRef.current.push(marker);
      bounds.extend({ lat: p.lat, lng: p.lng });
    }
    if (pins.length === 1) {
      mapRef.current.setCenter({ lat: pins[0].lat, lng: pins[0].lng });
      mapRef.current.setZoom(14);
    } else if (pins.length > 1) {
      mapRef.current.fitBounds(bounds, 40);
    } else {
      mapRef.current.setCenter({ lat: center[0], lng: center[1] });
    }
  }, [pinsKey, ready, center, pins]);

  // Delegate clicks on InfoWindow "View details" links to smooth-scroll + highlight.
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

  if (error) {
    return (
      <div className="flex h-72 w-full items-center justify-center rounded-xl border border-border bg-muted/40 text-sm text-muted-foreground md:h-96">
        Map unavailable
      </div>
    );
  }

  return (
    <div className="relative h-72 w-full overflow-hidden rounded-xl border border-border md:h-96">
      <div ref={containerRef} className="h-full w-full" />
      {!ready && (
        <div className="absolute inset-0 animate-pulse bg-muted/40" />
      )}
    </div>
  );
}
