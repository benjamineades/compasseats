export function RotatingEarth() {
  return (
    <div className="relative mx-auto flex aspect-square w-full max-w-xs items-center justify-center">
      {/* Stars */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden rounded-full opacity-60">
        <div className="absolute inset-[-20%] [background-image:radial-gradient(circle_at_20%_30%,#fff_0.5px,transparent_1px),radial-gradient(circle_at_70%_60%,#fff_0.5px,transparent_1px),radial-gradient(circle_at_45%_85%,#fff_0.5px,transparent_1px),radial-gradient(circle_at_85%_20%,#fff_0.5px,transparent_1px),radial-gradient(circle_at_10%_75%,#fff_0.5px,transparent_1px)] [background-size:120px_120px,180px_180px,90px_90px,150px_150px,200px_200px]" />
      </div>

      {/* Outer glow */}
      <div className="absolute inset-6 rounded-full bg-[radial-gradient(circle_at_30%_30%,oklch(0.74_0.13_55_/_35%),transparent_60%)] blur-2xl" />

      {/* Globe */}
      <div
        className="relative aspect-square w-[78%] overflow-hidden rounded-full shadow-[0_30px_80px_-20px_rgba(0,0,0,0.6),inset_-25px_-25px_60px_rgba(0,0,0,0.55),inset_18px_18px_40px_oklch(0.74_0.13_55_/_18%)]"
        style={{
          background:
            "radial-gradient(circle at 30% 30%, oklch(0.42 0.07 220), oklch(0.22 0.04 250) 70%, oklch(0.14 0.02 250) 100%)",
        }}
      >
        {/* Continents texture — repeating wrap, animated horizontally */}
        <div
          className="absolute inset-0 animate-[earth-spin_28s_linear_infinite] opacity-90 mix-blend-screen"
          style={{
            backgroundImage: `
              radial-gradient(ellipse 60px 90px at 18% 38%, oklch(0.55 0.10 145 / 0.85), transparent 65%),
              radial-gradient(ellipse 90px 50px at 30% 60%, oklch(0.58 0.11 140 / 0.8), transparent 70%),
              radial-gradient(ellipse 70px 110px at 50% 35%, oklch(0.56 0.10 145 / 0.85), transparent 70%),
              radial-gradient(ellipse 50px 80px at 62% 70%, oklch(0.57 0.11 140 / 0.8), transparent 70%),
              radial-gradient(ellipse 80px 60px at 82% 45%, oklch(0.55 0.10 145 / 0.85), transparent 70%),
              radial-gradient(ellipse 60px 90px at 118% 38%, oklch(0.55 0.10 145 / 0.85), transparent 65%),
              radial-gradient(ellipse 90px 50px at 130% 60%, oklch(0.58 0.11 140 / 0.8), transparent 70%)
            `,
            backgroundSize: "200% 100%",
            backgroundRepeat: "repeat-x",
          }}
        />
        {/* Cloud layer, slower */}
        <div
          className="absolute inset-0 animate-[earth-spin_60s_linear_infinite] opacity-30 mix-blend-screen"
          style={{
            backgroundImage: `
              radial-gradient(ellipse 100px 30px at 25% 30%, #fff, transparent 70%),
              radial-gradient(ellipse 140px 25px at 55% 55%, #fff, transparent 70%),
              radial-gradient(ellipse 90px 28px at 80% 25%, #fff, transparent 70%),
              radial-gradient(ellipse 100px 30px at 125% 30%, #fff, transparent 70%)
            `,
            backgroundSize: "200% 100%",
            backgroundRepeat: "repeat-x",
          }}
        />
        {/* Specular highlight */}
        <div className="absolute inset-0 rounded-full bg-[radial-gradient(circle_at_28%_22%,rgba(255,255,255,0.35),transparent_45%)]" />
        {/* Terminator shadow */}
        <div className="absolute inset-0 rounded-full bg-[radial-gradient(circle_at_75%_75%,rgba(0,0,0,0.55),transparent_60%)]" />
      </div>
    </div>
  );
}
