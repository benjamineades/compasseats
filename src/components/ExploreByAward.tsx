import { Link } from "@tanstack/react-router";

const AWARDS: { slug: string; name: string; description: string }[] = [
  { slug: "michelin", name: "Michelin Guide", description: "The true north in fine dining." },
  { slug: "worlds-50-best-restaurants", name: "World's 50 Best Restaurants", description: "The global benchmark for restaurant culture." },
  { slug: "worlds-50-best-bars", name: "World's 50 Best Bars", description: "The definitive ranking of the world's cocktail bars." },
  { slug: "james-beard", name: "James Beard Awards", description: "America's most respected culinary honors." },
  { slug: "best-chef-awards", name: "Best Chef Awards", description: "The chef community's vote on the world's best." },
  { slug: "spirited-awards", name: "Spirited Awards", description: "Tales of the Cocktail's tribute to the bar industry." },
  { slug: "oad", name: "OAD Top Restaurants", description: "A community-driven ranking from the world's most serious diners." },
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
          <Link
            key={a.slug}
            to="/award/$award"
            params={{ award: a.slug }}
            className="group rounded-lg border border-border bg-card px-4 py-3 transition-colors hover:border-primary/50 hover:bg-accent"
          >
            <div className="font-display text-base text-foreground group-hover:text-accent-strong">{a.name}</div>
            <div className="mt-0.5 text-xs text-muted-foreground">{a.description}</div>
          </Link>
        ))}
      </div>
    </section>
  );
}