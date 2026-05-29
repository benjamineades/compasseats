import { useEffect, useMemo, useRef, useState } from "react";
import { Search, Loader2 } from "lucide-react";
import { useNavigate } from "@tanstack/react-router";
import { Input } from "@/components/ui/input";
import { searchCities } from "@/lib/cities";
import {
  geoapifyCitySearch,
  slugifyPlace,
  type GeoapifyCityResult,
} from "@/lib/geoapify-search";
import type { City } from "@/lib/schema";

type Props = {
  placeholder?: string;
};

export function CitySearch({ placeholder }: Props) {
  const [value, setValue] = useState("");
  const [debounced, setDebounced] = useState("");
  const [uncharted, setUncharted] = useState<GeoapifyCityResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);
  const navigate = useNavigate();
  const wrapRef = useRef<HTMLDivElement>(null);
  const cacheRef = useRef(new Map<string, GeoapifyCityResult[]>());
  const abortRef = useRef<AbortController | null>(null);

  // Debounce input by 250ms.
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value.trim()), 250);
    return () => clearTimeout(t);
  }, [value]);

  // Tier 1: synchronous charted matches.
  const charted: City[] = useMemo(
    () => (debounced.length >= 1 ? searchCities(debounced, 8) : []),
    [debounced],
  );

  // Tier 2: Geoapify autocomplete (>= 3 chars).
  useEffect(() => {
    if (debounced.length < 3) {
      setUncharted([]);
      setLoading(false);
      return;
    }
    const cached = cacheRef.current.get(debounced);
    if (cached) {
      setUncharted(cached);
      setLoading(false);
      return;
    }
    abortRef.current?.abort();
    const ctrl = new AbortController();
    abortRef.current = ctrl;
    setLoading(true);
    geoapifyCitySearch(debounced, ctrl.signal)
      .then((res) => {
        cacheRef.current.set(debounced, res);
        setUncharted(res);
      })
      .catch((e) => {
        if ((e as Error).name !== "AbortError") setUncharted([]);
      })
      .finally(() => {
        if (!ctrl.signal.aborted) setLoading(false);
      });
    return () => ctrl.abort();
  }, [debounced]);

  // Dedupe Geoapify against charted by name+country (case-insensitive).
  const unchartedFiltered = useMemo(() => {
    if (uncharted.length === 0) return [];
    const have = new Set(
      charted.map(
        (c) => `${c.display.toLowerCase()}|${c.country.toLowerCase()}`,
      ),
    );
    return uncharted.filter(
      (u) => !have.has(`${u.name.toLowerCase()}|${u.country.toLowerCase()}`),
    );
  }, [uncharted, charted]);

  // Flat list for keyboard nav.
  const flat = useMemo(
    () => [
      ...charted.map((c) => ({ kind: "charted" as const, data: c })),
      ...unchartedFiltered.map((u) => ({ kind: "uncharted" as const, data: u })),
    ],
    [charted, unchartedFiltered],
  );

  useEffect(() => {
    setActive(0);
  }, [debounced]);

  useEffect(() => {
    const onDoc = (e: MouseEvent) => {
      if (!wrapRef.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onDoc);
    return () => document.removeEventListener("mousedown", onDoc);
  }, []);

  const goCharted = (c: City) => {
    setOpen(false);
    navigate({ to: "/city/$slug", params: { slug: c.slug } });
  };

  const goUncharted = (u: GeoapifyCityResult) => {
    setOpen(false);
    const slug = slugifyPlace(u.name);
    navigate({
      to: "/uncharted/$slug",
      params: { slug },
      state: {
        place: {
          name: u.name,
          region: u.region,
          country: u.country,
          lat: u.lat,
          lng: u.lng,
        },
      } as never,
    });
  };

  const select = (idx: number) => {
    const item = flat[idx];
    if (!item) return;
    if (item.kind === "charted") goCharted(item.data);
    else goUncharted(item.data);
  };

  const showEmpty =
    debounced.length >= 1 &&
    charted.length === 0 &&
    unchartedFiltered.length === 0 &&
    !loading;

  const sectionLabelStyle: React.CSSProperties = {
    fontFamily: '"Hanken Grotesk", system-ui, sans-serif',
    fontWeight: 600,
    fontSize: "0.72rem",
    letterSpacing: "0.32em",
    textTransform: "uppercase",
    color: "var(--primary)",
    padding: "14px 18px 8px",
  };

  return (
    <div ref={wrapRef} className="relative">
      <Search className="pointer-events-none absolute left-3 top-[1.4rem] h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      {loading && (
        <Loader2 className="pointer-events-none absolute right-3 top-[1.4rem] h-4 w-4 -translate-y-1/2 animate-spin text-muted-foreground" />
      )}
      <Input
        value={value}
        onChange={(e) => {
          setValue(e.target.value);
          setOpen(true);
        }}
        onFocus={() => setOpen(true)}
        onKeyDown={(e) => {
          if (!open) return;
          if (e.key === "ArrowDown") {
            e.preventDefault();
            setActive((a) => (flat.length ? (a + 1) % flat.length : 0));
          } else if (e.key === "ArrowUp") {
            e.preventDefault();
            setActive((a) =>
              flat.length ? (a - 1 + flat.length) % flat.length : 0,
            );
          } else if (e.key === "Enter") {
            e.preventDefault();
            select(active);
          } else if (e.key === "Escape") {
            setOpen(false);
          }
        }}
        placeholder={placeholder}
        className="h-12 pl-10 pr-10 text-base"
        maxLength={100}
        autoComplete="off"
      />
      {open && (flat.length > 0 || showEmpty) && (
        <div
          className="absolute left-0 right-0 top-full z-50 mt-1 overflow-auto"
          style={{
            background: "var(--background)",
            border: "1px solid var(--border)",
            borderRadius: 4,
            boxShadow: "0 8px 32px rgba(0,0,0,0.18)",
            maxHeight: "60vh",
          }}
        >
          {charted.length > 0 && (
            <>
              <div style={sectionLabelStyle}>Charted</div>
              {charted.map((c, i) => {
                const idx = i;
                return (
                  <ChartedRow
                    key={`c-${c.slug}`}
                    city={c}
                    active={idx === active}
                    onMouseEnter={() => setActive(idx)}
                    onClick={() => goCharted(c)}
                  />
                );
              })}
            </>
          )}
          {unchartedFiltered.length > 0 && (
            <>
              <div style={sectionLabelStyle}>Explore further</div>
              {unchartedFiltered.map((u, i) => {
                const idx = charted.length + i;
                return (
                  <UnchartedRow
                    key={`u-${u.placeId}`}
                    item={u}
                    active={idx === active}
                    onMouseEnter={() => setActive(idx)}
                    onClick={() => goUncharted(u)}
                  />
                );
              })}
            </>
          )}
          {showEmpty && (
            <div className="px-4 py-4 text-sm text-muted-foreground">
              No matches. Try another spelling, or a nearby city.
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function ChartedRow({
  city,
  active,
  onClick,
  onMouseEnter,
}: {
  city: City;
  active: boolean;
  onClick: () => void;
  onMouseEnter: () => void;
}) {
  return (
    <button
      type="button"
      onMouseDown={(e) => {
        e.preventDefault();
        onClick();
      }}
      onMouseEnter={onMouseEnter}
      className="flex w-full items-center gap-3 px-4 py-2.5 text-left"
      style={{ background: active ? "var(--accent)" : "transparent" }}
    >
      <span
        aria-hidden
        style={{
          width: 8,
          height: 8,
          borderRadius: 999,
          background: "var(--primary)",
          flex: "0 0 auto",
        }}
      />
      <span className="min-w-0 flex-1">
        <span
          className="block truncate"
          style={{
            fontFamily: "Fraunces, serif",
            fontWeight: 400,
            fontSize: "1.05rem",
            color: "var(--foreground)",
          }}
        >
          {city.display}
        </span>
        <span
          className="block truncate"
          style={{
            fontFamily: '"Hanken Grotesk", system-ui, sans-serif',
            fontWeight: 400,
            fontSize: "0.78rem",
            color: "var(--muted-foreground)",
          }}
        >
          {city.country} · {city.venue_count}{" "}
          {city.venue_count === 1 ? "venue" : "venues"}
        </span>
      </span>
    </button>
  );
}

function UnchartedRow({
  item,
  active,
  onClick,
  onMouseEnter,
}: {
  item: GeoapifyCityResult;
  active: boolean;
  onClick: () => void;
  onMouseEnter: () => void;
}) {
  const label = `${item.name}${item.region ? `, ${item.region}` : ""}, ${item.country}`;
  return (
    <button
      type="button"
      onMouseDown={(e) => {
        e.preventDefault();
        onClick();
      }}
      onMouseEnter={onMouseEnter}
      className="flex w-full items-center gap-3 px-4 py-2.5 text-left"
      style={{ background: active ? "var(--accent)" : "transparent" }}
    >
      <span
        aria-hidden
        style={{
          width: 8,
          height: 8,
          borderRadius: 999,
          border: "1px solid var(--primary)",
          background: "transparent",
          flex: "0 0 auto",
        }}
      />
      <span
        className="min-w-0 flex-1 truncate"
        style={{
          fontFamily: "Fraunces, serif",
          fontWeight: 400,
          fontSize: "1.05rem",
          color: "var(--muted-foreground)",
        }}
      >
        {label}
      </span>
    </button>
  );
}