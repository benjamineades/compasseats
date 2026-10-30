-- price-michelin-card-p1-rest-2026-10-30.sql
-- Block A, step 3 P1 rest (name search).
-- Population: active venues with a Michelin star/Bib award row, no price row and no card URL (P1 rest, 151 on
-- Oct 30, 2026). Held before the search: Turkey 16 (2025 rows only), Banshee (2024), Zhu Ji Zhi Mian Pu (archive URL).
-- Card found by name in the full Michelin lists (DK, FI, HR, LT, NO, PL, SE, SI, NZ, VN, California, Florida):
-- class A exact name + city 71; class C1 generic words only, same city, same distinction 33 (Ben "agree" 13:32 ET);
-- class C2 address proof on the venue's own website 12. Held after the search: 17 (see handoff).
-- Each relay venue has exactly one Michelin award row: 2026, star or Bib, source_url NULL (guarded).
-- Step 1: 116 UPDATE of awards.source_url (NULL -> card URL). Year, category and all other columns do not change.
-- Step 2: 116 INSERT into price (source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
--         symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
--         captured_at = read time). DK, NO, PL, SE cards show EUR symbols: stored as EUR (Ben "agree" 13:32 ET).
-- Card distinction equals the award category on every row (guarded).
-- Card countries: dk 12, fi 1, hr 4, lt 3, no 3, nz 46, pl 2, se 2, si 1, us 34, vn 8. Currencies: EUR 28, NZD 46, USD 34, VND 8. Card tiers: 1 = 17, 2 = 57, 3 = 16, 4 = 26. Card distinction: 1 star 44, 2 star 1, bib 71.
-- Relay sha256 48656407e2d1b7d95061dc0fe4fdb6644ecc4d7d53c7e798738939da0e8020a5 (inside this file).
-- Guards: counts before (price 7582, ledger max 152, audit max 118393); relay fingerprint md5
-- 4fe7c57b818aae150db124f7d2979430; venue id md5 09f240b3375713bbd6ace8e2e1b17cb2; old Michelin award rows md5 288cb3ef06e580323afe2f218d678c32;
-- latest award id md5 55ec7a7ab62a09da7a69ca2de17a385c; no price row on any relay venue; card URLs not in use on any award row.
-- Post-checks: price count 7698; ledgers 153 (award) and 154 (price);
-- audit 118394 to 118625: 116 awards UPDATE + 116 price INSERT, nothing else; each award and price row matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_00d4d6d264|us/en/south-island/christchurch_2307083/restaurant/gatherings|$$|CAT_P02|bib|nz|2026-10-30T17:33:41.281Z
ve_011fc70ba3|us/en/south-island/queenstown_2306160/restaurant/amisfield|$$$$|CAT_P04|1 star|nz|2026-10-30T17:33:42.625Z
ve_05a5e765a3|us/en/north-island/auckland_2302926/restaurant/paris-butter|$$$|CAT_P03|1 star|nz|2026-10-30T17:33:43.955Z
ve_0628743ad6|us/en/north-island/wellington_2305537/restaurant/jano-bistro|$$$|CAT_P03|1 star|nz|2026-10-30T17:33:45.300Z
ve_0732aa9608|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/banh-cuon-tay-ho-127|₫|CAT_P01|bib|vn|2026-10-30T17:33:46.626Z
ve_0849db628b|us/en/north-island/auckland_2302926/restaurant/parro|$$|CAT_P02|bib|nz|2026-10-30T17:33:47.958Z
ve_0a44a31b38|us/en/south-island/queenstown_2306160/restaurant/sherwood|$$|CAT_P02|1 star|nz|2026-10-30T17:33:49.288Z
ve_0b7f3ea5fb|us/en/capital-region/copenhagen/restaurant/petra-bar-restaurant|€|CAT_P01|bib|dk|2026-10-30T17:33:50.633Z
ve_0d2a2613bc|us/en/california/santa-monica/restaurant/seline|$$$$|CAT_P04|1 star|us|2026-10-30T17:33:51.987Z
ve_0f9ec4e4b7|us/en/north-island/wellington_2305537/restaurant/logan-brown|$$$|CAT_P03|1 star|nz|2026-10-30T17:33:53.331Z
ve_11f14d9320|us/en/california/us-los-angeles/restaurant/corridor-109|$$$$|CAT_P04|1 star|us|2026-10-30T17:33:54.672Z
ve_13663ffad8|us/en/north-island/auckland_2302926/restaurant/boda|$$|CAT_P02|bib|nz|2026-10-30T17:33:56.014Z
ve_15a11d38a2|us/en/florida/sarasota_2987163/restaurant/lucky-8|$$|CAT_P02|bib|us|2026-10-30T17:33:57.261Z
ve_19293e8d21|us/en/north-island/auckland_2302926/restaurant/cazador|$$|CAT_P02|bib|nz|2026-10-30T17:33:58.584Z
ve_196b2bb655|us/en/north-island/auckland_2302926/restaurant/bistro-saine|$$|CAT_P02|bib|nz|2026-10-30T17:33:59.906Z
ve_1c58da1095|us/en/florida/north-miami_2883821/restaurant/mutra|$$$$|CAT_P04|1 star|us|2026-10-30T17:34:01.163Z
ve_1c8cc4a492|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/upstairs|₫₫₫₫|CAT_P04|1 star|vn|2026-10-30T17:39:29.125Z
ve_20545d099c|us/en/california/oakland/restaurant/joodooboo|$$|CAT_P02|bib|us|2026-10-30T17:34:02.525Z
ve_228f6bde8b|us/en/california/san-francisco/restaurant/sorrel|$$$$|CAT_P04|1 star|us|2026-10-30T17:34:03.869Z
ve_23c9c842a2|us/en/zagreb-region/zagreb/restaurant/nure|€|CAT_P01|bib|hr|2026-10-30T17:34:05.200Z
ve_2606c64ac7|us/en/south-island/queenstown_2306160/restaurant/essence-1247217|$$$$|CAT_P04|2 star|nz|2026-10-30T17:39:30.371Z
ve_26113673ef|us/en/south-island/christchurch_2307083/restaurant/roca|$$|CAT_P02|bib|nz|2026-10-30T17:34:06.537Z
ve_2797da32c8|us/en/north-island/wellington_2305537/restaurant/cicio-cacio|$$|CAT_P02|bib|nz|2026-10-30T17:39:31.621Z
ve_27ca9196d7|us/en/uusimaa/helsinki/restaurant/boreal|€€€€|CAT_P04|1 star|fi|2026-10-30T17:34:07.870Z
ve_28735e5aef|us/en/south-island/queenstown_2306160/restaurant/the-cow-queenstown|$$|CAT_P02|bib|nz|2026-10-30T17:34:09.196Z
ve_29e2076287|us/en/capital-region/copenhagen/restaurant/levi|€€|CAT_P02|bib|dk|2026-10-30T17:34:10.528Z
ve_2d651dc5ee|us/en/california/san-francisco/restaurant/wolfsbane|$$$$|CAT_P04|1 star|us|2026-10-30T17:34:11.870Z
ve_3148ec4456|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/la-lola|₫₫|CAT_P02|bib|vn|2026-10-30T17:34:13.197Z
ve_33d2512bc1|us/en/south-island/christchurch_2307083/restaurant/the-athens-yacht-club|$$|CAT_P02|bib|nz|2026-10-30T17:34:14.516Z
ve_3471cf5525|us/en/capital-region/copenhagen/restaurant/graziano|€|CAT_P01|bib|dk|2026-10-30T17:34:15.865Z
ve_3ceedd2541|us/en/california/arcadia/restaurant/laoxi-noodle-house|$|CAT_P01|bib|us|2026-10-30T17:34:17.206Z
ve_41993ac9f8|us/en/florida/north-miami_2883821/restaurant/cotoa|$$|CAT_P02|bib|us|2026-10-30T17:34:18.531Z
ve_42fbd15dca|us/en/california/us-los-angeles/restaurant/little-fish-melrose-hill|$$|CAT_P02|bib|us|2026-10-30T17:34:19.871Z
ve_4820e71d0e|us/en/florida/pensacola_2881736/restaurant/a-mano-panino|$|CAT_P01|bib|us|2026-10-30T17:34:21.197Z
ve_4a4b70518b|us/en/south-island/christchurch_2307083/restaurant/the-monday-room|$$|CAT_P02|bib|nz|2026-10-30T17:34:22.521Z
ve_511c2dae82|us/en/north-island/wellington_2305537/restaurant/indian-alley|$$|CAT_P02|bib|nz|2026-10-30T17:39:32.868Z
ve_51fddc03a1|us/en/south-island/wanaka_2306683/restaurant/francesca|$$|CAT_P02|bib|nz|2026-10-30T17:34:23.855Z
ve_5378290021|us/en/south-island/christchurch_2307083/restaurant/fire-and-slice|$$|CAT_P02|bib|nz|2026-10-30T17:34:25.180Z
ve_550d36061d|us/en/south-island/wanaka_2306683/restaurant/bombay-palace-wanaka|$$|CAT_P02|bib|nz|2026-10-30T17:39:34.117Z
ve_5b7fbcd496|us/en/florida/saint-augustine_2881915/restaurant/bar-citra|$$|CAT_P02|bib|us|2026-10-30T17:34:26.499Z
ve_5d93b584c8|us/en/north-island/auckland_2302926/restaurant/ahi|$$$|CAT_P03|1 star|nz|2026-10-30T17:34:27.846Z
ve_6104079fa4|us/en/south-island/christchurch_2307083/restaurant/tussock-hill|$$$|CAT_P03|1 star|nz|2026-10-30T17:34:29.162Z
ve_66495c1b0a|us/en/california/encinitas_2876781/restaurant/atelier-manna|$$|CAT_P02|bib|us|2026-10-30T17:34:30.487Z
ve_6671f07730|us/en/north-island/auckland_2302926/restaurant/goat-1246393|$$|CAT_P02|bib|nz|2026-10-30T17:34:31.816Z
ve_6930919788|us/en/florida/key-west_2883507/restaurant/moondog-cafe-bakery|$$|CAT_P02|bib|us|2026-10-30T17:39:35.361Z
ve_69e9d7215e|us/en/california/us-sacramento/restaurant/the-kitchen-559371|$$$$|CAT_P04|1 star|us|2026-10-30T17:34:33.134Z
ve_6bdc815126|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/bun-rieu-yen|₫|CAT_P01|bib|vn|2026-10-30T17:34:34.461Z
ve_6e2b554c74|us/en/north-island/auckland_2302926/restaurant/osteria-uno|$$|CAT_P02|bib|nz|2026-10-30T17:34:35.809Z
ve_707860339b|us/en/south-island/arrowtown_2306844/restaurant/aosta|$$|CAT_P02|bib|nz|2026-10-30T17:34:37.139Z
ve_71d26b9cb5|us/en/masovia/warsaw/restaurant/alon-omakase|€€€€|CAT_P04|1 star|pl|2026-10-30T17:34:38.484Z
ve_7483bad22f|us/en/vilnius-region/vilnius_1985479/restaurant/deep-roots|€€€€|CAT_P04|1 star|lt|2026-10-30T17:34:39.819Z
ve_79c4b3fc92|us/en/north-island/auckland_2302926/restaurant/bianca-1248100|$$|CAT_P02|bib|nz|2026-10-30T17:34:41.140Z
ve_7a0520c296|us/en/vilnius-region/radiskis_7770291/restaurant/red-brick|€€€€|CAT_P04|1 star|lt|2026-10-30T17:34:42.471Z
ve_813dab7468|us/en/california/san-francisco/restaurant/kitchen-istanbul|$$|CAT_P02|bib|us|2026-10-30T17:34:43.814Z
ve_8456d9d090|us/en/ha-noi/ha-noi_2974158/restaurant/banh-cuon-gia-truyen-thanh-van-hang-ga-street|₫|CAT_P01|bib|vn|2026-10-30T17:34:45.143Z
ve_86149688c0|us/en/south-island/christchurch_2307083/restaurant/soul-quarter|$$|CAT_P02|bib|nz|2026-10-30T17:34:46.464Z
ve_88ca6f0215|us/en/north-island/wellington_2305537/restaurant/1154-pastaria|$|CAT_P01|bib|nz|2026-10-30T17:34:47.791Z
ve_88e7825deb|us/en/california/san-juan-capistrano/restaurant/heritage-barbecue|$$|CAT_P02|bib|us|2026-10-30T17:34:49.130Z
ve_8a95e5c71c|us/en/north-island/auckland_2302926/restaurant/apero-food-wine|$$|CAT_P02|bib|nz|2026-10-30T17:34:50.458Z
ve_8aa02a036f|us/en/oslo-region/oslo/restaurant/credo-1248105|€€€€|CAT_P04|1 star|no|2026-10-30T17:34:51.806Z
ve_8d14e37c73|us/en/ha-noi/ha-noi_2974158/restaurant/pho-ha-hang-hom|₫|CAT_P01|bib|vn|2026-10-30T17:34:53.151Z
ve_8f28a8c3c9|us/en/ha-noi/ha-noi_2974158/restaurant/onvit|₫₫₫|CAT_P03|1 star|vn|2026-10-30T17:34:54.478Z
ve_8f950e4488|us/en/california/pasadena/restaurant/union|$$|CAT_P02|bib|us|2026-10-30T17:34:55.821Z
ve_93938731bf|us/en/north-island/wellington_2305537/restaurant/hummingbird|$$|CAT_P02|bib|nz|2026-10-30T17:34:57.140Z
ve_94b838eb8b|us/en/california/us-san-diego/restaurant/soichi|$$$$|CAT_P04|1 star|us|2026-10-30T17:34:58.389Z
ve_98fdc9843a|us/en/california/us-los-angeles/restaurant/sonoratown|$|CAT_P01|bib|us|2026-10-30T17:34:59.744Z
ve_996cb062cf|us/en/south-island/wanaka_2306683/restaurant/kika-1247537|$$$|CAT_P03|1 star|nz|2026-10-30T17:35:01.079Z
ve_9c0a28d383|us/en/north-island/waiheke-island_2305319/restaurant/mudbrick|$$$|CAT_P03|1 star|nz|2026-10-30T17:35:02.389Z
ve_9c58775c6b|us/en/south-island/wanaka_2306683/restaurant/treehouse|$$|CAT_P02|bib|nz|2026-10-30T17:35:03.736Z
ve_9f50697f1f|us/en/silesia/pszczyna_2382223/restaurant/steampunk|€€€€|CAT_P04|1 star|pl|2026-10-30T17:35:05.050Z
ve_a19a34aecc|us/en/vestland/bekkjarvik_7770446/restaurant/mirabelle-by-orjan-johannessen|€€€€|CAT_P04|1 star|no|2026-10-30T17:35:06.368Z
ve_a38d20a146|us/en/south-island/christchurch_2307083/restaurant/odeon|$$|CAT_P02|bib|nz|2026-10-30T17:35:07.702Z
ve_a4cdd65b30|us/en/capital-region/copenhagen/restaurant/botschaft|€|CAT_P01|bib|dk|2026-10-30T17:35:09.050Z
ve_a9e86eef6d|us/en/north-island/auckland_2302926/restaurant/milenta|$$|CAT_P02|bib|nz|2026-10-30T17:35:10.382Z
ve_aa4d189c86|us/en/south-island/queenstown_2306160/restaurant/sundays-1241047|$$|CAT_P02|bib|nz|2026-10-30T17:35:11.711Z
ve_ab95922a06|us/en/florida/west-palm-beach_2883871/restaurant/emelina|$$$|CAT_P03|1 star|us|2026-10-30T17:35:13.035Z
ve_b4fda6bf48|us/en/florida/north-miami-beach_2883822/restaurant/barra-callao|$$|CAT_P02|bib|us|2026-10-30T17:35:14.374Z
ve_b800e5f2d9|us/en/south-island/christchurch_2307083/restaurant/inati|$$$|CAT_P03|1 star|nz|2026-10-30T17:35:15.701Z
ve_b9249cb9cb|us/en/savinja/celje/restaurant/gostilna-francl|€€|CAT_P02|bib|si|2026-10-30T17:35:16.998Z
ve_b97ec9a16a|us/en/south-island/queenstown_2306160/restaurant/rata|$$$|CAT_P03|1 star|nz|2026-10-30T17:35:18.333Z
ve_bae620298b|us/en/stockholm-region/stockholm/restaurant/adam-albin|€€€€|CAT_P04|1 star|se|2026-10-30T17:35:19.585Z
ve_bb7081f90e|us/en/florida/saint-augustine_2881915/restaurant/sunday|$$|CAT_P02|bib|us|2026-10-30T17:35:20.898Z
ve_bc652b214e|us/en/capital-region/copenhagen/restaurant/frank569608|€|CAT_P01|bib|dk|2026-10-30T17:35:22.235Z
ve_c47076de88|us/en/california/us-los-angeles/restaurant/kojima-1248017|$$$$|CAT_P04|1 star|us|2026-10-30T17:35:23.576Z
ve_c5d0ff1f05|us/en/florida/bonita-springs_2883470/restaurant/canary-club|$$|CAT_P02|bib|us|2026-10-30T17:35:24.894Z
ve_c6c4bba54c|us/en/kaunas-region/birstonas_1972842/restaurant/pievos|€€|CAT_P02|bib|lt|2026-10-30T17:35:26.200Z
ve_c7ded05de6|us/en/osijek-baranja/dakovo_1784403/restaurant/bistro-loora|€|CAT_P01|bib|hr|2026-10-30T17:39:36.609Z
ve_cbcc1f0329|us/en/capital-region/copenhagen/restaurant/sanchez|€|CAT_P01|bib|dk|2026-10-30T17:35:27.557Z
ve_cc325949fb|us/en/florida/miami/restaurant/to-be-determined|$$|CAT_P02|bib|us|2026-10-30T17:35:28.888Z
ve_cd005d1e4d|us/en/north-denmark/aalborg/restaurant/bach-nurup|€€|CAT_P02|1 star|dk|2026-10-30T17:35:30.205Z
ve_cd7c32c62a|us/en/north-island/auckland_2302926/restaurant/tala|$$$|CAT_P03|1 star|nz|2026-10-30T17:35:31.529Z
ve_cea5c87389|us/en/capital-region/copenhagen/restaurant/akme|€€€|CAT_P03|1 star|dk|2026-10-30T17:35:32.866Z
ve_d3f44a7e0b|us/en/california/us-los-angeles/restaurant/lugya-h|$|CAT_P01|bib|us|2026-10-30T17:39:37.864Z
ve_d4e21f04f5|us/en/south-island/christchurch_2307083/restaurant/londo|$$|CAT_P02|bib|nz|2026-10-30T17:35:34.187Z
ve_d506cb62f8|us/en/capital-region/copenhagen/restaurant/esse|€€€|CAT_P03|1 star|dk|2026-10-30T17:35:35.542Z
ve_d71553cf5f|us/en/nordland/kvitnes_7770468/restaurant/kvitnes-gard|€€€€|CAT_P04|1 star|no|2026-10-30T17:35:36.851Z
ve_d7257f016b|us/en/north-island/auckland_2302926/restaurant/pasta-cuore|$$|CAT_P02|bib|nz|2026-10-30T17:35:38.193Z
ve_db77e8996f|us/en/north-island/waiheke-island_2305319/restaurant/the-estate|$$$|CAT_P03|1 star|nz|2026-10-30T17:35:39.524Z
ve_dc68ae55f1|us/en/florida/miami/restaurant/double-luck|$$|CAT_P02|bib|us|2026-10-30T17:39:39.112Z
ve_dcdc654c7b|us/en/north-denmark/skagen/restaurant/oke|€€€|CAT_P03|1 star|dk|2026-10-30T17:35:40.846Z
ve_df8595ac1c|us/en/south-island/christchurch_2307083/restaurant/a-mano-1247933|$$|CAT_P02|bib|nz|2026-10-30T17:35:42.179Z
ve_e0a6d0b1e8|us/en/california/san-francisco/restaurant/naides|$$$$|CAT_P04|1 star|us|2026-10-30T17:35:43.548Z
ve_e20ad0a205|us/en/california/us-los-angeles/restaurant/lapaba|$$|CAT_P02|bib|us|2026-10-30T17:35:44.922Z
ve_e288def142|us/en/capital-region/copenhagen/restaurant/uformel|€€|CAT_P02|bib|dk|2026-10-30T17:35:46.253Z
ve_e3bd5c2d18|us/en/north-island/auckland_2302926/restaurant/gemmayze-street|$$|CAT_P02|bib|nz|2026-10-30T17:35:47.582Z
ve_ea75b7b1e8|us/en/north-island/auckland_2302926/restaurant/tempero-1248090|$$|CAT_P02|bib|nz|2026-10-30T17:35:48.925Z
ve_ec93c46116|us/en/california/la-jolla/restaurant/lucien|$$$$|CAT_P04|1 star|us|2026-10-30T17:35:50.257Z
ve_edecaf0478|us/en/istria/porec/restaurant/harry-s-piccolo-porec|€€€€|CAT_P04|1 star|hr|2026-10-30T17:35:51.593Z
ve_f12e597554|us/en/california/healdsburg/restaurant/troubadour|$$$$|CAT_P04|1 star|us|2026-10-30T17:39:40.357Z
ve_f22e145872|us/en/stockholm-region/stockholm/restaurant/rolfs-kok|€€|CAT_P02|bib|se|2026-10-30T17:35:52.924Z
ve_f320066f74|us/en/north-island/wellington_2305537/restaurant/ortega|$$|CAT_P02|1 star|nz|2026-10-30T17:39:41.604Z
ve_f3378b4564|us/en/osijek-baranja/osijek/restaurant/lulu-fusion-bistro|€|CAT_P01|bib|hr|2026-10-30T17:35:54.244Z
ve_f5b4865183|us/en/california/alhambra/restaurant/chengdu-taste|$$|CAT_P02|bib|us|2026-10-30T17:35:55.592Z
ve_f7ac5f7d96|us/en/california/us-los-angeles/restaurant/lielle|$$$$|CAT_P04|1 star|us|2026-10-30T17:35:56.936Z
ve_fe3bb3204c|us/en/capital-region/copenhagen/restaurant/lille-molle|€€€€|CAT_P04|1 star|dk|2026-10-30T17:35:58.282Z
ve_fead3f6b69|us/en/ha-noi/ha-noi_2974158/restaurant/mammom|₫₫|CAT_P02|bib|vn|2026-10-30T17:39:42.866Z$r$;
  rel jsonb;
  n_exp int := 116;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count before is not 7582'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 152 THEN RAISE EXCEPTION 'ledger max before is not 152'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118393 THEN RAISE EXCEPTION 'audit max before is not 118393'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '48656407e2d1b7d95061dc0fe4fdb6644ecc4d7d53c7e798738939da0e8020a5' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  -- relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'url', 'https://guide.michelin.com/' || f[2],
           'symbol_raw', f[3], 'currency', CASE f[6] WHEN 'us' THEN 'USD' WHEN 'nz' THEN 'NZD' WHEN 'vn' THEN 'VND' WHEN 'dk' THEN 'EUR' WHEN 'no' THEN 'EUR' WHEN 'pl' THEN 'EUR' WHEN 'se' THEN 'EUR' WHEN 'fi' THEN 'EUR' WHEN 'hr' THEN 'EUR' WHEN 'lt' THEN 'EUR' WHEN 'si' THEN 'EUR' END,
           'tier', char_length(f[3]), 'captured_at', f[7],
           'category', CASE f[5] WHEN 'bib' THEN 'Bib Gourmand' WHEN '1 star' THEN 'One Star' WHEN '2 star' THEN 'Two Stars' WHEN '3 star' THEN 'Three Stars' END) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 7 OR f[4] <> 'CAT_P0' || char_length(f[3])
                            OR char_length(f[3]) NOT BETWEEN 1 AND 4
                            OR f[3] <> repeat(left(f[3], 1), char_length(f[3])))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)
              WHERE x.currency IS NULL OR x.category IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'NZD' THEN '$' WHEN 'VND' THEN '₫'
                                              WHEN 'EUR' THEN '€' END)
    THEN RAISE EXCEPTION 'symbol, currency or distinction'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier||'|'||x.captured_at
                        ||'|'||x.category, E'\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text);
  IF v_fp <> '4fe7c57b818aae150db124f7d2979430' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '09f240b3375713bbd6ace8e2e1b17cb2' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows, as read before the build
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_old
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_old IS DISTINCT FROM '288cb3ef06e580323afe2f218d678c32' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;
  SELECT md5(string_agg(l.venue_id||'|'||l.id, E'\n' ORDER BY l.venue_id COLLATE "C"))
    INTO v_old
    FROM (SELECT DISTINCT ON (a.venue_id) a.venue_id, a.id
            FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
           WHERE a.source_id = 'michelin' AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
           ORDER BY a.venue_id, a.year DESC, a.id DESC) l;
  IF v_old IS DISTINCT FROM '55ec7a7ab62a09da7a69ca2de17a385c' THEN RAISE EXCEPTION 'latest award id md5 %', v_old; END IF;

  -- each row: venue active; no price row; exactly one Michelin award row, source_url NULL, category = card distinction
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id)
      OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin') <> 1
      OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
                        AND a.source_url IS NULL AND a.category = x.category);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows outside P1 rest or changed: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(url text) ON a.source_url = x.url)
    THEN RAISE EXCEPTION 'a card URL is already in use'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS x(url text) ON p.source_url = x.url)
    THEN RAISE EXCEPTION 'a card URL is already in use on a price row'; END IF;

  -- step 1: award source_url
  UPDATE awards a SET source_url = x.url
    FROM jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin' AND a.source_url IS NULL AND a.category = x.category;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', n_exp,
          'source-url:price-michelin-card-p1-rest-2026-10-30 | block A step 3 P1 rest (name search): card found by name search in the Michelin lists; award source_url '
          || 'NULL -> card URL, year and category unchanged | live card read, built-in browser | relay md5 4fe7c57b818aae150db124f7d2979430')
  RETURNING id INTO v_lid1;

  -- step 2: price (guard: card URL = latest Michelin star/Bib card URL of the venue)
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE x.url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\.michelin\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'card URL is not the latest award URL after step 1: %', v_bad; END IF;

  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, x.tier::smallint, x.symbol_raw, x.currency, 'guide_ingest', 'published_symbol', 'michelin',
         x.url, x.captured_at::timestamptz, NULL
    FROM jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text);
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'price rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', n_exp,
          'price-card:price-michelin-card-p1-rest-2026-10-30 | block A step 3 P1 rest (name search): no price row, card found by name search | '
          || n_exp || ' rows inserted (EUR 28, NZD 46, USD 34, VND 8) | live card read, built-in browser | relay md5 4fe7c57b818aae150db124f7d2979430')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7698 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> 153 OR v_lid2 <> 154 THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118393) <> 2 * n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN awards w ON w.id::text = a.row_pk
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = w.venue_id
       WHERE a.id > 118393 AND a.table_name = 'awards' AND a.action = 'UPDATE' AND w.source_id = 'michelin') <> n_exp
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 118393 AND a.table_name = 'price' AND a.action = 'INSERT') <> n_exp
    THEN RAISE EXCEPTION 'audit price INSERT rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)
          ON a.venue_id = x.venue_id AND a.source_id = 'michelin' AND a.source_url = x.url AND a.category = x.category) <> n_exp
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> n_exp
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
END
$do$;
COMMIT;
