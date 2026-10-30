# Handoff: Name differences read (cards + venue sites), no write. Oct 30, 2026. Decisions made. Next: the rename batch (72).

This file replaces `handoff-p1-rest-held-b2-done-2026-10-30.md` for live state and next steps. That file still holds the
batch 2 results and its method notes. The per-venue list is `name-diff-evidence-2026-10-30.txt` (94 lines). The working
rules and venue-delete method in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule (Claude
commits files to the repo itself) still apply. The rename method (rename_batches / rename_rows, `app.allow_rename`, slug
rule, plan fingerprint) is in `handoff-germany-renamed-set1-2026-10-08.md` and `handoff-germany-renamed-sets23-2026-10-09.md`;
slug template `docs/slugs-rename-michelin-2026-germany.sql`.

## Ben's input (Oct 30, 2026)
- 17:38 ET: list the name differences, grouped (wrong branch / card ward or branch suffix / venue's own spelling), with the
  site spelling; no write.
- 18:17 ET "Read sites" (approved each WebFetch).
- 18:32 ET: write the handoff.
- **18:35 ET "Let's go with your recommendations on the decisions": 1 = A (rules R1–R5 accepted), 2 = A (rename the
  9 † venues on site + card agreement), 3 = hold the 8 venues for a later batch.**

## Live state (read Oct 30, 22:32 UTC, whole tables). No write in this session.
| Table | Count |
|---|---|
| venues | 11,304 (active 10,937) |
| awards | 23,353 |
| price | 7,730 |
| slugs | 12,843 |
| listings | 11,304 |
| city_label_source | 24,005 |
| source_capture_ledger (max id) | **162** |
| audit_log (max id) | **118,753** |

## Done in this session
1. Start check (21:39 UTC): all counts, ledger 162, audit 118,753 matched. Repo attached with push access, clone at `93f2490`.
2. Card read (built-in browser, `fetch()` of each live card, 1.2 s pause; `h1` = card name; `a[data-event*=website]` = site):
   P1 rest 116 + Turkey 23 + LA Mahzen + 5 Vietnam held + Most + 3 sisters = 149 cards, all status 200.
3. Population: **94 venues** with a name difference. P1 rest **57** (the earlier "45" left out 12 that differ only in capitals
   or a card branch suffix: SELINE, BODA, ROCA, BAR CITRA, SOICHI, LONDO, LUCIEN, LULU FUSION BISTRO, lao xi noodle house,
   The Cow, Bombay Palace Wanaka, Bánh Cuốn Gia Truyền Thanh Vân); Turkey **23** (pairs file had 24; Asma Yaprağı differs only
   by a no-break space on the card); Efendy 1; Lucien Arkas 1; Vietnam held 5; Most Tumski 1; merged sisters 3; held P2 3.
4. Other publishers: 10 of the 94 have a non-Michelin award (best-chef-awards, la-liste, james-beard, oad). The `awards`
   table has no name column, so their spelling is not known (Sep 14 majority vote cannot be counted).
5. Site read (WebFetch, 22:17–22:31 UTC): 75 tried, **69 read**. Not read: Hummingbird, Botschaft, Ortega (robots);
   Chay Garden, Bağarası, Kitchen at EDITION Bodrum (site or server error). 2 redirects followed: Francesca →
   brutohospitality.co.nz/venues/francesca; Lille Mølle → norrlyst.dk/restaurantlillemoelle/.
6. Proposed result: **rename 72, keep 14, hold 8** (see the evidence file, column 6 and 7).

## Rules (accepted by Ben, Oct 30 18:35 ET)
- R1 The site writes the name one way → use that way.
- R2 The site writes it more than one way → use the way the card also uses.
- R3 Capitals alone are no difference when the site also writes normal case. All-caps-only sites keep the capitals
  (ROCA, LONDO, LUCIEN, ESSE).
- R4 No site way matches the card → the site's title or logo way.
- R5 No site, or not read → card name minus suffix (Oct 10 Michelin fallback).

## Summary by group
- **G1 wrong branch:** Nam Hin → Nam Hìn (rename). Maison Patte Noire `ve_c4d70b9a92` (card La P'tite Patte): hold.
- **G2 card suffix:** rename Bombay Palace, Lê Gia Khang, Mặn Mòi, Chay Garden. Keep The Cow, Hủ Tiếu Hồng Phát (site brand),
  Bánh Cuốn Gia Truyền Thanh Vân.
- **G3 own spelling:** rename 67 (site way 51 incl. Union Pasadena, Narımor Urla, Adil Müftüoğlu Uğur Lokantası, Tavacı Recep
  Usta ×2 [different cities]; card fallback 12). Keep 11: ROCA, LONDO, LUCIEN, Upstairs Tasting Room, Rātā Restaurant, Double
  Luck Chinese, Restaurant Levi, Steampunk Restauracja, Casius Antioch Kitchen Restaurant, Lucien Arkas Bağları, Efendy İstanbul.
- **Hold 8:** Maison Patte Noire; Bánh Bèo, Bánh Đập, Bánh Ướt (card "Bánh Bèo - Bánh đập", dash, no site); Andrea Ristorante -
  Enoteca `ve_6d2d60d7ba` (card Andrea, dash); Vegan Ramen UZU Kyoto `ve_bb69a63e96` (card UZU Kyoto, site not read);
  LULU FUSION BISTRO (site "LULU fusion bistro"); Arka Ristorente Pizzeria Bodrum (site "Arka Pizzaria" title / "Arka
  Pizzeria" footer); TURK FATIH TUTAK† (site "Turk Fatih Tutak", nav "TURK"); KITCHEN by Osman Sezener (site not read).

## Decisions (answered Oct 30 18:35 ET: 1 = A, 2 = A, 3 = later batch)
1. Rules R1–R5: A accept (recommended) / B change one.
2. The 9 † venues where site and card agree (SELINE, SOICHI, Amisfield, Logan Brown, The Kitchen, ESSE, MACAKIZI, TERUAR,
   Urla Vino Locale): A rename now on site + card agreement (recommended, Oct 10 ruling) / B read the other publishers first.
3. The 8 held venues: a name now, or a later batch.

## Next steps
1. Fresh read: names of the 72 rename venues = column 3 of the evidence file (gate on md5 of `id|name`, ordered by id).
2. Build the rename batch from the evidence file by script (no hand-typed names): rename_batches + rename_rows, then the slug
   file (new canonical slug where the slug rule gives a new slug, old slug non-canonical; check that no new slug is taken in
   the same city, e.g. 2 venues named Tavacı Recep Usta are in different cities). Ledger field_type `name`.
3. pglast check, dry run through the Read connector, present the file, wait for "go".
4. If the Write connector prompt closes by itself again, offer the SQL Editor route at once (see the batch 2 handoff).

## Method notes from this session
- Card read script (one tab on guide.michelin.com): store the URL list on `window`, loop with `await fetch('/'+path)`,
  `DOMParser`, 1.2 s pause; poll in separate short calls (a call over 45 s times out, the loop keeps running).
- **WebFetch needs Ben's approval per site.** Subagents' fetches were blocked when the prompt timed out (PROVENANCE_REQUIRED).
  Run site reads from the main thread while Ben is present, in batches of about 8.
- Cards for the 3 held-P2 venues (Andrea, UZU, Maison Patte Noire) were not re-read; their card names come from the held-P2
  handoff.

## Files
| File | Where |
|---|---|
| `name-diff-evidence-2026-10-30.txt` (94 data lines) | project `claude/`, repo `docs/` |
| this handoff | project `claude/`, repo `docs/` |

## Open items (carried, unchanged)
- Write connector prompt closes by itself (batch 2 handoff).
- Paloma Taqueria: closed for refurbishment; recheck. City label "Wanaka"; card spells "Wānaka".
- Carried from batch 1: 2025 Green Star rows missing for Chez Panisse, Chi Spacca, Pomet, Heritage (Long Beach);
  Green-Star-as-star check on other guides from the Aug 14 sheet load; 2025 rows of the 3 sisters (10486, 10493, 10494)
  have no URL; Banshee 2023/2024 Bib rows with no URL and American South 2025/2026 edition check; Miura / Beverly Hills city policy.
- Carried from the Turkey follow-ups handoff: Sankai by Nagaya price (₺₺₺₺, CAT_P04, TRY 4); Efendy recheck; one 2026
  Turkey Bib unknown (39 vs 38); Efendy and Lucien Arkas legacy `$$` rows; Sankai site spam; Turkey card cities that differ
  from ours (Revithia, Casa Lavanda, Bagarasi, Mandalya, Mezegi, Asma Yaprağı, Mezra Yalıkavak, Babayan Evi, Old Greek House).
- Carried from the P1-rest handoff: city labels Waiheke → Waiheke Island, Wanaka → Wānaka, Dakovo → Đakovo; held-P2 items
  (5 city changes, rechecks Café Spice Namasté and Unforgettable after Nov 12, 15 P2 venues that left the guide); Lavello
  `ve_04c2784726` (card Forentum); Les Fresques `ve_e574aeb7fd` name cleanup ("… une étoile Michelin depuis plus de 10 ans");
  Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov);
  Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7); Spain 2027 edition Dec 1; Germany 2027 and GB&I 2027
  edition dates not found; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; Belgium &
  Luxembourg 2027 (spring 2027); American Great Lakes first edition Apr 21, 2027; telleruide slug; apostrophe policy (now
  also: Lugya'h straight vs curly, Harry's, Kemal'in Yeri); Nadair (Atlanta) possibly closed; Dill (Lewes) status; Florida
  2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows;
  5 new awards on closed venues; `cities.venues_count` recount (Ben decides).

## Suggested opening prompt
```
Read claude/handoff-name-diffs-read-2026-10-30.md and claude/name-diff-evidence-2026-10-30.txt from the project files,
then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules and
claude/handoff-germany-renamed-sets23-2026-10-09.md for the rename and slug method. Do a fresh count read and confirm
ledger 162 and audit_log 118,753. My decisions are recorded in the handoff (1 = A, 2 = A, 8 held venues later).
Then build the rename batch for the 72 "rename" lines from the evidence file by script, with the slug file, run the
syntax check and the dry run, and show me the file and the counts in /ste style. No write before my go. Attach the
compasseats repo with push access for the commit after any write.
```
