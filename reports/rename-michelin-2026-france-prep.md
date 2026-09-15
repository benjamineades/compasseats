# Michelin 2026 France — the rename file, before you run it

Measured 2026-09-15 against the live database. **Nothing has been renamed.** This is the
file the rename job would read, and the reasons behind every row in it.

## The short version

- **252 names are ready to change.** They are in `fixtures/rename/michelin-2026-france-names.csv`.
- **29 are not, and need you.** 28 because of a dash, 1 because of a Chinese name. They are listed below and in `reports/rename-michelin-2026-france-unsure.csv`.
- **281 venues** were in scope. 252 + 29 = 281.
- Two of the three rulings could not be applied the way they are written, and the report
  says exactly why rather than pretending otherwise. Both land the same way: the rows they
  cover are held back, not guessed at.

## What to do next

1. Read the two lists below — the 28 dash names and the one Chinese name. Decide each one.
2. Run **Rename — apply** with `dry_run` **ticked**:

```
csv_path:     fixtures/rename/michelin-2026-france-names.csv
batch_key:    rename-michelin-2026-france
confirmation: RENAME rename-michelin-2026-france
dry_run:      ticked
```

3. Read that report. If it says 252 renamed, 0 refused, 0 needing you, run it again unticked.
4. Your decisions on the 29 held rows go in a **second file under a new batch key**. A key is
   used once, for ever, so they cannot be added to this one.

## The pool, measured again today

Population: the rows of ingest batch `michelin-2026-france` with verdict `match`, joined to
`venues`, where the live name differs from Michelin's `venue_name`.

| what | number |
|---|---|
| `match` rows in the batch | 719 |
| of those, live name differs from Michelin's | **281** |
| matched by a `use:` decision | 161 |
| matched on the exact name key | 120 |
| of those 120, differ by letter case only | 73 |
| a spaced dash in Michelin's name | 27 |
| a spaced dash in the current name | 2 |
| a spaced dash on either side (one venue has both) | **28** |
| hold an award from a publisher other than Michelin | 50 |
| hold awards from two or more other publishers | 20 |

Three of the handoff's numbers were worth re-measuring, and two moved:

- **161 `use:` pairs, where the handoff said 159.** 161 is what is in the database today. Where
  the other two came from is not recorded anywhere, so this report does not offer a reason.
- 73 case-only, confirmed exactly.
- **28 venues under ruling 2, not 29.** 27 + 2 = 29 counts one venue twice: `ve_52ded554a8`
  ("Ryoko - Comptoir à Ramen") has a spaced dash on both sides.

## Ruling 3 — majority wins. It could not run at all.

`awards` has no name column, so the only way to read another publisher's spelling is to open
that award's `source_url`. Measured across the 50 venues that hold a non-Michelin award:

| what | number |
|---|---|
| venues holding an award from another publisher | 50 |
| non-Michelin award rows on them | 118 |
| **of those, rows carrying a `source_url`** | **0** |
| distinct other publishers involved | 6 |

Every one of those 118 rows is a legacy row with no source URL. **No other publisher can
vote on any of the 281.** So ruling 3's last clause applies to the whole pool: one publisher
only, follow that publisher. Michelin's spelling wins every row in the file by default, not
by a vote it won.

This is worth knowing beyond this file: until the other guides are re-ingested through the
ingest job with their URLs, no majority vote can ever be computed for any venue.

### The 50 venues where no other publisher could vote

Population: the 281, joined to their non-Michelin awards. Every row below has 0 URLs.

| venue id | name now | other publishers, and how many rows |
|---|---|---|
| `ve_023efa5fc2` | Restaurant Cédric Burtin | la-liste x1 |
| `ve_0c4e0915ee` | Auberge des Glazicks | gault-millau x1, la-liste x1 |
| `ve_0dbdcc762c` | Restaurant L'Oustau de Baumanière*** | best-chef-awards x2, gault-millau x1, la-liste x1 |
| `ve_0e67db9894` | Jardin Des Sens | worlds-50-best-restaurants x2 |
| `ve_12e5bf15ad` | Restaurant Le Pré | la-liste x1 |
| `ve_1e4cfc0414` | LA BÒRIA | gault-millau x1 |
| `ve_21529fc55c` | Neige d'été | oad x1 |
| `ve_2332f48c17` | Restaurant Paul Bocuse | gault-millau x1, la-liste x1, worlds-50-best-restaurants x3 |
| `ve_2e985904ad` | Fleur de pavé | oad x1 |
| `ve_30501b82cb` | Restaurant Nicolas Carro | gault-millau x1 |
| `ve_33a1b4d4fc` | JIN | oad x1 |
| `ve_35d4ecca12` | Le Clos Des Sens | gault-millau x3, la-liste x1 |
| `ve_39ac1adc6c` | Hôtel Casadelmar | la-liste x1 |
| `ve_3cb99fd3d6` | Restaurant Soléna | gault-millau x1 |
| `ve_47aea93e3a` | Auberge Du Vert Mont | best-chef-awards x1 |
| `ve_48912b20f9` | Restaurant David Toutain | best-chef-awards x2, la-liste x1, oad x1 |
| `ve_4e77c0295c` | L’Auberge De Saint-Rémy | best-chef-awards x2, la-liste x1 |
| `ve_500702a2cd` | La Vague d'Or | gault-millau x2, la-liste x1 |
| `ve_59baf7ce7f` | Epicure | best-chef-awards x1, la-liste x1, wine-spectator x1 |
| `ve_5a2faf7397` | Restaurant Mirazur | best-chef-awards x2, gault-millau x1, la-liste x1, oad x1, worlds-50-best-restaurants x9 |
| `ve_5a67e55a7a` | Hôtel L' Assiette Champenoise | best-chef-awards x2, gault-millau x1, la-liste x1 |
| `ve_5b5ae98066` | Restaurant le Meurice Alain Ducasse | best-chef-awards x2, gault-millau x2, la-liste x1 |
| `ve_6522e4fb4b` | La Tour d'Argent | wine-spectator x1, worlds-50-best-restaurants x1 |
| `ve_6b022b029a` | Le Restaurant des Rois | gault-millau x2 |
| `ve_726a22f45a` | RESTAURANT Takao Takano | la-liste x1 |
| `ve_78e2ebdb64` | Le Manoir De La Régate | best-chef-awards x2, gault-millau x1 |
| `ve_7c2f54f0ab` | Restaurant Akrame | la-liste x1 |
| `ve_829f7fd32b` | Restaurant Omar Dhiab | oad x1 |
| `ve_846788b091` | ARBANE | gault-millau x1 |
| `ve_8859261736` | Relais De La Poste | la-liste x1 |
| `ve_890ec43950` | ROZO | gault-millau x1, la-liste x1 |
| `ve_8a8e59f190` | La Voile | la-liste x1 |
| `ve_95f52c5e5a` | Restaurant La Merise | la-liste x1 |
| `ve_9e5a1fe04b` | Restaurant Cyril Attrazic | best-chef-awards x1, la-liste x1 |
| `ve_a4aa7cb9ba` | Restaurant Frédéric Molina à Forêt Ivre | best-chef-awards x2 |
| `ve_ade26d34b5` | Sushi-B | oad x1 |
| `ve_b56c9cc152` | Palégrié chez l'Henri | oad x1 |
| `ve_b93b8941db` | Restaurant Les Morainières | la-liste x1 |
| `ve_baeae630ab` | Jules Verne | la-liste x1 |
| `ve_bbccd34af8` | Table Bruno Verjus | best-chef-awards x2, la-liste x1, oad x1, worlds-50-best-restaurants x3 |
| `ve_c09c6dfd4d` | Restaurant Christophe Hay | la-liste x1 |
| `ve_c0a013f8c2` | Une Table au Sud | gault-millau x1 |
| `ve_c29125ac38` | Hôtel Restaurant Maison Tiegezh | gault-millau x1 |
| `ve_c2aeca7793` | Plénitude | best-chef-awards x2, gault-millau x2, la-liste x1, worlds-50-best-restaurants x3 |
| `ve_d2820ac4f5` | La Mère Brazier | la-liste x1 |
| `ve_d6d6aa4c8d` | DUENDE | la-liste x1 |
| `ve_ea838a498e` | Restaurant Le Gabriel | best-chef-awards x2, gault-millau x1, la-liste x1 |
| `ve_eeded0c3ef` | Restaurant Kei | best-chef-awards x2, la-liste x1 |
| `ve_fb7c6d6400` | La Table du Castellet*** | best-chef-awards x1, gault-millau x1, la-liste x1 |
| `ve_feac5d24f0` | JY's | la-liste x1 |

## Rulings 1 and 2 — the dash. Held, all 28.

Ruling 2 says every name with a spaced dash is checked **against the venue's own website and
the Michelin page**, and the URL used is recorded. Neither page could be read: this session's
network blocks outbound page fetches. `guide.michelin.com`, a venue's own site
(`lareserve-paris.com`) and even `en.wikipedia.org` were all refused by the egress proxy.
Web search still answers, but a search snippet is not the venue's own page, and recording one
as the URL that settled a name would be a lie in the provenance column.

Ruling 2 already says what to do when no source confirms: **`unsure` — do not rename.** So all
28 are held. None of them is in the CSV.

The Michelin card URL below is measured — it is the `source_url` the promoted batch carries for
that venue. The venue's own website is the missing half; that is the one to open first.

| venue id | name now | Michelin prints | Michelin card |
|---|---|---|---|
| `ve_0500893ff4` | Villa Mirasol | Villa Mirasol - Bistrot 1912 | https://guide.michelin.com/en/nouvelle-aquitaine/mont-de-marsan/restaurant/villa-mirasol-bistrot-1912 |
| `ve_12e5bf15ad` | Restaurant Le Pré | Le Pré - Xavier Beaudiment | https://guide.michelin.com/en/auvergne-rhone-alpes/clermont-ferrand/restaurant/le-pre-xavier-beaudiment |
| `ve_2bd91023d9` | L'Atelier de Joël Robuchon Étoile | L'Atelier de Joël Robuchon - Étoile | https://guide.michelin.com/en/ile-de-france/paris/restaurant/l-atelier-de-joel-robuchon-etoile |
| `ve_30501b82cb` | Restaurant Nicolas Carro | Nicolas Carro - Hôtel de Carantec | https://guide.michelin.com/en/bretagne/carantec/restaurant/nicolas-carro |
| `ve_3a24173df2` | Fresques | Les Fresques - Hôtel Royal | https://guide.michelin.com/en/auvergne-rhone-alpes/evian-les-bains/restaurant/les-fresques400460 |
| `ve_4dd54878f0` | Maison vidal | Maison Vidal - Le Bistrot de Justin | https://guide.michelin.com/en/auvergne-rhone-alpes/saint-julien-chapteuil/restaurant/maison-vidal-le-bistrot-de-justin |
| `ve_4e77c0295c` | L’Auberge De Saint-Rémy | L'Auberge de Saint-Rémy - Fanny Rey & Jonathan Wahid | https://guide.michelin.com/en/provence-alpes-cote-dazur/saint-rmy-de-provence/restaurant/l-auberge-de-saint-remy-fanny-rey-and-jonathan-wahid |
| `ve_500702a2cd` | La Vague d'Or | La Vague d'Or - Cheval Blanc St-Tropez | https://guide.michelin.com/en/provence-alpes-cote-dazur/saint-tropez/restaurant/la-vague-d-or-cheval-blanc-st-tropez |
| `ve_52ded554a8` | Ryoko - Comptoir à Ramen | Ryoko - Comptoir à ramen | https://guide.michelin.com/en/bretagne/vannes/restaurant/ryoko |
| `ve_54db80a526` | La Table By Mi - K'L | La Table By Mi-K'L | https://guide.michelin.com/en/pays-de-la-loire/saumur/restaurant/la-table-by-mi-k-l |
| `ve_6461b9da4d` | Kodawari Ramen (Yokochō) | Kodawari Ramen - Yokochō | https://guide.michelin.com/en/ile-de-france/paris/restaurant/kodawari-ramen |
| `ve_6b022b029a` | Le Restaurant des Rois | Le Restaurant des Rois - La Réserve de Beaulieu | https://guide.michelin.com/en/provence-alpes-cote-dazur/beaulieu-sur-mer/restaurant/restaurant-des-rois |
| `ve_74b0053f51` | Le Feuillée | Le Feuillée - Le Couvent des Minimes | https://guide.michelin.com/en/provence-alpes-cote-dazur/mane/restaurant/le-feuillee-le-couvent-des-minimes |
| `ve_754eff4295` | Alice, le bistrot | Alice, le bistrot - Manoir de la Mortière | https://guide.michelin.com/en/pays-de-la-loire/les-sables-d-olonne/restaurant/alice-le-bistrot-le-manoir-de-la-mortiere |
| `ve_82af616d87` | Le Restaurant Téjérina | Téjérina - Hôtel de la Place | https://guide.michelin.com/en/auvergne-rhone-alpes/polliat/restaurant/tejerina-hotel-de-la-place |
| `ve_8a8e59f190` | La Voile | La Voile - La Réserve Ramatuelle | https://guide.michelin.com/en/provence-alpes-cote-dazur/ramatuelle/restaurant/la-voile |
| `ve_8dccaaf452` | Le Pavillon | Le Pavillon - Hôtel Westminster | https://guide.michelin.com/en/hauts-de-france/le-touquet-paris-plage/restaurant/le-pavillon9000 |
| `ve_9c2e7e5cf0` | Bellefeuille | Bellefeuille - Saint James Paris | https://guide.michelin.com/en/ile-de-france/paris/restaurant/bellefeuille-saint-james-paris |
| `ve_a0adf5e745` | Restaurant Le Cin5 | Le Cin5 - Au Cœur du Village | https://guide.michelin.com/en/auvergne-rhone-alpes/la-clusaz/restaurant/le-cinq |
| `ve_b4a6a34762` | Chez Yvonne | Chez Yvonne - S'Burjerstuewel | https://guide.michelin.com/en/grand-est/strasbourg/restaurant/chez-yvonne-s-burjerstuewel |
| `ve_bbccd34af8` | Table Bruno Verjus | Table - Bruno Verjus | https://guide.michelin.com/en/ile-de-france/paris/restaurant/table-bruno-verjus |
| `ve_c09c6dfd4d` | Restaurant Christophe Hay | Christophe Hay - Fleur de Loire | https://guide.michelin.com/en/centre-val-de-loire/blois/restaurant/christophe-hay-fleur-de-loire |
| `ve_c2aeca7793` | Plénitude | Plénitude - Cheval Blanc Paris | https://guide.michelin.com/en/ile-de-france/paris/restaurant/plenitude-cheval-blanc-paris |
| `ve_d61dd48136` | Le Art | Le Art - Château de la Gaude | https://guide.michelin.com/en/provence-alpes-cote-dazur/aix-en-provence/restaurant/le-art-chateau-de-la-gaude |
| `ve_d89d0b6d74` | JU-Maison de Cuisine | JU - Maison de Cuisine | https://guide.michelin.com/en/provence-alpes-cote-dazur/bonnieux/restaurant/ju-maison-de-cuisine |
| `ve_ea838a498e` | Restaurant Le Gabriel | Le Gabriel - La Réserve Paris | https://guide.michelin.com/en/ile-de-france/paris/restaurant/le-gabriel476630 |
| `ve_ec51bda29b` | Le 1862 | Le 1862 - Les Glycines | https://guide.michelin.com/en/nouvelle-aquitaine/les-eyzies-de-tayac/restaurant/le-1862 |
| `ve_f8977eb5ab` | AU LION D'OR | Au Lion d'Or - Chez Théo | https://guide.michelin.com/en/grand-est/rosenau/restaurant/au-lion-d-or-chez-theo |

Most of these look like ruling 1's case — a hotel or a chef after the dash, which never becomes
part of the venue name. Several plainly are not: `ve_52ded554a8` ("Ryoko - Comptoir à Ramen"),
`ve_54db80a526` ("La Table By Mi-K'L"), `ve_d89d0b6d74` ("JU - Maison de Cuisine") and
`ve_bbccd34af8` ("Table - Bruno Verjus") read like names the venue prints itself. Ruling 2 exists
precisely so that nobody decides that from the look of the string, so none of them is decided here.

## One more held row, for a different reason

**`ve_803026b38a` — "Impérial Choisy 美丽都" → Michelin prints "Impérial Choisy".**

Michelin drops the Chinese name. `venues.name_native` for this venue is NULL (measured), so
that name exists in exactly one place in the database: the name this rename would overwrite.
No ruling asks for that. Ruling 1 drops a publisher suffix; a venue's own name in its own
script is not a publisher suffix. Held, and flagged: the right home for 美丽都 is
`name_native`, which this job never writes.

Michelin card: https://guide.michelin.com/en/ile-de-france/paris/restaurant/imperial-choisy

## What is in the file

Population: the 252 rows of `fixtures/rename/michelin-2026-france-names.csv`.
Grouping key: what kind of difference the rename settles.

| kind of change | rows |
|---|---|
| Michelin spelling | 138 |
| case only | 73 |
| punctuation and spacing | 21 |
| case and accents | 20 |

Every row carries `source_id` `michelin` and that venue's own Michelin card as `source_url`.
`new_name` is Michelin's string exactly as the promoted batch recorded it — not tidied, not
re-cased, not trimmed.

A few of them are worth seeing, because they are the ones that clean up real damage:

| venue id | name now | becomes |
|---|---|---|
| `ve_0dbdcc762c` | Restaurant L'Oustau de Baumanière*** | L'Oustau de Baumanière |
| `ve_6ba1197b41` | L' ALTER-NATIVE ⭐ | L'Alter-Native |
| `ve_8976cb64df` | La _ Maison dans le Parc | La Maison dans le Parc |
| `ve_b4babd7276` | Restaurant @ Alain llorca | Alain Llorca |
| `ve_0320deb2e1` | Restaurant "Les Pieds dans l’eau" | Les Pieds Dans l'Eau |
| `ve_d472175bc2` | Calice ⭐ | Calice |

## Rows dropped because the current name already wins the vote

**None. Population: all 281.** For a current name to win, a publisher other than Michelin has
to print it, and no other publisher can vote (see ruling 3 above). The bin is empty for a
measured reason, not because nothing was checked.

## Rows where the current name already equals Michelin's

**None, by construction.** The pool is defined as the rows where the two differ, so the job
will report 0 `no_change`. If it reports any, something changed between this report and the run.

## How this was checked

- **The pool was not hand-typed.** All 281 rows were read out of the live database through the
  Supabase read connector, and the transcription was verified against an md5 the database
  computed over the same rows: `107e82138f710a525d1ae74ade47b775`. The 50-venue publisher table
  above was verified the same way (`ce2064aabcea5163d9c41ace63d2297b`).
- **The selection rules were re-run inside the database, not just in the script that wrote the
  file.** The same "not a dash row, not the Chinese-name row" filter, expressed in SQL against
  live, returns 252 rows hashing to `80e5c55132091b6928630e98b3842839` — the same md5 as the
  252 rows of the CSV. So the file is the live data, selected by the stated rule, and neither
  the transcription nor the filter drifted.
- **Name collisions were measured against the live database**, using the same rule the job
  uses: after all 252 renames, would any two venues in one city share a `norm_key`?
  **0.** So the apply should not route anything to review.
- **The file was run through the real job**, in dry run, against a throwaway Postgres built
  from this repo's schema and seeded with the 252 venues under their current names: 252
  renamed, 0 refused, 0 needing a human, every invariant passing, one ledger row (michelin).
  Never against the live database.
- Nothing in this session set `app.allow_rename`, and nothing renamed anything.

