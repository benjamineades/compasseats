import earthTexture from "@/assets/earth-texture.jpg";

// Photoreal spinning earth: equirectangular texture scrolled horizontally
// inside a circular mask, with radial shading + atmospheric glow for a sphere illusion.
export function RotatingEarth() {
  return (
    <div className="relative mx-auto flex aspect-square w-full max-w-xs items-center justify-center">
      {/* Atmospheric glow */}
      <div className="absolute inset-4 rounded-full bg-[radial-gradient(circle_at_50%_50%,rgba(120,180,255,0.35),transparent_65%)] blur-2xl" />

      {/* Sphere */}
      <div className="relative aspect-square w-[86%] overflow-hidden rounded-full shadow-[0_30px_80px_-20px_rgba(0,0,0,0.6)]">
        {/* Earth texture, scrolling */}
        <div
          className="absolute inset-0 animate-[earth-spin_40s_linear_infinite]"
          style={{
            backgroundImage: `url(${earthTexture})`,
            backgroundSize: "200% 100%",
            backgroundRepeat: "repeat-x",
          }}
        />
        {/* Specular highlight */}
        <div className="pointer-events-none absolute inset-0 rounded-full bg-[radial-gradient(circle_at_30%_25%,rgba(255,255,255,0.35),transparent_45%)]" />
        {/* Terminator / day-night shadow */}
        <div className="pointer-events-none absolute inset-0 rounded-full bg-[radial-gradient(circle_at_75%_75%,rgba(0,0,10,0.65),transparent_60%)]" />
        {/* Inner rim */}
        <div className="pointer-events-none absolute inset-0 rounded-full shadow-[inset_-20px_-20px_55px_rgba(0,0,0,0.55),inset_15px_15px_40px_rgba(120,170,255,0.18)]" />
      </div>
    </div>
  );
}
