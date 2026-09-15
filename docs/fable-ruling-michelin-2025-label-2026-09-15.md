# Fable ruling: the Michelin "2025" year label
CompassEats · Sep 15, 2026 · Read-only. No writes were made. No file in the repo or Project was changed.

## The ruling in two sentences
The legacy Michelin rows marked 2025 are a snapshot of the Michelin website taken between May 13 and June 1, 2026, so the year on them is a capture date, not an edition year. Do not relabel them in bulk. Retire each legacy row in a gated batch when a sourced 2026 row now sits on the same venue, and leave the rest alone until their guide gets a batch. The rows on venues that will not get a batch soon get a per-guide fix only after a written edition test.

One more finding changes the order of work. The France and Italy promotes created about 200 to 270 twin venues each, because those batches ran before the match test existed. Section 6 covers this.

---

## 1. What the 2025 rows are

### 1.1 The label came from the Sheet
The Sheet overview tab lists the Michelin tab with "Years Covered: Current". The other tabs list real year ranges. So the migration wrote one fixed year on rows that the Sheet never dated.
Source: the Sheet overview tab, https://docs.google.com/spreadsheets/d/1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s/edit

### 1.2 Population
Query: `awards` where `source_id='michelin'`, grouped by year.

| Year | Rows | Rows with `source_url` | Distinct venues |
|---|---|---|---|
| 2023 | 18 | 0 | 18 |
| 2024 | 25 | 0 | 25 |
| 2025 | 7,136 | 1 | 7,101 |
| 2026 | 3,216 | 2,288 | 3,212 |

The 2,288 rows with a URL are the three job batches (France 1,070, Italy 632, Japan 585 = 2,287) plus one Vietnam Green Star row. The 928 rows without a URL are older 2026 rows in DE, DK, FI, FO, HR, IS, LT, NO, NZ, PL, SE, SI, US and VN. The one 2025 row with a URL is a Korea Bib Gourmand row.

### 1.3 The capture window
I tested named promotions against the legacy rows. Each test reads the legacy row (year 2025, no URL) for one venue.

| Guide | 2026 edition date (URL) | Test venue | Published 2026 result | Legacy row says | Verdict |
|---|---|---|---|---|---|
| Italy | Nov 19, 2025 (lapresse.it, Nov 19, 2025) | La Rei Natura, Serralunga d'Alba | new Three Stars | Three Stars | legacy = 2026 |
| Spain & Andorra | Nov 25, 2025 (cope.es) | Aleia, Enigma, Mont Bar (Barcelona) · EMi (Madrid) | new Two Stars · new One Star | Two Stars · One Star | legacy = 2026 |
| France | Mar 16, 2026 (journalduluxe.fr) | Les Morainières, Jongieux · Hakuba, Paris · Arbane, Reims | new Three · new Two · new Two | Three · Two · Two | legacy = 2026 |
| Kyoto Osaka | Apr 23, 2026 (handoff) | Miyamasou, Kyoto | Three Stars | Three Stars | legacy = 2026 |
| Nara | May 13, 2026 (guide.michelin.com, Nara 2026 article) | Hoshino, new One Star (in the database under the wrong name "Nara Prison Museum by Hoshino Resorts") | new One Star | One Star | legacy = 2026 |
| Nordic Countries | Jun 1, 2026 (guide.michelin.com, Nordic 2026 article) | Kadeau, Copenhagen | promoted to Three Stars | Two Stars | legacy = 2025 |
| Germany | Jun 23, 2026 (hogapage.de, Jun 24, 2026) | L.A. Jordan, Deidesheim | promoted to Three Stars | Two Stars | legacy = 2025 |

So the snapshot includes the Nara 2026 selection (May 13, 2026) and does not include the Nordic 2026 selection (June 1, 2026). The capture happened in that window. This is consistent with one capture. It is not proof of one capture, because two legacy rows show a pre-2026 state:
- L'Ambroisie, Paris: legacy Three Stars. Michelin moved it to Two Stars for 2026 (announced Mar 10, 2026, gillespudlowski.com). The sourced 2026 row says Two Stars.
- Kohaku, Tokyo: legacy Three Stars. The sourced 2026 row says Two Stars (URL on the row).
I cannot say why these two rows are stale. A mixed source in the Sheet is the likely cause. I cannot establish it.

### 1.4 What "legacy = 2026" means for counts
The snapshot is incomplete for some guides. Population: legacy Michelin 2025 rows by country and category.
- Spain: 16 / 35 / 236 / 197 = 484. Published 2026 totals: 16 / 37 / 254 / 204 = 511. The rows hold 2026 results but 27 rows are missing. The Ramón Freixa Atelier (new Two Stars 2026) has no row at all.
- Italy: 15 / 33 / 312 / 252 Bib. Published 2026 stars: 15 / 38 / 341. The rows hold 2026 results but stars are short by 5 and 29.
- France: 31 / 60 / 478 / 412 Bib. The France & Monaco 2026 selection has 31 Three Stars in total (France plus Monaco). The database counts Monaco separately, so the France 31 has one extra row. I did not trace it.

### 1.5 The older 2026 rows (928, no URL) are correct
Kadeau (DK) and L.A. Jordan (DE) each have a 2025 row with the old category and a 2026 row with the new category. For those guides the two years are real history. Do not touch those rows in this work.

### 1.6 Per-guide status of the legacy rows
| Guides | Legacy 2025 rows hold | Basis |
|---|---|---|
| France, Italy, Japan (Tokyo, Kyoto Osaka, Nara), Spain & Andorra | the 2026 edition | named promotions above |
| Every guide whose 2026 edition was published before May 13, 2026 | the 2026 edition, expected | ceremony date only. Test three named promotions before you act. |
| Nordic Countries, Germany | the 2025 edition | Kadeau, L.A. Jordan |
| Every guide whose 2026 edition was published after June 1, 2026 | the 2025 edition, expected | ceremony date only. Test before you act. |
| Guides with a 2026 edition dated May 13 to June 1, 2026 | unknown | test decides |

I did not establish the ceremony date for every guide. The Opus chat must find each date on a Michelin URL before it touches that guide.

---

## 2. The ruling and why

### 2.1 The rule
1. A legacy Michelin row (year 2025, no `source_url`) is a claim with no per-row source. A job row (year 2026, with `source_url`) is a sourced claim. When both sit on the same venue, the job row is the record and the legacy row is retired.
2. Retire means delete, in one gated batch per guide, with expected counts stated first and read back after. The batch key and the counts go in the plan changelog. This is not a silent delete.
3. The retire batch runs for every venue with a sourced twin, same category or not. The six different-category cases are listed by award id in section 4 and get their own small batch, so you can look at each one.
4. A legacy row with no sourced twin keeps its 2025 label until the guide batch lands. The batch gives it a sourced twin, then rule 2 retires it.
5. A guide that will not get a batch soon can get a relabel batch (2025 to 2026) only when all of these are true: the ceremony date is on a Michelin URL and is before May 13, 2026, three named promotions from that ceremony match the legacy rows, and the decisions file records the URLs and the three tests. The batch note must say "edition year set from the ceremony date, capture May 13 to June 1, 2026, no per-row URL".
6. Never relabel a row on a venue that also carries an older 2026 row without a URL (the 928 rows). Those venues already have real history.

### 2.2 Why this and not the other options
**Relabel all 2025 rows to 2026, then dedupe.** Rejected as a bulk step. It would be wrong for Nordic, Germany and every guide published after June 1, 2026. Kadeau would show two 2026 rows, Two Stars and Three Stars, on one venue. It also asserts an edition year with no source on 7,136 rows in one move. Rule 5 keeps relabel as a narrow, tested, per-guide tool.

**Delete only where a 2026 row exists, nothing else.** Accepted as the main step, but not enough on its own. It leaves 280 France venues, 300 Italy venues and 11 Japan venues with a stale 2025 label. Most of those are twin venues (section 6), so the delete alone does not clean the site.

**Keep the rows and mark them unverified.** Rejected. The `awards` table has no such column, so this needs a schema change. The site shows every year per source, so a visitor would still read "2025" on a 2026 fact, and a venue would still show two Michelin rows.

**Undo the France and Italy promotes.** Not chosen here because I cannot see what the undo path reverses. `ingest_batches` has `undone_at`. If the undo job reverses venues, slugs, listings, awards and city labels from one batch, then undo plus a re-run with the match test is a cleaner fix for the twins than a merge file. The Opus chat must read the code and report before anyone picks that path.

### 2.3 What this protects
- No visitor sees a distinction under a wrong year on a venue that has a sourced row.
- No venue with one Michelin award shows two rows for it.
- Real history (Kadeau 2025 Two Stars, 2026 Three Stars) stays.
- Every delete is gated, counted and read back.

---

## 3. How it applies

### 3.1 Guides already done (France, Italy, Japan)
Run the retire batches in section 4. Then run the twin cleanup for France and Italy (section 6). Japan is clean because the match test ran there.

### 3.2 Spain & Andorra
Yes, the Spain batch can go ahead before this ruling is carried out. Your assumption is right. A promote only adds 2026 rows. After the Spain promote, run the same retire batch for ES and AD. Expected: about 480 legacy rows get a sourced twin. The exact count comes from the read query in section 4 after the promote.

Two things for the Spain brief:
- The match test must pull "the venue's latest Michelin category from the legacy rows", not "the 2025 category". Both are the same today, but the wording must not lock the year.
- The 27 missing Spain rows and Ramón Freixa Atelier will arrive as `new_venue`. That is correct. Do not pair them.

### 3.3 Every guide still ahead
Same as Spain. Promote first, retire second, one gated batch each.

### 3.4 Guides that will not get a batch soon
Use rule 5 or leave the rows alone. Leaving them alone is the safe default. Note that these venues show "Michelin 2025" on the site until then. If Ben wants that fixed sooner, the relabel batch is the tool, one guide at a time, after the three-promotion test.

### 3.5 Guides published after June 1, 2026
Do nothing. Their 2025 label is right. When their batch runs, the job adds 2026 rows and the 2025 rows stay as history. Only retire a 2025 row when its 2026 twin has the same category and the guide is proven to be a 2026-edition capture. For these guides that never happens, so the retire batch has zero expected rows.

---

## 4. Execution brief for the Opus chat

Do not run these until Ben says "go" for each batch. Every batch is one `BEGIN … COMMIT`. State the expected count, run, read back, compare.

### 4.0 Read query (population: legacy Michelin rows with a sourced twin, one country)
```sql
select a25.id, a25.venue_id, a25.category as cat25, a26.category as cat26
from awards a25
join awards a26
  on a26.venue_id = a25.venue_id
 and a26.source_id = 'michelin'
 and a26.year = 2026
 and a26.source_url is not null
join venues v on v.id = a25.venue_id
join cities c on c.id = v.city_id
where a25.source_id = 'michelin'
  and a25.year = 2025
  and a25.source_url is null
  and c.country_iso = 'JP';   -- change the country
```
Counts read on Sep 15, 2026:

| Country | Legacy rows with a sourced twin | Same category | Different category | Venues |
|---|---|---|---|---|
| FR | 701 | 697 | 4 | 698 |
| IT | 311 | 310 | 1 | 310 |
| JP | 568 | 567 | 1 | 568 |

### 4.1 Batch `retire-michelin-legacy-jp` (same category only)
Expected delete: **567** rows.
```sql
begin;
delete from awards a
using awards b, venues v, cities c
where a.source_id = 'michelin' and a.year = 2025 and a.source_url is null
  and b.venue_id = a.venue_id and b.source_id = 'michelin' and b.year = 2026
  and b.source_url is not null and b.category = a.category
  and v.id = a.venue_id and c.id = v.city_id and c.country_iso = 'JP';
-- read back inside the transaction: the 4.0 query for JP must return 1 row (Kohaku, award 1233).
commit;
```
Read back after commit: `awards` total 24,101 − 567 = **23,534**. Michelin 2025 rows 7,136 − 567 = **6,569**. No venue in JP has two Michelin rows of the same category.

### 4.2 Batch `retire-michelin-legacy-fr` (same category only)
Expected delete: **697**. Same SQL with `c.country_iso = 'FR'`. Read back: the 4.0 query for FR returns 4 rows (awards 865, 5244, 5237, 7723). `awards` total after 4.1 and 4.2: **22,837**.

### 4.3 Batch `retire-michelin-legacy-it` (same category only)
Expected delete: **310**. Same SQL with `'IT'`. Read back: the 4.0 query for IT returns 1 row (award 6420). `awards` total: **22,527**.

### 4.4 Batch `retire-michelin-legacy-mismatch` (six rows by id)
| Award id | Venue | Legacy says | Sourced 2026 row says | Note |
|---|---|---|---|---|
| 865 | L'Ambroisie, Paris | Three Stars | Two Stars | demotion published Mar 10, 2026 |
| 1233 | Kohaku, Tokyo | Three Stars | Two Stars | open the row's URL before delete |
| 5244 | Briketenia, Guéthary | Bib Gourmand | One Star | venue also has a legacy One Star row, retired in 4.2 |
| 5237 | Maison Tiegezh, Guer | Bib Gourmand | One Star | same pattern |
| 7723 | Villa Salone, Salon de Provence | Bib Gourmand | One Star | same pattern |
| 6420 | Restaurant La Pineta, Marina di Bibbona | Bib Gourmand | One Star | same pattern |

Expected delete: **6**.
```sql
begin;
delete from awards where id in (865, 1233, 5244, 5237, 7723, 6420)
  and source_id = 'michelin' and year = 2025 and source_url is null;
commit;
```
Read back: the 4.0 query returns 0 rows for FR, IT and JP. `awards` total: **22,521**.

Ristorante La Torre, Tavarnelle Val di Pesa (IT) has two legacy rows (Bib Gourmand and One Star) and no sourced twin. Leave it. It belongs to the Italy twin cleanup.

### 4.5 After each future promote (Spain next)
Run the 4.0 query for the country. State the count. Run 4.1 with that country. Then run the mismatch read for that country and handle each row by id.

### 4.6 Order of the remaining work
1. Retire batches 4.1 to 4.4 (safe now, small, no dependencies).
2. Spain & Andorra batch, then its retire batch.
3. France and Italy twin cleanup (section 6). This can run in parallel with Spain if Ben has two chats. It must finish before the rename job touches France or Italy names again, because a merge changes which venue keeps the name.
4. The rest of the guides, each with promote then retire.
5. Rename job.
6. Special-awards batch, after the last guide, as planned.

### 4.7 Ledger
Each retire batch writes one `source_capture_ledger` row: publisher `michelin`, field_type `award`, items = rows deleted, job `retire:<batch_key>`. Keep the same shape as the promote rows.

---

## 5. Effects on the site and the plan

### 5.1 What the site shows
The design system shows every year per source, with the newest year in the header and prior years on expand. So today a France venue shows "★★ Michelin 2026" with a "2025 ★★" line under it. The 2025 line is not a verified fact. After the retire batches, the venue shows one Michelin row. Kadeau keeps 2025 Two Stars and 2026 Three Stars, which is real.

### 5.2 History
The site can only show history that the database has a source for. After this ruling, Michelin history on a venue exists only where a guide's 2025 edition and 2026 edition were both captured (Nordic, Germany and the other 928-row guides) or where a future batch adds a dated row. That is honest. Do not build history from the legacy snapshot.

### 5.3 Publish builder
No change to the builder rule. One addition to the invariant suite: **no venue carries two Michelin rows with the same year and category**, and **no venue carries two Michelin rows with the same year from different sources of truth (one with URL, one without)**. The retire batches make both true for FR, IT and JP.

### 5.4 Plan document (v1.21 changelog)
Record these lines:
- The legacy Michelin year 2025 is a capture label. Capture window May 13 to June 1, 2026. Evidence: Nara 2026 in (Hoshino), Nordic 2026 out (Kadeau), Germany 2026 out (L.A. Jordan). Two stale rows noted (L'Ambroisie, Kohaku).
- Rule: sourced row wins, legacy twin retired in a gated batch per guide. Relabel only per guide after a three-promotion test. Never relabel a venue with an older 2026 row.
- The Sheet overview marks the Michelin tab "Current". Any future import from a "Current" list must carry a capture date, not a year.
- France and Italy promotes created twin venues (section 6). Cleanup is a tracked work item.

---

## 6. New finding: twin venues from the France and Italy promotes

### 6.1 What the database shows
Population: Michelin 2025 and 2026 star and Bib rows, FR and IT.

| Country | Venues with a 2025 row and no 2026 row | Venues with a 2026 row and no 2025 row | Of the first group, venues with a same-city, same-category 2026-only venue whose name key contains or is contained by theirs |
|---|---|---|---|
| FR | 280 | 372 | 204 |
| IT | 300 | 322 | 256 |

`ingest_rows` for the batches: France 719 match, 351 new_venue, 1 skipped. Italy 315 match, 317 new_venue, 1 duplicate. Japan 570 match, 15 new_venue.

France 2026 added 62 new Stars plus new Bib Gourmands. Italy 2026 added 25 new Stars plus new Bib Gourmands. So most of the 351 and 317 new venues are twins of venues that already existed.

### 6.2 Examples from a random sample (all same city, same category)
- Maison Pic / Pic, Valence, Three Stars
- Ristorante Famiglia Rana / Famiglia Rana, Oppeano, Two Stars
- Ristorante I Tenerumi / I Tenerumi, Isola Vulcano, Two Stars
- Le Chabichou - Hôtel & Spa / Le Chabichou by Stéphane Buron, Courchevel, One Star
- La Fourchette des Ducs - Restaurant Obernai Alsace / La Fourchette des Ducs, Obernai, Two Stars
- Hôtel Pilgrim - Quartier Latin / Pilgrim, Paris, One Star
- Ristorante Al Cambio / Al Cambio, Bologna, Bib Gourmand

Each twin is `published=true` with no geo, photo or blurb. A visitor to Valence sees two Three-Star venues named Pic.

### 6.3 What to do (recommendation, not part of the year ruling)
Option A, if the undo job is real: undo the France and Italy batches, rebuild the CSVs with the Japan match test, re-stage, re-promote. The Opus chat must first read the undo code and report what it reverses. The France rename job (252 + 15 names) already applied, so the undo must not reverse those names, or Ben must accept a re-run of the rename.

Option B, merge: build a pairing file like the Japan decisions file. Pair each 2025-only venue with one 2026-only venue in the same city with the same category, with name evidence from the Michelin page. Ben approves the file. One gated batch per country moves awards, slugs and aliases to the survivor and retires the twin. The survivor is the older venue (it has geo, photos and other awards). The Michelin legacy 2025 row on the survivor is then retired by rule 2, because the sourced 2026 row moves onto it.

I lean to Option B, because the rename job and any hand fixes since Sep 14 stay in place. Under-merge beats over-merge applies here in full: a pair with weak name evidence stays unpaired.

---

## 7. Numbers and dates checked
- 7,136 / 3,216 / 2,288 / 928 / 24,101: read from `awards` on Sep 15, 2026.
- 701 / 697 / 4, 311 / 310 / 1, 568 / 567 / 1: read from the 4.0 query.
- 280 / 372 / 204 and 300 / 322 / 256: read from the section 6 query.
- Ceremony dates: Italy Nov 19, 2025 (lapresse.it). Spain Nov 25, 2025 (cope.es). France Mar 16, 2026 (journalduluxe.fr). Nara May 13, 2026 (guide.michelin.com). Nordic Jun 1, 2026 (guide.michelin.com). Germany Jun 23, 2026 (hogapage.de). Tokyo Sep 25, 2025 and Kyoto Osaka Apr 23, 2026 come from the handoff and were not re-read here.
- Published totals: Spain 16 / 37 / 254 / 204 (handoff, cope.es). Italy 15 / 38 / 341 (qualitytravel.it). France & Monaco 668 starred, 31 Three Stars (journalduluxe.fr).
