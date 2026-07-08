/**
 * CompassEats — Bar List Ingestion (Google Apps Script) v2
 * =========================================================
 * CHANGED IN v2 (June 3, 2026):
 *   Bar ingest NO LONGER writes into the "venues" tab. Reshape rebuilds
 *   "venues" from scratch on every run and was wiping every bar this tool
 *   added. Instead, ingest now folds your pasted bar lists into a single
 *   "Bar Awards" tab — which reshape reads as a normal award source (just
 *   like Michelin, OAD, etc.). Bars now survive reshape and get the same
 *   name -> "Places Enrichment" geo matching as every other venue.
 *
 * ADDED July 1, 2026:
 *   fixBarImportDropdown() — one-time repair tool. Re-applies the source_slug
 *   dropdown across the WHOLE "Bar List Import" tab using the current
 *   VALID_BAR_SLUGS list, without touching any pasted data. Run this any
 *   time VALID_BAR_SLUGS changes (like when Europe's 50 Best Bars was added)
 *   and the tab already existed — the dropdown only gets set at tab
 *   creation time otherwise, so it goes stale.
 *
 * FIXED July 7, 2026:
 *   Removed a duplicate copy of this entire file's variables and functions
 *   that had been appended below the originals. JS keeps the LAST
 *   declaration of a var/function, so the second (stale) copy of
 *   VALID_BAR_SLUGS was silently overriding the first and had dropped
 *   europe-50-best-bars / europe-50-best-bars-51-100 from the valid list —
 *   those two would have failed to ingest. Also added top-500-bars.
 *
 *   SEPARATE BUG FIXED SAME DAY: the dedupe signature was
 *   source_slug|year|name — no city. Any two venues sharing a brand name in
 *   the same source+year (chain branches like "Punch Room at Edition" in
 *   five different cities, or "Salmon Guru" in three) collided and all but
 *   the first were silently dropped as "duplicates." The restaurant tool
 *   already included city in its signature; this brings the bar tool in
 *   line with it. A real run on Top 500 Bars lost exactly 20 branch venues
 *   this way before the fix (source_slug: top-500-bars, years 2024/2025).
 *
 * TWO FUNCTIONS
 *   makeBarImportTemplate()  creates a blank "Bar List Import" tab with the
 *                            right columns + a dropdown of valid sources.
 *   ingestBarLists()         reads ALL tabs whose name starts with
 *                            "Bar List Import", de-dupes against the
 *                            "Bar Awards" tab, and appends new award rows
 *                            to "Bar Awards". Then you run reshape.
 *
 * WORKFLOW
 *   1. Run makeBarImportTemplate() once (skip if the tab already exists).
 *   2. Find a published list (e.g. North America's 50 Best Bars 51-100).
 *   3. Paste rows into the template: source_slug, year, rank, name, city,
 *      country, category_override. One row per bar per year.
 *   4. Run ingestBarLists().        <-- fills "Bar Awards"
 *   5. Run reshapeCompassEats().    <-- folds Bar Awards into venues
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
// ONE-TIME REPAIR: re-applies the dropdown to the WHOLE column using the
// current VALID_BAR_SLUGS list, without touching any pasted values. Safe to
// run any time — it never deletes or changes cell contents, only the
// dropdown menu attached to the column.
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

  var added = 0, skippedDup = 0, bad = 0, blank = 0;
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

      var sig = src + '|' + year + '|' + normKey2_(name) + '|' + normKey2_(city);
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
    'duplicate rows skipped: ' + skippedDup + '\n' +
    'invalid source_slug rows skipped: ' + bad + '\n' +
    'blank/partial rows skipped: ' + blank + '\n\n' +
    'NEXT: run reshapeCompassEats to fold these into the venues tab.';
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
