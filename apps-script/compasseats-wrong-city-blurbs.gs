/**
 * CompassEats — Clear Wrong-City Blurbs (one-shot)
 * =================================================
 * Blanks blurb_short + blurb_long for venues whose bulk (Option A)
 * blurbs describe a DIFFERENT city than the venue's own — same-name venue
 * confusion from the batch generation (e.g. Restaurant Guy Savoy in PARIS
 * carrying the Las Vegas blurb; Aqua in WOLFSBURG carrying a Hong Kong blurb;
 * Atlas in ATLANTA carrying the Singapore blurb).
 *
 * Detection: blurb names a major city >150 km from the venue's own
 * coordinates (metro variants like New York City / Brooklyn excluded).
 * Full list with excerpts: wrong_city_blurb_audit.csv.
 *
 * Blanking restores the honest "A charted favorite in {city}" fallback
 * until these get regenerated with a city-anchored prompt in the
 * next blurb batch.
 *
 * RUN ORDER: after reshape + mergeDuplicateVenues + importBlurbsFromDrive
 * (the wrong text lives in blurbs_final.csv, so it returns on every import
 * until the batch file itself is regenerated — re-run this after each
 * import until then).
 *
 * HOW TO RUN: Apps Script → paste → Run clearWrongCityBlurbs.
 *
 * FIXED August 2, 2026: the original list keyed each venue by
 * city_slug + slug AS OF the original audit. Since then, mergeDuplicateVenues
 * and city-label corrections have shifted several of those keys (a "-2"
 * duplicate slug collapsing into its clean base slug, "manhattan" folding
 * into "new-york", "miami-beach" into "miami", "washington" into
 * "washington-dc"), so 13 of the original 119 keys no longer matched
 * anything and were silently skipped, even though 11 of those 13 still had
 * their wrong-city blurb sitting live and untouched. This run found and
 * fixed 12 of those 13 keys against the current venues export (10 simple
 * key drift, plus "ivy Sydney" and "Sushi Saito Thailand" which the
 * original list had guessed the WRONG city for in the first place, going
 * by the venue's name instead of its real city_slug — both have always
 * lived under a different city_slug than the list assumed). One entry
 * (washington/washington) didn't correspond to any identifiable venue and
 * was dropped rather than guessed at.
 */

var WRONG_CITY_KEYS = [
  'aachen/la-becasse-aachen',
  'aarhus/gastrome',
  'aix-en-provence/etude',
  'aomori/aomori-xwmafi',
  'atlanta/atlas',
  'atlanta/bacchanalia',
  'auchterarder/the-american-bar',
  'bad-gleichenberg/geschwister-rauch',
  'tokyo/sushi-saito-thailand',                 // FIXED — was 'bangkok/sushi-saito-thailand'; venue's own city_slug has always been tokyo
  'beijing/xinrongji',
  'benicarlo/restaurant-raul-resino',
  'berlin/coda',
  'berlin/hugos',
  'los-angeles/spago',
  'blois/restaurant-christophe-hay',            // FIXED — was '...-2'; mergeDuplicateVenues dropped the suffix
  'bordeaux/racines',
  'brampton/cedar-tree-by-hrishikesh-desai',
  'bry/restaurant-le-camelia',
  'caen/ivan-vautier',
  'castelnuovo-berardenga/poggio-rosso-ristorante',
  'changzhou/detan-hotel',
  'chicago/bazaar-meat-by-jose-andres',
  'colombo/nihonbashi-by-dharshan',
  'cossonay/restaurant-fleur-de-sel',
  'denver/death-co-denver',
  'dieppe/les-voiles-d-or',
  'doha/cut-by-wolfgang-puck',
  'dubai/la-petite-maison-lpm-dubai',
  'dubai/sexy-fish',                            // FIXED — was 'dubai/sexy-fish-dubai'; name was cleaned up, already blank, kept for list accuracy
  'edinburgh/lyla-restaurant-rooms',
  'florence/gucci-osteria',                     // FIXED — was 'florence/gucci-osteria-da-massimo-bottura'; name was cleaned up, already blank, kept for list accuracy
  'fukui/sushi-jubei',
  'fukuoka/sushi-osamu',
  'guangzhou/imperial-treasure-fine-chinese-cuisine-tsim-sha-tsui',
  'guangzhou/lei-garden',                       // FIXED — was '...-restaurant-2'; name+slug both cleaned up by merge
  'guangzhou/taotaoju',
  'hong-kong/ichu-hong-kong',
  'hong-kong/sushi-shin',
  'honolulu/mugen',
  'honolulu/sushi-ginza-onodera',
  'hsinchu-county/din-tai-fung',
  'jakarta/the-st-regis-bar',
  'kagoshima/meizan-kimiya',
  'khon-kaen/baan-heng',
  'khon-kaen/leng-yentafo-noodles',
  'khon-kaen/praprai-restaurant',
  'kyoto/kaiten-sushi-ginza-onodera-kyoto',
  'l-nstrup/restaurant-villa-vest',
  'laguepie/l-angle',
  'las-vegas/joel-robuchon',
  'lima/central',
  'lima/maido',
  'linz/rossbarth',
  'linz/verdi-restaurant-einkehr',
  'lisbon/kanazawa',
  'london/da-terra-restaurant',
  'london/hakkasan',
  'london/the-araki',
  'los-angeles/death-co-los-angeles',
  'los-angeles/ivy-sydney',                     // FIXED — was 'sydney/ivy-sydney'; venue's own city_slug has always been los-angeles
  'los-angeles/sushi-sasabune',
  'maastricht/prix-de-rome',
  'madrid/restaurante-pabu',
  'madrid/smoked-room-madrid-fire-omakase-by-dani-garcia',
  'malaga/blossom-restaurant',
  'new-york/roscioli-nyc',                      // FIXED — was 'manhattan/roscioli-nyc'; city label folded into new-york
  'mexico-city/au-pied-de-cochon',
  'miami/the-bazaar-by-jose-andres',            // FIXED — was 'miami-beach/...'; city label folded into miami
  'milan/contraste',
  'millinge/falsled-kro-1744-relais-chateaux',
  'montcy-notre-dame/l-auberge-du-laminak',
  'nagoya/reminiscence',
  'nagoya/sushi-hijikata',
  'nakhon-ratchasima/laab-somphit',
  'nakhon-ratchasima/oshin-snack-korat',
  'nakhon-ratchasima/sangthai-grilled-chicken',
  'nakhon-ratchasima/sow-jeck-pochana',
  'nantes/les-cadets',
  'nantes/restaurant-omija',
  'new-york/balthazar',
  'new-york/koloman',
  'new-york/raku',
  'new-york/yoshino-new-york',
  'oneonta/brooks-house-of-bar-b-q',
  'oropesa-del-mar/restaurant-llavor',
  'osaka/la-kanro',
  'osaka/matsuzushi',
  'osaka/yamada',
  'paris/il-ristorante-niko-romito',             // FIXED — was '...-2'; mergeDuplicateVenues dropped the suffix
  'paris/restaurant-guy-savoy',
  'paris/sola',
  'reijmerstok/brut172-by-hans-van-wolde',       // FIXED — was '...-2'; mergeDuplicateVenues dropped the suffix
  'saint-germain/hostel-de-montfleury',
  'salamanca/tayta-by-victor-gutierrez',         // FIXED — was '...-2'; mergeDuplicateVenues dropped the suffix
  'san-francisco/acquerello',
  'san-francisco/kiln',
  'san-mateo/wakuriya',
  'sankt-wolfgang-im-salzkammergut/paula-gourmet-restaurant',
  'scharbeutz/restaurant-belveder',
  'scorze/ristorante-san-martino',
  'seoul/kyodaiya',
  'seoul/l-amitie-cheongdam',
  'servon/auberge-sauvage',
  'shizuoka/seika-kobayashi',
  'shizuoka/seirin',
  'stuttgart/wielandshohe',
  'tata/platan-bistro',
  'tokyo/kikunoi',
  'tokyo/ryuzu',
  'tokyo/shinois',
  'toronto/danico',
  'ubon-ratchathani/mok',
  'udon-thani/khao-soi-thai-yai-restaurant-ua-udon',
  'udon-thani/red-lotus-pad-thai',
  'vancouver/st-lawrence-restaurant',            // FIXED — was '...-2'; mergeDuplicateVenues dropped the suffix
  'vichy/maison-decoret',
  'washington-dc/sushi-nakazawa',                // FIXED — was 'washington/sushi-nakazawa'; city label corrected to washington-dc
  'wolfsburg/aqua'
  // REMOVED: 'washington/washington' — no identifiable matching venue found; likely a bad entry in the original audit
];

function clearWrongCityBlurbs() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName('venues');
  if (!sheet) throw new Error('No "venues" tab found.');
  var vals = sheet.getDataRange().getValues();
  var headers = vals[0];
  var col = {};
  for (var h = 0; h < headers.length; h++) col[headers[h]] = h;

  var want = {};
  for (var i = 0; i < WRONG_CITY_KEYS.length; i++) want[WRONG_CITY_KEYS[i]] = true;

  var cleared = 0;
  var alreadyBlank = 0;
  var stillMissing = [];
  var seen = {};
  for (var r = 1; r < vals.length; r++) {
    var key = vals[r][col.city_slug] + '/' + vals[r][col.slug];
    if (!want[key]) continue;
    seen[key] = true;
    var touched = false;
    if (vals[r][col.blurb_short]) { vals[r][col.blurb_short] = ''; touched = true; }
    if (vals[r][col.blurb_long])  { vals[r][col.blurb_long]  = ''; touched = true; }
    if (touched) cleared++; else alreadyBlank++;
  }
  for (var k in want) { if (!seen[k]) stillMissing.push(k); }

  sheet.getRange(1, 1, vals.length, headers.length).setValues(vals);
  Logger.log('Cleared blurbs on ' + cleared + ' of ' + WRONG_CITY_KEYS.length + ' flagged venues.');
  Logger.log('Already blank (nothing to clear): ' + alreadyBlank);
  if (stillMissing.length) {
    Logger.log('Key still not found in venues tab (' + stillMissing.length + '): \n' + stillMissing.join('\n'));
  }
}
