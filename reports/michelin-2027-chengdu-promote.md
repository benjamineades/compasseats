# Ingest promote - michelin-2027-chengdu

Committed 2026-09-28T14:49:40.589Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,185 | 11,209 | 11,209 |
| awards | 22,190 | 22,237 | 22,237 |
| listings | 11,185 | 11,209 | 11,209 |
| slugs | 12,266 | 12,290 | 12,290 |
| city_label_source | 23,774 | 23,822 | 23,822 |
| price | 7,059 | 7,059 | 7,059 |
| source_capture_ledger | 53 | 55 | 55 |

Active venues: 10,824 -> 10,848.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 47 (expected 47) |
| venues delta equals new venues | pass | 24 (expected 24) |
| listings delta equals new venues | pass | 24 (expected 24) |
| slugs delta equals new venues | pass | 24 (expected 24) |
| city_label_source delta equals planned labels | pass | 48 (expected 48) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10824 -> 10848 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_b271ef2331` | Xin Rong Ji | /chengdu/xin-rong-ji | active | true | 1 |
| `ve_cec4b19f8b` | The Hall | /chengdu/the-hall | active | true | 1 |
| `ve_6ce4e59ddf` | Ma's Kitchen (Jinjiang) | /chengdu/ma-s-kitchen-jinjiang | active | true | 1 |
| `ve_f4300dee32` | Zinan | /chengdu/zinan | active | true | 1 |
| `ve_638e8e4893` | Focus by Bill Yue | /chengdu/focus-by-bill-yue | active | true | 1 |
| `ve_aa87491e3a` | Hokkien Cuisine | /chengdu/hokkien-cuisine | active | true | 1 |
| `ve_b7fe126ee0` | No.37 Lao Yuan Ba Chao Shou | /chengdu/no-37-lao-yuan-ba-chao-shou | active | true | 1 |
| `ve_513ad27ea8` | Mosnack | /chengdu/mosnack | active | true | 1 |
| `ve_d353daa74b` | Ban Tian Te Se Mian | /chengdu/ban-tian-te-se-mian | active | true | 1 |
| `ve_559d2e9f98` | Wan San Mian Guan (Qinglongzheng Street) | /chengdu/wan-san-mian-guan-qinglongzheng-street | active | true | 1 |
| `ve_a22d420df9` | Hu Er Ge Yao Shan Ti Hua | /chengdu/hu-er-ge-yao-shan-ti-hua | active | true | 1 |
| `ve_2259bdabb5` | The Woo's (Jinjiang) | /chengdu/the-woo-s-jinjiang | active | true | 1 |
| `ve_9788abe6b9` | Gui Tian Yuan Zi | /chengdu/gui-tian-yuan-zi | active | true | 1 |
| `ve_81ee6aa1e8` | Zhuan Zhuan Hui (Jinjiang) | /chengdu/zhuan-zhuan-hui-jinjiang | active | true | 1 |
| `ve_9ad4b93052` | Da Ya Ji | /chengdu/da-ya-ji | active | true | 1 |
| `ve_63d293449b` | Dumpling & Drinks (Lancao Road) | /chengdu/dumpling-drinks-lancao-road | active | true | 1 |
| `ve_68caf281a3` | Ren Ren Shui Jiao | /chengdu/ren-ren-shui-jiao | active | true | 1 |
| `ve_456bb67f9e` | Yao Guai Mian | /chengdu/yao-guai-mian | active | true | 1 |
| `ve_f21bd1d959` | Ting Yuan 399 (Jinjiang) | /chengdu/ting-yuan-399-jinjiang | active | true | 1 |
| `ve_107f3fe31e` | Xiao You Shao Mai (Qingyang) | /chengdu/xiao-you-shao-mai-qingyang | active | true | 1 |
| `ve_376f9dd936` | Guan Jin (Chenghan South Road) | /chengdu/guan-jin-chenghan-south-road | active | true | 1 |
| `ve_b8e20a1776` | Organization South | /chengdu/organization-south | active | true | 1 |
| `ve_f099074ae1` | Cuo Xia | /chengdu/cuo-xia | active | true | 1 |
| `ve_d5594bb27c` | Mao Wu Da Jiu Dian | /chengdu/mao-wu-da-jiu-dian | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2027-chengdu`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 47 |
| michelin | city_label | 48 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2027-chengdu`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2027-chengdu`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
