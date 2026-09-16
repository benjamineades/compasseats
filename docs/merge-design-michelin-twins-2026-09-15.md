# Merge design: France and Italy Michelin twins (Sep 15, 2026)

Status: both batches ran on Sep 15, 2026 (`merge-michelin-twins-fr`, ledger id 27; `merge-michelin-twins-it`, ledger id 28). The read-back counts agree with the table below. Ben chose "yes" for the Il Falconiere URL. Written by the execution chat after the Fable ruling `fable-ruling-michelin-2025-label-2026-09-15.md` (Option B, merge).

## Inputs

| File | Merge pairs | Pair-list checksum (sorted `keep|twin`) |
|---|---|---|
| `reports/michelin-2026-france-pairing.csv` | 260 (259 `merge`, 1 `merge-keep-twin`) | 64a0bbced772627ae5fc9e766fcaefed |
| `reports/michelin-2026-italy-pairing.csv` | 296 (`merge`) | c264a3ab9fb765de6c5e594c0ea9ca8d |

On Sep 15, the same rules applied to the live database gave the same two checksums. So the database and the approved files agree.

Words used here:
- **S** is the survivor, the venue that stays.
- **T** is the twin, the venue that goes.
- For a `merge` row, S is `keep_venue_id` and T is `twin_venue_id`.
- For the one `merge-keep-twin` row (La Voile), S is `ve_8a8e59f190` (La Voile) and T is `ve_8dd105f770` (La Réserve Ramatuelle). La Voile holds La Liste 2026 and the correct name. The hotel venue holds only the old Michelin row.

## What each table holds today (population: the 556 pairs)

| Table | On S | On T | Pairs with a row on both |
|---|---|---|---|
| awards | 771 | 556 | 556 |
| city_label_source | 1,115 | 1,112 | 556 |
| listings (all published) | 556 | 556 | 556 |
| slugs (all canonical) | 556 | 556 | 556 |
| price | 555 | 1 | 0 |
| blurbs | 5 | 0 | 0 |
| geo, photo_refs, hours, addresses | 0 | 0 | 0 |
| rename_rows | 0 | 0 | 0 |

The one T price row is on the hotel venue in the La Voile pair. La Voile has no price row.

## Steps for each batch (one transaction, one DO block)

1. **Pre-checks. If one check fails, the batch stops and changes nothing.**
   - Both venues of each pair exist and are in the batch country.
   - For a `merge` pair: T has one sourced Michelin 2026 row and no 2025 row, and S has an old 2025 row (no URL) in the same category and no 2026 row.
   - For the La Voile pair: these conditions apply in the opposite direction.
   - No venue is in two pairs.
2. **awards:** move all T award rows to S.
3. **awards:** delete each old Michelin 2025 row (no URL) on S when S now has a sourced 2026 row in the same category. This is the same rule as batches 4.1 to 4.3.
   - Italy only: also delete award 8447 (La Torre, old Bib). Michelin 2026 has no Bib for La Torre in that town.
4. **city_label_source:** move all T rows to S. This table has no audit trigger, so the batch writes one `audit_log` row for each move (table `city_label_source`, action `UPDATE`, old and new row).
5. **price:** if S has no price row and T has one, move it to S. Otherwise, delete the T row. France: 1 move (La Voile). Italy: 0.
6. **slugs:** move the T slug to S, with `is_canonical = false`. The Michelin-name URL stays in the table and points to S. No slug is deleted, and no redirect is added. These URLs were created on Sep 14 and 15, and the live site does not read them yet.
   - **Italy, Il Falconiere only (needs Ben's decision):** make the `cortona/il-falconiere` slug canonical, and make `san-martino/relais-chateaux-il-falconiere-spa` non-canonical. This makes the canonical URL agree with the Michelin town.
7. **listings:** delete the T listing. The S listing stays published.
8. **venues (S):**
   - Set status from `closed` to `active` where Michelin 2026 lists the venue: 4 in France (Vous, L'Ekrin, Espadon, Simple et Meilleur) and 8 in Italy (Tivoli, Dolomieu, Il Gallo Cedrone, Malga Panna, Laite, Nole, Terme, Alla Pace).
   - Italy: set the city of Il Falconiere (`ve_063f92c73f`) to Cortona (`ci_ef3df1afff`).
   - Names do not change. The rename guard stays on.
9. **venues (T):** delete T.
10. **Ledger:** one `source_capture_ledger` row, with publisher `michelin`, field_type `award`, items = number of pairs, and job `merge:merge-michelin-twins-fr` (or `-it`).
11. **Assertions before the commit.** Every count in the table below must be exact. After the merge, no venue in the country can have two Michelin rows in the same category, and no venue can have an old row and a sourced row in the same year.

## Expected counts (population: whole table)

| Count | Now | After France | After Italy |
|---|---|---|---|
| venues | 11,590 | 11,330 | 11,034 |
| active venues | 11,210 | 10,954 | 10,666 |
| awards | 22,521 | 22,261 | 21,964 |
| Michelin 2025 rows | 5,556 | 5,296 | 4,999 |
| Michelin 2026 rows | 3,216 | 3,216 | 3,216 |
| listings | 11,590 | 11,330 | 11,034 |
| slugs | 11,847 | 11,847 | 11,847 |
| non-canonical slugs | 257 | 517 | 813 |
| city_label_source | 23,464 | 23,464 | 23,464 |
| price | 7,091 | 7,091 | 7,091 |
| ledger rows | 22 | 23 | 24 |

Old Michelin 2025 rows left after both batches: France 20 and Italy 4 (the "no twin found" rows). Japan keeps 11.

Arithmetic:
- Active venues, France: 11,210 − 260 twins + 4 status fixes.
- Active venues, Italy: − 296 + 8.
- Italy awards and Michelin 2025 rows: − 296 − 1 (La Torre Bib).
- Non-canonical slugs, Italy: + 296, with Il Falconiere as a swap. The count is the same whether or not the swap runs.

## What the merge does not do

- **Names.** Survivors keep their old Google-style names. For the rename job, the Michelin names are in the `twin_name_michelin` column of the pairing files. The ruling says that the twin cleanup must finish before the rename job touches France or Italy. After these two batches, it is finished.
- **`cities.venues_count`.** Its own refresh job maintains this count. After the merge, the city San Martino holds no venue.
- **blurbs, geo, photos, hours, addresses.** Only 5 survivors have blurbs, and no twin has any of these rows.

## Consequences

- `UNDO michelin-2026-france` and `UNDO michelin-2026-italy` will refuse after the merge, because the twin venues no longer exist. The ruling accepts this cost.
- Recovery is through `audit_log`. Every changed row is logged there: venues, awards, slugs, listings, price, and the hand-written `city_label_source` rows.

## After the batches

- Read the counts back with the Read connection, and compare them with the table above.
- Plan v1.22: record the Fable ruling, batches 4.1 to 4.4, and both merges.
- Correction (Sep 15): an earlier chat note said that the ruling counted 89 Italy name pairs. That was wrong. Ruling section 6.1 counts 256, the same as this design.
