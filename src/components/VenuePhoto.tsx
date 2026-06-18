/**
 * VenuePhoto — venue image with a tasteful charcoal fallback.
 *
 * Photo cascade:
 *   1. `src`     — a curated photo URL (hosted by us). Wins when present.
 *   2. `placeId` — when there's no curated photo, fetch a live photo from the
 *                  CompassEats photo worker and show it with the credit Google
 *                  requires.
 *   3. neither / fetch fails — a card-colored panel with a faint compass mark.
 */

import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";
import { Compass } from "./Compass";

const PHOTO_WORKER =
  "https://compasseats-venue-photo.benjamin-eades.workers.dev";

type LivePhoto = {
  photoUri: string;
  attribution: string;
  attributionUri: string;
};

export function VenuePhoto({
  src,
  placeId,
  alt,
  className,
}: {
  src?: string;
  placeId?: string;
  alt: string;
  className?: string;
}) {
  const [live, setLive] = useState<LivePhoto | null>(null);

  useEffect(() => {
    if (src || !placeId) return;
    let cancelled = false;
    fetch(`${PHOTO_WORKER}/${encodeURIComponent(placeId)}?meta=1`)
      .then((r) => r.json())
      .then((d) => {
        if (!cancelled && d && d.ok && d.photoUri) {
          setLive({
            photoUri: d.photoUri,
            attribution: d.attribution || "",
            attributionUri: d.attributionUri || "",
          });
        }
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, [src, placeId]);

  if (src) {
    return (
      <img
        src={src}
        alt={alt}
        loading="lazy"
        className={cn("h-full w-full object-cover", className)}
      />
    );
  }

  if (live) {
    return (
      <div className={cn("relative h-full w-full", className)}>
        <img
          src={live.photoUri}
          alt={alt}
          loading="lazy"
          className="h-full w-full object-cover"
          onError={() => setLive(null)}
        />
        <p className="absolute bottom-1.5 right-2 text-[10px] italic text-white/80 drop-shadow">
          Photo:{" "}
          {live.attributionUri ? (
            <a
              href={live.attributionUri}
              target="_blank"
              rel="noopener noreferrer"
              className="underline"
            >
              {live.attribution || "Google"}
            </a>
          ) : (
            live.attribution || "Google"
          )}{" "}
          via Google
        </p>
      </div>
    );
  }

  return (
    <div
      className={cn(
        "flex h-full w-full items-center justify-center bg-card",
        className,
      )}
      aria-label={alt}
      role="img"
    >
      <Compass size={56} className="opacity-15" />
    </div>
  );
}