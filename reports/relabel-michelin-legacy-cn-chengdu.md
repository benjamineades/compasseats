# Decisions record: relabel-michelin-legacy-cn-chengdu

Rule: Fable ruling of Sep 24, 2026 (rule 5 and new rule 2.1.7).
Batch note (rule 5): "edition year set from the ceremony date, capture May 13 to June 1, 2026, no per-row URL".
Scope: city `ci_354b500e3a` (Chengdu) only. Not country CN.
Change: 32 Michelin award rows, year 2025 → 2026. No other column changes.

## Condition 1: ceremony date before May 13, 2026, on a Michelin URL

- Chengdu 2026 (5th edition) was published on **Sep 2, 2025**.
- URL: https://guide.michelin.com/mo/en/article/news-and-views/michelin-guide-chengdu-2026
- Published counts: Two Stars 2, One Star 11, Bib Gourmand 27 (40 rows).
- Chengdu 2027 replaced it on Sep 7, 2026: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-stars-chengdu-2027
- So the edition live in the capture window (May 13 to June 1, 2026) was Chengdu **2026**.

## Condition 2: three named 2026 changes match the legacy rows

The article names 5 changes in the 2026 edition: Co- (promoted to One Star), and 4 new Bib Gourmand restaurants. Three of the 4 new Bibs are in the legacy rows with the same category. None of them was in the 2025 edition.

| 2026 change (Michelin name) | Michelin URL | Legacy row | Legacy category | Result |
|---|---|---|---|---|
| Bai Nian Fen Zheng Niu Rou, new Bib | https://guide.michelin.com/hk/en/chengdu-municipality/chengdu/restaurant/bai-nian-fen-zheng-niu-rou | award 9772, `ve_84dc39ab0e` "Bainian Fenzheng Beef" | Bib Gourmand | match |
| Zeng Niu Rou (Qingyang), new Bib | https://guide.michelin.com/hk/en/chengdu-municipality/chengdu/restaurant/zeng-niu-rou-qingyang | award 9793, `ve_fa5e39740d` "Zengniurou" | Bib Gourmand | match |
| Long Sen Yuan (Qingyang), new Bib | https://guide.michelin.com/hk/en/chengdu-municipality/chengdu/restaurant/long-sen-yuan | award 9781, `ve_7ab59d83eb` "Longsenyuan" | Bib Gourmand | match |
| Cuo Xia, new Bib | https://guide.michelin.com/hk/en/chengdu-municipality/chengdu/restaurant/cuo-xia | none | none | absent |
| Co-, promoted to One Star | https://guide.michelin.com/hk/en/chengdu-municipality/chengdu/restaurant/co | none | none | absent |

Result: **pass**. The legacy rows hold three venues that exist only from the 2026 edition. Two changes are absent. The snapshot holds 32 of the 40 published rows, so it is incomplete, like the Spain and Italy snapshots. This does not change the edition label.

## Condition 3: this record

This file records the URLs and the tests. It is written before the "go".

## Condition 4: rule 6 read (no unsourced 2026 row in scope)

Population: Michelin rows on venues in `ci_354b500e3a`, by year and source state. Read on Sep 24, 2026, with the Read connector.

| year | sourced | rows |
|---|---|---|
| 2025 | false | 32 |

No 2026 line. **Pass.** One city in the table has "Chengdu" in its display name.

## Note for the later match test (not part of this batch)

Several legacy Chengdu names are not Michelin names: "Upper House Chengdu", "Heming Tea House", "Xiaolongkan Old Hot Pot", "Chenmapo Sichuan Restaurant" (One Star) and "Citadines South Chengdu" (Bib). They look like name contamination. The relabel keeps them as they are. The Chengdu 2027 match test must pair them by hand, and some can be wrong-venue rows.
