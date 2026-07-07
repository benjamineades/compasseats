/**
 * CompassEats — Collision Fix, Batch 1 (GREEN)  —  July 1, 2026
 * =============================================================================
 * Two functions. Run them IN ORDER, each once:
 *
 *   1. fixRequeryCanonicalNames()  — blanks the canonicalName column on every
 *      Places Enrichment row whose sheetName is 'geo-requery'. Those rows were
 *      written with Google's returned display name, which Reshape then uses as
 *      the venue's NAME → changes the slug → orphans the blurb (the exact
 *      mechanism of the June 20 "CollisionRequery" incident). Blanking the
 *      column keeps the corrected coordinates but lets every venue's name come
 *      from the award tabs again, restoring original slugs and blurb keys.
 *
 *   2. acceptGreenCollisionRows()  — takes the 143 parked requery results that
 *      were independently verified (returned coordinates land within 30 km of
 *      the queried city's own centroid, computed ONLY from venues that are not
 *      part of any collision — the "Amelia Island / Budapest" guard) and writes
 *      them into Places Enrichment as new rows:
 *        • keyed by the exact composite key Reshape looks up first
 *        • canonicalName BLANK (never renames a venue)
 *        • provenance 'collision-fix' in the sheetName column (easy to undo:
 *          filter on that value and delete)
 *      It reads placeId / lat / lng / photo / address / status live from the
 *      collision_review tab, skips any key already present in Places
 *      Enrichment, and stamps the consumed review rows decision = ACCEPT.
 *
 * SAFE BY DESIGN: append-only + one column blanked. Venue NAMES are never
 * touched. Nothing is deleted.
 *
 * AFTER BOTH RUNS: run the full pipeline
 *   reshapeCompassEats -> mergeDuplicateVenues -> importBlurbsFromDrive ->
 *   clearWrongCityBlurbs -> importOptionB -> generateCitiesTab ->
 *   generateRegionsTab -> preflightPublish
 * and CHECK that importBlurbsFromDrive reports ~10,300+ rows filled.
 * If that number craters, STOP and report back before publishing.
 */

var CFX_GREEN_KEYS = [
  "8 1 2 otto e mezzo bombana|macau",
  "8 1 2 otto e mezzo bombana|shanghai",
  "81 2 otto e mezzo bombana|hong kong",
  "agis counter|new york",
  "aleli rooftop|mexico city",
  "alma|montreal",
  "alma|prague",
  "alta calidad|new york",
  "amaru|melbourne",
  "aria|naples",
  "aska|new york",
  "atelier|munich",
  "avant|bangkok",
  "bakea|mexico city",
  "baron|beirut",
  "bird|copenhagen",
  "bonnies|new york",
  "cafe mars|new york",
  "capa|copenhagen",
  "caracol de mar|mexico city",
  "chainaya tea and cocktails|moscow",
  "chavelas|new york",
  "chuan tian xia|new york",
  "clara|bangkok",
  "coda|bangkok",
  "comedor jacinta|mexico city",
  "contramar|mexico city",
  "cosme|lima",
  "da vittorio|shanghai",
  "demo|lima",
  "don alfonso 1890|macau",
  "el cielo|miami",
  "enigma|ho chi minh city",
  "filigrana|mexico city",
  "fugaz|mexico city",
  "gaa|bangkok",
  "galanga thai house|mexico city",
  "gordos cantina|new york",
  "gucci osteria|florence",
  "guido|rimini",
  "haenyeo|new york",
  "harrys bar|paris",
  "harrys bar|venice",
  "hashimoto|toronto",
  "hemingway bar|paris",
  "hemingway bar|prague",
  "hometown bar b que new york|new york",
  "hugos|sydney",
  "igniv by andreas caminada|andermatt",
  "igniv|bangkok",
  "il ristorante niko romito|beijing",
  "il ristorante niko romito|shanghai",
  "ilis|new york",
  "izakaya|cairo",
  "jan|munich",
  "jean georges|shanghai",
  "jowong|mexico city",
  "koan|copenhagen",
  "koan|tokyo",
  "kol|torshavn",
  "la 89|mexico city",
  "la mar|lima",
  "la petite maison|miami",
  "la tour dargent|tokyo",
  "lagape|geneva",
  "lai heen|hong kong",
  "langle|barcelona",
  "laparte|geneva",
  "latelier de joel robuchon|geneva",
  "lei garden|guangzhou",
  "ling long|beijing",
  "ling long|shanghai",
  "lore|new york",
  "lyles|adelaide",
  "maison lameloise|shanghai",
  "maison premiere|new york",
  "maximo|houston",
  "maximo|mexico city",
  "mind|chengdu",
  "miss ada|new york",
  "mizumi|macau",
  "mraz and sohn|vienna",
  "mugaritz|munich",
  "olmo|new york",
  "pargot|mexico city",
  "pascucci al porticciolo|rome",
  "pierozek|new york",
  "pink rambo|mexico city",
  "plonk|mexico city",
  "pujol|mexico city",
  "quince|bangkok",
  "quintonil|mexico city",
  "radio|copenhagen",
  "raiz|mexico city",
  "root|city of bristol",
  "rosi|vienna",
  "ru yuan|changzhou",
  "ru yuan|hangzhou",
  "runner up|new york",
  "s ller d kro|copenhagen",
  "saint peter|sydney",
  "sal tangs|new york",
  "selma|copenhagen",
  "sexy fish|dubai",
  "shalom japan|new york",
  "siembra tortilleria|mexico city",
  "sobre masa|new york",
  "speedy romeo|new york",
  "spice market|new york",
  "sublime|guatemala city",
  "sud 777|mexico city",
  "summer palace|beijing",
  "sushi saito|bangkok",
  "tacos del valle|mexico city",
  "taian table|shanghai",
  "taku|cologne",
  "taku|london",
  "tang court|shanghai",
  "tanoreen|new york",
  "tan|beijing",
  "tan|shanghai",
  "taqueria el chato|new york",
  "taqueria el jarocho|mexico city",
  "taqueria los cocuyos|mexico city",
  "the four horsemen|new york",
  "the ivy|london",
  "the ivy|sydney",
  "the old man|singapore",
  "tohru in der schreiberei|munich",
  "ultramarinos demar|mexico city",
  "untable|new york",
  "via veneto|los angeles",
  "vigneron|mexico city",
  "villa torel|ensenada",
  "voraz|mexico city",
  "win son|new york",
  "xin rong ji|beijing",
  "xin rong ji|shanghai",
  "xin rong ji|taizhou",
  "yamazato|paris",
  "yemenat|new york",
  "yu zhi lan|chengdu",
  "zuicho|macau",
];

function fixRequeryCanonicalNames() {
  var ss = SpreadsheetApp.getActive();
  var e = ss.getSheetByName('Places Enrichment');
  if (!e) throw new Error('No Places Enrichment tab.');
  var vals = e.getDataRange().getValues();
  // Columns: 0 normalizedKey, 1 canonicalName, 2 sheetName
  var blanked = 0, alreadyBlank = 0;
  var col2 = []; // rebuild canonicalName column in memory, write once
  for (var i = 1; i < vals.length; i++) {
    var src = String(vals[i][2] || '');
    var canon = vals[i][1];
    if (src === 'geo-requery') {
      if (canon === '' || canon === null) { alreadyBlank++; }
      else { canon = ''; blanked++; }
    }
    col2.push([canon]);
  }
  if (col2.length) e.getRange(2, 2, col2.length, 1).setValues(col2);
  var msg = 'fixRequeryCanonicalNames\n' +
    'geo-requery rows with canonicalName blanked: ' + blanked + '\n' +
    'geo-requery rows already blank: ' + alreadyBlank + '\n\n' +
    'Expected blanked: ~704.\nNEXT: run acceptGreenCollisionRows().';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

function acceptGreenCollisionRows() {
  var ss = SpreadsheetApp.getActive();
  var rev = ss.getSheetByName('collision_review');
  if (!rev) throw new Error('No collision_review tab.');
  var e = ss.getSheetByName('Places Enrichment');
  if (!e) throw new Error('No Places Enrichment tab.');

  var want = {};
  for (var g = 0; g < CFX_GREEN_KEYS.length; g++) want[CFX_GREEN_KEYS[g]] = true;

  // Keys already in Places Enrichment — never write a duplicate key.
  var have = {};
  var ev = e.getDataRange().getValues();
  for (var er = 1; er < ev.length; er++) { var k0 = ev[er][0]; if (k0) have[String(k0)] = true; }

  // collision_review columns:
  // 0 decision, 1 queried_name, 2 queried_city, 3 returned_name, 4 composite_key,
  // 5 placeId, 6 lat, 7 lng, 8 photoName, 9 formattedAddress, 10 businessStatus, 11 note
  var rv = rev.getDataRange().getValues();
  var today = new Date().toISOString().slice(0, 10);
  var newRows = [], stampRows = [], usedKey = {};
  var skippedExisting = 0, missingData = 0;

  for (var i = 1; i < rv.length; i++) {
    var key = String(rv[i][4] || '');
    if (!want[key] || usedKey[key]) continue;
    if (have[key]) { usedKey[key] = true; skippedExisting++; continue; }
    var lat = rv[i][6], lng = rv[i][7], pid = rv[i][5];
    if (lat === '' || lat === null || lng === '' || lng === null || !pid) { missingData++; continue; }
    newRows.push([
      key,                      // normalizedKey (composite — Reshape checks this first)
      '',                       // canonicalName BLANK — never rename a venue
      'collision-fix',          // provenance
      pid, lat, lng,
      rv[i][8] || '',           // photoName
      rv[i][9] || '',           // formattedAddress
      rv[i][10] || '',          // businessStatus
      today
    ]);
    usedKey[key] = true;
    stampRows.push(i + 1);      // 1-based sheet row to stamp ACCEPT
  }

  if (newRows.length) {
    var last = e.getLastRow();
    e.getRange(last + 1, 1, newRows.length, 10).setValues(newRows);
  }
  for (var s = 0; s < stampRows.length; s++) {
    rev.getRange(stampRows[s], 1).setValue('ACCEPT');
    rev.getRange(stampRows[s], 12).setValue('verified vs anchored city centroid — applied ' + today);
  }

  var msg = 'acceptGreenCollisionRows\n' +
    'green keys in list:            ' + CFX_GREEN_KEYS.length + '\n' +
    'new Places Enrichment rows:    ' + newRows.length + '\n' +
    'skipped (key already present): ' + skippedExisting + '\n' +
    'skipped (missing lat/lng/id):  ' + missingData + '\n\n' +
    'Expected new rows: ~143.\n' +
    'NEXT: run the full pipeline starting with reshapeCompassEats,\n' +
    'and check importBlurbsFromDrive reports ~10,300+ rows filled.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
