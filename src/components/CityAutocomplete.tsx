import { useEffect, useRef, useState } from "react";
import { Search, Loader2, MapPin } from "lucide-react";
import { Input } from "@/components/ui/input";

export type CitySuggestion = {
  label: string;
  short: string;
  city: string;
  region?: string;
  country?: string;
};

type Props = {
  value: string;
  onChange: (v: string) => void;
  onSelect?: (s: CitySuggestion) => void;
  placeholder?: string;
  disabled?: boolean;
};

type NominatimItem = {
  place_id: number;
  display_name: string;
  address?: {
    city?: string;
    town?: string;
    village?: string;
    municipality?: string;
    suburb?: string;
    neighbourhood?: string;
    quarter?: string;
    city_district?: string;
    state?: string;
    country?: string;
  };
  type?: string;
  class?: string;
};

export function CityAutocomplete({ value, onChange, onSelect, placeholder, disabled }: Props) {
  const [items, setItems] = useState<CitySuggestion[]>([]);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);
  const justSelectedRef = useRef(false);
  const wrapRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const q = value.trim();
    if (justSelectedRef.current) {
      justSelectedRef.current = false;
      return;
    }
    if (q.length < 2) {
      setItems([]);
      setOpen(false);
      return;
    }
    const ctrl = new AbortController();
    const t = setTimeout(async () => {
      try {
        setLoading(true);
        const url = `https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&limit=6&featuretype=city&q=${encodeURIComponent(q)}`;
        const res = await fetch(url, {
          signal: ctrl.signal,
          headers: { Accept: "application/json" },
        });
        const data: NominatimItem[] = await res.json();
        const seen = new Set<string>();
        const mapped: CitySuggestion[] = [];
        for (const it of data) {
          const a = it.address ?? {};
          let city =
            a.city || a.town || a.village || a.municipality ||
            a.suburb || a.quarter || a.city_district || a.neighbourhood;
          // City-state edge cases (e.g. Monte-Carlo within Monaco): if the
          // resolved city name matches the country, prefer a more specific
          // sub-locality so users searching "Monte Carlo" don't see "Monaco".
          if (city && a.country && city === a.country) {
            city = a.suburb || a.quarter || a.city_district || a.neighbourhood || city;
          }
          if (!city) continue;
          const parts = [city, a.state, a.country].filter(Boolean) as string[];
          const label = parts.join(", ");
          const short = a.country && a.country !== "United States"
            ? `${city}, ${a.country}`
            : a.state
              ? `${city}, ${a.state}`
              : city;
          const key = label.toLowerCase();
          if (seen.has(key)) continue;
          seen.add(key);
          mapped.push({ label, short, city, region: a.state, country: a.country });
          if (mapped.length >= 6) break;
        }
        setItems(mapped);
        setOpen(mapped.length > 0);
        setActive(0);
      } catch (e) {
        if ((e as Error).name !== "AbortError") {
          setItems([]);
          setOpen(false);
        }
      } finally {
        setLoading(false);
      }
    }, 220);
    return () => {
      ctrl.abort();
      clearTimeout(t);
    };
  }, [value]);

  useEffect(() => {
    const onDoc = (e: MouseEvent) => {
      if (!wrapRef.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onDoc);
    return () => document.removeEventListener("mousedown", onDoc);
  }, []);

  const pick = (s: CitySuggestion) => {
    justSelectedRef.current = true;
    onChange(s.short);
    onSelect?.(s);
    setOpen(false);
    setItems([]);
  };

  return (
    <div ref={wrapRef} className="relative flex-1">
      <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      {loading && (
        <Loader2 className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 animate-spin text-muted-foreground" />
      )}
      <Input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onFocus={() => items.length > 0 && setOpen(true)}
        onKeyDown={(e) => {
          if (!open || items.length === 0) return;
          if (e.key === "ArrowDown") {
            e.preventDefault();
            setActive((a) => (a + 1) % items.length);
          } else if (e.key === "ArrowUp") {
            e.preventDefault();
            setActive((a) => (a - 1 + items.length) % items.length);
          } else if (e.key === "Enter") {
            e.preventDefault();
            pick(items[active]);
          } else if (e.key === "Escape") {
            setOpen(false);
          }
        }}
        placeholder={placeholder}
        disabled={disabled}
        className="h-12 pl-10 pr-10 text-base"
        maxLength={100}
        autoComplete="off"
        autoFocus
      />
      {open && items.length > 0 && (
        <ul
          role="listbox"
          className="absolute left-0 right-0 top-full z-50 mt-1 max-h-72 overflow-auto rounded-md border border-border bg-popover py-1 text-sm shadow-lg"
        >
          {items.map((it, i) => (
            <li key={`${it.label}-${i}`}>
              <button
                type="button"
                onMouseDown={(e) => {
                  e.preventDefault();
                  pick(it);
                }}
                onMouseEnter={() => setActive(i)}
                className={`flex w-full items-center gap-2 px-3 py-2 text-left ${
                  i === active ? "bg-accent text-accent-foreground" : "text-foreground"
                }`}
              >
                <MapPin className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                <span className="truncate">{it.label}</span>
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}