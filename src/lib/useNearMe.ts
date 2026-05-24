import { useCallback, useState } from "react";

export type Coords = [number, number];

const STORAGE_KEY = "compasseats:lastCoords";
const MAX_AGE_MS = 1000 * 60 * 60 * 24; // 24h

function loadCached(): Coords | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { coords?: Coords; ts?: number };
    if (
      !parsed.coords ||
      typeof parsed.ts !== "number" ||
      Date.now() - parsed.ts > MAX_AGE_MS
    ) {
      return null;
    }
    return parsed.coords;
  } catch {
    return null;
  }
}

function saveCached(coords: Coords) {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({ coords, ts: Date.now() }),
    );
  } catch {
    /* ignore quota / private mode */
  }
}

export function distanceKm(a: Coords, b: Coords): number {
  const [lat1, lng1] = a;
  const [lat2, lng2] = b;
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const x =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(x));
}

export function formatDistance(km: number): string {
  if (km < 1) return `${Math.round(km * 1000)} m`;
  if (km < 10) return `${km.toFixed(1)} km`;
  return `${Math.round(km)} km`;
}

export function useNearMe() {
  // Hydrate from a recent successful lookup so repeat visits feel instant.
  const [coords, setCoords] = useState<Coords | null>(() => loadCached());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [requested, setRequested] = useState(false);

  const requestLocation = useCallback(() => {
    setRequested(true);
    setError(null);
    // Instant path: use cached coords if available.
    const cached = loadCached();
    if (cached) {
      setCoords(cached);
      return;
    }
    if (typeof navigator === "undefined" || !navigator.geolocation) {
      setError("Geolocation isn't available in this browser.");
      return;
    }
    setLoading(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const next: Coords = [pos.coords.latitude, pos.coords.longitude];
        setCoords(next);
        saveCached(next);
        setLoading(false);
      },
      (err) => {
        setError(
          err.code === err.PERMISSION_DENIED
            ? "Location permission denied."
            : "Couldn't get your location.",
        );
        setLoading(false);
      },
      { enableHighAccuracy: false, timeout: 10000, maximumAge: 60000 },
    );
  }, []);

  return { coords, loading, error, requested, requestLocation };
}