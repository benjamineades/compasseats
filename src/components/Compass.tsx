type CompassProps = { size?: number; spin?: boolean; className?: string };

/**
 * Small compass mark for the header lockup, footer, and inline use.
 * Driven by --primary via currentColor, so it is brass in dark mode and
 * bronze in light mode with no per-theme code. The center dot uses
 * --foreground so it reads in both themes.
 */
export function Compass({ size = 92, spin = false, className = "" }: CompassProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 92 92"
      fill="none"
      className={className}
      style={{ color: "var(--primary)" }}
      aria-hidden="true"
    >
      <circle cx="46" cy="46" r="43" stroke="currentColor" strokeWidth="1" opacity="0.4" />
      {spin && (
        <g
          className="animate-[spin_60s_linear_infinite]"
          style={{ transformOrigin: "center", transformBox: "fill-box" }}
        >
          <circle cx="46" cy="46" r="34" stroke="currentColor" strokeWidth="0.6" opacity="0.3" />
        </g>
      )}
      <path d="M46 12 L55 50 L46 60 L37 50 Z" fill="currentColor" />
      <path d="M46 80 L37 50 L46 40 L55 50 Z" fill="currentColor" opacity="0.4" />
      <circle cx="46" cy="50" r="2.6" fill="var(--foreground)" />
    </svg>
  );
}

/**
 * Large animated compass rose — the homepage hero centerpiece
 * (replaces RotatingEarth). Outer ring is static; the inner ring and
 * tick marks rotate slowly.
 */
export function HeroCompass({ className = "" }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 120 120"
      fill="none"
      role="img"
      aria-label="CompassEats"
      className={className}
      style={{ color: "var(--primary)" }}
    >
      <circle cx="60" cy="60" r="56" stroke="currentColor" strokeWidth="1" opacity="0.5" />
      <g
        className="animate-[spin_60s_linear_infinite]"
        style={{ transformOrigin: "center", transformBox: "fill-box" }}
      >
        <circle cx="60" cy="60" r="44" stroke="currentColor" strokeWidth="0.6" opacity="0.3" />
        <g stroke="currentColor" strokeWidth="1" opacity="0.55">
          <line x1="60" y1="16" x2="60" y2="24" />
          <line x1="60" y1="96" x2="60" y2="104" />
          <line x1="16" y1="60" x2="24" y2="60" />
          <line x1="96" y1="60" x2="104" y2="60" />
        </g>
      </g>
      <path d="M60 22 L67 60 L60 70 L53 60 Z" fill="currentColor" />
      <path d="M60 98 L53 60 L60 50 L67 60 Z" fill="currentColor" opacity="0.45" />
      <circle cx="60" cy="60" r="3.4" fill="var(--foreground)" />
    </svg>
  );
}

/** Wordmark: Fraunces, with "Eats" italic in the accent color (brass/bronze). */
export function Wordmark({ className = "" }: { className?: string }) {
  return (
    <span className={`font-display text-xl tracking-tight ${className}`}>
      Compass<span className="italic text-accent-strong">Eats</span>
    </span>
  );
}