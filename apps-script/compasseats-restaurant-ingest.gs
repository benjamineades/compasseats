/**
 * CompassEats — Restaurant List Ingestion (Google Apps Script)  v4
 * ================================================================
 * CHANGED IN v2 (June 3, 2026):
 *   Restaurant ingest NO LONGER writes into the "venues" tab. Reshape
 *   rebuilds "venues" from scratch every run and was wiping every restaurant
 *   this tool added. Instead, ingest folds your pasted lists into a single
 *   "Restaurant Awards" tab — which reshape reads as a normal award source.
 *
 *   cuisine and price_band carry through into reshape (written to
 *   venues.cuisine_tags / venues.price_tier).
 *
 * ADDED IN v3 (August 4, 2026) — standing price-capture rule:
 *   price_symbol_raw, price_source_url. Capture the source's own price text
 *   as-is plus the page it came from. Provenance only, not read by reshape.
 *
 * ADDED IN v4 (August 8, 2026) — standing GEO-capture rule. READ THIS:
 *   Three new OPTIONAL columns: address_raw, coords_raw, geo_source_url.
 *
 *   WHY THIS EXISTS. Every address and coordinate in CompassEats today came
 *   from Google Places, matched on name + city. That has to go: Google's
 *   terms prohibit storing Places content, prohibit showing it on a
 *   non-Google map (CompassEats renders MapLibre), and prohibit using it to
 *   build a competing local-discovery product.
 *
 *   The replacement was going to be open geodata. Testing on a 200-venue
 *   stratified sample killed that as a standalone answer: measured against
 *   known coordinates at a 150 m bar, Overture resolved 57%, Geoapify 40%,
 *   either source 64%. It fails worst exactly where CompassEats is
 *   strongest — Japan 40%, China 47%, Middle East 50%.
 *
 *   The award guides themselves publish full street addresses, and several
 *   publish coordinates. A hand-check of 12 Michelin venues found a complete
 *   street address in schema.org JSON-LD on every page, plus venue-level
 *   coordinates to 6-7 decimal places, including the Japanese, Hong Kong and
 *   Shanghai venues that open geodata could not place.
 *
 *   So: capture geo at ingest, from the same page you're already reading for
 *   the award. One more field on a paste you're already doing.
 *
 *   WHAT TO PUT IN THEM
 *     address_raw    — the street address EXACTLY as the source printed it.
 *                      Do not reformat, translate, or strip the ward or
 *                      building name. "35 Nanzenji Kusagawacho, Sakyo-ku,
 *                      Kyoto 606-8437" goes in whole.
 *     coords_raw     — latitude and longitude if the source publishes them,
 *                      as "lat, lng" in one cell, e.g. "35.011355, 135.786742".
 *                      Blank if the source doesn't show them.
 *     geo_source_url — the exact page you read the address off.
 *
 *   WHAT NOT TO DO
 *     Do not paste coordinates from Google Maps, or from any geocoder, into
 *     coords_raw. This column means "the award guide published this." Mixing
 *     in other sources destroys the provenance that makes the column worth
 *     having, and in Google's case reintroduces the exact problem being
 *     removed. Blank is a perfectly good answer.
 *
 *   These three columns do NOT feed venues.lat / venues.lng yet. That is a
 *   separate, deliberate step in the wider re-architecture. This is capture
 *   only, so the backfill problem stops growing while the rest is designed.
 *   Appended at the very END of the column list on purpose — reshape's
 *   parser reads Restaurant Awards by column position, so nothing already in
 *   production shifts.
 *
 * HOW GRADING SYSTEMS WORK (read this — it's the important part)
 *   - A plain numeric RANK goes in the `rank` column (auto-labels "No. {rank}").
 *   - ANY other grading goes in `category_override` as free text:
 *       "3 Knives", "Two Stars", "98.5/100", "Three Toques", "Grand Award".
 *   A brand-new grading FORMAT needs NO script change and NO new column.
 *   NOTE: a brand-new SOURCE SLUG is different — it must be added to
 *   VALID_RESTAURANT_SLUGS below, or ingestRestaurantLists will silently skip
 *   every row using it (counted as "invalid source_slug"). It must also be
 *   added to AWARD_SOURCES in schema.ts before the site rebuilds, or the
 *   build's validation gate rejects those venues. Both are required.
 *
 * TWO FUNCTIONS
 *   makeRestaurantImportTemplate()  creates a blank "Restaurant List Import"
 *                                   tab with the right columns + a dropdown.
 *   ingestRestaurantLists()         reads ALL tabs whose name starts with
 *                                   "Restaurant List Import", de-dupes against
 *                                   "Restaurant Awards", and appends new rows.
 *
 * WORKFLOW
 *   1. Run makeRestaurantImportTemplate() once.
 *   2. Paste a list: source_slug, year, rank, name, city, country,
 *      [category_override], [cuisine], [price_band], [price_symbol_raw],
 *      [price_source_url], [address_raw], [coords_raw], [geo_source_url].
 *   3. Run ingestRestaurantLists().      <-- fills "Restaurant Awards"
 *   4. Run reshapeCompassEats().         <-- folds it into venues
 *
 * ONE-TIME MANUAL STEP (do this before running v4 for the first time):
 *   Your live "Restaurant Awards" tab already exists, so the "create tab
 *   with headers" branch below won't fire for it. Add three headers by hand:
 *     cell L1 = address_raw
 *     cell M1 = coords_raw
 *     cell N1 = geo_source_url
 *   (J1 and K1 should already hold price_symbol_raw and price_source_url
 *   from the v3 step. If they don't, add those first.)
 */

var R_IMPORT_PREFIX = 'Restaurant List Import';
var RESTAURANT_AWARDS_TAB = 'Restaurant Awards';

var VALID_RESTAURANT_SLUGS = [
  'worlds-50-best-restaurants', 'worlds-50-best-restaurants-51-100',
  'asia-50-best-restaurants', 'asia-50-best-restaurants-51-100',
  'latin-america-50-best-restaurants',
  'north-america-50-best-restaurants',
  'mena-50-best-restaurants',
  'africa-50-best-restaurants',
  'la-liste',
  '101-best-steakhouses',
  'michelin',
  'best-chef-awards',
  'james-beard', 'oad', 'gault-millau', 'tabelog', 'forbes-travel-guide',
  'wine-spectator'
];

// Column shape of the "Restaurant Awards" tab (reshape's parser reads these positions)
var RESTAURANT_AWARDS_HEADERS =
  ['source_slug', 'year', 'rank', 'name', 'city', 'country',
   'category_override', 'cuisine', 'price_band',
   'price_symbol_raw', 'price_source_url',
   'address_raw', 'coords_raw', 'geo_source_url'];

/**
 * SOURCE ALIAS MAP — lets your compiled files paste in AS-IS.
 */
var SOURCE_ALIASES_R = {
  "asia's 50 best restaurants": 'asia-50-best-restaurants',
  "latin america's 50 best restaurants": 'latin-america-50-best-restaurants',
  "north america's 50 best restaurants": 'north-america-50-best-restaurants',
  "middle east and north africa's 50 best restaurants": 'mena-50-best-restaurants',
  "mena's 50 best restaurants": 'mena-50-best-restaurants',
  "africa's 50 best restaurants": 'africa-50-best-restaurants',
  "world's 50 best restaurants": 'worlds-50-best-restaurants',
  "la liste": 'la-liste',
  "la liste 2026": 'la-liste',
  "michelin guide": 'michelin',
  "best chef awards": 'best-chef-awards',
  "101 best steakhouses": '101-best-steakhouses'
};

function normSourceR_(s) {
  if (!s) return '';
  var t = String(s).toLowerCase();
  t = t.replace(/&/g, ' and ');
  t = t.replace(/[''`]/g, '');
  t = t.replace(/[^a-z0-9]+/g, ' ');
  return t.replace(/\s+/g, ' ').trim();
}

function resolveSourceR_(raw) {
  var s = String(raw || '').trim();
  if (!s) return '';
  if (VALID_RESTAURANT_SLUGS.indexOf(s) >= 0) return s;          // already a slug
  var norm = normSourceR_(s);
  // Build a normalized-key view of the alias map ONCE, so apostrophes/&
  // in the keys don't block the match (keys were stored un-normalized).
  if (!resolveSourceR_._normMap) {
    resolveSourceR_._normMap = {};
    for (var key in SOURCE_ALIASES_R) {
      if (SOURCE_ALIASES_R.hasOwnProperty(key)) {
        resolveSourceR_._normMap[normSourceR_(key)] = SOURCE_ALIASES_R[key];
      }
    }
  }
  if (resolveSourceR_._normMap[norm]) return resolveSourceR_._normMap[norm];  // display name
  for (var k = 0; k < VALID_RESTAURANT_SLUGS.length; k++) {
    if (normSourceR_(VALID_RESTAURANT_SLUGS[k]) === norm) return VALID_RESTAURANT_SLUGS[k];
  }
  return '';
}

// ---------------------------------------------------------------------------

function makeRestaurantImportTemplate() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var name = R_IMPORT_PREFIX;
  var sheet = ss.getSheetByName(name);
  if (sheet) {
    SpreadsheetApp.getUi().alert('"' + name + '" already exists. Paste into it, ' +
      'or duplicate it as "' + name + ' 2" for a second list.');
    return;
  }
  sheet = ss.insertSheet(name);
  var headers = ['source_slug', 'year', 'rank', 'name', 'city', 'country',
    'category_override', 'cuisine', 'price_band',
    'price_symbol_raw', 'price_source_url',
    'address_raw', 'coords_raw', 'geo_source_url'];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
  sheet.setFrozenRows(1);

  var rule = SpreadsheetApp.newDataValidation()
    .requireValueInList(VALID_RESTAURANT_SLUGS, true)
    .setAllowInvalid(false)
    .setHelpText('Pick a valid restaurant source slug.')
    .build();
  sheet.getRange(2, 1, 2000, 1).setDataValidation(rule);

  var examples = [
    ['asia-50-best-restaurants', 2026, 1, 'Gaggan Anand', 'Bangkok', 'Thailand', '',
     'Progressive Indian', '$$$$', '', '', '', '', ''],
    ['best-chef-awards', 2025, '', 'Disfrutar', 'Barcelona', 'Spain', '3 Knives',
     'Modernist', '$$$$', '', '', '', '', ''],
    ['michelin', 2025, '', 'Le Bernardin', 'New York', 'United States', 'Three Stars',
     'Seafood', '$$$$', '', '', '155 W. 51st St., New York, 10019',
     '40.7614315, -73.9816835', 'https://guide.michelin.com/...'],
    ['michelin', 2025, '', 'Hyotei', 'Kyoto', 'Japan', 'Three Stars',
     'Kaiseki', '$$$$', '', '', '35 Nanzenji Kusagawacho, Sakyo-ku, Kyoto 606-8437',
     '35.011355, 135.786742', 'https://guide.michelin.com/...']
  ];
  sheet.getRange(2, 1, examples.length, headers.length).setValues(examples)
    .setFontColor('#999999').setFontStyle('italic');

  var note =
    'REQUIRED:\n' +
    'source_slug: pick from dropdown\n' +
    'year: award year (e.g. 2026)\n' +
    'name/city/country: the venue\n\n' +
    'GRADING — use ONE of these:\n' +
    'rank: numeric only (e.g. 1) -> auto-labels "No. 1"\n' +
    'category_override: any non-rank grade as free text\n' +
    '   e.g. "3 Knives", "Three Stars", "98.5/100", "Grand Award"\n' +
    '   (leave rank blank when you use this)\n\n' +
    'OPTIONAL venue attributes (blank is fine):\n' +
    'cuisine: e.g. "Nikkei" -> venues.cuisine_tags\n' +
    'price_band: CompassEats own normalized scale, e.g. $$$ -> venues.price_tier\n' +
    'price_symbol_raw: the price EXACTLY as the source displayed it\n' +
    'price_source_url: the exact page you saw that price on\n\n' +
    'OPTIONAL geo capture (NEW — please fill these in whenever the source\n' +
    'shows them, it saves a great deal of work later):\n' +
    'address_raw: the street address EXACTLY as printed. Keep the ward,\n' +
    '   building and postcode. Do not reformat or translate.\n' +
    'coords_raw: "lat, lng" in one cell if the source publishes coordinates,\n' +
    '   e.g. "35.011355, 135.786742". ONLY from the award source itself —\n' +
    '   never from Google Maps or any other geocoder. Blank is fine.\n' +
    'geo_source_url: the page you read the address off';
  sheet.getRange('A1').setNote(note);
  sheet.setColumnWidth(4, 220);
  sheet.setColumnWidth(7, 160);
  sheet.setColumnWidth(11, 260);
  sheet.setColumnWidth(12, 320);
  sheet.setColumnWidth(14, 260);

  SpreadsheetApp.getUi().alert(
    'Created "' + name + '".\n\n' +
    'Grey example rows show the format — knives / stars / scores go in ' +
    'category_override, NOT their own column. Delete the examples, paste your ' +
    'real list, then run ingestRestaurantLists.\n\n' +
    'NEW in v4: address_raw / coords_raw / geo_source_url. Fill these in ' +
    'whenever the award source shows an address. Coordinates ONLY if the ' +
    'guide itself publishes them, never from Google Maps.\n\n' +
    'Your compiled 6-column files still paste straight in; leave the extra ' +
    'columns blank.\n\n' +
    'For multiple lists, duplicate this tab as "' + name + ' 2", etc.');
}

// ---------------------------------------------------------------------------

function ingestRestaurantLists() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  // Gather import tabs
  var importSheets = ss.getSheets().filter(function (s) {
    return s.getName().indexOf(R_IMPORT_PREFIX) === 0;
  });
  if (!importSheets.length) {
    throw new Error('No "' + R_IMPORT_PREFIX + '" tab. Run makeRestaurantImportTemplate first.');
  }

  // Ensure the Restaurant Awards tab exists with headers
  var awardsSheet = ss.getSheetByName(RESTAURANT_AWARDS_TAB);
  if (!awardsSheet) {
    awardsSheet = ss.insertSheet(RESTAURANT_AWARDS_TAB);
    awardsSheet.getRange(1, 1, 1, RESTAURANT_AWARDS_HEADERS.length)
      .setValues([RESTAURANT_AWARDS_HEADERS]).setFontWeight('bold');
    awardsSheet.setFrozenRows(1);
  }

  // Build a set of award rows we already have, to avoid duplicates.
  // Signature = source_slug | year | normalized(name) | normalized(city)
  var existing = {};
  var av = awardsSheet.getDataRange().getValues();
  for (var ar = 1; ar < av.length; ar++) {
    var arow = av[ar];
    if (!arow || arow.join('') === '') continue;
    var asig = String(arow[0]).trim() + '|' + (Number(arow[1]) || '') + '|' +
               normKeyR_(arow[3]) + '|' + normKeyR_(String(arow[4] || ''));
    existing[asig] = true;
  }

  var added = 0, skippedDup = 0, bad = 0, blank = 0, withGeo = 0, withCoords = 0;
  var newRows = [];

  for (var si = 0; si < importSheets.length; si++) {
    var rows = importSheets[si].getDataRange().getValues();
    for (var ri = 1; ri < rows.length; ri++) {
      var row = rows[ri];
      var rawSrc = String(row[0] || '').trim();
      var name = String(row[3] || '').trim();
      if (!rawSrc && !name) { blank++; continue; }
      if (!rawSrc || !name) { blank++; continue; }
      var src = resolveSourceR_(rawSrc);   // accepts slug OR display name
      if (!src) { bad++; continue; }

      var year = Number(row[1]) || 2025;
      var rank = row[2] === '' ? '' : (Number(row[2]) || '');
      var city = String(row[4] || '').trim();
      var country = String(row[5] || '').trim();
      var catOverride = String(row[6] || '').trim();
      var cuisine = String(row[7] || '').trim();
      var priceBand = String(row[8] || '').trim();
      var priceSymbolRaw = String(row[9] || '').trim();
      var priceSourceUrl = String(row[10] || '').trim();
      var addressRaw = String(row[11] || '').trim();
      var coordsRaw = String(row[12] || '').trim();
      var geoSourceUrl = String(row[13] || '').trim();

      var sig = src + '|' + year + '|' + normKeyR_(name) + '|' + normKeyR_(city);
      if (existing[sig]) { skippedDup++; continue; }
      existing[sig] = true; // guard against dups within this same run

      if (addressRaw) withGeo++;
      if (coordsRaw) withCoords++;

      newRows.push([src, year, rank, name, city, country,
                    catOverride, cuisine, priceBand,
                    priceSymbolRaw, priceSourceUrl,
                    addressRaw, coordsRaw, geoSourceUrl]);
      added++;
    }
  }

  if (newRows.length) {
    var last = awardsSheet.getLastRow();
    awardsSheet.getRange(last + 1, 1, newRows.length, RESTAURANT_AWARDS_HEADERS.length)
      .setValues(newRows);
  }

  var msg =
    'Restaurant ingestion complete (v4 — writes to "Restaurant Awards").\n' +
    'award rows added to "Restaurant Awards": ' + added + '\n' +
    'duplicate rows skipped:                  ' + skippedDup + '\n' +
    'invalid source_slug rows skipped:        ' + bad + '\n' +
    'blank/partial rows skipped:              ' + blank + '\n\n' +
    'GEO CAPTURE (new in v4)\n' +
    '  rows carrying a street address:        ' + withGeo + ' of ' + added + '\n' +
    '  rows carrying source coordinates:      ' + withCoords + ' of ' + added + '\n' +
    (added > 0 && withGeo === 0
      ? '  NOTE: no addresses captured this run. If the source publishes them,\n' +
        '  going back for them later is far more work than doing it now.\n'
      : '') +
    '\nNEXT: run reshapeCompassEats to fold these into the venues tab.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// ---- helpers (suffixed _R to avoid collisions with other scripts) ---------

function normKeyR_(name) {
  if (!name) return '';
  var s = String(name).normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  s = s.replace(/['\u2018\u2019\u02BC`]/g, '');
  s = s.replace(/&/g, ' and ');
  s = s.replace(/[^a-z0-9]+/g, ' ');
  return s.replace(/\s+/g, ' ').trim();
}
