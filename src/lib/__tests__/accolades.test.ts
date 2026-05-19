import { describe, it, expect, beforeEach } from "vitest";
import {
  lookupAccolades,
  listAccoladesForCity,
  __test,
} from "@/lib/accolades.server";

beforeEach(() => __test.clearIndex());

describe("lookupAccolades — disambiguation", () => {
  it("merges multiple sheet rows for the same venue into strongest accolades", async () => {
    __test.setIndex([
      {
        name: "Eleven Madison Park",
        entry: { displayName: "Eleven Madison Park", michelinStars: 3, city: "new york", country: "usa" },
      },
      {
        name: "Eleven Madison Park",
        entry: {
          displayName: "Eleven Madison Park",
          worldsBest50Restaurants: { rank: 5, year: 2025 },
          city: "new york",
          country: "usa",
        },
      },
      {
        name: "Eleven Madison Park",
        entry: {
          displayName: "Eleven Madison Park",
          worldsBest50Restaurants: { rank: 22, year: 2022 },
          city: "new york",
          country: "usa",
        },
      },
    ]);
    const r = await lookupAccolades("Eleven Madison Park", "New York", "USA");
    expect(r?.michelinStars).toBe(3);
    // Most recent W50 wins the merge.
    expect(r?.worldsBest50Restaurants).toEqual({ rank: 5, year: 2025 });
  });

  it("returns null when country differs (different venue, same name)", async () => {
    __test.setIndex([
      {
        name: "Le Bernardin",
        entry: { displayName: "Le Bernardin", michelinStars: 3, city: "new york", country: "usa" },
      },
    ]);
    const r = await lookupAccolades("Le Bernardin", "Paris", "France");
    expect(r).toBeNull();
  });

  it("returns null when city differs within the same country", async () => {
    __test.setIndex([
      {
        name: "Alinea",
        entry: { displayName: "Alinea", michelinStars: 3, city: "chicago", country: "usa" },
      },
    ]);
    const r = await lookupAccolades("Alinea", "New York", "USA");
    expect(r).toBeNull();
  });

  it("picks the matching entry when same name exists in multiple cities", async () => {
    __test.setIndex([
      {
        name: "Quintonil",
        entry: { displayName: "Quintonil", michelinStars: 2, city: "mexico city", country: "mexico" },
      },
      {
        name: "Quintonil",
        entry: { displayName: "Quintonil (impostor)", michelinStars: 1, city: "madrid", country: "spain" },
      },
    ]);
    const r = await lookupAccolades("Quintonil", "Mexico City", "Mexico");
    expect(r?.michelinStars).toBe(2);
  });

  it("matches name with punctuation/accents normalized", async () => {
    __test.setIndex([
      {
        name: "L'Arpège",
        entry: { displayName: "L'Arpège", michelinStars: 3, city: "paris", country: "france" },
      },
    ]);
    const r = await lookupAccolades("LArpege", "Paris", "France");
    expect(r?.michelinStars).toBe(3);
  });

  it("returns null for venues not in the sheet (Yelp/TripAdvisor fallback path)", async () => {
    __test.setIndex([]);
    const r = await lookupAccolades("Some Random Diner", "Tulsa", "USA");
    expect(r).toBeNull();
  });
});

describe("country alias normalization", () => {
  it("matches USA sheet entry against 'United States' query", async () => {
    __test.setIndex([
      {
        name: "Per Se",
        entry: { displayName: "Per Se", michelinStars: 3, city: "new york", country: "usa" },
      },
    ]);
    const r = await lookupAccolades("Per Se", "New York", "United States");
    expect(r?.michelinStars).toBe(3);
  });

  it("matches UK aliases (United Kingdom vs England)", async () => {
    __test.setIndex([
      {
        name: "Core by Clare Smyth",
        entry: { displayName: "Core", michelinStars: 3, city: "london", country: "england" },
      },
    ]);
    const r = await lookupAccolades("Core by Clare Smyth", "London", "United Kingdom");
    expect(r?.michelinStars).toBe(3);
  });

  it("treats US state (NY) in JBA rows as USA", async () => {
    __test.setIndex([
      {
        name: "Gramercy Tavern",
        entry: {
          displayName: "Gramercy Tavern",
          jamesBeardAward: { name: "Outstanding Restaurant", year: 2023 },
          city: "new york",
          country: "usa", // build-time coercion already applied
        },
      },
    ]);
    const r = await lookupAccolades("Gramercy Tavern", "New York", "United States");
    expect(r?.jamesBeardAward?.year).toBe(2023);
  });
});

describe("listAccoladesForCity", () => {
  it("enumerates only venues matching the city + country", async () => {
    __test.setIndex([
      { name: "Atomix", entry: { displayName: "Atomix", michelinStars: 2, city: "new york", country: "usa" } },
      { name: "Le Bernardin", entry: { displayName: "Le Bernardin", michelinStars: 3, city: "new york", country: "usa" } },
      { name: "Disfrutar", entry: { displayName: "Disfrutar", michelinStars: 3, city: "barcelona", country: "spain" } },
    ]);
    const list = await listAccoladesForCity("New York", "USA");
    const names = list.map((v) => v.name).sort();
    expect(names).toEqual(["Atomix", "Le Bernardin"]);
  });
});