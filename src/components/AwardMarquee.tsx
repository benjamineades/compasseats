const AWARDS = [
  "Michelin Guide",
  "World's 50 Best Restaurants",
  "World's 50 Best Bars",
  "James Beard Foundation",
  "Best Chef Awards",
  "Tales of the Cocktail Spirited Awards",
];

function Row() {
  return (
    <div className="flex shrink-0 items-center gap-3 pr-3">
      {AWARDS.map((a) => (
        <span
          key={a}
          className="whitespace-nowrap rounded-full border border-accent-strong/40 px-3.5 py-1.5 font-display text-xs tracking-wide text-accent-strong"
        >
          {a}
        </span>
      ))}
    </div>
  );
}

export function AwardMarquee() {
  return (
    <section className="mt-10" aria-label="Award sources">
      <p className="mb-3 text-center text-xs uppercase tracking-wide text-muted-foreground">
        Charted from the guides that matter
      </p>
      <div className="group relative overflow-hidden">
        <div className="pointer-events-none absolute inset-y-0 left-0 z-10 w-16 bg-gradient-to-r from-background to-transparent" />
        <div className="pointer-events-none absolute inset-y-0 right-0 z-10 w-16 bg-gradient-to-l from-background to-transparent" />
        <div className="flex w-max animate-marquee group-hover:[animation-play-state:paused]">
          <Row />
          <Row />
        </div>
      </div>
    </section>
  );
}