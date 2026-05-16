export function RotatingEarth() {
  return (
    <div className="relative mx-auto flex aspect-square w-full max-w-xs items-center justify-center">
      <svg
        viewBox="0 0 200 200"
        className="h-full w-full animate-[earth-spin_40s_linear_infinite] text-foreground/70"
        fill="none"
        stroke="currentColor"
        strokeWidth="0.75"
        strokeLinecap="round"
      >
        {/* Outer circle */}
        <circle cx="100" cy="100" r="80" />
        {/* Parallels */}
        <ellipse cx="100" cy="100" rx="80" ry="20" />
        <ellipse cx="100" cy="100" rx="80" ry="45" />
        <ellipse cx="100" cy="100" rx="80" ry="68" />
        {/* Meridians */}
        <ellipse cx="100" cy="100" rx="20" ry="80" />
        <ellipse cx="100" cy="100" rx="45" ry="80" />
        <ellipse cx="100" cy="100" rx="68" ry="80" />
        {/* Axis */}
        <line x1="100" y1="20" x2="100" y2="180" />
      </svg>
    </div>
  );
}
