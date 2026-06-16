/**
 * CompassEats — Restaurant List Ingestion (Google Apps Script)  v2
 * ================================================================
 * CHANGED IN v2 (June 3, 2026):
 *   Restaurant ingest NO LONGER writes into the "venues" tab. Reshape
 *   rebuilds "venues" from scratch every run and was wiping every restaurant
 *   this tool added. Instead, ingest now folds your pasted lists into a
 *   single "Restaurant Awards" tab — which reshape reads as a normal award
 *   source. Restaurants now survive reshape and get the same
 *   name -> "Places Enrichment" geo matching as every other venue.
 *
 *   cuisine and price_band carry through the Restaurant Awards tab and into
 *   reshape (written to venues.cuisine_tags / venues.price_tier).
 *
 * HOW GRADING SYSTEMS WORK (read this — it's the important part)
 *   - A plain numeric RANK goes in the `rank` column (auto-labels "No. {rank}").
 *   - ANY other grading goes in `category_override` as free text:
 *       "3 Knives", "Two Stars", "98.5/100", "Three Toques", "Grand Award".
 *   A brand-new award type needs NO script change and NO new column — paste it
 *   with the right source_slug and put its grade in category_override.
 *   (Per the Handbook "two-place rule": new source = one paste + one
 *   AWARD_SOURCES entry in schema.ts. Nothing else.)
 *
 * TWO FUNCTIONS
 *   makeRestaurantImportTemplate()  creates a blank "Restaurant List Import"
 *                                   tab with the right columns + a dropdown.
 *   ingestRestaurantLists()         reads ALL tabs whose name starts with
 *                                   "Restaurant List Import", de-dupes against
 *                                   "Restaurant Awards", and appends new rows
 *                                   to it. Then you run reshape.
 *
 * WORKFLOW
 *   1. Run makeRestaurantImportTemplate() once.
 *   2. Paste a list: source_slug, year, rank, name, city, country,
 *      [category_override], [cuisine], [price_band].
 *   3. Run ingestRestaurantLists().      <-- fills "Restaurant Awards"
 *   4. Run reshapeCompassEats().         <-- folds it into venues
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
  'james-beard', 'oad', 'gault-millau', 'tabelog', 'forbes-travel-guide'
];

// Column shape of the "Restaurant Awards" tab (reshape's parser reads these positions)
var RESTAURANT_AWARDS_HEADERS =
  ['source_slug', 'year', 'rank', 'name', 'city', 'country',
   'category_override', 'cuisine', 'price_band'];

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
  if (SOURCE_ALIASES_R[norm]) return SOURCE_ALIASES_R[norm];     // display name
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
    'category_override', 'cuisine', 'price_band'];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
  sheet.setFrozenRows(1);

  var rule = SpreadsheetApp.newDataValidation()
    .requireValueInList(VALID_RESTAURANT_SLUGS, true)
    .setAllowInvalid(false)
    .setHelpText('Pick a valid restaurant source slug.')
    .build();
  sheet.getRange(2, 1, 2000, 1).setDataValidation(rule);

  var examples = [
    ['asia-50-best-restaurants', 2026, 1, 'Gaggan Anand', 'Bangkok', 'Thailand', '', 'Progressive Indian', '$$$$'],
    ['best-chef-awards', 2025, '', 'Disfrutar', 'Barcelona', 'Spain', '3 Knives', 'Modernist', '$$$$'],
    ['michelin', 2025, '', 'Le Bernardin', 'New York', 'United States', 'Three Stars', 'Seafood', '$$$$'],
    ['la-liste', 2026, '', 'Guy Savoy', 'Paris', 'France', '99.5/100', 'French', '$$$$']
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
    'price_band: e.g. $$$ -> venues.price_tier';
  sheet.getRange('A1').setNote(note);
  sheet.setColumnWidth(4, 220);
  sheet.setColumnWidth(7, 160);

  SpreadsheetApp.getUi().alert(
    'Created "' + name + '".\n\n' +
    'Grey example rows show the format — knives / stars / scores go in ' +
    'category_override, NOT their own column. Delete the examples, paste your ' +
    'real list, then run ingestRestaurantLists.\n\n' +
    'Your compiled 6-column files paste straight in; leave the extra columns blank.\n\n' +
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
  // Signature = source_slug | year | normalized(name)
  var existing = {};
  var av = awardsSheet.getDataRange().getValues();
  for (var ar = 1; ar < av.length; ar++) {
    var arow = av[ar];
    if (!arow || arow.join('') === '') continue;
    var asig = String(arow[0]).trim() + '|' + (Number(arow[1]) || '') + '|' +
               normKeyR_(arow[3]) + '|' + normKeyR_(String(arow[4] || ''));
    existing[asig] = true;
  }

  var added = 0, skippedDup = 0, bad = 0, blank = 0;
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

      var sig = src + '|' + year + '|' + normKeyR_(name) + '|' + normKeyR_(city);
      if (existing[sig]) { skippedDup++; continue; }
      existing[sig] = true; // guard against dups within this same run

      newRows.push([src, year, rank, name, city, country,
                    catOverride, cuisine, priceBand]);
      added++;
    }
  }

  if (newRows.length) {
    var last = awardsSheet.getLastRow();
    awardsSheet.getRange(last + 1, 1, newRows.length, RESTAURANT_AWARDS_HEADERS.length)
      .setValues(newRows);
  }

  var msg =
    'Restaurant ingestion complete (v2 — writes to "Restaurant Awards").\n' +
    'award rows added to "Restaurant Awards": ' + added + '\n' +
    'duplicate rows skipped:                  ' + skippedDup + '\n' +
    'invalid source_slug rows skipped:        ' + bad + '\n' +
    'blank/partial rows skipped:              ' + blank + '\n\n' +
    'NEXT: run reshapeCompassEats to fold these into the venues tab.';
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
