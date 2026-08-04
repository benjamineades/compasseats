import { useState, useRef, cloneElement, type ReactElement, type MouseEvent } from "react";
import { Link } from "@tanstack/react-router";
import { getCategoryNote } from "@/lib/award-descriptions";
import { useHoverCapable } from "@/hooks/use-hover-capable";
import { Popover, PopoverTrigger, PopoverContent } from "@/components/ui/popover";

/**
 * Wraps a single pill/badge element with a popover explaining the award
 * category in plain language. Opens on hover on devices that support it,
 * and on tap/keyboard focus everywhere. Every click on the trigger blocks
 * default behavior and stops propagation, so a badge nested inside a card
 * link never triggers navigation.
 *
 * Closing is delayed slightly (150ms) whenever the mouse leaves the trigger
 * OR the trigger loses focus, and that countdown is cancelled if the mouse
 * or focus lands on the popover content instead. This covers three input
 * types with one mechanism: a mouse user moving from badge to link, a touch
 * user tapping from badge to link (which moves focus, not the mouse), and a
 * keyboard user tabbing from badge to link.
 *
 * If no copy exists for the given source/category, renders the child
 * exactly as passed in, with no popover and no behavior change.
 */
export function AwardTooltip({
  source,
  category,
  children,
}: {
  source: string;
  category: string;
  children: ReactElement<any>;
}) {
  const note = getCategoryNote(source, category);
  const hoverCapable = useHoverCapable();
  const [open, setOpen] = useState(false);
  const closeTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  if (!note) return children;

  const clearCloseTimer = () => {
    if (closeTimer.current) {
      clearTimeout(closeTimer.current);
      closeTimer.current = null;
    }
  };

  const scheduleClose = () => {
    clearCloseTimer();
    closeTimer.current = setTimeout(() => setOpen(false), 150);
  };

  const childProps = (children.props ?? {}) as Record<string, any>;

  const trigger = cloneElement(children, {
    tabIndex: 0,
    onMouseEnter: hoverCapable
      ? () => {
          clearCloseTimer();
          setOpen(true);
        }
      : childProps.onMouseEnter,
    onMouseLeave: hoverCapable ? scheduleClose : childProps.onMouseLeave,
    onFocus: () => {
      clearCloseTimer();
      setOpen(true);
    },
    onBlur: scheduleClose,
    onClick: (e: MouseEvent) => {
      childProps.onClick?.(e);
      e.preventDefault();
      e.stopPropagation();
      clearCloseTimer();
      setOpen((o) => !o);
    },
    style: { ...(childProps.style ?? {}), cursor: "help" },
  } as any);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>{trigger}</PopoverTrigger>
      <PopoverContent
        className="w-72 text-sm"
        onMouseEnter={hoverCapable ? clearCloseTimer : undefined}
        onMouseLeave={hoverCapable ? scheduleClose : undefined}
        onFocus={clearCloseTimer}
        onBlur={scheduleClose}
      >
        <div>{note}</div>
        <div className="mt-2 border-t border-border pt-2">
          <Link
            to="/methodology"
            className="text-xs text-muted-foreground hover:text-foreground"
            onClick={() => {
              clearCloseTimer();
              setOpen(false);
            }}
          >
            Learn more →
          </Link>
        </div>
      </PopoverContent>
    </Popover>
  );
}
