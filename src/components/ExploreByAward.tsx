const AWARDS: { name: string; description: string }[] = [
  { name: "Michelin Guide", description: "The true north in fine dining." },
  { name: "World's 50 Best Restaurants", description: "The global benchmark for restaurant culture." },
  { name: "World's 50 Best Bars", description: "The definitive ranking of the world's cocktail bars." },
  { name: "James Beard Foundation", description: "America's most respected culinary honors." },
  { name: "Best Chef Awards", description: "The chef community's vote on the world's best." },
  { name: "Spirited Awards", description: "Tales of the Cocktail's tribute to the bar industry." },
];

export function ExploreByAward() {
  return (
    <section className="mt-16">
      <div className="mb-4">
        <h2 className="font-display text-xl text-foreground">Explore by award</h2>
        <p className="text-sm text-muted-foreground">The guides we chart from</p>
      </div>
      <div className="grid grid-cols-2 gap-2 md:grid-cols-3">
        {AWARDS.map((a) => (
          <div
            key={a.name}
            className="rounded-lg border border-border bg-card px-4 py-3"
          >
            <div className="font-display text-base text-foreground">{a.name}</div>
            <div className="mt-0.5 text-xs text-muted-foreground">{a.description}</div>
          </div>
        ))}
      </div>
    </section>
  );
}