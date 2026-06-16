/**
 * CompassEats — Clear Wrong-City Blurbs (one-shot)
 * =================================================
 * Blanks blurb_short + blurb_long for 119 venues whose bulk (Option A)
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
 * until these 119 get regenerated with a city-anchored prompt in the
 * next blurb batch.
 *
 * RUN ORDER: after reshape + mergeDuplicateVenues + importBlurbsFromDrive
 * (the wrong text lives in blurbs_final.csv, so it returns on every import
 * until the batch file itself is regenerated — re-run this after each
 * import until then).
 *
 * HOW TO RUN: Apps Script → paste → Run clearWrongCityBlurbs.
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
  'bangkok/sushi-saito-thailand',
  'beijing/xinrongji',
  'benicarlo/restaurant-raul-resino',
  'berlin/coda',
  'berlin/hugos',
  'los-angeles/spago',
  'blois/restaurant-christophe-hay-2',
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
  'dubai/sexy-fish-dubai',
  'edinburgh/lyla-restaurant-rooms',
  'florence/gucci-osteria-da-massimo-bottura',
  'fukui/sushi-jubei',
  'fukuoka/sushi-osamu',
  'guangzhou/imperial-treasure-fine-chinese-cuisine-tsim-sha-tsui',
  'guangzhou/lei-garden-restaurant-2',
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
  'los-angeles/sushi-sasabune',
  'maastricht/prix-de-rome',
  'madrid/restaurante-pabu',
  'madrid/smoked-room-madrid-fire-omakase-by-dani-garcia',
  'malaga/blossom-restaurant',
  'manhattan/roscioli-nyc',
  'mexico-city/au-pied-de-cochon',
  'miami-beach/the-bazaar-by-jose-andres',
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
  'paris/il-ristorante-niko-romito-2',
  'paris/restaurant-guy-savoy',
  'paris/sola',
  'reijmerstok/brut172-by-hans-van-wolde-2',
  'saint-germain/hostel-de-montfleury',
  'salamanca/tayta-by-victor-gutierrez-2',
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
  'sydney/ivy-sydney',
  'tata/platan-bistro',
  'tokyo/kikunoi',
  'tokyo/ryuzu',
  'tokyo/shinois',
  'toronto/danico',
  'ubon-ratchathani/mok',
  'udon-thani/khao-soi-thai-yai-restaurant-ua-udon',
  'udon-thani/red-lotus-pad-thai',
  'vancouver/st-lawrence-restaurant-2',
  'vichy/maison-decoret',
  'washington/sushi-nakazawa',
  'washington/washington',
  'wolfsburg/aqua'
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
  for (var r = 1; r < vals.length; r++) {
    var key = vals[r][col.city_slug] + '/' + vals[r][col.slug];
    if (!want[key]) continue;
    var touched = false;
    if (vals[r][col.blurb_short]) { vals[r][col.blurb_short] = ''; touched = true; }
    if (vals[r][col.blurb_long])  { vals[r][col.blurb_long]  = ''; touched = true; }
    if (touched) cleared++;
  }
  sheet.getRange(1, 1, vals.length, headers.length).setValues(vals);
  var msg = 'Cleared blurbs on ' + cleared + ' of ' + WRONG_CITY_KEYS.length + ' flagged venues.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
