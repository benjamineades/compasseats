# Handoff: CompassEats, Sep 15, 2026 (late). Japan promoted. Next up: Spain & Andorra.

For a fresh execution chat. Ben is not a developer and often uses a phone. This chat runs reads through Supabase Read and gated writes through Supabase Write. It writes Cowork briefs and decisions files, and keeps the plan current. Fable gives rulings. This file replaces the earlier Sep 14–15 handoff for live state and open items. The rules in that handoff still apply (naming rulings 1–4, the five buttons, the city-insert SQL pattern, the Michelin page-reading method).

## How Ben works with this chat
- Plain language. Use `/ste` style for data replies: short sentences, no contractions, one step at a time.
- Every count states its population and grouping key.
- One "go" for each write batch. State the expected counts before the write. After the commit, read the counts back with a Read query.
- Under-merge beats over-merge. Competitor sites (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) are never a source. Note: enprimeurclub.com calls itself Pearl's app, so treat it as a competitor. Every claim needs a URL.
- Never hand-retype a data file. Ben uploads files with GitHub "Add file → Upload files".
- Use a fresh Cowork session for each guide, with a self-contained first message delivered as a `.md` file. Ben attaches it and types "Read the attached brief and do the job."
- Ben replies with one word at each gate: `staged`, `restaged`, `promoted`. Read the database at each gate. Do not trust the button summary alone.

## Live state (read back after the Japan promote)
Population: whole table.

venues **11,590** (active 11,210) · awards **24,101** · listings **11,590** · slugs **11,847** · cities 3,237 · city_label_source 23,464 · price 7,091 · source_capture_ledger 18 · Michelin 2026 award rows **3,216**.
`ingest_batches`: 4, all promoted: `first-batch-2026-09`, `michelin-2026-france`, `michelin-2026-italy`, `michelin-2026-japan` (id 5).
The earlier handoff said "4 batches" while only 3 existed. It is correct now.

## Japan (batch `michelin-2026-japan`): done
- 585 rows: Three Stars 20, Two Stars 61, One Star 276, Bib Gourmand 228. All rows have a `source_url`. Each row is on a different venue.
- Ceremony totals were 592 (Tokyo 2026: Sep 25, 2025. Kyoto Osaka 2026: Apr 23, 2026. Nara 2026: May 13, 2026). The live site shows 7 fewer.
- First stage: 421 match, 152 new_venue, 12 review. The decisions file changed this to 570 match and 15 new. Without it, the promote would have created about 150 duplicate venues.
- The 2027 selections for Tokyo, Kyoto-Osaka and Nara go live together on **Feb 16, 2027**.
- Files: `fixtures/ingest/michelin-2026-japan.csv` (16 columns, with extra columns `michelin_guide` and `name_native_michelin`) and `reports/michelin-2026-japan-decisions.csv` (164 rows). The Cowork brief `cowork-michelin-2026-japan.md` and the log `michelin-2026-japan-log.md` went to Ben as chat files. They are not in the repo. Use the brief as the model for the next brief.

## Method change proven on Japan: a match test before the stage step
The job matches only on an exact name key in the same city. The loose-name pass removes only a leading `Restaurant/Le/La/Les/L'/Hôtel` and a " - " suffix. All other name changes (place prefix, other romanization, Google-style names) arrive as **new_venue with no review**. So:

1. Before the stage step, pull the country's venues with their Michelin 2025 category. Copy the key rule into Python:
   `norm_key(t) = regexp_replace(lower(f_unaccent(t)), '[^a-z0-9]+', '', 'g')`, or NULL if the result has fewer than 3 characters. A Python copy (NFKD, remove combining marks, æ→ae, ø→o, ß→ss, œ→oe, đ/Đ→d, ł→l) agreed on 1,111 of 1,112 Japan venues.
2. After the stage step, read the rows that did not match:
   `ingest_rows(id, batch_id, raw, validation, verdict)`. `validation` holds `line`, `reason`, `detail`, `venue_id`, `decision`, `candidates`, `new_venue_group`. `raw._line` is the 1-based data row.
3. Pair each non-match row with a venue that no match already uses. The venue must be in the same city and have the same 2025 category. For names that do not agree, use Michelin's page (web search returns Michelin page text even though fetch is blocked). If you cannot pair a row, use `new`.
4. **`use:ve_x` works on new_venue rows too**, not only on review rows. `stage.ts` `applyVenueDecisions` applies a decision to any line. Put a decision for every non-match row in the file, for the audit trail.
5. Before delivery, make sure that each `use:` venue is used one time only, no match row already uses it, it is in the same city, and its category agrees.

## Decisions (and why)
- **Sukiyabashi Jiro Roppongiten → new.** `ve_b6eb74a0a2` mixes the Ginza main shop (W50B 2002–03) with Roppongi. It needs a split.
- **DIALOGUE → new.** "Dialog in the Dark Japan" also holds an unrelated Forbes 2020 award.
- **Wrong-name rows with only one award and the same category were used** (REI, Gigio, Mizuno, Az, Kikunoi Sushi Ao). **Two Nara rows were matched only because no other venue was left:** Naramachi Kuko → `ve_c0eba7ae71`, Ajinotabibito Roman → `ve_9b2a449b60`.
- **Confirmed on Michelin pages:** Torakuro is in the Imperial Hotel (`ve_cb4fd18f7c`). Kyo Seika has the same OAD 2025 #326 as `ve_7ba5a45715`. Ñ is in Azuchimachi, Osaka, so it is new and not "Daimaru Shinsaibashi".

## For Fable: the Michelin "2025" year label
The legacy Michelin rows marked 2025 appear to hold the **current** selection. For each country, compare venues that have both a 2025 row and a 2026 row:

| Country | Pairs | Same category | Changed |
|---|---|---|---|
| FR | 701 | 697 | 4 |
| IT | 311 | 310 | 1 |
| JP | 568 | 567 | 1 |

Real year-to-year comparisons change much more. Examples: Myojaku (2★→3★), Miyamaso (3★) and Fujitora (new Bib) all changed in the 2026 editions, but the database already shows the 2026 result on their 2025 rows. The promotes did not make this problem larger, but most venues now show two identical Michelin rows. **Fable must decide** what to do: relabel the rows, delete them, or keep them.

## Next guide: Spain & Andorra (published counts)
Gala in Málaga, Nov 25, 2025 (before the June 1, 2026 Green Star cutover, so the guide uses the name Green Star). Totals for Spain & Andorra: **16 Three Stars, 37 Two Stars, 254 One Star, 204 Bib Gourmand = 511**. Green Star 59. The whole selection is 1,295 restaurants, and 7 of them are in Andorra.
Sources: https://www.cope.es/emisoras/andalucia/malaga-provincia/malaga/noticias/guia-michelin-2026-enciende-30-nuevas-estrellas-gala-celebrada-malaga-20251126_3259685.html · https://guide.michelin.com/es/es/articulo/michelin-guide-ceremony/nuevos-bib-gourmand-de-la-guia-michelin-espana-2026
Special awards (from comerdeoficio.com, confirm them on Michelin's site):
- Service: Abel Valverde (Desde 1911)
- Sommelier: Luis Baselga (Smoked Room)
- Young Chef: Juan Carlos García (Vandelvira)
- Mentor: Quique Dacosta

Database now (Michelin 2025 rows): Spain 16 / 35 / 236 / 197 = 484. Andorra: one One Star row. No 2025 row has a `source_url`.
Things to do in the brief:
- Find the Spain slug and the Andorra slug with the site search box.
- Andorra rows get `country_label` Andorra.
- Make sure that no 2027 Spain selection is live yet.
- Expect city labels with real towns, while the 2025 rows use the nearest big city (Italy's D'O pattern). Expect `city_not_found`, and city inserts through gated SQL.
- Expect Spanish article and prefix names ("Casa", "El", "Restaurante") that the loose-name pass does not catch. Run the match test.

## Open items
- **Next step:** write `cowork-michelin-2026-spain.md` from the Japan brief (without Pass 2, or with a native-name pass only where it helps), and give it to Ben.
- **Monaco gap:** Monaco has 8 Michelin 2025 rows and 0 for 2026. The France batch read only the France list (Monaco site count 1/3/5/0). Add a small `michelin-2026-monaco` batch.
- 3-venue ingest CSV (Restaurante 040, Woda Ognista; Casa Prunes stays unknown). The source URLs are in Drive "CompassEats Staging".
- Salvatore at Playboy W50B Bars 2012 rank block (defect 2).
- France leftover: A Mandria di Pigna, one row, new key.
- **Special-awards batch, after the last guide.** Fix the vocabulary first. Add these venues:
  - Maxi (Italy)
  - LOUISE Osaka (Sommelier Award). Michelin lists it as Selected. Use URL `.../osaka-region/osaka/restaurant/louise-1201389`, because the bare slug goes to Louise Hong Kong.
- Japan Green Star counts for that batch: Tokyo 13, Kyoto 10, Osaka 3, Nara 7. Nara gave no special awards.
- Publish builder: new venues are `published=true` with no geo, photo or blurb (15 more from Japan). The builder must show honest-geo states or hide these venues.
- Delete stale branches (see earlier handoff).
- Plan v1.20 still needs to go to `docs/` and Project Knowledge. Add a v1.21 changelog row for Japan and the match-test method.

## Cleanup list additions (from Japan)
- **Wrong names that now carry 2026 awards:**
  - "Ginza Kojyu - prenotato il 27"
  - "Kikunoi Sushi Aoi / Niku Unshuu"
  - "Mizuno Shop Kyoto Shinkyogoku"
  - "Kyoto Seikaen"
  - "Nara Prison Museum by Hoshino Resorts"
  - "Naramachi Historic District"
  - "Ajimi Restaurant"
  - "Shibuya Tokyu REI Hotel"
  - "Giglio"
  - "Az/Bifun Azuma Osaka"
  - "Teikokuhoteru Toraguro"

  The rename job can fix these, with Michelin as the majority source only where no other publisher disagrees.
- **Japan `name_native` backfill.** The CSV `name_native_michelin` column has a Japanese name for all 585 rows. The 27 Japanese-script venues need their script moved to `name_native` before any rename.
- **Junk rows with a Michelin 2025 award and no 2026 partner:**
  - Tokyo Bib: "Tokyo", "Shinjuku City", "Tokyo Ramen Street", "Dialog in the Dark Japan"
  - Osaka 1★: "Daimaru Shinsaibashi"
- **No 2026 row:** Sézanne, Kabi, Bini, Konjiki Hototogisu, Soba-dokoro Kitahara.
- The Sukiyabashi Jiro split (see Decisions).

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-japan-done-2026-09-15.md) and the Japan brief (cowork-michelin-2026-japan.md). Japan is promoted. Start the Spain & Andorra batch: confirm live counts with a Read query, then write cowork-michelin-2026-spain.md as a downloadable file, modeled on the Japan brief, with the Spain & Andorra counts and traps from the handoff. Give me step-by-step directions in /ste style.
```
