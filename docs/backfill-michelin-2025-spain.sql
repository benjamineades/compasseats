-- CompassEats, Nov 1 2026. Item 4: Michelin Guide Spain 2025 (with Andorra) stars from the archive.
-- Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"; 19:35 ET "Y3, Z1, G1" (Y3 check 3 moved/renamed pairs; Z1 use the 3
--   name-only pairs; G1 stars only, no full Spain 2025 Green Star list). Y switch in this build: use.
-- Source (read Nov 1 in the built-in browser; status 200; 0 redirects):
--   https://web.archive.org/web/20241130022008id_/https://guide.michelin.com/es/es/articulo/michelin-guide-ceremony/todas-las-estrellas-de-la-guia-michelin-espana-2025
--   (title "Todas las Estrellas de la Guia MICHELIN Espana 2025"; 292 starred = 16 / 33 / 243; ceremony Murcia, Nov 26 2024)
-- Relay sha256 27850f82436de16518689cbcd617b08c5d4f0ea5f2b56bb945062853155faf67; link map sha256 99ce36e453f63c917974df38f2b1d4aef250dfe9c50aedf72a3a8a98d8c574b6.
-- Built by docs/es-2025-build/build_backfill_es_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in ES / AD ('card'); else the venue id in the build script ('use').
--   Gates: plan md5 505b7c2694bb6f6ac7c16453ae2f6139; seq:venue md5 f3546777d28ca3038df1aecc58648f80; existing 2025 row ids md5 fbb517a822ede96ed0b57a5eb1755c73.
-- Expected: awards UPDATE 3 (source_url) and INSERT 279 (michelin, 2025); 1 ledger row; 282 audit rows (trigger).
--   awards 24,364 -> 24,643. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  arch_s   text := 'https://web.archive.org/web/20241130022008id_/https://guide.michelin.com/es/es/articulo/michelin-guide-ceremony/todas-las-estrellas-de-la-guia-michelin-espana-2025';
  plan_txt text := '[[1, "Three Stars", "casa-marcial", ""], [2, "Three Stars", "abac", ""], [3, "Three Stars", "cocina-hermanos-torres", ""], [4, "Three Stars", "disfrutar", ""], [5, "Three Stars", "lasarte", ""], [6, "Three Stars", "atrio", ""], [7, "Three Stars", "noor", ""], [8, "Three Stars", "quique-dacosta", ""], [9, "Three Stars", "akelare", ""], [10, "Three Stars", "arzak", ""], [11, "Three Stars", "aponiente", ""], [12, "Three Stars", "el-celler-de-can-roca", ""], [13, "Three Stars", "azurmendi", ""], [14, "Three Stars", "martin-berasategui", ""], [15, "Three Stars", "diverxo", ""], [16, "Three Stars", "cenador-de-amos", ""], [17, "Two Stars", "el-rincon-de-juan-carlos-1194880", ""], [18, "Two Stars", "maralba", ""], [19, "Two Stars", "cinc-sentits", ""], [20, "Two Stars", "enoteca204150", ""], [21, "Two Stars", "voro", ""], [22, "Two Stars", "alevante", ""], [23, "Two Stars", "l-escaleta", ""], [24, "Two Stars", "bo-tic", ""], [25, "Two Stars", "venta-moncalvillo", ""], [26, "Two Stars", "amelia-1191398", ""], [27, "Two Stars", "cabana-buenavista", ""], [28, "Two Stars", "mugaritz", ""], [29, "Two Stars", "el-portal", ""], [30, "Two Stars", "m-b", ""], [31, "Two Stars", "lu-cocina-y-alma", ""], [32, "Two Stars", "miramar", ""], [33, "Two Stars", "coque", ""], [34, "Two Stars", "deessa", ""], [35, "Two Stars", "dstage", ""], [36, "Two Stars", "la-terraza-del-casino", ""], [37, "Two Stars", "ramon-freixa-madrid", "ve_b705060cf6"], [38, "Two Stars", "smoked-room", ""], [39, "Two Stars", "skina", ""], [40, "Two Stars", "culler-de-pau", ""], [41, "Two Stars", "les-cols", ""], [42, "Two Stars", "pepe-vieira", ""], [43, "Two Stars", "bardal", ""], [44, "Two Stars", "retiro-da-costina", ""], [45, "Two Stars", "ivan-cerdeno", ""], [46, "Two Stars", "el-molino-de-urdaniz", ""], [48, "Two Stars", "ricard-camarena", ""], [49, "Two Stars", "bonamb", ""], [50, "One Star", "ibaya", ""], [51, "One Star", "arbore-da-veira", ""], [52, "One Star", "donaire", ""], [53, "One Star", "il-bocconcino-by-royal-hideaway", ""], [54, "One Star", "nub-1194862", ""], [55, "One Star", "san-ho", ""], [56, "One Star", "callizo", ""], [57, "One Star", "baeza-rufete", ""], [58, "One Star", "ababol", ""], [59, "One Star", "meson-sabor-andaluz", ""], [60, "One Star", "citrus-del-tancat", ""], [61, "One Star", "atalaya", ""], [62, "One Star", "boroa", ""], [63, "One Star", "solana", ""], [64, "One Star", "ansils", ""], [65, "One Star", "l-alianca-1919-d-angles", ""], [66, "One Star", "les-magnolies", ""], [67, "One Star", "el-corral-del-indianu", ""], [68, "One Star", "barro", ""], [69, "One Star", "etxebarri", ""], [70, "One Star", "txispa", ""], [71, "One Star", "vandelvira", ""], [72, "One Star", "aleia", ""], [73, "One Star", "alkimia", ""], [74, "One Star", "angle", ""], [75, "One Star", "atempo-1196425", ""], [76, "One Star", "aurt", "ve_27266639a6"], [77, "One Star", "caelis", ""], [78, "One Star", "come-by-paco-mendez", ""], [79, "One Star", "dos-palillos", ""], [80, "One Star", "enigma", ""], [81, "One Star", "fishology", ""], [82, "One Star", "hisop", ""], [83, "One Star", "hofmann", ""], [84, "One Star", "koy-shunka", ""], [85, "One Star", "mae-barcelona", ""], [86, "One Star", "moments", ""], [87, "One Star", "mont-bar", ""], [89, "One Star", "prodigi", ""], [90, "One Star", "quirat", ""], [91, "One Star", "slow-low", ""], [92, "One Star", "suto", ""], [93, "One Star", "teatro-kitchen-bar", "ve_6532e88951"], [94, "One Star", "via-veneto", ""], [95, "One Star", "as-garzas", ""], [96, "One Star", "la-boscana", ""], [97, "One Star", "el-ermitano", ""], [98, "One Star", "raul-resino", ""], [99, "One Star", "casa-bernardi", ""], [100, "One Star", "mina", ""], [101, "One Star", "nerua-guggenheim-bilbao", ""], [102, "One Star", "ola-martin-berasategui", ""], [103, "One Star", "zarate", ""], [104, "One Star", "cobo-evolucion", ""], [105, "One Star", "ricardo-temino", ""], [106, "One Star", "codigo-de-barra", ""], [107, "One Star", "can-jubany", ""], [108, "One Star", "audrey-s-by-rafa-soler", ""], [109, "One Star", "beat", ""], [110, "One Star", "orobianco", ""], [111, "One Star", "yayo-daporta", ""], [112, "One Star", "can-bosch", ""], [113, "One Star", "rincon-de-diego", ""], [114, "One Star", "canfranc-express", ""], [115, "One Star", "origen-1214557", ""], [116, "One Star", "magoga", ""], [117, "One Star", "oba", ""], [118, "One Star", "emporium", ""], [119, "One Star", "lera", ""], [120, "One Star", "choco", ""], [121, "One Star", "quatre-molins", ""], [122, "One Star", "casas-colgadas", ""], [123, "One Star", "peix-y-brases", ""], [124, "One Star", "garena", ""], [125, "One Star", "ibai-by-paulo-airaudo", ""], [126, "One Star", "kokotxa", ""], [127, "One Star", "la-gaia", ""], [128, "One Star", "omakase-by-walt", ""], [129, "One Star", "la-costa", ""], [130, "One Star", "tresmacarrons", ""], [131, "One Star", "la-finca", ""], [132, "One Star", "tohqa", "ve_b1c292cecb"], [134, "One Star", "sa-clastra", ""], [135, "One Star", "terra-1204404", ""], [136, "One Star", "sollo", ""], [137, "One Star", "andra-mari220169", ""], [138, "One Star", "elkano", ""], [139, "One Star", "auga", ""], [140, "One Star", "marcos", ""], [141, "One Star", "malena", ""], [142, "One Star", "divinum", ""], [143, "One Star", "massana", ""], [144, "One Star", "la-fonda-xesc", ""], [145, "One Star", "nublo", ""], [146, "One Star", "alameda220551", ""], [147, "One Star", "la-bicicleta", ""], [148, "One Star", "lillas-pastia", ""], [149, "One Star", "tatau", ""], [150, "One Star", "ancestral", "ve_c87595d42b"], [151, "One Star", "el-bohio", ""], [152, "One Star", "baga", ""], [153, "One Star", "dama-juana", ""], [154, "One Star", "malak", ""], [155, "One Star", "radis", ""], [156, "One Star", "mantua", ""], [157, "One Star", "el-xato", ""], [158, "One Star", "haydee-1192780", "ve_4ecd793ec3"], [159, "One Star", "ca-l-enric", ""], [160, "One Star", "eneko", ""], [161, "One Star", "muxgo", ""], [162, "One Star", "poemas-by-hermanos-padron", ""], [163, "One Star", "tabaiba", ""], [164, "One Star", "cocinandos", ""], [165, "One Star", "pablo", ""], [166, "One Star", "els-tinars", ""], [167, "One Star", "el-retiro", ""], [168, "One Star", "andreu-genestra-1208507", ""], [169, "One Star", "ajonegro", ""], [170, "One Star", "ikaro", ""], [171, "One Star", "kiro-sushi", ""], [173, "One Star", "a-barra", ""], [174, "One Star", "cebo-1203091", ""], [175, "One Star", "chispa-bistro", ""], [176, "One Star", "clos-madrid", ""], [177, "One Star", "corral-de-la-moreria-gastronomico", ""], [178, "One Star", "desde-1911", ""], [179, "One Star", "el-invernadero", ""], [180, "One Star", "gaytan", ""], [181, "One Star", "gofio-by-cicero-canary", ""], [182, "One Star", "la-tasqueria", ""], [183, "One Star", "osa", ""], [184, "One Star", "pabu", ""], [185, "One Star", "quimbaya", ""], [186, "One Star", "ravioxo", ""], [187, "One Star", "kabuki-wellington", "ve_dffad438e0"], [188, "One Star", "saddle", ""], [189, "One Star", "santerra", "ve_a76b44705a"], [190, "One Star", "sen-omakase", ""], [191, "One Star", "toki-1205025", ""], [192, "One Star", "ugo-chan", ""], [193, "One Star", "velascoabella", ""], [194, "One Star", "yugo", ""], [195, "One Star", "blossom-1202609", ""], [196, "One Star", "jose-carlos-garcia", ""], [197, "One Star", "kaleja", ""], [198, "One Star", "back", ""], [199, "One Star", "messina", ""], [200, "One Star", "nintai", ""], [201, "One Star", "la-botica", ""], [202, "One Star", "alejandro-serrano", ""], [204, "One Star", "los-guayres", ""], [205, "One Star", "almo", ""], [206, "One Star", "frases", ""], [207, "One Star", "fusion19", ""], [208, "One Star", "la-lobita", ""], [209, "One Star", "sala", ""], [210, "One Star", "casa-pepa", ""], [211, "One Star", "ferpel", ""], [212, "One Star", "ceibe", ""], [213, "One Star", "nova", ""], [215, "One Star", "o-pazo", ""], [216, "One Star", "dins-santi-taura", ""], [217, "One Star", "marc-fosh", ""], [218, "One Star", "zaranda-1191909", ""], [219, "One Star", "es-fum", ""], [220, "One Star", "europa", ""], [221, "One Star", "kabo", ""], [222, "One Star", "rodero", ""], [223, "One Star", "la-aquarela", ""], [224, "One Star", "ambivium", ""], [225, "One Star", "castell-peralada", ""], [226, "One Star", "taste-1973", ""], [227, "One Star", "kamezi", ""], [228, "One Star", "mu%e2%80%a2na", ""], [229, "One Star", "eirado-da-lena", ""], [230, "One Star", "voramar", ""], [231, "One Star", "maca-de-castro", ""], [232, "One Star", "casa-gerardo", ""], [233, "One Star", "taller", ""], [234, "One Star", "ayalga", ""], [235, "One Star", "els-casals", ""], [236, "One Star", "arrels", ""], [237, "One Star", "en-la-parra", ""], [238, "One Star", "victor-gutierrez", ""], [239, "One Star", "real-balneario", ""], [240, "One Star", "deliranto", ""], [241, "One Star", "monte-1190765", ""], [242, "One Star", "montia-1196081", ""], [243, "One Star", "solla", ""], [245, "One Star", "l-o", ""], [246, "One Star", "unic", ""], [247, "One Star", "esperit-roca", ""], [248, "One Star", "casa-nova", ""], [249, "One Star", "lluerna", ""], [250, "One Star", "arrea", ""], [251, "One Star", "casona-del-judio", ""], [252, "One Star", "el-serbal-1197026", ""], [253, "One Star", "a-tafona", ""], [254, "One Star", "casa-marcelo", ""], [255, "One Star", "simpar", "ve_5cb5124e0b"], [256, "One Star", "la-era-de-los-nogales", ""], [257, "One Star", "refectorio", ""], [258, "One Star", "abantal", ""], [259, "One Star", "canabota", ""], [260, "One Star", "el-doncel", ""], [261, "One Star", "el-molino-de-alcuneza", ""], [264, "One Star", "fogony", ""], [265, "One Star", "raices-carlos-maldonado", ""], [266, "One Star", "ama", ""], [267, "One Star", "epilogo", ""], [268, "One Star", "coto-de-quevedo", ""], [269, "One Star", "retama", ""], [270, "One Star", "hospederia-el-batan", ""], [271, "One Star", "l-antic-moli", ""], [272, "One Star", "les-moles", ""], [273, "One Star", "la-casa-de-manolo-franco", ""], [274, "One Star", "chiron", ""], [275, "One Star", "fierro", ""], [276, "One Star", "fraula", ""], [277, "One Star", "kaido-sushi-bar", ""], [278, "One Star", "la-salita-1192181", ""], [279, "One Star", "lienzo", ""], [280, "One Star", "riff", ""], [281, "One Star", "cal-paradis", ""], [282, "One Star", "alquimia", ""], [283, "One Star", "trigo", ""], [284, "One Star", "casa-arcas", ""], [285, "One Star", "maruja-limon", ""], [286, "One Star", "silabario", ""], [287, "One Star", "tula", ""], [288, "One Star", "villa-retiro", ""], [290, "One Star", "gente-rara", ""], [291, "One Star", "la-prensa", ""], [292, "One Star", "versatil", ""]]';
  job_txt  text := 'backfill:michelin-2025-spain-archive | item 4 (Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"; 19:35 ET "Y3, Z1, G1"): Michelin Guide Spain 2025 (with Andorra) stars from web.archive.org | 3 existing 2025 star rows get the source_url; 279 rows inserted (One Star:234,Three Stars:16,Two Stars:32 in all 282) | source_url = https://web.archive.org/web/20241130022008id_/https://guide.michelin.com/es/es/articulo/michelin-guide-ceremony/todas-las-estrellas-de-la-guia-michelin-espana-2025 | relay docs/es-2025-build/relay-es-2025-archive-20241130.txt sha256 27850f82...5faf67; card links links-es-2025-archive-20241130.txt sha256 99ce36e4...c574b6 | counts = article 292 starred (16/33/243, One Star 242 Spain + 1 Andorra) | ceremony Murcia, Nov 26 2024 | match: card link = Michelin card of an existing award row (273); venue id, 2025 row: 187 -> ve_dffad438e0; 189 -> ve_a76b44705a; 255 -> ve_5cb5124e0b; Y moved/renamed (Michelin card or press evidence): 37 -> ve_b705060cf6; 150 -> ve_c87595d42b; 158 -> ve_4ecd793ec3; Z1 name-only: 76 -> ve_27266639a6; 93 -> ve_6532e88951; 132 -> ve_b1c292cecb | Q1 skipped: El Poblet; Oria; Etxeko Ibiza; La Finca; Erre de Roca; NM; Es Tragón; Béns d’Avall; Baluarte; Cancook | G1: 2025 Green Stars not loaded (no full list found; las-estrellas-verdes-2025-9-novedades lists 9 new only; selection page archived page 1 only) | 2025 Bibs: no full list (N1), no change | plan md5 505b7c2694bb6f6ac7c16453ae2f6139';
  pj jsonb; rj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> '505b7c2694bb6f6ac7c16453ae2f6139' OR cnt <> 282 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected 505b7c2694bb6f6ac7c16453ae2f6139 / 282)', txt, cnt; END IF;

WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/restaurante?/' AND c.country_iso IN ('ES', 'AD')),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how
        FROM p LEFT JOIN t1 USING (seq))
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> 'f3546777d28ca3038df1aecc58648f80' THEN RAISE EXCEPTION 'seq:venue md5 % (expected f3546777d28ca3038df1aecc58648f80)', txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso IN ('ES', 'AD');
  IF cnt <> 282 THEN RAISE EXCEPTION 'venues in ES/AD % (expected 282)', cnt; END IF;
  SELECT count(DISTINCT vid) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 282 THEN RAISE EXCEPTION 'distinct venues % (expected 282)', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> 3 OR txt <> 'fbb517a822ede96ed0b57a5eb1755c73' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected 3 / fbb517a822ede96ed0b57a5eb1755c73)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> 3 THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected 3)', cnt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
   WHERE a.category IN ('Three Stars', 'Two Stars', 'One Star') AND a.category <> r.cat;
  IF cnt <> 0 THEN RAISE EXCEPTION 'venues with a different 2025 star row: %', cnt; END IF;
  SELECT md5(string_agg(id::text, ',' ORDER BY id)) INTO txt FROM awards WHERE id IN (6331,6335,7867);
  IF txt <> 'fbb517a822ede96ed0b57a5eb1755c73' THEN RAISE EXCEPTION 'existing id list md5 % (expected fbb517a822ede96ed0b57a5eb1755c73)', txt; END IF;

  -- 2. Counts before (read 2026-11-02 00:38:58 UTC)
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> 24364 OR num <> 31303 THEN RAISE EXCEPTION 'awards before % / max % (expected 24364 / 31303)', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 10660 THEN RAISE EXCEPTION 'Michelin awards before % (expected 10660)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 4284 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 4284)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3224 THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected 3224)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 31 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 31)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('ES', 'AD');
                                                IF cnt <> 6 THEN RAISE EXCEPTION 'ES/AD Michelin 2025 before % (expected 6)', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 163 OR led_max <> 215 THEN RAISE EXCEPTION 'ledger before % / max % (expected 163 / 215)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 117301 OR aud_max <> 122813 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 117301 / 122813)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = arch_s
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 3 THEN RAISE EXCEPTION 'award rows updated % (expected 3)', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, arch_s FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 279 THEN RAISE EXCEPTION 'award rows inserted % (expected 279)', cnt; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 282, job_txt);
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', cnt; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO cnt FROM awards;         IF cnt <> 24643 THEN RAISE EXCEPTION 'awards after % (expected 24643)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 10939 THEN RAISE EXCEPTION 'Michelin awards after % (expected 10939)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 4563 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 4563)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3221 THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected 3221)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 31 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 31)', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url = arch_s
     GROUP BY a.category) g;
  IF cnt <> 282 OR txt <> 'One Star:234,Three Stars:16,Two Stars:32'
    THEN RAISE EXCEPTION 'Spain Michelin 2025 with the archive URL % / % (expected 282 / One Star:234,Three Stars:16,Two Stars:32)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('ES', 'AD');
                                                IF cnt <> 285 THEN RAISE EXCEPTION 'ES/AD Michelin 2025 after % (expected 285)', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url = arch_s;
  IF txt <> 'f3546777d28ca3038df1aecc58648f80' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected f3546777d28ca3038df1aecc58648f80)', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> 164 THEN RAISE EXCEPTION 'ledger after % (expected 164)', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 282 AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> 282 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 282)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' = arch_s;
  IF cnt <> 279 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 279)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = arch_s
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> 3 THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected 3)', cnt; END IF;
END
$do$;
COMMIT;
