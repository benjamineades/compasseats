import { useMemo, useState, type ReactNode } from "react";
import {
  MapPin, Star, Leaf, Utensils, Trophy, Award, ExternalLink,
  Instagram, Facebook, Globe, CalendarCheck, Clock, Info, ArrowUpDown,
  ChevronDown, ChevronUp, Loader2, SlidersHorizontal, X,
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import {
  DropdownMenu, DropdownMenuTrigger, DropdownMenuContent,
  DropdownMenuCheckboxItem, DropdownMenuLabel, DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import {
  Tooltip, TooltipContent, TooltipProvider, TooltipTrigger,
} from "@/components/ui/tooltip";
import { VenueMap, PIN_COLORS, type Pin } from "@/components/VenueMap";
import { venueAnchorId } from "@/lib/cities";

export type Venue = {
  name: string;
  category: "restaurant" | "cocktail bar";
  cuisine: string;
  priceRange: string;
  description: string;
  neighborhood?: string;
  lat: number;
  lng: number;
  url?: string;
  urlType?: "website" | "instagram" | "facebook";
  michelinStars?: number;
  michelinGreenStar?: boolean;
  bibGourmand?: boolean;
  worldsBest50Restaurants?: { rank: number; year: number };
  worldsBest50Bars?: { rank: number; year: number };
  spiritedAward?: { name: string; year: number };
  jamesBeardAward?: { name: string; year: number };
  bestChefAward?: { knives: number; year: number };
  pinnacleAward?: { pins: number; year: number };
  chef?: string;
  signatureDish?: string;
  accoladeOverview?: string;
  whyThisPick?: string;
  reservationUrl?: string;
  reservationPlatform?: string;
  hours?: string;
  imageUrl?: string;
};

export type ResultsData = {
  city: string;
  country: string;
  cityBlurb?: string;
  lat: number;
  lng: number;
  venues: Venue[];
};

type QuickFilter = "restaurants" | "bars" | "openToday";
type AwardFilter = "michelin" | "worlds50" | "bestchef" | "jamesbeard";
type Filter = QuickFilter | AwardFilter;
type Sort = "ranked" | "nearest" | "alphabetical";

const MICHELIN_STAR_TIPS: Record<number, string> = {
  1: "One Michelin Star: A very good restaurant in its category.",
  2: "Two Michelin Stars: Excellent cooking, worth a detour.",
  3: "Three Michelin Stars: Exceptional cuisine, worth a special journey.",
};

const CURRENT_YEAR = new Date().getUTCFullYear();
const MIN_RECENT_YEAR = CURRENT_YEAR - 2;

function isRecentRanking(year?: number): boolean {
  return typeof year === "number" && year >= MIN_RECENT_YEAR;
}

function hasMichelin(v: Venue) {
  return (v.michelinStars ?? 0) > 0 || v.bibGourmand || v.michelinGreenStar;
}
function hasWorlds50(v: Venue) {
  return (
    (!!v.worldsBest50Restaurants && isRecentRanking(v.worldsBest50Restaurants.year)) ||
    (!!v.worldsBest50Bars && isRecentRanking(v.worldsBest50Bars.year))
  );
}
function hasBestChef(v: Venue) {
  return !!v.bestChefAward;
}
function hasJamesBeard(v: Venue) {
  return !!v.jamesBeardAward;
}

function distanceKm(a: [number, number], b: [number, number]) {
  const [lat1, lng1] = a, [lat2, lng2] = b;
  const R = 6371, toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1), dLng = toRad(lng2 - lng1);
  const x = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(x));
}

function parseHoursOpenToday(hours?: string): boolean | null {
  if (!hours) return null;
  // Best-effort heuristic: checks if the venue is open today (weekday only, not time of day).
  const day = new Date().toLocaleString("en-US", { weekday: "short" });
  const today3 = day.slice(0, 3);
  if (/daily/i.test(hours)) return true;
  if (new RegExp(today3, "i").test(hours)) return true;
  // Range like Mon–Fri / Tue–Sun
  const m = hours.match(/(Mon|Tue|Wed|Thu|Fri|Sat|Sun)[–-](Mon|Tue|Wed|Thu|Fri|Sat|Sun)/i);
  if (m) {
    const order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const s = order.indexOf(m[1]), e = order.indexOf(m[2]), now = order.indexOf(today3);
    if (s >= 0 && e >= 0 && now >= 0) {
      if (s <= e ? now >= s && now <= e : now >= s || now <= e) return true;
    }
  }
  return false;
}

export type VenueResultsLoadMore = {
  onLoadMore?: () => void;
  isLoadingMore?: boolean;
  hasMore?: boolean;
  loadMoreError?: string | null;
};

export function VenueResults({
  data,
  onLoadMore,
  isLoadingMore,
  hasMore,
  loadMoreError,
}: { data: ResultsData } & VenueResultsLoadMore) {
  const [filters, setFilters] = useState<Set<Filter>>(new Set());
  const [sort, setSort] = useState<Sort>("ranked");

  const filtered = useMemo(() => {
    const center: [number, number] = [data.lat, data.lng];
    const wantRest = filters.has("restaurants");
    const wantBars = filters.has("bars");
    const wantOpen = filters.has("openToday");
    const awardChecks: Array<(v: Venue) => boolean> = [];
    if (filters.has("michelin")) awardChecks.push((v) => (v.michelinStars ?? 0) > 0);
    if (filters.has("worlds50")) awardChecks.push(hasWorlds50);
    if (filters.has("bestchef")) awardChecks.push(hasBestChef);
    if (filters.has("jamesbeard")) awardChecks.push(hasJamesBeard);

    let venues = data.venues.filter((v) => {
      if (wantRest && !wantBars && v.category !== "restaurant") return false;
      if (wantBars && !wantRest && v.category !== "cocktail bar") return false;
      if (wantOpen && parseHoursOpenToday(v.hours) !== true) return false;
      if (awardChecks.length > 0 && !awardChecks.some((fn) => fn(v))) return false;
      return true;
    });
    if (sort === "alphabetical") {
      venues = [...venues].sort((a, b) => a.name.localeCompare(b.name));
    } else if (sort === "nearest") {
      venues = [...venues].sort(
        (a, b) => distanceKm(center, [a.lat, a.lng]) - distanceKm(center, [b.lat, b.lng]),
      );
    }
    return venues;
  }, [data, filters, sort]);

  // Original 1..10 indices are based on the unfiltered order (restaurants then bars)
  const indexMap = useMemo(() => {
    const map = new Map<Venue, number>();
    let r = 0, b = 0;
    for (const v of data.venues) {
      map.set(v, v.category === "restaurant" ? ++r : ++b);
    }
    return map;
  }, [data]);

  const michelinCount = data.venues.filter(hasMichelin).length;
  const worlds50Count = data.venues.filter(hasWorlds50).length;
  const bestChefCount = data.venues.filter(hasBestChef).length;
  const jamesBeardCount = data.venues.filter(hasJamesBeard).length;
  const noPrestige = michelinCount === 0 && worlds50Count === 0;

  const pins: Pin[] = filtered.map((v) => {
    const idx = indexMap.get(v) ?? 0;
    return {
      index: idx,
      name: v.name,
      category: v.category,
      lat: v.lat,
      lng: v.lng,
      accolade: summarizeAccolade(v),
      anchorId: venueAnchorId(v.category, idx),
    };
  });

  const restaurants = filtered.filter((v) => v.category === "restaurant");
  const bars = filtered.filter((v) => v.category === "cocktail bar");

  return (
    <TooltipProvider delayDuration={150}>
      <div className="mb-4 flex items-center gap-2 text-sm text-muted-foreground">
        <MapPin className="h-4 w-4" />
        Top spots in{" "}
        <span className="font-medium text-foreground">
          {data.city}{data.country ? `, ${data.country}` : ""}
        </span>
      </div>

      {noPrestige ? (
        <div className="mb-4 rounded-lg border border-amber-500/30 bg-amber-500/5 px-3 py-2.5 text-xs leading-relaxed text-amber-200/90">
          No Michelin or World's 50 Best venues in this city yet — showing top locally acclaimed spots instead.
        </div>
      ) : (
        <div className="mb-4 rounded-lg border border-border bg-card/40 px-3 py-2 text-[11px] leading-relaxed text-muted-foreground">
          Rankings reflect most recent available guide year.
        </div>
      )}

      <div className="sticky top-[70px] z-[60] -mx-6 mb-4 border-b border-border bg-background/80 px-6 py-3 backdrop-blur-md">
        <FilterBar
          filters={filters}
          setFilters={setFilters}
          showMichelin={michelinCount > 0}
          showWorlds50={worlds50Count > 0}
          showBestChef={bestChefCount > 0}
          showJamesBeard={jamesBeardCount > 0}
        />
      </div>

      {filtered.length === 0 ? (
        <EmptyState />
      ) : (
        <>
          <VenueMap center={[data.lat, data.lng]} pins={pins} />
          <div className="mt-3 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
            <span className="inline-flex items-center gap-1.5">
              <span className="inline-block h-3 w-3 rounded-full" style={{ background: PIN_COLORS.restaurant }} />
              Restaurants
            </span>
            <span className="inline-flex items-center gap-1.5">
              <span className="inline-block h-3 w-3 rounded-full" style={{ background: PIN_COLORS.bar }} />
              Cocktail bars
            </span>
            <div className="relative z-[60] ml-auto flex items-center gap-2">
              <ArrowUpDown className="h-3.5 w-3.5" />
              <Select value={sort} onValueChange={(v) => setSort(v as Sort)}>
                <SelectTrigger className="h-8 w-44 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ranked">Highest Ranked</SelectItem>
                  <SelectItem value="nearest">Nearest to City Center</SelectItem>
                  <SelectItem value="alphabetical">Alphabetical</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="mt-6 grid grid-cols-1 gap-6 md:grid-cols-2">
            <VenueColumn title="Restaurants" accent={PIN_COLORS.restaurant} accentText="#1a1a1a" items={restaurants} indexMap={indexMap} />
            <VenueColumn title="Cocktail Bars" accent={PIN_COLORS.bar} accentText="#fff" items={bars} indexMap={indexMap} />
          </div>
          {onLoadMore && (
            <div className="mt-10 flex flex-col items-center gap-2 text-center">
              {loadMoreError && (
                <p className="text-sm text-destructive">{loadMoreError}</p>
              )}
              {hasMore ? (
                <Button
                  variant="outline"
                  size="lg"
                  onClick={onLoadMore}
                  disabled={!!isLoadingMore}
                >
                  {isLoadingMore ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Finding more spots…
                    </>
                  ) : (
                    "Show 10 more"
                  )}
                </Button>
              ) : (
                <p className="text-sm text-muted-foreground">
                  No more results — you've seen every spot we could find in {data.city}.
                </p>
              )}
            </div>
          )}
          <p className="mt-8 text-center text-xs italic text-muted-foreground">
            Results charted from Michelin Guide, World's 50 Best, and more. Showing {filtered.length} venue{filtered.length === 1 ? "" : "s"}.
          </p>
        </>
      )}
    </TooltipProvider>
  );
}

function FilterBar({
  filter, setFilter, showMichelin, showWorlds50, showBestChef, showJamesBeard,
}: {
  filter: Filter; setFilter: (f: Filter) => void;
  showMichelin: boolean; showWorlds50: boolean;
  showBestChef: boolean; showJamesBeard: boolean;
}) {
  const all: { id: Filter; label: string }[] = [
    { id: "all", label: "All" },
    { id: "restaurants", label: "Restaurants" },
    { id: "bars", label: "Cocktail Bars" },
    { id: "michelin", label: "Michelin Starred" },
    { id: "worlds50", label: "World's 50 Best" },
    { id: "bestchef", label: "Best Chef Awards" },
    { id: "jamesbeard", label: "James Beard" },
    { id: "openToday", label: "Open Today" },
  ];
  const filters = all.filter((f) => {
    if (f.id === "michelin") return showMichelin;
    if (f.id === "worlds50") return showWorlds50;
    if (f.id === "bestchef") return showBestChef;
    if (f.id === "jamesbeard") return showJamesBeard;
    return true;
  });
  return (
    <div className="flex flex-wrap items-center gap-2">
      <div className="flex flex-wrap gap-1.5">
        {filters.map((f) => (
          <Button
            key={f.id}
            size="sm"
            variant={filter === f.id ? "default" : "outline"}
            onClick={() => setFilter(f.id)}
            className="h-8 rounded-full text-xs"
          >
            {f.label}
          </Button>
        ))}
      </div>
    </div>
  );
}

function EmptyState() {
  return (
    <Card className="border-dashed">
      <CardContent className="flex flex-col items-center gap-3 p-10 text-center">
        <MapPin className="h-8 w-8 text-muted-foreground" />
        <h3 className="text-lg font-semibold">No venues match those filters</h3>
        <p className="max-w-md text-sm text-muted-foreground">
          Try clearing the filters, or search a nearby major city like Paris, Tokyo, or New York.
        </p>
      </CardContent>
    </Card>
  );
}

function VenueColumn({
  title, accent, accentText, items, indexMap,
}: {
  title: string; accent: string; accentText: string; items: Venue[]; indexMap: Map<Venue, number>;
}) {
  return (
    <div>
      <h3 className="mb-3 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
        {title}
      </h3>
      <ol className="space-y-4">
        {items.map((v) => {
          const n = indexMap.get(v) ?? 0;
          const anchor = venueAnchorId(v.category, n);
          return (
            <li key={`${v.name}-${n}`} id={anchor}>
              <VenueCard v={v} n={n} accent={accent} accentText={accentText} />
            </li>
          );
        })}
      </ol>
    </div>
  );
}

function VenueCard({
  v, n, accent, accentText,
}: { v: Venue; n: number; accent: string; accentText: string }) {
  const [expanded, setExpanded] = useState(false);
  const hasDetails = !!(v.description || v.accoladeOverview || v.whyThisPick || v.chef);

  const action = v.reservationUrl
    ? { href: v.reservationUrl, label: "Book", icon: CalendarCheck,
        title: v.reservationPlatform ? `Book via ${v.reservationPlatform}` : "Book a reservation",
        cls: "border-emerald-500/40 bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20" }
    : v.url
    ? { href: v.url, label: "View Website", icon: Globe,
        title: "Open official website",
        cls: "border-border bg-card text-foreground hover:bg-accent" }
    : null;

  return (
    <Card className="group overflow-hidden transition-all hover:border-foreground/20">
      <VenueHeroImage v={v} n={n} accent={accent} accentText={accentText} />
      <CardContent className="p-4">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div className="flex flex-wrap items-center gap-1.5">
            <Badge variant="outline">{v.cuisine}</Badge>
            {v.neighborhood && <Badge variant="outline">{v.neighborhood}</Badge>}
            {v.hours && (
              <Badge variant="outline" title="Business hours" className="gap-1">
                <Clock className="h-3 w-3" />{v.hours}
              </Badge>
            )}
            <span className="text-sm font-medium text-muted-foreground">{v.priceRange}</span>
          </div>
          {action && (
            <a href={action.href} target="_blank" rel="noopener noreferrer" title={action.title}
              className={`inline-flex items-center gap-1 rounded-md border px-2 py-0.5 text-xs font-medium ${action.cls}`}>
              <action.icon className="h-3 w-3" />{action.label}<ExternalLink className="h-3 w-3 opacity-70" />
            </a>
          )}
        </div>

        <Accolades v={v} />

        {v.category === "restaurant" && v.signatureDish && (
          <div className="mt-2">
            <Badge variant="secondary" title="Signature dish">
              Signature: {v.signatureDish}
            </Badge>
          </div>
        )}

        {hasDetails && (
          <>
            <button
              type="button"
              onClick={() => setExpanded((e) => !e)}
              className="mt-3 inline-flex items-center gap-1 text-xs font-medium text-accent-strong hover:underline"
              aria-expanded={expanded}
            >
              {expanded ? (<><ChevronUp className="h-3 w-3" />Hide details</>) : (<><ChevronDown className="h-3 w-3" />Read more</>)}
            </button>
            {expanded && (
              <div className="mt-3 space-y-2">
                {v.category === "restaurant" && v.chef && (
                  <p className="text-sm text-foreground">
                    <span className="text-muted-foreground">Chef:</span> {v.chef}
                  </p>
                )}
                {v.description && (
                  <p className="text-sm leading-relaxed text-muted-foreground">{v.description}</p>
                )}
                {v.accoladeOverview && (
                  <div className="rounded-md border-l-2 border-amber-500/40 bg-amber-500/5 px-2 py-1.5">
                    <div className="text-[10px] font-semibold uppercase tracking-wide text-amber-500/90">Guide overview</div>
                    <p className="mt-0.5 text-sm leading-relaxed text-muted-foreground">{v.accoladeOverview}</p>
                  </div>
                )}
                {v.whyThisPick && (
                  <div className="rounded-md border-l-2 border-primary/50 bg-primary/5 px-2 py-1.5">
                    <div className="text-[10px] font-semibold uppercase tracking-wide text-accent-strong">Why this pick</div>
                    <p className="mt-0.5 text-sm leading-relaxed text-muted-foreground">{v.whyThisPick}</p>
                  </div>
                )}
              </div>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}

function VenueHeroImage({
  v, n, accent, accentText,
}: { v: Venue; n: number; accent: string; accentText: string }) {
  const [errored, setErrored] = useState(false);
  const showImage = !!v.imageUrl && !errored;

  const initials = v.name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase() ?? "")
    .join("");

  const monogram = (
    <div
      className="flex h-full w-full items-center justify-center"
      style={{
        background: `radial-gradient(circle at 30% 25%, ${accent}cc 0%, ${accent} 45%, ${accent}66 100%)`,
      }}
    >
      <span className="font-display text-3xl font-light tracking-wide" style={{ color: accentText }}>
        {initials}
      </span>
    </div>
  );

  return (
    <div className="relative aspect-[16/9] w-full max-h-[200px] overflow-hidden bg-muted">
      {showImage ? (
        <img
          src={v.imageUrl}
          alt={v.name}
          loading="lazy"
          referrerPolicy="no-referrer"
          onError={() => setErrored(true)}
          className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
      ) : v.url ? (
        <a href={v.url} target="_blank" rel="noopener noreferrer" className="block h-full w-full">
          {monogram}
        </a>
      ) : (
        monogram
      )}
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/85 via-black/30 to-transparent" />
      <div
        className="absolute left-3 top-3 flex h-7 min-w-7 items-center justify-center rounded-full px-1 text-xs font-semibold shadow-md"
        style={{ background: accent, color: accentText }}
      >
        {v.category === "cocktail bar" ? `B${n}` : `R${n}`}
      </div>
      <div className="absolute inset-x-0 bottom-0 p-3">
        {v.url ? (
          <a href={v.url} target="_blank" rel="noopener noreferrer"
            className="group inline-flex items-baseline gap-1.5 font-display text-lg font-semibold leading-tight text-white hover:text-white/90">
            {v.name}<LinkIcon type={v.urlType} />
          </a>
        ) : (
          <h2 className="font-display text-lg font-semibold leading-tight text-white">{v.name}</h2>
        )}
      </div>
    </div>
  );
}

function LinkIcon({ type }: { type?: Venue["urlType"] }) {
  const cls = "h-3.5 w-3.5 opacity-70 group-hover:opacity-100";
  if (type === "instagram") return <Instagram className={cls} />;
  if (type === "facebook") return <Facebook className={cls} />;
  if (type === "website") return <Globe className={cls} />;
  return <ExternalLink className={cls} />;
}

function InfoTip({ text }: { text: string }) {
  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <button type="button" className="ml-0.5 inline-flex" aria-label="What does this mean?">
          <Info className="h-3 w-3 opacity-60 hover:opacity-100" />
        </button>
      </TooltipTrigger>
      <TooltipContent side="top" className="max-w-xs text-xs leading-snug">{text}</TooltipContent>
    </Tooltip>
  );
}

function summarizeAccolade(v: Venue): string | undefined {
  if (v.michelinStars) return `${"★".repeat(v.michelinStars)} Michelin`;
  if (v.worldsBest50Restaurants && isRecentRanking(v.worldsBest50Restaurants.year))
    return `World's 50 Best #${v.worldsBest50Restaurants.rank} (${v.worldsBest50Restaurants.year})`;
  if (v.worldsBest50Bars && isRecentRanking(v.worldsBest50Bars.year))
    return `World's 50 Best Bars #${v.worldsBest50Bars.rank} (${v.worldsBest50Bars.year})`;
  if (v.spiritedAward) return `${v.spiritedAward.name} (${v.spiritedAward.year})`;
  if (v.pinnacleAward)
    return `Pinnacle Guide ${v.pinnacleAward.pins}-Pin (${v.pinnacleAward.year})`;
  if (v.jamesBeardAward) return `James Beard: ${v.jamesBeardAward.name} (${v.jamesBeardAward.year})`;
  if (v.bestChefAward)
    return `Best Chef Awards ${"🔪".repeat(v.bestChefAward.knives)} (${v.bestChefAward.year})`;
  if (v.bibGourmand) return "Michelin Bib Gourmand";
  if (v.michelinGreenStar) return "Michelin Green Star";
  return undefined;
}

function Accolades({ v }: { v: Venue }) {
  const stars = v.michelinStars ?? 0;
  const items: ReactNode[] = [];
  if (stars > 0) {
    items.push(
      <span key="m" className="inline-flex items-center gap-0.5 rounded-md border border-red-500/40 bg-red-500/10 px-1.5 py-0.5 text-xs font-medium text-red-400">
        {Array.from({ length: stars }).map((_, i) => (
          <Star key={i} className="h-3 w-3 fill-red-400 stroke-red-400" />
        ))}
        <InfoTip text={MICHELIN_STAR_TIPS[stars] ?? "Michelin Star awarded by the Michelin Guide."} />
      </span>,
    );
  }
  if (v.category === "restaurant" && v.worldsBest50Restaurants) {
    const w = v.worldsBest50Restaurants;
    if (isRecentRanking(w.year)) {
      items.push(
        <span key="w50r" className="inline-flex items-center gap-1 rounded-md border border-amber-500/40 bg-amber-500/10 px-1.5 py-0.5 text-xs font-medium text-amber-400">
          <Trophy className="h-3 w-3" />
          World's 50 Best #{w.rank} ({w.year})
          <InfoTip text={`Ranked #${w.rank} on the World's 50 Best Restaurants ${w.year} list.`} />
        </span>,
      );
    } else {
      items.push(
        <span key="w50r-old" className="inline-flex items-center gap-1 rounded-md border border-border bg-muted/40 px-1.5 py-0.5 text-xs font-medium text-muted-foreground">
          <Trophy className="h-3 w-3" />Previously ranked — World's 50 Best ({w.year})
        </span>,
      );
    }
  }
  if (v.michelinGreenStar) {
    items.push(
      <span key="g" className="inline-flex items-center gap-1 rounded-md border border-emerald-500/40 bg-emerald-500/10 px-1.5 py-0.5 text-xs font-medium text-emerald-400">
        <Leaf className="h-3 w-3" />Green Star
        <InfoTip text="Michelin Green Star: Recognises restaurants leading the way in sustainable gastronomy." />
      </span>,
    );
  }
  if (v.bibGourmand) {
    items.push(
      <span key="b" className="inline-flex items-center gap-1 rounded-md border border-orange-500/40 bg-orange-500/10 px-1.5 py-0.5 text-xs font-medium text-orange-400">
        <Utensils className="h-3 w-3" />Bib Gourmand
        <InfoTip text="Michelin Bib Gourmand: Friendly establishments serving good food at moderate prices." />
      </span>,
    );
  }
  if (v.worldsBest50Bars) {
    const w = v.worldsBest50Bars;
    if (isRecentRanking(w.year)) {
      items.push(
        <span key="w50b" className="inline-flex items-center gap-1 rounded-md border border-amber-500/40 bg-amber-500/10 px-1.5 py-0.5 text-xs font-medium text-amber-400">
          <Trophy className="h-3 w-3" />
          World's 50 Best Bars #{w.rank} ({w.year})
          <InfoTip text={`Ranked #${w.rank} on the World's 50 Best Bars ${w.year} list.`} />
        </span>,
      );
    } else {
      items.push(
        <span key="w50b-old" className="inline-flex items-center gap-1 rounded-md border border-border bg-muted/40 px-1.5 py-0.5 text-xs font-medium text-muted-foreground">
          <Trophy className="h-3 w-3" />Previously ranked — World's 50 Best Bars ({w.year})
        </span>,
      );
    }
  }
  if (v.spiritedAward) {
    items.push(
      <span key="sa" className="inline-flex items-center gap-1 rounded-md border border-fuchsia-500/40 bg-fuchsia-500/10 px-1.5 py-0.5 text-xs font-medium text-fuchsia-400">
        <Award className="h-3 w-3" />
        {v.spiritedAward.name} ({v.spiritedAward.year})
        <InfoTip text={`Tales of the Cocktail Spirited Award winner — ${v.spiritedAward.name} (${v.spiritedAward.year}). The industry's top honors for bars and bartenders.`} />
      </span>,
    );
  }
  if (v.category === "cocktail bar" && v.pinnacleAward) {
    const p = v.pinnacleAward;
    items.push(
      <span key="pin" className="inline-flex items-center gap-1 rounded-md border border-violet-500/40 bg-violet-500/10 px-1.5 py-0.5 text-xs font-medium text-violet-400">
        <Trophy className="h-3 w-3" />
        Pinnacle {p.pins}-Pin ({p.year})
        <InfoTip text={`The Pinnacle Guide awarded this bar ${p.pins} of 3 pins in ${p.year} — a global rating of the world's best cocktail bars.`} />
      </span>,
    );
  }
  if (v.jamesBeardAward) {
    items.push(
      <span key="jba" className="inline-flex items-center gap-1 rounded-md border border-rose-500/40 bg-rose-500/10 px-1.5 py-0.5 text-xs font-medium text-rose-400">
        <Award className="h-3 w-3" />
        James Beard: {v.jamesBeardAward.name} ({v.jamesBeardAward.year})
        <InfoTip text={`James Beard Award — ${v.jamesBeardAward.name} (${v.jamesBeardAward.year}). One of the most prestigious culinary honors in the United States.`} />
      </span>,
    );
  }
  if (v.category === "restaurant" && v.bestChefAward) {
    const bc = v.bestChefAward;
    items.push(
      <span
        key="bca"
        className="inline-flex items-center gap-1 rounded-md border border-sky-500/40 bg-sky-500/10 px-1.5 py-0.5 text-xs font-medium text-sky-400"
      >
        <Award className="h-3 w-3" />
        Best Chef {bc.knives}-Knives ({bc.year})
        <InfoTip
          text={`The Best Chef Awards ${bc.year} rated this restaurant's chef ${bc.knives} of 3 knives — a top global recognition by an international jury of chefs and critics.`}
        />
      </span>,
    );
  }
  if (items.length === 0) return null;
  return <div className="mt-2 flex flex-wrap items-center gap-1.5">{items}</div>;
}
