-- load-michelin-d-vietnam-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Vietnam. Approved: Ben Nov 6 2026 19:41 ET, choices 1-5 A (1 run 64 rows with the 4 weak Da Nang pairs; 2 Pho Bo Lam 10427 and Vi Que Kitchen 10516 no URL, recheck list and archive URL item; 3 Chi Mo to the hold register; 4 Nam Hien pair to the same-name list, no merge; 5 44 names to the rename batch). This file runs only after Ben's "go".
-- 64 rows keep year 2026 and get the card URL. 1 card(s) with no venue: no write. 2 row(s) stay with no URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: relay-vn-2026-cards-2026-11-06.txt sha256 078938594a09918abb58daffb4235bf2388922fb82f7ac554713dcd54c5a5b5d.
-- Expected after: awards 29052 unchanged; ledger 322 rows; audit_log +64.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$4714~ve_677f7ad7df~One Star~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/la-maison-1888
5311~ve_706ccb86c4~One Star~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/gia-1202148
5315~ve_4e2b60de79~One Star~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/hibana-by-koki
5318~ve_979fdb71b8~One Star~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/tam-vi
5377~ve_395ab92660~One Star~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/akuna
5380~ve_cba529b0c9~One Star~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/ciel%C2%A0
5382~ve_8e48893e84~One Star~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/coco-dining
5384~ve_6ba66a55b6~One Star~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/long-trieu
5392~ve_43b398d6a6~One Star~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/anan-saigon
9987~ve_668891bdf1~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/ba-%C4%91ong
9989~ve_da6cb534b9~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/banh-xeo-76
9991~ve_1bb011fe33~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/banh-xeo-tom-nhay-co-ba
9994~ve_7ea80d965f~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/be-ni-2
9995~ve_bf3ab39970~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/bun-bo-ba-roi-hai-chau
9998~ve_e588a5426e~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/bun-bo-hue-ba-thuong
10000~ve_9c65149530~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/bun-cha-ca-109
10002~ve_8276390c97~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/bun-cha-ca-hon
10004~ve_a0d4d79dcb~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/co-chu-nho
10006~ve_6b9f37768c~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/indian-aroma-restaurant
10008~ve_30abd88a39~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/my-quang-sua-hong-van
10010~ve_cfa5cda032~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/ngoc-chi
10012~ve_c8856c04d1~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/phu-hong
10014~ve_4d44c8e2da~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/quan-nhan
10015~ve_aca19daa0e~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/que-xua
10018~ve_efdcc82300~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/rang
10020~ve_e898497b9e~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/shamballa
10022~ve_a531cf8858~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/thia-go%C2%A0
10024~ve_0ec3de0157~Bib Gourmand~https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/an-thoi
10403~ve_d07c4a4752~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/1946-cua-bac
10404~ve_7b270d7945~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/bun-cha-ta-nguyen-huu-huan-street
10407~ve_82e968e300~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/bun-cha-chan
10408~ve_7fc00fbb2a~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/chao-ban
10410~ve_8119035cf6~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/cha-ca-thang-long
10413~ve_3c12826819~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/habakuk
10415~ve_a57aa562eb~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/ha-thanh-mansion
10417~ve_769b0b96e7~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/luk-lak
10418~ve_633e8f01e3~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/mien-luon-chan-cam-hoan-kiem
10421~ve_78cf71c1a8~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/mien-luon-%C4%91ong-thinh
10423~ve_d694e84e22~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/mr-bay-mien-tay
10424~ve_abe2a5b1af~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/pho-10-ly-quoc-su
10428~ve_efa1111ae7~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/pho-gia-truyen
10431~ve_348ccf14fe~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/pho-ga-nguyet
10433~ve_7c3cd2b0a0~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/pho-khoi-hoi
10435~ve_bb069b5bdd~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/the-east
10437~ve_6a2f8151ae~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/tuyet-bun-cha-34
10439~ve_9e3bd44b0c~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/xoi-com
10441~ve_6f0a0de9e3~Bib Gourmand~https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/uu-%C4%91am
10479~ve_12bdfdfdb0~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/banh-xeo-46a
10481~ve_e890762965~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/bo-kho-ganh
10483~ve_694300c441~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/bun-bo-hue-14b
10484~ve_246072e964~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/bep-me-in-le-thanh-ton
10488~ve_bb20b52aae~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/com-tam-ba-ghien
10490~ve_17a2a1c789~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/cuc-gach-quan
10492~ve_d7abd1c22a~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hum-garden
10496~ve_051ba4ae90~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/nha-tu
10498~ve_c3549b7c05~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-chao
10499~ve_91b7357c63~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-hoang
10502~ve_bbe74dd33e~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-huong-binh
10503~ve_e1b301f596~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-le-district-5
10505~ve_0a4428d676~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-minh
10508~ve_e505f66f71~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-mien-ga-ky-%C4%91ong
10510~ve_797a8e1c4e~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/pho-phuong
10511~ve_1e53a44028~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/sol-kitchen-bar
10514~ve_4a2932048e~Bib Gourmand~https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/tiem-com-tho-chuyen-ky$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '5e6f4b9aed151f6306fcd70d766db4d7' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso = 'VN') y;
  IF fp IS DISTINCT FROM '2824837a3f0dc5f3480b89e173af5bed' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11510 OR (SELECT count(*) FROM venues WHERE status='closed') <> 321 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11510 OR (SELECT count(*) FROM source_capture_ledger) <> 321 OR (SELECT max(id) FROM source_capture_ledger) <> 375 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129152 OR u2 <> 134981 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((21118, 've_afc5cbe328', 'https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/ba-vui'), (21119, 've_f21ee3afab', 'https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/banh-beo-banh-%C4%91ap'), (21120, 've_dff956ccb3', 'https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/le-gia-khang-ngu-hanh-son'), (21117, 've_1f12403d25', 'https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/nam-hien-phan-thanh-street'), (21114, 've_8456d9d090', 'https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/banh-cuon-gia-truyen-thanh-van-hang-ga-street'), (21115, 've_fead3f6b69', 'https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/mammom'), (21116, 've_8d14e37c73', 'https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/pho-ha-hang-hom'), (21127, 've_362cf33750', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/banh-canh-cua-ba-ba'), (21125, 've_0732aa9608', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/banh-cuon-tay-ho-127'), (21124, 've_6bdc815126', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/bun-rieu-yen'), (21122, 've_3195442b2e', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/chay-garden'), (21126, 've_39dc53fd44', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3'), (21123, 've_3148ec4456', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/la-lola'), (21121, 've_c1ed9b62ab', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/man-moi-thu-duc-city'), (21051, 've_8f28a8c3c9', 'https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/onvit'), (21052, 've_1c8cc4a492', 'https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/upstairs'))) <> 16 THEN RAISE EXCEPTION 'rows with URL'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url IN ('https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/chi-mo')) THEN RAISE EXCEPTION 'no-row card url in use'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 64 THEN RAISE EXCEPTION 'urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',64,'cleanup:load-michelin-d-vietnam-2026-11-06 | rule 2.1.7: Vietnam 2026, Jun 4, 2026, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-vietnam-2026 | year stays 2026, source_url = the card (/us/en/), all 81 card labels 2026 read Nov 6 2026, retire 0 | card with no venue, hold register, no write: chi-mo Chi Mo (Ho Chi Minh City), new Bib in the Jun 4 2026 Vietnam article, no venue in the database | relay sha256 078938594a09918abb58daffb4235bf2388922fb82f7ac554713dcd54c5a5b5d | Approved: Ben Nov 6 2026 19:41 ET, choices 1-5 A (1 run 64 rows with the 4 weak Da Nang pairs; 2 Pho Bo Lam 10427 and Vi Que Kitchen 10516 no URL, recheck list and archive URL item; 3 Chi Mo to the hold register; 4 Nam Hien pair to the same-name list, no merge; 5 44 names to the rename batch)');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso = 'VN';
  IF n <> 87 OR u1 <> 85 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 322 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134981 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=64' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
