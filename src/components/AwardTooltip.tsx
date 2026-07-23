import { useState, cloneElement, type ReactElement, type MouseEvent } from "react";
import { getCategoryNote } from "@/lib/award-descriptions";
import { useHoverCapable } from "@/hooks/use-hover-capable";
import { Popover, PopoverTrigger, PopoverContent } from "@/components/ui/popover";

/**
 * Wraps a single pill/badge element with a popover explaining the award
 * category in plain language. Opens on hover on devices that support it,
 * and on tap on touch devices. Every click on the trigger blocks default
 * behavior and stops propagation, so a badge nested inside a card link
 * never triggers navigation.
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

  if (!note) return children;

  const childProps = (children.props ?? {}) as Record<string, any>;

  const trigger = cloneElement(children, {
    tabIndex: 0,
    onMouseEnter: hoverCapable ? () => setOpen(true) : childProps.onMouseEnter,
    onMouseLeave: hoverCapable ? () => setOpen(false) : childProps.onMouseLeave,
    onFocus: () => setOpen(true),
    onBlur: () => setOpen(false),
    onClick: (e: MouseEvent) => {
      childProps.onClick?.(e);
      e.preventDefault();
      e.stopPropagation();
      setOpen((o) => !o);
    },
    style: { ...(childProps.style ?? {}), cursor: "help" },
  } as any);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>{trigger}</PopoverTrigger>
      <PopoverContent className="w-72 text-sm">{note}</PopoverContent>
    </Popover>
  );
}
