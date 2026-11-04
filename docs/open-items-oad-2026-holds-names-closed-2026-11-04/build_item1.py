import hashlib,sys,csv
NAME='cleanup-oad-2026-holds-item1-2026-11-04'
BEN=sys.argv[1] if len(sys.argv)>1 else 'PENDING: Ben has not chosen'
URL='https://www.oadguides.com/lists/japan/top-restaurants/2026'
VID='ve_'+hashlib.md5(b'tokyo:sushi-takumi').hexdigest()[:10]
PRE=f"""  IF (SELECT count(*) FROM venues) <> 11593 OR (SELECT count(*) FROM venues WHERE status='active') <> 11287 OR (SELECT count(*) FROM venues WHERE status='closed') <> 306 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27479 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2857 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13443 OR (SELECT count(*) FROM listings) <> 11593 OR (SELECT count(*) FROM city_label_source) <> 24593 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 33 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11287 OR (SELECT count(*) FROM source_capture_ledger) <> 237 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 124343 OR aud_max <> 130172 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT count(*) FROM venues WHERE id='ve_a1fee2bf94' AND name='Kusunoki' AND status='active' AND city_id='ci_ef0cc10ff4') <> 1 THEN RAISE EXCEPTION 'Kusunoki as read'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='tokyo' AND slug='sushi-takumi') OR EXISTS (SELECT 1 FROM venues WHERE id='{VID}') OR EXISTS (SELECT 1 FROM venues WHERE city_id='ci_ef0cc10ff4' AND norm_key=norm_key('Sushi Takumi')) THEN RAISE EXCEPTION 'new venue clash'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_id='oad' AND year=2026 AND source_url='{URL}' AND rank IN (469,755)) THEN RAISE EXCEPTION 'rank taken'; END IF;
"""
WRITE=f"""  INSERT INTO venues (id, name, category, city_id, status) VALUES ('{VID}', 'Sushi Takumi', 'restaurant'::venue_category, 'ci_ef0cc10ff4', 'active'::venue_status);
  INSERT INTO listings (venue_id, property_id, published) VALUES ('{VID}', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'tokyo', 'sushi-takumi', '{VID}', true);
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES ('{VID}', 'Tokyo', 'city_display'::label_column_t, 'oad', 'OAD 2026 holds item 1, Nov 4'), ('{VID}', 'Japan', 'country'::label_column_t, 'oad', 'OAD 2026 holds item 1, Nov 4') RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
    ('ve_a1fee2bf94', 'oad', 2026, 469, 'No. 469', NULL, '{URL}'),
    ('{VID}', 'oad', 2026, 755, 'No. 755', NULL, '{URL}');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards %', n; END IF;
  UPDATE cities c SET venues_count=coalesce(k.active_venues,0) FROM cities d LEFT JOIN city_venue_counts k ON k.city_id=d.id WHERE d.id=c.id AND c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', 2, 'cleanup:{NAME} | OAD 2026 hold rows, japan 469 and 755 | {URL} | {BEN}'),
    ('oad', 'city_label', 2, 'cleanup:{NAME} | city labels of Sushi Takumi | {BEN}');
  IF (SELECT count(*) FROM venues) <> 11594 OR (SELECT count(*) FROM venues WHERE status='active') <> 11288 OR (SELECT count(*) FROM venues WHERE status='closed') <> 306 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27481 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13444 OR (SELECT count(*) FROM listings) <> 11594 OR (SELECT count(*) FROM city_label_source) <> 24595 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 33 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11288 OR (SELECT count(*) FROM source_capture_ledger) <> 239 THEN RAISE EXCEPTION 'cities, ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=2,cities:UPDATE=1,city_label_source:INSERT=2,listings:INSERT=1,slugs:INSERT=1,venues:INSERT=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
"""
HEAD=f"""-- {NAME}.sql
-- CompassEats, Nov 4 2026. Open item 1 of handoff-oad-2026-holds-status-done. {BEN}. This file runs only after his "go".
-- 2 new OAD 2026 rows: Japan 469 on Kusunoki ve_a1fee2bf94 (second row), Japan 755 on new venue Sushi Takumi {VID} (Tokyo, active). No price, address, geo or blurb.
-- Expected after: venues 11,594 (active 11,288, closed 306); awards 27,481; OAD 2026 2,859; OAD 2025 2,437; slugs 13,444; listings 11,594; labels 24,595; price 7,759; redirects 33; aliases 222; cities 3,318, sum 11,288; ledger 239 rows; audit_log +8.
"""
DECL="DECLARE\n  n bigint; s text; aud_max bigint;\nBEGIN\n"
open(NAME+'.sql','w',encoding='utf-8',newline='\n').write(HEAD+"BEGIN;\nDO $load$\n"+DECL+PRE+WRITE+"END\n$load$;\nCOMMIT;\nSELECT 'OK: all gates passed' AS result;\n")
open('dry1.sql','w',encoding='utf-8',newline='\n').write("DO $load$\n"+DECL+PRE+"  RAISE EXCEPTION 'dry stop';\nEND\n$load$;\n")
H=['list','rank','printed_name','printed_city','oad_chef','oad_address','oad_phone','proposal','strength','evidence','url','second_url']
R=[
['japan',469,'Tempura Kusunoki Yotsuya (Hashimoto)','Tokyo','Yusuke Hashimoto','2-4 Arakicho','+81 3-6380-5677','second row on Kusunoki ve_a1fee2bf94','strong for the house, phone not found','OAD page prints the same 2-4 Arakicho as Kusunoki (rank 26). Omakase booking page named 天婦羅くすのき 四谷 (橋本) gives the place as Kusunoki Main Restaurant, Tokyo. Note post Oct 2024: Hashimoto, second cook, cooks this short course in Yotsuya. Tabelog Magazine Mar 2025: Hashimoto moved to the Nakameguro shop. So the printed row can be stale.','https://omakase.in/en/r/bj840119','https://note.com/0chandadakk0/n/n14b24ee7fb56'],
['japan',755,'Sushi Takumi','Tokyo','Takumi Suzuki','1-11 Yotsuya','+81 3-5261-3048','new venue, Tokyo, active','medium','Own site Sushi Takumi Tokyo names chef Takumi Suzuki, 3F 2-20-3 Higashi-Azabu. Ikyu: 鮨 たくみ, chef 鈴木たくみ, same address. Tabelog reviews July 2026. OAD address is Sushi Sho Yotsuya, OAD phone not found. Other Sushi Takumi: すし卓海, Kagurazaka, phone 03-5946-8499, chef not read.','https://sushitakumitokyo.com/en','https://restaurant.ikyu.com/154503'],
['japan',561,'Sushi Ueda','Osaka','Masamichi Ueda','3-8-15 Nishiki, Nagoya','+81 52-353-6005','stays open','not proven','Chef search in Japanese and English found no Osaka shop. Kobe and Nagoya Ueda have other facts.','',''],
['japan',611,'Kikuzushi','Kitakyushu','Yusuke Saguchi','Mela Plaza, Nagoya','+81 26-253-2258','stays open','not proven','New: 菊鮨 exists at 1-1-35 Kumade, Yahatanishi, Kitakyushu, phone 093-621-2010, reviews Apr 2026, open to 1 am, no chef named. Chef name is near Yusuke Seguchi of Kikuzushi Kasuga, which row 180 prints. City match only.','https://tabelog.com/en/fukuoka/A4004/A400404/40014986/','https://restaurant.ikyu.com/125271/'],
['japan',647,'Miyaba (Sushi)','','Ryujiro Nakamura','2-chome-14-1 Ginza','+81 3-3561-1234','stays open','not proven','New: Sushi Dokoro Miyaba, 2-11-8 Hamamatsucho, phone 03-3431-3880. Tabelog title says Closed, reviews Feb 2026. Address, phone and chef do not match OAD. miyaba.jp load failed in the browser.','https://tabelog.com/en/tokyo/A1314/A131401/13019499/',''],
['japan',675,'Meimon','','Kazunari Nakamura','1-4-15 Hakataekihigashi','+81 92-475-1234','stays open','not proven','Address search found no restaurant. OAD prints French and the chef of La Bonne Table.','',''],
['japan',712,'Tsubomi','Kanazawa','Keiya Kawaguchi','Daiwa, 2-1-1 Korinbo','+81 76-232-3388','stays open','not proven','New: Keiya Kawaguchi is at Sushi Tsubomi, Tokyo (TableAll), reviews Oct 2026, no move shown. Kanazawa Tsubomi is a sweets cafe, OAD prints 11 am to 6 pm. Row can be a second print of rank 419 or a real vote for the cafe.','https://www.tableall.com/restaurant/338','https://tabelog.com/en/tokyo/A1317/A131701/13221782/'],
]
csv.writer(open('oad-2026-holds-item1-evidence-2026-11-04.csv','w',newline='',encoding='utf-8')).writerows([H]+R)
print(VID)
