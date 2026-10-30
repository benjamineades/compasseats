-- price-michelin-card-p2-b1-2026-10-30.sql
-- Block A, step 2, batch 1 (France part 1).
-- Population P2: active venues with a Michelin One Star, Two Stars, Three Stars or Bib Gourmand row whose source_url is
-- a guide.michelin.com card URL (latest by year desc, id desc), and a price row with source legacy_guide and no source_url.
-- Source: the live Michelin card page (Price: line, data-sheet), read in the built-in browser.
-- Rows: 473 UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
-- source_url = card URL, symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
-- captured_at = read time). Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026).
-- Cards that show Selected only are also updated; award rows do not change (Ben, Oct 30, 2026; Oct 10 ruling).
-- Currencies: EUR 473. Card tiers: 1 = 6, 2 = 185, 3 = 72, 4 = 210. Card distinction: 1 star 232, 2 star 33, 3 star 17, bib 191.
-- Relay sha256 0461133228d5637042b2358354a654bed31c7d4a4a4357ddb5cbc8e60f7103a2 (inside this file).
-- Guards: counts before (price 7582, ledger max 140, audit max 113968); relay fingerprint md5
-- 611adefe4ed3a28e38878542fc391cd2; venue id md5 cf1c89ad4bc1241cff771e3536900c8f; old price rows md5 06d158dfc45db5e772dda7133825506a;
-- each row in P2 now with the same card URL.
-- Post-checks: price count 7582 (unchanged); ledger 141; audit 473 price UPDATE rows, nothing else;
-- each price row now matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_0046e8758c|en/auvergne-rhone-alpes/vonnas/restaurant/georges-blanc|€€€€|CAT_P04|2 star|fr|2026-10-30T04:59:13.017Z
ve_0092e19fc4|en/occitanie/montpellier/restaurant/la-reserve-rimbaud|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:14.371Z
ve_018398d0e7|en/provence-alpes-cote-dazur/marseille/restaurant/auffo|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:15.735Z
ve_01ff2b098d|en/normandie/rouen/restaurant/l-odas|€€€|CAT_P03|1 star|fr|2026-10-30T04:59:17.096Z
ve_020095097a|en/auvergne-rhone-alpes/vaux-en-beaujolais/restaurant/auberge-de-clochemerle|€€€|CAT_P03|1 star|fr|2026-10-30T04:59:18.444Z
ve_023efa5fc2|en/bourgogne-franche-comte/saint-rmy/restaurant/cedric-burtin|€€€€|CAT_P04|2 star|fr|2026-10-30T04:59:19.803Z
ve_024c410f00|en/auvergne-rhone-alpes/seytroux_1515695/restaurant/kern|€€€|CAT_P03|1 star|fr|2026-10-30T04:59:21.146Z
ve_0283d6c66f|en/normandie/le-havre/restaurant/le-margote|€€|CAT_P02|bib|fr|2026-10-30T04:59:22.490Z
ve_02d7a5a265|en/nouvelle-aquitaine/jarnac-champagne_1477221/restaurant/le-coude-a-coude-1217411|€€|CAT_P02|bib|fr|2026-10-30T04:59:23.832Z
ve_0320deb2e1|en/normandie/saint-langis-les-mortagne/restaurant/les-pieds-dans-l-eau|€€|CAT_P02|bib|fr|2026-10-30T04:59:25.175Z
ve_0333b4f6bc|en/corse/porticcio/restaurant/le-charlie|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:26.539Z
ve_0360eb1bd8|en/occitanie/saint-lizier/restaurant/le-carre-de-l-ange|€€|CAT_P02|bib|fr|2026-10-30T04:59:27.880Z
ve_03713b2a92|en/bourgogne-franche-comte/chablis/restaurant/chablis-wine-not|€€|CAT_P02|bib|fr|2026-10-30T04:59:29.216Z
ve_037f0184a7|en/occitanie/ste/restaurant/paris-mediterranee|€€|CAT_P02|bib|fr|2026-10-30T04:59:30.566Z
ve_03b9b4f203|en/centre-val-de-loire/amboise/restaurant/chateau-de-pray|€€€|CAT_P03|1 star|fr|2026-10-30T04:59:31.910Z
ve_03cccc1eff|en/auvergne-rhone-alpes/chasselay/restaurant/guy-lassausaie|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:33.242Z
ve_049080c2ad|en/nouvelle-aquitaine/irouleguy/restaurant/jarapea|€€|CAT_P02|bib|fr|2026-10-30T04:59:34.590Z
ve_0497d10eb2|en/bretagne/pont-aven/restaurant/moulin-de-rosmadec|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:35.934Z
ve_0500893ff4|en/nouvelle-aquitaine/mont-de-marsan/restaurant/villa-mirasol-bistrot-1912|€€|CAT_P02|bib|fr|2026-10-30T04:59:37.267Z
ve_0532e92a7d|en/auvergne-rhone-alpes/lyon/restaurant/danton|€€|CAT_P02|bib|fr|2026-10-30T04:59:38.627Z
ve_05469dccb6|en/ile-de-france/paris/restaurant/le-cinq6102|€€€€|CAT_P04|3 star|fr|2026-10-30T04:59:40.008Z
ve_054f1f59a0|en/ile-de-france/paris/restaurant/nhome|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:41.377Z
ve_0561162743|en/grand-est/ventron_1536962/restaurant/le-m-domaine-de-montagne|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:42.719Z
ve_05993971d3|en/ile-de-france/paris/restaurant/sushi-shunei|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:44.105Z
ve_05c971ee12|en/occitanie/palavas-les-flots/restaurant/le-st-georges431652|€€|CAT_P02|bib|fr|2026-10-30T04:59:45.446Z
ve_06037d720a|en/nouvelle-aquitaine/saintes/restaurant/saveurs-de-l-abbaye|€€|CAT_P02|bib|fr|2026-10-30T04:59:46.791Z
ve_060d04553e|en/occitanie/montagnac/restaurant/cote-mas|€€|CAT_P02|bib|fr|2026-10-30T04:59:48.132Z
ve_065a51baff|en/provence-alpes-cote-dazur/toulon/restaurant/le-pastel|€€|CAT_P02|bib|fr|2026-10-30T04:59:49.504Z
ve_0660358e08|en/auvergne-rhone-alpes/lyon/restaurant/prairial|€€€€|CAT_P04|1 star|fr|2026-10-30T04:59:50.856Z
ve_06c9c959ba|en/hauts-de-france/bermicourt/restaurant/la-cour-de-remi|€€|CAT_P02|bib|fr|2026-10-30T04:59:52.208Z
ve_06e851f210|en/auvergne-rhone-alpes/courchevel/restaurant/le-1947|€€€€|CAT_P04|3 star|fr|2026-10-30T04:59:53.641Z
ve_075746aec3|en/pays-de-la-loire/nantes/restaurant/p-tite-pomme|€€|CAT_P02|bib|fr|2026-10-30T04:59:54.984Z
ve_07a32e0a20|en/bourgogne-franche-comte/fuiss/restaurant/l-o-des-vignes|€€€|CAT_P03|1 star|fr|2026-10-30T04:59:56.382Z
ve_07ae922533|en/hauts-de-france/audresselles_1544592/restaurant/la-plage-1192535|€€|CAT_P02|bib|fr|2026-10-30T04:59:57.727Z
ve_07fc048900|en/pays-de-la-loire/l-herbaudire/restaurant/la-marine3780|€€€€|CAT_P04|3 star|fr|2026-10-30T04:59:59.126Z
ve_08067098bb|en/pays-de-la-loire/chahaignes_1570756/restaurant/silex-1214187|€€|CAT_P02|bib|fr|2026-10-30T05:00:00.513Z
ve_082c5146d3|en/centre-val-de-loire/romorantin-lanthenay/restaurant/grand-hotel-du-lion-d-or|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:01.860Z
ve_08e25557c5|en/centre-val-de-loire/richelieu_1584246/restaurant/fosse-saint-ange|€€|CAT_P02|bib|fr|2026-10-30T05:00:03.207Z
ve_0a7743c24c|en/ile-de-france/paris/restaurant/chakaiseiki-akiyoshi|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:04.576Z
ve_0a9006903d|en/occitanie/nimes/restaurant/le-bistr-au-le-mas-de-boudan|€€|CAT_P02|bib|fr|2026-10-30T05:00:05.941Z
ve_0b0fddb5b0|en/normandie/bagnoles-de-l-orne/restaurant/le-manoir-du-lys|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:07.275Z
ve_0b3b6ae541|en/nouvelle-aquitaine/langon/restaurant/l-atelier-flavien-valere|€€|CAT_P02|bib|fr|2026-10-30T05:00:08.623Z
ve_0b7ea4814f|en/bretagne/kervignac/restaurant/l-inattendu-domaine-de-locguenole|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:09.963Z
ve_0b86351c11|en/ile-de-france/rueil-malmaison/restaurant/ochre|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:11.333Z
ve_0bc3586925|en/ile-de-france/paris/restaurant/le-taillevent|€€€€|CAT_P04|2 star|fr|2026-10-30T05:00:12.683Z
ve_0bc4cb89dd|en/nouvelle-aquitaine/sauternes/restaurant/le-cercle-guiraud|€€€|CAT_P03|1 star|fr|2026-10-30T05:00:14.064Z
ve_0c9a3c0244|en/bourgogne-franche-comte/arbois/restaurant/le-bistronome|€€|CAT_P02|bib|fr|2026-10-30T05:00:15.420Z
ve_0cb1664757|en/nouvelle-aquitaine/seignosse/restaurant/villa-de-l-etang-blanc|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:16.770Z
ve_0cb2f01d1d|en/ile-de-france/paris/restaurant/lissit|€€|CAT_P02|bib|fr|2026-10-30T05:00:18.134Z
ve_0cc3262ff1|en/pays-de-la-loire/saumur/restaurant/l-essentiel-1192562|€€|CAT_P02|bib|fr|2026-10-30T05:00:19.488Z
ve_0d2f57151c|en/auvergne-rhone-alpes/lyon/restaurant/agastache|€€|CAT_P02|bib|fr|2026-10-30T05:00:20.879Z
ve_0d64bdf01f|en/ile-de-france/paris/restaurant/hakuba|€€€€|CAT_P04|2 star|fr|2026-10-30T05:00:22.258Z
ve_0d83c1a723|en/nouvelle-aquitaine/pyla-sur-mer/restaurant/le-skiff-club|€€€€|CAT_P04|2 star|fr|2026-10-30T05:00:23.631Z
ve_0dbdcc762c|en/provence-alpes-cote-dazur/les-baux-de-provence/restaurant/l-oustau-de-baumaniere|€€€€|CAT_P04|3 star|fr|2026-10-30T05:00:25.054Z
ve_0e67db9894|en/occitanie/montpellier/restaurant/jardin-des-sens|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:26.414Z
ve_0e7d03dfec|en/auvergne-rhone-alpes/abondance_1509103/restaurant/chalet-flachaire|€€€|CAT_P03|1 star|fr|2026-10-30T05:00:27.762Z
ve_0eb3af1481|en/bourgogne-franche-comte/joigny/restaurant/la-cote-saint-jacques|€€€€|CAT_P04|2 star|fr|2026-10-30T05:00:29.105Z
ve_0eba909fa4|en/grand-est/chlons-en-champagne/restaurant/jerome-feck|€€€|CAT_P03|1 star|fr|2026-10-30T05:00:30.462Z
ve_0f75cf565b|en/nouvelle-aquitaine/guiche/restaurant/le-gantxo|€€|CAT_P02|bib|fr|2026-10-30T05:00:31.814Z
ve_101f57b1dc|en/nouvelle-aquitaine/issigeac/restaurant/l-atelier|€€|CAT_P02|bib|fr|2026-10-30T05:00:33.158Z
ve_10ae9afbcc|en/provence-alpes-cote-dazur/nice/restaurant/la-merenda|€€|CAT_P02|bib|fr|2026-10-30T05:00:34.523Z
ve_10b8eaf5ef|en/bourgogne-franche-comte/charolles/restaurant/frederic-doucet|€€€€|CAT_P04|2 star|fr|2026-10-30T05:00:35.866Z
ve_10e5b8d3d7|en/hauts-de-france/lille/restaurant/purete|€€€|CAT_P03|1 star|fr|2026-10-30T05:00:37.287Z
ve_1195078d5d|en/ile-de-france/paris/restaurant/l-arome174292|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:38.644Z
ve_11a196c4e4|en/grand-est/fr-munster/restaurant/les-grands-arbres-verte-vallee|€€|CAT_P02|bib|fr|2026-10-30T05:00:40.007Z
ve_11cfd04600|en/auvergne-rhone-alpes/douvaine/restaurant/o-flaveurs|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:41.350Z
ve_120e307eb0|en/grand-est/fr-munster/restaurant/l-olivier-1196706|€€|CAT_P02|bib|fr|2026-10-30T05:00:42.695Z
ve_1225b75439|en/auvergne-rhone-alpes/nernier/restaurant/la-table-de-nernier|€€€|CAT_P03|bib|fr|2026-10-30T05:00:44.042Z
ve_1236038cae|en/bretagne/vitr/restaurant/entre-nous|€€|CAT_P02|bib|fr|2026-10-30T05:00:45.377Z
ve_12b71956d0|en/ile-de-france/meudon/restaurant/l-escarbille|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:46.749Z
ve_12e5bf15ad|en/auvergne-rhone-alpes/clermont-ferrand/restaurant/le-pre-xavier-beaudiment|€€€€|CAT_P04|2 star|fr|2026-10-30T05:00:48.098Z
ve_1322b9e099|en/ile-de-france/paris/restaurant/amalia|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:49.475Z
ve_1330ac75fe|en/provence-alpes-cote-dazur/rognes_1508191/restaurant/le-preau|€€|CAT_P02|bib|fr|2026-10-30T05:00:50.811Z
ve_133bfcf2fa|en/bretagne/plouider/restaurant/le-comptoir-de-la-butte|€€|CAT_P02|bib|fr|2026-10-30T05:00:52.172Z
ve_1342048f48|en/auvergne-rhone-alpes/megve/restaurant/flocons-de-sel|€€€€|CAT_P04|3 star|fr|2026-10-30T05:00:53.536Z
ve_13f86693b1|en/auvergne-rhone-alpes/saint-alban-de-roche/restaurant/l-emulsion327218|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:54.889Z
ve_1462089111|en/nouvelle-aquitaine/bidarray/restaurant/lore-ttipia-auberge-ostape|€€€€|CAT_P04|1 star|fr|2026-10-30T05:00:56.226Z
ve_152fb62579|en/auvergne-rhone-alpes/chamonix-mont-blanc/restaurant/akashon|€€|CAT_P02|bib|fr|2026-10-30T05:00:57.576Z
ve_156553c418|en/auvergne-rhone-alpes/belleville-auvergne-rhone-alpes/restaurant/le-beaujolais|€€|CAT_P02|bib|fr|2026-10-30T05:00:58.921Z
ve_1577ca7b7e|en/bretagne/rochefort-en-terre_1569018/restaurant/maison-cachee|€€|CAT_P02|bib|fr|2026-10-30T05:01:00.263Z
ve_15a5e124dc|en/occitanie/saint-cr/restaurant/philia|€€|CAT_P02|bib|fr|2026-10-30T05:01:01.609Z
ve_15cc98e474|en/occitanie/aureville/restaurant/en-marge|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:02.949Z
ve_15f476d193|en/bourgogne-franche-comte/dijon/restaurant/l-asperule|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:04.313Z
ve_163d7a4772|en/ile-de-france/paris/restaurant/frenchie262795|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:05.672Z
ve_16bdd233b0|en/grand-est/la-wantzenau/restaurant/relais-de-la-poste|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:07.033Z
ve_16d72421f6|en/ile-de-france/couilly-pont-aux-dames/restaurant/auberge-de-la-brie|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:08.375Z
ve_16f86baace|en/pays-de-la-loire/basse-goulaine/restaurant/restaurant-du-pont|€€|CAT_P02|bib|fr|2026-10-30T05:01:09.734Z
ve_1741280cda|en/centre-val-de-loire/oucques/restaurant/o-en-couleur|€€|CAT_P02|bib|fr|2026-10-30T05:01:11.088Z
ve_17a24b80ee|en/provence-alpes-cote-dazur/nice/restaurant/bistrot-d-antoine|€€|CAT_P02|bib|fr|2026-10-30T05:01:12.451Z
ve_17a53abb59|en/grand-est/marlenheim/restaurant/le-cerf|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:13.797Z
ve_1844ecb32d|en/bretagne/rennes/restaurant/breizh-cafe-rennes|€€|CAT_P02|bib|fr|2026-10-30T05:01:15.172Z
ve_1871280da8|en/provence-alpes-cote-dazur/toulon/restaurant/shanael|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:16.524Z
ve_18aa1ae78d|en/bretagne/dinard/restaurant/pourquoi-pas|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:17.972Z
ve_18fe0e78a3|en/bretagne/vannes/restaurant/la-table-domaine-du-liziec|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:19.326Z
ve_1940cafa4a|en/ile-de-france/paris/restaurant/geoelia|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:20.674Z
ve_1986da12de|en/bourgogne-franche-comte/dijon/restaurant/so|€|CAT_P01|bib|fr|2026-10-30T05:01:22.028Z
ve_1990fd1147|en/grand-est/gundershoffen/restaurant/le-cygne|€€|CAT_P02|bib|fr|2026-10-30T05:01:23.366Z
ve_19b4e9d3c3|en/occitanie/montrab/restaurant/l-aparte|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:24.714Z
ve_1a6bd9c48e|en/ile-de-france/nanterre/restaurant/cabane|€€|CAT_P02|bib|fr|2026-10-30T05:01:26.080Z
ve_1aa07a9581|en/auvergne-rhone-alpes/clermont-ferrand/restaurant/le-chardonnay|€€|CAT_P02|bib|fr|2026-10-30T05:01:27.419Z
ve_1ab5144619|en/centre-val-de-loire/mont-pres-chambord_1583528/restaurant/domus|€€|CAT_P02|bib|fr|2026-10-30T05:01:28.760Z
ve_1ad9b37a16|en/pays-de-la-loire/montaigu/restaurant/la-robe|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:30.096Z
ve_1adc9042b3|en/auvergne-rhone-alpes/naves-parmelan_1514499/restaurant/le-cafe-de-la-poste|€€|CAT_P02|bib|fr|2026-10-30T05:01:31.462Z
ve_1b049d3964|en/ile-de-france/paris/restaurant/ose-1203614|€€|CAT_P02|bib|fr|2026-10-30T05:01:32.833Z
ve_1b690abc69|en/bourgogne-franche-comte/dijon/restaurant/william-frachot|€€€€|CAT_P04|2 star|fr|2026-10-30T05:01:34.184Z
ve_1b8b3584fa|en/auvergne-rhone-alpes/lyon/restaurant/la-viree|€€|CAT_P02|bib|fr|2026-10-30T05:01:35.551Z
ve_1c1a0667ed|en/auvergne-rhone-alpes/chonas-l-amballan/restaurant/la-table-de-philippe-girardon|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:36.920Z
ve_1c7815dd09|en/auvergne-rhone-alpes/saint-theoffrey_1515526/restaurant/maltacina|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:38.261Z
ve_1c922a2987|en/ile-de-france/paris/restaurant/pantagruel|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:39.635Z
ve_1cc58df978|en/pays-de-la-loire/saint-nazaire/restaurant/topaze|€€|CAT_P02|bib|fr|2026-10-30T05:01:40.975Z
ve_1cd1d3e54d|en/provence-alpes-cote-dazur/le-puy-sainte-rparade/restaurant/la-table-de-l-orangerie-chateau-de-fonscolombe|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:42.335Z
ve_1ced33e109|en/bretagne/saint-malo/restaurant/fidelis|€€|CAT_P02|bib|fr|2026-10-30T05:01:43.704Z
ve_1d45b90d41|en/ile-de-france/paris/restaurant/alan-geaam|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:45.057Z
ve_1d70e6c83b|en/ile-de-france/paris/restaurant/epopee|€€€|CAT_P03|bib|fr|2026-10-30T05:01:46.424Z
ve_1db894a468|en/occitanie/saint-hilaire-de-brethmas_3915683/restaurant/le-saint-hilaire-1208787|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:47.770Z
ve_1dc0e69375|en/bretagne/saint-brieuc/restaurant/aux-pesked|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:49.127Z
ve_1dc3abb3aa|en/occitanie/ste/restaurant/quai-17|€€|CAT_P02|bib|fr|2026-10-30T05:01:50.468Z
ve_1dd2e9c45c|en/hauts-de-france/courcelles-sur-vesle/restaurant/la-table-de-courcelles-chateau-de-courcelles|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:51.804Z
ve_1e0a5a501f|en/auvergne-rhone-alpes/courchevel/restaurant/le-farcon|€€€€|CAT_P04|1 star|fr|2026-10-30T05:01:53.159Z
ve_1e4cfc0414|en/auvergne-rhone-alpes/veyras/restaurant/la-boria-1200901|€€€|CAT_P03|1 star|fr|2026-10-30T05:01:54.513Z
ve_1e74d7438b|en/auvergne-rhone-alpes/valence/restaurant/pic|€€€€|CAT_P04|3 star|fr|2026-10-30T05:01:55.869Z
ve_1efc681da3|en/ile-de-france/paris/restaurant/arpege|€€€€|CAT_P04|3 star|fr|2026-10-30T05:01:57.238Z
ve_1efea8d4f3|en/occitanie/clara/restaurant/les-loges-du-jardin-d-aymeric|€€|CAT_P02|bib|fr|2026-10-30T05:01:58.568Z
ve_1f121d0835|en/bourgogne-franche-comte/gevrey-chambertin/restaurant/bistrot-lucien|€€|CAT_P02|bib|fr|2026-10-30T05:01:59.913Z
ve_1f9d04e96f|en/occitanie/quint-fonsegrives/restaurant/en-pleine-nature|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:01.256Z
ve_2029f8e065|en/auvergne-rhone-alpes/baix_1516672/restaurant/epona-1205894|€€|CAT_P02|bib|fr|2026-10-30T05:02:02.596Z
ve_20ef8a2874|en/occitanie/alvignac_1490419/restaurant/le-voyage-d-ernestine|€€|CAT_P02|bib|fr|2026-10-30T05:02:03.935Z
ve_21529fc55c|en/ile-de-france/paris/restaurant/neige-d-ete|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:05.302Z
ve_217afd549e|en/normandie/giverny/restaurant/le-jardin-des-plumes|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:06.695Z
ve_21cd5c1365|en/auvergne-rhone-alpes/lyon/restaurant/circle|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:08.045Z
ve_21e122348b|en/grand-est/langres/restaurant/mirabelle-1216505|€€|CAT_P02|bib|fr|2026-10-30T05:02:10.249Z
ve_21f1556ce9|en/occitanie/garons/restaurant/michel-kayser-restaurant-alexandre|€€€€|CAT_P04|2 star|fr|2026-10-30T05:02:12.274Z
ve_2237e20f18|en/ile-de-france/paris/restaurant/mam-from-hanoi|€€|CAT_P02|bib|fr|2026-10-30T05:02:14.275Z
ve_223dd369c0|en/grand-est/sarreguemines/restaurant/auberge-st-walfrid|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:16.297Z
ve_22548593ff|en/occitanie/puylausic_1498483/restaurant/la-maison-despoues|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:18.251Z
ve_2304caab1b|en/normandie/le-havre/restaurant/le-bouche-a-oreille531147|€€|CAT_P02|bib|fr|2026-10-30T05:02:20.258Z
ve_23317e8d00|en/provence-alpes-cote-dazur/calas-cabries_1505051/restaurant/la-bastide-bourrelly-mathias-dandine|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:22.265Z
ve_2332f48c17|en/auvergne-rhone-alpes/collonges-au-mont-d-or/restaurant/paul-bocuse|€€€€|CAT_P04|2 star|fr|2026-10-30T05:02:24.284Z
ve_238989dcec|en/provence-alpes-cote-dazur/ventabren/restaurant/dan-b|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:26.257Z
ve_2410f5b67e|en/nouvelle-aquitaine/bordeaux/restaurant/mets-mots|€€|CAT_P02|bib|fr|2026-10-30T05:02:28.284Z
ve_244a886a56|en/pays-de-la-loire/la-plaine-sur-mer/restaurant/anne-de-bretagne|€€€€|CAT_P04|2 star|fr|2026-10-30T05:02:30.262Z
ve_2473cc7347|en/centre-val-de-loire/cellettes/restaurant/granica|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:32.276Z
ve_24b9c243a7|en/provence-alpes-cote-dazur/aix-en-provence/restaurant/etude-1207141|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:34.256Z
ve_251039d1c1|en/centre-val-de-loire/loches/restaurant/arbore-sens|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:35.603Z
ve_2548d72a9b|en/provence-alpes-cote-dazur/moustiers-sainte-marie/restaurant/la-bastide-de-moustiers|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:36.958Z
ve_25a811e430|en/nouvelle-aquitaine/royan/restaurant/rafales|€€|CAT_P02|bib|fr|2026-10-30T05:02:38.317Z
ve_25fc60c8fe|en/nouvelle-aquitaine/saintes/restaurant/l-iode|€€|CAT_P02|bib|fr|2026-10-30T05:02:39.667Z
ve_266151655e|en/provence-alpes-cote-dazur/les-arcs/restaurant/le-relais-des-moines|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:41.016Z
ve_269814ba61|en/ile-de-france/paris/restaurant/le-grand-restaurant-jean-francois-piege|€€€€|CAT_P04|2 star|fr|2026-10-30T05:02:42.441Z
ve_269f11d680|en/auvergne-rhone-alpes/valence/restaurant/le-bac-a-traille|€€|CAT_P02|bib|fr|2026-10-30T05:02:43.824Z
ve_26fde8afb1|en/grand-est/drusenheim/restaurant/au-gourmet|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:45.188Z
ve_273d8e1a92|en/grand-est/ensisheim/restaurant/l-orchidee|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:46.539Z
ve_27785657a0|en/auvergne-rhone-alpes/chonas-l-amballan/restaurant/le-cottage|€€|CAT_P02|bib|fr|2026-10-30T05:02:47.883Z
ve_27bf87983c|en/grand-est/couviez/restaurant/les-epices-curiens|€€|CAT_P02|bib|fr|2026-10-30T05:02:49.226Z
ve_27cdde1136|en/ile-de-france/paris/restaurant/pur-jean-francois-rouquette|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:50.622Z
ve_27f8c9e215|en/bourgogne-franche-comte/montbellet/restaurant/la-marande|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:51.981Z
ve_281df52815|en/ile-de-france/paris/restaurant/onor|€€€€|CAT_P04|1 star|fr|2026-10-30T05:02:53.352Z
ve_2843fa2551|en/ile-de-france/paris/restaurant/virtus|€€€€|CAT_P04|2 star|fr|2026-10-30T05:02:54.725Z
ve_2867acf693|en/occitanie/laguepie_1494921/restaurant/l-angle|€€|CAT_P02|bib|fr|2026-10-30T05:02:56.057Z
ve_286c2dd02c|en/occitanie/toulouse/restaurant/stephane-tournie-les-jardins-de-l-opera|€€€|CAT_P03|1 star|fr|2026-10-30T05:02:57.402Z
ve_28c5aaecdc|en/nouvelle-aquitaine/tulle/restaurant/les-7|€€|CAT_P02|bib|fr|2026-10-30T05:02:58.747Z
ve_2951161c1d|en/bretagne/lannion/restaurant/le-brelevenez|€€|CAT_P02|bib|fr|2026-10-30T05:03:00.148Z
ve_29a64cfeb1|en/provence-alpes-cote-dazur/villedieu/restaurant/le-bistrot-de-villedieu|€€|CAT_P02|bib|fr|2026-10-30T05:03:01.501Z
ve_29ccf29fbf|en/ile-de-france/paris/restaurant/comice|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:02.867Z
ve_2a18117e96|en/provence-alpes-cote-dazur/carry-le-rouet_1505150/restaurant/l-oursin|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:04.222Z
ve_2a3f16fb34|en/nouvelle-aquitaine/espelette/restaurant/choko-ona|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:05.567Z
ve_2a8ec4ed1a|en/ile-de-france/paris/restaurant/episodes|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:06.931Z
ve_2ae4df5c7f|en/ile-de-france/paris/restaurant/il-carpaccio300866|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:08.287Z
ve_2b515ada6c|en/nouvelle-aquitaine/puymoyen/restaurant/aumi|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:09.636Z
ve_2b59b24d2b|en/occitanie/nimes/restaurant/jerome-nutile|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:10.988Z
ve_2b9eda483e|en/pays-de-la-loire/nantes/restaurant/l-atlantide-1874-maison-gueho|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:12.336Z
ve_2bd91023d9|en/ile-de-france/paris/restaurant/l-atelier-de-joel-robuchon-etoile|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:13.698Z
ve_2bf7f1463e|en/auvergne-rhone-alpes/les-vans/restaurant/likoke|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:15.049Z
ve_2cd3424697|en/ile-de-france/paris/restaurant/granite|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:16.425Z
ve_2cd490ae81|en/pays-de-la-loire/angers/restaurant/lait-thym-sel|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:17.773Z
ve_2d5b8da238|en/nouvelle-aquitaine/la-rochelle/restaurant/christopher-coutanceau|€€€€|CAT_P04|3 star|fr|2026-10-30T05:03:19.147Z
ve_2dca11e0ed|en/auvergne-rhone-alpes/marcols/restaurant/oxalis-1209557|€€|CAT_P02|bib|fr|2026-10-30T05:03:20.488Z
ve_2df65b448c|en/auvergne-rhone-alpes/charmes-sur-rhne/restaurant/le-carre-d-alethius|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:21.846Z
ve_2e35f20ae1|en/bourgogne-franche-comte/saulieu/restaurant/la-cote-d-or|€€€€|CAT_P04|2 star|fr|2026-10-30T05:03:23.200Z
ve_2e985904ad|en/ile-de-france/paris/restaurant/fleur-de-pave|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:24.576Z
ve_2f2b83b250|en/grand-est/malling/restaurant/alexis-baudin|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:25.948Z
ve_2fb8e6021d|en/occitanie/conques/restaurant/emilie-thomas-moulin-de-cambelong|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:27.294Z
ve_30501b82cb|en/bretagne/carantec/restaurant/nicolas-carro|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:28.642Z
ve_305db3beb3|en/grand-est/baerenthal/restaurant/l-arnsbourg|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:29.987Z
ve_307af7ab89|en/nouvelle-aquitaine/nieul_1470595/restaurant/chapelle-saint-martin|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:31.322Z
ve_30c62ebaf4|en/occitanie/cahors/restaurant/l-o-a-la-bouche|€€|CAT_P02|bib|fr|2026-10-30T05:03:32.660Z
ve_30f92fd38d|en/nouvelle-aquitaine/angoulme/restaurant/la-bistronomie-1215864|€€|CAT_P02|bib|fr|2026-10-30T05:03:34.001Z
ve_31497de99c|en/ile-de-france/paris/restaurant/le-baudelaire|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:35.366Z
ve_316c5d39b0|en/provence-alpes-cote-dazur/nice/restaurant/cafe-des-musiciens|€€|CAT_P02|bib|fr|2026-10-30T05:03:36.726Z
ve_317d5b5369|en/bretagne/rennes/restaurant/fezi|€€|CAT_P02|bib|fr|2026-10-30T05:03:38.143Z
ve_31c89ab872|en/bourgogne-franche-comte/beaune/restaurant/la-table-du-square|€€|CAT_P02|bib|fr|2026-10-30T05:03:39.504Z
ve_31fc6f58b0|en/bourgogne-franche-comte/chassy_1527287/restaurant/jk-restaurant|€€|CAT_P02|bib|fr|2026-10-30T05:03:40.852Z
ve_322b300fcf|en/auvergne-rhone-alpes/margencel/restaurant/sechex-nous|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:42.193Z
ve_327ad3b070|en/provence-alpes-cote-dazur/marseille/restaurant/am-par-alexandre-mazzia|€€€€|CAT_P04|3 star|fr|2026-10-30T05:03:43.546Z
ve_334ad1fa8d|en/ile-de-france/paris/restaurant/anne|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:44.910Z
ve_3372f001f0|en/ile-de-france/versailles/restaurant/la-table-du-11|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:46.272Z
ve_337c427931|en/auvergne-rhone-alpes/les-salles_1522366/restaurant/colette-1207666|€€|CAT_P02|bib|fr|2026-10-30T05:03:47.619Z
ve_33a1b4d4fc|en/ile-de-france/paris/restaurant/jin|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:48.976Z
ve_33cc5c69fb|en/ile-de-france/paris/restaurant/maison-rostang|€€€€|CAT_P04|2 star|fr|2026-10-30T05:03:50.331Z
ve_3450c5dac1|en/bretagne/saint-pol-de-lon/restaurant/la-pomme-d-api|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:51.671Z
ve_347d06ed18|en/auvergne-rhone-alpes/replonges/restaurant/la-huchette|€€€€|CAT_P04|1 star|fr|2026-10-30T05:03:53.023Z
ve_3549878575|en/grand-est/rimbach-prs-guebwiller/restaurant/l-ao-l-aigle-d-or|€€|CAT_P02|bib|fr|2026-10-30T05:03:54.419Z
ve_354adc31ce|en/bretagne/plomeur_1568548/restaurant/nuance-1215929|€€€|CAT_P03|1 star|fr|2026-10-30T05:03:55.763Z
ve_35ccab770a|en/pays-de-la-loire/angers/restaurant/l-ardoise-502593|€€|CAT_P02|bib|fr|2026-10-30T05:03:57.125Z
ve_35d4ecca12|en/auvergne-rhone-alpes/annecy/restaurant/le-clos-des-sens|€€€€|CAT_P04|3 star|fr|2026-10-30T05:03:58.490Z
ve_3668dbb234|en/provence-alpes-cote-dazur/tourtour/restaurant/la-table63544|€€|CAT_P02|bib|fr|2026-10-30T05:03:59.834Z
ve_36b401e4fd|en/bourgogne-franche-comte/dijon/restaurant/loiseau-des-ducs|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:01.183Z
ve_36cae250a1|en/bretagne/la-roche-bernard/restaurant/auberge-des-deux-magots|€€|CAT_P02|bib|fr|2026-10-30T05:04:02.576Z
ve_3735c86fab|en/ile-de-france/paris/restaurant/pavyllon-paris|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:03.933Z
ve_3755ee4117|en/grand-est/steige/restaurant/auberge-chez-guth|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:05.282Z
ve_3756bee2d9|en/hauts-de-france/illies/restaurant/l-epicurieux|€€|CAT_P02|bib|fr|2026-10-30T05:04:06.619Z
ve_376cd7a445|en/ile-de-france/paris/restaurant/espadon|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:07.998Z
ve_377c9c3b7b|en/ile-de-france/paris/restaurant/astrance|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:09.356Z
ve_379053fb48|en/nouvelle-aquitaine/bordeaux/restaurant/madame-b|€€|CAT_P02|bib|fr|2026-10-30T05:04:10.718Z
ve_3806706fc6|en/occitanie/cajarc/restaurant/jeu-de-quilles|€€|CAT_P02|bib|fr|2026-10-30T05:04:12.067Z
ve_3839d0581f|en/auvergne-rhone-alpes/mribel/restaurant/l-ekrin-by-laurent-azoulay|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:13.464Z
ve_384b63bd3a|en/occitanie/tarbes/restaurant/l-empreinte499783|€€|CAT_P02|bib|fr|2026-10-30T05:04:14.816Z
ve_38a2036e3d|en/provence-alpes-cote-dazur/cairanne/restaurant/coteaux-et-fourchettes|€€|CAT_P02|bib|fr|2026-10-30T05:04:16.172Z
ve_38c864a72f|en/ile-de-france/paris/restaurant/la-table-de-mee|€€|CAT_P02|bib|fr|2026-10-30T05:04:17.544Z
ve_3919ec1489|en/grand-est/hagondange/restaurant/quai-des-saveurs|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:18.885Z
ve_392ea1dc3d|en/bretagne/rennes/restaurant/yoko|€€|CAT_P02|bib|fr|2026-10-30T05:04:20.233Z
ve_399c020346|en/pays-de-la-loire/saint-michel-chef-chef_1576777/restaurant/beau-boucot|€€|CAT_P02|bib|fr|2026-10-30T05:04:21.587Z
ve_399fae0d97|en/provence-alpes-cote-dazur/nice/restaurant/onice|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:22.946Z
ve_39ac1adc6c|en/corse/porto-vecchio/restaurant/casadelmar|€€€€|CAT_P04|2 star|fr|2026-10-30T05:04:24.288Z
ve_3a24173df2|en/auvergne-rhone-alpes/evian-les-bains/restaurant/les-fresques400460|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:25.632Z
ve_3a28aa2952|en/ile-de-france/paris/restaurant/gaya-par-pierre-gagnaire|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:27.009Z
ve_3a3e26a2a9|en/auvergne-rhone-alpes/talloires-montmin/restaurant/jean-sulpice|€€€€|CAT_P04|2 star|fr|2026-10-30T05:04:28.389Z
ve_3a6d55a587|en/ile-de-france/paris/restaurant/sushi-yoshinaga|€€€€|CAT_P04|2 star|fr|2026-10-30T05:04:29.799Z
ve_3ac6f3b0a7|en/ile-de-france/paris/restaurant/aux-2-k|€€|CAT_P02|bib|fr|2026-10-30T05:04:31.202Z
ve_3ae95a89c5|en/bretagne/bruz_1563399/restaurant/recolte|€€|CAT_P02|bib|fr|2026-10-30T05:04:32.537Z
ve_3b1fb8d8f2|en/auvergne-rhone-alpes/beaufort_1509411/restaurant/les-9-neves|€€|CAT_P02|bib|fr|2026-10-30T05:04:33.900Z
ve_3b53a3e4a6|en/occitanie/saint-cr/restaurant/les-trois-soleils-de-montal|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:35.237Z
ve_3b5781df0d|en/nouvelle-aquitaine/brive-la-gaillarde/restaurant/inspyration|€€|CAT_P02|bib|fr|2026-10-30T05:04:36.583Z
ve_3c84380295|en/provence-alpes-cote-dazur/nice/restaurant/olive-et-artichaut|€€|CAT_P02|bib|fr|2026-10-30T05:04:37.929Z
ve_3c970f6c7f|en/normandie/bayeux/restaurant/la-rapiere|€€|CAT_P02|bib|fr|2026-10-30T05:04:39.286Z
ve_3cb99fd3d6|en/nouvelle-aquitaine/bordeaux/restaurant/solena|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:40.636Z
ve_3cd0be5fe7|en/ile-de-france/paris/restaurant/jip|€€|CAT_P02|bib|fr|2026-10-30T05:04:42.048Z
ve_3d10f5f246|en/normandie/blainville-sur-mer/restaurant/athome|€€|CAT_P02|bib|fr|2026-10-30T05:04:43.417Z
ve_3d116f3aaa|en/auvergne-rhone-alpes/evian-les-bains/restaurant/le-muratore|€€|CAT_P02|bib|fr|2026-10-30T05:04:44.780Z
ve_3d687f93c4|en/grand-est/malroy_1542423/restaurant/aux-3-capitaines|€€|CAT_P02|bib|fr|2026-10-30T05:04:46.120Z
ve_3d9ae68450|en/grand-est/strasbourg/restaurant/au-pont-du-corbeau|€€|CAT_P02|bib|fr|2026-10-30T05:04:47.475Z
ve_3f047cbdde|en/auvergne-rhone-alpes/grenoble/restaurant/maison-fantin-latour-stephane-froidevaux|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:48.815Z
ve_3f2b100f8c|en/occitanie/montpellier/restaurant/leclere|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:50.164Z
ve_40293b76ff|en/ile-de-france/fontainebleau/restaurant/l-axel|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:51.510Z
ve_40366c0dda|en/auvergne-rhone-alpes/malataverne/restaurant/le-bistrot-270|€€|CAT_P02|bib|fr|2026-10-30T05:04:52.864Z
ve_404495a2c6|en/bretagne/plerin/restaurant/la-vieille-tour7741|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:54.224Z
ve_406f63b922|en/bourgogne-franche-comte/tournus/restaurant/l-ecrin-de-yohann-chapuis|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:55.574Z
ve_4083f63795|en/nouvelle-aquitaine/bordeaux/restaurant/ressources|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:56.946Z
ve_410eec24c6|en/provence-alpes-cote-dazur/marseille/restaurant/belle-de-mars|€€€|CAT_P03|1 star|fr|2026-10-30T05:04:58.319Z
ve_412056e4a1|en/auvergne-rhone-alpes/le-bourget-du-lac/restaurant/lamartine|€€€€|CAT_P04|1 star|fr|2026-10-30T05:04:59.659Z
ve_4177d33633|en/occitanie/conques/restaurant/bistrot-le-heron|€€|CAT_P02|bib|fr|2026-10-30T05:05:00.988Z
ve_41ab1bd7bd|en/auvergne-rhone-alpes/curis-au-mont-d-or_1510529/restaurant/l-epicurieux-chez-luc|€|CAT_P01|bib|fr|2026-10-30T05:05:02.336Z
ve_41cd965a96|en/auvergne-rhone-alpes/lyon/restaurant/cinq-mains|€€|CAT_P02|bib|fr|2026-10-30T05:05:03.697Z
ve_41f3fa8b6a|en/grand-est/reims/restaurant/brasserie-le-jardin|€€|CAT_P02|bib|fr|2026-10-30T05:05:05.042Z
ve_422768e33f|en/bourgogne-franche-comte/pupillin/restaurant/la-table-du-grapiot|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:06.385Z
ve_422abe6fe0|en/nouvelle-aquitaine/cognac/restaurant/les-foudres|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:07.726Z
ve_429b4eb60e|en/auvergne-rhone-alpes/hauteluce/restaurant/mont-blanc-restaurant-gouter|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:09.066Z
ve_42a5fc32bc|en/provence-alpes-cote-dazur/avignon/restaurant/pollen1000267|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:10.422Z
ve_430c10b06e|en/ile-de-france/paris/restaurant/alliance|€€€€|CAT_P04|2 star|fr|2026-10-30T05:05:11.784Z
ve_434b55e085|en/bourgogne-franche-comte/pommard/restaurant/aupres-du-clocher|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:13.140Z
ve_446491ec99|en/ile-de-france/paris/restaurant/pertinence|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:14.511Z
ve_45583812a6|en/occitanie/lastours/restaurant/le-puits-du-tresor|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:15.868Z
ve_459e6df134|en/provence-alpes-cote-dazur/ze/restaurant/chateau-eza|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:17.224Z
ve_45bf2a4926|en/hauts-de-france/chantilly/restaurant/le-verbois|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:18.581Z
ve_46605064bb|en/ile-de-france/rolleboise/restaurant/le-panoramique-domaine-de-la-corniche|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:19.926Z
ve_47380954a0|en/occitanie/toulouse/restaurant/l-ecorce-1243609|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:21.276Z
ve_47aea93e3a|en/hauts-de-france/boeschepe/restaurant/auberge-du-vert-mont|€€|CAT_P02|1 star|fr|2026-10-30T05:05:22.622Z
ve_47bd33e55b|en/provence-alpes-cote-dazur/nice/restaurant/le-chantecler|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:23.975Z
ve_4813cef5a6|en/nouvelle-aquitaine/hasparren/restaurant/la-maison-de-pierre|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:25.366Z
ve_48365740d9|en/auvergne-rhone-alpes/courchevel/restaurant/sylvestre-wahid-les-grandes-alpes|€€€€|CAT_P04|2 star|fr|2026-10-30T05:05:26.741Z
ve_487864d071|en/ile-de-france/versailles/restaurant/ducasse-au-chateau-de-versailles-le-grand-controle|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:28.095Z
ve_488f806834|en/nouvelle-aquitaine/massignac/restaurant/dyades-au-domaine-des-etangs|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:29.443Z
ve_48912b20f9|en/ile-de-france/paris/restaurant/david-toutain|€€€€|CAT_P04|2 star|fr|2026-10-30T05:05:30.818Z
ve_48fb509454|en/auvergne-rhone-alpes/saint-bonnet-le-froid/restaurant/bistrot-la-coulemelle|€€|CAT_P02|bib|fr|2026-10-30T05:05:32.158Z
ve_493998ebb3|en/nouvelle-aquitaine/saint-jean-de-luz/restaurant/le-kaiku|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:33.526Z
ve_49d6e95d61|en/pays-de-la-loire/la-chaize-giraud/restaurant/maison-brume|€€|CAT_P02|bib|fr|2026-10-30T05:05:34.878Z
ve_4a0678f5c7|en/auvergne-rhone-alpes/grane/restaurant/len-k-la-maison-bonnet|€€|CAT_P02|bib|fr|2026-10-30T05:05:36.233Z
ve_4a5a35a053|en/nouvelle-aquitaine/bordeaux/restaurant/l-oiseau-bleu|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:38.897Z
ve_4a7ca97f2c|en/centre-val-de-loire/boulleret/restaurant/maison-medard|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:40.237Z
ve_4a899535b9|en/hauts-de-france/la-madelaine-sous-montreuil/restaurant/la-grenouillere|€€€€|CAT_P04|2 star|fr|2026-10-30T05:05:41.597Z
ve_4af142be78|en/ile-de-france/paris/restaurant/le-george|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:42.951Z
ve_4b445cedda|en/occitanie/als/restaurant/epices-et-tout|€€|CAT_P02|bib|fr|2026-10-30T05:05:44.296Z
ve_4b86bdb91b|en/nouvelle-aquitaine/saint-robert_1472156/restaurant/monsieur-robert|€€|CAT_P02|bib|fr|2026-10-30T05:05:45.629Z
ve_4bddce6b9f|en/provence-alpes-cote-dazur/nice/restaurant/les-agitateurs|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:46.988Z
ve_4c2452517e|en/auvergne-rhone-alpes/pont-de-vaux/restaurant/le-raisin|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:48.342Z
ve_4c62a5b273|en/grand-est/wingen-sur-moder/restaurant/villa-rene-lalique|€€€€|CAT_P04|2 star|fr|2026-10-30T05:05:49.697Z
ve_4c62f184c5|en/ile-de-france/paris/restaurant/savarin-1219118|€€|CAT_P02|bib|fr|2026-10-30T05:05:51.061Z
ve_4cb67af7ab|en/ile-de-france/paris/restaurant/irwin|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:52.417Z
ve_4cd7b2f800|en/ile-de-france/paris/restaurant/le-pantruche|€€|CAT_P02|bib|fr|2026-10-30T05:05:53.765Z
ve_4d144afb56|en/grand-est/lunville/restaurant/chateau-d-adomenil|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:55.105Z
ve_4d254317ea|en/bretagne/saint-malo/restaurant/le-st-placide|€€€€|CAT_P04|1 star|fr|2026-10-30T05:05:56.468Z
ve_4dc1e77833|en/auvergne-rhone-alpes/correnon-en-vercors/restaurant/asterales|€€€|CAT_P03|1 star|fr|2026-10-30T05:05:57.803Z
ve_4dd54878f0|en/auvergne-rhone-alpes/saint-julien-chapteuil/restaurant/maison-vidal-le-bistrot-de-justin|€€|CAT_P02|bib|fr|2026-10-30T05:05:59.133Z
ve_4e68e3ec43|en/auvergne-rhone-alpes/aubenas/restaurant/les-coloquintes|€€|CAT_P02|bib|fr|2026-10-30T05:06:00.474Z
ve_4e73948e8f|en/occitanie/pzenas/restaurant/le-pre-st-jean|€€|CAT_P02|bib|fr|2026-10-30T05:06:01.853Z
ve_4ef700d74a|en/bretagne/brest/restaurant/peck-co|€|CAT_P01|bib|fr|2026-10-30T05:06:03.217Z
ve_4f07a8ac1b|en/occitanie/aulon/restaurant/auberge-des-aryelets|€€|CAT_P02|bib|fr|2026-10-30T05:06:04.560Z
ve_500702a2cd|en/provence-alpes-cote-dazur/saint-tropez/restaurant/la-vague-d-or-cheval-blanc-st-tropez|€€€€|CAT_P04|3 star|fr|2026-10-30T05:06:05.948Z
ve_50192b88c3|en/nouvelle-aquitaine/availles-limouzine/restaurant/la-chatellenie|€€|CAT_P02|bib|fr|2026-10-30T05:06:07.280Z
ve_503267190f|en/normandie/dieppe/restaurant/bistrot-du-pollet|€€|CAT_P02|bib|fr|2026-10-30T05:06:08.614Z
ve_505605329e|en/nouvelle-aquitaine/meilhan-sur-garonne_1487757/restaurant/chez-pierrette|€€|CAT_P02|bib|fr|2026-10-30T05:06:09.956Z
ve_50f7dc8e41|en/auvergne-rhone-alpes/bg-le-chtel/restaurant/la-table-bagesienne|€€|CAT_P02|bib|fr|2026-10-30T05:06:11.292Z
ve_511eebf1d8|en/occitanie/le-rozier/restaurant/l-alicanta|€€|CAT_P02|bib|fr|2026-10-30T05:06:12.632Z
ve_5185174abe|en/normandie/honfleur/restaurant/saquana|€€|CAT_P02|bib|fr|2026-10-30T05:06:13.994Z
ve_52aa097620|en/bourgogne-franche-comte/dole/restaurant/bagatelle|€€|CAT_P02|bib|fr|2026-10-30T05:06:15.335Z
ve_52bf46c5b5|en/occitanie/aumont-aubrac/restaurant/le-gabale|€€|CAT_P02|bib|fr|2026-10-30T05:06:16.687Z
ve_52ded554a8|en/bretagne/vannes/restaurant/ryoko|€|CAT_P01|bib|fr|2026-10-30T05:06:18.030Z
ve_52f32e41bc|en/pays-de-la-loire/angers/restaurant/gribiche|€€|CAT_P02|bib|fr|2026-10-30T05:06:19.405Z
ve_53549ca557|en/provence-alpes-cote-dazur/cannes/restaurant/aux-bons-enfants|€€|CAT_P02|bib|fr|2026-10-30T05:06:20.773Z
ve_53f4614426|en/occitanie/toulouse/restaurant/une-table-a-deux|€€|CAT_P02|bib|fr|2026-10-30T05:06:22.133Z
ve_541100d8fa|en/bretagne/trbeurden/restaurant/manoir-de-lan-kerellec|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:23.483Z
ve_5428ff40cc|en/occitanie/l-isle-jourdain/restaurant/l-echappee-belle|€€|CAT_P02|bib|fr|2026-10-30T05:06:24.863Z
ve_54654daa96|en/occitanie/toulouse/restaurant/agapes|€€|CAT_P02|1 star|fr|2026-10-30T05:06:26.225Z
ve_5472eed49c|en/ile-de-france/paris/restaurant/aida|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:27.603Z
ve_547b373170|en/auvergne-rhone-alpes/villefranche-sur-sane/restaurant/l-abbaye-caladoise|€€|CAT_P02|bib|fr|2026-10-30T05:06:28.966Z
ve_54db80a526|en/pays-de-la-loire/saumur/restaurant/la-table-by-mi-k-l|€€|CAT_P02|bib|fr|2026-10-30T05:06:30.310Z
ve_552f3c0465|en/bretagne/quimper/restaurant/eclosion-1209008|€€|CAT_P02|bib|fr|2026-10-30T05:06:31.654Z
ve_554b0cdf0b|en/pays-de-la-loire/cholet/restaurant/l-ourdissoir|€€|CAT_P02|bib|fr|2026-10-30T05:06:33.004Z
ve_5583f4dd31|en/ile-de-france/paris/restaurant/la-grande-cascade|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:34.354Z
ve_55d4d282cc|en/auvergne-rhone-alpes/chamalires/restaurant/radio10778|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:35.700Z
ve_56062c13aa|en/nouvelle-aquitaine/l-houmeau_1477385/restaurant/briemm|€€|CAT_P02|bib|fr|2026-10-30T05:06:37.075Z
ve_563d99bfa6|en/bourgogne-franche-comte/pernand-vergelesses/restaurant/le-charlemagne|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:38.415Z
ve_566407caa5|en/auvergne-rhone-alpes/ouches/restaurant/chateau-d-origny|€€€|CAT_P03|1 star|fr|2026-10-30T05:06:39.754Z
ve_566ff18e1b|en/auvergne-rhone-alpes/annecy/restaurant/maison-benoit-vidal|€€€€|CAT_P04|2 star|fr|2026-10-30T05:06:41.104Z
ve_567ee76555|en/provence-alpes-cote-dazur/l-isle-sur-la-sorgue/restaurant/solelh|€€|CAT_P02|bib|fr|2026-10-30T05:06:42.452Z
ve_5683d1f7b5|en/occitanie/pzenas/restaurant/restaurant-de-lauzun|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:43.811Z
ve_56d0c83801|en/auvergne-rhone-alpes/le-bourget-du-lac/restaurant/atmospheres|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:45.182Z
ve_57f23e5782|en/grand-est/languimberg/restaurant/chez-michele|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:46.514Z
ve_581cbf3eab|en/normandie/vreux/restaurant/la-gazette|€€|CAT_P02|bib|fr|2026-10-30T05:06:47.862Z
ve_5968472196|en/auvergne-rhone-alpes/chamalires/restaurant/le-welcome|€€|CAT_P02|bib|fr|2026-10-30T05:06:49.234Z
ve_597683621c|en/provence-alpes-cote-dazur/la-ciotat/restaurant/couleurs-de-shimatani|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:50.577Z
ve_59baf7ce7f|en/ile-de-france/paris/restaurant/epicure|€€€€|CAT_P04|3 star|fr|2026-10-30T05:06:51.945Z
ve_59c42e889d|en/bretagne/mr-de-bretagne/restaurant/auberge-grand-maison|€€€|CAT_P03|1 star|fr|2026-10-30T05:06:53.283Z
ve_5a2faf7397|en/provence-alpes-cote-dazur/menton/restaurant/mirazur|€€€€|CAT_P04|3 star|fr|2026-10-30T05:06:54.699Z
ve_5a58cf9714|en/ile-de-france/paris/restaurant/vaisseau|€€€€|CAT_P04|1 star|fr|2026-10-30T05:06:56.061Z
ve_5a67e55a7a|en/grand-est/reims/restaurant/assiette-champenoise|€€€€|CAT_P04|3 star|fr|2026-10-30T05:06:57.418Z
ve_5ab33e0684|en/bretagne/pont-croix_1568702/restaurant/glaz|€€|CAT_P02|bib|fr|2026-10-30T05:06:58.760Z
ve_5afd04ec26|en/provence-alpes-cote-dazur/les-baux-de-provence/restaurant/l-aupiho|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:00.131Z
ve_5b1ab313d4|en/ile-de-france/paris/restaurant/a-l-improviste|€€|CAT_P02|bib|fr|2026-10-30T05:07:01.505Z
ve_5b5ae98066|en/ile-de-france/paris/restaurant/le-meurice-alain-ducasse|€€€€|CAT_P04|2 star|fr|2026-10-30T05:07:02.896Z
ve_5c2f7e9c49|en/hauts-de-france/saint-andre-lez-lille_1550077/restaurant/le-mana|€€|CAT_P02|bib|fr|2026-10-30T05:07:04.270Z
ve_5c38471ed5|en/bretagne/plougasnou/restaurant/la-maison-de-kerdies|€€|CAT_P02|bib|fr|2026-10-30T05:07:05.617Z
ve_5c7eaea144|en/hauts-de-france/lille/restaurant/ginko|€€€|CAT_P03|1 star|fr|2026-10-30T05:07:06.986Z
ve_5cb59144d7|en/pays-de-la-loire/noirmoutier-en-lile/restaurant/l-assiette-au-jardin|€€|CAT_P02|bib|fr|2026-10-30T05:07:08.323Z
ve_5cc5d7608c|en/grand-est/colroy-la-roche/restaurant/la-cheneaudiere-le-feuillage|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:09.698Z
ve_5cedaaeee1|en/provence-alpes-cote-dazur/nice/restaurant/jan|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:11.059Z
ve_5d0a495512|en/bretagne/rennes/restaurant/la-petite-ourse|€|CAT_P01|bib|fr|2026-10-30T05:07:12.418Z
ve_5dbd29350e|en/grand-est/reims/restaurant/le-millenaire|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:13.775Z
ve_5e2901f87c|en/hauts-de-france/croix/restaurant/arborescence|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:15.121Z
ve_5f1fff252d|en/grand-est/obernai/restaurant/la-fourchette-des-ducs|€€€€|CAT_P04|2 star|fr|2026-10-30T05:07:16.470Z
ve_5f6e9c926b|en/auvergne-rhone-alpes/alixan_1509150/restaurant/mandibule|€€€|CAT_P03|1 star|fr|2026-10-30T05:07:17.824Z
ve_603d4413f2|en/occitanie/collioure/restaurant/la-balette|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:19.249Z
ve_60a745d0fd|en/ile-de-france/paris/restaurant/mavrommatis|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:20.737Z
ve_6188ecefea|en/normandie/saint-pair-sur-mer/restaurant/seme|€€|CAT_P02|bib|fr|2026-10-30T05:07:22.083Z
ve_61a7a04212|en/auvergne-rhone-alpes/lyon/restaurant/le-tiroir|€€|CAT_P02|bib|fr|2026-10-30T05:07:23.431Z
ve_61e542d969|en/bretagne/lorient/restaurant/le-tire-bouchon|€€|CAT_P02|bib|fr|2026-10-30T05:07:24.780Z
ve_61eaa343bd|en/nouvelle-aquitaine/bordeaux/restaurant/tentazioni|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:26.134Z
ve_6222e38fdf|en/grand-est/richardmnil/restaurant/au-bon-accueil-34208|€€|CAT_P02|bib|fr|2026-10-30T05:07:27.466Z
ve_62593f532b|en/occitanie/laguiole/restaurant/le-suquet-sebastien-bras|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:28.862Z
ve_629548d961|en/provence-alpes-cote-dazur/manosque/restaurant/chez-bastien|€€|CAT_P02|bib|fr|2026-10-30T05:07:30.225Z
ve_62d149aafe|en/hauts-de-france/lille/restaurant/le-restaurant-du-cerisier|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:31.586Z
ve_632293d6ee|en/corse/lumio/restaurant/a-casa-di-ma|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:32.924Z
ve_634228e9d5|en/grand-est/colmar/restaurant/restaurant-girardin|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:34.270Z
ve_63957fe46d|en/grand-est/rhinau/restaurant/au-vieux-couvent|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:35.613Z
ve_639bbbc461|en/occitanie/montpellier/restaurant/pastis-restaurant|€€€|CAT_P03|1 star|fr|2026-10-30T05:07:36.968Z
ve_63beffdf34|en/auvergne-rhone-alpes/pailherols/restaurant/l-auberge-des-montagnes|€€|CAT_P02|bib|fr|2026-10-30T05:07:38.313Z
ve_63f70bc85f|en/provence-alpes-cote-dazur/nice/restaurant/l-aromate233368|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:39.670Z
ve_6461b9da4d|en/ile-de-france/paris/restaurant/kodawari-ramen|€|CAT_P01|bib|fr|2026-10-30T05:07:41.031Z
ve_64682cb1f2|en/occitanie/colomiers/restaurant/maison-pellestor-veyrier|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:42.363Z
ve_6522e4fb4b|en/ile-de-france/paris/restaurant/tour-d-argent|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:43.727Z
ve_65591e378b|en/provence-alpes-cote-dazur/saint-tropez/restaurant/arnaud-donckele-maxime-frederic-at-louis-vuitton|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:45.081Z
ve_65cc559db5|en/ile-de-france/paris/restaurant/baieta|€€€|CAT_P03|1 star|fr|2026-10-30T05:07:46.455Z
ve_6678fed584|en/ile-de-france/paris/restaurant/le-sergent-recruteur|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:47.806Z
ve_668fbdb55d|en/nouvelle-aquitaine/conne-de-labarde_1483730/restaurant/maison-wessman-par-thierry-marx|€€|CAT_P02|bib|fr|2026-10-30T05:07:49.141Z
ve_66b3513ead|en/auvergne-rhone-alpes/aubenas/restaurant/l-aubepine|€€|CAT_P02|bib|fr|2026-10-30T05:07:50.488Z
ve_66c5011f54|en/hauts-de-france/favires/restaurant/la-cle-des-champs|€€|CAT_P02|bib|fr|2026-10-30T05:07:51.835Z
ve_67cecd1e33|en/bourgogne-franche-comte/beaune/restaurant/le-clos-du-cedre|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:53.190Z
ve_6825d41183|en/bretagne/saint-grgoire/restaurant/maison-ronan-kervarrec|€€€€|CAT_P04|2 star|fr|2026-10-30T05:07:54.545Z
ve_68a6950342|en/ile-de-france/paris/restaurant/l-ambroisie|€€€€|CAT_P04|2 star|fr|2026-10-30T05:07:55.900Z
ve_68ebaf7fa5|en/centre-val-de-loire/fougeres-sur-bievre/restaurant/avarum|€€|CAT_P02|bib|fr|2026-10-30T05:07:57.237Z
ve_68ffebdace|en/ile-de-france/paris/restaurant/monsieur-dior-by-yannick-alleno|€€€€|CAT_P04|1 star|fr|2026-10-30T05:07:58.591Z
ve_69057f331c|en/nouvelle-aquitaine/saintes/restaurant/le-parvis|€€|CAT_P02|bib|fr|2026-10-30T05:07:59.931Z
ve_6924132da6|en/grand-est/rixheim/restaurant/le-7eme-continent|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:01.316Z
ve_696d8588d7|en/occitanie/prats-de-mollo-la-preste/restaurant/bellavista|€€|CAT_P02|bib|fr|2026-10-30T05:08:02.652Z
ve_69934b07bd|en/provence-alpes-cote-dazur/tourrettes/restaurant/faventia|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:04.000Z
ve_6a41ada405|en/bourgogne-franche-comte/dole/restaurant/iida-ya|€€|CAT_P02|bib|fr|2026-10-30T05:08:05.344Z
ve_6a4bcbfb3b|en/bretagne/plougonvelin/restaurant/hostellerie-de-la-pointe-st-mathieu|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:06.687Z
ve_6a8fd785e4|en/provence-alpes-cote-dazur/gigondas/restaurant/l-oustalet|€€€|CAT_P03|1 star|fr|2026-10-30T05:08:08.039Z
ve_6a9bd70b49|en/bretagne/vannes/restaurant/boma|€€|CAT_P02|bib|fr|2026-10-30T05:08:09.403Z
ve_6ad9c595f7|en/grand-est/monswiller/restaurant/kasbur|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:10.747Z
ve_6b022b029a|en/provence-alpes-cote-dazur/beaulieu-sur-mer/restaurant/restaurant-des-rois|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:12.107Z
ve_6b9e04de75|en/ile-de-france/paris/restaurant/geosmine|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:13.477Z
ve_6ba1197b41|en/occitanie/bziers/restaurant/l-alter-native|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:14.825Z
ve_6ba4dc026f|en/nouvelle-aquitaine/la-flotte/restaurant/l-ecailler|€€€|CAT_P03|1 star|fr|2026-10-30T05:08:16.173Z
ve_6bd3775186|en/ile-de-france/paris/restaurant/substance|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:17.533Z
ve_6bdb5c2bd3|en/ile-de-france/paris/restaurant/le-tout-paris|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:18.913Z
ve_6c005ef142|en/grand-est/blienschwiller/restaurant/le-pressoir-de-bacchus|€€|CAT_P02|bib|fr|2026-10-30T05:08:20.281Z
ve_6c3ea53f2b|en/auvergne-rhone-alpes/le-puy-en-velay/restaurant/le-chamarlenc|€€€|CAT_P03|1 star|fr|2026-10-30T05:08:21.632Z
ve_6c6b97642b|en/ile-de-france/paris/restaurant/alleno-paris-au-pavillon-ledoyen|€€€€|CAT_P04|3 star|fr|2026-10-30T05:08:23.005Z
ve_6cddcafc1c|en/normandie/servon/restaurant/auberge-sauvage|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:24.349Z
ve_6cdf0b4d41|en/pays-de-la-loire/les-sorinieres/restaurant/le-1201-abbaye-de-villeneuve|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:25.687Z
ve_6d0954c2d8|en/provence-alpes-cote-dazur/la-ciotat/restaurant/roche-belle|€€|CAT_P02|bib|fr|2026-10-30T05:08:27.040Z
ve_6d4b571c98|en/grand-est/berrwiller/restaurant/l-arbre-vert|€€|CAT_P02|bib|fr|2026-10-30T05:08:28.405Z
ve_6d6daeee37|en/grand-est/montchenot/restaurant/le-grand-cerf|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:31.056Z
ve_6db828084a|en/occitanie/lattes/restaurant/le-temps-d-aime|€€|CAT_P02|bib|fr|2026-10-30T05:08:32.414Z
ve_6dd1ac7950|en/auvergne-rhone-alpes/annecy/restaurant/l-esquisse|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:33.773Z
ve_6e7aed280b|en/auvergne-rhone-alpes/chasse-sur-rhone_1510027/restaurant/les-nympheas-1218862|€€|CAT_P02|bib|fr|2026-10-30T05:08:35.111Z
ve_6eb714998c|en/ile-de-france/paris/restaurant/le-clarence|€€€€|CAT_P04|2 star|fr|2026-10-30T05:08:36.489Z
ve_6ecf974e14|en/bretagne/saint-malo/restaurant/la-fourchette-a-droite|€€|CAT_P02|bib|fr|2026-10-30T05:08:37.852Z
ve_6edde35381|en/auvergne-rhone-alpes/lyon/restaurant/sipres|€€|CAT_P02|bib|fr|2026-10-30T05:08:39.227Z
ve_6f3e5b6e6d|en/ile-de-france/issy-les-moulineaux/restaurant/maison-avoise|€€€|CAT_P03|1 star|fr|2026-10-30T05:08:40.581Z
ve_6f517e1f9c|en/auvergne-rhone-alpes/clermont-ferrand/restaurant/le-bistrot-d-a-cote|€€|CAT_P02|bib|fr|2026-10-30T05:08:41.937Z
ve_70045fa97a|en/bourgogne-franche-comte/courban/restaurant/chateau-de-courban|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:43.287Z
ve_70c395aaa5|en/ile-de-france/paris/restaurant/tomy-co|€€€|CAT_P03|1 star|fr|2026-10-30T05:08:44.649Z
ve_71187198ea|en/nouvelle-aquitaine/biarritz/restaurant/ahpe|€€|CAT_P02|bib|fr|2026-10-30T05:08:46.010Z
ve_71aa0107d1|en/ile-de-france/paris/restaurant/lucas-carton|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:47.378Z
ve_7211968ea6|en/auvergne-rhone-alpes/maubec_7770448/restaurant/l-esprit-bistrot|€€|CAT_P02|bib|fr|2026-10-30T05:08:48.752Z
ve_726a22f45a|en/auvergne-rhone-alpes/lyon/restaurant/takao-takano|€€€€|CAT_P04|2 star|fr|2026-10-30T05:08:50.120Z
ve_72902ba16f|en/auvergne-rhone-alpes/clermont-ferrand/restaurant/apicius205570|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:51.466Z
ve_72bc10551e|en/provence-alpes-cote-dazur/cannes/restaurant/la-palme-d-or|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:52.819Z
ve_74395c5c3c|en/auvergne-rhone-alpes/bourg-en-bresse/restaurant/mets-et-vins|€€|CAT_P02|bib|fr|2026-10-30T05:08:54.163Z
ve_7490a1189e|en/ile-de-france/paris/restaurant/lao-siam|€€|CAT_P02|bib|fr|2026-10-30T05:08:55.526Z
ve_7494ba16e0|en/auvergne-rhone-alpes/megve/restaurant/vous|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:56.899Z
ve_74b0053f51|en/provence-alpes-cote-dazur/mane/restaurant/le-feuillee-le-couvent-des-minimes|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:58.252Z
ve_74cb737437|en/ile-de-france/paris/restaurant/don-juan-ii|€€€€|CAT_P04|1 star|fr|2026-10-30T05:08:59.606Z
ve_74cd6eb343|en/bretagne/trbeurden/restaurant/vivace-1208978|€€|CAT_P02|bib|fr|2026-10-30T05:09:00.964Z
ve_750501612f|en/provence-alpes-cote-dazur/cassis/restaurant/la-villa-madie|€€€€|CAT_P04|3 star|fr|2026-10-30T05:09:02.377Z
ve_750c61e243|en/auvergne-rhone-alpes/saint-pray/restaurant/barr-avel|€€|CAT_P02|bib|fr|2026-10-30T05:09:03.775Z
ve_75405fe85b|en/occitanie/roquemaure_1503805/restaurant/tribu|€€|CAT_P02|bib|fr|2026-10-30T05:09:05.132Z
ve_754e0eb50d|en/pays-de-la-loire/pornic/restaurant/l-orangerie-1200220|€€|CAT_P02|bib|fr|2026-10-30T05:09:06.491Z
ve_754eff4295|en/pays-de-la-loire/les-sables-d-olonne/restaurant/alice-le-bistrot-le-manoir-de-la-mortiere|€€|CAT_P02|bib|fr|2026-10-30T05:09:07.870Z
ve_755bf8d6ea|en/ile-de-france/paris/restaurant/l-abysse-paris|€€€€|CAT_P04|2 star|fr|2026-10-30T05:09:09.295Z
ve_75913135f6|en/grand-est/la-vancelle/restaurant/auberge-frankenbourg|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:10.654Z
ve_75b42ccfa2|en/bretagne/carnac/restaurant/cote-cuisine|€€€|CAT_P03|1 star|fr|2026-10-30T05:09:12.013Z
ve_765c1b6aa3|en/nouvelle-aquitaine/prigueux/restaurant/l-essentiel117707|€€€|CAT_P03|1 star|fr|2026-10-30T05:09:13.363Z
ve_76a2262e75|en/grand-est/fouday/restaurant/julien|€€|CAT_P02|bib|fr|2026-10-30T05:09:14.775Z
ve_76c4bce6a9|en/provence-alpes-cote-dazur/flayosc/restaurant/le-jardin-de-berne|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:16.133Z
ve_76d0e682fb|en/auvergne-rhone-alpes/lyon/restaurant/bergamote|€€|CAT_P02|bib|fr|2026-10-30T05:09:17.548Z
ve_76f8401643|en/auvergne-rhone-alpes/l-albenc/restaurant/bistrot-louise|€€|CAT_P02|bib|fr|2026-10-30T05:09:18.923Z
ve_7723d4bc53|en/bourgogne-franche-comte/bonntage/restaurant/l-etang-du-moulin|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:20.253Z
ve_772b095e31|en/auvergne-rhone-alpes/granges-les-beaumont/restaurant/les-cedres|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:21.589Z
ve_7735b36541|en/grand-est/labaroche/restaurant/la-rochette|€€|CAT_P02|bib|fr|2026-10-30T05:09:22.945Z
ve_777a3fe819|en/hauts-de-france/brebires/restaurant/air-accueil|€€|CAT_P02|bib|fr|2026-10-30T05:09:24.351Z
ve_777fae7be2|en/ile-de-france/paris/restaurant/jouvence|€€|CAT_P02|bib|fr|2026-10-30T05:09:25.697Z
ve_7788732e3d|en/normandie/treis-sants-en-ouche_7770447/restaurant/le-moulin-fouret|€€|CAT_P02|bib|fr|2026-10-30T05:09:27.037Z
ve_77e6e37fab|en/occitanie/nimes/restaurant/rouge-1200806|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:28.403Z
ve_77ea00d9e9|en/provence-alpes-cote-dazur/aix-en-provence/restaurant/les-galinas|€€|CAT_P02|bib|fr|2026-10-30T05:09:29.780Z
ve_7828910915|en/nouvelle-aquitaine/bordeaux/restaurant/panaille|€€|CAT_P02|bib|fr|2026-10-30T05:09:31.139Z
ve_786a084bdb|en/ile-de-france/paris/restaurant/mosuke|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:32.502Z
ve_78e2ebdb64|en/pays-de-la-loire/nantes/restaurant/manoir-de-la-regate|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:33.849Z
ve_78f7d96f66|en/provence-alpes-cote-dazur/valdeblore/restaurant/auberge-de-la-roche-1203180|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:35.214Z
ve_7963871c91|en/auvergne-rhone-alpes/montluon/restaurant/la-chapelle|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:36.549Z
ve_796eb7756a|en/provence-alpes-cote-dazur/salon-de-provence/restaurant/villa-salone|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:37.900Z
ve_797c204266|en/nouvelle-aquitaine/guthary/restaurant/briketenia|€€€|CAT_P03|1 star|fr|2026-10-30T05:09:39.249Z
ve_798556fd62|en/occitanie/montpellier/restaurant/ebullition|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:40.610Z
ve_79f4d40e88|en/normandie/mathieu_1560708/restaurant/roze|€€|CAT_P02|bib|fr|2026-10-30T05:09:41.949Z
ve_7ad29c69ec|en/bretagne/quimper/restaurant/ti-coz|€€|CAT_P02|bib|fr|2026-10-30T05:09:43.300Z
ve_7afa7aaf3e|en/auvergne-rhone-alpes/annecy/restaurant/la-rotonde-des-tresoms|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:44.668Z
ve_7b1c4fa3a5|en/occitanie/belcastel/restaurant/vieux-pont|€€€|CAT_P03|1 star|fr|2026-10-30T05:09:46.013Z
ve_7b1c963f2f|en/auvergne-rhone-alpes/grignan/restaurant/le-clair-de-la-plume|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:47.361Z
ve_7b51bfe39a|en/ile-de-france/paris/restaurant/pierre-gagnaire6112|€€€€|CAT_P04|3 star|fr|2026-10-30T05:09:48.743Z
ve_7bf75a1ba3|en/provence-alpes-cote-dazur/mandelieu-la-napoule/restaurant/bessem|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:50.099Z
ve_7c2090b77f|en/bourgogne-franche-comte/valloux/restaurant/auberge-des-chenets|€€|CAT_P02|bib|fr|2026-10-30T05:09:51.372Z
ve_7c2f54f0ab|en/ile-de-france/paris/restaurant/akrame507272|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:52.737Z
ve_7c32575d62|en/normandie/deauville/restaurant/maximin-hellio|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:54.085Z
ve_7ca1d05c55|en/normandie/lyons-la-fort/restaurant/la-licorne-royale|€€€€|CAT_P04|1 star|fr|2026-10-30T05:09:55.422Z
ve_7cdc03d0fb|en/auvergne-rhone-alpes/saint-saturnin_1524702/restaurant/le-moulin-de-la-santoire|€€|CAT_P02|bib|fr|2026-10-30T05:09:56.775Z
ve_7ce2d0952f|en/auvergne-rhone-alpes/lyon/restaurant/le-jean-moulin|€€|CAT_P02|bib|fr|2026-10-30T05:09:58.139Z
ve_7d148be3ce|en/nouvelle-aquitaine/ciboure/restaurant/ekaitza|€€€€|CAT_P04|2 star|fr|2026-10-30T05:09:59.512Z
ve_7d1cc37f02|en/occitanie/saint-hilaire-d-ozilhan_1503960/restaurant/la-belle-vie|€€€|CAT_P03|1 star|fr|2026-10-30T05:10:00.867Z
ve_7d24cfdc87|en/hauts-de-france/belle-glise/restaurant/la-grange-de-belle-eglise|€€€|CAT_P03|1 star|fr|2026-10-30T05:10:02.227Z
ve_7d839d6f44|en/auvergne-rhone-alpes/val-d-isre/restaurant/la-table-de-l-ours|€€€€|CAT_P04|1 star|fr|2026-10-30T05:10:03.579Z
ve_7dbb9707de|en/hauts-de-france/villeneuve-d-ascq_1550830/restaurant/harmonie-1245894|€€€|CAT_P03|1 star|fr|2026-10-30T05:10:04.984Z$r$;
  rel jsonb;
  n_exp int := 473;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count before is not 7582'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 140 THEN RAISE EXCEPTION 'ledger max before is not 140'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 113968 THEN RAISE EXCEPTION 'audit max before is not 113968'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '0461133228d5637042b2358354a654bed31c7d4a4a4357ddb5cbc8e60f7103a2' THEN RAISE EXCEPTION 'relay sha256'; END IF;
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
  IF v_fp <> '611adefe4ed3a28e38878542fc391cd2' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> 'cf1c89ad4bc1241cff771e3536900c8f' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows: the legacy price rows of the relay venues, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '06d158dfc45db5e772dda7133825506a' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;

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
          'price-card:price-michelin-card-p2-b1-2026-10-30 | block A step 2 batch 1 (France part 1): legacy price rows with no URL, active Michelin star/Bib venues with a card URL | '
          || n_exp || ' rows updated from legacy (EUR 473) | live card read, built-in browser | relay md5 611adefe4ed3a28e38878542fc391cd2')
  RETURNING id INTO v_lid;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid <> 141 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 113968) <> n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 113968 AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
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
