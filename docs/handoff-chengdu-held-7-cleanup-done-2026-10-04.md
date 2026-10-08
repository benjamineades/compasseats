# Handoff: CompassEats, Oct 4, 2026. Chengdu held 7 venues deleted. Archive method test 1 complete. Next: Germany, then Plan v1.30.

This file replaces `handoff-chengdu-2026-sourced-25-2026-10-02.md` for live state, decisions, open items, methods and dead ends (the Oct 2 methods and dead ends are carried below, so that file is no longer needed). The Sep 28 ruling (conditions 1 to 8) and Ben's three decisions after the ruling are in `handoff-chengdu-renamed-reviewed-2026-09-28.md`. The methods, dead ends, database notes, key ids and working preferences in `handoff-michelin-chengdu-2027-done-2026-09-28.md` and `handoff-plan-v129-done-2026-09-28.md` still apply. Attach all four files to the next chat.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". Ben uploads chat files to the repo (give click steps).
- Suggest a handoff break before a new large block of work.

Open item 1 of the Oct 2 sourced-25 handoff is closed. Archive method test 1 (Chengdu 2026) is complete: step 1 promote (Oct 2), step 2 the 25-row update (Oct 2), step 3 this cleanup (Oct 4).

## Live state
Population: whole table. Read Oct 5 02:01 UTC (Oct 4 evening, Atlanta) after the commit.

| Table | Count |
|---|---|
| venues | **11,205** (active **10,839**, closed 366) |
| awards | **22,249** |
| Michelin 2025 / 2026 / 2027 rows | 3,796 / **4,659** / 47 |
| listings / slugs | **11,205** / **12,304** (canonical **11,205**, non-canonical 1,099) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_label_source | 3,244 / **23,814** |
| price | **7,049** (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **65** (last id **85**) |
| audit_log | **103,905** (last id **107,294**) |
| ingest_batches promoted | 1, 3–12 (no id 2) |
| rename_batches | 2, 4, 6, 8, 10 applied. rename_rows 551 |
| Chengdu `ci_354b500e3a` | **54** venues, **73** slug rows. Michelin 2026 rows **40**, all archive-sourced, 40 distinct URLs: Two Stars 2, One Star 11, Bib 27 (= Michelin's 2026 article). Unsourced **0**. Michelin 2027 rows 47. |

## Done in this session
**Start check:** all counts, ledger 84 and audit 107,245 matched the Oct 2 handoff. Repo commit `c2ab4dc` (Oct 2 17:53 -0400): `docs/source-url-michelin-2026-chengdu-legacy.sql` sha256 `619cc3fd31729378143efd5739f6934e3c2bb3ad940780726b549d2a26075a5a` (correct). `reports/chengdu-2026-archive-relay.jsonl` sha256 `216ffff2…f5ffc` (correct). `docs/slugs-rename-michelin-2027-chengdu.sql` is also in the repo.

**Pre-check of the 7 held venues.** Population: the 7 venues, all 10 tables with a `venue_id` foreign key (read from `pg_constraint`: addresses, awards, blurbs, city_label_source, geo, hours, listings, photo_refs, price, slugs), plus `redirects`, `rename_rows` and `ingest_rows`.
- Each venue held: 1 award (Michelin 2026 Bib Gourmand, no `source_url`, no other publisher), 1 price (`legacy_guide`), 2 Michelin city labels (Chengdu, China), 1 listing, 1 canonical `chengdu/…` slug. 0 blurbs, addresses, geo, hours, photo_refs, rename_rows, ingest_rows, redirects.
- No venue held a non-Michelin award, so no question went to Ben.

**The write** (`cleanup-michelin-cn-chengdu-held-7.sql`, Ben "go", committed Oct 5 02:01:26 UTC, Write connector, 1 transaction, all gates passed):
- Deleted 7 venues with their rows: Shudaxia Hot Pot Luomashi Branch `ve_ff8d4998fc` (9774), Zhongshuijiao `ve_27c721b197` (9775), Jincheng Fengqiwu Freshwater Fishes Restaurant `ve_a63b7965ed` (9778), Shuyanfu `ve_c2e875e4a0` (9779), Ma Wang Zi Chuan Restaurant `ve_8593c366aa` (9783), Citadines South Chengdu `ve_29c8d7a57b` (9785), Tivano `ve_51c6534d14` (9789).
- Order (as ledger 76): 14 hand audit rows, then delete city_label_source 14, awards 7, price 7, slugs 7, listings 7, venues 7, then 1 ledger row. Old URLs give a 404. No redirect.
- Guards: venue ids md5 `31285f27f58b1afd957f57af75578557`; award ids md5 `bcc44f12bc65c96bb5bed543ecdb668b` (= the held list md5); city label ids md5 `507a33fb2a5f4e9a1eb296b449f9e8c1` (ids 8467–8470, 8475–8478, 8485, 8486, 8489, 8490, 8497, 8498); plan fingerprint `bfca2dfd2f940e704c2f9aba94570da3` (md5 of `venue_id|name|award_id|category|symbol_raw|price_source|city_slug/slug|city label ids`, by venue_id, newline).
- Ledger **85**: michelin, award, 7, job = `cleanup:cleanup-michelin-cn-chengdu-held-7 | contamination rule (Ben, Sep 28): 7 legacy Michelin 2026 Chengdu Bib rows with no provable pairing, deleted with their venues | award ids 9774,9775,9778,9779,9783,9785,9789 | old URLs 404, no redirect | archive method test 1, step 3 of 3`.
- Audit **107,246–107,294** (49 rows, all DELETE): city_label_source 14 (hand), awards 7, price 7, slugs 7, listings 7, venues 7.
- Read-back: as in Live state. 0 rows remain on the 7 venue ids.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `cleanup-michelin-cn-chengdu-held-7.sql` (247 lines) | Run. Chat file. Ben to upload to `docs/` (check at the next start) | `afeb8302e5d6cc973c81012ecdc8d211051446c181aae0a669256db7745fb585` |
| `docs/source-url-michelin-2026-chengdu-legacy.sql` | Run, in the repo | `619cc3fd…26075a5a` |
| `reports/chengdu-2026-archive-relay.jsonl` | Final, in the repo | `216ffff2…f5ffc` |
| `fixtures/ingest/michelin-2026-chengdu.csv` / `-decisions.csv` | Final, in the repo | `6b40b0c5…6b517a` / `26b21b4c…6d7130` |
| `reports/michelin-2026-chengdu-archive-evidence.md` | Final, in the repo | `3455894b…849ead` |

## Database notes (carried from Oct 2, plus new)
- `source_capture_ledger` has no note column (columns: id identity ALWAYS, publisher, field_type, items, captured_at default now(), job). A ledger note goes in `job` after the job key, separated by ` | `. The `kind:key` prefix stays first. Ledgers 84 and 85 use this form.
- `audit_log` columns: id (identity ALWAYS), table_name, row_pk, action, old_row, new_row, at (default now()). No `actor` column. A hand audit row: `INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL ...` before the delete.
- Trigger audit rows use `row_pk` = award id for `awards`, and `row_pk` = venue_id for `price`, `slugs`, `listings`, `venues`.
- Triggers (from `pg_trigger`): `trg_audit_awards`, `trg_audit_listings`, `trg_audit_price`, `trg_audit_slugs`, `trg_audit_venues`, `trg_venue_rename`. None on `city_label_source` or `source_capture_ledger`.
- `redirects` columns: `from_path`, `to_path` (text).
- All 10 foreign keys to `venues` have no ON DELETE action, so a venue delete fails if a child row remains.

## Methods that worked (this session and Oct 2)
- **Venue-delete pre-check:** list the foreign keys first (`pg_constraint` with `confrelid='public.venues'::regclass`), then count every child table per venue. Also check `redirects`, `rename_rows` and `ingest_rows` by text match (no foreign key).
- **Gated venue delete:** guards on md5 of each id list and a plan fingerprint read live inside the `DO` block; expected counts before and after; audit rows checked by table and `row_pk`; post-check that 0 rows remain on the venue ids.
- **Category count in one number:** `Two Stars*10000 + One Star*100 + Bib` (Chengdu 2026 = 21127).
- **Per-row test from files, not from typing:** a Python script writes SQL `VALUES` from the relay and the fixture + decisions file, with an md5 guard per set. Line N of the decisions file = data row N of the fixture.
- **Plan fingerprint:** run the plan query read-only, record the md5, then gate on it inside the `DO` block.
- **Syntax check before the dry run:** `pglast.parse_sql(file)`, then `pglast.parse_plpgsql('CREATE FUNCTION f() RETURNS void LANGUAGE plpgsql AS $x$' + body + '$x$;')`.
- **Dry run:** send the `DO` block up to the first write through the Read connector. It stops with "read-only transaction". A read after the dry run shows no id was used. Post-checks run only in the real transaction.
- **Price evidence for a venue with no price row:** read the audit_log rows of the earlier move (the deleted price row keeps `symbol_raw` in `old_row`). Gate on the audit ids.
- **Name-only venue test:** loose key (`looseKey.ts`, inline in SQL with `f_unaccent`) of the venue name = loose key of the card name with a trailing `(…)` branch removed.
- **Archive URL offsets:** in `https://web.archive.org/web/<ts>id_/<url>`, `substr(url, 29, 14)` = timestamp, `substr(url, 47)` = the captured URL. Condition in SQL: `source_url ~ '^https://web\.archive\.org/web/\d{14}id_/https://guide\.michelin\.com/'`.
- **Relay build in one tab on web.archive.org:** CDX per locale without `collapse`, store on `window`, sequential loop (1.2 s pause) over `/web/<ts>id_/<url>`, keep the first in-window capture that names the edition, record `response.url` (0 redirects). Write the lines (sorted, non-ASCII as `\uXXXX`), hash in the browser, save by heredoc, compare the hash.
- **Repo check:** fresh `git clone --depth 1`, then `sha256sum`.

## Dead ends: do not retry
- `audit_log.actor` (no such column).
- `information_schema.triggers` through the Read connector (shows no `awards` triggers). Use `pg_trigger`.
- `pglast.parser.parse_plpgsql` (no such attribute). Use `pglast.parse_plpgsql`.
- An address test for Chengdu legacy venues (`addresses` had 0 rows for them).
- A ledger note column (none exists).
- `ingest_batches.year` (column is `list_year`); `source_capture_ledger.item_count` (column is `items`); `audit_log.op` (column is `action`).
- A `web.archive.org` venue name as the match key when the name changed between editions (check `norm_key` first, add a `use:` decision).
- Looking for earlier cleanup SQL files in the repo as a template: none are there (ledger 52, 76, 79 files were chat files). Use this session's file or the audit_log rows as the model.

## Open items, in order
1. **Germany, #8 (next work block)** (806 legacy / 0 sourced, read Sep 28: 468 labelled 2025, 338 labelled 2026). Ceremony date from a guide.michelin.com URL; 2027 edition check (rule 2.1.7); label check on the 338 rows labelled 2026; then promote and cleanup under amended rule 2.1.1 and the Sep 28 standing rules (temporary closure, conflicting evidence, Michelin-closed venue, contamination with no pairing). Rule text is in Plan v1.29 (`docs/CompassEats-Rearchitecture-Plan.html`).
2. **Plan v1.30.** Not started. Content: item 9 of the Sep 28 renamed-reviewed handoff (Chengdu rename batch 10, slug file, Set 1 cleanup ledger 79, the archive source, the Sep 28 ruling with the 15-row count, Ben's three decisions, the Italy/Spain small-read table); the Oct 2 promote session (ceremony URLs, relay rebuild and hash, batch 12, ledger 82–83, audit 107,203–107,220, line 15 decision, new venue `ve_24aeca03f9`); the Oct 2 25-row update (ledger 84, audit 107,221–107,245, the 4516 and 9788 decisions); this cleanup (ledger 85, audit 107,246–107,294, Chengdu 40 of 40 sourced); the ledger note form in `job`; "archive method test 1 complete". Method: plan-edit method in the v1.29 handoff (read the `Version` line first; expect 1.29).
3. France slug set (148 venues). Ben decides when.
4. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
5. Price from the Michelin card (3,739 venues, plus The Hall ¥¥¥¥). Ben chooses the method. NOTE: the 3,739 population was read before the Chengdu cleanup; read it again.
6. Later-ceremony guides, promote only: Texas after Oct 8, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
7. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star (no column).
8. Rechecks, no date: Dill (status), Kilberry Inn (reopening date), Endo at the Rotunda (reopening), Hare & Hounds (reopening after the fire), Zhu Ji Zhi Mian Pu (left the guide in 2027; status `active`, no closure evidence).
9. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`.

## Suggested opening prompt
```
Read the attached handoffs (handoff-chengdu-held-7-cleanup-done-2026-10-04.md first, then handoff-chengdu-renamed-reviewed-2026-09-28.md for the Sep 28 ruling and decisions, then handoff-plan-v129-done-2026-09-28.md and handoff-michelin-chengdu-2027-done-2026-09-28.md for methods, dead ends and database notes). Confirm live counts, ledger id 85 and audit_log id 107,294 with a Read query, and check that docs/cleanup-michelin-cn-chengdu-held-7.sql in the repo has sha256 afeb8302…7745fb585 (tell me if it is missing). Read the Version line of docs/CompassEats-Rearchitecture-Plan.html (expect 1.29). Then start open item 1, Germany: find the Germany 2026 and 2027 ceremony dates from guide.michelin.com URLs, read the Germany legacy rows (labels 2025 and 2026), and tell me in /ste style which rules apply and what the promote and cleanup will need. Ask me any question the plan does not decide. No write before my go.
```

If Ben wants Plan v1.30 first, replace the last three sentences with: "Then start open item 2, Plan v1.30: build it from v1.29 with the plan-edit method, check it, and present it before I save it."
