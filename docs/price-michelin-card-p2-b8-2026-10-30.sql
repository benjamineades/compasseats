-- price-michelin-card-p2-b8-2026-10-30.sql
-- Block A, step 2, batch 8 (China + Taiwan, 457 venues).
-- Population P2: active venues with a Michelin One Star, Two Stars, Three Stars or Bib Gourmand row whose source_url is
-- a guide.michelin.com card URL (latest by year desc, id desc), and a price row with source legacy_guide and no source_url.
-- Source: the live Michelin card page (Price: line, data-sheet), read in the built-in browser.
-- Rows: 455 UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
-- source_url = card URL, symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
-- captured_at = read time). Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026).
-- Cards that show Selected only are also updated; award rows do not change (Ben, Oct 30, 2026; Oct 10 ruling).
-- Currencies: CNY 316, TWD 139. Card tiers: 1 = 173, 2 = 163, 3 = 60, 4 = 59. Card distinction: 1 star 104, 2 star 26, 3 star 6, bib 319.
-- Relay sha256 5a7840c23535d80c06f1a220a86ed7d30e6e63b434a1c2c2f74cd9e81bce5948 (inside this file).
-- Guards: counts before (price 7582, ledger max 147, audit max 117344); relay fingerprint md5
-- d6b7ca00b59b46025dda673c6e4547ef; venue id md5 9e3543f58a6207673ed65d955a61abc2; old price rows md5 2b5e68dd641233908e58153ab8ab44be;
-- each row in P2 now with the same card URL.
-- Post-checks: price count 7582 (unchanged); ledger 148; audit 455 price UPDATE rows, nothing else;
-- each price row now matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_00c898a89c|us/en/guangdong-province/guangzhou/restaurant/hua-ge-si-chu|¥|CAT_P01|bib|cn|2026-10-30T15:11:51Z
ve_015c3461ad|us/en/fujian-province/xiamen_1031934/restaurant/chic-1699-1213633|¥¥|CAT_P02|bib|cn|2026-10-30T15:11:52Z
ve_01b7949aea|us/en/jiang-su/yangzhou_1032329/restaurant/liuyuanchun-teahouse|¥|CAT_P01|bib|cn|2026-10-30T15:11:54Z
ve_024fc869a8|us/en/taipei-region/taipei/restaurant/wok-by-o-bond|$$$|CAT_P03|1 star|tw|2026-10-30T15:11:55Z
ve_025cd433e8|us/en/beijing-municipality/beijing/restaurant/xiang-bin-xuan-huayuan-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:11:56Z
ve_027040b69f|us/en/zhe-jiang/hangzhou_1027184/restaurant/er-ba-jiu-su-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:11:58Z
ve_0275d5b5aa|us/en/taipei-region/taipei/restaurant/huang-chi-lu-rou-fan|$|CAT_P01|bib|tw|2026-10-30T15:11:59Z
ve_02939d941a|us/en/guangdong-province/guangzhou/restaurant/hai-men-yu-zi-dian-yanling-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:00Z
ve_0350f6581d|us/en/taipei-region/taipei/restaurant/clavius|$$|CAT_P02|bib|tw|2026-10-30T15:12:02Z
ve_03d9d02d43|us/en/taichung-region/taichung/restaurant/feng-chi-goose|$$|CAT_P02|bib|tw|2026-10-30T15:12:03Z
ve_0460a32c7d|us/en/shanghai-municipality/shanghai/restaurant/cong-s-kitchen|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:04Z
ve_054d080ebd|us/en/kaohsiung-region/kaohsiung/restaurant/chao-ming|$$|CAT_P02|bib|tw|2026-10-30T15:12:06Z
ve_05b64d0d3b|us/en/tainan-region/tainan/restaurant/a-hsing-congee|$|CAT_P01|bib|tw|2026-10-30T15:12:07Z
ve_06e033a0b9|us/en/taichung-region/taichung/restaurant/sur|$$$|CAT_P03|1 star|tw|2026-10-30T15:12:08Z
ve_075467c543|us/en/kaohsiung-region/kaohsiung/restaurant/hu-dong-beef|$$|CAT_P02|bib|tw|2026-10-30T15:12:10Z
ve_09774c4bd0|us/en/kaohsiung-region/kaohsiung/restaurant/yang-bao-bao-nanzih|$|CAT_P01|bib|tw|2026-10-30T15:12:11Z
ve_0b0173ebae|us/en/beijing-municipality/beijing/restaurant/qiantang-garden|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:12Z
ve_0b942c3ee4|us/en/zhe-jiang/hangzhou_1027184/restaurant/wu-zi-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:12:14Z
ve_0ba160383c|us/en/fujian-province/quanzhou_1030272/restaurant/che-qiao-tou-wen-a-shui-wan-daxi-street|¥|CAT_P01|bib|cn|2026-10-30T15:12:15Z
ve_0bc5323db1|us/en/shanghai-municipality/shanghai/restaurant/yunhe-noodle-huangpu|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:16Z
ve_0bc92c27fb|us/en/taipei-region/taipei/restaurant/hsiung-chi-scallion-pancake|$|CAT_P01|bib|tw|2026-10-30T15:12:18Z
ve_0cae22406b|us/en/tainan-region/tainan/restaurant/eat-to-fat|$$|CAT_P02|bib|tw|2026-10-30T15:12:19Z
ve_0cf7c0fc2d|us/en/jiang-su/yangzhou_1032329/restaurant/cai-gen-xiang-xiao-guan|¥|CAT_P01|bib|cn|2026-10-30T15:12:20Z
ve_0d3c59fe15|us/en/taipei-region/taipei/restaurant/inn-s|$$|CAT_P02|bib|tw|2026-10-30T15:12:22Z
ve_0d894398dc|us/en/kaohsiung-region/kaohsiung/restaurant/haili|$$$|CAT_P03|1 star|tw|2026-10-30T15:12:23Z
ve_0e059a0bed|us/en/taichung-region/taichung/restaurant/niou-jia-juang|$$|CAT_P02|bib|tw|2026-10-30T15:12:24Z
ve_0e534fbaaf|us/en/guangdong-province/guangzhou/restaurant/ease-yuexiu|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:26Z
ve_0e814ced6c|us/en/taipei-region/taipei/restaurant/shuang-yue-food|$$|CAT_P02|bib|tw|2026-10-30T15:12:27Z
ve_0e8f46440b|us/en/jiang-su/nanjing_1029511/restaurant/xin-fang-yuan|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:28Z
ve_0ede725a20|us/en/jiang-su/nanjing_1029511/restaurant/xiao-pan-ji-ya-xie-fen-si-tang|¥|CAT_P01|bib|cn|2026-10-30T15:12:30Z
ve_11145845a4|us/en/beijing-municipality/beijing/restaurant/zhiguan|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:12:31Z
ve_116a14d35a|us/en/zhe-jiang/taizhou_7770462/restaurant/hong-da-xing-li-fan-dian|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:32Z
ve_125d99aabc|us/en/tainan-region/tainan/restaurant/san-hao-yi-kung-tao-angelica-duck|$|CAT_P01|bib|tw|2026-10-30T15:12:34Z
ve_1262d6f013|us/en/guangdong-province/guangzhou/restaurant/jiang-by-chef-fei|¥¥¥|CAT_P03|2 star|cn|2026-10-30T15:12:35Z
ve_133ee0a10d|us/en/chengdu-municipality/chengdu/restaurant/mind|¥|CAT_P01|bib|cn|2026-10-30T15:12:36Z
ve_1488ed42ea|us/en/beijing-municipality/beijing/restaurant/hong-fan-qie-yuyuantan-south-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:38Z
ve_14ca1bc485|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/guang-xing-pork-knuckle|$|CAT_P01|bib|tw|2026-10-30T15:12:39Z
ve_14f90c6a05|us/en/guangdong-province/guangzhou/restaurant/rong-yi-fa-niu-za-dian-shishu-road|¥|CAT_P01|bib|cn|2026-10-30T15:12:40Z
ve_156612d964|us/en/zhe-jiang/taizhou_7770462/restaurant/guoping-seafood|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:42Z
ve_156a566ac2|us/en/zhe-jiang/taizhou_7770462/restaurant/yi-qin-shou-da-mian|¥|CAT_P01|bib|cn|2026-10-30T15:12:43Z
ve_15e08088e5|us/en/taipei-region/taipei/restaurant/pang|$$|CAT_P02|bib|tw|2026-10-30T15:12:44Z
ve_16aa1a89bc|us/en/shanghai-municipality/shanghai/restaurant/canton-table|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:12:46Z
ve_16b408725d|us/en/fujian-province/xiamen_1031934/restaurant/chen-xian-sen-sha-cha-mian|¥|CAT_P01|bib|cn|2026-10-30T15:12:47Z
ve_16e5a2e0f0|us/en/guangdong-province/guangzhou/restaurant/lao-xiguan-laifen-wenming-road|¥|CAT_P01|bib|cn|2026-10-30T15:12:48Z
ve_16e9923170|us/en/fujian-province/fuzhou_1026814/restaurant/mei-ya-bo-hua-sheng-tang|¥|CAT_P01|bib|cn|2026-10-30T15:12:50Z
ve_16ecb158f6|us/en/fujian-province/xiamen_1031934/restaurant/yue-hua-sha-cha-mian|¥|CAT_P01|bib|cn|2026-10-30T15:12:51Z
ve_16f13cb80f|us/en/shanghai-municipality/shanghai/restaurant/yongfu-mini|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:52Z
ve_182038319c|us/en/shanghai-municipality/shanghai/restaurant/da-dong-xuhui|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:12:54Z
ve_1907996693|us/en/guangdong-province/guangzhou/restaurant/xing-fu-yi-zhan|¥¥|CAT_P02|bib|cn|2026-10-30T15:12:55Z
ve_19227e10e5|us/en/taipei-region/taipei/restaurant/yi-jia-zi|$|CAT_P01|bib|tw|2026-10-30T15:12:56Z
ve_1971841503|us/en/taipei-region/taipei/restaurant/hang-zhou-xiao-long-bao-da-an|$$|CAT_P02|bib|tw|2026-10-30T15:12:58Z
ve_19a53314b7|us/en/taipei-region/taipei/restaurant/chung-chia-sheng-jian-bao|$|CAT_P01|bib|tw|2026-10-30T15:12:59Z
ve_19b20dfec4|us/en/jiang-su/changzhou_1025968/restaurant/tai-hu-san-bai-guan|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:01Z
ve_19c49ddd1f|us/en/fujian-province/xiamen_1031934/restaurant/lao-song-bian-shi-dian|¥|CAT_P01|bib|cn|2026-10-30T15:13:02Z
ve_1acc9ddd6e|us/en/guangdong-province/guangzhou/restaurant/chowa|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:13:03Z
ve_1af2a4131e|us/en/beijing-municipality/beijing/restaurant/mansion-cuisine-by-jingyan|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:13:05Z
ve_1afae7044e|us/en/jiang-su/changzhou_1025968/restaurant/sheng-xing-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:13:06Z
ve_1b2c03f776|us/en/guangdong-province/guangzhou/restaurant/chuang-fa|¥|CAT_P01|bib|cn|2026-10-30T15:13:07Z
ve_1b6f9b2bd8|us/en/kaohsiung-region/kaohsiung/restaurant/sho|$$$|CAT_P03|1 star|tw|2026-10-30T15:13:09Z
ve_1be97f049d|us/en/jiang-su/nanjing_1029511/restaurant/you-mian|¥|CAT_P01|bib|cn|2026-10-30T15:13:10Z
ve_1c6912f8ae|us/en/zhe-jiang/taizhou_7770462/restaurant/bei-men-niu-xie-geng|¥|CAT_P01|bib|cn|2026-10-30T15:13:11Z
ve_1cbfbbefdc|us/en/guangdong-province/guangzhou/restaurant/taste-soar-%C3%97-da-tou-hui|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:13Z
ve_1d76320fee|us/en/zhe-jiang/wenzhou_1031793/restaurant/he-jiu-jia|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:14Z
ve_1db6f458ea|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/song-jhao|$|CAT_P01|bib|tw|2026-10-30T15:13:15Z
ve_1dc8aff442|us/en/zhe-jiang/hangzhou_1027184/restaurant/hangzhou-house|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:13:17Z
ve_1e754d072b|us/en/tainan-region/tainan/restaurant/lo-cheng-migao|$|CAT_P01|bib|tw|2026-10-30T15:13:18Z
ve_1f01073866|us/en/jiang-su/nanjing_1029511/restaurant/li-ji-qing-zhen-guan|¥|CAT_P01|bib|cn|2026-10-30T15:13:19Z
ve_1f4aafb6c5|us/en/zhe-jiang/taizhou_7770462/restaurant/mr-liang-seafood|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:21Z
ve_1fe3d010a2|us/en/zhe-jiang/hangzhou_1027184/restaurant/xiao-lao-hun-tun|¥|CAT_P01|bib|cn|2026-10-30T15:13:22Z
ve_20233163d3|us/en/taipei-region/taipei/restaurant/din-tai-fung-xinyi-road|$$|CAT_P02|bib|tw|2026-10-30T15:13:23Z
ve_208a1abe67|us/en/chengdu-municipality/chengdu/restaurant/rongrong-beida-pugaimian|¥|CAT_P01|bib|cn|2026-10-30T15:13:25Z
ve_214cfada26|us/en/guangdong-province/guangzhou/restaurant/soodle-jinsui-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:26Z
ve_21a105d24a|us/en/northern-taiwan/hsinchu-city_2853126/restaurant/yuan-wei-duck-noodle|$|CAT_P01|bib|tw|2026-10-30T15:13:27Z
ve_220fd92029|us/en/zhe-jiang/taizhou_7770462/restaurant/lao-bian-jiu-jia-jindai-road|¥¥|CAT_P02|1 star|cn|2026-10-30T15:13:29Z
ve_221516babd|us/en/taipei-region/taipei/restaurant/mipon|$$|CAT_P02|1 star|tw|2026-10-30T15:13:30Z
ve_233a70ec6d|us/en/jiang-su/nanjing_1029511/restaurant/zheng-qing-niu-rou-guo-tie-dian|¥|CAT_P01|bib|cn|2026-10-30T15:13:31Z
ve_2368174d5b|us/en/jiang-su/yangzhou_1032329/restaurant/liu-she-ji|¥|CAT_P01|bib|cn|2026-10-30T15:13:33Z
ve_24de3005f6|us/en/beijing-municipality/beijing/restaurant/fu-chun-ju|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:13:34Z
ve_25f4d10415|us/en/taichung-region/taichung/restaurant/fu-kuei-ting|$|CAT_P01|bib|tw|2026-10-30T15:13:35Z
ve_269ab60a27|us/en/taipei-region/taipei/restaurant/a|$$$$|CAT_P04|2 star|tw|2026-10-30T15:13:38Z
ve_2766d50b55|us/en/jiang-su/nanjing_1029511/restaurant/jin-ling-wang-jia-hun-tun-jiqing-road|¥|CAT_P01|bib|cn|2026-10-30T15:13:39Z
ve_27c58623d2|us/en/fujian-province/fuzhou_1026814/restaurant/longkushan-eatery|¥|CAT_P01|bib|cn|2026-10-30T15:13:41Z
ve_28cbd5e446|us/en/taipei-region/taipei/restaurant/tableau-by-craig-yang|$$|CAT_P02|bib|tw|2026-10-30T15:13:42Z
ve_29d118509d|us/en/shanghai-municipality/shanghai/restaurant/rong-cuisine-huangpu|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:43Z
ve_29e49b967a|us/en/tainan-region/tainan/restaurant/hsi-lo-tien-beef-soup|$|CAT_P01|bib|tw|2026-10-30T15:13:45Z
ve_2ae8d2a042|us/en/zhe-jiang/taizhou_7770462/restaurant/rong-jia-xiao-chi-ziyang-street|¥|CAT_P01|bib|cn|2026-10-30T15:13:46Z
ve_2b7c417eb0|us/en/beijing-municipality/beijing/restaurant/lao-chuan-ban|¥¥|CAT_P02|bib|cn|2026-10-30T15:13:47Z
ve_2f0ad8b474|us/en/guangdong-province/guangzhou/restaurant/imperial-treasure-fine-teochew-cuisine-1190416|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:13:48Z
ve_2f34823c41|us/en/shanghai-municipality/shanghai/restaurant/nanxiang-steamed-bun-city-god-temple|¥|CAT_P01|bib|cn|2026-10-30T15:13:50Z
ve_2fdca93624|us/en/northern-taiwan/hsinchu-city_2853126/restaurant/jiu-tian-fu|$|CAT_P01|bib|tw|2026-10-30T15:13:51Z
ve_30b983e982|us/en/shanghai-municipality/shanghai/restaurant/t-ang-court-506725|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:13:52Z
ve_326f6967cf|us/en/guangdong-province/guangzhou/restaurant/tong-ji|¥|CAT_P01|bib|cn|2026-10-30T15:13:54Z
ve_337cd1e0fb|us/en/taipei-region/taipei/restaurant/motoichi|$$$$|CAT_P04|1 star|tw|2026-10-30T15:13:55Z
ve_338f3c1f04|us/en/taipei-region/taipei/restaurant/mai-mien-yen-tsai|$|CAT_P01|bib|tw|2026-10-30T15:13:56Z
ve_33c0ec99ea|us/en/fujian-province/xiamen_1031934/restaurant/hokklo|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:13:58Z
ve_3431b7271e|us/en/guangdong-province/guangzhou/restaurant/zijin-shi-fang|¥|CAT_P01|bib|cn|2026-10-30T15:13:59Z
ve_346f053e97|us/en/guangdong-province/guangzhou/restaurant/bingsheng-mansion|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:14:00Z
ve_348be5a2fb|us/en/guangdong-province/guangzhou/restaurant/hai-yan-lou-binjiang-east-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:02Z
ve_35c10411c4|us/en/shanghai-municipality/shanghai/restaurant/oriental-sense-palate|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:14:03Z
ve_362df974af|us/en/zhe-jiang/hangzhou_1027184/restaurant/ye-long-jing|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:05Z
ve_3685a7f175|us/en/shanghai-municipality/shanghai/restaurant/lu-style-1203592|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:14:06Z
ve_36ae4d6bcd|us/en/chengdu-municipality/chengdu/restaurant/xu-s-cuisine|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:14:07Z
ve_36bb6de657|us/en/taipei-region/taipei/restaurant/da-qiao-tou-tube-rice-pudding|$|CAT_P01|bib|tw|2026-10-30T15:14:09Z
ve_36e6b1664a|us/en/guangdong-province/guangzhou/restaurant/ft-bak-kut-teh|¥|CAT_P01|bib|cn|2026-10-30T15:14:10Z
ve_37341fa372|us/en/fujian-province/quanzhou_1030272/restaurant/jian-lai-fa|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:11Z
ve_37910677a4|us/en/chengdu-municipality/chengdu/restaurant/mi-xun-teahouse|¥¥|CAT_P02|1 star|cn|2026-10-30T15:14:13Z
ve_386b5b5e79|us/en/guangdong-province/guangzhou/restaurant/xin-tai-le-yuexiu|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:14Z
ve_38a720dd68|us/en/jiang-su/yangzhou_1032329/restaurant/yangzhou-yan-38-changchun-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:15Z
ve_3959d1eab4|us/en/guangdong-province/guangzhou/restaurant/yu-yue-heen|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:14:17Z
ve_3966886aeb|us/en/fujian-province/fuzhou_1026814/restaurant/shang-xing|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:18Z
ve_39d22a063e|us/en/beijing-municipality/beijing/restaurant/the-beijing-kitchen|¥¥|CAT_P02|1 star|cn|2026-10-30T15:14:19Z
ve_3b54c9f5ca|us/en/shanghai-municipality/shanghai/restaurant/maison-lameloise-563686|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:14:21Z
ve_3b5cc5997a|us/en/guangdong-province/guangzhou/restaurant/enning-liu-fu-ji-donghua-east-road|¥|CAT_P01|bib|cn|2026-10-30T15:14:22Z
ve_3c3f107341|us/en/shanghai-municipality/shanghai/restaurant/taian-table|¥¥¥¥|CAT_P04|3 star|cn|2026-10-30T15:14:23Z
ve_3cbcb3b38a|us/en/jiang-su/nanjing_1029511/restaurant/du-shi-li-de-xiang-cun|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:25Z
ve_3e561feda9|us/en/jiang-su/suzhou_1031079/restaurant/su-cheng-jia-yan-ligongdi-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:26Z
ve_3f7b8ed781|us/en/jiang-su/suzhou_1031079/restaurant/pingjiangsong|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:14:27Z
ve_40083176bc|us/en/beijing-municipality/beijing/restaurant/the-georg|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:14:29Z
ve_40135edd08|us/en/guangdong-province/guangzhou/restaurant/mian-ji-yuexiu|¥|CAT_P01|bib|cn|2026-10-30T15:14:30Z
ve_404cbd8475|us/en/jiang-su/nanjing_1029511/restaurant/fang-po|¥|CAT_P01|bib|cn|2026-10-30T15:14:31Z
ve_41a4101cbd|us/en/chengdu-municipality/chengdu/restaurant/co|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:14:32Z
ve_435c5b0c16|us/en/taipei-region/taipei/restaurant/tsui-feng-yuan|$$|CAT_P02|bib|tw|2026-10-30T15:14:34Z
ve_43d10763ed|us/en/northern-taiwan/hsinchu-city_2853126/restaurant/garden-v|$$|CAT_P02|bib|tw|2026-10-30T15:14:35Z
ve_43df8a2af9|us/en/fujian-province/fuzhou_1026814/restaurant/yi-tong-lou|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:37Z
ve_4473c30ea7|us/en/beijing-municipality/beijing/restaurant/mo-jasmine|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:14:38Z
ve_4500db80db|us/en/chengdu-municipality/chengdu/restaurant/wu-ji-guai-wei-mian-jinjiang|¥|CAT_P01|bib|cn|2026-10-30T15:14:39Z
ve_450c5c9eb7|us/en/beijing-municipality/beijing/restaurant/xiang-lin-tian-xia|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:41Z
ve_45a1b54b5a|us/en/zhe-jiang/wenzhou_1031793/restaurant/shuang-jing-tou|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:42Z
ve_466ef261dc|us/en/guangdong-province/guangzhou/restaurant/hunan-cuisine|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:43Z
ve_4732e861db|us/en/zhe-jiang/wenzhou_1031793/restaurant/yan-ji-gao-tou-pu|¥|CAT_P01|bib|cn|2026-10-30T15:14:45Z
ve_47575e3f57|us/en/zhe-jiang/wenzhou_1031793/restaurant/zhang-ren-hun-tun-pu|¥|CAT_P01|bib|cn|2026-10-30T15:14:46Z
ve_476e20b4b5|us/en/taipei-region/taipei/restaurant/de-nuit|$$$$|CAT_P04|1 star|tw|2026-10-30T15:14:47Z
ve_47a6d40bd0|us/en/taichung-region/taichung/restaurant/a-kun-mian|$|CAT_P01|bib|tw|2026-10-30T15:14:49Z
ve_47ede2d4aa|us/en/zhe-jiang/taizhou_7770462/restaurant/tang-a-yi-bian-shi|¥|CAT_P01|bib|cn|2026-10-30T15:14:50Z
ve_4864070326|us/en/taipei-region/taipei/restaurant/ming-fu|$$$|CAT_P03|1 star|tw|2026-10-30T15:14:51Z
ve_491f56a6f3|us/en/taipei-region/taipei/restaurant/chuan-ya|$$$|CAT_P03|1 star|tw|2026-10-30T15:14:53Z
ve_49eda396f5|us/en/taichung-region/taichung/restaurant/ajisai|$|CAT_P01|bib|tw|2026-10-30T15:14:54Z
ve_4a18464f0a|us/en/guangdong-province/guangzhou/restaurant/sa-er-ta-dongxiang-shou-zhua|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:55Z
ve_4a37c70b1a|us/en/taipei-region/taipei/restaurant/sung-chu-yuan|$$|CAT_P02|bib|tw|2026-10-30T15:14:57Z
ve_4a3f18795d|us/en/fujian-province/xiamen_1031934/restaurant/a-zhong-shi-fang|¥¥|CAT_P02|bib|cn|2026-10-30T15:14:58Z
ve_4aa1263325|us/en/tainan-region/tainan/restaurant/amei|$$|CAT_P02|bib|tw|2026-10-30T15:14:59Z
ve_4b0e487c12|us/en/zhe-jiang/taizhou_7770462/restaurant/lao-tai-zhou|¥|CAT_P01|bib|cn|2026-10-30T15:15:01Z
ve_4bb832227c|us/en/shanghai-municipality/shanghai/restaurant/lao-di-fang-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:15:02Z
ve_4cf56bc68c|us/en/fujian-province/xiamen_1031934/restaurant/cong-hui-tongan-lao-mei-shi-fan-dian|¥|CAT_P01|bib|cn|2026-10-30T15:15:03Z
ve_4de0f2dfd4|us/en/taichung-region/taichung/restaurant/l-atelier-par-yao|$$$|CAT_P03|1 star|tw|2026-10-30T15:15:05Z
ve_4ed10d8cc8|us/en/guangdong-province/guangzhou/restaurant/hui-xing-yuan|¥|CAT_P01|bib|cn|2026-10-30T15:15:06Z
ve_4f01015bdb|us/en/taipei-region/taipei/restaurant/sushiyoshi|$$$$|CAT_P04|1 star|tw|2026-10-30T15:15:07Z
ve_4f22bd0e88|us/en/zhe-jiang/hangzhou_1027184/restaurant/fang-lao-da|¥|CAT_P01|bib|cn|2026-10-30T15:15:09Z
ve_4f483f5e0b|us/en/kaohsiung-region/kaohsiung/restaurant/simmer-house|$$|CAT_P02|bib|tw|2026-10-30T15:15:10Z
ve_4f5d44401e|us/en/chengdu-municipality/chengdu/restaurant/lao-chengdu-san-yang-mian|¥|CAT_P01|bib|cn|2026-10-30T15:15:11Z
ve_4f7a800d7e|us/en/jiang-su/nanjing_1029511/restaurant/chi-man|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:13Z
ve_4f80d1c56e|us/en/guangdong-province/guangzhou/restaurant/liang-jie-nanning-pumiao-shengzha-mifen|¥|CAT_P01|bib|cn|2026-10-30T15:15:14Z
ve_4fb3596a23|us/en/beijing-municipality/beijing/restaurant/no-69-fangzhuanchang-zhajiangmian|¥|CAT_P01|bib|cn|2026-10-30T15:15:15Z
ve_502a1361dd|us/en/zhe-jiang/hangzhou_1027184/restaurant/xiao-shan-wei-dao|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:17Z
ve_506425696b|us/en/taichung-region/taichung/restaurant/jl-studio|$$$$|CAT_P04|3 star|tw|2026-10-30T15:15:18Z
ve_50fcf225a9|us/en/jiang-su/changzhou_1025968/restaurant/jiu-yan-hehai-east-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:19Z
ve_5129a7ce2d|us/en/shanghai-municipality/shanghai/restaurant/wu-you-xian|¥¥|CAT_P02|1 star|cn|2026-10-30T15:15:21Z
ve_51d39ce232|us/en/guangdong-province/guangzhou/restaurant/nan-yuan|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:22Z
ve_51d92fd612|us/en/jiang-su/nanjing_1029511/restaurant/dai-yuet-heen|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:15:23Z
ve_5217a49d50|us/en/tainan-region/tainan/restaurant/yeh-jia-calamari-rice-noodle-soup|$|CAT_P01|bib|tw|2026-10-30T15:15:25Z
ve_52de4f5640|us/en/shanghai-municipality/shanghai/restaurant/tan-1246400|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:26Z
ve_5358922bfc|us/en/shanghai-municipality/shanghai/restaurant/vivant-by-johnny-pham|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:15:27Z
ve_5439a35462|us/en/zhe-jiang/hangzhou_1027184/restaurant/bao-zhong-bao-shi-fu|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:29Z
ve_545d5d504b|us/en/fujian-province/xiamen_1031934/restaurant/minnan-minnan-siming|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:30Z
ve_548b41f4ff|us/en/fujian-province/fuzhou_1026814/restaurant/jiangnan-wok%E2%80%A7rong|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:15:31Z
ve_55908920f1|us/en/kaohsiung-region/kaohsiung/restaurant/bei-gang-tsai-rice-tube-yancheng|$|CAT_P01|bib|tw|2026-10-30T15:15:33Z
ve_55a80e1d17|us/en/jiang-su/suzhou_1031079/restaurant/yangzhou-yan-qu-yuan|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:34Z
ve_567d9f103c|us/en/beijing-municipality/beijing/restaurant/giada-garden|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:15:35Z
ve_5782845a81|us/en/fujian-province/fuzhou_1026814/restaurant/yong-zhou-ji-bian-rou-jinrong-south-road|¥|CAT_P01|bib|cn|2026-10-30T15:15:37Z
ve_57a4626bdf|us/en/zhe-jiang/hangzhou_1027184/restaurant/ru-yuan|¥¥¥|CAT_P03|2 star|cn|2026-10-30T15:15:38Z
ve_594cd8ed54|us/en/guangdong-province/guangzhou/restaurant/xiang-qun-longjin-east-road|¥|CAT_P01|bib|cn|2026-10-30T15:15:39Z
ve_5b34bc394e|us/en/fujian-province/xiamen_1031934/restaurant/wuwei-natural-food|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:41Z
ve_5bb470fe65|us/en/guangdong-province/guangzhou/restaurant/song-yuan|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:42Z
ve_5c1618e003|us/en/taipei-region/taipei/restaurant/inita|$$$$|CAT_P04|1 star|tw|2026-10-30T15:15:43Z
ve_5c2048e226|us/en/fujian-province/xiamen_1031934/restaurant/hao-shi-lai|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:45Z
ve_5c6146eda4|us/en/fujian-province/quanzhou_1030272/restaurant/a-qiu-niu-pai-huxin-street|¥|CAT_P01|bib|cn|2026-10-30T15:15:46Z
ve_5f54cf44b8|us/en/jiang-su/suzhou_1031079/restaurant/tong-de-xing-jiayu-fang|¥|CAT_P01|bib|cn|2026-10-30T15:15:47Z
ve_5ffdc0cb19|us/en/shanghai-municipality/shanghai/restaurant/fu-1015|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:15:49Z
ve_60213ad03e|us/en/guangdong-province/guangzhou/restaurant/temple-street|¥|CAT_P01|bib|cn|2026-10-30T15:15:50Z
ve_60879acc37|us/en/taichung-region/taichung/restaurant/li-xiao-lou|$$|CAT_P02|bib|tw|2026-10-30T15:15:51Z
ve_613736306e|us/en/shanghai-municipality/shanghai/restaurant/lu-bo-lang|¥¥|CAT_P02|bib|cn|2026-10-30T15:15:53Z
ve_615254eaed|us/en/shanghai-municipality/shanghai/restaurant/lao-zheng-xing-huangpu|¥¥|CAT_P02|1 star|cn|2026-10-30T15:15:54Z
ve_619429b2c4|us/en/taipei-region/taipei/restaurant/yu-kapo-1198592|$$$$|CAT_P04|2 star|tw|2026-10-30T15:15:55Z
ve_61f1a5a54b|us/en/shanghai-municipality/shanghai/restaurant/fu-1039|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:15:57Z
ve_6315071786|us/en/taipei-region/taipei/restaurant/wu-wang-tsai-chi|$|CAT_P01|bib|tw|2026-10-30T15:15:58Z
ve_6340373046|us/en/guangdong-province/guangzhou/restaurant/hongtu-hall|¥¥|CAT_P02|1 star|cn|2026-10-30T15:15:59Z
ve_6386e53030|us/en/zhe-jiang/wenzhou_1031793/restaurant/xiao-cai-yuan|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:01Z
ve_63e27edbe2|us/en/taipei-region/taipei/restaurant/hsiao-wang-steamed-minced-pork-with-pickles-in-broth|$|CAT_P01|bib|tw|2026-10-30T15:16:02Z
ve_643f7f9a62|us/en/beijing-municipality/beijing/restaurant/lu-shang-lu|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:16:03Z
ve_65981da71e|us/en/taipei-region/taipei/restaurant/talking-heads|$$|CAT_P02|bib|tw|2026-10-30T15:16:05Z
ve_6672c50f83|us/en/taipei-region/taipei/restaurant/sinchao-rice-shoppe|$$|CAT_P02|bib|tw|2026-10-30T15:16:06Z
ve_6672d45c44|us/en/beijing-municipality/beijing/restaurant/gastro-esthetics-dadong|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:16:07Z
ve_671b5f074f|us/en/zhe-jiang/hangzhou_1027184/restaurant/jie-xiang-lou|¥¥¥|CAT_P03|2 star|cn|2026-10-30T15:16:09Z
ve_674ed12b78|us/en/shanghai-municipality/shanghai/restaurant/gong-de-lin-jingan|¥|CAT_P01|bib|cn|2026-10-30T15:16:10Z
ve_67f01b1cdf|us/en/chengdu-municipality/chengdu/restaurant/rong-yuan-can-guan|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:11Z
ve_680ba6ae90|us/en/guangdong-province/guangzhou/restaurant/xin-wen-ji-yuexiu|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:13Z
ve_69877791d1|us/en/chengdu-municipality/chengdu/restaurant/nian-feng-restaurant|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:14Z
ve_6999ba83ec|us/en/zhe-jiang/hangzhou_1027184/restaurant/longjing-manor|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:16:15Z
ve_69a5bf5664|us/en/jiang-su/suzhou_1031079/restaurant/ge-jia-wu-farmer-s-house|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:17Z
ve_6a5ce2a273|us/en/shanghai-municipality/shanghai/restaurant/wang-lu|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:18Z
ve_6b7a0f46bd|us/en/tainan-region/tainan/restaurant/hao-nung-chia-migao|$|CAT_P01|bib|tw|2026-10-30T15:16:20Z
ve_6caa7297d8|us/en/taipei-region/taipei/restaurant/logy|$$$$|CAT_P04|2 star|tw|2026-10-30T15:16:21Z
ve_6d9c2d924e|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/shang-hao|$|CAT_P01|bib|tw|2026-10-30T15:16:22Z
ve_6ee0642103|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/garden-h|$$|CAT_P02|bib|tw|2026-10-30T15:16:24Z
ve_6f5ab461ea|us/en/shanghai-municipality/shanghai/restaurant/jing-mei-wu-xi-si-fang-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:16:25Z
ve_6f82b3520a|us/en/beijing-municipality/beijing/restaurant/pang-mei-noodles|¥|CAT_P01|bib|cn|2026-10-30T15:16:26Z
ve_6fc43f582e|us/en/shanghai-municipality/shanghai/restaurant/ren-he-guan-zhaojiabang-road|¥¥|CAT_P02|1 star|cn|2026-10-30T15:16:28Z
ve_708f092edb|us/en/fujian-province/quanzhou_1030272/restaurant/hall-thing-licheng|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:29Z
ve_70ca3373b2|us/en/zhe-jiang/hangzhou_1027184/restaurant/guiyu|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:16:30Z
ve_7176a2f9d7|us/en/jiang-su/nanjing_1029511/restaurant/zhi-he-lao-ya-fen-si-tang|¥|CAT_P01|bib|cn|2026-10-30T15:16:32Z
ve_723b9b518f|us/en/taichung-region/taichung/restaurant/oretachi-no-nikuya-1195583|$$$|CAT_P03|1 star|tw|2026-10-30T15:16:33Z
ve_72de8637df|us/en/kaohsiung-region/kaohsiung/restaurant/thai-yuan|$$|CAT_P02|bib|tw|2026-10-30T15:16:34Z
ve_73891a53ce|us/en/taichung-region/taichung/restaurant/kuisine|$$|CAT_P02|bib|tw|2026-10-30T15:16:36Z
ve_74763ed659|us/en/beijing-municipality/beijing/restaurant/furong|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:16:37Z
ve_763d077255|us/en/jiang-su/yangzhou_1032329/restaurant/hu-yuan-mei-shi|¥|CAT_P01|bib|cn|2026-10-30T15:16:38Z
ve_7680c3ed3f|us/en/tainan-region/tainan/restaurant/a-xing-shi-mu-yu|$|CAT_P01|bib|tw|2026-10-30T15:16:40Z
ve_76907429c5|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/san-tung|$$|CAT_P02|bib|tw|2026-10-30T15:16:41Z
ve_7702035d81|us/en/zhe-jiang/hangzhou_1027184/restaurant/jin-sha|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:16:42Z
ve_7874ea5ed1|us/en/fujian-province/xiamen_1031934/restaurant/shan-li-yan-sha-cha-mian|¥|CAT_P01|bib|cn|2026-10-30T15:16:44Z
ve_79f90b6af9|us/en/taipei-region/taipei/restaurant/serenity|$$|CAT_P02|bib|tw|2026-10-30T15:16:45Z
ve_7ab59d83eb|us/en/chengdu-municipality/chengdu/restaurant/long-sen-yuan|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:46Z
ve_7c2a8db0cc|us/en/guangdong-province/guangzhou/restaurant/fa-sing-garden-jinsui-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:16:47Z
ve_7d700ff172|us/en/zhe-jiang/hangzhou_1027184/restaurant/l-eclat-19|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:16:49Z
ve_7f8b5c7d71|us/en/taichung-region/taichung/restaurant/fu-juang-yuan|$|CAT_P01|bib|tw|2026-10-30T15:16:50Z
ve_8010044864|us/en/taipei-region/taipei/restaurant/eika|$$$$|CAT_P04|2 star|tw|2026-10-30T15:16:52Z
ve_8045bb31ef|us/en/fujian-province/quanzhou_1030272/restaurant/zhong-ji-yan-shao-fan-ya|¥|CAT_P01|bib|cn|2026-10-30T15:16:53Z
ve_80722205c3|us/en/taipei-region/taipei/restaurant/jin-shang-hsuan|$$|CAT_P02|bib|tw|2026-10-30T15:16:54Z
ve_810781d02c|us/en/zhe-jiang/wenzhou_1031793/restaurant/sun-guo-hua-qing-jiang-san-xian-mian-renmin-north-road|¥|CAT_P01|bib|cn|2026-10-30T15:16:56Z
ve_815608d63a|us/en/taipei-region/taipei/restaurant/unnamed-clay-oven-roll|$|CAT_P01|bib|tw|2026-10-30T15:16:57Z
ve_81aa03708d|us/en/tainan-region/tainan/restaurant/chang-ying-seafood-house|$$|CAT_P02|bib|tw|2026-10-30T15:16:58Z
ve_820878c98e|us/en/chengdu-municipality/chengdu/restaurant/gong-zhou-ba-shu-wei-yuan|¥|CAT_P01|bib|cn|2026-10-30T15:17:00Z
ve_820fa9d3a6|us/en/taichung-region/taichung/restaurant/house-of-dawn|$|CAT_P01|bib|tw|2026-10-30T15:17:01Z
ve_821f15690f|us/en/shanghai-municipality/shanghai/restaurant/canton-8-runan-street|¥¥|CAT_P02|2 star|cn|2026-10-30T15:17:02Z
ve_82d2546fa6|us/en/taichung-region/taichung/restaurant/moon-pavilion|$$|CAT_P02|bib|tw|2026-10-30T15:17:04Z
ve_832a291604|us/en/zhe-jiang/hangzhou_1027184/restaurant/yue-ji|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:05Z
ve_83ae36b088|us/en/taipei-region/taipei/restaurant/ken-an-ho|$$$$|CAT_P04|1 star|tw|2026-10-30T15:17:06Z
ve_84dc39ab0e|us/en/chengdu-municipality/chengdu/restaurant/bai-nian-fen-zheng-niu-rou|¥|CAT_P01|bib|cn|2026-10-30T15:17:08Z
ve_8517995e19|us/en/guangdong-province/guangzhou/restaurant/lei-garden-yuexiu|¥¥|CAT_P02|1 star|cn|2026-10-30T15:17:09Z
ve_858d4a4ba7|us/en/fujian-province/fuzhou_1026814/restaurant/hou-jie-lao-hua-yadao-lane|¥|CAT_P01|bib|cn|2026-10-30T15:17:10Z
ve_85c6feef1b|us/en/fujian-province/quanzhou_1030272/restaurant/qing-you-yu|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:12Z
ve_87a1c45c26|us/en/taipei-region/taipei/restaurant/tairroir|$$$$|CAT_P04|3 star|tw|2026-10-30T15:17:13Z
ve_8848276309|us/en/jiang-su/suzhou_1031079/restaurant/wan-tai-xing|¥|CAT_P01|bib|cn|2026-10-30T15:17:14Z
ve_88553fb416|us/en/beijing-municipality/beijing/restaurant/poetry%E2%80%A7wine|¥¥|CAT_P02|1 star|cn|2026-10-30T15:17:16Z
ve_885573af29|us/en/shanghai-municipality/shanghai/restaurant/lan-xin-jinxian-road|¥|CAT_P01|bib|cn|2026-10-30T15:17:17Z
ve_8855f2f247|us/en/shanghai-municipality/shanghai/restaurant/sheng-yong-xing|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:18Z
ve_889a42dda9|us/en/zhe-jiang/taizhou_7770462/restaurant/shen-ji-mai-xia-mian-pi-dian|¥|CAT_P01|bib|cn|2026-10-30T15:17:20Z
ve_892eae0859|us/en/jiang-su/suzhou_1031079/restaurant/wei-ji-ao-mian-guan-east-baita-road|¥|CAT_P01|bib|cn|2026-10-30T15:17:21Z
ve_894c978cf0|us/en/shanghai-municipality/shanghai/restaurant/ji-pin-court|¥¥¥|CAT_P03|2 star|cn|2026-10-30T15:17:22Z
ve_8974cad8e9|us/en/zhe-jiang/taizhou_7770462/restaurant/ma-lu-qiao-jiang-tang-mian|¥|CAT_P01|bib|cn|2026-10-30T15:17:24Z
ve_8b3a664168|us/en/shanghai-municipality/shanghai/restaurant/zhou-she-minhang|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:26Z
ve_8bb1dc1f91|us/en/fujian-province/fuzhou_1026814/restaurant/guan-zhong-wang-shi|¥|CAT_P01|bib|cn|2026-10-30T15:17:28Z
ve_8c19320bad|us/en/kaohsiung-region/kaohsiung/restaurant/hung-chi-rice-shop|$|CAT_P01|bib|tw|2026-10-30T15:17:29Z
ve_8c3f87f67f|us/en/jiang-su/yangzhou_1032329/restaurant/fan-shui-chang-yu-mian-north-jiefang-road|¥|CAT_P01|bib|cn|2026-10-30T15:17:30Z
ve_8c951102be|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/a-ba-s-taro-ball|$|CAT_P01|bib|tw|2026-10-30T15:17:32Z
ve_8cbb6e9fa9|us/en/shanghai-municipality/shanghai/restaurant/hao-sheng|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:33Z
ve_8ce0987360|us/en/zhe-jiang/wenzhou_1031793/restaurant/yangjia-shantou-mai-mian-lao-dian-canghe-lane|¥|CAT_P01|bib|cn|2026-10-30T15:17:34Z
ve_8d96aa8573|us/en/shanghai-municipality/shanghai/restaurant/mao-long|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:36Z
ve_8db1436125|us/en/beijing-municipality/beijing/restaurant/sheng-yong-xing-chaoyang|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:37Z
ve_8ddc148987|us/en/fujian-province/fuzhou_1026814/restaurant/yu-xian-lou|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:38Z
ve_8e1dc1810a|us/en/taichung-region/taichung/restaurant/fu-din-wang-central|$|CAT_P01|bib|tw|2026-10-30T15:17:40Z
ve_8ee03ec013|us/en/taichung-region/taichung/restaurant/peng-cheng-tang|$$|CAT_P02|bib|tw|2026-10-30T15:17:41Z
ve_8eebb0534c|us/en/fujian-province/fuzhou_1026814/restaurant/shan-hai-nan-yan|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:42Z
ve_8f7de74442|us/en/jiang-su/nanjing_1029511/restaurant/meng-du-hui-1216395|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:44Z
ve_8ff48e1c8f|us/en/shanghai-municipality/shanghai/restaurant/the-house-of-rong|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:17:45Z
ve_91b0601a41|us/en/zhe-jiang/taizhou_7770462/restaurant/hui-pu-pai-dang|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:46Z
ve_9248e378f3|us/en/taipei-region/taipei/restaurant/tien-hsia-san-chueh|$$|CAT_P02|bib|tw|2026-10-30T15:17:48Z
ve_92b5f3a2f3|us/en/shanghai-municipality/shanghai/restaurant/sole|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:49Z
ve_931133988a|us/en/guangdong-province/guangzhou/restaurant/wen-ji-yixinji|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:50Z
ve_9345ef8e01|us/en/zhe-jiang/taizhou_7770462/restaurant/fullie-s-seafood-house|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:52Z
ve_93ad314358|us/en/shanghai-municipality/shanghai/restaurant/yangzhou-fan-dian-huangpu|¥¥|CAT_P02|bib|cn|2026-10-30T15:17:53Z
ve_93ec5db78a|us/en/taichung-region/taichung/restaurant/ke-kou-beef-noodles|$|CAT_P01|bib|tw|2026-10-30T15:17:54Z
ve_944737f887|us/en/shanghai-municipality/shanghai/restaurant/fu-1088|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:17:56Z
ve_9460417485|us/en/tainan-region/tainan/restaurant/yuan-zai-hui-guohua-street|$|CAT_P01|bib|tw|2026-10-30T15:17:57Z
ve_947ed0aa02|us/en/taipei-region/taipei/restaurant/la-vie-by-thomas-buhner|$$$$|CAT_P04|1 star|tw|2026-10-30T15:17:58Z
ve_958e8f01d5|us/en/shanghai-municipality/shanghai/restaurant/huaiyang-delights-jingan|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:18:00Z
ve_959d4758e4|us/en/zhe-jiang/taizhou_7770462/restaurant/jiu-wei|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:01Z
ve_96325036c3|us/en/tainan-region/tainan/restaurant/kaiyuan-red-cook-spanish-mackerel|$|CAT_P01|bib|tw|2026-10-30T15:18:02Z
ve_96745043a5|us/en/tainan-region/tainan/restaurant/small-park-danzai-noodles|$|CAT_P01|bib|tw|2026-10-30T15:18:04Z
ve_982513a97e|us/en/taipei-region/taipei/restaurant/saffron|$$|CAT_P02|bib|tw|2026-10-30T15:18:05Z
ve_983ce43901|us/en/fujian-province/quanzhou_1030272/restaurant/luo-ji-mian-xian-hu|¥|CAT_P01|bib|cn|2026-10-30T15:18:06Z
ve_992e7faf4b|us/en/shanghai-municipality/shanghai/restaurant/rongjia-noodle-soup-with-yellow-croaker|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:08Z
ve_9962046586|us/en/chengdu-municipality/chengdu/restaurant/yu-zhi-lan-1196150|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:18:09Z
ve_9a47242102|us/en/zhe-jiang/taizhou_7770462/restaurant/zhang-yuan-chui-fan-yanyu-road|¥|CAT_P01|bib|cn|2026-10-30T15:18:10Z
ve_9a6521d748|us/en/taipei-region/taipei/restaurant/sens-1204678|$$$$|CAT_P04|1 star|tw|2026-10-30T15:18:12Z
ve_9a84effcd4|us/en/guangdong-province/guangzhou/restaurant/dayang-wenming-road|¥|CAT_P01|bib|cn|2026-10-30T15:18:13Z
ve_9a9803fa50|us/en/taipei-region/taipei/restaurant/sushi-ryu|$$$$|CAT_P04|1 star|tw|2026-10-30T15:18:14Z
ve_9ab72fba83|us/en/taichung-region/taichung/restaurant/shanghai-food|$|CAT_P01|bib|tw|2026-10-30T15:18:16Z
ve_9ba3a5d492|us/en/jiang-su/nanjing_1029511/restaurant/wu-ming-lao-lu-mian|¥|CAT_P01|bib|cn|2026-10-30T15:18:17Z
ve_9c004b1f6f|us/en/chengdu-municipality/chengdu/restaurant/yangboying-za-jiang-mian|¥|CAT_P01|bib|cn|2026-10-30T15:18:18Z
ve_9c582cd9ed|us/en/jiang-su/suzhou_1031079/restaurant/san-xing-yang-rou-guan|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:20Z
ve_9cb807d5e4|us/en/taipei-region/taipei/restaurant/hosu|$$$|CAT_P03|1 star|tw|2026-10-30T15:18:21Z
ve_9d548b5d3b|us/en/shanghai-municipality/shanghai/restaurant/blossom-1246455|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:22Z
ve_9d640cd684|us/en/kaohsiung-region/kaohsiung/restaurant/joes-gangshan|$$|CAT_P02|bib|tw|2026-10-30T15:18:24Z
ve_9e20e8846b|us/en/northern-taiwan/hsinchu-county_2853127/restaurant/bebu|$$|CAT_P02|bib|tw|2026-10-30T15:18:25Z
ve_9e3ff3f767|us/en/fujian-province/quanzhou_1030272/restaurant/zhang-lin-a-shan-jiang-mu-ya|¥|CAT_P01|bib|cn|2026-10-30T15:18:26Z
ve_9f2b2906c2|us/en/fujian-province/quanzhou_1030272/restaurant/chun-sheng|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:28Z
ve_9fb6c62935|us/en/kaohsiung-region/kaohsiung/restaurant/gen-1214088|$$$$|CAT_P04|1 star|tw|2026-10-30T15:18:29Z
ve_a0386d8940|us/en/shanghai-municipality/shanghai/restaurant/fu-he-hui|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:18:30Z
ve_a119bb8427|us/en/beijing-municipality/beijing/restaurant/mingyuan-restaurant|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:32Z
ve_a326cc3591|us/en/tainan-region/tainan/restaurant/dayong-street-no-name-congee|$|CAT_P01|bib|tw|2026-10-30T15:18:33Z
ve_a3b31ca55d|us/en/chengdu-municipality/chengdu/restaurant/fu-rong-huang|¥¥|CAT_P02|1 star|cn|2026-10-30T15:18:34Z
ve_a3dcfd53ea|us/en/zhe-jiang/taizhou_7770462/restaurant/wei-chen-xiao-chi|¥|CAT_P01|bib|cn|2026-10-30T15:18:36Z
ve_a3e49b0fb3|us/en/guangdong-province/guangzhou/restaurant/stay-here|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:37Z
ve_a4c83564e5|us/en/shanghai-municipality/shanghai/restaurant/tou-zao|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:18:38Z
ve_a4cfa692ff|us/en/guangdong-province/guangzhou/restaurant/lingnan-house|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:18:40Z
ve_a4f1a3bf9c|us/en/jiang-su/changzhou_1025968/restaurant/hua-yue-dou-xiang|¥|CAT_P01|bib|cn|2026-10-30T15:18:41Z
ve_a5be00397d|us/en/taipei-region/taipei/restaurant/hugh|$$|CAT_P02|bib|tw|2026-10-30T15:18:42Z
ve_a5ddf32fa3|us/en/taichung-region/taichung/restaurant/lou-s-nantun|$$|CAT_P02|bib|tw|2026-10-30T15:18:44Z
ve_a64a235506|us/en/chengdu-municipality/chengdu/restaurant/gan-ji-fei-chang-fen|¥|CAT_P01|bib|cn|2026-10-30T15:18:45Z
ve_a709525134|us/en/fujian-province/xiamen_1031934/restaurant/a-xi-xia-mian|¥|CAT_P01|bib|cn|2026-10-30T15:18:46Z
ve_a85f950dc3|us/en/shanghai-municipality/shanghai/restaurant/qiao-ai-lai-lai-xiao-long-huangpu|¥|CAT_P01|bib|cn|2026-10-30T15:18:48Z
ve_a8a1e98cc4|us/en/fujian-province/quanzhou_1030272/restaurant/antstory|¥¥|CAT_P02|bib|cn|2026-10-30T15:18:49Z
ve_a8ad15d3e1|us/en/fujian-province/ningde/restaurant/shou-ning-mi-gao|¥|CAT_P01|bib|cn|2026-10-30T15:18:50Z
ve_a8fec65396|us/en/taichung-region/taichung/restaurant/taichung-meatball|$|CAT_P01|bib|tw|2026-10-30T15:18:52Z
ve_a9d88204ae|us/en/jiang-su/changzhou_1025968/restaurant/chang-xian-de-tianning|¥|CAT_P01|bib|cn|2026-10-30T15:18:53Z
ve_aa194713b5|us/en/fujian-province/fuzhou_1026814/restaurant/a-xin-xian-lao-gongnong-road|¥|CAT_P01|bib|cn|2026-10-30T15:18:54Z
ve_ab36d946a2|us/en/shanghai-municipality/shanghai/restaurant/il-ristorante-niko-romito-563683|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:18:56Z
ve_ab77079d98|us/en/fujian-province/xiamen_1031934/restaurant/ming-yue-xia-mian-xiahe-road|¥|CAT_P01|bib|cn|2026-10-30T15:18:57Z
ve_ab89dbb319|us/en/beijing-municipality/beijing/restaurant/yibin|¥|CAT_P01|bib|cn|2026-10-30T15:18:58Z
ve_abd6c983fc|us/en/beijing-municipality/beijing/restaurant/tianchumiaoxiang-vegetarian-chaoyang|¥|CAT_P01|bib|cn|2026-10-30T15:19:00Z
ve_ac8b79d0e6|us/en/taipei-region/taipei/restaurant/nobuo|$$$$|CAT_P04|2 star|tw|2026-10-30T15:19:01Z
ve_ac8ba871b0|us/en/kaohsiung-region/kaohsiung/restaurant/liang-chia-pig-knuckle|$|CAT_P01|bib|tw|2026-10-30T15:19:02Z
ve_ad0bb34099|us/en/chengdu-municipality/chengdu/restaurant/silver-pot|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:19:04Z
ve_ad61d5e039|us/en/guangdong-province/guangzhou/restaurant/jian-ji|¥|CAT_P01|bib|cn|2026-10-30T15:19:05Z
ve_aead754c2b|us/en/northern-taiwan/hsinchu-county_2853127/restaurant/ang-gu|$|CAT_P01|bib|tw|2026-10-30T15:19:07Z
ve_af3baeb42c|us/en/fujian-province/ningde/restaurant/fu-ding-zheng-zong-bian-rou-jianxin-road|¥|CAT_P01|bib|cn|2026-10-30T15:19:08Z
ve_b00c7b967b|us/en/guangdong-province/guangzhou/restaurant/imperial-treasure-fine-chinese-cuisine-559150|¥¥¥|CAT_P03|2 star|cn|2026-10-30T15:19:09Z
ve_b075220a1b|us/en/beijing-municipality/beijing/restaurant/blackswan|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:19:11Z
ve_b172568649|us/en/shanghai-municipality/shanghai/restaurant/bao-li-xuan|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:19:12Z
ve_b1cd4dc1c2|us/en/tainan-region/tainan/restaurant/shang-hao-chih-beef-soup|$|CAT_P01|bib|tw|2026-10-30T15:19:13Z
ve_b4290b10a5|us/en/taipei-region/taipei/restaurant/the-guest-house|$$$|CAT_P03|1 star|tw|2026-10-30T15:19:15Z
ve_b47c884651|us/en/guangdong-province/guangzhou/restaurant/jia-yuan|¥|CAT_P01|bib|cn|2026-10-30T15:19:16Z
ve_b66dbcd3f4|us/en/jiang-su/suzhou_1031079/restaurant/yu-mian-tang|¥|CAT_P01|bib|cn|2026-10-30T15:19:17Z
ve_b69e4aa4be|us/en/guangdong-province/guangzhou/restaurant/da-ge-fan-tangxiayong-west-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:19Z
ve_b7fc0083cc|us/en/jiang-su/nanjing_1029511/restaurant/pin-ning-fu|¥¥|CAT_P02|1 star|cn|2026-10-30T15:19:20Z
ve_b8255461a4|us/en/chengdu-municipality/chengdu/restaurant/chen-mapo-tofu-qinghua-road|¥|CAT_P01|bib|cn|2026-10-30T15:19:21Z
ve_b925f98f4d|us/en/shanghai-municipality/shanghai/restaurant/ling-long-1209951|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:19:23Z
ve_b96a90755c|us/en/tainan-region/tainan/restaurant/yi-wei-pin|$|CAT_P01|bib|tw|2026-10-30T15:19:24Z
ve_bb0235c8dc|us/en/shanghai-municipality/shanghai/restaurant/narisawa-1209925|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:19:25Z
ve_bb2dc8bf0e|us/en/shanghai-municipality/shanghai/restaurant/polux|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:27Z
ve_bb37e8ee54|us/en/taichung-region/taichung/restaurant/yuen-ji|$$$$|CAT_P04|1 star|tw|2026-10-30T15:19:28Z
ve_bc7ea4dff4|us/en/beijing-municipality/beijing/restaurant/tong-he-ju-yuetan-south-street|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:29Z
ve_bd23f794b5|us/en/jiang-su/yangzhou_1032329/restaurant/cheng-yuan|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:19:31Z
ve_bdcb7d5b71|us/en/jiang-su/yangzhou_1032329/restaurant/lao-hu-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:19:32Z
ve_be11ec0b37|us/en/guangdong-province/guangzhou/restaurant/hai-xian-jie-cai-guan|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:33Z
ve_be1a29005e|us/en/jiang-su/changzhou_1025968/restaurant/ru-yuan-1246197|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:35Z
ve_be6f09d00f|us/en/taipei-region/taipei/restaurant/le-palais|$$$|CAT_P03|3 star|tw|2026-10-30T15:19:36Z
ve_bf3adf5226|us/en/beijing-municipality/beijing/restaurant/cai-yi-xuan|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:19:37Z
ve_bfe8dfb541|us/en/tainan-region/tainan/restaurant/a-wen-rice-cake|$|CAT_P01|bib|tw|2026-10-30T15:19:39Z
ve_c146f02657|us/en/shanghai-municipality/shanghai/restaurant/cheng-long-hang-huangpu|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:19:40Z
ve_c34958da29|us/en/shanghai-municipality/shanghai/restaurant/yu-ge-zhan-jiang-jingan|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:41Z
ve_c4eac998eb|us/en/zhe-jiang/taizhou_7770462/restaurant/rong-cun-gucheng-street|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:43Z
ve_c8459a2a39|us/en/taipei-region/taipei/restaurant/chi-chia-chuang-changchun-road|$$|CAT_P02|bib|tw|2026-10-30T15:19:44Z
ve_c89d460a41|us/en/beijing-municipality/beijing/restaurant/jing-hua-lou|¥¥|CAT_P02|bib|cn|2026-10-30T15:19:45Z
ve_c8a7e44d46|us/en/shanghai-municipality/shanghai/restaurant/imperial-treasure-fine-chinese-cuisine-huangpu|¥¥¥|CAT_P03|2 star|cn|2026-10-30T15:19:47Z
ve_c8ceea9779|us/en/shanghai-municipality/shanghai/restaurant/lei-garden-pudong|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:19:48Z
ve_c90b07f1bf|us/en/beijing-municipality/beijing/restaurant/the-house-of-dynasties|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:19:49Z
ve_c95452bfed|us/en/beijing-municipality/beijing/restaurant/lamdre|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:19:51Z
ve_cac97d5fb7|us/en/taipei-region/taipei/restaurant/frassi|$$$$|CAT_P04|1 star|tw|2026-10-30T15:19:52Z
ve_cade3ee4ad|us/en/taichung-region/taichung/restaurant/kung-fu-shanghai-fish-ball|$|CAT_P01|bib|tw|2026-10-30T15:19:53Z
ve_cf58024443|us/en/kaohsiung-region/kaohsiung/restaurant/caizong-li|$|CAT_P01|bib|tw|2026-10-30T15:19:55Z
ve_d03a39c2c2|us/en/jiang-su/nanjing_1029511/restaurant/jin-ling-yang-jia-hun-tun-dian-caodu-alley|¥|CAT_P01|bib|cn|2026-10-30T15:19:56Z
ve_d1e93b6c95|us/en/northern-taiwan/hsinchu-county_2853127/restaurant/shou-wu-eat|$$|CAT_P02|bib|tw|2026-10-30T15:19:57Z
ve_d33390c047|us/en/chengdu-municipality/chengdu/restaurant/chaimen-hui|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:19:59Z
ve_d36d973876|us/en/shanghai-municipality/shanghai/restaurant/yu-du-lao-wei-mian-huangpu|¥|CAT_P01|bib|cn|2026-10-30T15:20:00Z
ve_d3814835da|us/en/shanghai-municipality/shanghai/restaurant/amazing-chinese-cuisine-changning|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:20:01Z
ve_d399685f96|us/en/guangdong-province/guangzhou/restaurant/yong-zuo-baoye-north-street|¥|CAT_P01|bib|cn|2026-10-30T15:20:03Z
ve_d3cc6fd8cb|us/en/shanghai-municipality/shanghai/restaurant/mi-thai-an-fu-road|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:04Z
ve_d3f69a8eff|us/en/jiang-su/nanjing_1029511/restaurant/cui-jie-xiao-chi|¥|CAT_P01|bib|cn|2026-10-30T15:20:05Z
ve_d46114d738|us/en/jiang-su/changzhou_1025968/restaurant/qing-wa-xiang-tianning|¥|CAT_P01|bib|cn|2026-10-30T15:20:07Z
ve_d485a840c0|us/en/shanghai-municipality/shanghai/restaurant/fabula|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:20:08Z
ve_d4e5fdbd3e|us/en/beijing-municipality/beijing/restaurant/il-ristorante-niko-romito-1186723|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:20:09Z
ve_d5746d246e|us/en/zhe-jiang/hangzhou_1027184/restaurant/zhi-zhu-xihu|¥|CAT_P01|bib|cn|2026-10-30T15:20:11Z
ve_d658df99a8|us/en/fujian-province/quanzhou_1030272/restaurant/zhuang-ji-quan-fu-lu-mian-guan|¥|CAT_P01|bib|cn|2026-10-30T15:20:12Z
ve_d735435a09|us/en/northern-taiwan/hsinchu-county_2853127/restaurant/tang-tsao-yuan|$$|CAT_P02|bib|tw|2026-10-30T15:20:13Z
ve_d74805f382|us/en/kaohsiung-region/kaohsiung/restaurant/ibu-kitchen|$$|CAT_P02|bib|tw|2026-10-30T15:20:15Z
ve_d786202a4e|us/en/guangdong-province/guangzhou/restaurant/wei-shi-jia|¥|CAT_P01|bib|cn|2026-10-30T15:20:16Z
ve_d7f1193b3e|us/en/tainan-region/tainan/restaurant/jai-mi-ba|$$|CAT_P02|bib|tw|2026-10-30T15:20:17Z
ve_d82e2354e6|us/en/fujian-province/fuzhou_1026814/restaurant/wenru-no-9|¥¥|CAT_P02|1 star|cn|2026-10-30T15:20:19Z
ve_d8b49ebd66|us/en/fujian-province/fuzhou_1026814/restaurant/jing-li|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:20Z
ve_d9eac922c0|us/en/zhe-jiang/hangzhou_1027184/restaurant/xun-wei-jiang-nan|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:21Z
ve_da97d58bf1|us/en/taipei-region/taipei/restaurant/mudan|$$$$|CAT_P04|2 star|tw|2026-10-30T15:20:23Z
ve_dac6f2bd65|us/en/jiang-su/yangzhou_1032329/restaurant/shuang-dong|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:24Z
ve_db92193fc0|us/en/chengdu-municipality/chengdu/restaurant/young-art-yong-ya-he-xian-tongzilin-east-road|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:20:26Z
ve_dc479eb6ab|us/en/shanghai-municipality/shanghai/restaurant/da-hu-chun-middle-sichuan-road|¥|CAT_P01|bib|cn|2026-10-30T15:20:27Z
ve_dcb8ece7dd|us/en/taipei-region/taipei/restaurant/shin-yeh-taiwanese-signature|$$|CAT_P02|1 star|tw|2026-10-30T15:20:28Z
ve_dd2193c1f9|us/en/taichung-region/taichung/restaurant/shin-yuan|$$|CAT_P02|bib|tw|2026-10-30T15:20:30Z
ve_dd9529abf4|us/en/jiang-su/changzhou_1025968/restaurant/fang-xiang-by-detan-zhonglou|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:31Z
ve_de7979639f|us/en/guangdong-province/guangzhou/restaurant/bingsheng-private-kitchen|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:20:32Z
ve_ded5fe0f9c|us/en/tainan-region/tainan/restaurant/po-jen-tang|$|CAT_P01|bib|tw|2026-10-30T15:20:34Z
ve_dfa9421242|us/en/fujian-province/xiamen_1031934/restaurant/bai-jia-chun-hao-de-lai-jiang-mu-ya-zhongxing-road|¥|CAT_P01|bib|cn|2026-10-30T15:20:35Z
ve_dff5cddc5f|us/en/shanghai-municipality/shanghai/restaurant/da-vittorio-570570|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:20:36Z
ve_e08de51373|us/en/beijing-municipality/beijing/restaurant/yu-hua-tai-xicheng|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:38Z
ve_e0abec6b4b|us/en/kaohsiung-region/kaohsiung/restaurant/niu-lao-da|$$|CAT_P02|bib|tw|2026-10-30T15:20:39Z
ve_e1109450cf|us/en/chengdu-municipality/chengdu/restaurant/fang-xiang-jing|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:20:40Z
ve_e1d0fe73ca|us/en/taipei-region/taipei/restaurant/yuan-fang-guabao|$|CAT_P01|bib|tw|2026-10-30T15:20:42Z
ve_e1de2a4f90|us/en/shanghai-municipality/shanghai/restaurant/the-lakeside-veggie|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:43Z
ve_e2e5854a3f|us/en/fujian-province/xiamen_1031934/restaurant/zhen-zhen-hai-li-jian|¥|CAT_P01|bib|cn|2026-10-30T15:20:44Z
ve_e4539f8c60|us/en/guangdong-province/guangzhou/restaurant/yu-garden|¥¥|CAT_P02|1 star|cn|2026-10-30T15:20:46Z
ve_e4a5d832bc|us/en/jiang-su/nanjing_1029511/restaurant/qiang-ye-fan-dian-changbai-street|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:47Z
ve_e4c6252666|us/en/taipei-region/taipei/restaurant/kitcho|$$$$|CAT_P04|1 star|tw|2026-10-30T15:20:48Z
ve_e573ea7e30|us/en/chengdu-municipality/chengdu/restaurant/yongle-restaurant-wuhou|¥|CAT_P01|bib|cn|2026-10-30T15:20:50Z
ve_e59b755e48|us/en/zhe-jiang/wenzhou_1031793/restaurant/zheng-zhengliang-seafood-nantang-street|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:51Z
ve_e5e6bb6ea3|us/en/guangdong-province/guangzhou/restaurant/wisca-haizhu|¥¥|CAT_P02|1 star|cn|2026-10-30T15:20:52Z
ve_e61dc1a188|us/en/beijing-municipality/beijing/restaurant/king-s-joy|¥¥¥¥|CAT_P04|2 star|cn|2026-10-30T15:20:54Z
ve_e6415390b3|us/en/fujian-province/fuzhou_1026814/restaurant/min-shi-fu|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:55Z
ve_e6980b4433|us/en/taipei-region/taipei/restaurant/l-atelier-de-joel-robuchon550759|$$$$|CAT_P04|2 star|tw|2026-10-30T15:20:56Z
ve_e6c12e5f11|us/en/kaohsiung-region/kaohsiung/restaurant/ciao-zai-tou-huang-s-braised-pork-rice-ciaotou|$|CAT_P01|bib|tw|2026-10-30T15:20:58Z
ve_e974046d60|us/en/jiang-su/changzhou_1025968/restaurant/south-garden|¥¥|CAT_P02|bib|cn|2026-10-30T15:20:59Z
ve_e9fe72a9b0|us/en/kaohsiung-region/kaohsiung/restaurant/chun-lan-gua-bao|$|CAT_P01|bib|tw|2026-10-30T15:21:00Z
ve_ea16adb1d3|us/en/taichung-region/taichung/restaurant/chin-chih-yuan|$|CAT_P01|bib|tw|2026-10-30T15:21:02Z
ve_ea349b8773|us/en/northern-taiwan/new-taipei-city_2853082/restaurant/dian-xiao-er-datong-north-road|$|CAT_P01|bib|tw|2026-10-30T15:21:03Z
ve_ebab369dd0|us/en/fujian-province/xiamen_1031934/restaurant/guo-gong-fan-dian|¥|CAT_P01|bib|cn|2026-10-30T15:21:04Z
ve_eca1f440c7|us/en/jiang-su/suzhou_1031079/restaurant/a-cheng|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:06Z
ve_eca27cd696|us/en/shanghai-municipality/shanghai/restaurant/a-yong-mian-guan-dongshufang-road|¥|CAT_P01|bib|cn|2026-10-30T15:21:07Z
ve_ecff937fc5|us/en/fujian-province/xiamen_1031934/restaurant/shan-gu-tang|¥|CAT_P01|bib|cn|2026-10-30T15:21:08Z
ve_ed2d2d73ee|us/en/taipei-region/taipei/restaurant/hsiao-cho-chih-chia|$$|CAT_P02|bib|tw|2026-10-30T15:21:10Z
ve_ed743bab06|us/en/zhe-jiang/hangzhou_1027184/restaurant/fu-yuan-ju-shangcheng|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:11Z
ve_ed781f677a|us/en/jiang-su/suzhou_1031079/restaurant/bai-sheng-ren-jia-wuzhong|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:13Z
ve_ed8fe96699|us/en/beijing-municipality/beijing/restaurant/xin-rong-ji-xinyuan-south-road|¥¥¥¥|CAT_P04|3 star|cn|2026-10-30T15:21:14Z
ve_eda15577f1|us/en/fujian-province/ningde/restaurant/hu-yu-zhong-wu-qu-bian-rou|¥|CAT_P01|bib|cn|2026-10-30T15:21:15Z
ve_edc5ed438c|us/en/beijing-municipality/beijing/restaurant/shanghai-cuisine|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:21:17Z
ve_edc7493c3b|us/en/beijing-municipality/beijing/restaurant/trb-hutong|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:21:18Z
ve_edd7b52006|us/en/zhe-jiang/taizhou_7770462/restaurant/he-wei-xiao-chao|¥|CAT_P01|bib|cn|2026-10-30T15:21:19Z
ve_eeb6efed57|us/en/beijing-municipality/beijing/restaurant/tan-1218718|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:21Z
ve_ef15c92b52|us/en/shanghai-municipality/shanghai/restaurant/yi-long-court|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:21:22Z
ve_efe34c1826|us/en/taichung-region/taichung/restaurant/night-school-braised-pork-rice|$|CAT_P01|bib|tw|2026-10-30T15:21:23Z
ve_eff1768dd7|us/en/northern-taiwan/hsinchu-county_2853127/restaurant/shan-guo-tang|$$|CAT_P02|bib|tw|2026-10-30T15:21:25Z
ve_f0739c29ee|us/en/zhe-jiang/taizhou_7770462/restaurant/lao-huang-chao-ma-ci|¥|CAT_P01|bib|cn|2026-10-30T15:21:26Z
ve_f12636cf86|us/en/kaohsiung-region/kaohsiung/restaurant/the-front-house|$$$|CAT_P03|1 star|tw|2026-10-30T15:21:27Z
ve_f18b4ed788|us/en/taipei-region/taipei/restaurant/lao-shan-dong-homemade-noodles|$|CAT_P01|bib|tw|2026-10-30T15:21:29Z
ve_f1a0a54c6d|us/en/zhe-jiang/hangzhou_1027184/restaurant/xin-liu-he|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:30Z
ve_f1bfe13e78|us/en/shanghai-municipality/shanghai/restaurant/easeful-cuisine|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:31Z
ve_f2f22f4cec|us/en/taipei-region/taipei/restaurant/t-t|$$$|CAT_P03|1 star|tw|2026-10-30T15:21:33Z
ve_f32bd5d54f|us/en/taipei-region/taipei/restaurant/circum|$$$|CAT_P03|1 star|tw|2026-10-30T15:21:34Z
ve_f4a69bd8e0|us/en/beijing-municipality/beijing/restaurant/chao-shang-chao|¥¥¥¥|CAT_P04|3 star|cn|2026-10-30T15:21:35Z
ve_f5558579ff|us/en/zhe-jiang/hangzhou_1027184/restaurant/yu-zhi-lan-1217657|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:21:37Z
ve_f62c27d4bf|us/en/fujian-province/quanzhou_1030272/restaurant/de-wen-xia-zai-mian|¥|CAT_P01|bib|cn|2026-10-30T15:21:38Z
ve_f6bb8ab869|us/en/tainan-region/tainan/restaurant/fu-tai-table-third-generation|$|CAT_P01|bib|tw|2026-10-30T15:21:39Z
ve_f758f5878a|us/en/taipei-region/taipei/restaurant/jen-ho-yuan|$$|CAT_P02|bib|tw|2026-10-30T15:21:41Z
ve_f8917f2b64|us/en/fujian-province/xiamen_1031934/restaurant/wu-tang-sha-cha-mian|¥|CAT_P01|bib|cn|2026-10-30T15:21:42Z
ve_f8b893eeff|us/en/taipei-region/taipei/restaurant/soft-power|$|CAT_P01|bib|tw|2026-10-30T15:21:43Z
ve_f9a80a0cc1|us/en/beijing-municipality/beijing/restaurant/lei-garden-jinbao-tower|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:21:45Z
ve_fa111c5154|us/en/taipei-region/taipei/restaurant/su-lai-chuan|$|CAT_P01|bib|tw|2026-10-30T15:21:46Z
ve_fa442b75d7|us/en/shanghai-municipality/shanghai/restaurant/le-comptoir-de-pierre-gagnaire|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:21:47Z
ve_fa5e39740d|us/en/chengdu-municipality/chengdu/restaurant/zeng-niu-rou-qingyang|¥|CAT_P01|bib|cn|2026-10-30T15:21:49Z
ve_fa7734074b|us/en/zhe-jiang/wenzhou_1031793/restaurant/ayu-renjiashao|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:50Z
ve_faf602fed0|us/en/shanghai-municipality/shanghai/restaurant/ming-court-570629|¥¥¥|CAT_P03|1 star|cn|2026-10-30T15:21:51Z
ve_fb2d8a30a9|us/en/beijing-municipality/beijing/restaurant/jingyi|¥|CAT_P01|bib|cn|2026-10-30T15:21:53Z
ve_fb81fae00f|us/en/shanghai-municipality/shanghai/restaurant/jin-xuan|¥¥¥¥|CAT_P04|1 star|cn|2026-10-30T15:21:54Z
ve_fbbf6d56c4|us/en/beijing-municipality/beijing/restaurant/bao-du-jin-sheng-long|¥¥|CAT_P02|bib|cn|2026-10-30T15:21:55Z
ve_fe25f22c59|us/en/zhe-jiang/wenzhou_1031793/restaurant/xue-miao-zhu-zang-fen|¥|CAT_P01|bib|cn|2026-10-30T15:21:57Z
ve_fe3988645e|us/en/taipei-region/taipei/restaurant/little-tree-food-da-an-road|$$|CAT_P02|bib|tw|2026-10-30T15:21:58Z
ve_fe82420389|us/en/zhe-jiang/taizhou_7770462/restaurant/li-ji-gu-tou-tang|¥|CAT_P01|bib|cn|2026-10-30T15:21:59Z
ve_feb8000925|us/en/jiang-su/nanjing_1029511/restaurant/fu-lin-xuan-jiqingmen-street|¥¥|CAT_P02|bib|cn|2026-10-30T15:22:01Z$r$;
  rel jsonb;
  n_exp int := 455;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count before is not 7582'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 147 THEN RAISE EXCEPTION 'ledger max before is not 147'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 117344 THEN RAISE EXCEPTION 'audit max before is not 117344'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '5a7840c23535d80c06f1a220a86ed7d30e6e63b434a1c2c2f74cd9e81bce5948' THEN RAISE EXCEPTION 'relay sha256'; END IF;
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
  IF v_fp <> 'd6b7ca00b59b46025dda673c6e4547ef' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '9e3543f58a6207673ed65d955a61abc2' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows: the legacy price rows of the relay venues, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '2b5e68dd641233908e58153ab8ab44be' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;

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
          'price-card:price-michelin-card-p2-b8-2026-10-30 | block A step 2 batch 8 (China + Taiwan, 457 venues): legacy price rows with no URL, active Michelin star/Bib venues with a card URL | '
          || n_exp || ' rows updated from legacy (CNY 316, TWD 139) | live card read, built-in browser | relay md5 d6b7ca00b59b46025dda673c6e4547ef')
  RETURNING id INTO v_lid;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid <> 148 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 117344) <> n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 117344 AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
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
