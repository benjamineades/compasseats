# Rename apply - rename-michelin-2027-chengdu

Committed 2026-09-28T20:38:39.948Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2027-chengdu` |
| CSV | `fixtures/rename/michelin-2027-chengdu-names.csv` |
| rows in the file | 18 |
| renamed | 18 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Michelin Chengdu 2027 paired legacy venues; majority rule Sep 14; Co- 3 of 3; Yongya tie to venue site (Ben, option A) |

## Verdicts

Population: all 18 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 18 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 18 row(s) this batch would rename, read from the database before a single name changed.

18 of the 18 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_133ee0a10d` | chengdu | Mind | Mind (Wuhou) | michelin 2 | no | /chengdu/mind |
| `ve_36ae4d6bcd` | chengdu | Xujia Cai (Wangjiang Branch) | Xu's Cuisine | michelin 2 | no | /chengdu/xujia-cai-wangjiang-branch |
| `ve_37910677a4` | chengdu | Heming Tea House | Mi Xun Teahouse | michelin 2 | no | /chengdu/heming-tea-house |
| `ve_41a4101cbd` | chengdu | Chenmapo Sichuan Restaurant | Co- | michelin 2, asia-50-best-restaurants 1, best-chef-awards 1 | no | /chengdu/chenmapo-sichuan-restaurant |
| `ve_4f5d44401e` | chengdu | Laochengdu Sanyang Noodles | Lao Chengdu Yi Cheng Xian San Yang Mian | michelin 2 | no | /chengdu/laochengdu-sanyang-noodles |
| `ve_67f01b1cdf` | chengdu | Rongyuan Restaurant | Rong Yuan Can Guan | michelin 2 | no | /chengdu/rongyuan-restaurant |
| `ve_69877791d1` | chengdu | Nianfeng Alley | Nian Feng Restaurant | michelin 2 | no | /chengdu/nianfeng-alley |
| `ve_7ab59d83eb` | chengdu | Longsenyuan | Long Sen Yuan (Qingyang) | michelin 2 | no | /chengdu/longsenyuan |
| `ve_820878c98e` | chengdu | Jinjiang Bashu Weiyuan | Gong Zhou · Ba Shu Wei Yuan | michelin 2 | no | /chengdu/jinjiang-bashu-weiyuan |
| `ve_84dc39ab0e` | chengdu | Bainian Fenzheng Beef | Bai Nian Fen Zheng Niu Rou | michelin 2 | no | /chengdu/bainian-fenzheng-beef |
| `ve_9c004b1f6f` | chengdu | Yangboying Traditional Mixed Sauce Noodles | Yangboying Chuan Tong Za Jiang Mian | michelin 2 | no | /chengdu/yangboying-traditional-mixed-sauce-noodles |
| `ve_a3b31ca55d` | chengdu | Furonghuang Garden Restaurant | Fu Rong Huang | michelin 2 | no | /chengdu/furonghuang-garden-restaurant |
| `ve_a64a235506` | chengdu | Ganji Pig's Intestines Powder | Gan Ji Fei Chang Fen | michelin 2 | no | /chengdu/ganji-pig-s-intestines-powder |
| `ve_ad0bb34099` | chengdu | Xiaolongkan Old Hot Pot | Silver Pot | michelin 2 | no | /chengdu/xiaolongkan-old-hot-pot |
| `ve_b8255461a4` | chengdu | Chen Mapo Tofu Restaurant | Chen Mapo Tofu (Qinghua Road) | michelin 2 | no | /chengdu/chen-mapo-tofu-restaurant |
| `ve_d33390c047` | chengdu | Chaimen Residence | Chaimen Hui | michelin 2 | no | /chengdu/chaimen-residence |
| `ve_db92193fc0` | chengdu | Yongya Hexian | Young Art · Yong Ya He Xian (Tongzilin East Road) | michelin 2, la-liste 1 | no | /chengdu/yongya-hexian |
| `ve_e1109450cf` | chengdu | Aromatherapy Jing | Fang Xiang Jing | michelin 2 | no | /chengdu/aromatherapy-jing |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 18 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,212 | 11,212 | 11,212 |
| awards | 22,241 | 22,241 | 22,241 |
| slugs | 12,293 | 12,293 | 12,293 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 59 | 60 | 60 |
| rename_batches | 4 | 5 | 5 |
| rename_rows | 533 | 551 | 551 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 18 (expected 18) |
| every renamed venue's live name is its new_name | pass | 0 of 18 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 18 (expected 18) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 18 name changes (expected 18), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 18 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_133ee0a10d` | Mind | Mind (Wuhou) | michelin | https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurant/mind |
| `ve_36ae4d6bcd` | Xujia Cai (Wangjiang Branch) | Xu's Cuisine | michelin | https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurant/xu-s-cuisine |
| `ve_37910677a4` | Heming Tea House | Mi Xun Teahouse | michelin | https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurant/mi-xun-teahouse |
| `ve_41a4101cbd` | Chenmapo Sichuan Restaurant | Co- | michelin | https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurant/co |
| `ve_4f5d44401e` | Laochengdu Sanyang Noodles | Lao Chengdu Yi Cheng Xian San Yang Mian | michelin | https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurant/lao-chengdu-san-yang-mian |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2027-chengdu`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 18 |

Spellings followed: michelin (18).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2027-chengdu`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2027-chengdu`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
