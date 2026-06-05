/**
 * VenuePhoto — venue image with a tasteful charcoal fallback.
 *
 * When `src` is missing, renders a card-colored panel with a faint compass
 * mark so the layout doesn't collapse and the empty state still feels on-brand.
 */

import { cn } from "@/lib/utils";
import { Compass } from "./Compass";

export function VenuePhoto({
  src,
  alt,
  className,
}: {
  src?: string;
  alt: string;
  className?: string;
}) {
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