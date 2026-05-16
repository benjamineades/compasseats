// Minimalist spinning earth: thin line drawing of continents scrolling
// horizontally inside a circular sphere, with subtle meridians/parallels.
export function RotatingEarth() {
  return (
    <div className="relative mx-auto flex aspect-square w-full max-w-xs items-center justify-center text-foreground/70">
      <svg viewBox="0 0 200 200" className="h-full w-full" fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round">
        <defs>
          <clipPath id="globe-clip">
            <circle cx="100" cy="100" r="80" />
          </clipPath>
          {/* Continent silhouettes drawn across a 400-wide strip so it can loop seamlessly */}
          <symbol id="continents" viewBox="0 0 400 160" overflow="visible">
            {/* North America */}
            <path d="M18,40 q8,-18 26,-20 q14,-2 22,8 q10,8 6,22 q-2,10 -14,16 q-4,12 -16,14 q-12,2 -18,-8 q-12,-6 -10,-18 q-2,-8 4,-14 z" />
            {/* South America */}
            <path d="M62,92 q10,-6 18,4 q6,12 -2,24 q-2,14 -12,20 q-10,4 -14,-6 q-6,-12 0,-24 q2,-12 10,-18 z" />
            {/* Europe */}
            <path d="M180,40 q10,-8 22,-4 q12,2 14,12 q4,10 -6,16 q-10,8 -22,4 q-14,-2 -14,-14 q-2,-8 6,-14 z" />
            {/* Africa */}
            <path d="M188,72 q14,-6 26,2 q12,8 10,24 q0,16 -12,28 q-10,12 -22,8 q-12,-4 -14,-20 q-4,-14 2,-28 q2,-10 10,-14 z" />
            {/* Asia */}
            <path d="M232,34 q22,-10 50,-4 q28,4 38,20 q10,16 -6,28 q-18,12 -44,8 q-26,-2 -42,-14 q-12,-10 -10,-22 q2,-10 14,-16 z" />
            {/* Australia */}
            <path d="M308,108 q14,-6 28,0 q14,6 12,18 q-2,12 -16,16 q-16,4 -28,-4 q-10,-8 -8,-18 q2,-8 12,-12 z" />
            {/* Duplicate set shifted by 200 for seamless loop */}
            <g transform="translate(200,0)">
              <path d="M18,40 q8,-18 26,-20 q14,-2 22,8 q10,8 6,22 q-2,10 -14,16 q-4,12 -16,14 q-12,2 -18,-8 q-12,-6 -10,-18 q-2,-8 4,-14 z" />
              <path d="M62,92 q10,-6 18,4 q6,12 -2,24 q-2,14 -12,20 q-10,4 -14,-6 q-6,-12 0,-24 q2,-12 10,-18 z" />
            </g>
          </symbol>
        </defs>

        {/* Sphere outline */}
        <circle cx="100" cy="100" r="80" strokeWidth="1" />

        <g clipPath="url(#globe-clip)">
          {/* Parallels */}
          <g strokeWidth="0.5" opacity="0.5">
            <ellipse cx="100" cy="100" rx="80" ry="22" />
            <ellipse cx="100" cy="100" rx="80" ry="48" />
            <ellipse cx="100" cy="100" rx="80" ry="68" />
            <line x1="20" y1="100" x2="180" y2="100" />
          </g>

          {/* Scrolling continents */}
          <g strokeWidth="1" className="animate-[earth-drift_30s_linear_infinite]">
            <use href="#continents" x="20" y="20" width="320" height="160" />
            <use href="#continents" x="-180" y="20" width="320" height="160" />
            <use href="#continents" x="220" y="20" width="320" height="160" />
          </g>
        </g>
      </svg>
    </div>
  );
}
