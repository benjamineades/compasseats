-- CompassEats, Nov 1 2026. Item 4: Michelin Guide Great Britain & Ireland 2025 stars and Green Stars from the archive.
-- Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1": N1 stars and Green Star only (no Bib); R1 source_url = the archive id_ URL;
--   Q1 skip lines with no venue. Name-only pairs (6 lines): use.
-- Sources (read Nov 1 in the built-in browser; status 200; 0 redirects):
--   stars  https://web.archive.org/web/20250211084823id_/https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland
--          (title "Every MICHELIN-Star Restaurant in Great Britain & Ireland 2025"; 10 / 29 / 181)
--   green  https://web.archive.org/web/20250211223426id_/https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new
--          (title "5 New Green Stars for Great Britain & Ireland 2025"; full list 36)
--   Counts = the Feb 10, 2025 ceremony article "at a Glance": 10 / 29 / 181 / 36 Green Stars.
-- Relay sha256 003ae95ec6c1031f558f503be6f8d35f6f0d930bb10f2ee0e7991985b87536e0; link map sha256 60d35e7df6077a30e0d5991bc96e29bea9d7a741e4994e9d8f0554030d80bdc1.
-- Built by docs/gbi-2025-build/build_backfill_gbi_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in GB / IE / JE ('card'); else the venue id in the build script ('use').
--   Gates: plan md5 40a7717a776f4c40d0a81e8de8a3c826; seq:venue md5 d9c1efc8511427095a124d59fc9904a6; existing 2025 row ids md5 0baa629e41d701d68e62760f92c2c2b9.
-- Expected: awards UPDATE 6 (source_url) and INSERT 224 (michelin, 2025); 1 ledger row; 230 audit rows (trigger).
--   awards 23,560 -> 23,784. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  arch_s   text := 'https://web.archive.org/web/20250211084823id_/https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland';
  arch_g   text := 'https://web.archive.org/web/20250211223426id_/https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new';
  plan_txt text := '[[1, "Three Stars", "alain-ducasse-at-the-dorchester", ""], [2, "Three Stars", "core-by-clare-smyth", ""], [3, "Three Stars", "fat-duck", ""], [4, "Three Stars", "helene-darroze-at-the-connaught", ""], [5, "Three Stars", "l-enclume", ""], [6, "Three Stars", "moor-hall", ""], [7, "Three Stars", "restaurant-gordon-ramsay", ""], [8, "Three Stars", "sketch-the-lecture-room-library", ""], [9, "Three Stars", "the-ledbury", ""], [10, "Three Stars", "waterside-inn", ""], [11, "Two Stars", "a-wong", ""], [12, "Two Stars", "alex-dilling-at-hotel-cafe-royal", ""], [13, "Two Stars", "brooklands", ""], [14, "Two Stars", "chapter-one-by-mickael-viljanen", ""], [16, "Two Stars", "da-terra", ""], [17, "Two Stars", "dede", ""], [18, "Two Stars", "dinner-by-heston-blumenthal", ""], [19, "Two Stars", "gymkhana", ""], [20, "Two Stars", "hand-and-flowers", ""], [21, "Two Stars", "hide-and-fox", ""], [22, "Two Stars", "humble-chicken", ""], [23, "Two Stars", "ikoyi", ""], [24, "Two Stars", "kitchen-table-at-bubbledogs", "ve_11e25b87c1"], [26, "Two Stars", "belmond-le-manoir-aux-quat-saisons", "ve_7b865a33b7"], [27, "Two Stars", "liath", ""], [28, "Two Stars", "midsummer-house", ""], [29, "Two Stars", "opheem", ""], [30, "Two Stars", "patrick-guilbaud", ""], [31, "Two Stars", "andrew-fairlie-at-gleneagles", ""], [32, "Two Stars", "restaurant-sat-bains", ""], [33, "Two Stars", "story", ""], [34, "Two Stars", "terre-1203607", ""], [35, "Two Stars", "the-clove-club", ""], [36, "Two Stars", "the-glenturret-lalique", ""], [37, "Two Stars", "ritz-restaurant", ""], [38, "Two Stars", "trivet", ""], [39, "Two Stars", "ynyshir", ""], [40, "One Star", "1890-by-gordon-ramsay", ""], [41, "One Star", "33-the-homend", ""], [42, "One Star", "64-goodge-street", ""], [43, "One Star", "acleaf", ""], [44, "One Star", "adam-s", ""], [45, "One Star", "akoko", ""], [46, "One Star", "alchemilla530690", ""], [47, "One Star", "allium-at-askham-hall", ""], [48, "One Star", "amaya", ""], [49, "One Star", "angler392235", ""], [50, "One Star", "anglothai", ""], [51, "One Star", "aniar", ""], [52, "One Star", "artichoke", ""], [53, "One Star", "aulis", ""], [54, "One Star", "avery-1210944", ""], [55, "One Star", "ballyfin", ""], [56, "One Star", "bastible", ""], [57, "One Star", "bastion", ""], [58, "One Star", "beach-house", ""], [59, "One Star", "behind", ""], [60, "One Star", "ben-wilkinson-at-the-pass", ""], [61, "One Star", "benares", ""], [62, "One Star", "black-swan", ""], [63, "One Star", "bohemia", ""], [64, "One Star", "brat", ""], [66, "One Star", "bulrush", ""], [67, "One Star", "bybrook", ""], [68, "One Star", "cail-bruich", ""], [69, "One Star", "campagne", ""], [70, "One Star", "caractere", ""], [71, "One Star", "casa-fofo", ""], [72, "One Star", "cedar-tree-by-hrishikesh-desai", ""], [73, "One Star", "chestnut", ""], [74, "One Star", "chez-bruce", ""], [75, "One Star", "chishuru", ""], [77, "One Star", "condita", ""], [78, "One Star", "cornus", ""], [79, "One Star", "cottage-in-the-wood", ""], [81, "One Star", "cycene", ""], [82, "One Star", "dining-room-at-the-goring", ""], [83, "One Star", "dog-and-gun-inn", ""], [84, "One Star", "d-olier-street", ""], [85, "One Star", "dorian", ""], [87, "One Star", "dysart-petersham", ""], [88, "One Star", "elephant", ""], [89, "One Star", "elystan-street", ""], [90, "One Star", "endo-at-the-rotunda", "ve_b9d291ce2a"], [91, "One Star", "evelyn-s-table", ""], [93, "One Star", "fordwich-arms", ""], [94, "One Star", "forest-side", ""], [95, "One Star", "forge-1190154", ""], [96, "One Star", "frog-by-adam-handling", ""], [97, "One Star", "galvin-la-chapelle", ""], [98, "One Star", "gidleigh-park", ""], [99, "One Star", "glovers-alley", ""], [100, "One Star", "gorse", ""], [101, "One Star", "grace-and-savour", ""], [102, "One Star", "gravetye-manor", ""], [103, "One Star", "hambleton-hall", ""], [104, "One Star", "harwood-arms", ""], [105, "One Star", "heft", ""], [106, "One Star", "heron-1197434", ""], [107, "One Star", "hide", ""], [108, "One Star", "hinds-head", ""], [109, "One Star", "hjem", "ve_c905b58267"], [110, "One Star", "home-1196052", ""], [111, "One Star", "homestead-cottage", ""], [112, "One Star", "house", ""], [113, "One Star", "house-of-tides", ""], [115, "One Star", "interlude", ""], [116, "One Star", "jamavar", ""], [117, "One Star", "john-s-house", ""], [118, "One Star", "kitchen-w8", ""], [119, "One Star", "kol", ""], [120, "One Star", "la-trompette", ""], [121, "One Star", "lady-helen", ""], [122, "One Star", "lake-road-kitchen", ""], [123, "One Star", "latymer", ""], [124, "One Star", "le-champignon-sauvage", ""], [125, "One Star", "lignum", ""], [126, "One Star", "lita", ""], [127, "One Star", "loch-bay", ""], [128, "One Star", "luca", ""], [129, "One Star", "lumiere", ""], [130, "One Star", "lyla-1210030", ""], [131, "One Star", "lyle-s", "ve_d8accd5787"], [132, "One Star", "lympstone-manor", ""], [133, "One Star", "mana", ""], [134, "One Star", "mark-poynton-at-caistor-hall", "ve_3892089530"], [135, "One Star", "martin-wishart", ""], [136, "One Star", "masons-arms", "ve_d5ec6cac85"], [137, "One Star", "mauro-colagreco-at-raffles-london-at-the-owo", ""], [138, "One Star", "meadowsweet-1196227", ""], [139, "One Star", "morston-hall", ""], [140, "One Star", "mountain", ""], [141, "One Star", "murano", ""], [142, "One Star", "muse-1188132", ""], [143, "One Star", "myse", ""], [144, "One Star", "northcote", ""], [145, "One Star", "nut-tree", ""], [146, "One Star", "old-stamp-house", ""], [147, "One Star", "olive-tree", ""], [148, "One Star", "oma-1213973", ""], [149, "One Star", "ormer-mayfair", ""], [150, "One Star", "osip", ""], [151, "One Star", "outlaw-s-fish-kitchen", ""], [153, "One Star", "ox399109", ""], [154, "One Star", "paul-ainsworth-at-no-6", ""], [155, "One Star", "pavyllon-london", ""], [156, "One Star", "pea-porridge", ""], [157, "One Star", "pentonbridge-inn", ""], [158, "One Star", "petrus284688", ""], [159, "One Star", "pied-a-terre", ""], [160, "One Star", "pine", ""], [161, "One Star", "pipe-and-glass", ""], [162, "One Star", "plates-london", ""], [163, "One Star", "portland", ""], [164, "One Star", "quilon", ""], [165, "One Star", "restaurant-hywel-jones-by-lucknam-park", ""], [166, "One Star", "restaurant-22", ""], [167, "One Star", "river-cafe", ""], [168, "One Star", "rogan-co", ""], [169, "One Star", "roots1090849", ""], [170, "One Star", "row-on-5", ""], [171, "One Star", "sabor", ""], [172, "One Star", "shaun-rankin-at-grantley-hall", ""], [173, "One Star", "simpsons", "ve_7cdb1751a2"], [174, "One Star", "skof", ""], [175, "One Star", "so-la", "ve_653d7fb4a4"], [176, "One Star", "sollip", ""], [177, "One Star", "so%e2%80%93lo", ""], [178, "One Star", "solstice-by-kenny-atkinson", ""], [179, "One Star", "sorrel545459", "ve_f98f790eff"], [180, "One Star", "sosban-the-old-butchers", ""], [181, "One Star", "source-1206579", ""], [182, "One Star", "st-barts", ""], [183, "One Star", "st-john", ""], [184, "One Star", "star-inn-at-harome", ""], [185, "One Star", "stark", ""], [186, "One Star", "starling", ""], [187, "One Star", "sushi-kanesaka-1210127", ""], [188, "One Star", "taku-1205623", "ve_4789a4e337"], [189, "One Star", "the-angel189123", ""], [190, "One Star", "the-barn", ""], [191, "One Star", "the-bishop-s-buttery", ""], [192, "One Star", "the-coach", ""], [193, "One Star", "the-cross-at-kenilworth", ""], [194, "One Star", "the-dining-room193454", ""], [195, "One Star", "kitchin", ""], [196, "One Star", "the-morrison-room", ""], [197, "One Star", "muddlers-club", ""], [198, "One Star", "the-neptune", ""], [199, "One Star", "the-ninth", ""], [200, "One Star", "the-oak-room", ""], [201, "One Star", "the-peat-inn", ""], [202, "One Star", "the-royal-oak", ""], [203, "One Star", "the-samling", ""], [204, "One Star", "the-sportsman", ""], [205, "One Star", "the-tudor-pass", ""], [206, "One Star", "white-swan", ""], [207, "One Star", "the-whitebrook", ""], [208, "One Star", "timberyard", ""], [209, "One Star", "trinity", ""], [210, "One Star", "trishna", ""], [211, "One Star", "umu", ""], [212, "One Star", "unalome-by-graeme-cheevers", ""], [213, "One Star", "upstairs-by-tom-shepherd", ""], [214, "One Star", "variety-jones", ""], [215, "One Star", "veeraswamy", ""], [216, "One Star", "walnut-tree", ""], [217, "One Star", "wild-honey-st-james", ""], [218, "One Star", "wilsons", ""], [219, "One Star", "winteringham-fields", ""], [220, "One Star", "coworth-park", ""], [223, "Green Star", "black-swan", ""], [224, "Green Star", "coombeshead-farm", "ve_60f0332fb7"], [229, "Green Star", "forge-1190154", ""], [231, "Green Star", "interlude", ""], [232, "Green Star", "jericho", "ve_21f3f34844"], [233, "Green Star", "belmond-le-manoir-aux-quat-saisons", "ve_7b865a33b7"], [234, "Green Star", "l-enclume", ""], [236, "Green Star", "moor-hall", ""], [239, "Green Star", "osip", ""], [241, "Green Star", "pine", ""], [242, "Green Star", "pythouse-kitchen-garden", ""], [243, "Green Star", "restaurant-sat-bains", ""], [244, "Green Star", "silo-1183942", "ve_85eaf781c4"], [245, "Green Star", "st-barts", ""], [248, "Green Star", "where-the-light-gets-in", "ve_15b2f1594e"], [250, "Green Star", "wilsons", ""], [251, "Green Star", "inver", "ve_6875e82e76"], [252, "Green Star", "annwn", "ve_16395a9c38"], [255, "Green Star", "the-whitebrook", ""]]';
  job_txt  text := 'backfill:michelin-2025-great-britain-ireland-archive | item 4 (Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"): Michelin Guide Great Britain & Ireland 2025 stars and Green Stars from web.archive.org | 6 existing 2025 star rows get the source_url; 224 rows inserted (Green Star:19,One Star:174,Three Stars:10,Two Stars:27 in all 230) | stars source_url = https://web.archive.org/web/20250211084823id_/https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland | Green Star source_url = https://web.archive.org/web/20250211223426id_/https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new | relay docs/gbi-2025-build/relay-gbi-2025-archive-20250211.txt sha256 003ae95e...7536e0; card links links-gbi-2025-archive-20250211.txt sha256 60d35e7d...80bdc1 | counts = ceremony ''at a Glance'' 10/29/181/36 | match: card link = Michelin card of an existing award row (212); use by venue id: 24 -> ve_11e25b87c1; 90 -> ve_b9d291ce2a; 134 -> ve_3892089530; 136 -> ve_d5ec6cac85; 173 -> ve_7cdb1751a2; 175 -> ve_653d7fb4a4; 179 -> ve_f98f790eff; 224 -> ve_60f0332fb7; 232 -> ve_21f3f34844; 248 -> ve_15b2f1594e; 251 -> ve_6875e82e76; 252 -> ve_16395a9c38 | name-only pairs (use): 26 -> ve_7b865a33b7; 109 -> ve_c905b58267; 131 -> ve_d8accd5787; 188 -> ve_4789a4e337; 233 -> ve_7b865a33b7; 244 -> ve_85eaf781c4 | Q1 skipped, no venue: Claude Bosi at Bibendum; La Dame de Pic London; Bridge Arms; Club Gascon; Crocadon (One Star); DOSA; Five Fields; Humo; Outlaw''s New Road; Angela''s (GS); Apricity (GS); Crocadon (GS); CULTURE (GS); Daylesford Organic Farm (GS); Exmoor Forest Inn (GS); Homestead Kitchen (GS); Marle (GS); Native (GS); Oak (GS); Petersham Nurseries Cafe (GS); The Small Holding (GS); Tillingham (GS); Wild Shropshire (GS); CHAPTERS (GS); Henry Robertson (GS); Kai Restaurant (GS) | 2025 Bibs: no full list (N1), no change | plan md5 40a7717a776f4c40d0a81e8de8a3c826';
  pj jsonb; rj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> '40a7717a776f4c40d0a81e8de8a3c826' OR cnt <> 230 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected 40a7717a776f4c40d0a81e8de8a3c826 / 230)', txt, cnt; END IF;

  WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid FROM jsonb_array_elements(pj) e),
    sl AS (SELECT DISTINCT lower(substring(split_part(a.source_url, '?', 1) from '/restaurant/([^/]+)/?$')) slug, a.venue_id
             FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
            WHERE a.source_id = 'michelin' AND a.source_url ~ '/restaurant/' AND c.country_iso IN ('GB', 'IE', 'JE')),
    t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
    r AS (SELECT p.seq, p.cat,
            CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
            CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how,
            CASE WHEN p.cat = 'Green Star' THEN 'G' ELSE 'S' END src
          FROM p LEFT JOIN t1 USING (seq))
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how, src) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> 'd9c1efc8511427095a124d59fc9904a6' THEN RAISE EXCEPTION 'seq:venue md5 % (expected d9c1efc8511427095a124d59fc9904a6)', txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso IN ('GB', 'IE', 'JE');
  IF cnt <> 230 THEN RAISE EXCEPTION 'venues in GB/IE/JE % (expected 230)', cnt; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 230 THEN RAISE EXCEPTION 'distinct venue + category % (expected 230)', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> 6 OR txt <> '0baa629e41d701d68e62760f92c2c2b9' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected 6 / 0baa629e41d701d68e62760f92c2c2b9)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> 6 THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected 6)', cnt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
   WHERE r.cat <> 'Green Star' AND a.category IN ('Three Stars', 'Two Stars', 'One Star') AND a.category <> r.cat;
  IF cnt <> 0 THEN RAISE EXCEPTION 'venues with a different 2025 star row: %', cnt; END IF;

  -- 2. Counts before (read Nov 1 20:59:53 UTC)
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> 23560 OR num <> 30499 THEN RAISE EXCEPTION 'awards before % / max % (expected 23560 / 30499)', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 9856 THEN RAISE EXCEPTION 'Michelin awards before % (expected 9856)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 3480 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3480)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3243 THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected 3243)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 12 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 12)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('GB', 'IE', 'JE');
                                                IF cnt <> 9 THEN RAISE EXCEPTION 'GB/IE/JE Michelin 2025 before % (expected 9)', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 161 OR led_max <> 213 THEN RAISE EXCEPTION 'ledger before % / max % (expected 161 / 213)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 116478 OR aud_max <> 121990 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 116478 / 121990)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = CASE WHEN r.src = 'G' THEN arch_g ELSE arch_s END
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) r
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 6 THEN RAISE EXCEPTION 'award rows updated % (expected 6)', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, CASE WHEN r.src = 'G' THEN arch_g ELSE arch_s END FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) r
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 224 THEN RAISE EXCEPTION 'award rows inserted % (expected 224)', cnt; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 230, job_txt);
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', cnt; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO cnt FROM awards;         IF cnt <> 23784 THEN RAISE EXCEPTION 'awards after % (expected 23784)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 10080 THEN RAISE EXCEPTION 'Michelin awards after % (expected 10080)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 3704 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3704)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3237 THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected 3237)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 31 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 31)', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL
       AND ((a.category = 'Green Star' AND a.source_url = arch_g) OR (a.category <> 'Green Star' AND a.source_url = arch_s))
     GROUP BY a.category) g;
  IF cnt <> 230 OR txt <> 'Green Star:19,One Star:174,Three Stars:10,Two Stars:27'
    THEN RAISE EXCEPTION 'GB&I Michelin 2025 with the archive URLs % / % (expected 230 / Green Star:19,One Star:174,Three Stars:10,Two Stars:27)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('GB', 'IE', 'JE');
                                                IF cnt <> 233 THEN RAISE EXCEPTION 'GB/IE/JE Michelin 2025 after % (expected 233)', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url = CASE WHEN r.src = 'G' THEN arch_g ELSE arch_s END;
  IF txt <> 'd9c1efc8511427095a124d59fc9904a6' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected d9c1efc8511427095a124d59fc9904a6)', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> 162 THEN RAISE EXCEPTION 'ledger after % (expected 162)', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 230 AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> 230 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 230)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' IN (arch_s, arch_g);
  IF cnt <> 224 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 224)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' IN (arch_s, arch_g)
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> 6 THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected 6)', cnt; END IF;
END
$do$;
COMMIT;
