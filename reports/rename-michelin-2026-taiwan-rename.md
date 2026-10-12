# Rename apply - rename-michelin-2026-taiwan

**DRY RUN - rolled back.** Everything below is what would have happened.
Every name in the database is exactly as it was.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-taiwan` |
| CSV | `fixtures/rename/michelin-2026-taiwan-names.csv` |
| rows in the file | 75 |
| renamed | 75 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | (none) |

## Verdicts

Population: all 75 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 75 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 75 row(s) this batch would rename, read from the database before a single name changed.

75 of the 75 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_269ab60a27` | taipei | Taipei | A | michelin 2 | no | /taipei/taipei |
| `ve_8010044864` | taipei | EIKA 盈科 | Eika | michelin 2 | no | /taipei/eika |
| `ve_da97d58bf1` | taipei | 牡丹．極上 天ぷら．本店 | MUDAN TEMPURA | michelin 2, la-liste 1, oad 1 | no | /taipei/taipei-mlnkge |
| `ve_619429b2c4` | taipei | Yu Kappo | Yu Kapo | michelin 2 | no | /taipei/yu-kappo |
| `ve_ecaf898f47` | taipei | Golden Formosa Taiwanese Cuisine | Golden Formosa | michelin 1, oad 1 | no | /taipei/golden-formosa-taiwanese-cuisine |
| `ve_9cb807d5e4` | taipei | HOSU | Hosu | michelin 2 | no | /taipei/hosu |
| `ve_e97925aa1c` | taipei | Impromptu by Paul Lee (麗晶精品林森北路出入口下來） | Impromptu by Paul Lee | michelin 1, oad 1 | no | /taipei/impromptu-by-paul-lee |
| `ve_83ae36b088` | taipei | 謙安和 Ken Anho | Ken Anhe | michelin 2 | no | /taipei/ken-anho |
| `ve_4864070326` | taipei | 明福台菜 | Ming Fu | michelin 2 | no | /taipei/taipei-5aenqg |
| `ve_337cd1e0fb` | taipei | 元一 天婦羅 | Motoichi | michelin 2 | no | /taipei/taipei-cogs04 |
| `ve_0fcffab802` | taipei | Mountain & Sea House Restaurant | Mountain and Sea House | michelin 1, oad 1 | no | /taipei/mountain-sea-house-restaurant |
| `ve_a797b25772` | taipei | MUME | Mume | asia-50-best-restaurants 6, la-liste 1, michelin 1, oad 1 | no | /taipei/mume |
| `ve_1b6f9b2bd8` | kaohsiung | 承 Sho | Sho | michelin 2, oad 1 | no | /kaohsiung/sho |
| `ve_06e033a0b9` | taichung | 澀 Sur- | Sur- | michelin 2 | no | /taichung/sur |
| `ve_f12636cf86` | kaohsiung | 方蒔 the FRONT HOUSE | the FRONT HOUSE | michelin 2 | no | /kaohsiung/the-front-house |
| `ve_024fc869a8` | taipei | WOK by obond | Wok by O'BOND | michelin 2 | no | /taipei/wok-by-obond |
| `ve_7680c3ed3f` | tainan | 阿興虱目魚 | A Xing Shi Mu Yu | michelin 2 | no | /tainan/tainan-ihy0ja |
| `ve_8c951102be` | new-taipei-city | 阿爸の芋圓 樂華店 | A-ba's Taro Ball | michelin 2 | no | /new-taipei-city/new-taipei-city-29a714 |
| `ve_4aa1263325` | tainan | A-Mei Restaurant | Amei | michelin 2 | no | /tainan/a-mei-restaurant |
| `ve_aead754c2b` | hsinchu-county | Ang Gu Noodles | Ang Gu | michelin 2 | no | /hsinchu-county/ang-gu-noodles |
| `ve_9e20e8846b` | hsinchu-county | Bebu春嬌粄條 | Bebu | michelin 2 | no | /hsinchu-county/bebu |
| `ve_81aa03708d` | tainan | Chang Ying | Chang Ying Seafood House | michelin 2 | no | /tainan/chang-ying |
| `ve_e9fe72a9b0` | kaohsiung | 春蘭割包 | Chun Lan Gua Bao | michelin 2 | no | /kaohsiung/kaohsiung-php238 |
| `ve_e6c12e5f11` | kaohsiung | 橋仔頭黃家肉燥飯總店 | Ciao Zai Tou Huang's Braised Pork Rice (Ciaotou) | michelin 2 | no | /kaohsiung/kaohsiung-zinpge |
| `ve_36bb6de657` | taipei | 大橋頭米糕 | Da-Qiao-Tou Tube Rice Pudding (Yanping North Road) | michelin 2 | no | /taipei/taipei-qkbqdo |
| `ve_ea349b8773` | new-taipei-city | 店小二魯肉飯 | Dian Xiao Er (Datong North Road) | michelin 2 | no | /new-taipei-city/new-taipei-city-a39aba |
| `ve_20233163d3` | taipei | Din Tai Fung Xinyi Branch | Din Tai Fung (Xinyi Road) | michelin 2 | no | /taipei/din-tai-fung-xinyi-branch |
| `ve_03d9d02d43` | taichung | 鳳記鵝肉老店（沙鹿本店） | Feng Chi Goose | michelin 2 | no | /taichung/taichung-5gg5ke |
| `ve_8e1dc1810a` | taichung | Fu din wang | Fu Din Wang (Central) | michelin 2 | no | /taichung/fu-din-wang |
| `ve_f6bb8ab869` | tainan | Fu Tai Table (3rd Gen) | Fu Tai Table Third Generation | michelin 2 | no | /tainan/fu-tai-table-3rd-gen |
| `ve_6ee0642103` | new-taipei-city | GARDENh | Garden h | michelin 2 | no | /new-taipei-city/gardenh |
| `ve_43d10763ed` | hsinchu-city | Garden.V Restaurant | Garden.V | michelin 2 | no | /hsinchu-city/garden-v-restaurant |
| `ve_14ca1bc485` | new-taipei-city | 光興腿庫 | Guang Xing Pork Knuckle | michelin 2 | no | /new-taipei-city/new-taipei-city-842841 |
| `ve_6b7a0f46bd` | tainan | Hao Nong Jia Sticky Rice | Hao Nung Chia Migao | michelin 2 | no | /tainan/hao-nong-jia-sticky-rice |
| `ve_29e49b967a` | tainan | Xiluodian Beef Soup | Hsi Lo Tien Beef Soup | michelin 2 | no | /tainan/xiluodian-beef-soup |
| `ve_ed2d2d73ee` | taipei | 小酌之家 | Hsiao Cho Chih Chia | michelin 2 | no | /taipei/taipei-5hozhi |
| `ve_0275d5b5aa` | taipei | Huang Ji Braised Pork | Huang Chi Lu Rou Fan | michelin 2 | no | /taipei/huang-ji-braised-pork |
| `ve_d74805f382` | kaohsiung | 阿香的廚房 Ibu Kitchen | Ibu Kitchen | michelin 2 | no | /kaohsiung/ibu-kitchen |
| `ve_0d3c59fe15` | taipei | Inn's+ | Inn's+ (Shuangcheng Street) | michelin 2 | no | /taipei/inn-s |
| `ve_f758f5878a` | taipei | Ren He Yuan | Jen Ho Yuan | michelin 2 | no | /taipei/ren-he-yuan |
| `ve_2fdca93624` | hsinchu-city | 九添福牛肉麵館新竹城隍店 | Jiu Tian Fu | michelin 2 | no | /hsinchu-city/hsinchu-city-c5o5kk |
| `ve_9d640cd684` | kaohsiung | 舊市羊肉 | Joes (Gangshan) | michelin 2 | no | /kaohsiung/kaohsiung-bjq5bk |
| `ve_96325036c3` | tainan | 開元紅燒𩵚魠魚羹 | Kaiyuan Red-cook Spanish Mackerel | michelin 2 | no | /tainan/tainan-zzvhye |
| `ve_cade3ee4ad` | taichung | 功夫上海手工魚丸 | Kung Fu Shanghai Fish Ball | michelin 2 | no | /taichung/taichung-va1zhg |
| `ve_73891a53ce` | taichung | Küisine | Küisine (West) | michelin 2 | no | /taichung/kuisine |
| `ve_f18b4ed788` | taipei | Lao Shandong Homemade Noodles | Lao Shan Dong Homemade Noodles | michelin 2 | no | /taipei/lao-shandong-homemade-noodles |
| `ve_60879acc37` | taichung | 裡小樓小料理 | Li Xiao Lou | michelin 2 | no | /taichung/taichung-1cbnyi |
| `ve_ac8ba871b0` | kaohsiung | 良佳豬腳 最新消息請關注fb ig(已恢復長時間營業） | Liang Chia Pig Knuckle | michelin 2 | no | /kaohsiung/fb-ig |
| `ve_fe3988645e` | taipei | Little Tree Food (Da'an) | Little Tree Food (Da'an Road) | michelin 2 | no | /taipei/little-tree-food-da-an |
| `ve_1e754d072b` | tainan | 落成米糕 | Lo Cheng Migao | michelin 2 | no | /tainan/tainan-ggb2k8 |
| `ve_0e814ced6c` | taipei | Moon Moon Food Qingdao Branch | MoonMoonFood (Qingdao East Road) | michelin 2 | no | /taipei/moon-moon-food-qingdao-branch |
| `ve_0e059a0bed` | taichung | 東勢牛稼莊 | Niou Jia Juang | michelin 2 | no | /taichung/taichung-kkntei |
| `ve_e0abec6b4b` | kaohsiung | 牛老大涮牛肉-高雄總店/高雄必吃美食/火鍋/必比登推介 | NIU LAO DA (Zihciang 2nd Road) | michelin 2 | no | /kaohsiung/kaohsiung-s2bg6e |
| `ve_8ee03ec013` | taichung | 彭城堂台菜海鮮餐廳 | Peng Cheng Tang | michelin 2 | no | /taichung/taichung-oq7abu |
| `ve_ded5fe0f9c` | tainan | PO-JEN STORE | Po Jen Tang | michelin 2 | no | /tainan/po-jen-store |
| `ve_15e08088e5` | taipei | Pàng Taqueria | Pàng | michelin 2 | no | /taipei/pang-taqueria |
| `ve_eff1768dd7` | hsinchu-county | SHAN GUO TANG | Shan Guo Tang | michelin 2 | no | /hsinchu-county/shan-guo-tang |
| `ve_b1cd4dc1c2` | tainan | Shang Hao Chi Beef Soup | Shang Hao Chih Beef Soup | michelin 2 | no | /tainan/shang-hao-chi-beef-soup |
| `ve_9ab72fba83` | taichung | 滬舍餘味 | Shanghai Food (Nantun) | michelin 2 | no | /taichung/taichung-rkgf0k |
| `ve_dd2193c1f9` | taichung | Shin Yuan (West) – Taichung | Shin Yuan (West) | michelin 2 | no | /taichung/shin-yuan-west-taichung |
| `ve_d1e93b6c95` | hsinchu-county | 首烏廚EAT | Shou Wu EAT | michelin 2 | no | /hsinchu-county/eat |
| `ve_4f483f5e0b` | kaohsiung | Simmer house | Simmer House | michelin 2 | no | /kaohsiung/simmer-house |
| `ve_fa111c5154` | taipei | 露店 蘇來傳 | Su Lai Chuan | michelin 2 | no | /taipei/taipei-asvsts |
| `ve_1db6f458ea` | new-taipei-city | Song Jhao | SÒNG JHAO | michelin 2 | no | /new-taipei-city/song-jhao |
| `ve_28cbd5e446` | taipei | TABLEAU by Craig Yang | Tableau by Craig Yang | michelin 2 | no | /taipei/tableau-by-craig-yang |
| `ve_d735435a09` | hsinchu-county | 唐草園精緻麵食TANG TSAO YUAN | Tang Tsao Yuan | michelin 2 | no | /hsinchu-county/tang-tsao-yuan |
| `ve_72de8637df` | kaohsiung | 泰元THAIYUAN | Thai Yuan | michelin 2 | no | /kaohsiung/thaiyuan |
| `ve_63e27edbe2` | taipei | Wang’s Broth | Wang's Broth | michelin 2 | no | /taipei/wang-s-broth |
| `ve_09774c4bd0` | kaohsiung | Yang Bao Bao | Yang Bao Bao (Chaoming Road) | michelin 2 | no | /kaohsiung/yang-bao-bao |
| `ve_5217a49d50` | tainan | 葉家小卷米粉 | Yeh Jia Calamari Rice Noodle Soup | michelin 2 | no | /tainan/tainan-rzkfou |
| `ve_19227e10e5` | taipei | 一甲子餐飲 | Yi Jia Zi | michelin 2 | no | /taipei/taipei-sfiti8 |
| `ve_b96a90755c` | tainan | Tainan Yi Wei Pin | Yi Wei Pin | michelin 2 | no | /tainan/tainan-yi-wei-pin |
| `ve_e1d0fe73ca` | taipei | Yuan Fang Gua Bao | Yuan Fang Guabao | michelin 2 | no | /taipei/yuan-fang-gua-bao |
| `ve_21a105d24a` | hsinchu-city | 原味鴨肉麵 | Yuan Wei Duck Noodle | michelin 2 | no | /hsinchu-city/hsinchu-city-gafaxa |
| `ve_9460417485` | tainan | Yuan Zai Hui | Yuan Zai Hui (Guohua Street) | michelin 2 | no | /tainan/yuan-zai-hui |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 75 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

| table.column | rows holding one of these names |
|---|---|
| `city_label_source.label` | 124 |
| `cities.display` | 1 |

Those are copies this job does **not** rewrite. It changes `venues.name` and nothing else; anything above is for your list.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,315 | 11,315 | 11,315 |
| awards | 22,866 | 22,866 | 22,866 |
| slugs | 12,777 | 12,777 | 12,777 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 88 | 89 | 89 |
| rename_batches | 11 | 12 | 12 |
| rename_rows | 1,024 | 1,099 | 1,099 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 75 (expected 75) |
| every renamed venue's live name is its new_name | pass | 0 of 75 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 75 (expected 75) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 75 name changes (expected 75), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 75 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_269ab60a27` | Taipei | A | michelin | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/a |
| `ve_8010044864` | EIKA 盈科 | Eika | michelin | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/eika |
| `ve_da97d58bf1` | 牡丹．極上 天ぷら．本店 | MUDAN TEMPURA | venue | https://www.mudantempura.com/ |
| `ve_619429b2c4` | Yu Kappo | Yu Kapo | michelin | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/yu-kapo-1198592 |
| `ve_ecaf898f47` | Golden Formosa Taiwanese Cuisine | Golden Formosa | michelin | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/golden-formosa |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-taiwan`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 74 |

1 row(s) name `venue` as their source - the venue's own website settled the spelling. The venue is not a publisher and holds no row in `award_sources`, which `source_capture_ledger.publisher` points at, so those rows are not in the ledger. They are in `rename_rows` with their URL, like every other row.

Spellings followed: michelin (74), venue (1).

## Undo

Nothing to undo: this was a dry run. Untick the box to do it for real.
