# Handoff: Turkey 2026 follow-ups done (Efendy, Lucien Arkas = LA Mahzen, Sankai status). Oct 30, 2026. Next: P1-rest held 19, then name differences.

This file replaces `handoff-turkey-2026-relabel-done-2026-10-30.md` for live state and next steps. That file still holds
the Turkey relabel results and method notes. `handoff-price-card-p1-rest-done-2026-10-30.md` holds the list of the held
P1-rest venues. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method. The working rules in
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule (Claude commits files to the repo
itself) still apply.

## Ben's decisions (Oct 30, 2026)
- 14:31 ET "A" for all:
  1. Efendy Istanbul: relabel with the archive URL.
  2. Efendy status: keep `active`, recheck later (a removed card alone does not prove a closure).
  3. Lucien Arkas Bağları = LA Mahzen: pair, relabel, keep our name. D4 (promote LA Mahzen) is cancelled.
  4. Sankai by Nagaya: status `closed` -> `active`.
- 14:34 ET "go".

## Findings
- **Efendy** `ve_51ce2088a5`: live card 404 (Oct 30). web.archive.org captures Jan 6, Jan 13 (`/en/`) and Jan 28, 2026
  (`/de/de/`) show card 1209218 "EFENDY", Bib, `dateAwarded` 2026, CAT_P02, Nisbetiye Caddesi No:13, Levent. Michelin
  removed the card after Jan 28. No closure evidence (Time Out Oct 2024: open).
- **Lucien Arkas Bağları** `ve_f8013e6d34` = **LA Mahzen** card 1208310 (Torbalı, Izmir, Bib 2026, CAT_P02). Proof: the
  card text names the Domaine Lucien Arkas vineyards; the card website link `lawines.com.tr/restaurant.aspx` has the title
  "Lucien Arkas Bağları"; the card had the name LA Mahzen in Aug 2024 captures too.
- **Sankai by Nagaya** `ve_f088b7a06a`: live card One Star 2026, no closure note; venue site no closure notice; no
  closure in web search. The `closed` status came from the Aug 14 sheet load (audit 4862). The venue site
  (sankai.com.tr) holds injected casino spam: do not link to it.
- **Bib count:** article 39; known 38 (36 matched + Efendy + LA Mahzen/Lucien Arkas). **One 2026 Bib is still
  unknown.** It is not on the current list and not in the database.
- web.archive.org CDX gave 503 "Temporarily Offline" on some calls. A second try after a wait worked. Prefix queries
  with `filter=original:` over a large path returned empty; exact card URLs per locale worked (`/en/`, `/de/de/`,
  `/tr/tr/` had captures; `/us/en/` had none for Efendy).

## Live state (read Oct 30, 18:35 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,714** (no change) |
| venues | 11,307 (active **10,940**, closed **367**) |
| awards | 23,352 |
| source_capture_ledger (max id) | **157** |
| audit_log (max id) | **118,697** |
| Turkey Michelin rows | 2026 **55**, 2025 **0** |
| Active Michelin star/Bib venues with no price row | **22** (19 held P1-rest + Terra, La Torre One Fire, Sankai by Nagaya) |

## Done in this session
1. Start check (18:20 UTC): price 7,714, ledger 156, audit 118,694. All matched. Repo attached with push access, clone
   at `43372cc`.
2. Evidence reads (built-in browser): see `michelin-turkey-2026-followups-evidence-2026-10-30.txt`.
3. File `michelin-turkey-2026-followups-2026-10-30.sql` (8,134 bytes, sha256
   `3f73caa430cddf07cd8bc22d8c2807c247143f4250b644134a1aff89e3d1cb47`). Relay 3 lines, sha256
   `80f186e802cf9cc792860da4c463f0c68279b6f3e1e5494680c95cb8e5426069`, md5 `0c2186a05eddeaa63c7a7a7867cfda18`.
   Builder `build_turkey_followups_sql.py` (new). pglast 8.7 syntax check passed; dry run (Read connector, guards then a
   forced stop at the first UPDATE) passed. Write 18:35:26 UTC, Write connector, one transaction, all guards and
   post-checks passed:
   - W1: award 10663 (Efendy) year 2025 -> 2026, source_url NULL ->
     `https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy`.
   - W2: award 10686 (Lucien Arkas Bağları) year 2025 -> 2026, source_url NULL ->
     `https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen`. Venue name not changed.
   - Ledger **157**: michelin, award, 2.
   - W3: venue `ve_f088b7a06a` status closed -> active. Status only, no ledger row (SLOW&LOW, De Groene Lantaarn and
     Regent precedent). Gate on the venue row md5 `666fed8cd33fd973391ed253f8ab4f9a`.
   - Audit **118,695–118,697**: awards UPDATE 10663, awards UPDATE 10686, venues UPDATE `ve_f088b7a06a` (status only).

## Files
| File | sha256 | Where |
|---|---|---|
| `michelin-turkey-2026-followups-2026-10-30.sql` | `3f73caa4…e3d1cb47` | project `claude/`, repo `docs/` |
| `michelin-turkey-2026-followups-relay-2026-10-30.txt` (3 lines, no final newline) | `80f186e8…8e5426069` | project `claude/`, repo `docs/` |
| `michelin-turkey-2026-followups-evidence-2026-10-30.txt` | (see repo commit) | project `claude/`, repo `docs/` |
| `build_turkey_followups_sql.py` (new) | (see repo commit) | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Open items
- **Next (Ben's order):**
  1. The held P1-rest venues, **19**: Banshee, Zhu Ji Zhi Mian Pu, California no-star 5, other city 2, distinction 1,
     branch 4, no website 4, name not on site 1. List in `handoff-price-card-p1-rest-done-2026-10-30.md`.
  2. The name differences: 45 from P1 rest, 24 Turkey (pairs file columns 5 and 6), plus Efendy (card "EFENDY", ours
     "Efendy İstanbul") and Lucien Arkas (card "LA Mahzen", ours "Lucien Arkas Bağları"; Ben 14:31: our name stays).
- New from this session:
  - Sankai by Nagaya: now active with no price row. The live card read today shows ₺₺₺₺ (CAT_P04, TRY 4). Small price
    INSERT with the next price batch.
  - Efendy recheck: card removed after Jan 28, 2026. Find out if the venue closed or only left the guide.
  - One 2026 Turkey Bib from the article is still unknown (39 vs 38).
  - Efendy and Lucien Arkas keep a legacy `$$` price row (no currency); card ₺₺ TRY 2 goes in the later P2 batch with
    the 36 Turkey legacy rows.
  - Sankai venue site has injected spam.
- Carried from the Turkey relabel handoff: Turkey card cities that differ from ours (Revithia, Casa Lavanda, Bagarasi,
  Mandalya, Mezegi, Asma Yaprağı, Mezra Yalıkavak, Babayan Evi, Old Greek House); 36 Turkey legacy price rows (P2).
- Carried from the P1-rest handoff: city labels Waiheke → Waiheke Island, Wanaka → Wānaka, Dakovo → Đakovo;
  California 2026 One Star rows with no star on the current list; held-P2 items (5 city changes, 3 name differences,
  rechecks Café Spice Namasté and Unforgettable after Nov 12, 15 P2 venues that left the guide); Lavello
  `ve_04c2784726`; Les Fresques `ve_e574aeb7fd`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire
  `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov); Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule
  2.1.7); Spain 2027 edition Dec 1; Germany 2027 and GB&I 2027 edition dates not found; Northeast Cities after Dec 14;
  Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027); American Great Lakes
  first edition Apr 21, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes)
  status; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy
  special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-turkey-followups-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p1-rest-done-2026-10-30.md for the held P1-rest list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
price 7,714, ledger 157 and audit_log 118,697. Then start the 19 held P1-rest venues: show me in /ste style each group
with the evidence and the options. No write before my go. Attach the compasseats repo with push access for the commit
after any write.
```
