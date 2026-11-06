-- load-michelin-2026-singapore-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Singapore 2026 edition. Ben choices 1-8:A, Nov 5 20:49 ET. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the ceremony was Aug 4, 2026, after June 1, so the 126 legacy rows hold the 2025 edition (article of Jul 24, 2025: https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025). They stay as 2025 history. Relabel 0, retire 0.
-- 142 new rows, year 2026, with the /us/en/ card URL: Three Stars 3, Two Stars 9, One Star 33, Bib Gourmand 97 (https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2026).
-- 17 new venues, card name, restaurant, active, published.
-- 2025 edition rows added: 4. Closures: 2.
-- Source: docs/michelin-2026-singapore-2026-11-05/relay-sg-2026-list-pages-2026-11-05.txt sha256 d6df72b17a315fd238ee56d19edadabdcbd073c1ae51cab391dad330b1605d8c.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11691 (active 11384, closed 307); awards 28519; slugs 13635; listings 11691; labels 24789; cities 3321, sum 11384; ledger 264 rows; Michelin 2025/2026/2027 4600/7073/122; audit_log +236.
BEGIN;
DO $load$
DECLARE
  aw text := $plan$ve_002141a22b|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jin-ting-wan
ve_0127e72f1b|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/boon-tong-kee-balestier-road
ve_06e63a5d42|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/bahrakath-mutton-soup
ve_0c856ed715|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/saint-pierre
ve_17558af4cf|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lixin-teochew-fishball-noodles
ve_1882d162a4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/beach-road-fish-head-bee-hoon
ve_1c011e6ff0|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jalan-sultan-prawn-mee
ve_1cb7a45f01|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jaan-by-kirk-westaway
ve_1e48294edc|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/na-na-curry
ve_202c4324ef|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/fei-fei-roasted-%E2%80%A2-noodle
ve_21dcfa3295|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/yhingthai-palace
ve_2389dbd8d0|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/whole-earth
ve_23cace31ff|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lagnaa
ve_24f8177b25|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/koh-brother-pig-s-organ-soup
ve_281d2b5bc6|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/fu-ming-cooked-food
ve_28cd57c885|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/no-18-zion-road-fried-kway-teow
ve_29cab76b7a|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/sushi-sakuta
ve_2b29fdec69|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/kwang-kee-teochew-fish-porridge
ve_2be6384828|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/chai-chuan-tou-yang-rou-tang
ve_2c4893da5a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/du-du-shou-shi
ve_2ced00f8d1|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/summer-pavillion
ve_2cffb4557a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hoo-kee-bak-chang
ve_2de01f07a0|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/tiong-bahru-hainanese-boneless-chicken-rice
ve_307e81d7e0|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/han-kee
ve_31443c7e19|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/spinach-soup
ve_328e74e8e0|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/ar-er-soup
ve_35158ba672|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/nouri
ve_356c3f7e53|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lerouy-1195638
ve_36c7c933c1|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/marguerite
ve_3770989848|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lai-heng-handmade-teochew-kueh
ve_37b84733f8|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/delhi-lahori
ve_389c4c4217|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/whitegrass
ve_38ccf6662d|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/sin-huat-eating-house
ve_3b20f19655|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/chuan-kee-boneless-braised-duck
ve_3e30f0d0b3|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/kitchenman-nasi-lemak
ve_4005ef4503|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hai-nan-xing-zhou-beef-noodle
ve_40613faa1f|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/shoukouwa
ve_435bae01ed|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/kwee-heng
ve_45d3f61ccf|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hui-wei-chilli-ban-mian
ve_48a9a096b3|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/zhi-wei-xian-zion-road-big-prawn-noodle
ve_48d50a4e4b|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/xiu-ji-ikan-bilis-yong-tau-fu
ve_49f1a57a35|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/true-blue-cuisine
ve_4ae884613f|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/willow
ve_4ba1439ca8|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/yong-chun-wan-ton-noodle
ve_4deb0c2986|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/heng
ve_50c31e03ce|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/labyrinth
ve_548686853a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hong-heng-fried-sotong-prawn-mee
ve_57f5944034|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/seroja
ve_5a5a88539c|Three Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/odette
ve_5b38b62991|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/waku-ghin
ve_5cd5ee184b|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/pangium
ve_5f2dde818e|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/chey-sua-carrot-cake
ve_5f96bf1fa5|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/ru-ji-kitchen
ve_6150431a62|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/1887-by-andre
ve_6236dcb2f6|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/loca-niru
ve_677a6f224a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/tai-wah-pork-noodle
ve_67c75dd2eb|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/tai-seng-fish-soup
ve_69c36a3edf|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/singapore-fried-hokkien-mee
ve_6b337647ff|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/heng-kee
ve_6bffb4c7e4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hainan-zi
ve_6d318f5bf2|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/zai-shun-curry-fish-head
ve_6d3ee3a1b4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/muthu-s-curry-little-india
ve_70c9e72ac2|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/song-fish-soup
ve_74af388cd7|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/soh-kee-cooked-food
ve_76e5d38748|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/omakase-stevens
ve_83283d9440|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jason-penang-cuisine
ve_85732683a4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/anglo-indian-shenton-way
ve_85a590ea3b|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/candlenut
ve_88810fb0a1|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lei-garden-501509
ve_88f59221fa|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/iggy-s
ve_8b15474d29|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/tian-tian-hainanese-chicken-rice
ve_8d2be7d991|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hup-kee-fried-oyster-omelette
ve_8d7f7f5336|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/nam-sing-hokkien-fried-mee
ve_8db5a2e230|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/bismillah-biryani
ve_8dbfa11f3a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/yi-pin-wei-braised-duck%EF%BC%8Ekway-chap
ve_8e7c1c6608|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/born
ve_9088daf796|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/meta-570540
ve_9919c621d4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jia-xiang
ve_9bed3015f8|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/to-ricos-guo-shi
ve_9c82f18726|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/araya
ve_9cbb87bdaf|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/margaret-drive-sin-kee-chicken-rice
ve_9cf6b5fe0a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/zhup-zhup
ve_9d087c1721|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/xiangyee
ve_9d877ca6fd|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/ji-ji-noodle-house
ve_a17ba076bd|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/song-fa-bak-kut-teh-new-bridge-road
ve_a1cc871e3a|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/sushi-kimura-1247953
ve_a2766aaafd|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/rajarani-thosai
ve_a29b63593f|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/cut
ve_a2a73f2890|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/wok-hei-hor-fun
ve_a3b0050fdb|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lao-fu-zi-fried-kway-teow
ve_a497b4b94d|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/adam-rd-noo-cheng-big-prawn-noodle
ve_a4ed4683e3|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/a-noodle-story
ve_a6cd4611d3|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/cheok-kee
ve_a881aa8987|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/cloudstreet
ve_a947c882a3|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jungle
ve_aab14ed20a|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/song-kee-teochew-fish-porridge
ve_ad804b758b|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/seng-kee-black-chicken-herbal-soup
ve_ade207892d|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/burnt-ends-1200777
ve_adedc1ce2e|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/j2-famous-crispy-curry-puff
ve_ae801a7622|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hong-kong-yummy-soup
ve_af21932872|Two Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/thevar
ve_afa43188a0|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/sin-heng-claypot-bak-koot-teh
ve_b1b42b2c4c|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/outram-park-fried-kway-teow
ve_b20d4e0428|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/indocafe-the-white-house
ve_b35f990460|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/new-lucky-claypot-rice
ve_b9c64072fb|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/sik-bao-sin-desmond-s-creation
ve_ba6c7780ca|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/yong-fu-1218314
ve_bc1a078378|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/the-coconut-club-1195654
ve_bd4c24ab20|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/king-of-laksa
ve_bf2230cf37|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/imperial-treasure-fine-teochew-cuisine-orchard
ve_c18e6698bd|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/cherry-garden-by-chef-fei
ve_c1a6e2e265|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/nae-um
ve_c1eb69dd87|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/the-blue-ginger-tanjong-pagar
ve_c2e6c8acfb|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hill-street-tai-hwa-pork-noodle
ve_c7544bc540|Three Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/zen
ve_c87089f0b5|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/shisen-hanten
ve_c90e4d51fe|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/fico-1213088
ve_c9606ad3c7|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/ma-cuisine
ve_cb49debd91|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jag
ve_cf392c5f30|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/un-yang-kor-dai
ve_d08c7095be|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/ji-de-lai-hainanese-chicken-rice
ve_d22ba45770|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/summer-palace-501658
ve_d54fcdaf78|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/joo-siah-bak-koot-teh
ve_d8a3b12b83|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/da-shi-jia
ve_d8cdbfd73f|Three Stars|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/les-amis
ve_deac5b49eb|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/tian-nan-xing-minced-pork-noodle
ve_e19c1da802|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/selamat-datang-warong-pak-sapari
ve_e1dc8f6877|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/kelantan-kway-chap-pig-organ-soup
ve_e2325ed446|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/jian-bo-tiong-bahru-shui-kueh
ve_e23bb4c347|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/kotuwa
ve_e252f25bbc|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/sushi-ichi
ve_e43b00d099|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/kok-sen
ve_e4eee7c600|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/tenshima
ve_e7de830b40|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/buona-terra
ve_e889827c8f|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/chef-kang-s-noodle-house
ve_e8f106c916|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/cumi-bali
ve_ec2a970f84|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/boon-keng-road-fish-head-bee-hoon
ve_f28a629cb4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/mp-thai
ve_f6902da1f4|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/heng-heng-cooked-food
ve_f84e29015b|One Star|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/hamamoto
ve_fda8c4766c|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/lian-he-ben-ji-claypot
ve_fe545a4e92|Bib Gourmand|https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/alliance-seafood$plan$;
  nw text := $plan$ve_002141a22b|jin-ting-wan|singapore|ci_d3197fb64e|Singapore|Jin Ting Wan
ve_48d50a4e4b|xiu-ji-ikan-bilis-yong-tau-fu|singapore|ci_d3197fb64e|Singapore|Xiu Ji Ikan Bilis Yong Tau Fu
ve_6150431a62|1887-by-andre|singapore|ci_d3197fb64e|Singapore|1887 by André
ve_6236dcb2f6|loca-niru|singapore|ci_d3197fb64e|Singapore|Loca Niru
ve_8d2be7d991|hup-kee-fried-oyster-omelette|singapore|ci_d3197fb64e|Singapore|Hup Kee Fried Oyster Omelette
ve_8dbfa11f3a|yi-pin-wei-braised-duck-kway-chap|singapore|ci_d3197fb64e|Singapore|Yi Pin Wei Braised Duck．Kway Chap
ve_9919c621d4|jia-xiang|singapore|ci_d3197fb64e|Singapore|Jia Xiang
ve_9d087c1721|xiangyee|singapore|ci_d3197fb64e|Singapore|Xiangyee
ve_a1cc871e3a|sushi-kimura|singapore|ci_d3197fb64e|Singapore|Sushi Kimura +
ve_a2766aaafd|rajarani-thosai|singapore|ci_d3197fb64e|Singapore|Rajarani Thosai
ve_ad804b758b|seng-kee-black-chicken-herbal-soup|singapore|ci_d3197fb64e|Singapore|Seng Kee Black Chicken Herbal Soup
ve_ba6c7780ca|yong-fu|singapore|ci_d3197fb64e|Singapore|Yong Fu
ve_bd4c24ab20|king-of-laksa|singapore|ci_d3197fb64e|Singapore|King of Laksa
ve_c18e6698bd|cherry-garden-by-chef-fei|singapore|ci_d3197fb64e|Singapore|Cherry Garden by Chef Fei
ve_deac5b49eb|tian-nan-xing-minced-pork-noodle|singapore|ci_d3197fb64e|Singapore|Tian Nan Xing Minced Pork Noodle
ve_e4eee7c600|tenshima|singapore|ci_d3197fb64e|Singapore|Tenshima
ve_ec2a970f84|boon-keng-road-fish-head-bee-hoon|singapore|ci_d3197fb64e|Singapore|Boon Keng Road Fish Head Bee Hoon$plan$;
  ay text := $plan$ve_719d6d86e0|One Star|https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025
ve_72e993e4a4|One Star|https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025
ve_8b5854c9bd|One Star|https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025
ve_bf2230cf37|One Star|https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025$plan$;
  cl text := $plan$ve_72e993e4a4|Esora|active|ci_d3197fb64e
ve_8b5854c9bd|Alma by Juan Amador|active|ci_d3197fb64e$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(aw) <> '233fcd284a184503f89e2ddd0bdcf7f7' OR md5(nw) <> '8e8d6c57275a14315a3258b5435afb84' OR md5(ay) <> '96f40d1a442ffc38d78d7b2e67e42f1d' OR md5(cl) <> 'f8de2799be9614f4f9ba561b0e1ed0a8' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Singapore' AND a.year=2025) y;
  IF fp IS DISTINCT FROM 'c57f2885ba6db7b4ef84488917418d16' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore') <> 126 THEN RAISE EXCEPTION 'Singapore Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11674 OR (SELECT count(*) FROM venues WHERE status='active') <> 11369 OR (SELECT count(*) FROM venues WHERE status='closed') <> 305 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28373 OR (SELECT max(id) FROM awards) <> 35544 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4596 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6931 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13618 OR (SELECT count(*) FROM listings) <> 11674 OR (SELECT count(*) FROM city_label_source) <> 24755 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11369 OR (SELECT count(*) FROM source_capture_ledger) <> 261 OR (SELECT max(id) FROM source_capture_ledger) <> 315 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_d3197fb64e') <> 210 THEN RAISE EXCEPTION 'Singapore count before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 126585 OR aud_max <> 132414 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active' AND v.city_id='ci_d3197fb64e');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(ay,E'\n') x);
  IF s IS DISTINCT FROM '42b48116a63ed84d350d467b41bcf9a8' THEN RAISE EXCEPTION '2025 venues %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(ay,E'\n') x)) THEN RAISE EXCEPTION '2025 venue holds Michelin'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x);
  IF s IS DISTINCT FROM (SELECT md5(string_agg(x, E'\n' ORDER BY x COLLATE "C")) FROM regexp_split_to_table(cl,E'\n') x) THEN RAISE EXCEPTION 'closure fingerprint %', s; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x) AND published) <> 2 THEN RAISE EXCEPTION 'closure listings'; END IF;
  -- New venues. The norm_key test is inside the city: Yong Fu in Hong Kong is another restaurant.
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR (v.city_id=split_part(x,'|',4) AND v.norm_key=norm_key(split_part(x,'|',6)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Singapore','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 34 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 142 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: 2025 edition rows absent from the live rows
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2025, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(ay,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'awards 2025 %', n; END IF;
  -- WRITE: closures
  UPDATE venues SET status='closed' WHERE id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x) AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=225 WHERE id='ci_d3197fb64e' AND venues_count=210;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',142,'cleanup:load-michelin-2026-singapore-2026-11-05 | rule 2.1.1 and 2.1.7: ceremony Aug 4, 2026 (https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2026), legacy rows hold the 2025 edition, relabel 0, retire 0 | list read Nov 5, 2026 | relay sha256 d6df72b17a315fd238ee56d19edadabdcbd073c1ae51cab391dad330b1605d8c | Ben choices 1-8:A, Nov 5 20:49 ET'),
    ('michelin','award',4,'cleanup:load-michelin-2026-singapore-2026-11-05 | 2025 edition One Star rows absent from the live rows: Alma, Esora, Euphoria, Imperial Treasure Fine Teochew Cuisine | Chaleur has no venue | https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025 | Ben choices 1-8:A, Nov 5 20:49 ET'),
    ('michelin','city_label',34,'cleanup:load-michelin-2026-singapore-2026-11-05 | city labels of 17 new venues | Ben choices 1-8:A, Nov 5 20:49 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11691 OR (SELECT count(*) FROM venues WHERE status='active') <> 11384 OR (SELECT count(*) FROM venues WHERE status='closed') <> 307 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28519 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 146 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> md5((SELECT string_agg(x, E'\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4600 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7073 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=97,One Star=33,Three Stars=3,Two Stars=9' THEN RAISE EXCEPTION 'Singapore 2026 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore' AND a.year=2025 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=89,One Star=31,Three Stars=3,Two Stars=7' THEN RAISE EXCEPTION 'Singapore 2025 %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13635 OR (SELECT count(*) FROM listings) <> 11691 OR (SELECT count(*) FROM city_label_source) <> 24789 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11384 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 264 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=146,cities:UPDATE=1,city_label_source:INSERT=34,listings:INSERT=17,listings:UPDATE=2,slugs:INSERT=17,venues:INSERT=17,venues:UPDATE=2' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
