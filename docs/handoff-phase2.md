# CompassEats — Phase 2 Handoff
**From:** the Fable design/escalation chat (closed Aug 24, 2026)
**To:** the next working sessions — a Sonnet chat for the apply batch and pipeline build, a Cowork task for the classification pass
**Reader:** Ben runs every step — non-technical, click-by-click, one statement at a time, dry-run before any write, logs pasted back. Every count states its population and grouping key.

**Authoritative docs:** Re-Architecture Plan v1.15 · Schema Map v1.7 · compass-schema-v1.sql · handoff-phase1-execution.md · the Phase 1 load + verification handoffs · the Aug 24 verified-triage PDF · `triage-final.csv` (this handoff's companion — the machine-readable verdict record for all 163 groups). Docs override memory.

---

## 1 · State as of August 24

Phase 1 is closed except the apply batch below. Live and verified in Supabase: venues 10,903 · cities 3,176 (11 destination regions) · awards 21,846 across 21 sources · listings 10,903 · slugs 10,903 + 5 non-canonical restores · blurbs **142** (141 Option B records, one covering a dual-category twin) · city_aliases 263 · price **7,092** legacy-guide symbol rows · norm_key NULL-guard live (120 short-key venues exempt from dedupe) · geo, addresses, hours, photo_refs deliberately empty.

The placeId triage is **decided in full**: `triage-final.csv` holds all 163 groups — 137 machine-passed keeps (pin-home + name test), 23 verified keeps, 2 name-mismatch drop-alls (Taian, ivy), 1 removal (Dialog in the Dark). 160 groups keep exactly one placeId; every other collision row loses its id.

## 2 · The apply batch (Sonnet chat, gated SQL, in this order)

Generate from `triage-final.csv` + the verified PDF. One statement at a time, dry-run SELECT before every write, counts verified after each. All operations are audit-logged by trigger.

1. **Deletions (PHANTOM ×3 + NOT A VENUE ×2 rows):** the-angel [beersel], pco [mumbai], harry-sasson [sao-paulo], dialog-in-the-dark [tokyo] and [los-angeles]. Child rows first (awards, price, blurbs, listings, slugs), then venues. Their slugs do NOT survive — these venues never existed; a redirect would point at nothing.
2. **Closure (Oxalis Schluchsee):** `status='closed'`, `listings.published=false`. Award record untouched. First live use of the closed-venue rule.
3. **MERGE class (8 groups):** loser rows fold into keepers exactly like the load's 11 merges — awards move dedupe-aware, listings/price/blurbs resolve to keeper, loser slugs become non-canonical rows pointing at the keeper, loser venue rows delete. Jory additionally needs the `newberg` city created (region stays Willamette Valley); the merged venue moves there and both old slugs (portland, willamette-valley-oregon) stay non-canonical.
4. **Name fixes (11, from the PDF's verbatim list):** Taian Table, Taian Table Guangzhou, Chez Philippe (Memphis), Allium at Askham Hall, The Ivy (Los Angeles), Amelia (Dubai), Eau de Vie Melbourne, Dry Martini Sorrento, Seed Library (London), Da Vittorio St. Moritz, Da Vittorio Shanghai. The rename guard requires the job flag — one-statement pattern: `WITH cfg AS (SELECT set_config('app.allow_rename','on',true)) UPDATE venues ... FROM cfg`. Names drive slugs: existing slugs stay as they are (URLs unchanged); no blurb re-keying needed (none of these carry Option B blurbs).
5. **photo_refs load:** one row per venue with an unambiguous placeId — the 160 keepers from `triage-final.csv` plus every venue never in a collision group, ids from the enrichment export (`places_enrichment.csv`, keyed by normalizedKey + placeId). Staging-table pattern like the price load. Every venue in a collision group that is NOT the keeper gets no row — compass-mark fallback, as ratified. Expected photo losses ≈ the non-keeper collision members (~200 venues; state the exact count in the dry run).
6. **New placeIds for the 17 named twins** (Da Vittorio St. Moritz + Shanghai, Chez Philippe Memphis, Primo Orlando, Allium at Askham Hall, Bulgari Bar Rome + Milan, Spago Maui, Eau de Vie Melbourne, COA Shanghai, Dry Martini Sorrento, Amelia Dubai, Seed Library London, Taian Table Guangzhou + Shanghai, The Ivy LA, ivy Sydney): **hand re-attach, zero API** — Ben copies each venue's placeId from its Google Maps share link at his leisure; a small guarded INSERT template takes them as they come. No bulk re-query (ratified), no quota change.

## 3 · The classification pass (Cowork task — browsing-heavy, citation-per-verdict)

The 137 machine-passed groups still owe their other-row classification under the four classes (MERGE / TWIN / PHANTOM / NOT A VENUE). The Aug 24 PDF's standard governs: verify against award sources and the venue's own site, cite a source per verdict, name mismatch disqualifies even on an address match, and flag any machine drop that smells like the three matcher bug classes (metro containment, diacritics, adjacent postal names). Opening prompt: use the one at the end of the verified PDF, updated with: the 26 are settled, the missing-name gap is closed (the enrichment export named all 163 groups), and output extends `triage-final.csv` in place.

## 4 · Phase 2 proper (Sonnet chat, after the apply batch)

Pipeline repo, staged jobs, guards, publish builder — per Plan §5/§7. Two requirements already ratified into it: the publish builder gates on `listings.published`, never `venues.status`; and every ingest array, prompt, and watch list derives from `award_sources` (seed 23). Opus checkpoint on the invariant suite before first promote.

## 5 · Open items and owners

- **Ben:** send the specialist brief (Plan §6 — now six questions + the exposure inventory). Read the Michelin card. Paste placeIds for the 17 twins as convenient.
- **Next chats:** the closed-venue sweep (new pre-swap workstream, own detection pass + approval gate — scope in Phase 2 chat). Award Radar checks: Asia's 50 Best Bars 2026 absent entirely; Asia restaurants 51–100 missing 2022; four upper-band existence checks; Yangzhou Shang Palace missing (Ben-verified starred venue, no row). The three wrong-city duplicate venues (Mugaritz-Munich, Noor-Groningen, Nakamura-Tokyo) + suspect Beersel-Angel: now covered by the apply batch's PHANTOM deletions where verified, else merge_review.
- **Blurb program:** 142 attached, all `needs_rewrite`. Ben's researched branch facts (Étude→Aix, Joo-ok→NYC, Hakkasan→Abu Dhabi, Sushi Shin→Tokyo, Shang Palace→HK, Niko Romito→four starred branches) are rewrite-program inputs, recorded in the Aug 23 thread.
- **Judgment-grade, still owed:** the joined-tab measurement (discordant counts, per-stratum rollup, both reweighted arms together) — reviewer session holds the CSVs. Escalate the verdicts to Opus/Fable.
- **Escalation triggers unchanged:** verification surprises, joined-tab verdicts, specialist/Michelin answers, ratified-rule changes, Phase 4 design.

*The design-and-Phase-1 thread closed Aug 24 with the triage decided 160/2/1 and every rule it produced on the record in Plan v1.15.*
