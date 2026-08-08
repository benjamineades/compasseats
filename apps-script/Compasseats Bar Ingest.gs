/**
 * CompassEats — Bar List Ingestion (Google Apps Script) v4
 * =========================================================
 * CHANGED IN v2 (June 3, 2026):
 *   Bar ingest NO LONGER writes into the "venues" tab. Reshape rebuilds
 *   "venues" from scratch on every run and was wiping every bar this tool
 *   added. Instead, ingest folds your pasted bar lists into a single
 *   "Bar Awards" tab — which reshape reads as a normal award source.
 *
 * ADDED July 1, 2026:
 *   fixBarImportDropdown() — one-time repair tool. Re-applies the source_slug
 *   dropdown across the WHOLE "Bar List Import" tab using the current
 *   VALID_BAR_SLUGS list, without touching any pasted data. Run this any time
 *   VALID_BAR_SLUGS changes and the tab already existed — the dropdown only
 *   gets set at tab creation time otherwise, so it goes stale.
 *
 * FIXED July 7, 2026:
 *   Removed a duplicate copy of this entire file's variables and functions
 *   that had been appended below the originals. JS keeps the LAST declaration
 *   of a var/function, so the second (stale) copy of VALID_BAR_SLUGS was
 *   silently overriding the first and had dropped europe-50-best-bars /
 *   europe-50-best-bars-51-100 from the valid list. Also added top-500-bars.
 *
 *   SEPARATE BUG FIXED SAME DAY: the dedupe signature was
 *   source_slug|year|name — no city. Any two venues sharing a brand name in
 *   the same source+year (chain branches like "Punch Room at Edition" in five
 *   different cities, or "Salmon Guru" in three) collided and all but the
 *   first were silently dropped as "duplicates." A real run on Top 500 Bars
 *   lost exactly 20 branch venues this way before the fix.
 *
 * ADDED IN v3 (August 4, 2026) — standing price-capture rule:
 *   price_symbol_raw, price_source_url. Capture the source's own price text
 *   exactly as displayed, plus the URL. Provenance only.
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
 *   either source 64%. It fails worst exactly where CompassEats is strongest.
 *
 *   Bars matter here specifically. They are CompassEats' deliberate wedge,
 *   and they are typically smaller and newer than starred restaurants, so
 *   open datasets know them less well. Capturing the address at ingest, from
 *   the list you are already reading, is by far the cheapest fix.
 *
 *   WHAT TO PUT IN THEM
 *     address_raw    — the street address EXACTLY as the source printed it.
 *                      Do not reformat, translate, or strip the floor,
 *                      building or ward.
 *     coords_raw     — latitude and longitude if the source publishes them,
 *                      as "lat, lng" in one cell, e.g. "22.281463, 114.158670".
 *                      Blank if the source doesn't show them.
 *     geo_source_url — the exact page you read the address off.
 *
 *   WHAT NOT TO DO
 *     Do not paste coordinates from Google Maps, or from any geocoder, into
 *     coords_raw. This column means "the award source published this."
 *     Mixing in other sources destroys the provenance that makes the column
 *     worth having, and in Google's case reintroduces the exact problem being
 *     removed. Blank is a perfectly good answer.
 *
 *   These three columns do NOT feed venues.lat / venues.lng yet. That is a
 *   separate, deliberate step in the wider re-architecture. This is capture
 *   only, so the backfill problem stops growing while the rest is designed.
 *   Appended at the very END of the column list on purpose — reshape's parser
 *   reads Bar Awards by column position, so nothing in production shifts.
 *
 * TWO FUNCTIONS
 *   makeBarImportTemplate()  creates a blank "Bar List Import" tab with the
 *                            right columns + a dropdown of valid sources.
 *   ingestBarLists()         reads ALL tabs whose name starts with
 *                            "Bar List Import", de-dupes against "Bar Awards",
 *                            and appends new award rows to it.
 *
 * WORKFLOW
 *   1. Run makeBarImportTemplate() once (skip if the tab already exists).
 *   2. Find a published list (e.g. North America's 50 Best Bars 51-100).
 *   3. Paste rows: source_slug, year, rank, name, city, country,
 *      category_override, [price_symbol_raw], [price_source_url],
 *      [address_raw], [coords_raw], [geo_source_url].
 *   4. Run ingestBarLists().        <-- fills "Bar Awards"
 *   5. Run reshapeCompassEats().    <-- folds Bar Awards into venues
 *
 * ONE-TIME MANUAL STEP (do this before running v4 for the first time):
 *   Your live "Bar Awards" tab already exists, so the "create tab with
 *   headers" branch below won't fire for it. Add three headers by hand:
 *     cell J1 = address_raw
 *     cell K1 = coords_raw
 *     cell L1 = geo_source_url
 *   (H1 and I1 should already hold price_symbol_raw and price_source_url from
 *   the v3 step. If they don't, add those first.)
 *
 * VALID SOURCE SLUGS (must match schema.ts AWARD_SOURCES and reshape):
 *   worlds-50-best-bars, worlds-50-best-bars-51-100,
 *   north-america-50-best-bars, north-america-50-best-bars-51-100,
 *   asia-50-best-bars, asia-50-best-bars-51-100,
 *   pinnacle-guide, spirited-awards, james-beard,
 *   europe-50-best-bars, europe-50-best-bars-51-100,
 *   top-500-bars
 */

var IMPORT_PREFIX = 'Bar List Import';
var BAR_AWARDS_TAB = 'Bar Awards';

var VALID_BAR_SLUGS = [
  'worlds-50-best-bars', 'worlds-50-best-bars-51-100',
  'north-america-50-best-bars', 'north-america-50-best-bars-51-100',
  'asia-50-best-bars', 'asia-50-best-bars-51-100',
  'pinnacle-guide', 'spirited-awards', 'james-beard',
  'europe-50-best-bars', 'europe-50-best-bars-51-100',
  'top-500-bars'
];

// SOURCE ALIAS MAP — lets compiled files with display names paste in AS-IS.
var SOURCE_ALIASES_B = {
  "asia's 50 best bars": 'asia-50-best-bars',
  "asia's 50 best bars 51-100": 'asia-50-best-bars-51-100',
  "north america's 50 best bars": 'north-america-50-best-bars',
  "north america's 50 best bars 51-100": 'north-america-50-best-bars-51-100',
  "europe's 50 best bars": 'europe-50-best-bars',
  "europe's 50 best bars 51-100": 'europe-50-best-bars-51-100',
  "world's 50 best bars": 'worlds-50-best-bars',
  "worlds 50 best bars": 'worlds-50-best-bars',
  "world's 50 best bars 51-100": 'worlds-50-best-bars-51-100',
  "spirited awards": 'spirited-awards',
  "the pinnacle guide": 'pinnacle-guide',
  "pinnacle guide": 'pinnacle-guide',
  "james beard awards": 'james-beard',
  "top 500 bars": 'top-500-bars',
  "top500 bars": 'top-500-bars'
};

function normSourceB_(s) {
  if (!s) return '';
  var t = String(s).toLowerCase();
  t = t.replace(/['\u2018\u2019\u02BC`]/g, '');
  t = t.replace(/&/g, ' and ');
  t = t.replace(/[^a-z0-9]+/g, ' ');
  return t.replace(/\s+/g, ' ').trim();
}

function resolveSourceB_(raw) {
  var s = String(raw || '').trim();
  if (!s) return '';
  if (VALID_BAR_SLUGS.indexOf(s) >= 0) return s;  // already a slug
  var norm = normSourceB_(s);
  if (!resolveSourceB_._normMap) {
    resolveSourceB_._normMap = {};
    for (var key in SOURCE_ALIASES_B) {
      if (SOURCE_ALIASES_B.hasOwnProperty(key)) {
        resolveSourceB_._normMap[normSourceB_(key)] = SOURCE_ALIASES_B[key];
      }
    }
  }
  if (resolveSourceB_._normMap[norm]) return resolveSourceB_._normMap[norm];
  for (var k = 0; k < VALID_BAR_SLUGS.length; k++) {
    if (normSourceB_(VALID_BAR_SLUGS[k]) === norm) return VALID_BAR_SLUGS[k];
  }
  return '';
}

// Column shape of the "Bar Awards" tab (reshape's parser reads these positions)
var BAR_AWARDS_HEADERS =
  ['source_slug', 'year', 'rank', 'name', 'city', 'country', 'category_override',
   'price_symbol_raw', 'price_source_url',
   'address_raw', 'coords_raw', 'geo_source_url'];

// ---------------------------------------------------------------------------
function makeBarImportTemplate() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var name = IMPORT_PREFIX;
  var sheet = ss.getSheetByName(name);
  if (sheet) {
    SpreadsheetApp.getUi().alert('"' + name + '" already exists. Paste into it, ' +
      'or duplicate it as "' + name + ' 2" for a second list.');
    return;
  }
  sheet = ss.insertSheet(name);
  var headers = ['source_slug', 'year', 'rank', 'name', 'city', 'country',
    'category_override', 'price_symbol_raw', 'price_source_url',
    'address_raw', 'coords_raw', 'geo_source_url'];
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
  sheet.setFrozenRows(1);

  // Source dropdown
  var rule = SpreadsheetApp.newDataValidation()
    .requireValueInList(VALID_BAR_SLUGS, true)
    .setAllowInvalid(false)
    .setHelpText('Pick a valid bar source slug.')
    .build();
  sheet.getRange(2, 1, 1000, 1).setDataValidation(rule);

  // Example rows (delete before importing your real data)
  var examples = [
    ['north-america-50-best-bars', 2026, 1, 'Sip & Guzzle', 'New York',
     'United States', '', '', '', '', '', ''],
    ['north-america-50-best-bars', 2026, 2, 'Handshake Speakeasy', 'Mexico City',
     'Mexico', '', '', '', '', '', ''],
    ['worlds-50-best-bars-51-100', 2025, 54, 'Bar Mauro', 'Mexico City',
     'Mexico', '', '', '', 'Calle Example 123, Roma Norte, 06700',
     '19.419444, -99.161944', 'https://www.theworlds50best.com/bars/...']
  ];
  sheet.getRange(2, 1, examples.length, headers.length).setValues(examples)
    .setFontColor('#999999').setFontStyle('italic');

  // Notes
  var note =
    'source_slug: pick from dropdown\n' +
    'year: award year (e.g. 2026)\n' +
    'rank: numeric rank (blank if unranked award)\n' +
    'name/city/country: the venue\n' +
    'category_override: optional — leave blank to auto-build "No. {rank}"\n\n' +
    'OPTIONAL price capture (blank is fine):\n' +
    'price_symbol_raw: the price EXACTLY as the source displayed it\n' +
    '   e.g. "$$", "£30 avg cocktail". Do not normalize it yourself.\n' +
    'price_source_url: the exact page you saw that price on\n\n' +
    'OPTIONAL geo capture (NEW — please fill these in whenever the source\n' +
    'shows them, it saves a great deal of work later):\n' +
    'address_raw: the street address EXACTLY as printed. Keep the floor,\n' +
    '   building and ward. Do not reformat or translate.\n' +
    'coords_raw: "lat, lng" in one cell if the source publishes coordinates.\n' +
    '   ONLY from the award source itself — never from Google Maps or any\n' +
    '   other geocoder. Blank is fine.\n' +
    'geo_source_url: the page you read the address off';
  sheet.getRange('A1').setNote(note);
  sheet.setColumnWidth(4, 220);
  sheet.setColumnWidth(9, 260);
  sheet.setColumnWidth(10, 320);
  sheet.setColumnWidth(12, 260);

  SpreadsheetApp.getUi().alert(
    'Created "' + name + '".\n\n' +
    'Grey example rows show the format — delete them, paste your real list, ' +
    'then run ingestBarLists.\n\n' +
    'NEW in v4: address_raw / coords_raw / geo_source_url. Fill these in ' +
    'whenever the award source shows an address. Coordinates ONLY if the ' +
    'source itself publishes them, never from Google Maps.\n\n' +
    'For multiple lists, duplicate this tab as "' + name + ' 2", etc.');
}

// ---------------------------------------------------------------------------
// ONE-TIME REPAIR: re-applies the dropdown to the WHOLE column using the
// current VALID_BAR_SLUGS list, without touching any pasted values. Safe to
// run any time — it never deletes or changes cell contents, only the dropdown
// menu attached to the column.
// ---------------------------------------------------------------------------
function fixBarImportDropdown() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(IMPORT_PREFIX);
  if (!sheet) {
    SpreadsheetApp.getUi().alert('No "' + IMPORT_PREFIX + '" tab found — nothing to fix.');
    return;
  }
  var rule = SpreadsheetApp.newDataValidation()
    .requireValueInList(VALID_BAR_SLUGS, true)
    .setAllowInvalid(false)
    .setHelpText('Pick a valid bar source slug.')
    .build();
  var lastRow = Math.max(sheet.getLastRow(), 1000);
  sheet.getRange(2, 1, lastRow - 1, 1).setDataValidation(rule);
  SpreadsheetApp.getUi().alert(
    'Dropdown refreshed on "' + IMPORT_PREFIX + '", rows 2–' + lastRow + '.\n\n' +
    'Your pasted data was not touched — only the dropdown menu was updated.\n' +
    'It now includes all ' + VALID_BAR_SLUGS.length + ' current sources: ' +
    VALID_BAR_SLUGS.join(', '));
}

// ---------------------------------------------------------------------------
function ingestBarLists() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  // Gather import tabs
  var importSheets = ss.getSheets().filter(function (s) {
    return s.getName().indexOf(IMPORT_PREFIX) === 0;
  });
  if (!importSheets.length) {
    throw new Error('No "' + IMPORT_PREFIX + '" tab. Run makeBarImportTemplate first.');
  }

  // Ensure the Bar Awards tab exists with headers
  var awardsSheet = ss.getSheetByName(BAR_AWARDS_TAB);
  if (!awardsSheet) {
    awardsSheet = ss.insertSheet(BAR_AWARDS_TAB);
    awardsSheet.getRange(1, 1, 1, BAR_AWARDS_HEADERS.length)
      .setValues([BAR_AWARDS_HEADERS]).setFontWeight('bold');
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
      normKey2_(arow[3]) + '|' + normKey2_(arow[4]);
    existing[asig] = true;
  }

  var added = 0, skippedDup = 0, bad = 0, blank = 0, withGeo = 0, withCoords = 0;
  var newRows = [];

  for (var si = 0; si < importSheets.length; si++) {
    var rows = importSheets[si].getDataRange().getValues();
    for (var ri = 1; ri < rows.length; ri++) {
      var row = rows[ri];
      var src = resolveSourceB_(row[0]);
      var name = String(row[3] || '').trim();

      if (!src && !name) { blank++; continue; }
      if (!src || !name) { blank++; continue; }
      if (VALID_BAR_SLUGS.indexOf(src) < 0) { bad++; continue; }

      var year = Number(row[1]) || 2025;
      var rank = row[2] === '' ? '' : (Number(row[2]) || '');
      var city = String(row[4] || '').trim();
      var country = String(row[5] || '').trim();
      var catOverride = String(row[6] || '').trim();
      var priceSymbolRaw = String(row[7] || '').trim();
      var priceSourceUrl = String(row[8] || '').trim();
      var addressRaw = String(row[9] || '').trim();
      var coordsRaw = String(row[10] || '').trim();
      var geoSourceUrl = String(row[11] || '').trim();

      var sig = src + '|' + year + '|' + normKey2_(name) + '|' + normKey2_(city);
      if (existing[sig]) { skippedDup++; continue; }
      existing[sig] = true; // guard against dups within this same run

      if (addressRaw) withGeo++;
      if (coordsRaw) withCoords++;

      newRows.push([src, year, rank, name, city, country, catOverride,
                    priceSymbolRaw, priceSourceUrl,
                    addressRaw, coordsRaw, geoSourceUrl]);
      added++;
    }
  }

  if (newRows.length) {
    var last = awardsSheet.getLastRow();
    awardsSheet.getRange(last + 1, 1, newRows.length, BAR_AWARDS_HEADERS.length)
      .setValues(newRows);
  }

  var msg =
    'Bar ingestion complete (v4 — writes to "Bar Awards").\n' +
    'award rows added to "Bar Awards": ' + added + '\n' +
    'duplicate rows skipped: ' + skippedDup + '\n' +
    'invalid source_slug rows skipped: ' + bad + '\n' +
    'blank/partial rows skipped: ' + blank + '\n\n' +
    'GEO CAPTURE (new in v4)\n' +
    '  rows carrying a street address:   ' + withGeo + ' of ' + added + '\n' +
    '  rows carrying source coordinates: ' + withCoords + ' of ' + added + '\n' +
    (added > 0 && withGeo === 0
      ? '  NOTE: no addresses captured this run. If the source publishes them,\n' +
        '  going back for them later is far more work than doing it now.\n'
      : '') +
    '\nNEXT: run reshapeCompassEats to fold these into the venues tab.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// ---- helpers ----------------------------------------------------------
function normKey2_(name) {
  if (!name) return '';
  var s = String(name).normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  s = s.replace(/['\u2018\u2019\u02BC`]/g, '');
  s = s.replace(/&/g, ' and ');
  s = s.replace(/[^a-z0-9]+/g, ' ');
  return s.replace(/\s+/g, ' ').trim();
}
