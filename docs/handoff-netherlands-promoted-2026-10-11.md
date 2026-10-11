# Handoff: CompassEats, Oct 11, 2026 (12:05 Atlanta). Netherlands 2026 staged and promoted (batch 16, ledger 120-121). 7 NL cities added (audit 110,370-110,377). Next: Netherlands rename CSV, slugs, status items.

This file replaces `claude/handoff-netherlands-captured-2026-10-10.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-netherlands-captured-2026-10-10.md`: the Netherlands capture record (196 rows), the De Groene Lantaarn close (audit 110,369), the hold register, the "nothing below a Bib" rule.
- `claude/handoff-netherlands-brief-2026-10-10.md`: the ceremony-date and label-check table for 10 countries, the Netherlands facts and name items.
- `claude/handoff-belgium-luxembourg-renamed-2026-10-10.md`: the batch 20 rename record and the tie rule (the model for the Netherlands rename).
- `claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md`: the slug-file record and the slug check against `slug.ts`.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check, the slug-file method.
- `claude/handoff-belgium-luxembourg-retired-2026-10-10.md`: the capture-check, simulation, pairing, stage and promote record.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`): rule 2.1.1 (amended Sep 24), rule 2.1.7, the Sep 28 standing rules.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps). Ben starting a stage or real promote job is his "go".
- Suggest a handoff break before a new large block of work.
- Plan versions, briefs and handoffs are saved to the project over the same name (`project_write` with `local_path`).
- Name ties and doubt (Ben, Oct 10): the vote first; in a tie or unclear case the venue's own spelling wins, Michelin is the fallback.
- CompassEats does not track anything below a Michelin Bib (Ben, Oct 10). A venue that dropped to Selected stays `active` with its old rows as history and no new row.

## Live state
Population: whole table. Read Oct 11, 15:59:44 UTC (11:59 Atlanta), after the promote.

| Table | Count |
|---|---|
| venues | **11,254** (active **10,887**, closed 367) |
| awards | **22,659** |
| Michelin 2025 / 2026 / 2027 rows | 3,545 / **5,320** / 47 |
| listings / slugs | **11,254** / **12,638** |
| cities / city_aliases / city_label_source | **3,258** / **259** / **23,912** |
| price | 7,048 |
| source_capture_ledger | **85** (last id **121**) |
| audit_log | **106,303** (last id **110,895**) |
| ingest_batches | 1, 3-**16** promoted (no id 2) |
| Netherlands Michelin rows (venue city `country_iso` NL) | 381 = 185 legacy 2025 (unsourced, kept as history) + 196 sourced 2026 card rows (batch 16) |

## Done in this session (Oct 10, 23:09 to Oct 11, 12:05 Atlanta)

**1. Start check (Oct 11, 03:10 UTC).** All counts, ledger 117, audit 110,369 matched the captured handoff.

**2. File checks.** `michelin-2026-netherlands.csv` sha256 `aa72b5e6…d7b2` = log; 44,886 bytes; UTF-8, no BOM, LF, 197 lines, 17 fields each. Log sha256 `e05b58a7…6e02`. 1 / 20 / 98 / 77 = 196 = brief. Fixed columns all as the brief. 0 duplicate URLs, 0 non-NFC. All 9 new stars and 10 new Bibs present; none of the 20 dropped venues present. Both files in the repo at `b728fa4` (hashes checked in a fresh clone). Brief in the repo `docs/cowork-michelin-2026-netherlands.md` sha256 `2405ef1c…f03d0f` (correct).

**3. Pre-stage simulation (read-only).** Germany method, stage logic copied from `scripts/ingest/lib/resolve.ts`, `stageLogic.ts`, `looseKey.ts`; ASCII `U&'…'` input; in-SQL guard md5 of `line|name|city|country|cat` = `7318a4941f33dca845be614aeec76c9c`.
- Before the city fix: 99 match, 45 new_venue, 7 city_not_found, 42 loose key, 2 key too short (O&O, ML), 1 same key other city (Apicius). Run-1 md5 `b13ad20a…`.
- All 99 matches held exactly 1 legacy 2025 row in the same category, all `active`, 0 duplicates.

**4. Ben's decisions (Oct 11, 10:58, tappable choices).**
- **Q1 = A:** line 73 Wils (One Star, Amsterdam) → `use:ve_40a12813d1` "Restaurant Wils" (held only OAD 2025 No. 612, no Michelin row). "Wils Bakery Café" `ve_8363cbde5d` is a different venue (Bib, line 163, match).
- **Q2 = B:** the Valkenburg card city gets display "Valkenburg aan de Geul" with alias `valkenburg`.
- Correction recorded: with Q1 = A, run 2 = 175 match / 21 new_venue (the option text said 176 / 20; that was wrong).

**5. Step A: 7 NL cities (Ben "go" 11:19).** File `docs/cities-michelin-2026-netherlands.sql` (164 lines, ASCII, sha256 `52e9fa6e3e5ed48402ca0b6cf99e802b54a5c0f8e5acfa005055b70b0ee32594`, repo `698d561`). Labels written from the CSV by script; guards: counts 3,251 / 258, source md5 `31c6f1d0…809a`, plan md5 `3856e2db…6fef`, no id/slug/display/alias clash, no NL batch yet; POST: counts 3,258 / 259, 8 audit rows, stage-job resolution of 11 labels (7 new + The Hague, Apeldoorn, Sint-Oedenrode, Groningen) gives exactly the expected NL city. Dry run (Read connector) stopped at the first INSERT; POST resolution tested read-only with virtual rows (11 of 11). **Write connector committed first time, Oct 11 15:20:41 UTC.** Audit **110,370-110,376** (cities INSERT, trigger), **110,377** (city_aliases INSERT `valkenburg`, hand). No ledger row.

| Card city (line, card) | City id | Display | Slug |
|---|---|---|---|
| Schin op Geul (6, SUIS) | `ci_a266c0fcb3` | Schin op Geul | `schin-op-geul` |
| Veeningen (22, Le Epifaan) | `ci_8ed4b91b42` | Veeningen | `veeningen` |
| Duiven (29, 't Raedthuys) | `ci_c9ac96ac24` | Duiven | `duiven` |
| Hoog Soeren (32, Wild Atelier) | `ci_3017dc985b` | Hoog Soeren | `hoog-soeren` |
| Valkenburg (44, Ambrozijn) | `ci_5a37103403` | Valkenburg aan de Geul (+ alias `valkenburg`) | `valkenburg-aan-de-geul` |
| Mierlo (51, De Cuijt) | `ci_c986145941` | Mierlo | `mierlo` |
| Kortgene (103, Rozewied) | `ci_4daaa88782` | Kortgene | `kortgene` |

Note: a second Valkenburg exists in Zuid-Holland (near Katwijk). If a card ever prints "Valkenburg" for it, the alias sends it to Valkenburg aan de Geul. No venue or city row for that town today.

**6. Step B: decisions file.** `fixtures/ingest/michelin-2026-netherlands-decisions.csv`: 98 lines (header + 97), 20,718 bytes, UTF-8, all quoted, CRLF, sha256 `bb2e151c8b00f57b7293aeaf024f1c6e6dcbe2b5278c168bc4ac0859970920e2`, repo `698d561`. Built by script from the simulation (re-run after Step A), the repo CSV, the repo log (part 6 lists) and an md5-guarded legacy read (185 rows, `4aeb975cb6752dd374c9d1fde7944c26`, same md5 in SQL and Python).
- 76 `use:` (41 job loose-key candidate; 31 shared name word; 2 card URL tail = legacy name: Nami → "Noble Kitchen" `ve_e8decd292e`, O&O; 1 elimination: De Moerbei → "Mulberry Restaurant" `ve_f4ff77e92f`, Warmond; 1 Ben Q1: Wils) and 21 `new`.
- Checks: no legacy venue used twice; all 19 log newcomers are `new`; the 2 other `new` are Bistro de la Mer (Amsterdam) and 't Raedthuys (Duiven), both in the 2025 article with no venue row; the 11 legacy rows left = the 11 dropped venues.
- Notable pairs: RIJKS® → "Rijks" `ve_2c9dedb1ab`; Karel 5 → "Grand Hotel Karel V" `ve_97fcea6748`; Raedthuys (Doetinchem Bib) → "Eterij & Tapperij 't Raedthuys" `ve_e99b14f627`; CUE → "CUE- Bar Restaurant Amsterdam" `ve_00d0fd700d`; Au Coin des Bons Enfants → "Au Coin" `ve_8e2aeaade5`; Central Park → "Relais & Chateaux - Central Park Voorburg" `ve_b914824fca`.

**7. Stage (batch 16).**
- Re-simulation after Step A: only the 7 city lines changed (now `new_venue`). Prediction: 99 match, 52 new_venue, 42 loose key, 2 key too short, 1 same key other city; run-1 md5 (`line|verdict|reason|venue_id`) `701a81fb16cf17ee84728b81a0c38ced`.
- **Run 1** (Ben, 15:55:35 UTC): = prediction on every line (md5 `701a81fb…` both sides); staged URL md5 (sorted, C collation) `6f8287f7…790e` = CSV. Review CSV 45 rows, all with a decision; every loose-key decision = the printed candidate.
- **Run 2** with decisions (Ben, 15:57 UTC): md5 of `line|verdict|venue_id|decision` = `a1b61d3ec167a7be311a26f55d1a1a44` both sides. 175 match (1 / 18 / 89 / 67) on 175 distinct venues + 21 new_venue (0 / 2 / 9 / 10) in 21 groups; 0 review, duplicate or reject. The batch note still says "run 1" (run 2 does not change the note).

**8. Promote.**
- **Dry run** (Ben, 15:58 UTC): 11 of 11 invariants pass; rolled back; used ledger 118-119 and audit 110,378-110,636.
- **Real promote** (Ben's run = "go", committed **Oct 11 15:59:31 UTC**): ledger **120** (michelin, award, 196) and **121** (michelin, city_label, 42), job `ingest-promote:michelin-2026-netherlands`. Audit **110,637-110,895** (259, all INSERT, one timestamp): venues 21 (110,637-110,657), listings 21 (110,658-110,678), slugs 21 (110,679-110,699), awards 196 (110,700-110,895). Award ids **28,898-29,093**.
- Row check: 196 of 196 rows have exactly one award; 196 distinct URLs; year 2026, category = staged row, no rank, no distinction; all NL, all `active`; 175 of 175 matches on the decided venue; 21 of 21 new venues carry the card name and card city, each with 1 award, 1 listing, 1 canonical slug, 2 city labels. The 185 legacy 2025 NL rows are all still there.
- The real new venue ids = the dry-run ids (the job derives them from fixed inputs).

**New venues (21):** SUIS `ve_6267d02f02` /schin-op-geul/suis · Azurite `ve_dd68e7cb45` /delft/azurite · Le Epifaan `ve_68d6eacdf5` /veeningen/le-epifaan · 't Raedthuys `ve_ac078b1119` /duiven/t-raedthuys · Wild Atelier `ve_ff06e71af7` /hoog-soeren/wild-atelier · Nassau `ve_e5c8a91032` /groningen/nassau · Ambrozijn `ve_c914e2cfe3` /valkenburg-aan-de-geul/ambrozijn · De Cuijt `ve_2f893f9438` /mierlo/de-cuijt · Bistro de la Mer `ve_f0d56b4eae` /amsterdam/bistro-de-la-mer · Bij Sidney `ve_71312bb8f8` /loenen-aan-de-vecht/bij-sidney · Rozewied `ve_12e1dee96f` /kortgene/rozewied · Dokjard `ve_128b8427d0` /groningen/dokjard · Bistro Luux `ve_c2c0630e58` /weert/bistro-luux · ORA | Taverna & Bar `ve_6d9803a0e6` /breda/ora-taverna-bar · Bistro Toost `ve_09f0bb8b15` /amstelveen/bistro-toost · Boon & De Koot `ve_8669f5408d` /amsterdam/boon-de-koot · FuLu Mandarijn `ve_e7949f46d6` /amsterdam/fulu-mandarijn · Utage Sake Bar `ve_e515f6353a` /amsterdam/utage-sake-bar · Brasserie Bruis `ve_3be5964407` /haarlem/brasserie-bruis · Wijn Boer `ve_b36d4390ac` /zwolle/wijn-boer · Ramen Kitanoya `ve_1e7a896777` /the-hague/ramen-kitanoya.

**Legacy rows with no 2026 card (11, kept as 2025 history):** One Star De Juwelier 3680 (`ve_8a277bc814`, Selected in 2026, stays active), Demain 4401 (closed), Da Vinci 6221 (`ve_b92ff90e25`, Maasbracht), Sense 8951 (`ve_e40817454c`, Vught); Bib Oriole Garden Bistro 9258 (`ve_3e369166d3`), Bistrôt Chapeau 9536 (`ve_30ec4d6d70`), LEV. aan de IJssel 10061 (`ve_6d8bee674e`, = LEV Foodbar), HAVN 10592 (`ve_6b61f17da2`), Prix de Rome 11064 (`ve_ccff986445`), Regent 11431 (`ve_7b3edc3520`, = Bistrot Regent), Avenue43 11592 (`ve_adccf8c7cf`).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-netherlands.csv` | In the repo (`b728fa4`) | `aa72b5e6…d7b2` |
| `docs/michelin-2026-netherlands-log.md` | In the repo (`b728fa4`) | `e05b58a7…6e02` |
| `docs/cities-michelin-2026-netherlands.sql` | Run (audit 110,370-110,377), in the repo (`698d561`) | `52e9fa6e…2594` |
| `fixtures/ingest/michelin-2026-netherlands-decisions.csv` | Applied in run 2, in the repo (`698d561`) | `bb2e151c…20e2` |
| `reports/michelin-2026-netherlands-stage.md` / `-review.csv` | Written by the stage job (`e64b5d0`) | `82f4687f…` / `881dc711…` (review CSV holds the 45 run-1 rows) |
| `reports/michelin-2026-netherlands-promote.md` | Real run (`55313ab`) | `6411d360…a1c1` |

## Methods that worked (new)
- **Simulation result to disk:** a Read query whose result is larger than the tool limit is saved to a file automatically. Adding the needed columns to the large simulation query (per-line legacy candidates in the same city and category, minus the venues already matched; plus the full legacy list and its md5 on line 1) puts every id on disk, so the decisions file is built by script with no retyping.
- **Pairing order for the decisions file:** (1) Ben's explicit decisions; (2) the job's loose-key candidate when it is the legacy row in the same city and category; (3) one remaining legacy candidate shares a name word (stop words removed); (4) card URL tail = slug of the legacy name; (5) elimination only when one legacy row is left in the city and category, it is not a dropped venue (log part 6), the card is not a newcomer, and no other open line competes; else `new`. Checks: no venue used twice; newcomers all `new`; leftover legacy = dropped list.
- **City insert with no staged rows:** labels from the CSV as array constants (`ARRAY[U&'…']`) plus `unnest` in each statement, guarded by an md5 of `line|label|country` against the CSV. The POST resolution gate can be tested read-only with the new rows added as a virtual `UNION ALL` to `cities` and `city_aliases`.
- **Stage run checks:** run 1 = md5 of `line|verdict|reason|venue_id` (`raw->>'_line'`, `validation->>'reason'`, `validation->>'venue_id'`); run 2 = md5 of `line|verdict|venue_id|decision` (`validation->>'decision'`); staged URL md5 with `collate "C"` = Python sort by UTF-8 bytes.
- **Promote ids:** a dry run uses up ledger and audit ids (sequences advance) but the new venue ids are the same in the real run.

## Dead ends: do not retry (new)
- `CREATE TEMP TABLE` inside a `DO` block through the Read connector: "cannot execute CREATE TABLE AS in a read-only transaction", so the PRE gates never run. Use array constants with `unnest`.
- A gate that counts a fixed `VALUES` list always passes; count the rows of the result instead.

## Open items, in order
1. **Netherlands rename CSV (next, new chat).** Texas / Belgium method (two md5-guarded inputs, `loadRenameCsv`), vote rule + tie rule (Oct 10). Population: the 196 batch-16 awards joined by `source_url`; card name ≠ `venues.name` on **86** venues: 2 case-only, 9 same `norm_key`, 75 other (for example "Restaurant GEM." → "GEM. by Soenil Bahadoer", "Mulberry Restaurant" → "De Moerbei", "Noble Kitchen" → "Nami", "Grand Hotel Karel V" → "Karel 5", "Restaurant Wils" → "Wils", "Rijks" → "RIJKS®", "Brut172 by Hans van Wolde", "François Geurds FG Restaurant", "t Nonnetje", "Restaurant Flore", "Restaurant De Nieuwe Winkel", "Bij Jef Restaurant & Hotel"). 0 blurbs, 0 earlier rename rows; 19 other-publisher rows on these venues (vote rule). Questions for Ben likely: case-only rows, chef suffix "GEM. by Soenil Bahadoer" (Sep 14 ruling: a publisher's chef suffix never becomes part of `venues.name`; check the venue's own site), trademark sign "RIJKS®", names with stray marks ("Restaurant Joann *", "Restaurant LIZZ*", "Pieters Restaurant*", "Restaurant Atelier*", "Te Koop in Tilburg,-"), and The Hague/Den Haag needs nothing (city, not name).
2. **Slugs** for renamed venues (Texas / Belgium slug-file method, check against `slug.ts`).
3. **Netherlands status items:** Restaurant Daalder* `ve_3b8f5d3656` (active, no Michelin row, card gone, page "Restaurant niet gevonden"): read closure evidence, apply the standing rules. Read status evidence for Da Vinci, Sense and the 7 dropped Bibs (rows stay as history either way; only closure evidence gives `closed`).
4. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
5. **Switzerland after Nov 2, 2026** (option A, promote only).
6. **Gap list after the Netherlands:** retire-path countries Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; promote-only Taiwan, Singapore; Thailand after its 2027 edition (rule 2.1.7); Canada as three guides.
7. **Hold registers:** Texas, Belgium & Luxembourg, Netherlands (Mindful Voices: Bij Jef, Mearkas, De Librije/Nelson Tanate; special awards: Young Chef Rozewied `ve_12e1dee96f`, Service Restaurant Château Neercanne `ve_df2327ee2f`, Sommelier Brut172 `ve_face3f9c07`, Opening of the Year Restaurant Luwte (Groningen, Selected, no venue)) → special-awards batch.
8. Price from the Michelin card (adds the 196 NL `€` cards: €€€€ 77, €€ 75, €€€ 42, € 2). Ben chooses the method.
9. France slug set (148 venues). Ben decides when.
10. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
11. Later-ceremony guides, promote only: Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
12. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues), re-checked under the tie rule. Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
13. Rechecks, no date: Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
14. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount (the 7 new NL cities have `venues_count` 0); RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes.
15. Repo `.env`: Ben to check that the Google Maps and MapTiler browser keys are restricted by HTTP referrer.
16. Plan v1.31: everything in the slug and brief handoffs, the Netherlands capture result, the "nothing below a Bib" rule, audit 110,369, **plus this session** (7 NL cities, Q1/Q2, batch 16, ledger 120-121, audit 110,370-110,895).
17. Options B (Phase 3 map-location pass) and C (publish builder): open for later.
18. Project file cleanup, part 2: after the migration is done.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-netherlands-promoted-2026-10-11.md first, then claude/handoff-belgium-luxembourg-renamed-2026-10-10.md for the rename record and the tie rule, then claude/handoff-texas-done-2026-10-10.md for the rename-CSV, collision-check and slug methods, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 121 and audit_log id 110,895 with a Read query. Then start open item 1: build the Netherlands rename CSV for the 86 venues with the Texas method (vote rule and tie rule), examine it read-only, and ask me the questions the rules do not decide. No write before my go.
```
