import { useCallback, useEffect, useState } from "react";
import type { ResultsData, Venue } from "@/components/VenueResults";

export type VenueQuery = { city: string; region?: string; country?: string };

export function useVenueLoadMore(opts: {
  data: ResultsData | undefined;
  query: VenueQuery | undefined;
  append: (newVenues: Venue[]) => void;
}) {
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Reset state whenever the city query identity changes (new search).
  const queryKey = opts.query
    ? `${opts.query.city}|${opts.query.region ?? ""}|${opts.query.country ?? ""}`
    : "";
  useEffect(() => {
    setHasMore(true);
    setError(null);
    setIsLoadingMore(false);
  }, [queryKey]);

  const loadMore = useCallback(async () => {
    if (!opts.data || !opts.query || isLoadingMore || !hasMore) return;
    setIsLoadingMore(true);
    setError(null);
    try {
      const res = await fetch("/api/top-restaurants", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...opts.query,
          exclude: opts.data.venues.map((v) => v.name).slice(0, 500),
          limit: 10,
        }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json?.error ?? "Failed to load more results");
      const existing = new Set(
        opts.data.venues.map((v) => v.name.trim().toLowerCase()),
      );
      const fresh = (((json?.venues as Venue[]) ?? []) || []).filter(
        (v) => v?.name && !existing.has(v.name.trim().toLowerCase()),
      );
      if (fresh.length === 0) {
        setHasMore(false);
      } else {
        opts.append(fresh);
        // If the model returned very few fresh venues, we've likely exhausted the city.
        if (fresh.length < 3) setHasMore(false);
      }
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setIsLoadingMore(false);
    }
  }, [opts, isLoadingMore, hasMore]);

  return { loadMore, isLoadingMore, hasMore, error };
}