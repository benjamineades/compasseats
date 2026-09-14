# Ingest decisions — michelin-2026-france

Companion to `reports/michelin-2026-france-decisions.csv`. Measured against the
live database on 2026-09-14, read-only; nothing was written to it.

**The file proposes. You decide.** Every proposal sits in a `proposed` column
and the `decision` column stage actually reads is empty. Copy `proposed` into
`decision` for the rows you agree with — in Sheets that is one column paste —
and leave the rest for a second look. Then re-run **Ingest — stage** with the
same CSV, the same batch key, and `decisions_path` pointing at this file.

Read these three things first, in this order:

1. **Create the 40 cities** below by SQL. The job never creates a city, and 40
   `new` rows cannot land without one.
2. **The four blank rows.** They are blank because two CSV rows point at one
   venue and only you can say which.
3. **The eight `medium` rows.** Each names the exact thing to check.

Everything else is 503 rows at `high`.

---

## Counts

Population for every table here: the **515 rows that need a decision** — all 458
`new_venue`, all 45 `review_city`, all 12 `review_venue` from the stage report.
The other 556 rows of the batch matched and are not in this file.

### By proposal

| proposed | rows | what it means |
|---|---|---|
| `new` | 348 | nothing in the database is this venue |
| `use:ve_x` | 161 | this row is that existing venue |
| _(blank)_ | 4 | two CSV rows want the same venue — your call |
| `city:ci_x` | 1 | the city exists, the label just cannot reach it |
| `skip` | 1 | Pigna — leave it out until the city row is settled |

### By confidence

| confidence | rows | what it means |
|---|---|---|
| high | 503 | 348 `new` with no candidate at all, 153 `use:` where the 2025 and 2026 tiers agree, plus the `city:` and the `skip` |
| medium | 8 | worth a look: the reason column says exactly why |
| _(none)_ | 4 | the blank rows; there is no proposal to be confident about |

### By stage verdict and proposal

| stage verdict | proposed | rows |
|---|---|---|
| new_venue | `new` | 301 |
| new_venue | `use:ve_x` | 155 |
| new_venue | _(blank)_ | 2 |
| review_city | `new` | 40 |
| review_city | `use:ve_x` | 3 |
| review_city | `city:ci_x` | 1 |
| review_city | `skip` | 1 |
| review_venue | `new` | 7 |
| review_venue | `use:ve_x` | 3 |
| review_venue | _(blank)_ | 2 |

The headline: **155 of the 458 `new_venue` rows are not new.** They are already
in the database in the same city, under the other naming convention.

---

## The blank rows — for Ben

Four rows, two pairs. In each pair both CSV rows reduce to the same name and
both point at one existing venue. One of them is that venue and the other is a
second restaurant that shares a name, and this file will not guess which.

| line | csv_name | csv_city | the venue both want |
|---|---|---|---|
| 349 | Les Fresques - Château des Vigiers | Monestier | `ve_3a24173df2` Fresques, Évian-les-Bains, One Star 2025 |
| 562 | Les Fresques - Hôtel Royal | Évian-les-Bains | `ve_3a24173df2` — same venue |
| 710 | L'Atelier | Montaigu | `ve_101f57b1dc` Restaurant L'Atelier, Issigeac, Bib 2025 |
| 844 | L'Atelier | Issigeac | `ve_101f57b1dc` — same venue |

In both pairs the second row is the one whose city already matches, so the
likely answer is `use:` on 562 and 844 and `new` on 349 and 710 — but that is a
guess about two restaurants, not a measurement, so it is not written down as a
proposal.

---

## Cities to create

40 cities, one row each, every one of them France. Create them before the
re-stage; the job never creates a city, and each of these rows carries a `new`
proposal that cannot land without one.

| label | country | rows | csv line |
|---|---|---|---|
| Alleyras | France | 1 | 434 |
| Ammerschwihr | France | 1 | 519 |
| Arcachon | France | 1 | 182 |
| Bellevigne-en-Layon | France | 1 | 173 |
| Binic | France | 1 | 126 |
| Cassel | France | 1 | 183 |
| Chaintré | France | 1 | 447 |
| Charols | France | 1 | 522 |
| Chartres | France | 1 | 208 |
| Clichy | France | 1 | 791 |
| Èze-Bord-de-Mer | France | 1 | 641 |
| Fontevraud-l'Abbaye | France | 1 | 178 |
| Lamorlaye | France | 1 | 790 |
| Le Broc | France | 1 | 409 |
| Le Lavandou | France | 1 | 614 |
| Le Mans | France | 1 | 176 |
| Le Reposoir | France | 1 | 1034 |
| Lembach | France | 1 | 505 |
| Levernois | France | 1 | 433 |
| Lucinges | France | 1 | 552 |
| Malbuisson | France | 1 | 508 |
| Mayenne | France | 1 | 161 |
| Montbazon | France | 1 | 201 |
| Montenach | France | 1 | 419 |
| Noyal-sur-Vilaine | France | 1 | 146 |
| Parnac | France | 1 | 377 |
| Piré-Chancé | France | 1 | 147 |
| Pont-du-Château | France | 1 | 406 |
| Pujaut | France | 1 | 542 |
| Riquewihr | France | 1 | 520 |
| Saint-Didier-de-la-Tour | France | 1 | 514 |
| Saint-Paul-de-Vence | France | 1 | 626 |
| Saint-Pée-sur-Nivelle | France | 1 | 196 |
| Taillades | France | 1 | 1033 |
| Tresserve | France | 1 | 544 |
| Uzès | France | 1 | 504 |
| Villars | France | 1 | 1042 |
| Villeneuve-lès-Avignon | France | 1 | 549 |
| Vinay | France | 1 | 371 |
| Vincennes | France | 1 | 345 |

That is 40 of the 43 `city_not_found` rows. The other three are not missing
cities at all:

| line | label | what is actually going on |
|---|---|---|
| 2 | L'Herbaudière | the hamlet on Noirmoutier; the venue is already in `noirmoutier-en-lile` — `use:` proposed |
| 82 | Collonges-au-Mont-d'Or | Paul Bocuse's commune; the venue is already in `lyon` — `use:` proposed |
| 1069 | Pigna | the city row exists — see below |

Two more labels come through as `country_label_disagrees` rather than
`city_not_found`, and they are not missing cities either:

| line | label | what is actually going on |
|---|---|---|
| 991 | Munster | `cities` holds `munster-fr`, display "Munster, France"; `use:` proposed on the venue already in it |
| 992 | Munster | same city; no venue candidate, so `city:ci_aafc2b6136` — the job creates the venue itself once the city is set |

**Do not create a Munster.** One is already there.

### Pigna

`cities` holds `pigna` (`ci_92d5a8ab3d`), display "Pigna", **with no country at
all**, and `ve_6abba077f0` "A Mandria di Pigna" — a Bib Gourmand 2025 — sits in
it. The row never reaches it because a blank country plus a "France" hint is
UNKNOWN, not agreement, and the resolver drops candidates it cannot vouch for
(the three-valued logic in `lib/resolve.ts`).

The proposal is `skip`. There is a Pigna in Corsica and a Pigna in Liguria; a
city row with no country is not a thing this batch should decide. Give that row
a country, then stage the line under a new key.

---

## Where the two patterns collide

One row in the batch had both: a loose candidate in its own city **and** one in
another city.

| line | csv_name | csv_city | same city | other city |
|---|---|---|---|---|
| 532 | Le Relais de la Poste | La Wantzenau | `ve_16bdd233b0` Hôtel-Restaurant Le Relais de la Poste, One Star 2025 | `ve_8859261736` Relais De La Poste, Magescq, One Star 2025 |

It resolves itself: line 204 of this same batch already matches the Magescq
venue exactly, so that candidate is spoken for and the same-city one is the
only one left. `use:ve_16bdd233b0`, high. No other row in the batch has both.

---

## How the candidates were found

For every one of the 515 rows, against the live database:

- **Population searched.** Venues in a French city — `cities.country_iso = 'FR'`
  (595 cities) plus the 21 cities with a blank country, 616 in all — that hold a
  Michelin **2025** row. 988 venues.
- **Compared on** the name reduced to letters and digits, unaccented and
  lowercased by the database's own `f_unaccent`, after dropping a leading
  `restaurant`, `le`, `la`, `les`, `l`, `hotel`/`hôtel` repeatedly, and after
  cutting the **CSV** name at the first `" - "`. A key under three characters is
  no key, the same floor `norm_key` itself applies. Stored names are not cut at
  the dash: cutting both sides is a wider rule than the evidence supports.
- **Same city first, then any French city.** A candidate in another city is
  pattern 2 — the database kept the nearest big city, Michelin prints the
  commune — and is proposed at `medium` with `city differs: db <slug>, michelin
  <label>` in the reason. The venue is never moved.

Three things narrow that further, and each one is in the `reason` column of the
rows it touched:

1. **A venue another row of this batch already speaks for is not a candidate
   here.** Twelve rows lost a candidate this way, and it is what keeps the Paris
   "Origines" with the Paris row (line 276) instead of handing it to Le Broc
   (line 409), and the Paris "Baca'v" with line 823 instead of
   Boulogne-Billancourt (line 786). A candidate is dropped when another row
   matched it exactly, or when another row sits in that candidate's own city
   under a name the candidate's name is the start of.
2. **Two rows may not propose the same venue.** Both go blank — the four rows
   above.
3. **Six rows got a candidate the brief's population would have missed**, and
   they are in the file because proposing `new` for them would have created a
   duplicate:
   - lines 31, 83, 97, 105 — L'Auberge des Glazicks, Mère Brazier, L'Auberge de
     Saint-Rémy, La Voile. Each is already in its own city, from another guide
     (La Liste, Gault&Millau, The Best Chef), holding no Michelin 2025 row. All
     four are `medium`: there is no 2025 tier to compare.
   - lines 336, 914 — "AT" in Paris and "So" in Dijon. These are the
     `norm_key_too_short` rows, where no key can match automatically; both exist
     under the same name written out. 914 is `high` (Bib in both years), 336 is
     `medium` (no Michelin 2025 row).
   - Line 296, "ES" in Paris, has nothing: `new`.

### One number in the brief does not survive contact with the data

The brief said 304 of the 458 `new_venue` rows have exactly one same-city loose
candidate, 2 have several, and 152 have none. Measured, under the rule the brief
itself specifies:

| | rows |
|---|---|
| exactly one same-city candidate | **152** |
| several same-city candidates | **0** |
| no same-city candidate | **306** — of which 6 have a candidate only in another city, so 300 have none anywhere |

152 appears on both sides, so the two figures look transposed. Widening the rule
does not get near 304 either: cutting the stored name at the dash as well gives
198, cutting both sides at any hyphen gives 194, and dropping the Michelin-2025
requirement gives 156.

The 161 `use:` proposals come from three places: **152** same-city (154
candidates, less the two that went blank), **3** other-city, and **6** from the
widenings in point 3 above.

Worth knowing: **every one of the 154 same-city candidates carries the same
Michelin tier in 2025 as the 2026 row claims.** Not one promotion or demotion
among them. That is why 153 of the `use:` proposals are `high` — a loose name
match in the same commune that also agrees on the award is about as good as this
gets without a human.

---

## Timings

| step | took | detail |
|---|---|---|
| the stage run this file is built on | 3.5s | 1,071 rows, batch 3, `reports/michelin-2026-france-stage.md` |
| candidate search, live, read-only | ~25s over 8 statements | the 988-venue population, the 515 rows' keys, the claim checks and the city lookups |
| building this file and the CSV | 0.07s | 515 rows, no database |
| the ingest suite, with the stage fix | 11.6s | 40 tests, throwaway Postgres |

The stage fix adds one phase, **loose-name pass**, which prints in the timings
table of every future run. It looks only at rows the exact pass left as
`new_venue`, and only in those rows' own cities, so it is one indexed query per
chunk rather than a scan: on the test database the 1,071-row fixture goes
through it in under 0.1s. It has not been measured against the live instance
from here — staging writes, and this session's connector is read-only.
