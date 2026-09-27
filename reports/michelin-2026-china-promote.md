# Ingest promote - michelin-2026-china

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,061 | 11,221 | 11,221 |
| awards | 22,024 | 22,493 | 22,493 |
| listings | 11,061 | 11,221 | 11,221 |
| slugs | 11,874 | 12,034 | 12,034 |
| city_label_source | 23,518 | 23,838 | 23,838 |
| price | 7,090 | 7,090 | 7,090 |
| source_capture_ledger | 32 | 34 | 34 |

Active venues: 10,699 -> 10,859.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 469 (expected 469) |
| venues delta equals new venues | pass | 160 (expected 160) |
| listings delta equals new venues | pass | 160 (expected 160) |
| slugs delta equals new venues | pass | 160 (expected 160) |
| city_label_source delta equals planned labels | pass | 320 (expected 320) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10699 -> 10859 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_13e93ccbe7` | Jingji | /beijing/jingji | active | true | 1 |
| `ve_2eeac39d82` | Chao Shang Chao (Xicheng) | /beijing/chao-shang-chao-xicheng | active | true | 1 |
| `ve_9758a288cd` | Lu Style (Anding Road) | /beijing/lu-style-anding-road | active | true | 1 |
| `ve_c1203f68bf` | Rong Pao | /beijing/rong-pao | active | true | 1 |
| `ve_abccb8710d` | Seventh Son | /beijing/seventh-son | active | true | 1 |
| `ve_0907d6d8e8` | Xin Rong Ji (Jianguomenwai Street) | /beijing/xin-rong-ji-jianguomenwai-street | active | true | 1 |
| `ve_29a960cf7b` | Xin Rong Ji (Jinrong Street) | /beijing/xin-rong-ji-jinrong-street | active | true | 1 |
| `ve_343a90895d` | Zijin Mansion | /beijing/zijin-mansion | active | true | 1 |
| `ve_683d3eef6c` | Bao Bao Hao | /beijing/bao-bao-hao | active | true | 1 |
| `ve_7b3fa587f4` | Fujian Cuisine (Dongsanhuan North Road) | /beijing/fujian-cuisine-dongsanhuan-north-road | active | true | 1 |
| `ve_ab4ae66796` | Hua Sheng Feng (Dongsanhuan South Road) | /beijing/hua-sheng-feng-dongsanhuan-south-road | active | true | 1 |
| `ve_c93f199c6e` | Liu Ma Ma Dumplings (Chaoyang) | /beijing/liu-ma-ma-dumplings-chaoyang | active | true | 1 |
| `ve_47fb87d3b0` | Man Heng Ji | /beijing/man-heng-ji | active | true | 1 |
| `ve_bc244843c4` | My Soup | /beijing/my-soup | active | true | 1 |
| `ve_aff1c67ff4` | Zhong | /beijing/zhong | active | true | 1 |
| `ve_67313b2934` | Fleurs Et Festin | /xiamen/fleurs-et-festin | active | true | 1 |
| `ve_b16482a53f` | Hatter | /fuzhou/hatter | active | true | 1 |
| `ve_2aad95237f` | 167 Shan Hai Li | /fuzhou/167-shan-hai-li | active | true | 1 |
| `ve_94a391d73a` | Da Tong Shao Jiu Lang | /xiamen/da-tong-shao-jiu-lang | active | true | 1 |
| `ve_2a71cf2840` | Dai Tai | /xiamen/dai-tai | active | true | 1 |
| `ve_2ee867733a` | Homeme18" (Huming Road) | /xiamen/homeme18-huming-road | active | true | 1 |
| `ve_8329660025` | Lai Cuo Cheng Bian Shi Dian | /xiamen/lai-cuo-cheng-bian-shi-dian | active | true | 1 |
| `ve_fd26816b1d` | Lao A Bo | /quanzhou/lao-a-bo | active | true | 1 |
| `ve_3252daae0e` | Lin Yi Nen Ming Pai Zhu Xue Hua | /fuzhou/lin-yi-nen-ming-pai-zhu-xue-hua | active | true | 1 |
| `ve_a745410058` | Lu Niang Zi (Huli) | /xiamen/lu-niang-zi-huli | active | true | 1 |
| `ve_65092c7cbb` | Ning Chuan Zu Yao Yu Wan | /ningde/ning-chuan-zu-yao-yu-wan | active | true | 1 |
| `ve_03353c38b1` | Pan Ya Yuan | /xiamen/pan-ya-yuan | active | true | 1 |
| `ve_9fe2d9c536` | Panda's | /xiamen/panda-s | active | true | 1 |
| `ve_58278caf72` | Si Xia Li (Huli) | /xiamen/si-xia-li-huli | active | true | 1 |
| `ve_5cbc70d4e5` | Tong'an Fan Dian (Huachang Road) | /xiamen/tong-an-fan-dian-huachang-road | active | true | 1 |
| `ve_7ca85fe62d` | Wai Tou Niu Rou (Meiling Road) | /quanzhou/wai-tou-niu-rou-meiling-road | active | true | 1 |
| `ve_910d7c4aaf` | Wu Lan Sha Cha Mian | /xiamen/wu-lan-sha-cha-mian | active | true | 1 |
| `ve_b9457bcd14` | Xian Xiong Qi | /xiamen/xian-xiong-qi | active | true | 1 |
| `ve_416299efd7` | Xiang Mo Jin Nian | /xiamen/xiang-mo-jin-nian | active | true | 1 |
| `ve_d4078ef7ff` | Xiao Cheng Xi | /xiamen/xiao-cheng-xi | active | true | 1 |
| `ve_3c4b336d0a` | Xiao Dong Men Niu Rou Shui Fen Lao Dian | /ningde/xiao-dong-men-niu-rou-shui-fen-lao-dian | active | true | 1 |
| `ve_2718ce16b6` | Xingxian (Mawei) | /fuzhou/xingxian-mawei | active | true | 1 |
| `ve_a887966a7f` | Ye Jia Hua Sheng Tang | /fuzhou/ye-jia-hua-sheng-tang | active | true | 1 |
| `ve_eca0c32c21` | Yi Qiang (Dadao Road) | /fuzhou/yi-qiang-dadao-road | active | true | 1 |
| `ve_f96435baf5` | The Bay by Chef Fei | /shenzhen/the-bay-by-chef-fei | active | true | 1 |
| `ve_25f63580d9` | Yun Jing | /shenzhen/yun-jing | active | true | 1 |
| `ve_46093ed834` | Chao Shang Chao | /shenzhen/chao-shang-chao | active | true | 1 |
| `ve_38916224da` | Fumée | /shenzhen/fumee | active | true | 1 |
| `ve_29456c74be` | Lai Heen | /guangzhou/lai-heen | active | true | 1 |
| `ve_7f26576721` | Opus 388 | /shenzhen/opus-388 | active | true | 1 |
| `ve_716f9013a3` | Song | /guangzhou/song | active | true | 1 |
| `ve_e7a5110d4f` | Stiller | /guangzhou/stiller | active | true | 1 |
| `ve_0305fef230` | Suyab Courtyard・Pickmoon Gourmet | /guangzhou/suyab-courtyard-pickmoon-gourmet | active | true | 1 |
| `ve_59067001bc` | Xin Ji | /guangzhou/xin-ji | active | true | 1 |
| `ve_d6217834fc` | Xin Rong Ji | /shenzhen/xin-rong-ji | active | true | 1 |
| `ve_bf4f0713f7` | Yong | /guangzhou/yong | active | true | 1 |
| `ve_c4b1d010c4` | Baode (Dunhe Road) | /guangzhou/baode-dunhe-road | active | true | 1 |
| `ve_e15034d80b` | Cuihu (Nanshan) | /shenzhen/cuihu-nanshan | active | true | 1 |
| `ve_30dca02626` | Da Tang Liang Tang | /shenzhen/da-tang-liang-tang | active | true | 1 |
| `ve_d9aa54003e` | Dai Yong Town | /guangzhou/dai-yong-town | active | true | 1 |
| `ve_167ecfa11e` | Dioswa Bistro | /shenzhen/dioswa-bistro | active | true | 1 |
| `ve_4c3d06df7b` | E Qian Ya Hou | /guangzhou/e-qian-ya-hou | active | true | 1 |
| `ve_d0f6e10741` | Fat Kee | /shenzhen/fat-kee | active | true | 1 |
| `ve_8ae79907cc` | Gao San Jie Dou Hua Dian | /shenzhen/gao-san-jie-dou-hua-dian | active | true | 1 |
| `ve_46c906b415` | Ge Ji Mei Ji Xian | /shenzhen/ge-ji-mei-ji-xian | active | true | 1 |
| `ve_175d6ce4a3` | Hua Zhou B Ji Fan Dian | /shenzhen/hua-zhou-b-ji-fan-dian | active | true | 1 |
| `ve_4eaed104ef` | Jie Yang Lao Er Guo Tiao Tang | /shenzhen/jie-yang-lao-er-guo-tiao-tang | active | true | 1 |
| `ve_dcfe53c583` | Jiu Jiu Noodle | /shenzhen/jiu-jiu-noodle | active | true | 1 |
| `ve_7579b43152` | Little Tok Panjang | /shenzhen/little-tok-panjang | active | true | 1 |
| `ve_01d04b922a` | Mai Yu Lao Sha Guo Zhou | /shenzhen/mai-yu-lao-sha-guo-zhou | active | true | 1 |
| `ve_c5be40e627` | Mamak | /guangzhou/mamak | active | true | 1 |
| `ve_2becba2392` | Mei Lu Xiao Chu | /guangzhou/mei-lu-xiao-chu | active | true | 1 |
| `ve_bd01e5fa80` | Pier 3 | /shenzhen/pier-3 | active | true | 1 |
| `ve_aee74187ea` | Rex Shan Shui Chang Fen | /shenzhen/rex-shan-shui-chang-fen | active | true | 1 |
| `ve_c0a3184148` | Ru Yi Chuan Tong Zhu Sheng Mian | /guangzhou/ru-yi-chuan-tong-zhu-sheng-mian | active | true | 1 |
| `ve_b0e15826f5` | Show Hands | /shenzhen/show-hands | active | true | 1 |
| `ve_ca753ad297` | Si Mao Cai Guan | /guangzhou/si-mao-cai-guan | active | true | 1 |
| `ve_9322582563` | Tai Shan Lao Biao Xian Tang Yuan (Xihua Road) | /guangzhou/tai-shan-lao-biao-xian-tang-yuan-xihua-road | active | true | 1 |
| `ve_c652d1f565` | Tai Shan Lao Huang Shan Fan | /shenzhen/tai-shan-lao-huang-shan-fan | active | true | 1 |
| `ve_056b071c7c` | Wuchuan Hao Wei Lai | /guangzhou/wuchuan-hao-wei-lai | active | true | 1 |
| `ve_cf4089984b` | Xiao Fu Rong | /shenzhen/xiao-fu-rong | active | true | 1 |
| `ve_e773df6165` | Xiao Long Niu Rou Mian (Futian) | /shenzhen/xiao-long-niu-rou-mian-futian | active | true | 1 |
| `ve_97b4f3505c` | Xiguan Zhuyuan (Lizhiwan) | /guangzhou/xiguan-zhuyuan-lizhiwan | active | true | 1 |
| `ve_24544d8147` | Xiguan Zhuyuan (Shiba Fu) | /guangzhou/xiguan-zhuyuan-shiba-fu | active | true | 1 |
| `ve_2388fa3eff` | Xin Hu Cun Cu Rou (Longhua Jianshe Road) | /shenzhen/xin-hu-cun-cu-rou-longhua-jianshe-road | active | true | 1 |
| `ve_ffc480ca32` | Xin Ji Ke Jia Wei Dao | /shenzhen/xin-ji-ke-jia-wei-dao | active | true | 1 |
| `ve_453d6fb6b1` | Xingning Ke Jia Cai Guan (Meicun Road) | /shenzhen/xingning-ke-jia-cai-guan-meicun-road | active | true | 1 |
| `ve_5276ee70a2` | Ya Yuan | /guangzhou/ya-yuan | active | true | 1 |
| `ve_2fdd3a2ae3` | Yao Ji | /guangzhou/yao-ji | active | true | 1 |
| `ve_bdff7ef11b` | Yu Yuen | /guangzhou/yu-yuen | active | true | 1 |
| `ve_776f6bffc0` | Yuan Sheng Tai | /shenzhen/yuan-sheng-tai | active | true | 1 |
| `ve_1e4f1a0464` | Ze 8 (Haizhu) | /guangzhou/ze-8-haizhu | active | true | 1 |
| `ve_d639bca3df` | Zhou Men | /guangzhou/zhou-men | active | true | 1 |
| `ve_cabae88fce` | Ambré Ciel | /hangzhou/ambre-ciel | active | true | 1 |
| `ve_6069ec83d9` | Carved Dragons (Jiaojiang) | /taizhou/carved-dragons-jiaojiang | active | true | 1 |
| `ve_0ebccf2149` | Dingshan · Jiangyan | /suzhou/dingshan-jiangyan | active | true | 1 |
| `ve_49d76f1590` | Jiangnan Wok · Yun | /nanjing/jiangnan-wok-yun | active | true | 1 |
| `ve_a1741badff` | Lei Garden (Xuhui) | /shanghai/lei-garden-xuhui | active | true | 1 |
| `ve_0e2ce57dcd` | Moose (Changning) | /shanghai/moose-changning | active | true | 1 |
| `ve_cf229c5c5f` | Moose (Pudong) | /shanghai/moose-pudong | active | true | 1 |
| `ve_bc2baac574` | Obscura | /shanghai/obscura | active | true | 1 |
| `ve_55f5752b45` | Sense | /hangzhou/sense | active | true | 1 |
| `ve_b77a5b1eac` | Seventh Son | /shanghai/seventh-son | active | true | 1 |
| `ve_64bc6a47bd` | Shang Palace | /yangzhou/shang-palace | active | true | 1 |
| `ve_a6da955b4f` | Song | /hangzhou/song | active | true | 1 |
| `ve_01ef554181` | Wild Yeast | /hangzhou/wild-yeast | active | true | 1 |
| `ve_392d15eab8` | Xi Ding Jia Yan | /suzhou/xi-ding-jia-yan | active | true | 1 |
| `ve_5d854edbc3` | Xin Rong Ji | /hangzhou/xin-rong-ji | active | true | 1 |
| `ve_84ec62fcbd` | Xin Rong Ji (Jiaojiang) | /taizhou/xin-rong-ji-jiaojiang | active | true | 1 |
| `ve_ee5c3cf115` | Xin Rong Ji (West Nanjing Road) | /shanghai/xin-rong-ji-west-nanjing-road | active | true | 1 |
| `ve_6769026317` | Yong Fu (Hongkou) | /shanghai/yong-fu-hongkou | active | true | 1 |
| `ve_be4a97c179` | Yong Yi Ting | /shanghai/yong-yi-ting | active | true | 1 |
| `ve_23c4b48882` | Yue Hai Tang | /shanghai/yue-hai-tang | active | true | 1 |
| `ve_7a30148b69` | 157 Shi Fang | /shanghai/157-shi-fang | active | true | 1 |
| `ve_c6ae6d866a` | Bai Nian Hun Tun Lao Dian | /wenzhou/bai-nian-hun-tun-lao-dian | active | true | 1 |
| `ve_78e649ee27` | Chun | /shanghai/chun | active | true | 1 |
| `ve_5fa8fc7bce` | Datou Yingshi Xiaoguan | /hangzhou/datou-yingshi-xiaoguan | active | true | 1 |
| `ve_6ac90e1017` | Definitely Fresh (Xihu) | /hangzhou/definitely-fresh-xihu | active | true | 1 |
| `ve_91bcf27047` | Dou Lai Fan Dian | /hangzhou/dou-lai-fan-dian | active | true | 1 |
| `ve_4718a2a879` | Fu Xing Mian Wang (Hedong Road) | /hangzhou/fu-xing-mian-wang-hedong-road | active | true | 1 |
| `ve_e1152bfc8e` | Ge Lang Guan | /hangzhou/ge-lang-guan | active | true | 1 |
| `ve_d068cb8fb6` | Gu Jia Bao Zi | /nanjing/gu-jia-bao-zi | active | true | 1 |
| `ve_a47777d12a` | Guang Ying Ju · Lao Zheng Xing | /nanjing/guang-ying-ju-lao-zheng-xing | active | true | 1 |
| `ve_3475456c9b` | Gusu Fusion | /suzhou/gusu-fusion | active | true | 1 |
| `ve_c9bdf9ddb8` | Hao Po Tang Bao | /nanjing/hao-po-tang-bao | active | true | 1 |
| `ve_66199ee46e` | He Shan Mian Jia | /shanghai/he-shan-mian-jia | active | true | 1 |
| `ve_de90b6e9c3` | Heng Qian Kou Huang Zhu Ying San Xian Mian | /wenzhou/heng-qian-kou-huang-zhu-ying-san-xian-mian | active | true | 1 |
| `ve_e64517047a` | Ho Hung Kee | /shanghai/ho-hung-kee | active | true | 1 |
| `ve_0f6a5f23d0` | Hou Pin Xiao Yuan | /nanjing/hou-pin-xiao-yuan | active | true | 1 |
| `ve_b9c67532ea` | Hui Xin Xiao Chi Dian (Deyuan Road) | /hangzhou/hui-xin-xiao-chi-dian-deyuan-road | active | true | 1 |
| `ve_253a0eaf55` | Jin Hong Lao Zi Hao Zhu Zang Fen | /wenzhou/jin-hong-lao-zi-hao-zhu-zang-fen | active | true | 1 |
| `ve_685df7c6f5` | Jin Wen Yu Yuan (Huiyuan Road) | /wenzhou/jin-wen-yu-yuan-huiyuan-road | active | true | 1 |
| `ve_688dcee8c9` | Juan Juan Zao Dian Dian | /wenzhou/juan-juan-zao-dian-dian | active | true | 1 |
| `ve_a3e33775da` | King's Choice (Huyu Road) | /hangzhou/king-s-choice-huyu-road | active | true | 1 |
| `ve_ccc308b463` | Lai Cui Mian Guan (Ji Mao Road) | /hangzhou/lai-cui-mian-guan-ji-mao-road | active | true | 1 |
| `ve_ca46b5e287` | Lao Chen Jia | /suzhou/lao-chen-jia | active | true | 1 |
| `ve_557b576103` | Lao Wen Zhou Hun Tun Dan | /wenzhou/lao-wen-zhou-hun-tun-dan | active | true | 1 |
| `ve_5aab4721a0` | Ling Ling Jiu Jia | /suzhou/ling-ling-jiu-jia | active | true | 1 |
| `ve_22e8135a7f` | Little Pigtail Noodle Shop | /hangzhou/little-pigtail-noodle-shop | active | true | 1 |
| `ve_94f8b27a1d` | Liu Jia You Meng Mei | /suzhou/liu-jia-you-meng-mei | active | true | 1 |
| `ve_a1e52e5a36` | Liu Yi Lou (Nanxin Road) | /suzhou/liu-yi-lou-nanxin-road | active | true | 1 |
| `ve_c191e091bb` | Ma Er Si Fang Cai | /hangzhou/ma-er-si-fang-cai | active | true | 1 |
| `ve_aa712d5a1b` | Mao Chang Lao Mian Guan | /wenzhou/mao-chang-lao-mian-guan | active | true | 1 |
| `ve_c89d728777` | Nan Feng Fan Dian | /hangzhou/nan-feng-fan-dian | active | true | 1 |
| `ve_7c286e49de` | Ning Hai Shi Fu | /shanghai/ning-hai-shi-fu | active | true | 1 |
| `ve_e2f29db6ed` | Oriental Chao | /suzhou/oriental-chao | active | true | 1 |
| `ve_6379ca3d4d` | Ou Yue Zun Xian | /shanghai/ou-yue-zun-xian | active | true | 1 |
| `ve_2f83e6a534` | Qing Chun Perma | /hangzhou/qing-chun-perma | active | true | 1 |
| `ve_3a4a55928e` | Qing Tao | /hangzhou/qing-tao | active | true | 1 |
| `ve_84faf8d1f8` | Rong Xian Mian Guan (Qianjiang Road) | /hangzhou/rong-xian-mian-guan-qianjiang-road | active | true | 1 |
| `ve_01fc419350` | Run Feng He Niu Za | /wenzhou/run-feng-he-niu-za | active | true | 1 |
| `ve_b426a6ef18` | Shi Wei Xian (Shangcheng) | /hangzhou/shi-wei-xian-shangcheng | active | true | 1 |
| `ve_45e0ac2be8` | Tang Yuan | /suzhou/tang-yuan | active | true | 1 |
| `ve_2a78957c12` | The Taste of Huzhou | /shanghai/the-taste-of-huzhou | active | true | 1 |
| `ve_268dcb0fb1` | Tong Ma Ma (Xihu) | /hangzhou/tong-ma-ma-xihu | active | true | 1 |
| `ve_56dfa4c5fa` | Wang Ri Shun Hao (Shangcheng) | /hangzhou/wang-ri-shun-hao-shangcheng | active | true | 1 |
| `ve_74012718ad` | Xiao Bai Cai | /hangzhou/xiao-bai-cai | active | true | 1 |
| `ve_4a103bb6ce` | Xiao Dian Huang | /hangzhou/xiao-dian-huang | active | true | 1 |
| `ve_a6a9979c01` | Xiao Tao Mian Guan | /shanghai/xiao-tao-mian-guan | active | true | 1 |
| `ve_4b36b8659a` | Xiao Zhu Fan Dian | /hangzhou/xiao-zhu-fan-dian | active | true | 1 |
| `ve_2e4a06078e` | Xiu Cai Yang Rou Mian | /hangzhou/xiu-cai-yang-rou-mian | active | true | 1 |
| `ve_46863e0216` | Xu Jian Ping Tang Bao (Rehe South Road) | /nanjing/xu-jian-ping-tang-bao-rehe-south-road | active | true | 1 |
| `ve_476b32da8e` | Xu Pangzi San Bai Wan Bao Ying Chang Yu Mian | /nanjing/xu-pangzi-san-bai-wan-bao-ying-chang-yu-mian | active | true | 1 |
| `ve_09f3924823` | Yu Cheng | /yangzhou/yu-cheng | active | true | 1 |
| `ve_8e59e4721a` | Yu Ji Seafood | /wenzhou/yu-ji-seafood | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-china`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 469 |
| michelin | city_label | 320 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-china`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-china`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
