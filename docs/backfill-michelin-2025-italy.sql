-- CompassEats, Nov 2 2026. Item 4: Michelin Guide Italy 2025 stars from the archive.
-- Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"; Nov 2 05:44 ET "Z2, H2, G1" (Z2 check 5 name-only pairs against the venue's
--   own site; H2 examine both San Martino cards; G1 stars only, no full Italy 2025 Green Star list).
--   Switches in this build: Contaminazioni use; San Martino a.
-- Source (read Nov 1 in the built-in browser; status 200; 0 redirects):
--   https://web.archive.org/web/20241105213726id_/https://guide.michelin.com/it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia
--   (title "Tutte le stelle della Guida MICHELIN Italia 2025!"; 393 starred = 14 / 38 / 341; ceremony Parma, Nov 5 2024)
-- Relay sha256 d5c2a9ebda5f251167ad8460c457a30ca133cd2ff4c0747e9f128f1a29b25b39.
-- Built by docs/it-2025-build/build_backfill_it_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in IT / SM ('card'); else the venue id in the build script ('use').
--   Gates: plan md5 d748ff347794c270a01b59e4eab15189; seq:venue md5 4c25150f45bcaf66094ba69ed5f7402a; existing 2025 row ids md5 0548104fe69a02b66108b6a0b6084a9a.
-- Expected: awards UPDATE 2 (source_url) and INSERT 365 (michelin, 2025); 1 ledger row; 367 audit rows (trigger).
--   awards 24,713 -> 25,078. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  arch_s   text := 'https://web.archive.org/web/20241105213726id_/https://guide.michelin.com/it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia';
  plan_txt text := '[[1, "Three Stars", "piazza-duomo", ""], [2, "Three Stars", "atelier-moessmer-norbert-niederkofler", ""], [3, "Three Stars", "da-vittorio", ""], [4, "Three Stars", "reale", ""], [5, "Three Stars", "enoteca-pinchiorri", ""], [6, "Three Stars", "enrico-bartolini-al-mudec", ""], [7, "Three Stars", "osteria-francescana", ""], [8, "Three Stars", "quattro-passi", ""], [9, "Three Stars", "villa-crespi", ""], [10, "Three Stars", "la-pergola69016", ""], [11, "Three Stars", "le-calandre", ""], [12, "Three Stars", "dal-pescatore", ""], [13, "Three Stars", "uliassi", ""], [14, "Three Stars", "casa-perbellini", ""], [15, "Two Stars", "l-olivo", ""], [16, "Two Stars", "villa-elena", ""], [17, "Two Stars", "taverna-estia", ""], [18, "Two Stars", "piazzetta-milu", ""], [19, "Two Stars", "antica-corona-reale", ""], [20, "Two Stars", "locanda-del-sant-uffizio-enrico-bartolini", ""], [21, "Two Stars", "arnolfo", ""], [22, "Two Stars", "miramonti-l-altro", ""], [23, "Two Stars", "d-o", ""], [24, "Two Stars", "santa-elisabetta", ""], [25, "Two Stars", "villa-feltrinelli", ""], [26, "Two Stars", "agli-amici", ""], [27, "Two Stars", "san-domenico", ""], [28, "Two Stars", "dani-maison", ""], [29, "Two Stars", "la-madia", ""], [30, "Two Stars", "magnolia", ""], [31, "Two Stars", "la-peca", ""], [32, "Two Stars", "antica-osteria-cera", ""], [33, "Two Stars", "madonnina-del-pescatore", ""], [34, "Two Stars", "verso-capitaneo", ""], [35, "Two Stars", "andrea-aprea", ""], [36, "Two Stars", "seta-by-antonio-guida", ""], [37, "Two Stars", "campo-del-drago", ""], [38, "Two Stars", "caino", ""], [39, "Two Stars", "george-restaurant", ""], [40, "Two Stars", "duomo160079", ""], [41, "Two Stars", "acquolina", ""], [42, "Two Stars", "il-pagliaccio", ""], [43, "Two Stars", "enoteca-la-torre", ""], [44, "Two Stars", "terra151934", ""], [45, "Two Stars", "la-rei-natura-by-michelangelo-mammoliti", ""], [46, "Two Stars", "st-george-by-heinz-beck", ""], [47, "Two Stars", "kresios", ""], [48, "Two Stars", "castel-fine-dining", ""], [49, "Two Stars", "harry-s-piccolo", ""], [50, "Two Stars", "glam-enrico-bartolini", ""], [51, "Two Stars", "il-piccolo-principe", ""], [52, "Two Stars", "torre-del-saracino", ""], [53, "One Star", "la-bandiera", ""], [54, "One Star", "villa-maiella", ""], [55, "One Star", "d-one-restaurant-diffuso", ""], [56, "One Star", "al-metro", ""], [58, "One Star", "vitantonio-lombardo", ""], [60, "One Star", "abbruzzino-oltre", ""], [62, "One Star", "gambero-rosso", ""], [63, "One Star", "hyle", ""], [64, "One Star", "qafiz", ""], [65, "One Star", "dattilo", ""], [66, "One Star", "alici", ""], [67, "One Star", "glicine", ""], [68, "One Star", "la-caravella-dal-1959", ""], [69, "One Star", "sensi536205", ""], [70, "One Star", "maeba-restaurant", ""], [71, "One Star", "caracol", ""], [72, "One Star", "cetaria", ""], [73, "One Star", "le-monzu", ""], [74, "One Star", "il-refettorio", ""], [75, "One Star", "il-papavero", ""], [76, "One Star", "bluh-furore", ""], [77, "One Star", "o-me-o-il-mare", ""], [78, "One Star", "indaco", ""], [79, "One Star", "relais-blu", ""], [80, "One Star", "aria-1197785", ""], [81, "One Star", "veritas", ""], [82, "One Star", "taverna-del-capitano", ""], [83, "One Star", "re-santi-e-leoni", ""], [84, "One Star", "le-trabe", ""], [86, "One Star", "tre-olivi", ""], [87, "One Star", "president", ""], [88, "One Star", "li-galli", ""], [89, "One Star", "zass", ""], [90, "One Star", "un-piano-nel-cielo", ""], [92, "One Star", "il-flauto-di-pan", ""], [93, "One Star", "rossellinis", ""], [95, "One Star", "don-geppi", ""], [96, "One Star", "don-alfonso-1890-151521", ""], [97, "One Star", "contaminazioni-restaurant", "ve_48a3d8cc5d"], [98, "One Star", "il-buco", ""], [99, "One Star", "lorelei", ""], [100, "One Star", "terrazza-bosquet", ""], [101, "One Star", "marotta", ""], [102, "One Star", "la-locanda-del-borgo", ""], [103, "One Star", "cannavacciuolo-countryside", ""], [105, "One Star", "oasis-sapori-antichi", ""], [106, "One Star", "antica-osteria-nonna-rosa", ""], [107, "One Star", "volta-del-fuenti", ""], [108, "One Star", "del-lago", ""], [109, "One Star", "i-portici", ""], [110, "One Star", "la-palta", ""], [111, "One Star", "iacobucci", ""], [112, "One Star", "ancora-1213776", ""], [113, "One Star", "la-buca130947", ""], [114, "One Star", "la-zanzara", ""], [115, "One Star", "alto", ""], [116, "One Star", "al-gatto-verde", ""], [117, "One Star", "l-erba-del-re", ""], [118, "One Star", "inkiostro", ""], [119, "One Star", "il-piastrino", ""], [120, "One Star", "antica-corte-pallavicina", ""], [121, "One Star", "abocar-due-cucine", ""], [122, "One Star", "guido", ""], [123, "One Star", "ca-matilde", ""], [125, "One Star", "osteria-del-viandante", ""], [126, "One Star", "da-gorini", ""], [127, "One Star", "casa-mazzucchelli", ""], [128, "One Star", "trattoria-da-amerigo", ""], [129, "One Star", "trattoria-al-cacciatore-della-subida", ""], [130, "One Star", "l-argine-a-venco", ""], [131, "One Star", "osteria-altran", ""], [132, "One Star", "la-primula", ""], [133, "One Star", "laite", ""], [134, "One Star", "colline-ciociare", ""], [135, "One Star", "sintesi", ""], [136, "One Star", "il-tino", ""], [137, "One Star", "pascucci-al-porticciolo", ""], [138, "One Star", "aminta-resort", ""], [139, "One Star", "antonello-colonna-labico", ""], [140, "One Star", "mater1apr1ma", ""], [141, "One Star", "acqua-pazza-1192022", ""], [142, "One Star", "la-trota", ""], [143, "One Star", "enoteca-al-parlamento-achilli", ""], [144, "One Star", "all-oro", ""], [145, "One Star", "aroma", ""], [146, "One Star", "glass-hostaria", ""], [147, "One Star", "idylio-by-apreda", ""], [148, "One Star", "il-convivio-troiani", ""], [149, "One Star", "imago", ""], [150, "One Star", "marco-martini-restaurant", ""], [151, "One Star", "moma", ""], [152, "One Star", "orma-roma", ""], [153, "One Star", "per-me-giulio-terrinoni", ""], [154, "One Star", "pipero", ""], [155, "One Star", "pulejo", ""], [156, "One Star", "zia", ""], [158, "One Star", "la-parolina", ""], [159, "One Star", "nove", ""], [160, "One Star", "vignamare", ""], [161, "One Star", "impronta-d-acqua", ""], [162, "One Star", "equilibrio", ""], [163, "One Star", "il-marin-eataly", ""], [164, "One Star", "san-giorgio562345", ""], [166, "One Star", "sarri", ""], [167, "One Star", "il-vescovado", ""], [168, "One Star", "paolo-e-barbara", ""], [169, "One Star", "balzi-rossi", "ve_13f18c5fed"], [170, "One Star", "casa-buono", ""], [171, "One Star", "il-cantuccio", ""], [172, "One Star", "grow-restaurant", ""], [173, "One Star", "impronte", ""], [174, "One Star", "due-colombe", ""], [175, "One Star", "al-gambero", ""], [176, "One Star", "il-saraceno", ""], [177, "One Star", "materia", ""], [178, "One Star", "kitchen-325766", ""], [179, "One Star", "olmo", ""], [180, "One Star", "esplanade", ""], [181, "One Star", "acquerello197794", ""], [182, "One Star", "il-fagiano", ""], [183, "One Star", "lido-84", "ve_e16ffafc83"], [184, "One Star", "la-tortuga", ""], [185, "One Star", "la-coldana", ""], [186, "One Star", "trattoria-contemporanea", ""], [187, "One Star", "il-cantinone-e-sport-hotel-alpina", ""], [188, "One Star", "capriccio", ""], [189, "One Star", "la-presef", ""], [190, "One Star", "anima-fine-dining", ""], [191, "One Star", "berton", ""], [192, "One Star", "contraste", ""], [193, "One Star", "cracco", ""], [195, "One Star", "horto-1204821", ""], [196, "One Star", "il-luogo-di-aimo-e-nadia", ""], [197, "One Star", "iyo", ""], [198, "One Star", "aalto", ""], [199, "One Star", "joia", ""], [200, "One Star", "moebius-sperimentale", ""], [201, "One Star", "sadler", ""], [202, "One Star", "sine", ""], [204, "One Star", "acqua-1201998", ""], [205, "One Star", "contrada-bricconi", ""], [206, "One Star", "cucina-cereda", ""], [207, "One Star", "leon-d-oro146788", ""], [209, "One Star", "casa-leali", ""], [210, "One Star", "sui-generis", ""], [211, "One Star", "la-rucola-2-0", ""], [212, "One Star", "la-speranzina-restaurant-relais", ""], [213, "One Star", "tancredi", ""], [214, "One Star", "osteria-degli-assonica", "ve_62d9bf3a36"], [215, "One Star", "villa-naj", ""], [216, "One Star", "il-sereno-al-lago", ""], [217, "One Star", "loro", ""], [219, "One Star", "i-castagni", ""], [220, "One Star", "osteria-della-brughiera", ""], [221, "One Star", "lanterna-verde", ""], [222, "One Star", "dalla-gioconda", ""], [223, "One Star", "andreina", ""], [224, "One Star", "il-tiglio", ""], [225, "One Star", "nostrano", ""], [227, "One Star", "retroscena", ""], [228, "One Star", "locanda-mammi", ""], [229, "One Star", "locanda-del-pilone", ""], [230, "One Star", "cannavacciuolo-le-cattedrali-asti", ""], [231, "One Star", "all-enoteca", ""], [232, "One Star", "atelier161790", ""], [233, "One Star", "massimo-camia", ""], [234, "One Star", "borgo-sant-anna", ""], [235, "One Star", "fre", ""], [236, "One Star", "locanda-di-orta", ""], [237, "One Star", "cannavacciuolo-by-the-lake", ""], [238, "One Star", "zappatori", ""], [239, "One Star", "21-9", ""], [240, "One Star", "il-patio", ""], [241, "One Star", "il-centro", ""], [242, "One Star", "la-credenza", ""], [243, "One Star", "il-ristorante-di-guido-da-costigliole", ""], [244, "One Star", "guido361561", ""], [245, "One Star", "al-sorriso", ""], [246, "One Star", "ca-vittoria", ""], [247, "One Star", "andrea-larossa", ""], [248, "One Star", "cannavacciuolo-bistrot", ""], [249, "One Star", "carignano", ""], [250, "One Star", "condividere", ""], [251, "One Star", "del-cambio", ""], [253, "One Star", "piano-35", ""], [254, "One Star", "unforgettable", ""], [255, "One Star", "vintage-1997", ""], [256, "One Star", "la-ciau-del-tornavento", ""], [257, "One Star", "dolce-stil-novo-alla-reggia", ""], [258, "One Star", "nazionale", ""], [259, "One Star", "dissapore-di-andrea-catalano", ""], [260, "One Star", "pasha", ""], [262, "One Star", "primo-restaurant", ""], [263, "One Star", "casamatta", ""], [265, "One Star", "angelo-sabatelli", ""], [266, "One Star", "due-camini", ""], [267, "One Star", "casa-sgarra", ""], [268, "One Star", "quintessenza-1195965", ""], [269, "One Star", "confusion", ""], [270, "One Star", "fradis-minoris", ""], [271, "One Star", "il-fuoco-sacro", ""], [272, "One Star", "gusto-by-sadler", ""], [273, "One Star", "zash", ""], [274, "One Star", "i-pupi", ""], [275, "One Star", "limu", ""], [276, "One Star", "coria", ""], [277, "One Star", "sapio", ""], [278, "One Star", "i-tenerumi", ""], [279, "One Star", "il-cappero", ""], [280, "One Star", "shalai", ""], [281, "One Star", "signum", ""], [282, "One Star", "votavota", ""], [284, "One Star", "crocifisso", ""], [285, "One Star", "mec-restaurant", ""], [286, "One Star", "locanda-don-serafino", ""], [287, "One Star", "cortile-spirito-santo", ""], [288, "One Star", "la-capinera", ""], [289, "One Star", "otto-geleng", ""], [290, "One Star", "principe-cerami", ""], [291, "One Star", "vineria-modi", ""], [292, "One Star", "il-bavaglino-1206991", ""], [293, "One Star", "octavin", "ve_df6d5db906"], [295, "One Star", "cannavacciuolo-vineyard", ""], [296, "One Star", "contrada", ""], [297, "One Star", "poggio-rosso", ""], [298, "One Star", "il-visibilio", ""], [299, "One Star", "l-asinello", ""], [300, "One Star", "la-trattoria-enrico-bartolini", ""], [301, "One Star", "saporium", ""], [302, "One Star", "serrae-villa-fiesole", ""], [303, "One Star", "atto-di-vito-mollica", ""], [304, "One Star", "borgo-san-jacopo", ""], [305, "One Star", "gucci-osteria-da-massimo-bottura", ""], [306, "One Star", "il-palagio", ""], [307, "One Star", "saporium-firenze", ""], [308, "One Star", "bistrot", ""], [309, "One Star", "la-magnolia", ""], [310, "One Star", "lorenzo", ""], [311, "One Star", "lux-lucis", ""], [312, "One Star", "locanda-dei-banchieri", ""], [313, "One Star", "il-pievano", ""], [314, "One Star", "bracali", ""], [315, "One Star", "la-pineta", ""], [317, "One Star", "butterfly", ""], [318, "One Star", "sala-dei-grappoli", ""], [319, "One Star", "osmosi", ""], [320, "One Star", "osteria-di-passignano", ""], [321, "One Star", "il-pellicano", ""], [322, "One Star", "paca", ""], [324, "One Star", "linfa", ""], [325, "One Star", "il-falconiere", ""], [326, "One Star", "silene", ""], [327, "One Star", "la-torre166500", ""], [328, "One Star", "lunasia500267", ""], [329, "One Star", "romano", ""], [330, "One Star", "atman", "ve_48fe5153e8"], [331, "One Star", "peter-brunel-ristorante-gourmet", ""], [332, "One Star", "apostelstube", ""], [333, "One Star", "kuppelrain", ""], [334, "One Star", "el-molin", ""], [335, "One Star", "la-stua-de-michil", ""], [336, "One Star", "tilia", ""], [337, "One Star", "luisl-stube", ""], [338, "One Star", "dolomieu", ""], [339, "One Star", "il-gallo-cedrone", ""], [340, "One Star", "stube-hermitage", ""], [341, "One Star", "in-viaggio-claudio-melis1154911", ""], [342, "One Star", "prezioso", ""], [343, "One Star", "sissi", ""], [344, "One Star", "malga-panna", ""], [345, "One Star", "schoneck", ""], [346, "One Star", "gourmetstube-einhorn", ""], [347, "One Star", "johannes-stube", ""], [348, "One Star", "anna-stuben", ""], [349, "One Star", "grual", ""], [350, "One Star", "locanda-margon", ""], [351, "One Star", "osteria-acquarol", ""], [352, "One Star", "zur-rose", ""], [353, "One Star", "alpenroyal-gourmet", ""], [354, "One Star", "suinsom", ""], [355, "One Star", "zum-lowen", "ve_c61d257fcf"], [356, "One Star", "casa-vissani", "ve_bcb1504177"], [357, "One Star", "une", ""], [358, "One Star", "vespasia", ""], [359, "One Star", "ada", ""], [361, "One Star", "elementi", ""], [362, "One Star", "paolo-griffa-al-caffe-nazionale", ""], [363, "One Star", "vecchio-ristoro", ""], [364, "One Star", "wood460913", ""], [365, "One Star", "casin-del-gamba", ""], [366, "One Star", "damini-macelleria-affini", ""], [367, "One Star", "la-tana-gourmet", ""], [368, "One Star", "aqua-crua", ""], [369, "One Star", "storie-d-amore", ""], [370, "One Star", "nin", ""], [371, "One Star", "oseleta", ""], [372, "One Star", "amista-33", ""], [373, "One Star", "sanbrite", ""], [374, "One Star", "tivoli", ""], [376, "One Star", "vecchia-malcesine", ""], [377, "One Star", "la-favellina", ""], [378, "One Star", "venissa", ""], [379, "One Star", "gellius", ""], [380, "One Star", "famiglia-rana", ""], [381, "One Star", "dolada", ""], [382, "One Star", "lazzaro-1915", ""], [383, "One Star", "locanda-san-lorenzo", ""], [384, "One Star", "spinechile", ""], [385, "One Star", "san-martino", "ve_74d392b2d5"], [386, "One Star", "local", ""], [387, "One Star", "oro-restaurant", ""], [389, "One Star", "quadri", ""], [390, "One Star", "wisteria", ""], [391, "One Star", "wisteria", "ve_b24b1c1085"], [392, "One Star", "wisteria", "ve_acdfd2daf5"]]';
  job_txt  text := 'backfill:michelin-2025-italy-archive | item 4 (Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"; Nov 2 05:44 ET "Z2, H2, G1"): Michelin Guide Italy 2025 stars from web.archive.org | 2 existing 2025 star rows get the source_url; 365 rows inserted (One Star:315,Three Stars:14,Two Stars:38 in all 367) | source_url = https://web.archive.org/web/20241105213726id_/https://guide.michelin.com/it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia | relay docs/it-2025-build/relay-it-2025-archive-20241105.txt sha256 d5c2a9eb...b25b39 | counts = article 393 starred (14/38/341) = ceremony article total 393 | ceremony Parma, Nov 5 2024 | match: card link = Michelin card of an existing award row (356); venue id, 2025 row: 293 -> ve_df6d5db906; 330 -> ve_48fe5153e8; name pair, 2026 card same town: 214 -> ve_62d9bf3a36; 391 -> ve_b24b1c1085; 392 -> ve_acdfd2daf5 (391, 392: article links point to the Wisteria card); Z2 name-only (own site or press): 97 -> ve_48a3d8cc5d; 169 -> ve_13f18c5fed; 183 -> ve_e16ffafc83; 355 -> ve_c61d257fcf; 356 -> ve_bcb1504177; H2: 385 -> ve_74d392b2d5 (San Martino Scorze; Michelin 2026 lists Scorze and Treviglio; 218 Treviglio skipped, no venue; the Scorze venue 2026 row holds the Treviglio card) | Q1 skipped: Don Alfonso 1890 San Barbato; Abbruzzino; Luigi Lepore; Osteria Arbustico; Sud; Re Maurì; Tenuta Villa Guerra; Arnaldo - Clinica Gastronomica; Essenza; The Cook; Felix Lo Basso home & restaurant; Il Circolino; Sedicesimo Secolo; L''Arcade; Magorabin; Bros''; Porta di Basso; Accursio; Terramira; Gabbiano 3.0; Castello di Fighine; L''Acciuga; Vite; Palais Royal Restaurant; Matteo Grandi in Basilica | G1: 2025 Green Stars not loaded (total 69; guida-michelin-italia-2025-11-nuove-stelle-verdi lists 11 new only; selection page archived page 1 only, 48 of 68) | 2025 Bibs: no full list (N1), no change | plan md5 d748ff347794c270a01b59e4eab15189';
  pj jsonb; rj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> 'd748ff347794c270a01b59e4eab15189' OR cnt <> 367 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected d748ff347794c270a01b59e4eab15189 / 367)', txt, cnt; END IF;

WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante|ristorante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/(restaurant|restaurante|ristorante)/' AND c.country_iso IN ('IT', 'SM')),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how
        FROM p LEFT JOIN t1 USING (seq))
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> '4c25150f45bcaf66094ba69ed5f7402a' THEN RAISE EXCEPTION 'seq:venue md5 % (expected 4c25150f45bcaf66094ba69ed5f7402a)', txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso IN ('IT', 'SM');
  IF cnt <> 367 THEN RAISE EXCEPTION 'venues in IT/SM % (expected 367)', cnt; END IF;
  SELECT count(DISTINCT vid) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 367 THEN RAISE EXCEPTION 'distinct venues % (expected 367)', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> 2 OR txt <> '0548104fe69a02b66108b6a0b6084a9a' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected 2 / 0548104fe69a02b66108b6a0b6084a9a)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> 2 THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected 2)', cnt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
   WHERE a.category IN ('Three Stars', 'Two Stars', 'One Star') AND a.category <> r.cat;
  IF cnt <> 0 THEN RAISE EXCEPTION 'venues with a different 2025 star row: %', cnt; END IF;
  SELECT md5(string_agg(id::text, ',' ORDER BY id)) INTO txt FROM awards WHERE id IN (3729,8939);
  IF txt <> '0548104fe69a02b66108b6a0b6084a9a' THEN RAISE EXCEPTION 'existing id list md5 % (expected 0548104fe69a02b66108b6a0b6084a9a)', txt; END IF;

  -- 2. Counts before (read 2026-11-02 10:59:28 UTC)
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> 24713 OR num <> 31652 THEN RAISE EXCEPTION 'awards before % / max % (expected 24713 / 31652)', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 11009 THEN RAISE EXCEPTION 'Michelin awards before % (expected 11009)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 4633 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 4633)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3220 THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected 3220)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 55 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 55)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('IT', 'SM');
                                                IF cnt <> 4 THEN RAISE EXCEPTION 'IT/SM Michelin 2025 before % (expected 4)', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 165 OR led_max <> 217 THEN RAISE EXCEPTION 'ledger before % / max % (expected 165 / 217)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 117654 OR aud_max <> 123166 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 117654 / 123166)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = arch_s
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 2 THEN RAISE EXCEPTION 'award rows updated % (expected 2)', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, arch_s FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 365 THEN RAISE EXCEPTION 'award rows inserted % (expected 365)', cnt; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 367, job_txt);
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', cnt; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO cnt FROM awards;         IF cnt <> 25078 THEN RAISE EXCEPTION 'awards after % (expected 25078)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 11374 THEN RAISE EXCEPTION 'Michelin awards after % (expected 11374)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 4998 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 4998)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3218 THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected 3218)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 55 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 55)', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url = arch_s
     GROUP BY a.category) g;
  IF cnt <> 367 OR txt <> 'One Star:315,Three Stars:14,Two Stars:38'
    THEN RAISE EXCEPTION 'Italy Michelin 2025 with the archive URL % / % (expected 367 / One Star:315,Three Stars:14,Two Stars:38)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('IT', 'SM');
                                                IF cnt <> 369 THEN RAISE EXCEPTION 'IT/SM Michelin 2025 after % (expected 369)', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url = arch_s;
  IF txt <> '4c25150f45bcaf66094ba69ed5f7402a' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected 4c25150f45bcaf66094ba69ed5f7402a)', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> 166 THEN RAISE EXCEPTION 'ledger after % (expected 166)', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 367 AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> 367 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 367)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' = arch_s;
  IF cnt <> 365 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 365)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = arch_s
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> 2 THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected 2)', cnt; END IF;
END
$do$;
COMMIT;
