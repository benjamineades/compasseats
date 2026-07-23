import { useEffect, useState } from "react";

/**
 * True if the current device supports hover (mouse, trackpad), false for
 * touch-only devices. Used to decide whether award badge popovers open on
 * hover (desktop) or only on tap (mobile), since Radix's Tooltip primitive
 * does not support touch at all and Popover needs to be told which mode
 * to behave in.
 */
export function useHoverCapable(): boolean {
  const [hoverCapable, setHoverCapable] = useState(true);

  useEffect(() => {
    const mql = window.matchMedia("(hover: hover)");
    setHoverCapable(mql.matches);
    const handler = (e: MediaQueryListEvent) => setHoverCapable(e.matches);
    mql.addEventListener("change", handler);
    return () => mql.removeEventListener("change", handler);
  }, []);

  return hoverCapable;
}