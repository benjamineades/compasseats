-- price-michelin-card-p2-b4-2026-10-30.sql
-- Block A, step 2, batch 4 (Japan, 568 venues).
-- Population P2: active venues with a Michelin One Star, Two Stars, Three Stars or Bib Gourmand row whose source_url is
-- a guide.michelin.com card URL (latest by year desc, id desc), and a price row with source legacy_guide and no source_url.
-- Source: the live Michelin card page (Price: line, data-sheet), read in the built-in browser.
-- Rows: 566 UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
-- source_url = card URL, symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
-- captured_at = read time). Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026).
-- Cards that show Selected only are also updated; award rows do not change (Ben, Oct 30, 2026; Oct 10 ruling).
-- Currencies: JPY 566. Card tiers: 1 = 85, 2 = 133, 3 = 184, 4 = 164. Card distinction: 1 star 269, 2 star 60, 3 star 20, bib 217.
-- Relay sha256 d5c8ff329cc599b7a3e9123ff0024f7529434f1436f18ceab6495a49a275a99d (inside this file).
-- Guards: counts before (price 7582, ledger max 143, audit max 115494); relay fingerprint md5
-- 8ba34f2c348892115c457b6aa090c45e; venue id md5 1946c6d9b0f1819dfc40620360d34612; old price rows md5 82320598e849ac3b78466c3123a2a23a;
-- each row in P2 now with the same card URL.
-- Post-checks: price count 7582 (unchanged); ledger 144; audit 566 price UPDATE rows, nothing else;
-- each price row now matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_0266238561|us/en/kyoto-region/kyoto/restaurant/takayama|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:23.582Z
ve_0340ada29d|us/en/osaka-region/osaka/restaurant/fushimimachi-kakoiyama|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:24.877Z
ve_03fe5f705f|us/en/tokyo-region/tokyo/restaurant/bistro-glouton|¥¥|CAT_P02|bib|jp|2026-10-30T07:18:26.223Z
ve_041c8fb2df|us/en/nara-region/nara/restaurant/oryori-hirooka|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:27.595Z
ve_05152fecb8|us/en/kyoto-region/kyoto/restaurant/kentan-horibe|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:28.947Z
ve_056b102763|us/en/osaka-region/osaka/restaurant/via-del-emme|¥¥|CAT_P02|bib|jp|2026-10-30T07:18:30.275Z
ve_06b9113572|us/en/kyoto-region/kyoto/restaurant/komedokoro-inamoto|¥¥|CAT_P02|bib|jp|2026-10-30T07:18:31.603Z
ve_070a18eed9|us/en/tokyo-region/tokyo/restaurant/il-ballond-oro|¥¥|CAT_P02|bib|jp|2026-10-30T07:18:32.956Z
ve_0767b4aa0a|us/en/tokyo-region/tokyo/restaurant/akasaka-kikunoi|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:18:34.280Z
ve_07887175b2|us/en/kyoto-region/kyoto/restaurant/yokoi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:35.631Z
ve_07996ae9b7|us/en/kyoto-region/kyoto/restaurant/ryo-sho|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:18:36.981Z
ve_0810d95181|us/en/osaka-region/osaka/restaurant/taian|¥¥¥|CAT_P03|3 star|jp|2026-10-30T07:18:38.323Z
ve_0826f18c1a|us/en/tokyo-region/tokyo/restaurant/sushi-oya|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:39.695Z
ve_087c611947|us/en/osaka-region/osaka/restaurant/shinchi-yamamoto|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:41.022Z
ve_08c64892ba|us/en/osaka-region/osaka/restaurant/hiraishi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:42.348Z
ve_094f48c1e3|us/en/tokyo-region/tokyo/restaurant/ittoan|¥|CAT_P01|bib|jp|2026-10-30T07:18:43.693Z
ve_09549dd1f7|us/en/nara-region/nara/restaurant/da-terra-1197086|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:45.027Z
ve_09a8b80f97|us/en/tokyo-region/tokyo/restaurant/amarantos|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:46.351Z
ve_09aacb0422|us/en/tokyo-region/tokyo/restaurant/sincere|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:47.740Z
ve_09cfaad40e|us/en/kyoto-region/kyoto/restaurant/cenci|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:49.064Z
ve_0a13ccdcb2|us/en/tokyo-region/tokyo/restaurant/higashiyama-muku|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:50.400Z
ve_0a3a67bc36|us/en/osaka-region/osaka/restaurant/sushi-hoshiyama|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:18:51.735Z
ve_0a60b6461b|us/en/osaka-region/osaka/restaurant/au-soleil-couchant|¥¥|CAT_P02|bib|jp|2026-10-30T07:18:53.067Z
ve_0ade33a779|us/en/kyoto-region/kyoto/restaurant/ogata|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:18:55.096Z
ve_0b7681b27f|us/en/tokyo-region/tokyo/restaurant/esterre-by-alain-ducasse|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:18:57.097Z
ve_0bc5f10006|us/en/osaka-region/osaka/restaurant/daidokoro-kamiya|¥¥|CAT_P02|bib|jp|2026-10-30T07:18:59.096Z
ve_0c85dc54ca|us/en/osaka-region/osaka/restaurant/ayamuya|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:01.095Z
ve_0e0d852f12|us/en/tokyo-region/tokyo/restaurant/edomae-shinsaku|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:03.097Z
ve_0e2518ebfe|us/en/tokyo-region/tokyo/restaurant/azabujuban-fukuda|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:05.097Z
ve_0e750f18bc|us/en/tokyo-region/tokyo/restaurant/oniku-karyu|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:07.096Z
ve_0e8fe328a3|us/en/osaka-region/osaka/restaurant/aka-to-shiro|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:09.096Z
ve_0f8cddca39|us/en/kyoto-region/kyoto/restaurant/kenninji-gion-maruyama|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:19:11.096Z
ve_0fadfdc41e|us/en/osaka-region/osaka/restaurant/izakaya-tokitame|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:13.097Z
ve_100939d444|us/en/nara-region/nara/restaurant/gokan-uogin|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:15.097Z
ve_104e470657|us/en/kyoto-region/kyoto/restaurant/kikunoi-sushi-ao|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:17.097Z
ve_10a564419c|us/en/tokyo-region/tokyo/restaurant/sushi-ryujiro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:19.097Z
ve_115c866946|us/en/tokyo-region/tokyo/restaurant/sushi-masashi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:21.097Z
ve_118c549ee1|us/en/osaka-region/osaka/restaurant/sushitsune|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:23.096Z
ve_11f71e3b19|us/en/tokyo-region/tokyo/restaurant/le-cabaret-1194236|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:25.096Z
ve_1228812987|us/en/tokyo-region/tokyo/restaurant/kagurazaka-ishikawa|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:19:27.097Z
ve_1253ff63cb|us/en/kyoto-region/kyoto/restaurant/vena|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:29.097Z
ve_1426466ab2|us/en/osaka-region/osaka/restaurant/gastroteka-bimendi|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:31.096Z
ve_1528041274|us/en/osaka-region/osaka/restaurant/az|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:33.097Z
ve_153a0acc8c|us/en/kyoto-region/kyoto/restaurant/kokage|¥|CAT_P01|bib|jp|2026-10-30T07:19:35.096Z
ve_15901447bb|us/en/tokyo-region/tokyo/restaurant/hakunei|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:37.094Z
ve_1613162f00|us/en/tokyo-region/tokyo/restaurant/ryuzu|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:19:39.096Z
ve_16444df23a|us/en/tokyo-region/tokyo/restaurant/l-effervescence|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:19:41.097Z
ve_165bb75c02|us/en/nara-region/nara/restaurant/tsukumo|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:19:42.435Z
ve_169776367b|us/en/kyoto-region/kyoto/restaurant/nijojo-furuta|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:43.760Z
ve_1739f951dc|us/en/kyoto-region/kyoto/restaurant/okina|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:45.129Z
ve_17a391541c|us/en/kyoto-region/kyoto/restaurant/kyoryori-fujimoto|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:46.455Z
ve_17cc364bf0|us/en/osaka-region/osaka/restaurant/hachi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:47.790Z
ve_184c446cc9|us/en/osaka-region/osaka/restaurant/oudon-yomogi|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:49.117Z
ve_1858e9ce1e|us/en/tokyo-region/tokyo/restaurant/onigiri-asakusa-yadoroku|¥|CAT_P01|bib|jp|2026-10-30T07:19:50.496Z
ve_18bafb08e6|us/en/nara-region/nara/restaurant/la-trace|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:51.840Z
ve_18bf242c3e|us/en/kyoto-region/kyoto/restaurant/tenjaku|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:53.188Z
ve_19243b1c9c|us/en/osaka-region/osaka/restaurant/chukashunsai-morimoto|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:54.510Z
ve_196259eb98|us/en/tokyo-region/tokyo/restaurant/khao-1217131|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:55.869Z
ve_19c9148e3e|us/en/kyoto-region/kyoto/restaurant/velrosier|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:19:57.209Z
ve_19ecb161f6|us/en/osaka-region/osaka/restaurant/bistrot-neuf-1242628|¥¥|CAT_P02|bib|jp|2026-10-30T07:19:58.534Z
ve_1aa3f14a3d|us/en/tokyo-region/tokyo/restaurant/sharikimon-onozawa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:19:59.870Z
ve_1ac93b8725|us/en/tokyo-region/tokyo/restaurant/quintessence-1193907|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:20:01.225Z
ve_1b1f4550a4|us/en/tokyo-region/tokyo/restaurant/prunier-1200289|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:02.574Z
ve_1b466a5770|us/en/tokyo-region/tokyo/restaurant/audace|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:03.908Z
ve_1b4c11e405|us/en/kyoto-region/kyoto/restaurant/hana-kitcho|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:05.257Z
ve_1b655de605|us/en/tokyo-region/tokyo/restaurant/loiseau-de-france|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:06.621Z
ve_1b6e351f59|us/en/tokyo-region/tokyo/restaurant/hamacho-kaneko|¥|CAT_P01|bib|jp|2026-10-30T07:20:07.953Z
ve_1bbc2233f7|us/en/osaka-region/osaka/restaurant/udondokoro-shigemi|¥|CAT_P01|bib|jp|2026-10-30T07:20:09.286Z
ve_1c88c9a376|us/en/osaka-region/osaka/restaurant/torisho-ishii|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:10.634Z
ve_1ca39112fa|us/en/tokyo-region/tokyo/restaurant/tempura-maehira|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:11.976Z
ve_1dd4870df5|us/en/tokyo-region/tokyo/restaurant/jeeten|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:13.298Z
ve_1e0adb25c9|us/en/kyoto-region/kyoto/restaurant/nakamitsu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:14.644Z
ve_1e25d71308|us/en/osaka-region/osaka/restaurant/kushiage-010|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:15.984Z
ve_1fc9785dc5|us/en/osaka-region/osaka/restaurant/ueroku-wine|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:17.319Z
ve_1fce8cda75|us/en/tokyo-region/tokyo/restaurant/homemade-ramen-muginae|¥|CAT_P01|bib|jp|2026-10-30T07:20:18.664Z
ve_2074100447|us/en/kyoto-region/kyoto/restaurant/koga|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:20.008Z
ve_21e18a46e2|us/en/tokyo-region/tokyo/restaurant/arroceria-la-panza|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:21.335Z
ve_229d889321|us/en/tokyo-region/tokyo/restaurant/hommage|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:20:22.674Z
ve_233a1477b3|us/en/osaka-region/osaka/restaurant/oribe|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:24.006Z
ve_237d867f36|us/en/kyoto-region/kyoto/restaurant/oito|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:25.359Z
ve_240c9f8e3c|us/en/tokyo-region/tokyo/restaurant/den|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:20:26.704Z
ve_24c21f0e0f|us/en/osaka-region/osaka/restaurant/milpa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:20:28.039Z
ve_24d365e537|us/en/kyoto-region/kyoto/restaurant/chikuyuan-taro-no-atsumori|¥|CAT_P01|bib|jp|2026-10-30T07:20:29.377Z
ve_24f473c47d|us/en/kyoto-region/kyoto/restaurant/sanso-kyoyamato|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:20:30.726Z
ve_26199d1edb|us/en/tokyo-region/tokyo/restaurant/grill-grand|¥|CAT_P01|bib|jp|2026-10-30T07:20:32.076Z
ve_2735613bfa|us/en/osaka-region/osaka/restaurant/presqu’ile|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:33.326Z
ve_2781ff363b|us/en/kyoto-region/kyoto/restaurant/sushi-kappo-nakaichi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:34.651Z
ve_282053b3f3|us/en/osaka-region/osaka/restaurant/empathie|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:35.989Z
ve_285c8ec77d|us/en/osaka-region/osaka/restaurant/ideal-bistro|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:37.313Z
ve_2882c38a39|us/en/kyoto-region/kyoto/restaurant/lapintaika|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:38.641Z
ve_28c3e71671|us/en/tokyo-region/tokyo/restaurant/shinois|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:20:39.998Z
ve_28c66c04e4|us/en/osaka-region/osaka/restaurant/ad-hoc-1193091|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:41.368Z
ve_28f93dac25|us/en/kyoto-region/kyoto/restaurant/sushi-rakumi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:20:42.696Z
ve_28f9969ee9|us/en/kyoto-region/kyoto/restaurant/ryoriya-maekawa|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:44.027Z
ve_2975ff0f80|us/en/tokyo-region/tokyo/restaurant/hatsuogawa|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:45.357Z
ve_2a1f597caa|us/en/tokyo-region/tokyo/restaurant/los-reyes-magos|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:46.682Z
ve_2a4c4351a5|us/en/tokyo-region/tokyo/restaurant/metis-roppongi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:48.040Z
ve_2a93c92bc8|us/en/tokyo-region/tokyo/restaurant/cristiano-s|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:49.373Z
ve_2b86916db9|us/en/tokyo-region/tokyo/restaurant/lauburu|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:50.704Z
ve_2b9977706a|us/en/osaka-region/osaka/restaurant/katamachi-kawaguchi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:20:52.027Z
ve_2c67034c77|us/en/kyoto-region/kyoto/restaurant/yusokuryori-mankamero|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:20:53.370Z
ve_2c6bdb719c|us/en/kyoto-region/kyoto/restaurant/sumibi-kappo-ifuki|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:20:54.701Z
ve_2c7d5b1e03|us/en/nara-region/nara/restaurant/ike-edoyakiunagi-asahitei|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:56.027Z
ve_2d4e824cb3|us/en/tokyo-region/tokyo/restaurant/towa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:20:57.344Z
ve_2d7c9264d5|us/en/osaka-region/osaka/restaurant/sakeya-sakana-yoshimura|¥¥|CAT_P02|bib|jp|2026-10-30T07:20:58.675Z
ve_2dbff4bc03|us/en/osaka-region/osaka/restaurant/sushi-sanshin|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:00.027Z
ve_2e8a0ddae8|us/en/tokyo-region/tokyo/restaurant/l-osier|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:21:01.374Z
ve_2f2d0d3e24|us/en/osaka-region/osaka/restaurant/sumibi-iwata|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:02.624Z
ve_31054ffaba|us/en/tokyo-region/tokyo/restaurant/asakusa-hirayama|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:03.970Z
ve_3131fd82fb|us/en/tokyo-region/tokyo/restaurant/makiyaki-ginza-onodera|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:05.322Z
ve_3155a60729|us/en/kyoto-region/kyoto/restaurant/muromachi-yui|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:21:06.652Z
ve_31c0193de3|us/en/tokyo-region/tokyo/restaurant/tohakuan-karibe|¥|CAT_P01|bib|jp|2026-10-30T07:21:07.987Z
ve_3213838b49|us/en/kyoto-region/kyoto/restaurant/gombe|¥|CAT_P01|bib|jp|2026-10-30T07:21:09.316Z
ve_322c7c1e5b|us/en/tokyo-region/tokyo/restaurant/prisma-1194160|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:21:10.671Z
ve_328287749a|us/en/kyoto-region/kyoto/restaurant/tozentei|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:12.007Z
ve_328e9da1dc|us/en/tokyo-region/tokyo/restaurant/l-as|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:13.362Z
ve_32950649ba|us/en/osaka-region/osaka/restaurant/chi-fu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:14.708Z
ve_3374d120b0|us/en/kyoto-region/kyoto/restaurant/sushizen|¥|CAT_P01|bib|jp|2026-10-30T07:21:16.044Z
ve_34f1f4878c|us/en/tokyo-region/tokyo/restaurant/zupperia-osteria-pitigliano|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:17.402Z
ve_35a300fc07|us/en/kyoto-region/kyoto/restaurant/kyoboshi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:18.750Z
ve_35b499f9f9|us/en/osaka-region/osaka/restaurant/tosara|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:20.070Z
ve_37469ce12d|us/en/tokyo-region/tokyo/restaurant/monolith|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:21.411Z
ve_3788f04641|us/en/tokyo-region/tokyo/restaurant/sasaki-seimenjo|¥|CAT_P01|bib|jp|2026-10-30T07:21:22.781Z
ve_3800dd8c46|us/en/tokyo-region/tokyo/restaurant/tachiguisushi-sushikawa|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:24.127Z
ve_38014b33f3|us/en/tokyo-region/tokyo/restaurant/alchimiste|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:25.484Z
ve_3813795fa1|us/en/tokyo-region/tokyo/restaurant/sazenka|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:21:26.860Z
ve_3862b9b33f|us/en/tokyo-region/tokyo/restaurant/ma-poule|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:28.223Z
ve_38793db837|us/en/osaka-region/osaka/restaurant/sushi-shigenaga|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:29.605Z
ve_3aa6c81ddd|us/en/tokyo-region/tokyo/restaurant/falo|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:30.941Z
ve_3ae4ff85b9|us/en/osaka-region/osaka/restaurant/capi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:32.302Z
ve_3b1d1ca75a|us/en/tokyo-region/tokyo/restaurant/nodaiwa-azabu-Iikura-honten-1194124|¥¥|CAT_P02|1 star|jp|2026-10-30T07:21:33.635Z
ve_3b476d06c1|us/en/osaka-region/osaka/restaurant/oryori-amenimomakezu|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:34.992Z
ve_3c46f82f40|us/en/osaka-region/osaka/restaurant/nishitemma-ichigaya|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:36.341Z
ve_3cd64c60ad|us/en/kyoto-region/kyoto/restaurant/kashiwai|¥|CAT_P01|bib|jp|2026-10-30T07:21:37.694Z
ve_3d4b0c6d82|us/en/kyoto-region/kyoto/restaurant/kyokaiseki-kichisen|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:21:39.055Z
ve_3d96f21923|us/en/kyoto-region/kyoto/restaurant/gion-sasaki|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:21:40.413Z
ve_3dce045817|us/en/kyoto-region/kyoto/restaurant/kombu-to-men-kiichi|¥|CAT_P01|bib|jp|2026-10-30T07:21:41.748Z
ve_3e0d7ba19c|us/en/osaka-region/osaka/restaurant/ogimachi-udonya-asuro|¥|CAT_P01|bib|jp|2026-10-30T07:21:43.100Z
ve_3e240669cf|us/en/tokyo-region/tokyo/restaurant/soba-tajima|¥|CAT_P01|bib|jp|2026-10-30T07:21:44.428Z
ve_3e4630aa9d|us/en/kyoto-region/kyoto/restaurant/gion-maruyama|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:21:45.764Z
ve_40036dc7a9|us/en/tokyo-region/tokyo/restaurant/washokuya-taichi|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:47.100Z
ve_403bdaaaa3|us/en/kyoto-region/kyoto/restaurant/uozuya|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:48.443Z
ve_40675185d5|us/en/tokyo-region/tokyo/restaurant/tanimoto|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:49.781Z
ve_4105cbe1c6|us/en/kyoto-region/kyoto/restaurant/bocca-del-vino|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:51.180Z
ve_418d1e9238|us/en/kyoto-region/kyoto/restaurant/kenya|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:52.506Z
ve_41ffc915c2|us/en/osaka-region/osaka/restaurant/matsuzushi-tanigawa|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:53.866Z
ve_4234e01afa|us/en/tokyo-region/tokyo/restaurant/jushu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:21:55.202Z
ve_4266a442c5|us/en/osaka-region/osaka/restaurant/higashichaya-nakamura|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:21:56.544Z
ve_42b6f24c27|us/en/tokyo-region/tokyo/restaurant/sushi-yoshino|¥¥|CAT_P02|bib|jp|2026-10-30T07:21:57.892Z
ve_42e852e214|us/en/kyoto-region/kyoto/restaurant/otagi|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:21:59.232Z
ve_43028da2fe|us/en/osaka-region/osaka/restaurant/teruya|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:22:00.561Z
ve_432b7e8f38|us/en/kyoto-region/kyoto/restaurant/fuyacho-kuraku|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:01.894Z
ve_445a6ec342|us/en/kyoto-region/kyoto/restaurant/mirei-1193056|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:04.512Z
ve_44a5f7a02e|us/en/tokyo-region/tokyo/restaurant/sushi-yuki-1213818|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:05.860Z
ve_4516eb1874|us/en/tokyo-region/tokyo/restaurant/primo-passo|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:07.212Z
ve_45355446a9|us/en/tokyo-region/tokyo/restaurant/noura|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:08.555Z
ve_45960aa123|us/en/osaka-region/osaka/restaurant/shokudo-akari|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:09.921Z
ve_45ff3e49a6|us/en/osaka-region/osaka/restaurant/sushi-harasho|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:22:11.261Z
ve_460a05976d|us/en/kyoto-region/kyoto/restaurant/mashiro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:12.587Z
ve_464b8fc633|us/en/tokyo-region/tokyo/restaurant/rei|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:13.927Z
ve_4671047bc7|us/en/nara-region/nara/restaurant/okada|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:15.288Z
ve_46f5f7e476|us/en/tokyo-region/tokyo/restaurant/trois-visages|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:16.631Z
ve_470c7d8e11|us/en/tokyo-region/tokyo/restaurant/jingumae-higuchi|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:22:17.987Z
ve_48f6ccbb98|us/en/osaka-region/osaka/restaurant/jibundoki|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:19.318Z
ve_491642d330|us/en/kyoto-region/kyoto/restaurant/sumiyakisosaitoriya-hitomi|¥|CAT_P01|bib|jp|2026-10-30T07:22:20.658Z
ve_4925d9fb4a|us/en/osaka-region/osaka/restaurant/rakushin|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:21.985Z
ve_4a5e42c2b6|us/en/tokyo-region/tokyo/restaurant/hyakuyaku-by-tokuyamazushi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:23.314Z
ve_4b24de3db6|us/en/kyoto-region/kyoto/restaurant/kiyama|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:24.655Z
ve_4d0b74fbac|us/en/kyoto-region/kyoto/restaurant/shigetsu|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:25.991Z
ve_4d2a7f1523|us/en/tokyo-region/tokyo/restaurant/osteria-da-k-kappa|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:27.344Z
ve_4d7b1a8139|us/en/tokyo-region/tokyo/restaurant/joel-robuchon-1193981|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:22:28.693Z
ve_4e415062c3|us/en/tokyo-region/tokyo/restaurant/rozzo-sicilia|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:30.043Z
ve_4e61db8ff1|us/en/osaka-region/osaka/restaurant/yakitori-ichimatsu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:31.405Z
ve_4e63eb5572|us/en/kyoto-region/kyoto/restaurant/ramen-touhichi|¥|CAT_P01|bib|jp|2026-10-30T07:22:32.752Z
ve_4f4d47929d|us/en/tokyo-region/tokyo/restaurant/zurriola|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:34.085Z
ve_4fa281f2ff|us/en/tokyo-region/tokyo/restaurant/seki-hanare|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:35.429Z
ve_5014ed0e59|us/en/osaka-region/osaka/restaurant/mugito-mensuke|¥|CAT_P01|bib|jp|2026-10-30T07:22:36.776Z
ve_507213fe75|us/en/nara-region/nara/restaurant/lega|¥¥|CAT_P02|1 star|jp|2026-10-30T07:22:38.111Z
ve_515f7d9316|us/en/kyoto-region/kyoto/restaurant/tokuha-motonari|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:22:39.431Z
ve_517e7ff6c2|us/en/kyoto-region/kyoto/restaurant/restaurant-hiramatsu-kodaiji|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:40.761Z
ve_51e8305180|us/en/tokyo-region/tokyo/restaurant/au-deco|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:42.113Z
ve_520ed7d621|us/en/nara-region/nara/restaurant/wa-yamamura|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:43.463Z
ve_525c1cc7a8|us/en/kyoto-region/kyoto/restaurant/doppo|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:22:44.812Z
ve_5265af918f|us/en/kyoto-region/kyoto/restaurant/gion-nishikawa|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:22:46.139Z
ve_527183abed|us/en/kyoto-region/kyoto/restaurant/eitaroya|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:47.489Z
ve_5283e50fdc|us/en/tokyo-region/tokyo/restaurant/craftale|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:48.844Z
ve_528d7bf0b1|us/en/kyoto-region/kyoto/restaurant/ayanokoji-karatsu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:50.194Z
ve_52b9de414e|us/en/osaka-region/osaka/restaurant/yonemasu|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:51.522Z
ve_537899a6f4|us/en/kyoto-region/kyoto/restaurant/droit|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:52.871Z
ve_53b6032c82|us/en/kyoto-region/kyoto/restaurant/higashiyama-yoshihisa|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:22:54.206Z
ve_540d615c36|us/en/kyoto-region/kyoto/restaurant/kikunoi-mugesambo|¥¥|CAT_P02|bib|jp|2026-10-30T07:22:55.534Z
ve_5452333718|us/en/tokyo-region/tokyo/restaurant/sushi-matsuura|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:56.882Z
ve_54676b2278|us/en/kyoto-region/kyoto/restaurant/germoglio|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:22:58.212Z
ve_54dd9230f5|us/en/tokyo-region/tokyo/restaurant/ginza-kitagawa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:22:59.549Z
ve_56bf1127ea|us/en/tokyo-region/tokyo/restaurant/sushi-mikata|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:00.899Z
ve_56c6657840|us/en/osaka-region/osaka/restaurant/tenboshi|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:02.235Z
ve_573199af8e|us/en/osaka-region/osaka/restaurant/point|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:03.583Z
ve_574009e126|us/en/tokyo-region/tokyo/restaurant/tompachitei|¥|CAT_P01|bib|jp|2026-10-30T07:23:04.927Z
ve_59339574d2|us/en/tokyo-region/tokyo/restaurant/le-monde-gourmand|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:06.265Z
ve_59e336b376|us/en/tokyo-region/tokyo/restaurant/oryori-tsuji|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:23:07.599Z
ve_59eb547631|us/en/osaka-region/osaka/restaurant/terada|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:08.958Z
ve_5a1ee2f1d0|us/en/nara-region/nara/restaurant/unagino-toyokawa|¥|CAT_P01|bib|jp|2026-10-30T07:23:10.299Z
ve_5a485b8b10|us/en/tokyo-region/tokyo/restaurant/le-sputnik|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:11.646Z
ve_5a5f89b599|us/en/nara-region/nara/restaurant/ajinokaze-nishimura|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:13.040Z
ve_5aa79a55ab|us/en/kyoto-region/kyoto/restaurant/gion-yorozuya|¥|CAT_P01|bib|jp|2026-10-30T07:23:14.369Z
ve_5ae66b3ce7|us/en/tokyo-region/tokyo/restaurant/daigo|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:15.707Z
ve_5b3f4a7f36|us/en/tokyo-region/tokyo/restaurant/nishiazabu-sushi-shin|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:23:17.040Z
ve_5b49a9e016|us/en/kyoto-region/kyoto/restaurant/kokyu|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:23:18.381Z
ve_5be55d7d5d|us/en/tokyo-region/tokyo/restaurant/nemo|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:19.727Z
ve_5ca644943b|us/en/osaka-region/osaka/restaurant/diva-1242557|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:21.064Z
ve_5e46bced6d|us/en/tokyo-region/tokyo/restaurant/nihombashi-sonoji|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:23:22.401Z
ve_5e4c6b5e47|us/en/kyoto-region/kyoto/restaurant/kanamean-nishitomiya|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:23:23.734Z
ve_5e95837099|us/en/tokyo-region/tokyo/restaurant/bottega-1194168|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:25.067Z
ve_5eeec43f90|us/en/tokyo-region/tokyo/restaurant/katsuyoshi|¥|CAT_P01|bib|jp|2026-10-30T07:23:26.398Z
ve_5fa2251428|us/en/tokyo-region/tokyo/restaurant/yama-1214953|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:23:27.777Z
ve_5fc48d83af|us/en/osaka-region/osaka/restaurant/benikurage|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:29.119Z
ve_5fdec7cdbf|us/en/tokyo-region/tokyo/restaurant/maz|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:23:30.450Z
ve_600f8aecb8|us/en/kyoto-region/kyoto/restaurant/gion-kida|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:23:31.775Z
ve_60b3a6dc45|us/en/osaka-region/osaka/restaurant/fujiya-1935|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:23:33.097Z
ve_6131017f3c|us/en/osaka-region/osaka/restaurant/kahala|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:23:34.450Z
ve_61d60cddfc|us/en/kyoto-region/kyoto/restaurant/soba-rojina|¥|CAT_P01|bib|jp|2026-10-30T07:23:35.777Z
ve_62593aeff2|us/en/kyoto-region/kyoto/restaurant/muromachi-wakuden|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:37.110Z
ve_63a235c8e5|us/en/nara-region/nara/restaurant/matsuki|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:38.440Z
ve_63a6805c29|us/en/osaka-region/osaka/restaurant/naniwaryori-yu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:39.784Z
ve_63a8fc16bb|us/en/tokyo-region/tokyo/restaurant/itsuka|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:41.110Z
ve_63c158b08e|us/en/tokyo-region/tokyo/restaurant/tensuke|¥|CAT_P01|bib|jp|2026-10-30T07:23:42.431Z
ve_63c486d595|us/en/osaka-region/osaka/restaurant/yunico-1194638|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:43.681Z
ve_650217c5b8|us/en/kyoto-region/kyoto/restaurant/gion-fukushi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:45.017Z
ve_650425a5b1|us/en/tokyo-region/tokyo/restaurant/ramen-break-beats|¥|CAT_P01|bib|jp|2026-10-30T07:23:46.359Z
ve_6517d9dd16|us/en/osaka-region/osaka/restaurant/zeshin|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:47.688Z
ve_65d5a5a4f0|us/en/kyoto-region/kyoto/restaurant/deux-filles|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:49.013Z
ve_65f96ecad1|us/en/kyoto-region/kyoto/restaurant/jukuseibuta-kawamura|¥|CAT_P01|bib|jp|2026-10-30T07:23:50.371Z
ve_671892af09|us/en/osaka-region/osaka/restaurant/miyamoto|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:23:51.708Z
ve_67847aba07|us/en/tokyo-region/tokyo/restaurant/sushidokoro-shigeru|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:53.044Z
ve_68d2414744|us/en/kyoto-region/kyoto/restaurant/torisaki|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:54.381Z
ve_6ae0fab4ce|us/en/tokyo-region/tokyo/restaurant/waketokuyama|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:55.705Z
ve_6ae499440e|us/en/osaka-region/osaka/restaurant/atelier-hanada|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:23:57.044Z
ve_6badff1e98|us/en/kyoto-region/kyoto/restaurant/mizai|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:23:58.386Z
ve_6bf6db4c8b|us/en/nara-region/nara/restaurant/sosakukushinomise-rindo|¥¥|CAT_P02|bib|jp|2026-10-30T07:23:59.710Z
ve_6c0ed2d896|us/en/osaka-region/osaka/restaurant/ajikitcho-horieten|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:01.037Z
ve_6c82d559c8|us/en/osaka-region/osaka/restaurant/tonkatsu-minato|¥|CAT_P01|bib|jp|2026-10-30T07:24:02.393Z
ve_6dae49031a|us/en/tokyo-region/tokyo/restaurant/sosakumenkobo-nakiryu|¥|CAT_P01|bib|jp|2026-10-30T07:24:03.736Z
ve_6e3a543b7d|us/en/nara-region/nara/restaurant/villa-communico|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:05.065Z
ve_6e4f0f5f1e|us/en/osaka-region/osaka/restaurant/ayamedo|¥|CAT_P01|bib|jp|2026-10-30T07:24:06.396Z
ve_6e58c7a0a2|us/en/tokyo-region/tokyo/restaurant/tempura-yaguchi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:07.736Z
ve_6e8a954749|us/en/tokyo-region/tokyo/restaurant/sushi-kanesaka|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:24:09.067Z
ve_6f03c72816|us/en/nara-region/nara/restaurant/masala-an-takumi|¥¥|CAT_P02|bib|jp|2026-10-30T07:24:10.397Z
ve_7027eecce5|us/en/osaka-region/osaka/restaurant/ono|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:11.730Z
ve_702f1f5ddd|us/en/tokyo-region/tokyo/restaurant/tonkatsu-nanaido|¥|CAT_P01|bib|jp|2026-10-30T07:24:13.070Z
ve_703da6e298|us/en/tokyo-region/tokyo/restaurant/japanese-ramen-gokan|¥|CAT_P01|bib|jp|2026-10-30T07:24:14.412Z
ve_709ab5055e|us/en/tokyo-region/tokyo/restaurant/azabu-kadowaki|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:24:15.740Z
ve_70cb3235ec|us/en/tokyo-region/tokyo/restaurant/kohaku|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:24:17.068Z
ve_722db4b9cf|us/en/tokyo-region/tokyo/restaurant/alceppo|¥¥|CAT_P02|bib|jp|2026-10-30T07:24:18.397Z
ve_730c73dbcd|us/en/osaka-region/osaka/restaurant/shunsaiten-tsuchiya|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:24:19.719Z
ve_738589d1ef|us/en/tokyo-region/tokyo/restaurant/sumibikappo-shirosaka|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:21.040Z
ve_73d656b1f5|us/en/tokyo-region/tokyo/restaurant/tenmasa-1194080|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:22.397Z
ve_73df01afd9|us/en/tokyo-region/tokyo/restaurant/seiju|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:23.738Z
ve_741bd4a128|us/en/tokyo-region/tokyo/restaurant/beige-alain-ducasse|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:25.079Z
ve_75178730d2|us/en/kyoto-region/kyoto/restaurant/gosho-iwasaki|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:26.405Z
ve_75546539a6|us/en/osaka-region/osaka/restaurant/sushidokoro-kaihara|¥¥|CAT_P02|bib|jp|2026-10-30T07:24:27.757Z
ve_75fab86e5d|us/en/osaka-region/osaka/restaurant/masuda|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:29.101Z
ve_7608480c94|us/en/tokyo-region/tokyo/restaurant/lature|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:30.443Z
ve_7725abc286|us/en/tokyo-region/tokyo/restaurant/l-amitie-1194223|¥¥|CAT_P02|bib|jp|2026-10-30T07:24:31.808Z
ve_788968654e|us/en/osaka-region/osaka/restaurant/oryori-yamada|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:33.153Z
ve_78b8f9dbc6|us/en/osaka-region/osaka/restaurant/le-pont-de-ciel|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:34.488Z
ve_79f503c7e0|us/en/kyoto-region/kyoto/restaurant/moko|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:35.814Z
ve_7a11b2a8bb|us/en/kyoto-region/kyoto/restaurant/jean-georges-at-the-shinmonzen|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:37.165Z
ve_7b133a1d0c|us/en/tokyo-region/tokyo/restaurant/faro-1194154|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:38.505Z
ve_7b1eba342c|us/en/nara-region/nara/restaurant/hoshino|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:39.851Z
ve_7b67588778|us/en/tokyo-region/tokyo/restaurant/shiosoba-jiku|¥|CAT_P01|bib|jp|2026-10-30T07:24:41.187Z
ve_7b6babc38b|us/en/kyoto-region/kyoto/restaurant/sokkon-fujimoto|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:42.508Z
ve_7b7b814935|us/en/kyoto-region/kyoto/restaurant/mizuno|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:43.830Z
ve_7ba1a9cef9|us/en/osaka-region/osaka/restaurant/ajikitcho-bumbuan|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:45.166Z
ve_7ba5a45715|us/en/kyoto-region/kyoto/restaurant/kyo-seika|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:46.509Z
ve_7c0b90f228|us/en/tokyo-region/tokyo/restaurant/asahina-gastronome|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:24:47.850Z
ve_7c6ee7dd13|us/en/tokyo-region/tokyo/restaurant/fushikino|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:24:49.187Z
ve_7cde64442b|us/en/osaka-region/osaka/restaurant/nishino|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:50.520Z
ve_7d39c534fc|us/en/kyoto-region/kyoto/restaurant/gion-owatari|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:51.850Z
ve_7d5908767f|us/en/tokyo-region/tokyo/restaurant/hakuun|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:24:53.193Z
ve_7d719b50b6|us/en/kyoto-region/kyoto/restaurant/izugen|¥|CAT_P01|bib|jp|2026-10-30T07:24:54.540Z
ve_7d84d1845a|us/en/tokyo-region/tokyo/restaurant/myojaku|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:24:55.883Z
ve_7dc507bd4d|us/en/tokyo-region/tokyo/restaurant/ippei-hanten|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:24:57.238Z
ve_7e28f93de5|us/en/osaka-region/osaka/restaurant/ramen-kuon|¥|CAT_P01|bib|jp|2026-10-30T07:24:58.579Z
ve_7e47dfa192|us/en/osaka-region/osaka/restaurant/il-luogo-di-takeuchi|¥¥|CAT_P02|bib|jp|2026-10-30T07:24:59.907Z
ve_7e7731c91c|us/en/tokyo-region/tokyo/restaurant/sushi-keita|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:01.248Z
ve_7e7cd5212f|us/en/osaka-region/osaka/restaurant/tonkatsu-fujii|¥|CAT_P01|bib|jp|2026-10-30T07:25:02.588Z
ve_7f19c3bfb0|us/en/tokyo-region/tokyo/restaurant/katchar-batchar|¥|CAT_P01|bib|jp|2026-10-30T07:25:03.938Z
ve_7f4f7363bc|us/en/osaka-region/osaka/restaurant/kamigata-rainbow|¥|CAT_P01|bib|jp|2026-10-30T07:25:05.299Z
ve_7f732a531c|us/en/tokyo-region/tokyo/restaurant/ginza-fukuju|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:25:06.647Z
ve_804832ea81|us/en/tokyo-region/tokyo/restaurant/edition-koji-shimomura|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:25:07.984Z
ve_80c3d65773|us/en/tokyo-region/tokyo/restaurant/night-market-1241936|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:09.340Z
ve_80d44a9cf1|us/en/kyoto-region/kyoto/restaurant/teuchisoba-kanei|¥|CAT_P01|bib|jp|2026-10-30T07:25:10.688Z
ve_80f82eb22c|us/en/kyoto-region/kyoto/restaurant/saketosakana-dna|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:12.020Z
ve_81794a868b|us/en/osaka-region/osaka/restaurant/iroha|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:25:13.349Z
ve_81970bdd3b|us/en/tokyo-region/tokyo/restaurant/sanosushi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:14.688Z
ve_82b64cf9a8|us/en/tokyo-region/tokyo/restaurant/sugita|¥|CAT_P01|bib|jp|2026-10-30T07:25:16.016Z
ve_83a2fd41fd|us/en/tokyo-region/tokyo/restaurant/ginza-haru-chan-ramen|¥|CAT_P01|bib|jp|2026-10-30T07:25:17.353Z
ve_83f310f4a5|us/en/nara-region/nara/restaurant/a-votre-sante|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:18.686Z
ve_8406809a2b|us/en/osaka-region/osaka/restaurant/oryori-horikawa|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:20.009Z
ve_84a7697352|us/en/nara-region/nara/restaurant/pizzeria-trattoria-magazzino|¥|CAT_P01|bib|jp|2026-10-30T07:25:21.340Z
ve_851936a65e|us/en/kyoto-region/kyoto/restaurant/ikkon-uehara|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:22.662Z
ve_85a0be00d4|us/en/tokyo-region/tokyo/restaurant/tonkatsu-enraku|¥|CAT_P01|bib|jp|2026-10-30T07:25:23.989Z
ve_85fa88a932|us/en/osaka-region/osaka/restaurant/pitak-gohan|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:25.339Z
ve_8684be1880|us/en/tokyo-region/tokyo/restaurant/bistrot-vivienne|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:26.683Z
ve_8725e9beb6|us/en/tokyo-region/tokyo/restaurant/tempura-motoyoshi|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:25:28.004Z
ve_875b8bf8d7|us/en/kyoto-region/kyoto/restaurant/koke|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:25:29.346Z
ve_878258b3d0|us/en/tokyo-region/tokyo/restaurant/ginza-shinohara|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:25:30.675Z
ve_87ad9ed8ff|us/en/nara-region/nara/restaurant/oryori-hanagaki|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:25:32.020Z
ve_87e66e9a14|us/en/kyoto-region/kyoto/restaurant/sonoba|¥|CAT_P01|bib|jp|2026-10-30T07:25:33.350Z
ve_87fee68a08|us/en/tokyo-region/tokyo/restaurant/negima|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:34.676Z
ve_8877e1420e|us/en/osaka-region/osaka/restaurant/naniwa-okina|¥|CAT_P01|bib|jp|2026-10-30T07:25:36.004Z
ve_88d2384467|us/en/nara-region/nara/restaurant/koikiryori-aji-manso|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:37.343Z
ve_8992bdffbb|us/en/tokyo-region/tokyo/restaurant/mejiro-shunkotei|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:38.686Z
ve_8a7d6a8c04|us/en/tokyo-region/tokyo/restaurant/series|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:40.032Z
ve_8a81bc1872|us/en/nara-region/nara/restaurant/toi-inshokuten|¥|CAT_P01|bib|jp|2026-10-30T07:25:41.371Z
ve_8af01f5580|us/en/kyoto-region/kyoto/restaurant/itsutsu|¥|CAT_P01|bib|jp|2026-10-30T07:25:42.698Z
ve_8c188887e2|us/en/tokyo-region/tokyo/restaurant/kutan|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:25:44.027Z
ve_8c63fdf8f3|us/en/kyoto-region/kyoto/restaurant/ima-1242636|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:45.356Z
ve_8cbb1d2222|us/en/kyoto-region/kyoto/restaurant/miyawaki-1205446|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:25:46.692Z
ve_8d06b69e57|us/en/osaka-region/osaka/restaurant/sobadokoro-toki|¥|CAT_P01|bib|jp|2026-10-30T07:25:48.036Z
ve_8d33004142|us/en/kyoto-region/kyoto/restaurant/saryo-tesshin|¥|CAT_P01|bib|jp|2026-10-30T07:25:49.382Z
ve_8d760d0eab|us/en/tokyo-region/tokyo/restaurant/akasaka-shimabukuro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:25:50.707Z
ve_8d9a9ffe0d|us/en/tokyo-region/tokyo/restaurant/katsuo-shokudo|¥|CAT_P01|bib|jp|2026-10-30T07:25:52.049Z
ve_8f34bc70e2|us/en/osaka-region/osaka/restaurant/suigyo-murabayashi|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:53.376Z
ve_8f601d1f30|us/en/tokyo-region/tokyo/restaurant/abysse|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:25:54.698Z
ve_90a6bad24f|us/en/osaka-region/osaka/restaurant/konoha|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:25:56.022Z
ve_93a6706c3d|us/en/tokyo-region/tokyo/restaurant/shokudo-wata|¥¥|CAT_P02|bib|jp|2026-10-30T07:25:57.353Z
ve_944d53ba79|us/en/tokyo-region/tokyo/restaurant/mochibuta-tonkatsu-taiyo|¥|CAT_P01|bib|jp|2026-10-30T07:25:58.705Z
ve_948e6afab9|us/en/tokyo-region/tokyo/restaurant/nogizaka-shin|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:00.031Z
ve_9516ed5fb8|us/en/kyoto-region/kyoto/restaurant/miyamaso|¥¥¥|CAT_P03|3 star|jp|2026-10-30T07:26:01.384Z
ve_95447208a1|us/en/tokyo-region/tokyo/restaurant/hiroo-ishizaka|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:02.692Z
ve_9592f540ae|us/en/osaka-region/osaka/restaurant/la-cime|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:26:04.026Z
ve_95a22e3b7b|us/en/kyoto-region/kyoto/restaurant/sen|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:05.352Z
ve_95bcb6b2cd|us/en/kyoto-region/kyoto/restaurant/godan-miyazawa|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:06.696Z
ve_96e24bc5c4|us/en/osaka-region/osaka/restaurant/prestau|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:08.040Z
ve_97017f2e82|us/en/tokyo-region/tokyo/restaurant/santosham|¥|CAT_P01|bib|jp|2026-10-30T07:26:09.367Z
ve_9765128021|us/en/osaka-region/osaka/restaurant/sumisho-mikuriya|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:10.723Z
ve_9927747144|us/en/nara-region/nara/restaurant/nara-nikon|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:26:12.062Z
ve_99f6caa187|us/en/kyoto-region/kyoto/restaurant/kikunoi-roan|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:26:13.428Z
ve_9b2a449b60|us/en/nara-region/nara/restaurant/ajinotabibito-roman|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:14.785Z
ve_9c8ea87567|us/en/tokyo-region/tokyo/restaurant/matsunozushi|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:16.117Z
ve_9ca2427216|us/en/tokyo-region/tokyo/restaurant/tenoshima|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:17.455Z
ve_9d000915ce|us/en/osaka-region/osaka/restaurant/numata-sou|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:18.815Z
ve_9dca83deb3|us/en/kyoto-region/kyoto/restaurant/ramenya-fujitora|¥|CAT_P01|bib|jp|2026-10-30T07:26:20.142Z
ve_9f0810dd2c|us/en/osaka-region/osaka/restaurant/yoshiko|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:21.466Z
ve_9f48692e69|us/en/osaka-region/osaka/restaurant/sushi-murakami-jiro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:22.719Z
ve_9f5ec8d17f|us/en/tokyo-region/tokyo/restaurant/la-gloire-1218215|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:24.073Z
ve_9f61af1d63|us/en/kyoto-region/kyoto/restaurant/dodici|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:25.422Z
ve_9f685d756f|us/en/tokyo-region/tokyo/restaurant/sushi-tanaka|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:26.780Z
ve_9f7c0f8333|us/en/tokyo-region/tokyo/restaurant/ramenya-toy-box|¥|CAT_P01|bib|jp|2026-10-30T07:26:28.123Z
ve_9f840cb8f6|us/en/tokyo-region/tokyo/restaurant/lien|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:29.486Z
ve_a026a001d5|us/en/kyoto-region/kyoto/restaurant/kodaiji-wakuden|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:26:30.825Z
ve_a02e6600ed|us/en/tokyo-region/tokyo/restaurant/teuchi-asama|¥|CAT_P01|bib|jp|2026-10-30T07:26:32.170Z
ve_a091613af6|us/en/kyoto-region/kyoto/restaurant/gokomachi-tagawa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:33.506Z
ve_a0b46a014e|us/en/kyoto-region/kyoto/restaurant/kinobu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:34.837Z
ve_a17af50aab|us/en/tokyo-region/tokyo/restaurant/koshikiryori-koki|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:36.202Z
ve_a183c8d745|us/en/tokyo-region/tokyo/restaurant/l-argent|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:37.538Z
ve_a18aa57c9a|us/en/tokyo-region/tokyo/restaurant/jizozushi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:38.870Z
ve_a201cd49ee|us/en/osaka-region/osaka/restaurant/oimatsu-kitagawa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:40.219Z
ve_a20648e454|us/en/tokyo-region/tokyo/restaurant/wokotote|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:41.553Z
ve_a22f0d5ca3|us/en/kyoto-region/kyoto/restaurant/tsujifusa|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:42.897Z
ve_a2851e9995|us/en/nara-region/nara/restaurant/le-content|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:44.235Z
ve_a36203d5fe|us/en/tokyo-region/tokyo/restaurant/yakumo-uezu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:45.584Z
ve_a38eb90da3|us/en/tokyo-region/tokyo/restaurant/est|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:46.920Z
ve_a3b6d23b94|us/en/kyoto-region/kyoto/restaurant/sambongi-shoten|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:48.274Z
ve_a428f842ed|us/en/tokyo-region/tokyo/restaurant/l-affinage|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:26:49.620Z
ve_a44c306b74|us/en/tokyo-region/tokyo/restaurant/hoppers-1206470|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:50.962Z
ve_a468cb68fa|us/en/nara-region/nara/restaurant/tori-yamaguchi|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:52.315Z
ve_a478821022|us/en/tokyo-region/tokyo/restaurant/tempura-ginya|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:53.671Z
ve_a4ad8057f1|us/en/tokyo-region/tokyo/restaurant/apotheose|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:55.010Z
ve_a4ccfe8a03|us/en/kyoto-region/kyoto/restaurant/lurra˚|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:26:56.357Z
ve_a5480a374b|us/en/tokyo-region/tokyo/restaurant/le-nougat|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:57.714Z
ve_a58a80365b|us/en/tokyo-region/tokyo/restaurant/yaesu-unagi-hashimoto|¥¥|CAT_P02|bib|jp|2026-10-30T07:26:59.062Z
ve_a59a2ff126|us/en/tokyo-region/tokyo/restaurant/sushi-hashimoto|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:00.398Z
ve_a5be2a7631|us/en/tokyo-region/tokyo/restaurant/heritage-by-kei-kobayashi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:01.754Z
ve_a610874feb|us/en/kyoto-region/kyoto/restaurant/ogawa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:03.101Z
ve_a619e82279|us/en/tokyo-region/tokyo/restaurant/hibino-chukashokudo|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:04.427Z
ve_a681e2656f|us/en/tokyo-region/tokyo/restaurant/tour-d-argent-1194082|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:05.767Z
ve_a6d7edffb1|us/en/tokyo-region/tokyo/restaurant/mutsukari|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:07.092Z
ve_a75312d4a4|us/en/osaka-region/osaka/restaurant/ichiju-nisai-ueno-minoten|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:08.497Z
ve_a7814f101f|us/en/osaka-region/osaka/restaurant/ramen-hayato|¥|CAT_P01|bib|jp|2026-10-30T07:27:09.819Z
ve_a7c0f9c0ad|us/en/tokyo-region/tokyo/restaurant/meishan|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:11.154Z
ve_a8218c6356|us/en/tokyo-region/tokyo/restaurant/nabeno-ism|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:12.487Z
ve_a835c5c0a7|us/en/kyoto-region/kyoto/restaurant/ryoriya-otaya|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:13.823Z
ve_a844d90911|us/en/tokyo-region/tokyo/restaurant/kappo-muroi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:15.172Z
ve_a8657ba3f1|us/en/tokyo-region/tokyo/restaurant/narisawa|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:27:16.514Z
ve_a8dff37cee|us/en/osaka-region/osaka/restaurant/chukasoba-uemachi|¥|CAT_P01|bib|jp|2026-10-30T07:27:17.863Z
ve_a92073cc52|us/en/kyoto-region/kyoto/restaurant/choshoku-kishin|¥|CAT_P01|bib|jp|2026-10-30T07:27:19.193Z
ve_a92a6007b8|us/en/kyoto-region/kyoto/restaurant/isshisoden-nakamura|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:27:20.538Z
ve_a930f04a4c|us/en/osaka-region/osaka/restaurant/mendokoro-subete|¥|CAT_P01|bib|jp|2026-10-30T07:27:21.886Z
ve_aa22b5b234|us/en/kyoto-region/kyoto/restaurant/hyotei|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:27:23.260Z
ve_aa8dbfb40e|us/en/tokyo-region/tokyo/restaurant/edosoba-hosokawa|¥|CAT_P01|bib|jp|2026-10-30T07:27:24.596Z
ve_aa911be50c|us/en/osaka-region/osaka/restaurant/macauda|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:25.942Z
ve_ab7af1e163|us/en/osaka-region/osaka/restaurant/sushidokoro-amano|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:27.279Z
ve_aba2335682|us/en/osaka-region/osaka/restaurant/tempura-kozaki|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:28.605Z
ve_abe53da98d|us/en/tokyo-region/tokyo/restaurant/watabe|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:29.963Z
ve_ac328eb134|us/en/osaka-region/osaka/restaurant/p-greco|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:31.299Z
ve_acc33cb5a9|us/en/kyoto-region/kyoto/restaurant/shichiku-kiko|¥¥|CAT_P02|bib|jp|2026-10-30T07:27:32.664Z
ve_ad66bf6c44|us/en/osaka-region/osaka/restaurant/agnel-d-or|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:34.013Z
ve_af90655f71|us/en/kyoto-region/kyoto/restaurant/izuu|¥|CAT_P01|bib|jp|2026-10-30T07:27:35.370Z
ve_afb506fe0a|us/en/tokyo-region/tokyo/restaurant/tempura-kakiage-yukimura|¥|CAT_P01|bib|jp|2026-10-30T07:27:36.703Z
ve_b052738a53|us/en/tokyo-region/tokyo/restaurant/dominique-bouchet-1194086|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:38.035Z
ve_b06a0811a3|us/en/osaka-region/osaka/restaurant/la-baie|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:39.363Z
ve_b129b5c20e|us/en/tokyo-region/tokyo/restaurant/ren-mishina|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:40.696Z
ve_b2a9c5dd98|us/en/tokyo-region/tokyo/restaurant/tempura-miyashiro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:42.039Z
ve_b2d49bd3e2|us/en/osaka-region/osaka/restaurant/alarde|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:43.390Z
ve_b304753456|us/en/tokyo-region/tokyo/restaurant/maerge|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:44.746Z
ve_b3343819b0|us/en/tokyo-region/tokyo/restaurant/iruca-tokyo|¥|CAT_P01|bib|jp|2026-10-30T07:27:46.074Z
ve_b3a910372f|us/en/tokyo-region/tokyo/restaurant/ryugin-1194232|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:27:47.429Z
ve_b3fa3db8ee|us/en/tokyo-region/tokyo/restaurant/harutaka|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:27:48.772Z
ve_b415a07c45|us/en/tokyo-region/tokyo/restaurant/sushi-miura|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:50.106Z
ve_b41a81d92d|us/en/tokyo-region/tokyo/restaurant/biriyani-osawa|¥|CAT_P01|bib|jp|2026-10-30T07:27:51.459Z
ve_b428886c60|us/en/tokyo-region/tokyo/restaurant/sushi-ichijo|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:52.800Z
ve_b45a2766ee|us/en/tokyo-region/tokyo/restaurant/takumi-tatsuhiro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:27:54.124Z
ve_b488191349|us/en/tokyo-region/tokyo/restaurant/hortensia|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:55.464Z
ve_b4b70eeb1f|us/en/osaka-region/osaka/restaurant/yakitori-torisen|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:56.810Z
ve_b4caa0629a|us/en/tokyo-region/tokyo/restaurant/florilege|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:27:58.146Z
ve_b58e420a30|us/en/kyoto-region/kyoto/restaurant/noguchi-tsunagu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:27:59.475Z
ve_b5e228696f|us/en/osaka-region/osaka/restaurant/tanpopo|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:00.802Z
ve_b650db8176|us/en/kyoto-region/kyoto/restaurant/manjuji-hakuran|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:02.120Z
ve_b6b92bad9c|us/en/kyoto-region/kyoto/restaurant/canton-shunsai-ikki|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:03.472Z
ve_b8de11fc52|us/en/osaka-region/osaka/restaurant/nishishinsaibashi-yuno|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:04.837Z
ve_b93083694c|us/en/tokyo-region/tokyo/restaurant/ensui|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:28:06.173Z
ve_b9712f0468|us/en/tokyo-region/tokyo/restaurant/shokuzen-abe|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:07.501Z
ve_b9c32ddde1|us/en/tokyo-region/tokyo/restaurant/gucci-osteria-da-massimo-bottura-1201836|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:08.830Z
ve_b9fc233945|us/en/tokyo-region/tokyo/restaurant/yakitori-takahashi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:10.173Z
ve_ba30fe8b31|us/en/tokyo-region/tokyo/restaurant/la-paix-1194221|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:11.560Z
ve_ba96015edf|us/en/tokyo-region/tokyo/restaurant/ginza-katsukami-ii|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:12.906Z
ve_bab8d84fe2|us/en/tokyo-region/tokyo/restaurant/shigeyuki|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:14.154Z
ve_bb2519bf19|us/en/tokyo-region/tokyo/restaurant/ewig|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:15.487Z
ve_bb55f9386a|us/en/kyoto-region/kyoto/restaurant/enyuan-kobayashi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:28:16.822Z
ve_bbd64ac805|us/en/kyoto-region/kyoto/restaurant/sojiki-nakahigashi|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:28:19.429Z
ve_bd624f4dc3|us/en/tokyo-region/tokyo/restaurant/arroceria-sal-y-amor|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:20.758Z
ve_bd6e9bb505|us/en/osaka-region/osaka/restaurant/donostia-1193223|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:22.103Z
ve_be2932ad48|us/en/tokyo-region/tokyo/restaurant/edomae-sushi-hanabusa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:28:23.439Z
ve_bf247e78e6|us/en/kyoto-region/kyoto/restaurant/korisu|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:24.769Z
ve_bfbe253c73|us/en/nara-region/nara/restaurant/a-plus|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:26.110Z
ve_c0676be22f|us/en/osaka-region/osaka/restaurant/numata|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:28:27.429Z
ve_c08f465911|us/en/osaka-region/osaka/restaurant/oimatsu-hisano|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:28:28.781Z
ve_c0b15d11a6|us/en/tokyo-region/tokyo/restaurant/piao-xiang|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:30.139Z
ve_c0eba7ae71|us/en/nara-region/nara/restaurant/naramachi-kuko|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:31.471Z
ve_c24f570ba1|us/en/osaka-region/osaka/restaurant/kyomachibori-nakamura|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:32.814Z
ve_c272fb2453|us/en/tokyo-region/tokyo/restaurant/bramasole|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:34.141Z
ve_c2bd60fcc3|us/en/tokyo-region/tokyo/restaurant/seizan|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:28:35.469Z
ve_c3309b0314|us/en/osaka-region/osaka/restaurant/ryoriya-inaya|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:28:36.800Z
ve_c41a9f1b06|us/en/osaka-region/osaka/restaurant/kaishoku-shimizu|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:38.148Z
ve_c4682579b3|us/en/tokyo-region/tokyo/restaurant/mejiro-zorome|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:39.400Z
ve_c4b29728ba|us/en/osaka-region/osaka/restaurant/aozora-blue|¥|CAT_P01|bib|jp|2026-10-30T07:28:40.735Z
ve_c4fcbee41b|us/en/kyoto-region/kyoto/restaurant/juu-go|¥|CAT_P01|bib|jp|2026-10-30T07:28:42.061Z
ve_c52edca512|us/en/tokyo-region/tokyo/restaurant/saucer|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:43.389Z
ve_c5e1936ab5|us/en/nara-region/nara/restaurant/sen-1218506|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:44.777Z
ve_c67f088ee9|us/en/tokyo-region/tokyo/restaurant/le-bistrot-des-bleus|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:46.089Z
ve_c6d37c2ca6|us/en/kyoto-region/kyoto/restaurant/bistro-cerisier|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:47.416Z
ve_c7e7577ef8|us/en/tokyo-region/tokyo/restaurant/crony-1194937|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:28:48.739Z
ve_c7fe6633c2|us/en/nara-region/nara/restaurant/yamaoka-pizza|¥|CAT_P01|bib|jp|2026-10-30T07:28:50.073Z
ve_c7fe830435|us/en/osaka-region/osaka/restaurant/sakamoto-sushi|¥¥¥|CAT_P03|bib|jp|2026-10-30T07:28:51.395Z
ve_c8c6cb35da|us/en/osaka-region/osaka/restaurant/yugen-1193266|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:28:52.723Z
ve_c9ed078ab1|us/en/tokyo-region/tokyo/restaurant/ponta-honke|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:54.050Z
ve_c9f749f049|us/en/osaka-region/osaka/restaurant/kushingarando|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:28:55.381Z
ve_ca14dd4bd6|us/en/tokyo-region/tokyo/restaurant/ubuka|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:28:56.717Z
ve_ca8543ec8e|us/en/osaka-region/osaka/restaurant/osteria-la-cicerchia|¥¥|CAT_P02|bib|jp|2026-10-30T07:28:58.069Z
ve_caf9868dd5|us/en/kyoto-region/kyoto/restaurant/higashiyama-tsukasa|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:28:59.411Z
ve_cb4fd18f7c|us/en/tokyo-region/tokyo/restaurant/torakuro|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:29:00.758Z
ve_cbcc9ce0f2|us/en/kyoto-region/kyoto/restaurant/anpeiji|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:02.084Z
ve_cc076f2eb5|us/en/osaka-region/osaka/restaurant/chukasoba-mugen|¥|CAT_P01|bib|jp|2026-10-30T07:29:03.411Z
ve_cc4afb1b4a|us/en/tokyo-region/tokyo/restaurant/soba-osame|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:04.755Z
ve_cca8bba662|us/en/tokyo-region/tokyo/restaurant/kioicho-fukudaya|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:29:06.080Z
ve_ccea42e79e|us/en/osaka-region/osaka/restaurant/rooots-nakanoshima|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:07.429Z
ve_cd4cdf5953|us/en/tokyo-region/tokyo/restaurant/gigio|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:08.774Z
ve_ce2bc1a91d|us/en/kyoto-region/kyoto/restaurant/shimmonzen-yonemura|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:10.117Z
ve_ceb42cf754|us/en/osaka-region/osaka/restaurant/a-canto|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:11.480Z
ve_cf1874968b|us/en/osaka-region/osaka/restaurant/pierre-1193242|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:12.837Z
ve_cf97942f07|us/en/tokyo-region/tokyo/restaurant/yakitori-abe|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:14.189Z
ve_d0a8ad4cd5|us/en/tokyo-region/tokyo/restaurant/yakumo|¥|CAT_P01|bib|jp|2026-10-30T07:29:15.522Z
ve_d11dd2956c|us/en/osaka-region/osaka/restaurant/tonkatsu-katsu-hana|¥|CAT_P01|bib|jp|2026-10-30T07:29:16.870Z
ve_d16f623333|us/en/kyoto-region/kyoto/restaurant/miyagawacho-hotta|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:18.201Z
ve_d25edda09c|us/en/kyoto-region/kyoto/restaurant/muromachi-kaji|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:19.535Z
ve_d282fc4f58|us/en/tokyo-region/tokyo/restaurant/esquisse|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:29:20.866Z
ve_d40c0bd9a7|us/en/osaka-region/osaka/restaurant/koryu|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:29:22.222Z
ve_d416ed4909|us/en/kyoto-region/kyoto/restaurant/sushi-matsumoto|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:23.569Z
ve_d5e4f613a2|us/en/tokyo-region/tokyo/restaurant/cycle-by-mauro-colagreco|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:29:24.901Z
ve_d5e8a793dc|us/en/kyoto-region/kyoto/restaurant/asperge-blanche|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:26.251Z
ve_d6fdeb37d3|us/en/kyoto-region/kyoto/restaurant/kodaiji-jugyuan|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:29:27.598Z
ve_d8140bc55d|us/en/osaka-region/osaka/restaurant/la-bonne-tache|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:28.945Z
ve_d840c4c6d7|us/en/osaka-region/osaka/restaurant/kamigatachuka-shintani|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:30.286Z
ve_d8e1332f00|us/en/tokyo-region/tokyo/restaurant/torishige|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:31.638Z
ve_d93f1a17e5|us/en/tokyo-region/tokyo/restaurant/yoshoku-edoya|¥|CAT_P01|bib|jp|2026-10-30T07:29:32.978Z
ve_d9f20852fc|us/en/tokyo-region/tokyo/restaurant/l-eterre|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:29:34.308Z
ve_db529201bd|us/en/kyoto-region/kyoto/restaurant/oryori-mashita|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:35.643Z
ve_db7ab990c5|us/en/osaka-region/osaka/restaurant/difference|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:36.997Z
ve_dcd72a2523|us/en/tokyo-region/tokyo/restaurant/osobano-kouga|¥|CAT_P01|bib|jp|2026-10-30T07:29:38.343Z
ve_dd43c3f8db|us/en/tokyo-region/tokyo/restaurant/ginza-kousui|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:29:39.687Z
ve_dd95ad4d23|us/en/kyoto-region/kyoto/restaurant/kyogoku-kaneyo|¥|CAT_P01|bib|jp|2026-10-30T07:29:41.028Z
ve_dddfe1a4e3|us/en/kyoto-region/kyoto/restaurant/kanesho|¥|CAT_P01|bib|jp|2026-10-30T07:29:42.375Z
ve_dde3200388|us/en/osaka-region/osaka/restaurant/sui-oya|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:43.704Z
ve_de7e4dc0fe|us/en/kyoto-region/kyoto/restaurant/bistro-yanagihara|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:45.039Z
ve_debbbeb7e6|us/en/kyoto-region/kyoto/restaurant/kako-okamoto|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:46.387Z
ve_df282c7523|us/en/tokyo-region/tokyo/restaurant/kanda|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:29:47.723Z
ve_df3846fc23|us/en/tokyo-region/tokyo/restaurant/t-astous|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:49.056Z
ve_e033f957bd|us/en/osaka-region/osaka/restaurant/kushikatsu-gojoya|¥|CAT_P01|bib|jp|2026-10-30T07:29:50.383Z
ve_e0c755ed9c|us/en/osaka-region/osaka/restaurant/sinae|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:51.715Z
ve_e0dfaa8a0d|us/en/kyoto-region/kyoto/restaurant/nijo-minami|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:53.047Z
ve_e12193f13b|us/en/osaka-region/osaka/restaurant/kashiwaya-osaka-kitashinchi|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:29:54.429Z
ve_e1dd901f4b|us/en/tokyo-region/tokyo/restaurant/guchokuni|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:29:55.751Z
ve_e297b6b395|us/en/tokyo-region/tokyo/restaurant/tachigui-sushi-tonari|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:57.092Z
ve_e2986a8431|us/en/tokyo-region/tokyo/restaurant/sennomago|¥¥|CAT_P02|bib|jp|2026-10-30T07:29:58.427Z
ve_e2d7695d51|us/en/kyoto-region/kyoto/restaurant/mube|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:29:59.756Z
ve_e3c75d550f|us/en/kyoto-region/kyoto/restaurant/muginoyoake|¥|CAT_P01|bib|jp|2026-10-30T07:30:01.100Z
ve_e42c6c66a7|us/en/kyoto-region/kyoto/restaurant/higashiyama-ogata|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:02.429Z
ve_e492bf2a18|us/en/kyoto-region/kyoto/restaurant/korean-restaurant-byeoleeya|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:03.781Z
ve_e4a08ae33f|us/en/kyoto-region/kyoto/restaurant/shiro-1215790|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:05.117Z
ve_e4a3898964|us/en/tokyo-region/tokyo/restaurant/sorahana|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:06.465Z
ve_e51cd0572c|us/en/tokyo-region/tokyo/restaurant/ma-cuisine-1194175|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:07.811Z
ve_e52e6620cb|us/en/osaka-region/osaka/restaurant/kashiwaya-osaka-senriyama|¥¥¥|CAT_P03|3 star|jp|2026-10-30T07:30:09.150Z
ve_e59072066e|us/en/kyoto-region/kyoto/restaurant/la-biographie|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:10.476Z
ve_e5a5ea255c|us/en/tokyo-region/tokyo/restaurant/les-six|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:11.820Z
ve_e5ba1be631|us/en/tokyo-region/tokyo/restaurant/sushi-kojima|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:13.162Z
ve_e7c08dffe1|us/en/osaka-region/osaka/restaurant/sobakiri-karani|¥|CAT_P01|bib|jp|2026-10-30T07:30:14.493Z
ve_e8797214ef|us/en/tokyo-region/tokyo/restaurant/miyasaka|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:15.856Z
ve_e98c089c67|us/en/tokyo-region/tokyo/restaurant/tonkatsu-hinata|¥|CAT_P01|bib|jp|2026-10-30T07:30:17.202Z
ve_e9c02f6955|us/en/tokyo-region/tokyo/restaurant/shutei-tanaka|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:18.533Z
ve_ea5494c6e5|us/en/tokyo-region/tokyo/restaurant/trattoria-buca-massimo|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:19.876Z
ve_ea699830d5|us/en/tokyo-region/tokyo/restaurant/koryori-kuhara|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:21.215Z
ve_ea74528979|us/en/osaka-region/osaka/restaurant/iwaki|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:22.542Z
ve_ebb1e229ab|us/en/kyoto-region/kyoto/restaurant/la-buche|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:23.883Z
ve_ec860811a8|us/en/tokyo-region/tokyo/restaurant/yotsuya-minemura|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:25.207Z
ve_eca3f99567|us/en/tokyo-region/tokyo/restaurant/lanbroa|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:26.536Z
ve_ed52c66bde|us/en/osaka-region/osaka/restaurant/nikomi-kimura|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:27.930Z
ve_edb3774188|us/en/tokyo-region/tokyo/restaurant/seisoka|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:29.270Z
ve_edda0d770f|us/en/tokyo-region/tokyo/restaurant/nishiazabu-taku|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:30.624Z
ve_ee035a63f6|us/en/kyoto-region/kyoto/restaurant/washoku-haru|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:31.964Z
ve_ee13fbdff8|us/en/tokyo-region/tokyo/restaurant/shimbashi-sasada|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:33.329Z
ve_ef7686f705|us/en/kyoto-region/kyoto/restaurant/noodle-shop-rennosuke|¥|CAT_P01|bib|jp|2026-10-30T07:30:34.681Z
ve_efda18ba60|us/en/tokyo-region/tokyo/restaurant/manoir|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:36.027Z
ve_f08a7f3e3e|us/en/osaka-region/osaka/restaurant/hajime|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:30:37.368Z
ve_f0d446a0ce|us/en/osaka-region/osaka/restaurant/sobakiri-gaku|¥|CAT_P01|bib|jp|2026-10-30T07:30:38.712Z
ve_f1c98fa936|us/en/tokyo-region/tokyo/restaurant/les-copains-de-dominique-bouchet|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:40.045Z
ve_f1cbfcaf7b|us/en/tokyo-region/tokyo/restaurant/kinoshita-1197753|¥¥|CAT_P02|bib|jp|2026-10-30T07:30:41.375Z
ve_f1defd77a3|us/en/nara-region/nara/restaurant/sushi-kawashima|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:42.719Z
ve_f2dd90a146|us/en/tokyo-region/tokyo/restaurant/ramen-matsui|¥|CAT_P01|bib|jp|2026-10-30T07:30:44.060Z
ve_f3381acae9|us/en/kyoto-region/kyoto/restaurant/gion-okada|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:45.399Z
ve_f343a6d543|us/en/tokyo-region/tokyo/restaurant/les-saisons-1194250|¥¥¥¥|CAT_P04|1 star|jp|2026-10-30T07:30:46.733Z
ve_f36f372e39|us/en/tokyo-region/tokyo/restaurant/kyorakutei|¥|CAT_P01|bib|jp|2026-10-30T07:30:48.069Z
ve_f39a5bfa2e|us/en/kyoto-region/kyoto/restaurant/kappo-hassun|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:49.413Z
ve_f3d4836d3e|us/en/tokyo-region/tokyo/restaurant/nol|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:50.747Z
ve_f63e3acb53|us/en/kyoto-region/kyoto/restaurant/kikunoi-honten|¥¥¥¥|CAT_P04|3 star|jp|2026-10-30T07:30:52.075Z
ve_f662817abc|us/en/tokyo-region/tokyo/restaurant/sushidokoro-kiraku|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:53.408Z
ve_f6fe97d98a|us/en/osaka-region/osaka/restaurant/tenjimbashi-aoki|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:30:54.748Z
ve_f70f6c6e59|us/en/tokyo-region/tokyo/restaurant/il-ristorante-niko-romito-1208307|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:56.090Z
ve_f714c96944|us/en/nara-region/nara/restaurant/akordu|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:30:57.440Z
ve_f73fc8c5b9|us/en/tokyo-region/tokyo/restaurant/l-elan|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:30:58.785Z
ve_f7af020b45|us/en/kyoto-region/kyoto/restaurant/gion-matayoshi|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:31:00.120Z
ve_f7f53488ea|us/en/tokyo-region/tokyo/restaurant/hashimoto|¥|CAT_P01|bib|jp|2026-10-30T07:31:01.462Z
ve_f99fafc294|us/en/tokyo-region/tokyo/restaurant/oku|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:31:02.816Z
ve_f9b5a7c265|us/en/tokyo-region/tokyo/restaurant/chukasoba-ginza-hachigo|¥|CAT_P01|bib|jp|2026-10-30T07:31:04.158Z
ve_f9ed2c8729|us/en/tokyo-region/tokyo/restaurant/yakitori-sanka|¥¥|CAT_P02|bib|jp|2026-10-30T07:31:05.510Z
ve_fa184cf626|us/en/tokyo-region/tokyo/restaurant/ten-yokota|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:31:06.840Z
ve_fad6b2e87b|us/en/kyoto-region/kyoto/restaurant/wagokoro-izumi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:31:08.171Z
ve_fb2e45b8f4|us/en/tokyo-region/tokyo/restaurant/tempura-kondo|¥¥¥|CAT_P03|2 star|jp|2026-10-30T07:31:09.508Z
ve_fb4a45b6d2|us/en/osaka-region/osaka/restaurant/la-becasse-1193280|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:31:10.850Z
ve_fcd6e9b961|us/en/tokyo-region/tokyo/restaurant/kyobashi-tempura-fukamachi|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:31:12.175Z
ve_fcf29fc52b|us/en/nara-region/nara/restaurant/kaiseki-morimoto|¥¥¥|CAT_P03|1 star|jp|2026-10-30T07:31:13.524Z
ve_fd61eb9e95|us/en/osaka-region/osaka/restaurant/sobakiri-arabompu|¥|CAT_P01|bib|jp|2026-10-30T07:31:14.871Z
ve_fdd4c0d652|us/en/tokyo-region/tokyo/restaurant/teuchisoba-jiyusan|¥¥|CAT_P02|bib|jp|2026-10-30T07:31:16.241Z
ve_fdea70bea1|us/en/tokyo-region/tokyo/restaurant/ginza-koju|¥¥¥¥|CAT_P04|2 star|jp|2026-10-30T07:31:17.573Z
ve_ffca00f08e|us/en/tokyo-region/tokyo/restaurant/la-bettola-da-ochiai|¥¥|CAT_P02|bib|jp|2026-10-30T07:31:18.908Z$r$;
  rel jsonb;
  n_exp int := 566;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count before is not 7582'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 143 THEN RAISE EXCEPTION 'ledger max before is not 143'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 115494 THEN RAISE EXCEPTION 'audit max before is not 115494'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> 'd5c8ff329cc599b7a3e9123ff0024f7529434f1436f18ceab6495a49a275a99d' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  -- relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'source_url', 'https://guide.michelin.com/' || f[2], 'symbol_raw', f[3],
           'currency', CASE f[6] WHEN 'us' THEN 'USD' WHEN 'cn' THEN 'CNY' WHEN 'tw' THEN 'TWD' WHEN 'jp' THEN 'JPY' WHEN 'kr' THEN 'KRW' WHEN 'gb' THEN 'GBP' WHEN 'fr' THEN 'EUR' WHEN 'de' THEN 'EUR' WHEN 'it' THEN 'EUR' WHEN 'nl' THEN 'EUR' WHEN 'es' THEN 'EUR' WHEN 'be' THEN 'EUR' WHEN 'mc' THEN 'EUR' WHEN 'ie' THEN 'EUR' WHEN 'lu' THEN 'EUR' WHEN 'ad' THEN 'EUR' END,
           'tier', char_length(f[3]), 'captured_at', f[7]) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 7 OR f[4] <> 'CAT_P0' || char_length(f[3])
                            OR char_length(f[3]) NOT BETWEEN 1 AND 4
                            OR f[3] <> repeat(left(f[3], 1), char_length(f[3])))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(symbol_raw text, currency text)
              WHERE x.currency IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'TWD' THEN '$' WHEN 'CNY' THEN '¥'
                                              WHEN 'JPY' THEN '¥' WHEN 'KRW' THEN '₩' WHEN 'GBP' THEN '£' WHEN 'EUR' THEN '€' END)
    THEN RAISE EXCEPTION 'symbol does not match currency'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.source_url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier||'|'||x.captured_at,
                        E'\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text);
  IF v_fp <> '8ba34f2c348892115c457b6aa090c45e' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '1946c6d9b0f1819dfc40620360d34612' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows: the legacy price rows of the relay venues, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '82320598e849ac3b78466c3123a2a23a' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;

  -- each row: venue active; legacy price row with no URL; card URL = latest Michelin star/Bib card URL of the venue
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL)
      OR x.source_url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\.michelin\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows outside P2 or URL changed: %', v_bad; END IF;

  UPDATE price p
     SET tier = x.tier::smallint, symbol_raw = x.symbol_raw, currency = x.currency, source = 'guide_ingest',
         method = 'published_symbol', publisher = 'michelin', source_url = x.source_url,
         captured_at = x.captured_at::timestamptz, confidence = NULL
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text)
   WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', n_exp,
          'price-card:price-michelin-card-p2-b4-2026-10-30 | block A step 2 batch 4 (Japan, 568 venues): legacy price rows with no URL, active Michelin star/Bib venues with a card URL | '
          || n_exp || ' rows updated from legacy (JPY 566) | live card read, built-in browser | relay md5 8ba34f2c348892115c457b6aa090c45e')
  RETURNING id INTO v_lid;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid <> 144 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 115494) <> n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 115494 AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit price UPDATE rows'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text)
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.source_url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> n_exp
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
END
$do$;
COMMIT;
