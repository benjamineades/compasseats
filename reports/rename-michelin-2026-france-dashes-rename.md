# Rename apply - rename-michelin-2026-france-dashes

Committed 2026-09-15T03:33:57.684Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-france-dashes` |
| CSV | `fixtures/rename/michelin-2026-france-dashes.csv` |
| rows in the file | 17 |
| renamed | 17 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | French dash names, 17 rows, browser-checked |

## Verdicts

Population: all 17 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 17 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 17 row(s) this batch would rename, read from the database before a single name changed.

17 of the 17 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_0500893ff4` | mont-de-marsan | Villa Mirasol | Bistrot 1912 | michelin 2 | no | /mont-de-marsan/villa-mirasol |
| `ve_12e5bf15ad` | clermont-ferrand | Restaurant Le Pré | Le Pré | michelin 2, la-liste 1 | no | /clermont-ferrand/restaurant-le-pre |
| `ve_2bd91023d9` | paris | L'Atelier de Joël Robuchon Étoile | L'Atelier de Joël Robuchon - Étoile | michelin 2 | no | /paris/l-atelier-de-joel-robuchon-etoile |
| `ve_30501b82cb` | carantec | Restaurant Nicolas Carro | Nicolas Carro | michelin 2, gault-millau 1 | no | /carantec/restaurant-nicolas-carro |
| `ve_3a24173df2` | evian-les-bains | Fresques | Les Fresques | michelin 2 | no | /evian-les-bains/fresques |
| `ve_4dd54878f0` | saint-julien-chapteuil | Maison vidal | Maison Vidal - Le Bistrot de Justin | michelin 2 | no | /saint-julien-chapteuil/maison-vidal |
| `ve_4e77c0295c` | saint-remy | L’Auberge De Saint-Rémy | L'Auberge de Saint-Rémy | best-chef-awards 2, la-liste 1, michelin 1 | no | /saint-remy/l-auberge-de-saint-remy |
| `ve_52ded554a8` | vannes | Ryoko - Comptoir à Ramen | Ryoko - Comptoir à ramen | michelin 2 | no | /vannes/ryoko-comptoir-a-ramen |
| `ve_54db80a526` | saumur | La Table By Mi - K'L | La Table By Mi-K'L | michelin 2 | no | /saumur/la-table-by-mi-k-l |
| `ve_6461b9da4d` | paris | Kodawari Ramen (Yokochō) | Kodawari Ramen - Yokochō | michelin 2 | no | /paris/kodawari-ramen-yokocho |
| `ve_82af616d87` | polliat | Le Restaurant Téjérina | Téjérina | michelin 2 | no | /polliat/le-restaurant-tejerina |
| `ve_a0adf5e745` | la-clusaz | Restaurant Le Cin5 | Le Cin5 | michelin 2 | no | /la-clusaz/restaurant-le-cin5 |
| `ve_bbccd34af8` | paris | Table Bruno Verjus | Table | worlds-50-best-restaurants 3, best-chef-awards 2, la-liste 1, michelin 1, oad 1 | no | /paris/table-bruno-verjus |
| `ve_c09c6dfd4d` | blois | Restaurant Christophe Hay | Christophe Hay | michelin 2, la-liste 1 | no | /blois/restaurant-christophe-hay |
| `ve_d89d0b6d74` | bonnieux | JU-Maison de Cuisine | JU - Maison de Cuisine | michelin 2 | no | /bonnieux/ju-maison-de-cuisine |
| `ve_ea838a498e` | paris | Restaurant Le Gabriel | Le Gabriel | best-chef-awards 2, michelin 2, gault-millau 1, la-liste 1 | no | /paris/restaurant-le-gabriel |
| `ve_f8977eb5ab` | rosenau | AU LION D'OR | Au Lion d'Or | michelin 2 | no | /rosenau/au-lion-d-or |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 17 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,258 | 11,258 | 11,258 |
| awards | 22,884 | 22,884 | 22,884 |
| slugs | 11,515 | 11,515 | 11,515 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 13 | 14 | 14 |
| rename_batches | 1 | 2 | 2 |
| rename_rows | 252 | 269 | 269 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 17 (expected 17) |
| every renamed venue's live name is its new_name | pass | 0 of 17 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 17 (expected 17) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 17 name changes (expected 17), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 17 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_0500893ff4` | Villa Mirasol | Bistrot 1912 | venue | https://www.villamirasol.fr/fr/restaurant-bistronomique |
| `ve_12e5bf15ad` | Restaurant Le Pré | Le Pré | michelin | https://guide.michelin.com/en/auvergne-rhone-alpes/clermont-ferrand/restaurant/le-pre-xavier-beaudiment |
| `ve_2bd91023d9` | L'Atelier de Joël Robuchon Étoile | L'Atelier de Joël Robuchon - Étoile | michelin | https://guide.michelin.com/en/ile-de-france/paris/restaurant/l-atelier-de-joel-robuchon-etoile |
| `ve_30501b82cb` | Restaurant Nicolas Carro | Nicolas Carro | michelin | https://guide.michelin.com/en/bretagne/carantec/restaurant/nicolas-carro |
| `ve_3a24173df2` | Fresques | Les Fresques | michelin | https://guide.michelin.com/en/auvergne-rhone-alpes/evian-les-bains/restaurant/les-fresques400460 |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-france-dashes`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 15 |

2 row(s) name `venue` as their source - the venue's own website settled the spelling. The venue is not a publisher and holds no row in `award_sources`, which `source_capture_ledger.publisher` points at, so those rows are not in the ledger. They are in `rename_rows` with their URL, like every other row.

Spellings followed: michelin (15), venue (2).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2026-france-dashes`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2026-france-dashes`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
