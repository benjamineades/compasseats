export function Compass({ size = 92, spin = false }: { size?: number; spin?: boolean }) {
  return (
    <svg width={size} height={size} viewBox="0 0 92 92" fill="none"
         style={{ color: "var(--primary)" }} aria-hidden="true">
      <circle cx="46" cy="46" r="43" stroke="currentColor" strokeWidth="1" opacity="0.4" />
      {spin && (
        <g className="origin-center animate-[spin_60s_linear_infinite]">
          <circle cx="46" cy="46" r="34" stroke="currentColor" strokeWidth="0.6" opacity="0.3" />
        </g>
      )}
      <path d="M46 12 L55 50 L46 60 L37 50 Z" fill="currentColor" />
      <path d="M46 80 L37 50 L46 40 L55 50 Z" fill="currentColor" opacity="0.4" />
      <circle cx="46" cy="50" r="2.6" fill="var(--foreground)" />
    </svg>
  );
}

export function Wordmark({ className = "" }: { className?: string }) {
  return (
    <span className={`font-display text-xl tracking-tight ${className}`}>
      Compass<span className="italic text-accent-strong">Eats</span>
    </span>
  );
}
