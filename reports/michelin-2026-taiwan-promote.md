# Ingest promote - michelin-2026-taiwan

Committed 2026-10-12T00:49:55.011Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,254 | 11,315 | 11,315 |
| awards | 22,659 | 22,866 | 22,866 |
| listings | 11,254 | 11,315 | 11,315 |
| slugs | 12,716 | 12,777 | 12,777 |
| city_label_source | 23,912 | 24,034 | 24,034 |
| price | 7,048 | 7,048 | 7,048 |
| source_capture_ledger | 86 | 88 | 88 |

Active venues: 10,886 -> 10,947.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 207 (expected 207) |
| venues delta equals new venues | pass | 61 (expected 61) |
| listings delta equals new venues | pass | 61 (expected 61) |
| slugs delta equals new venues | pass | 61 (expected 61) |
| city_label_source delta equals planned labels | pass | 122 (expected 122) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10886 -> 10947 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_5559e9180c` | Mizue | /taipei/mizue | active | true | 1 |
| `ve_46199fee65` | Molino de Urdániz | /taipei/molino-de-urdaniz | active | true | 1 |
| `ve_7fb7d7c34d` | A Cut | /taipei/a-cut | active | true | 1 |
| `ve_b017ac2790` | Ad Astra | /taipei/ad-astra | active | true | 1 |
| `ve_b3f74363c9` | aMaze | /taipei/amaze | active | true | 1 |
| `ve_577799bcaf` | Ban Bo | /taipei/ban-bo | active | true | 1 |
| `ve_217324874a` | Fujin Tree Taiwanese Cuisine & Champagne (Songshan) | /taipei/fujin-tree-taiwanese-cuisine-champagne-songshan | active | true | 1 |
| `ve_5982cea881` | Hābu | /kaohsiung/habu | active | true | 1 |
| `ve_d9f9152025` | Kiku | /taipei/kiku | active | true | 1 |
| `ve_5ea36ed3f8` | Nibbon | /kaohsiung/nibbon | active | true | 1 |
| `ve_651744a412` | Restaurant 12 | /taipei/restaurant-12 | active | true | 1 |
| `ve_40a55cfa6b` | SHINEYU | /taichung/shineyu | active | true | 1 |
| `ve_544e352dbc` | Sushi Akira | /taipei/sushi-akira | active | true | 1 |
| `ve_fd14ae57be` | Sushi An | /hsinchu-county/sushi-an | active | true | 1 |
| `ve_330f3f4178` | Sushi Kajin | /taipei/sushi-kajin | active | true | 1 |
| `ve_547f1867d4` | Tien Hsiang Lo | /taipei/tien-hsiang-lo | active | true | 1 |
| `ve_ab005c1886` | Yu Dao | /tainan/yu-dao | active | true | 1 |
| `ve_013408683a` | Abba Hakka | /new-taipei-city/abba-hakka | active | true | 1 |
| `ve_6825dd130f` | BAA Wanli Goat | /tainan/baa-wanli-goat | active | true | 1 |
| `ve_b4be84da72` | Bei Ya Duck Thick Soup | /new-taipei-city/bei-ya-duck-thick-soup | active | true | 1 |
| `ve_f3cd3980d4` | Bitan Chiao Tou Goose | /new-taipei-city/bitan-chiao-tou-goose | active | true | 1 |
| `ve_65fa70f1be` | Cat House | /hsinchu-city/cat-house | active | true | 1 |
| `ve_dfeb448273` | CHAN CHI | /tainan/chan-chi | active | true | 1 |
| `ve_9fa686ebe2` | Cheng Shi | /tainan/cheng-shi | active | true | 1 |
| `ve_dc2bbd612c` | Ching Jiao | /taipei/ching-jiao | active | true | 1 |
| `ve_9d5627b2f3` | Cianjin Braised Pork Rice | /kaohsiung/cianjin-braised-pork-rice | active | true | 1 |
| `ve_fdbcec9464` | Da One Gone Lamb | /new-taipei-city/da-one-gone-lamb | active | true | 1 |
| `ve_dae12e66cb` | Don Moo | /taichung/don-moo | active | true | 1 |
| `ve_66052eab74` | Dongmen Rice Noodle Soup | /hsinchu-city/dongmen-rice-noodle-soup | active | true | 1 |
| `ve_757c8c78b9` | Erge Shih Tang | /kaohsiung/erge-shih-tang | active | true | 1 |
| `ve_85216c5295` | He Jih Hsiang (Minzu Road) | /hsinchu-city/he-jih-hsiang-minzu-road | active | true | 1 |
| `ve_564b39567a` | Hou Chi Duck Rice | /kaohsiung/hou-chi-duck-rice | active | true | 1 |
| `ve_919a718cb4` | Hsiu Ming | /kaohsiung/hsiu-ming | active | true | 1 |
| `ve_9f67b9b8ee` | Huang Chia Shrimp Roll | /tainan/huang-chia-shrimp-roll | active | true | 1 |
| `ve_320f4e04ee` | Hung Chin | /hsinchu-county/hung-chin | active | true | 1 |
| `ve_898937d7db` | Jhen Pin | /new-taipei-city/jhen-pin | active | true | 1 |
| `ve_05071b0521` | Lai Kang Shan | /new-taipei-city/lai-kang-shan | active | true | 1 |
| `ve_0a22f427a5` | Lao Shih Kuan Noodles | /taichung/lao-shih-kuan-noodles | active | true | 1 |
| `ve_03f3f92eb5` | Liao Chi Migao | /kaohsiung/liao-chi-migao | active | true | 1 |
| `ve_e3a11647b4` | Lien Wu Chiao Lamb Soup | /tainan/lien-wu-chiao-lamb-soup | active | true | 1 |
| `ve_3859baecaf` | Mi Yuan Tzu Steamed Glutinous Rice | /kaohsiung/mi-yuan-tzu-steamed-glutinous-rice | active | true | 1 |
| `ve_a8a03c5d2b` | Monsoon | /hsinchu-county/monsoon | active | true | 1 |
| `ve_deacf6de90` | No Name Lamb Soup | /tainan/no-name-lamb-soup | active | true | 1 |
| `ve_0728682a08` | No Name Noodles | /taichung/no-name-noodles | active | true | 1 |
| `ve_908bce5c92` | Noon Turnip Cake | /hsinchu-county/noon-turnip-cake | active | true | 1 |
| `ve_68f8103652` | Nung Wei Hsiao Chu | /hsinchu-city/nung-wei-hsiao-chu | active | true | 1 |
| `ve_1244277aac` | Open Smile | /taipei/open-smile | active | true | 1 |
| `ve_6cb4f81b13` | San Chieh Mei Nung Chia Le | /new-taipei-city/san-chieh-mei-nung-chia-le | active | true | 1 |
| `ve_74a3feb74f` | Shian Jeng Shrimp Bawan | /tainan/shian-jeng-shrimp-bawan | active | true | 1 |
| `ve_311b391026` | Superman | /new-taipei-city/superman | active | true | 1 |
| `ve_b362656ec7` | Toriaezu Curry | /taipei/toriaezu-curry | active | true | 1 |
| `ve_c91400454b` | Tsai Chia Beef Noodles | /new-taipei-city/tsai-chia-beef-noodles | active | true | 1 |
| `ve_17c0cef701` | Tsou Chi Cai Bao (Zhongzheng Road) | /hsinchu-county/tsou-chi-cai-bao-zhongzheng-road | active | true | 1 |
| `ve_3ec1cc96ed` | Xie Shopkeeper | /tainan/xie-shopkeeper | active | true | 1 |
| `ve_e497685786` | Yeh Chia Pork Ribs Medicinal Herbs Soup | /new-taipei-city/yeh-chia-pork-ribs-medicinal-herbs-soup | active | true | 1 |
| `ve_73f1c17f03` | Yeh San Duck Thick Soup | /tainan/yeh-san-duck-thick-soup | active | true | 1 |
| `ve_4b5f48ef55` | Yi Ge Rice Vermicelli | /hsinchu-county/yi-ge-rice-vermicelli | active | true | 1 |
| `ve_5ba0efb167` | Yonghe Chia Hsiang Soy Milk | /new-taipei-city/yonghe-chia-hsiang-soy-milk | active | true | 1 |
| `ve_e3cc8e6df9` | Yu Yu 1969 | /taipei/yu-yu-1969 | active | true | 1 |
| `ve_907de0e767` | Yung Yen | /kaohsiung/yung-yen | active | true | 1 |
| `ve_dca4964305` | Zhu-Ji Dong Tsai Ya | /tainan/zhu-ji-dong-tsai-ya | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-taiwan`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 207 |
| michelin | city_label | 122 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-taiwan`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-taiwan`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
