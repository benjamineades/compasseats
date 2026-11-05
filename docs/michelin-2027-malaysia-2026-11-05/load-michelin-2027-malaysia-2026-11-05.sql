-- load-michelin-2027-malaysia-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Kuala Lumpur & Penang 2027 and the 2026 label. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Rule 2.1.7: the 66 legacy rows hold the 2026 edition (ceremony Nov 11, 2025: https://guide.michelin.com/en/article/michelin-guide-ceremony/malaysia-full-selection-2026). Relabel 2025 -> 2026. No source_url. Retire 0.
-- Then 70 new rows, year 2027: Two Stars 1, One Star 9, Bib Gourmand 60, source_url = the card (/us/en/). 4 new venues.
-- Source: docs/michelin-2027-malaysia-2026-11-05/relay-my-2027-list-pages-2026-11-05.txt sha256 f145be1e1f8128f22059cfef8cf700efb4aac9bce039efc9dcc5dd048cb67fb0.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11672 (active 11369, closed 303); awards 28366; slugs 13616; listings 11672; labels 24751; cities 3321, sum 11369; ledger 255 rows; Michelin 2025/2026/2027 4930/6590/122; audit_log +159.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$2184|ve_4df75e0ea5|Two Stars
5145|ve_5fb42921c9|One Star
5146|ve_3eb71e74f4|One Star
5714|ve_1956f85ef8|One Star
5717|ve_705085f5e5|One Star
5718|ve_029831f29d|One Star
5720|ve_45a6cd6cc9|One Star
5721|ve_0a3979eb3d|One Star
5722|ve_a3757bfed4|One Star
10263|ve_8170285a94|Bib Gourmand
10264|ve_1edcb5d0c0|Bib Gourmand
10265|ve_e9490a1590|Bib Gourmand
10266|ve_30acc47074|Bib Gourmand
10267|ve_0e32b10f52|Bib Gourmand
10268|ve_b723b6103b|Bib Gourmand
10269|ve_b6590f8808|Bib Gourmand
10270|ve_63e0e5b6a4|Bib Gourmand
10271|ve_9494c702d6|Bib Gourmand
10272|ve_ff339c089d|Bib Gourmand
10273|ve_7d405bcf02|Bib Gourmand
10274|ve_75da63785d|Bib Gourmand
10275|ve_8278980536|Bib Gourmand
10276|ve_e5b5026a4e|Bib Gourmand
10277|ve_010971fed7|Bib Gourmand
10278|ve_c33b6405c3|Bib Gourmand
10279|ve_97b7a906d3|Bib Gourmand
10280|ve_047a2c6261|Bib Gourmand
10281|ve_1ec4dd4906|Bib Gourmand
10282|ve_9f150d6f0f|Bib Gourmand
10283|ve_b54d8af4a1|Bib Gourmand
10284|ve_78fd0c5910|Bib Gourmand
10285|ve_18554be84d|Bib Gourmand
10286|ve_e137bc040a|Bib Gourmand
10287|ve_12d2b1101f|Bib Gourmand
10288|ve_2a7584aca3|Bib Gourmand
10289|ve_9156dfc937|Bib Gourmand
10290|ve_71a9ff7b01|Bib Gourmand
10762|ve_1d28549f02|Bib Gourmand
10763|ve_b51d61a2cf|Bib Gourmand
10764|ve_02dbe107de|Bib Gourmand
10765|ve_bcd0baa29f|Bib Gourmand
10766|ve_1569932f04|Bib Gourmand
10767|ve_ac70ae8632|Bib Gourmand
10768|ve_911387ca74|Bib Gourmand
10769|ve_f47f713cf6|Bib Gourmand
10770|ve_1159f5a76f|Bib Gourmand
10771|ve_0863dfa720|Bib Gourmand
10772|ve_f90ecf7436|Bib Gourmand
10773|ve_ac8f06d025|Bib Gourmand
10774|ve_de917acda2|Bib Gourmand
10775|ve_15423d04be|Bib Gourmand
10776|ve_6da2164371|Bib Gourmand
10777|ve_dae7944089|Bib Gourmand
10778|ve_73cfa89a00|Bib Gourmand
10779|ve_da250213da|Bib Gourmand
10780|ve_eb77fd68ae|Bib Gourmand
10781|ve_003bb97d1b|Bib Gourmand
10782|ve_15aa903c9c|Bib Gourmand
10783|ve_42ca15697d|Bib Gourmand
10784|ve_646d576229|Bib Gourmand
10785|ve_d1c0717a0a|Bib Gourmand
12068|ve_40bde2f6be|Bib Gourmand
12069|ve_49238ef301|Bib Gourmand
12070|ve_ce590a0a10|Bib Gourmand
12071|ve_4731ec9e3a|Bib Gourmand
12072|ve_6f66fe2b77|Bib Gourmand$plan$;
  aw text := $plan$ve_003bb97d1b|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/roti-by-d-tandoor
ve_010971fed7|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/my-own-cafe
ve_029831f29d|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/chim-by-chef-noom
ve_02dbe107de|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/anak-baba
ve_047a2c6261|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/rasa-rasa
ve_0863dfa720|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/hing-kee-bakuteh-jalan-kepong
ve_0a3979eb3d|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/molina
ve_0e32b10f52|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/bridge-street-prawn-noodle
ve_1159f5a76f|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/hai-kah-lang
ve_12d2b1101f|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/teksen
ve_15423d04be|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/lama
ve_1569932f04|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/congkak-bukit-bintang
ve_15aa903c9c|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/sao-nam
ve_18554be84d|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/sister-yao-s-char-koay-kak
ve_1956f85ef8|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/akar
ve_1d28549f02|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/ah-hei-bak-kut-teh
ve_1ec4dd4906|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/ravi-s-famous-apom-manis
ve_1edcb5d0c0|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/awesome-char-koay-teow
ve_2a7584aca3|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/thara
ve_30acc47074|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/bibik-s-kitchen
ve_3eb71e74f4|One Star|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/auntie-gaik-lean-s-old-school-eatery
ve_40bde2f6be|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/seberang-perai/restaurant/bm-cathay-pancake
ve_42ca15697d|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/sek-yuen
ve_45a6cd6cc9|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/dc-by-darren-chin
ve_4731ec9e3a|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/seberang-perai/restaurant/neighbourwood
ve_49238ef301|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/seberang-perai/restaurant/bm-yam-rice
ve_4df75e0ea5|Two Stars|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/dewakan
ve_5fb42921c9|One Star|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/au-jardin
ve_63e0e5b6a4|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/ghee-lian
ve_646d576229|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/sin-kiew-yee-shin-kee-beef-noodles
ve_6da2164371|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/leen-s
ve_6f66fe2b77|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/seberang-perai/restaurant/taman-bukit-curry-mee
ve_6fb1e2353b|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/7-chai-ipoh-hor-fun
ve_705085f5e5|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/beta
ve_71a9ff7b01|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/winn-s-cafe
ve_73cfa89a00|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/nam-heong-chicken-rice
ve_75da63785d|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/laksalicious
ve_78fd0c5910|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/sifu
ve_7d405bcf02|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/ivy-s-nyonya-cuisine
ve_8278980536|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/lum-lai-duck-meat-koay-teow-th-ng
ve_911387ca74|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/foong-lian
ve_9156dfc937|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/wan-dao-tou-assam-laksa
ve_9494c702d6|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/green-house-prawn-mee-loh-mee
ve_97b7a906d3|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/penang-road-famous-laksa
ve_9f150d6f0f|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/sardaarji
ve_a3757bfed4|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/terra-dining
ve_ac70ae8632|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/de-wan-1958
ve_ac8f06d025|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/jalan-ipoh-claypot-chicken-rice
ve_b51d61a2cf|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/aliyaa
ve_b54d8af4a1|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/siam-road-char-koay-teow
ve_b6590f8808|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/duck-blood-curry-mee
ve_b723b6103b|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/communal-table-by-gen
ve_bcd0baa29f|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/coast-by-kayra
ve_c33b6405c3|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/penang-road-famous-jin-kor-char-kuey-teow
ve_ce590a0a10|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/seberang-perai/restaurant/ming-qing-charcoal-duck-egg-char-koay-teow
ve_d1c0717a0a|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/wong-mei-kee
ve_da250213da|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/nasi-ayam-hainan-chee-meng-jalan-kelang-lama
ve_da9da38e39|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/minji-bak-kut-teh
ve_dae7944089|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/mtr-1924
ve_dc32f76e1a|One Star|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/potager-1214971
ve_de917acda2|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/lai-fong-lala-noodles
ve_e137bc040a|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/super-star-koay-teow-soup
ve_e515d7f579|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/seberang-perai/restaurant/lemon-koay-teow-soup
ve_e5b5026a4e|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/moh-teng-pheow-nyonya-koay
ve_e9490a1590|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/bee-hwa-cafe
ve_eb77fd68ae|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/nirwana
ve_f47f713cf6|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/gulainya
ve_f8db3067b6|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/serabai-istimewa
ve_f90ecf7436|Bib Gourmand|https://guide.michelin.com/us/en/kuala-lumpur-region/kuala-lumpur/restaurant/hor-poh-cuisine
ve_ff339c089d|Bib Gourmand|https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/hot-bowl-white-curry-mee$plan$;
  nw text := $plan$ve_6fb1e2353b|7-chai-ipoh-hor-fun|kuala-lumpur|ci_3531a466fc|Kuala Lumpur|7 Chai Ipoh Hor Fun
ve_da9da38e39|minji-bak-kut-teh|kuala-lumpur|ci_3531a466fc|Kuala Lumpur|Minji Bak Kut Teh
ve_f8db3067b6|serabai-istimewa|george-town|ci_021dfa5a5a|George Town|Serabai Istimewa
ve_e515d7f579|lemon-koay-teow-soup|seberang-perai|ci_1ba468de61|Seberang Perai|Lemon Koay Teow Soup$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'db24f53371a232f15b5e42867865e13c' OR md5(aw) <> 'c36ef99aef841eb08959fb9bb52cddd3' OR md5(nw) <> '6445e455c4a4d981859d52ee057dc094' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Malaysia' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '85989c4837abf015fc58fffe380e714e' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia') <> 66 THEN RAISE EXCEPTION 'Malaysia Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11668 OR (SELECT count(*) FROM venues WHERE status='active') <> 11365 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28296 OR (SELECT max(id) FROM awards) <> 35467 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4996 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6524 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 52 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13612 OR (SELECT count(*) FROM listings) <> 11668 OR (SELECT count(*) FROM city_label_source) <> 24743 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11365 OR (SELECT count(*) FROM source_capture_ledger) <> 252 OR (SELECT max(id) FROM source_capture_ledger) <> 306 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 126068 OR aud_max <> 131897 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026 WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(rl,E'\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 66 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venues, listings, slugs, city counts
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + y.k FROM (SELECT split_part(x,'|',4) id, count(*)::int k FROM regexp_split_to_table(nw,E'\n') x GROUP BY 1) y WHERE c.id=y.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Malaysia','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 70 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',66,'relabel:load-michelin-2027-malaysia-2026-11-05 | rule 2.1.7: Kuala Lumpur & Penang edition live at capture = 2026 (ceremony Nov 11, 2025, https://guide.michelin.com/en/article/michelin-guide-ceremony/malaysia-full-selection-2026) | year 2025 -> 2026, no per-row URL, retire 0 | DRAFT, choices not yet given'),
    ('michelin','award',70,'cleanup:load-michelin-2027-malaysia-2026-11-05 | Kuala Lumpur & Penang 2027, ceremony Nov 4, 2026 | Two Stars 1, One Star 9, Bib 60 | relay sha256 f145be1e1f8128f22059cfef8cf700efb4aac9bce039efc9dcc5dd048cb67fb0 | DRAFT, choices not yet given'),
    ('michelin','city_label',8,'cleanup:load-michelin-2027-malaysia-2026-11-05 | city labels of 4 new venues | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11672 OR (SELECT count(*) FROM venues WHERE status='active') <> 11369 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28366 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 70 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> 'c36ef99aef841eb08959fb9bb52cddd3' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4930 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6590 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia' AND a.year=2027 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=60,One Star=9,Two Stars=1' THEN RAISE EXCEPTION 'Malaysia 2027 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=57,One Star=8,Two Stars=1' THEN RAISE EXCEPTION 'Malaysia 2026 %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13616 OR (SELECT count(*) FROM listings) <> 11672 OR (SELECT count(*) FROM city_label_source) <> 24751 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11369 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 255 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=70,awards:UPDATE=66,cities:UPDATE=3,city_label_source:INSERT=8,listings:INSERT=4,slugs:INSERT=4,venues:INSERT=4' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
