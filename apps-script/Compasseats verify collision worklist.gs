/**
 * CompassEats — Collision Worklist Dry-Run Verifier
 * ---------------------------------------------------
 * READ-ONLY. This script does not change, delete, or move any data.
 * It only CREATES A NEW REPORT TAB. Your venues, awards tabs, and the
 * collision worklist tab are never touched.
 *
 * WHAT IT DOES
 * For every row in your imported collision worklist where the fill-in
 * column says REMOVE or REPIN, this checks all the raw award-source
 * tabs (Michelin Guide, Worlds 50 Best, Best Chef Awards, OAD, etc.)
 * to see if a real listing actually exists at the "wrong" city.
 *
 * If it finds one, that row gets flagged — it likely means the
 * "phantom" venue is actually a real, separate restaurant/bar that
 * happens to share a name, and the REMOVE/REPIN decision for that row
 * needs a second look before anything is applied live.
 *
 * If it finds nothing, the original decision is more likely safe —
 * but should still get a quick human glance before you delete or
 * repin anything for real.
 *
 * HOW TO RUN IT
 * 1. In your Google Sheet: Extensions → Apps Script
 * 2. Create a new file (or paste into an existing blank one) and
 *    paste this whole thing in.
 * 3. In the toolbar dropdown, select "dryRunVerifyCollisionWorklist"
 * 4. Click Run (▶). First run will ask you to authorize — that's
 *    normal, it's your own script on your own sheet.
 * 5. It may take 1–3 minutes (it's reading a lot of tabs). When done,
 *    a popup will tell you how many rows it checked and flagged.
 * 6. Look at the new tab it created, named something like
 *    "Verify-Report-2026-07-15". Sort by the "flag" column to see
 *    the flagged rows first.
 */

// ---- Which raw tabs to check, and which columns hold the name/city ----
var SOURCE_TABS = [
  { name: 'Michelin Guide',            nameCol: 'Name', cityCol: 'Location', combined: true },
  { name: 'Worlds 50 Best',            nameCol: 'Name', cityCol: 'City' },
  { name: 'Best Chef Awards',          nameCol: 'Name', cityCol: 'Location', combined: true },
  { name: 'James Beard Awards',        nameCol: 'Name', cityCol: 'City' },
  { name: 'Pinnacle Guide',            nameCol: 'Name', cityCol: 'City' },
  { name: 'Spirited Awards',           nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD North America 2026',    nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD South America 2026',    nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD Asia 2025',             nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD Europe 2025',           nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD Japan 2025',            nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD North America 2025',    nameCol: 'Name', cityCol: 'City' },
  { name: 'OAD South America 2025',    nameCol: 'Name', cityCol: 'City' },
  { name: '101 Best Steakhouses 2026', nameCol: 'Name', cityCol: 'City' },
  { name: '101 Best Steakhouses 2025', nameCol: 'Name', cityCol: 'Location', combined: true },
  { name: 'Restaurant Awards',         nameCol: 'name', cityCol: 'city' },
  { name: 'Bar Awards',                nameCol: 'name', cityCol: 'city' }
];

// Short/generic words we ignore when matching, so "Restaurant" or "Hotel"
// alone never counts as a match.
var STOPWORDS = {
  'restaurant': 1, 'ristorante': 1, 'restaurante': 1, 'hotel': 1,
  'the': 1, 'by': 1, 'de': 1, 'la': 1, 'le': 1, 'el': 1, 'grand': 1,
  'and': 1, 'guide': 1
};

function normText_(s) {
  return String(s || '')
    .toLowerCase()
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

function meaningfulTokens_(s) {
  var words = normText_(s).split(' ');
  var out = [];
  for (var i = 0; i < words.length; i++) {
    var w = words[i];
    if (w.length >= 4 && !STOPWORDS[w]) out.push(w);
  }
  return out;
}

function findWorklistSheet_(ss) {
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    var sh = sheets[i];
    var lastCol = sh.getLastColumn();
    if (lastCol < 5) continue;
    var header = sh.getRange(1, 1, 1, lastCol).getValues()[0].map(String);
    if (header.indexOf('pin_id') !== -1 &&
        header.indexOf('role') !== -1 &&
        header.indexOf('ACTION (fill: KEEP/REMOVE/REPIN)') !== -1) {
      return sh;
    }
  }
  throw new Error('Could not find the collision worklist tab (looking for headers pin_id / role / ACTION).');
}

// Builds a token -> [ {rawName, city, tab} ] index across all raw source tabs.
function buildSourceIndex_(ss) {
  var tokenIndex = {};
  var missingTabs = [];

  SOURCE_TABS.forEach(function (cfg) {
    var sh = ss.getSheetByName(cfg.name);
    if (!sh) { missingTabs.push(cfg.name); return; }
    var lastRow = sh.getLastRow();
    var lastCol = sh.getLastColumn();
    if (lastRow < 2) return;
    var header = sh.getRange(1, 1, 1, lastCol).getValues()[0];
    var nameIdx = header.indexOf(cfg.nameCol);
    var cityIdx = header.indexOf(cfg.cityCol);
    if (nameIdx === -1 || cityIdx === -1) { missingTabs.push(cfg.name + ' (columns not found)'); return; }

    var data = sh.getRange(2, 1, lastRow - 1, lastCol).getValues();
    data.forEach(function (row) {
      var rawName = row[nameIdx];
      if (!rawName) return;
      var city = row[cityIdx];
      if (cfg.combined && city) city = String(city).split(',')[0];
      if (!city) return;

      var entry = { rawName: rawName, city: city, tab: cfg.name };
      var toks = meaningfulTokens_(rawName);
      toks.forEach(function (t) {
        if (!tokenIndex[t]) tokenIndex[t] = [];
        tokenIndex[t].push(entry);
      });
    });
  });

  if (missingTabs.length) {
    Logger.log('Tabs skipped (not found or missing expected columns): ' + missingTabs.join(', '));
  }
  return tokenIndex;
}

function dryRunVerifyCollisionWorklist() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var worklist = findWorklistSheet_(ss);
  var lastRow = worklist.getLastRow();
  var lastCol = worklist.getLastColumn();
  var header = worklist.getRange(1, 1, 1, lastCol).getValues()[0];

  var col = {};
  header.forEach(function (h, i) { col[h] = i; });

  var data = worklist.getRange(2, 1, lastRow - 1, lastCol).getValues();
  var tokenIndex = buildSourceIndex_(ss);

  var outName = 'Verify-Report-' + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyy-MM-dd-HHmm');
  var existing = ss.getSheetByName(outName);
  if (existing) ss.deleteSheet(existing);
  var out = ss.insertSheet(outName);
  out.appendRow(['row_index', 'name', 'city_display', 'ACTION', 'FOLD', 'flag', 'matched_raw_name', 'matched_raw_city', 'matched_tab']);

  var checked = 0, flagged = 0;

  data.forEach(function (row, i) {
    var action = row[col['ACTION (fill: KEEP/REMOVE/REPIN)']];
    if (action !== 'REMOVE' && action !== 'REPIN') return;
    var role = row[col['role']];
    if (role === 'HOME' || role === '(not-in-worklist)') return;

    checked++;
    var name = row[col['name']];
    var cityDisplay = row[col['city_display']];
    var fold = col['FOLD_AWARDS_TO_HOME (y/n)'] !== undefined ? row[col['FOLD_AWARDS_TO_HOME (y/n)']] : '';

    var toks = meaningfulTokens_(name);
    var candidates = [];
    toks.forEach(function (t) {
      if (tokenIndex[t]) candidates = candidates.concat(tokenIndex[t]);
    });

    var targetCity = normText_(cityDisplay);
    var match = null;
    for (var c = 0; c < candidates.length; c++) {
      if (normText_(candidates[c].city) === targetCity) { match = candidates[c]; break; }
    }

    var flag, matchInfo;
    if (match) {
      flag = '⚠️ REAL RAW ENTRY FOUND AT THIS CITY — do not remove/fold/repin blindly, re-check manually';
      matchInfo = [match.rawName, match.city, match.tab];
      flagged++;
    } else {
      flag = 'no raw match found — original decision looks OK, still worth a glance';
      matchInfo = ['', '', ''];
    }

    out.appendRow([i, name, cityDisplay, action, fold, flag].concat(matchInfo));
  });

  out.autoResizeColumns(1, 9);
  Logger.log('Checked ' + checked + ' rows. Flagged ' + flagged + ' as possible real venues.');
  SpreadsheetApp.getUi().alert(
    'Dry-run complete.\n\nChecked: ' + checked + ' rows\nFlagged for re-review: ' + flagged + '\n\nSee tab: ' + outName
  );
}
