-- load-50-best-spirited-2026-2026-11-05.sql
-- CompassEats, Nov 5 2026. Open item 1 of handoff-launch-list-radar-done-2026-11-05. Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A". This file runs only after Ben's "go".
-- 315 new award rows: World's 50 Best Bars 2026 100, Asia's 50 Best Bars 2026 100, World's 50 Best Restaurants 2026 100, Spirited Awards 2026 15. 28 new venues (all bar, active, published). 1 new city (Galle).
-- Evidence: 50-best-spirited-2026-evidence-2026-11-05.csv. No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11623 (active 11320, closed 303); awards 27796; slugs 13567; listings 11623; labels 24653; cities 3319, sum 11320; ledger 250 rows; audit_log +477 (125306 rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$Montana|hong-kong|Hong Kong|Hong Kong|worlds-50-best-bars
Bar Gabriel|istanbul|Istanbul|Turkey|worlds-50-best-bars
Naked|athens|Athens|Greece|worlds-50-best-bars
Mius|hong-kong|Hong Kong|Hong Kong|worlds-50-best-bars
Otro Bar|san-jose|San José|Costa Rica|worlds-50-best-bars
Three Horses|melbourne|Melbourne|Australia|worlds-50-best-bars
G.O.D|bangkok|Bangkok|Thailand|worlds-50-best-bars
La Borracha|accra|Accra|Ghana|worlds-50-best-bars
Obsidian Bar|shenzhen|Shenzhen|China|asia-50-best-bars
Pony Up|shanghai|Shanghai|China|asia-50-best-bars
CMYK|changsha|Changsha|China|asia-50-best-bars
M+MS Bar|seoul|Seoul|South Korea|asia-50-best-bars
Problem Child|manila|Makati|Philippines|asia-50-best-bars
Aqua Bar|bangkok|Bangkok|Thailand|asia-50-best-bars
Tiao|beijing|Beijing|China|asia-50-best-bars
BOP|singapore|Singapore|Singapore|asia-50-best-bars
Cabinet 8|kuala-lumpur|Kuala Lumpur|Malaysia|asia-50-best-bars
Between the Sips|jakarta|Jakarta|Indonesia|asia-50-best-bars
The Bar at the Ritz-Carlton Tokyo|tokyo|Tokyo|Japan|asia-50-best-bars
Hats Bar|jakarta|Jakarta|Indonesia|asia-50-best-bars
Aabbcc|new-delhi|New Delhi|India|asia-50-best-bars
Bar Bon Funk|singapore|Singapore|Singapore|asia-50-best-bars
Chimney|hangzhou|Hangzhou|China|asia-50-best-bars
Ropewalk|galle|Galle|Sri Lanka|asia-50-best-bars
Bar Long Fong|beijing|Beijing|China|asia-50-best-bars
The Spirits Library|manila|Makati|Philippines|asia-50-best-bars
Cobra|columbus|Columbus|United States|spirited-awards
Bryant's Cocktail Lounge|milwaukee|Milwaukee|United States|spirited-awards$plan$;
  cl text := $plan$galle|Galle|Sri Lanka|LK|1$plan$;
  al text := $plan$wb|1||89e647b929
wb|2||fde05d62a1
wb|3||2d64be2724
wb|4||114e7e85f2
wb|5||f666df5301
wb|6||5dde540c28
wb|7||846912e3a1
wb|8||be4d971102
wb|9||73438bd8cd
wb|10||1f97b4f29c
wb|11||51118f9027
wb|12||4834f0a15b
wb|13||7354fda9db
wb|14||fec141b0fc
wb|15||ecbb074260
wb|16||54866b70a6
wb|17||01e8f7a7d3
wb|18||82b44b967f
wb|19||8568e9d2e5
wb|20||05b2f7610f
wb|21||bcb4e4b84f
wb|22||04121927dd
wb|23||17d212b769
wb|24||5c7c64ab03
wb|25||bfbc85db67
wb|26||b031886a48
wb|27||f802b602c1
wb|28||cdf6da8d11
wb|29||c7a3c0308a
wb|30||740d862737
wb|31||5c115f5da3
wb|32||c76570eed2
wb|33||a4249334e6
wb|34||74a0eb0cc4
wb|35||53059d0c81
wb|36||a45d654209
wb|37||77c7853582
wb|38||d1add621c8
wb|39||6cd9c1b505
wb|40||18ae06b942
wb|41||f01c7f187a
wb|42||2988652c65
wb|43||c9867db238
wb|44||330958cefd
wb|45||ad5e94ad80
wb|46||0a0425ab1b
wb|47||e0686a098e
wb|48||ca7462648a
wb|49||c15d0dc615
wb|50||10788d0e05
wb|51||9162f49ab7
wb|52||02ebc28502
wb|53||1fa8307ed2
wb|54||bbbd76c206
wb|55||ff718d2b90
wb|56||036cb7e5ed
wb|57||cff99fcc18
wb|58||5821e6f420
wb|59||ce1a459deb
wb|60||0a2d39e6bd
wb|61||5fffaa9af2
wb|62||03f9ae3090
wb|63||85763dcb0d
wb|64||6a52eabeef
wb|65||b3b51b159d
wb|66||df9d307d66
wb|67||2a90808d57
wb|68||e3f3f2be9b
wb|69||0398aa18f7
wb|70||5a0c96c3ee
wb|71||96a41b5ec6
wb|72||5d717b675f
wb|73||97098d900b
wb|74||62d3a80d5a
wb|75||b12fffb75f
wb|76||b375d8b43a
wb|77||2786cd9cb9
wb|78||528bcb4252
wb|79||941f41d72b
wb|80||b294e1f0aa
wb|81||59d44bb899
wb|82||e971d33539
wb|83||d4713fdf10
wb|84||49aa7b1223
wb|85||608a7bb06a
wb|86||e60728f652
wb|87||145736ef0c
wb|88||b60abb118f
wb|89||db36dd716d
wb|90||5857606ead
wb|91||012855b792
wb|92||08b99c5d91
wb|93||825841b307
wb|94||27493434c0
wb|95||13098c0869
wb|96||3e2a8aa427
wb|97||49982aa63d
wb|98||09431b9089
wb|99||c0bcf8d709
wb|100||fd6d30880f
ab|1||4834f0a15b
ab|2||846912e3a1
ab|3||89e647b929
ab|4||f802b602c1
ab|5||0a2d39e6bd
ab|6||114e7e85f2
ab|7||6f0b877a60
ab|8||cff99fcc18
ab|9||82b44b967f
ab|10||79d5359761
ab|11||22fc005070
ab|12||d1add621c8
ab|13||314a4e2d47
ab|14||941f41d72b
ab|15||e1ba80a398
ab|16||db36dd716d
ab|17||3c8603b388
ab|18||60e8ffc199
ab|19||06d30d61f9
ab|20||740d862737
ab|21||9ee0da838c
ab|22||f01c7f187a
ab|23||d4569d460d
ab|24||bbbd76c206
ab|25||49982aa63d
ab|26||ca7462648a
ab|27||046b5ba9af
ab|28||82dd70d831
ab|29||e60728f652
ab|30||e7ad405be9
ab|31||608a7bb06a
ab|32||9d704d0f72
ab|33||96a41b5ec6
ab|34||953b4951da
ab|35||6670c4bede
ab|36||59d44bb899
ab|37||bfbc85db67
ab|38||acb8d6ce6c
ab|39||9b4e2c60c3
ab|40||cbbb19fad3
ab|41||2aaa6c9b16
ab|42||e61b7f928d
ab|43||9d7e3e0d94
ab|44||c2ba64d968
ab|45||a924426e0a
ab|46||efc873f914
ab|47||a45d654209
ab|48||9e3edea764
ab|49||0398aa18f7
ab|50||bb1c65d427
ab|51||019f10f560
ab|52||6af8c74bd3
ab|53||62d3a80d5a
ab|54||4065bce4d2
ab|55||01628a9fb2
ab|56||c0bcf8d709
ab|57||c5a953654f
ab|58||cb3cd230b2
ab|59||da1a10b6cb
ab|60||3e2a8aa427
ab|61||3a8435ad35
ab|62||330958cefd
ab|63||2e38c8fac4
ab|64||fa5fc953be
ab|65||54a93a70e3
ab|66||e2d85a0b22
ab|67||7035175286
ab|68||50508005e0
ab|69||62f7ef99e1
ab|70||549052a728
ab|71||bb3d39b856
ab|72||121398093b
ab|73||7ab4fb5bdf
ab|74||418463e608
ab|75||c60b4166af
ab|76||e955672c8f
ab|77||c11ceceaa3
ab|78||18960e46d6
ab|79||fd6d30880f
ab|80||818e796590
ab|81||0403fb1677
ab|82||2dcb0bb68d
ab|83||b27a885361
ab|84||d0c514cd67
ab|85||e1d14e19aa
ab|86||3418617247
ab|87||3503821ac6
ab|88||60f0400918
ab|89||5753ab6302
ab|90||4c2f17a546
ab|91||1d1c6d3e7e
ab|92||8967f0593b
ab|93||0e455e4c5e
ab|94||c41317d511
ab|95||0d6a554162
ab|96||3bcbdff4eb
ab|97||3df1b0fa85
ab|98||2bb3b536ee
ab|99||1e2773bf5c
ab|100||579265aa74
wr|1||a122719d41
wr|2||260c4c33ff
wr|3||768a440eb6
wr|4||5a8c26383a
wr|5||2f004d998d
wr|6||d4fb60b454
wr|7||1ee134c813
wr|8||0887d3b2c0
wr|9||ad0e407c44
wr|10||c2aeca7793
wr|11||8d7ba03806
wr|12||554dca07f5
wr|13||80a5405658
wr|14||d14b90da5e
wr|15||5a5a88539c
wr|16||164d9e4fc4
wr|17||5fef4bc011
wr|18||07435fce14
wr|19||fb89a8302d
wr|20||76865f818b
wr|21||78e5d38e3e
wr|22||fcbc08e9d3
wr|23||c5e00877c1
wr|24||d9e8560f1a
wr|25||dfa308c00a
wr|26||cf90bcbecd
wr|27||a4c824e918
wr|28||e61e6c68d8
wr|29||1a7001ee86
wr|30||ca840dae3d
wr|31||62c6667f81
wr|32||d55db66fe4
wr|33||34ccffd703
wr|34||98fdf69141
wr|35||9f081eb5bf
wr|36||57a4626bdf
wr|37||ba9edb7571
wr|38||d256863a88
wr|39||6ce9f52552
wr|40||412e1716a6
wr|41||315c71f2a5
wr|42||f1cea59a7a
wr|43||1727fb4901
wr|44||335d635543
wr|45||839ff539f2
wr|46||346cfb5939
wr|47||885707af72
wr|48||52eec2fc38
wr|49||9b785db6b6
wr|50||93ccb12ed1
wr|51||44b2cf5421
wr|52||9592f540ae
wr|53||b925f98f4d
wr|54||a89501169b
wr|55||a7517b2452
wr|56||3813795fa1
wr|57||8bab1ac2d2
wr|58||cc5d387fb5
wr|59||a8657ba3f1
wr|60||0f072a7818
wr|61||b4caa0629a
wr|62||a0386d8940
wr|63||44d34eda5e
wr|64||57f5944034
wr|65||a058d716ba
wr|66||6e7ed69ce8
wr|67||1efc681da3
wr|68||72e32dfdf5
wr|69||17ff31b7b3
wr|70||57517b6560
wr|71||90fbb2fe9e
wr|72||2721e3f85e
wr|73||03a241137f
wr|74||7e5311f93e
wr|75||b401142d6e
wr|76||4a8730ef92
wr|77||c3b5b8becf
wr|78||409a1b7b21
wr|79||8a9d405170
wr|80||089c84c290
wr|81||cfc4d4dff7
wr|82||72cc39cf6e
wr|83||78e41a2703
wr|84||d3db4b1e46
wr|85||a4c05fac5d
wr|86||93575e6ab1
wr|87||2a90808d57
wr|88||81e21905a6
wr|89||ade207892d
wr|90||65ed1f31ff
wr|91||240c9f8e3c
wr|92||c95452bfed
wr|93||502e89f9ca
wr|94||467cda6952
wr|95||4d40a80629
wr|96||703961ccfa
wr|97||a9c22a7d39
wr|98||50c31e03ce
wr|99||649178d372
wr|100||d0ed7ab726
sp||Best International Bar Team|89e647b929
sp||Best International Cocktail Bar|c7a3c0308a
sp||Best International Hotel Bar|bfbc85db67
sp||Best International Restaurant Bar|bd75262274
sp||Best New International Cocktail Bar|17d212b769
sp||Best U.S. Bar Team|2845fa21b3
sp||Best U.S. Cocktail Bar|c15d0dc615
sp||Best U.S. Hotel Bar|ee59820013
sp||Best U.S. Restaurant Bar|b4384f8f0d
sp||Best New U.S. Cocktail Bar|51118f9027
sp||World's Best Bar|bd75262274
sp||World's Best Cocktail Menu|afdd93e931
sp||World's Best Spirits Selection|e0686a098e
sp||Timeless International Award|46333a7d51
sp||Timeless U.S. Award|21ab0ac723$plan$;
  p jsonb; n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(nl||E'\n#\n'||cl||E'\n#\n'||al) <> '98c3fa39542c122c1f5688828bb9a668' THEN RAISE EXCEPTION 'plan text'; END IF;
  WITH r AS (SELECT split_part(x,'|',1) name, split_part(x,'|',2) city_slug, split_part(x,'|',3) clab, split_part(x,'|',4) colab, split_part(x,'|',5) pub FROM regexp_split_to_table(nl,E'\n') x),
       q AS (SELECT r.*, trim(both '-' from regexp_replace(lower(f_unaccent(r.name)),'[^a-z0-9]+','-','g')) slug FROM r),
       w AS (SELECT q.*, 've_'||left(md5(q.city_slug||':'||q.slug),10) id, coalesce(c.id,'ci_'||left(md5(q.city_slug),10)) city_id, c.id IS NULL is_new FROM q LEFT JOIN cities c ON c.slug=q.city_slug),
       ca AS (SELECT split_part(x,'|',1) slug, split_part(x,'|',2) display, split_part(x,'|',3) country, split_part(x,'|',4) country_iso, split_part(x,'|',5)::int venues_count FROM regexp_split_to_table(cl,E'\n') x),
       a0 AS (SELECT split_part(x,'|',1) c, nullif(split_part(x,'|',2),'')::int rank, split_part(x,'|',3) cat, 've_'||split_part(x,'|',4) venue_id FROM regexp_split_to_table(al,E'\n') x),
       aa AS (SELECT c, rank, coalesce(nullif(cat,''),'No. '||rank) category, venue_id, CASE c WHEN 'sp' THEN 'https://talesofthecocktail.org/tales-of-the-cocktail-foundation-announces-2026-spirited-awards-winners/' ELSE 'https://www.the50.com/'||(CASE c WHEN 'wb' THEN 'bars/best-in-the-world' WHEN 'ab' THEN 'bars/best-in-asia' ELSE 'restaurants/best-in-the-world' END)||'/list/'||(CASE WHEN rank<=50 THEN '1-50' ELSE '51-100' END) END url FROM a0)
  SELECT jsonb_build_object(
    'new',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'city_id',city_id,'city_slug',city_slug,'slug',slug)) FROM w),
    'aw',(SELECT jsonb_agg(jsonb_build_object('venue_id',venue_id,'source',CASE c WHEN 'wb' THEN 'worlds-50-best-bars' WHEN 'ab' THEN 'asia-50-best-bars' WHEN 'wr' THEN 'worlds-50-best-restaurants' ELSE 'spirited-awards' END,'rank',rank,'category',category,'url',url)) FROM aa),
    'cities',(SELECT jsonb_agg(jsonb_build_object('id','ci_'||left(md5(slug),10),'slug',slug,'display',display,'country',country,'country_iso',country_iso,'venues_count',venues_count)) FROM ca),
    'upd',(SELECT jsonb_agg(jsonb_build_object('id',city_id,'plus',c)) FROM (SELECT city_id, count(*) c FROM w WHERE NOT is_new GROUP BY 1) y),
    'labels',(SELECT jsonb_agg(jsonb_build_object('venue_id',id,'label',l,'col',col,'pub',pub)) FROM (SELECT id, clab l, 'city_display' col, pub FROM w UNION ALL SELECT id, colab, 'country', pub FROM w) y)) INTO p;
  IF (SELECT md5(string_agg(e->>'id',E'\n' ORDER BY e->>'id' COLLATE "C")) FROM jsonb_array_elements(p->'new') e) <> '171a1969e56dc2b8c700a22088b35224' THEN RAISE EXCEPTION 'venue ids'; END IF;
  IF (SELECT md5(string_agg(t,E'\n' ORDER BY t COLLATE "C")) FROM (SELECT (e->>'venue_id')||'|'||(e->>'source')||'|'||coalesce(e->>'rank','')||'|'||(e->>'category')||'|'||(e->>'url') t FROM jsonb_array_elements(p->'aw') e) y) <> '55a51719a30609dc5447c57698e85ab6' THEN RAISE EXCEPTION 'award rows'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN (SELECT DISTINCT e->>'venue_id' FROM jsonb_array_elements(p->'aw') e);
  IF fp IS DISTINCT FROM '6b808f87a76bcd52071d79850e3eb0d1' THEN RAISE EXCEPTION 'live venue fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11595 OR (SELECT count(*) FROM venues WHERE status='active') <> 11292 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27481 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id IN ('worlds-50-best-bars','asia-50-best-bars','worlds-50-best-restaurants','spirited-awards')) <> 0 THEN RAISE EXCEPTION '2026 rows exist'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13539 OR (SELECT count(*) FROM listings) <> 11595 OR (SELECT count(*) FROM city_label_source) <> 24597 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11292 OR (SELECT count(*) FROM source_capture_ledger) <> 243 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 124829 OR aud_max <> 130658 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text) WHERE x.id <> 've_'||left(md5(x.city_slug||':'||x.slug),10) OR trim(both '-' from regexp_replace(lower(f_unaccent(x.name)),'[^a-z0-9]+','-','g')) <> x.slug;
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text, city_id text) WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=x.id OR (v.city_id=x.city_id AND v.norm_key=norm_key(x.name))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.city_slug AND t.slug=x.slug);
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'cities') x(id text, slug text) WHERE x.id <> 'ci_'||left(md5(x.slug),10) OR EXISTS (SELECT 1 FROM cities c WHERE c.id=x.id OR c.slug=x.slug) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.slug AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(p->'upd') x(id text) JOIN cities c ON c.id=x.id) <> 21 THEN RAISE EXCEPTION 'cities to update'; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT x.id, x.slug, x.display, x.country, x.country_iso, 'city'::city_kind, NULL, NULL, NULL, x.venues_count FROM jsonb_to_recordset(p->'cities') x(id text, slug text, display text, country text, country_iso text, venues_count int);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'cities %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + x.plus FROM jsonb_to_recordset(p->'upd') x(id text, plus int) WHERE c.id=x.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 21 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT x.id, x.name, 'bar'::venue_category, x.city_id, 'active'::venue_status FROM jsonb_to_recordset(p->'new') x(id text, name text, city_id text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 28 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT x.id, 'eats', true FROM jsonb_to_recordset(p->'new') x(id text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 28 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', x.city_slug, x.slug, x.id, true FROM jsonb_to_recordset(p->'new') x(id text, city_slug text, slug text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 28 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) SELECT x.venue_id, x.label, x.col::label_column_t, x.pub, '2026 edition, new venue' FROM jsonb_to_recordset(p->'labels') x(venue_id text, label text, col text, pub text) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 56 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT x.venue_id, x.source, 2026, x.rank, x.category, NULL, x.url FROM jsonb_to_recordset(p->'aw') x(venue_id text, source text, rank int, category text, url text) ORDER BY x.source, x.rank, x.category;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 315 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('worlds-50-best-bars','award',100,'cleanup:load-50-best-spirited-2026-2026-11-05 | 2026 edition, open item 1 | https://www.the50.com/bars/best-in-the-world/list/1-50 | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"'),
    ('asia-50-best-bars','award',100,'cleanup:load-50-best-spirited-2026-2026-11-05 | 2026 edition, open item 1 | https://www.the50.com/bars/best-in-asia/list/1-50 | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"'),
    ('worlds-50-best-restaurants','award',100,'cleanup:load-50-best-spirited-2026-2026-11-05 | 2026 edition, open item 1 | https://www.the50.com/restaurants/best-in-the-world/list/1-50 | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"'),
    ('spirited-awards','award',15,'cleanup:load-50-best-spirited-2026-2026-11-05 | 2026 edition, open item 1 | https://talesofthecocktail.org/tales-of-the-cocktail-foundation-announces-2026-spirited-awards-winners/ | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"'),
    ('worlds-50-best-bars','city_label',16,'cleanup:load-50-best-spirited-2026-2026-11-05 | city labels of 8 new venues | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"'),
    ('asia-50-best-bars','city_label',36,'cleanup:load-50-best-spirited-2026-2026-11-05 | city labels of 18 new venues | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"'),
    ('spirited-awards','city_label',4,'cleanup:load-50-best-spirited-2026-2026-11-05 | city labels of 2 new venues | Ben Nov 5 16:23 ET "1A, 2A, 3A, 4A, 5A"');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11623 OR (SELECT count(*) FROM venues WHERE status='active') <> 11320 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27796 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 315 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||source_id||'|'||coalesce(rank::text,'')||'|'||category||'|'||source_url,E'\n' ORDER BY venue_id||'|'||source_id||'|'||coalesce(rank::text,'')||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026) <> '55a51719a30609dc5447c57698e85ab6' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id='worlds-50-best-bars') <> 100 OR (SELECT count(*) FROM awards WHERE year=2026 AND source_id='asia-50-best-bars') <> 100 OR (SELECT count(*) FROM awards WHERE year=2026 AND source_id='worlds-50-best-restaurants') <> 100 OR (SELECT count(*) FROM awards WHERE year=2026 AND source_id='spirited-awards') <> 15 THEN RAISE EXCEPTION 'list counts after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13567 OR (SELECT count(*) FROM listings) <> 11623 OR (SELECT count(*) FROM city_label_source) <> 24653 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3319 OR (SELECT sum(venues_count) FROM cities) <> 11320 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 250 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=315,cities:INSERT=1,cities:UPDATE=21,city_label_source:INSERT=56,listings:INSERT=28,slugs:INSERT=28,venues:INSERT=28' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
