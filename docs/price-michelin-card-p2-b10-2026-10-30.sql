-- price-michelin-card-p2-b10-2026-10-30.sql
-- Block A, step 2, batch 10 (United States, 146 venues).
-- Population P2: active venues with a Michelin One Star, Two Stars, Three Stars or Bib Gourmand row whose source_url is
-- a guide.michelin.com card URL (latest by year desc, id desc), and a price row with source legacy_guide and no source_url.
-- Source: the live Michelin card page (Price: line, data-sheet), read in the built-in browser.
-- Rows: 146 UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
-- source_url = card URL, symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
-- captured_at = read time). Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026).
-- Cards that show Selected only are also updated; award rows do not change (Ben, Oct 30, 2026; Oct 10 ruling).
-- Currencies: USD 146. Card tiers: 1 = 19, 2 = 75, 3 = 18, 4 = 34. Card distinction: 1 star 42, 2 star 2, bib 102.
-- Relay sha256 496cb95b41a1c99bd2065541b1723f3e63a67d68f0cc06584de25e5ca2d8c104 (inside this file).
-- Guards: counts before (price 7582, ledger max 149, audit max 118228); relay fingerprint md5
-- d247e219b2de3354c1d3284a616aa8ab; venue id md5 ab89145314745ccfc3095d581cb74582; old price rows md5 1fa0af67bbce8290f1d1eb204a9e0ce8;
-- each row in P2 now with the same card URL.
-- Post-checks: price count 7582 (unchanged); ledger 150; audit 146 price UPDATE rows, nothing else;
-- each price row now matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_027dca0101|us/en/texas/austin_2958315/restaurant/franklin-barbecue|$$|CAT_P02|bib|us|2026-10-30T16:35:32.259Z
ve_04509480d4|us/en/louisiana/new-orleans_2906000/restaurant/lufu-nola|$$|CAT_P02|bib|us|2026-10-30T16:35:33.632Z
ve_051574d412|us/en/north-carolina/asheville_2147494/restaurant/mother-1241183|$$|CAT_P02|bib|us|2026-10-30T16:35:34.983Z
ve_059ad5aef5|us/en/colorado/denver_1261491/restaurant/bruto|$$$$|CAT_P04|1 star|us|2026-10-30T16:35:36.233Z
ve_0678615d14|us/en/georgia/atlanta_2884144/restaurant/the-busy-bee|$$|CAT_P02|bib|us|2026-10-30T16:35:37.583Z
ve_07202716ee|us/en/texas/seguin_2958298/restaurant/burnt-bean-co|$$|CAT_P02|bib|us|2026-10-30T16:35:38.922Z
ve_0a2ed5219a|us/en/georgia/atlanta_2884144/restaurant/bacchanalia-1196004|$$$$|CAT_P04|1 star|us|2026-10-30T16:35:40.167Z
ve_0a354cbf5a|us/en/texas/houston_2986624/restaurant/papalo-taqueria|$|CAT_P01|bib|us|2026-10-30T16:35:41.509Z
ve_0a702c2a37|us/en/colorado/denver_1261491/restaurant/kizaki|$$$$|CAT_P04|1 star|us|2026-10-30T16:35:42.844Z
ve_0e99e24eb3|us/en/texas/austin_2958315/restaurant/cuantos-tacos|$|CAT_P01|bib|us|2026-10-30T16:35:44.251Z
ve_0ef83029cf|us/en/texas/austin_2958315/restaurant/interstellar-bbq|$$|CAT_P02|1 star|us|2026-10-30T16:35:45.591Z
ve_0f90fac3c8|us/en/louisiana/new-orleans_2906000/restaurant/turkey-and-the-wolf|$|CAT_P01|bib|us|2026-10-30T16:35:46.961Z
ve_0fda0669c2|us/en/colorado/denver_1261491/restaurant/hop-alley|$$|CAT_P02|bib|us|2026-10-30T16:35:48.315Z
ve_133540c07a|us/en/tennessee/nashville_2790527/restaurant/kisser|$$|CAT_P02|bib|us|2026-10-30T16:35:49.673Z
ve_149603bb4c|us/en/texas/spring_2986734/restaurant/corkscrew-bbq|$$|CAT_P02|1 star|us|2026-10-30T16:35:51.026Z
ve_15cd23fa6f|us/en/texas/tomball_2987082/restaurant/tejas-chocolate|$$|CAT_P02|bib|us|2026-10-30T16:35:52.367Z
ve_16470bde41|us/en/georgia/atlanta_2884144/restaurant/fred-s-meat-bread|$|CAT_P01|bib|us|2026-10-30T16:35:53.736Z
ve_16547d8aaf|us/en/colorado/denver_1261491/restaurant/the-ginger-pig|$$|CAT_P02|bib|us|2026-10-30T16:35:55.112Z
ve_183de4be53|us/en/louisiana/new-orleans_2906000/restaurant/cochon-butcher|$$|CAT_P02|bib|us|2026-10-30T16:35:56.479Z
ve_198d219342|us/en/colorado/boulder_1261512/restaurant/cozobi-fonda-fina|$$|CAT_P02|bib|us|2026-10-30T16:35:57.837Z
ve_1a38a681aa|us/en/georgia/marietta_2884138/restaurant/spring-1210096|$$$$|CAT_P04|1 star|us|2026-10-30T16:35:59.209Z
ve_1b61246e2c|us/en/texas/austin_2958315/restaurant/dai-due|$$|CAT_P02|bib|us|2026-10-30T16:36:00.580Z
ve_1bf9937c5b|us/en/texas/houston_2986624/restaurant/rosie-cannonball|$$|CAT_P02|bib|us|2026-10-30T16:36:01.977Z
ve_1ceb065bb0|us/en/texas/dallas_2954570/restaurant/ngon-vietnamese-kitchen|$$|CAT_P02|bib|us|2026-10-30T16:36:03.338Z
ve_1d120c74fb|us/en/texas/san-antonio_2958156/restaurant/the-jerk-shack|$|CAT_P01|bib|us|2026-10-30T16:36:04.682Z
ve_23439113f9|us/en/mississippi/jackson_2919677/restaurant/sacred-ground-barbecue|$$|CAT_P02|bib|us|2026-10-30T16:36:06.016Z
ve_2925ba1328|us/en/tennessee/nashville_2790527/restaurant/uzbegim|$|CAT_P01|bib|us|2026-10-30T16:36:07.388Z
ve_2ac28e8e1e|us/en/south-carolina/charleston_2952029/restaurant/vern-s|$$$|CAT_P03|1 star|us|2026-10-30T16:36:08.759Z
ve_2b170a2ed7|us/en/louisiana/new-orleans_2906000/restaurant/cochon|$$|CAT_P02|bib|us|2026-10-30T16:36:10.120Z
ve_2b78d5a995|us/en/south-carolina/charleston_2952029/restaurant/malagon-mercado-y-taperia|$$|CAT_P02|1 star|us|2026-10-30T16:36:11.453Z
ve_2c003e4230|us/en/georgia/atlanta_2884144/restaurant/heirloom-market-bbq|$$|CAT_P02|bib|us|2026-10-30T16:36:12.793Z
ve_2d80e6f1be|us/en/texas/houston_2986624/restaurant/le-jardinier-houston|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:14.147Z
ve_2f53612809|us/en/texas/san-antonio_2958156/restaurant/ladino|$$|CAT_P02|bib|us|2026-10-30T16:36:15.494Z
ve_305ffe56a5|us/en/tennessee/nashville_2790527/restaurant/bastion-1214985|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:16.831Z
ve_3a7ac84485|us/en/colorado/denver_1261491/restaurant/la-diabla-pozole-y-mezcal|$$|CAT_P02|bib|us|2026-10-30T16:36:18.188Z
ve_3afe9a3d98|us/en/texas/houston_2986624/restaurant/nancy-s-hustle|$$|CAT_P02|bib|us|2026-10-30T16:36:19.547Z
ve_3c2ad8d111|us/en/texas/houston_2986624/restaurant/nobie-s|$$|CAT_P02|bib|us|2026-10-30T16:36:20.891Z
ve_3c782ed879|us/en/texas/houston_2986624/restaurant/march|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:22.257Z
ve_3c936a3b52|us/en/colorado/denver_1261491/restaurant/makfam|$|CAT_P01|bib|us|2026-10-30T16:36:23.605Z
ve_3ceab91f49|us/en/texas/dallas_2954570/restaurant/mot-hai-ba|$$|CAT_P02|bib|us|2026-10-30T16:36:24.982Z
ve_3e20a18996|us/en/texas/houston_2986624/restaurant/the-pit-room|$$|CAT_P02|bib|us|2026-10-30T16:36:26.330Z
ve_3fbb33695d|us/en/texas/austin_2958315/restaurant/veracruz-fonda-bar|$$|CAT_P02|bib|us|2026-10-30T16:36:27.689Z
ve_406833c260|us/en/louisiana/new-orleans_2906000/restaurant/mister-mao|$$|CAT_P02|bib|us|2026-10-30T16:36:29.067Z
ve_41c2e6a68a|us/en/texas/houston_2986624/restaurant/truth-bbq|$$|CAT_P02|bib|us|2026-10-30T16:36:30.423Z
ve_421719c2c8|us/en/texas/austin_2958315/restaurant/hestia|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:31.789Z
ve_45bf3594ba|us/en/texas/dallas_2954570/restaurant/nonna|$$$|CAT_P03|bib|us|2026-10-30T16:36:33.178Z
ve_45c836720b|us/en/texas/austin_2958315/restaurant/briscuits|$$|CAT_P02|bib|us|2026-10-30T16:36:34.535Z
ve_4b248cb84b|us/en/texas/san-antonio_2958156/restaurant/southerleigh-fine-food-brewery|$$$|CAT_P03|bib|us|2026-10-30T16:36:35.892Z
ve_4b4567b1e3|us/en/south-carolina/greenville_2952122/restaurant/scoundrel|$$$|CAT_P03|1 star|us|2026-10-30T16:36:37.150Z
ve_4c0b829f4f|us/en/texas/austin_2958315/restaurant/kemuri-tatsu-ya|$$|CAT_P02|bib|us|2026-10-30T16:36:38.508Z
ve_4d9e9050e6|us/en/texas/austin_2958315/restaurant/barley-swine|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:39.838Z
ve_4e51697d5a|us/en/georgia/atlanta_2884144/restaurant/atlas|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:41.197Z
ve_4fffd43831|us/en/louisiana/new-orleans_2906000/restaurant/hungry-eyes|$$|CAT_P02|bib|us|2026-10-30T16:36:42.543Z
ve_54115e71ea|us/en/tennessee/nashville_2790527/restaurant/peninsula-1215049|$$$|CAT_P03|bib|us|2026-10-30T16:36:43.889Z
ve_5a622386fb|us/en/georgia/atlanta_2884144/restaurant/whoopsie-s|$$|CAT_P02|bib|us|2026-10-30T16:36:45.233Z
ve_61a453ed5d|us/en/texas/houston_2986624/restaurant/pinkerton-s-bbq|$$|CAT_P02|bib|us|2026-10-30T16:36:46.482Z
ve_643b43e09f|us/en/texas/fort-worth_2954653/restaurant/goldee-s|$$|CAT_P02|1 star|us|2026-10-30T16:36:47.836Z
ve_6529ae0590|us/en/tennessee/nashville_2790527/restaurant/the-catbird-seat|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:49.181Z
ve_65a9abbc0b|us/en/texas/austin_2958315/restaurant/la-santa-barbacha|$|CAT_P01|bib|us|2026-10-30T16:36:50.554Z
ve_66772d3ed1|us/en/texas/houston_2986624/restaurant/theodore-rex|$$$|CAT_P03|bib|us|2026-10-30T16:36:51.908Z
ve_6683b09d8e|us/en/georgia/atlanta_2884144/restaurant/hayakawa|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:53.274Z
ve_68e8796030|us/en/colorado/boulder_1261512/restaurant/frasca-food-and-wine|$$$$|CAT_P04|1 star|us|2026-10-30T16:36:54.643Z
ve_690206fe34|us/en/georgia/avondale-estates_2884153/restaurant/arepa-mia|$$|CAT_P02|bib|us|2026-10-30T16:36:55.897Z
ve_6b248c2fcb|us/en/colorado/denver_1261491/restaurant/mister-oso|$$|CAT_P02|bib|us|2026-10-30T16:36:57.256Z
ve_7569b3cee9|us/en/georgia/atlanta_2884144/restaurant/antico-pizza-napoletana|$|CAT_P01|bib|us|2026-10-30T16:36:58.600Z
ve_7976a1ce68|us/en/colorado/denver_1261491/restaurant/mezcaleria-alma|$$$|CAT_P03|1 star|us|2026-10-30T16:36:59.964Z
ve_7a0319b152|us/en/colorado/denver_1261491/restaurant/beckon|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:01.325Z
ve_80632217e6|us/en/texas/houston_2986624/restaurant/bcn-taste-tradition|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:02.689Z
ve_81f42fb289|us/en/texas/austin_2958315/restaurant/mercado-sin-nombre|$|CAT_P01|bib|us|2026-10-30T16:37:04.033Z
ve_82c2c3a23d|us/en/texas/austin_2958315/restaurant/parish-barbecue|$$|CAT_P02|bib|us|2026-10-30T16:37:05.371Z
ve_83d07e16bb|us/en/colorado/denver_1261491/restaurant/margot-1241646|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:06.734Z
ve_85577c3e90|us/en/louisiana/new-orleans_2906000/restaurant/dooky-chase|$$|CAT_P02|bib|us|2026-10-30T16:37:08.108Z
ve_87d73fa1ae|us/en/colorado/denver_1261491/restaurant/tavernetta|$$$|CAT_P03|bib|us|2026-10-30T16:37:09.463Z
ve_87ea6ff8f0|us/en/north-carolina/asheville_2147494/restaurant/little-chango|$|CAT_P01|bib|us|2026-10-30T16:37:10.803Z
ve_87f46d270a|us/en/texas/houston_2986624/restaurant/ema-1214429|$|CAT_P01|bib|us|2026-10-30T16:37:12.134Z
ve_88772dcc74|us/en/texas/san-antonio_2958156/restaurant/isidore|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:13.473Z
ve_89ee75c2fa|us/en/tennessee/memphis_2788663/restaurant/hog-hominy|$$|CAT_P02|bib|us|2026-10-30T16:37:14.805Z
ve_8b2e19270b|us/en/tennessee/chattanooga_2790931/restaurant/little-coyote|$$|CAT_P02|bib|us|2026-10-30T16:37:16.147Z
ve_8c183ed2b6|us/en/louisiana/new-orleans_2906000/restaurant/acamaya|$$|CAT_P02|bib|us|2026-10-30T16:37:17.511Z
ve_8c3871b684|us/en/texas/houston_2986624/restaurant/musaafer|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:18.865Z
ve_8cbf1bc738|us/en/colorado/aspen_1262302/restaurant/bosq-1206081|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:20.196Z
ve_8dbf8709c5|us/en/texas/san-antonio_2958156/restaurant/cullum-s-attaboy|$$|CAT_P02|bib|us|2026-10-30T16:37:21.545Z
ve_8e8324d5fe|us/en/georgia/atlanta_2884144/restaurant/o-by-brush|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:22.907Z
ve_9235ac2d13|us/en/texas/dallas_2954570/restaurant/gemma-1196492|$$$|CAT_P03|bib|us|2026-10-30T16:37:24.256Z
ve_92523d0b1e|us/en/louisiana/new-orleans_2906000/restaurant/saint-germain|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:25.615Z
ve_9286e0efb2|us/en/texas/austin_2958315/restaurant/craft-omakase|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:26.946Z
ve_92b0a196fe|us/en/texas/lockhart_2958209/restaurant/barbs-b-q|$$|CAT_P02|bib|us|2026-10-30T16:37:28.278Z
ve_940cdef65f|us/en/texas/austin_2958315/restaurant/micklethwait-craft-meats|$$|CAT_P02|bib|us|2026-10-30T16:37:29.621Z
ve_9969ef4d4f|us/en/north-carolina/asheville_2147494/restaurant/luminosa|$$|CAT_P02|bib|us|2026-10-30T16:37:30.975Z
ve_99e24dc483|us/en/texas/austin_2958315/restaurant/odd-duck|$$$|CAT_P03|bib|us|2026-10-30T16:37:32.229Z
ve_9a0cb6065b|us/en/tennessee/nashville_2790527/restaurant/redheaded-stranger|$|CAT_P01|bib|us|2026-10-30T16:37:33.616Z
ve_9ac7950879|us/en/texas/austin_2958315/restaurant/kg-bbq|$$|CAT_P02|bib|us|2026-10-30T16:37:34.973Z
ve_9d2047e66f|us/en/north-carolina/raleigh_2149711/restaurant/sam-jones-bbq|$|CAT_P01|bib|us|2026-10-30T16:37:36.331Z
ve_9e74ef1987|us/en/alabama/birmingham_2870441/restaurant/bayonet|$$|CAT_P02|bib|us|2026-10-30T16:37:37.679Z
ve_9e8d5ff94c|us/en/mississippi/jackson_2919677/restaurant/elvie-s|$$$|CAT_P03|bib|us|2026-10-30T16:37:39.020Z
ve_9f5cf63b71|us/en/georgia/atlanta_2884144/restaurant/bomb-biscuit-co|$|CAT_P01|bib|us|2026-10-30T16:37:40.364Z
ve_a1e9245503|us/en/colorado/denver_1261491/restaurant/glo-noodle-house|$$|CAT_P02|bib|us|2026-10-30T16:37:41.703Z
ve_a278b8a6da|us/en/texas/houston_2986624/restaurant/maximo-1218096|$$|CAT_P02|bib|us|2026-10-30T16:37:43.070Z
ve_a42a74280b|us/en/texas/spring_2986734/restaurant/belly-of-the-beast|$$|CAT_P02|bib|us|2026-10-30T16:37:44.416Z
ve_a4b6c65ad1|us/en/south-carolina/charleston_2952029/restaurant/leon-s-oyster-shop|$$|CAT_P02|bib|us|2026-10-30T16:37:45.782Z
ve_a874422d77|us/en/texas/austin_2958315/restaurant/nixta-taqueria|$$|CAT_P02|bib|us|2026-10-30T16:37:47.138Z
ve_abdb64f6ae|us/en/texas/houston_2986624/restaurant/da-gama-canteen|$$|CAT_P02|bib|us|2026-10-30T16:37:48.480Z
ve_ac5785c449|us/en/texas/san-antonio_2958156/restaurant/mixtli|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:49.843Z
ve_acf9fb758c|us/en/texas/houston_2986624/restaurant/mala-sichuan-bistro|$$|CAT_P02|bib|us|2026-10-30T16:37:51.187Z
ve_ad96e779fa|us/en/texas/houston_2986624/restaurant/annam|$$$|CAT_P03|bib|us|2026-10-30T16:37:52.535Z
ve_aecd5da318|us/en/alabama/birmingham_2870441/restaurant/la-fete|$$|CAT_P02|bib|us|2026-10-30T16:37:53.882Z
ve_b1638f89b3|us/en/texas/dallas_2954570/restaurant/mamani|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:55.251Z
ve_b7459176eb|us/en/louisiana/new-orleans_2906000/restaurant/parkway-bakery-tavern|$|CAT_P01|bib|us|2026-10-30T16:37:56.607Z
ve_b74cb31f78|us/en/texas/dallas_2954570/restaurant/tatsu-dallas|$$$$|CAT_P04|1 star|us|2026-10-30T16:37:57.971Z
ve_be9de9e1fa|us/en/colorado/denver_1261491/restaurant/ash-kara|$$$|CAT_P03|bib|us|2026-10-30T16:37:59.331Z
ve_c50bc40f8a|us/en/texas/houston_2986624/restaurant/tatemo|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:00.667Z
ve_c55c51d4a9|us/en/georgia/atlanta_2884144/restaurant/estrellita|$$|CAT_P02|bib|us|2026-10-30T16:38:02.016Z
ve_c578547312|us/en/louisiana/new-orleans_2906000/restaurant/domilise-s-po-boy-bar|$|CAT_P01|bib|us|2026-10-30T16:38:03.263Z
ve_c57906eb91|us/en/colorado/denver_1261491/restaurant/alma-fonda-fina|$$$|CAT_P03|1 star|us|2026-10-30T16:38:04.616Z
ve_c75054a62d|us/en/georgia/atlanta_2884144/restaurant/fishmonger|$$|CAT_P02|bib|us|2026-10-30T16:38:05.969Z
ve_c8d6e35576|us/en/alabama/mobile_2870561/restaurant/the-noble-south|$$|CAT_P02|bib|us|2026-10-30T16:38:07.298Z
ve_c931bd1f24|us/en/tennessee/nashville_2790527/restaurant/st-vito-focacceria|$$|CAT_P02|bib|us|2026-10-30T16:38:08.653Z
ve_c9b0592d46|us/en/tennessee/nashville_2790527/restaurant/locust|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:10.001Z
ve_cac24c5056|us/en/texas/bellaire_2959890/restaurant/blood-bros-bbq|$$|CAT_P02|bib|us|2026-10-30T16:38:11.352Z
ve_cb7248b3a0|us/en/texas/austin_2958315/restaurant/emmer-rye|$$$|CAT_P03|bib|us|2026-10-30T16:38:12.596Z
ve_cca4f35717|us/en/texas/spring_2986734/restaurant/rosemeyer-bar-b-q|$$|CAT_P02|bib|us|2026-10-30T16:38:13.944Z
ve_d3f02d0ccc|us/en/louisiana/new-orleans_2906000/restaurant/emeril-s|$$$|CAT_P03|2 star|us|2026-10-30T16:38:15.309Z
ve_d5d8afd717|us/en/georgia/atlanta_2884144/restaurant/omakase-table|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:16.659Z
ve_d68607a0fc|us/en/texas/dallas_2954570/restaurant/cattleack-barbeque|$$|CAT_P02|bib|us|2026-10-30T16:38:17.908Z
ve_d98a2019c9|us/en/texas/houston_2986624/restaurant/nam-giao|$|CAT_P01|bib|us|2026-10-30T16:38:19.246Z
ve_d9e28a8c8e|us/en/texas/pearland_2986629/restaurant/killen-s-bbq|$$|CAT_P02|bib|us|2026-10-30T16:38:20.608Z
ve_dd3377d2a9|us/en/louisiana/new-orleans_2906000/restaurant/saba-1203232|$$|CAT_P02|bib|us|2026-10-30T16:38:21.953Z
ve_df10a7fbbe|us/en/colorado/boulder_1261512/restaurant/basta|$$|CAT_P02|bib|us|2026-10-30T16:38:23.317Z
ve_df22614e29|us/en/georgia/atlanta_2884144/restaurant/lazy-betty|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:24.676Z
ve_e00ab3eeee|us/en/tennessee/nashville_2790527/restaurant/ss-gai|$$|CAT_P02|bib|us|2026-10-30T16:38:26.072Z
ve_e4be6c2af6|us/en/north-carolina/charlotte_2987283/restaurant/counter|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:27.450Z
ve_e6f4312f7c|us/en/georgia/atlanta_2884144/restaurant/little-bear|$$|CAT_P02|bib|us|2026-10-30T16:38:28.794Z
ve_e7242c6433|us/en/south-carolina/charleston_2952029/restaurant/wild-common|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:30.145Z
ve_e7f3720ffe|us/en/north-carolina/knightdale_2149824/restaurant/prime-barbecue|$$|CAT_P02|bib|us|2026-10-30T16:38:31.466Z
ve_eae5522238|us/en/north-carolina/charlotte_2987283/restaurant/lang-van|$|CAT_P01|bib|us|2026-10-30T16:38:32.804Z
ve_eb298ae7b7|us/en/tennessee/nashville_2790527/restaurant/sho-pizza-bar|$$|CAT_P02|bib|us|2026-10-30T16:38:34.075Z
ve_ec88e3b3fd|us/en/north-carolina/raleigh_2149711/restaurant/mala-pata|$$|CAT_P02|bib|us|2026-10-30T16:38:35.402Z
ve_edfbed50ed|us/en/colorado/denver_1261491/restaurant/the-wolf-s-tailor|$$$$|CAT_P04|2 star|us|2026-10-30T16:38:36.776Z
ve_f1659c7842|us/en/texas/houston_2986624/restaurant/chopnblok|$$|CAT_P02|bib|us|2026-10-30T16:38:38.127Z
ve_f61163430a|us/en/texas/san-antonio_2958156/restaurant/nicosi|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:39.499Z
ve_f6e16a7e67|us/en/alabama/birmingham_2870441/restaurant/ovenbird|$$|CAT_P02|bib|us|2026-10-30T16:38:40.838Z
ve_f900f0303b|us/en/alabama/birmingham_2870441/restaurant/pizza-grace|$$|CAT_P02|bib|us|2026-10-30T16:38:42.187Z
ve_fa852c4bab|us/en/louisiana/new-orleans_2906000/restaurant/zasu|$$$|CAT_P03|1 star|us|2026-10-30T16:38:43.547Z
ve_fccd682917|us/en/georgia/atlanta_2884144/restaurant/mujo|$$$$|CAT_P04|1 star|us|2026-10-30T16:38:44.886Z
ve_ff5f007ff8|us/en/texas/san-antonio_2958156/restaurant/mezquite|$$$|CAT_P03|bib|us|2026-10-30T16:38:46.144Z
ve_ffaacc86dd|us/en/texas/austin_2958315/restaurant/distant-relatives|$$|CAT_P02|bib|us|2026-10-30T16:38:47.487Z$r$;
  rel jsonb;
  n_exp int := 146;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count before is not 7582'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 149 THEN RAISE EXCEPTION 'ledger max before is not 149'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118228 THEN RAISE EXCEPTION 'audit max before is not 118228'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '496cb95b41a1c99bd2065541b1723f3e63a67d68f0cc06584de25e5ca2d8c104' THEN RAISE EXCEPTION 'relay sha256'; END IF;
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
  IF v_fp <> 'd247e219b2de3354c1d3284a616aa8ab' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> 'ab89145314745ccfc3095d581cb74582' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows: the legacy price rows of the relay venues, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '1fa0af67bbce8290f1d1eb204a9e0ce8' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;

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
          'price-card:price-michelin-card-p2-b10-2026-10-30 | block A step 2 batch 10 (United States, 146 venues): legacy price rows with no URL, active Michelin star/Bib venues with a card URL | '
          || n_exp || ' rows updated from legacy (USD 146) | live card read, built-in browser | relay md5 d247e219b2de3354c1d3284a616aa8ab')
  RETURNING id INTO v_lid;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid <> 150 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118228) <> n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 118228 AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
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
