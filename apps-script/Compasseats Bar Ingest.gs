/**
 * CompassEats — Bar List Ingestion (Google Apps Script)  v2
 * =========================================================
 * CHANGED IN v2 (June 3, 2026):
 *   Bar ingest NO LONGER writes into the "venues" tab. Reshape rebuilds
 *   "venues" from scratch on every run and was wiping every bar this tool
 *   added. Instead, ingest now folds your pasted bar lists into a single
 *   "Bar Awards" tab — which reshape reads as a normal award source (just
 *   like Michelin, OAD, etc.). Bars now survive reshape and get the same
 *   name -> "Places Enrichment" geo matching as every other venue.
 *
 * TWO FUNCTIONS
 *   makeBarImportTemplate()   creates a blank "Bar List Import" tab with the
 *                             right columns + a dropdown of valid sources.
 *   ingestBarLists()          reads ALL tabs whose name starts with
 *                             "Bar List Import", de-dupes against the
 *                             "Bar Awards" tab, and appends new award rows
 *                             to "Bar Awards". Then you run reshape.
 *
 * WORKFLOW
 *   1. Run makeBarImportTemplate() once (skip if the tab already exists).
 *   2. Find a published list (e.g. North America's 50 Best Bars 51-100).
 *   3. Paste rows into the template: source_slug, year, rank, name, city,
 *      country, category_override. One row per bar per year.
 *   4. Run ingestBarLists().            <-- fills "Bar Awards"
 *   5. Run reshapeCompassEats().        <-- folds Bar Awards into venues
 *
 * VALID SOURCE SLUGS (must match schema.ts AWARD_SOURCES and reshape):
 *   worlds-50-best-bars, worlds-50-best-bars-51-100,
 *   north-america-50-best-bars, north-america-50-best-bars-51-100,
 *   asia-50-best-bars, asia-50-best-bars-51-100,
 *   pinnacle-guide, spirited-awards
 */

var IMPORT_PREFIX = 'Bar List Import';
var BAR_AWARDS_TAB = 'Bar Awards';

var VALID_BAR_SLUGS = [
  'worlds-50-best-bars', 'worlds-50-best-bars-51-100',
  'north-america-50-best-bars', 'north-america-50-best-bars-51-100',
  'asia-50-best-bars', 'asia-50-best-bars-51-100',
  'pinnacle-guide', 'spirited-awards', 'james-beard'
];

// Column shape of the "Bar Awards" tab (reshape's parser reads these positions)
var BAR_AWARDS_HEADERS =
  ['source_slug', 'year', 'rank', 'name', 'city', 'country', 'category_override'];

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
  var headers = ['source_slug', 'year', 'rank', 'name', 'city', 'country', 'category_override'];
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
    ['north-america-50-best-bars', 2026, 1, 'Sip & Guzzle', 'New York', 'United States', ''],
    ['north-america-50-best-bars', 2026, 2, 'Handshake Speakeasy', 'Mexico City', 'Mexico', ''],
    ['worlds-50-best-bars-51-100', 2025, 54, 'Bar Mauro', 'Mexico City', 'Mexico', '']
  ];
  sheet.getRange(2, 1, examples.length, headers.length).setValues(examples)
    .setFontColor('#999999').setFontStyle('italic');

  // Notes
  var note =
    'source_slug: pick from dropdown\n' +
    'year: award year (e.g. 2026)\n' +
    'rank: numeric rank (blank if unranked award)\n' +
    'name/city/country: the venue\n' +
    'category_override: optional — leave blank to auto-build "No. {rank}"';
  sheet.getRange('A1').setNote(note);
  sheet.setColumnWidth(4, 220);

  SpreadsheetApp.getUi().alert(
    'Created "' + name + '".\n\n' +
    'Grey example rows show the format — delete them, paste your real list, ' +
    'then run ingestBarLists.\n\n' +
    'For multiple lists, duplicate this tab as "' + name + ' 2", etc.');
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
  // Signature = source_slug | year | normalized(name)
  var existing = {};
  var av = awardsSheet.getDataRange().getValues();
  for (var ar = 1; ar < av.length; ar++) {
    var arow = av[ar];
    if (!arow || arow.join('') === '') continue;
    var asig = String(arow[0]).trim() + '|' + (Number(arow[1]) || '') + '|' +
               normKey2_(arow[3]);
    existing[asig] = true;
  }

  var added = 0, skippedDup = 0, bad = 0, blank = 0;
  var newRows = [];

  for (var si = 0; si < importSheets.length; si++) {
    var rows = importSheets[si].getDataRange().getValues();
    for (var ri = 1; ri < rows.length; ri++) {
      var row = rows[ri];
      var src = String(row[0] || '').trim();
      var name = String(row[3] || '').trim();
      if (!src && !name) { blank++; continue; }
      if (!src || !name) { blank++; continue; }
      if (VALID_BAR_SLUGS.indexOf(src) < 0) { bad++; continue; }

      var year = Number(row[1]) || 2025;
      var rank = row[2] === '' ? '' : (Number(row[2]) || '');
      var city = String(row[4] || '').trim();
      var country = String(row[5] || '').trim();
      var catOverride = String(row[6] || '').trim();

      var sig = src + '|' + year + '|' + normKey2_(name);
      if (existing[sig]) { skippedDup++; continue; }
      existing[sig] = true; // guard against dups within this same run

      newRows.push([src, year, rank, name, city, country, catOverride]);
      added++;
    }
  }

  if (newRows.length) {
    var last = awardsSheet.getLastRow();
    awardsSheet.getRange(last + 1, 1, newRows.length, BAR_AWARDS_HEADERS.length)
      .setValues(newRows);
  }

  var msg =
    'Bar ingestion complete (v2 — writes to "Bar Awards").\n' +
    'award rows added to "Bar Awards": ' + added + '\n' +
    'duplicate rows skipped:           ' + skippedDup + '\n' +
    'invalid source_slug rows skipped: ' + bad + '\n' +
    'blank/partial rows skipped:       ' + blank + '\n\n' +
    'NEXT: run reshapeCompassEats to fold these into the venues tab.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// ---- helpers (suffixed _2 to avoid collisions with other scripts) ---------

function normKey2_(name) {
  if (!name) return '';
  var s = String(name).normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  s = s.replace(/['\u2018\u2019\u02BC`]/g, '');
  s = s.replace(/&/g, ' and ');
  s = s.replace(/[^a-z0-9]+/g, ' ');
  return s.replace(/\s+/g, ' ').trim();
}
