/**
 * CompassEats — City-in-name RENAME cleanup
 * ------------------------------------------------------------------
 * Purpose: 46 venues have a wrong city baked into their display NAME
 *          (leftover from last session's REPIN fixes, which move the
 *          pin but never touch the name). This script cleans the name.
 *
 * It changes ONLY the 'name' column. It never touches slug, city,
 * lat/lng, awards, or anything else. Slugs are intentionally left
 * alone (they key the blurbs).
 *
 * TWO FUNCTIONS — same safety pattern as CompassEats-ApplyMasterFixes.gs:
 *   1) previewRenames()    -> READ-ONLY. Mutates nothing. Writes a
 *                             'RenamePreview-<time>' tab showing exactly
 *                             what WOULD change, plus anything it can't
 *                             match so you catch problems before applying.
 *   2) applyRenamesLive()  -> Actually renames. Gated behind the
 *                             CONFIRM_LIVE_RUN flag below. Will refuse to
 *                             run until you flip it to true.
 *
 * HOW TO USE:
 *   Step 1. Run previewRenames(). Read the preview tab.
 *   Step 2. Only if the preview looks right: set CONFIRM_LIVE_RUN = true
 *           (line below), save, then run applyRenamesLive().
 * ------------------------------------------------------------------
 */

var SHEET_ID   = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
var VENUES_TAB = 'venues';

// ----> Leave false for the dry run. Flip to true ONLY to apply. <----
var CONFIRM_LIVE_RUN = true;

// The approved 46-row worklist (generated directly from the reviewed CSV).
// Match is by (name + city); apply overwrites 'name' with 'proposed'.
var RENAMES = [
  {"name": "ARMANI/RISTORANTE PARIS", "city": "Dubai", "proposed": "ARMANI/RISTORANTE"},
  {"name": "Aulis London", "city": "Phang-Nga", "proposed": "Aulis"},
  {"name": "Beefbar Hong Kong", "city": "Monaco", "proposed": "Beefbar"},
  {"name": "Berenjak Dubai", "city": "London", "proposed": "Berenjak"},
  {"name": "Carbone New York", "city": "Las Vegas", "proposed": "Carbone"},
  {"name": "Carbone New York", "city": "Hong Kong", "proposed": "Carbone"},
  {"name": "GOAT Bangkok", "city": "Auckland", "proposed": "GOAT"},
  {"name": "Hutong New York", "city": "London", "proposed": "Hutong"},
  {"name": "Mott 32 Las Vegas", "city": "Toronto", "proposed": "Mott 32"},
  {"name": "Mott 32 Las Vegas", "city": "Hong Kong", "proposed": "Mott 32"},
  {"name": "Mott 32 Las Vegas", "city": "Vancouver", "proposed": "Mott 32"},
  {"name": "Nobu London (Old Park Lane)", "city": "New York", "proposed": "Nobu (Old Park Lane)"},
  {"name": "Sexy Fish Dubai", "city": "London", "proposed": "Sexy Fish"},
  {"name": "Sexy Fish Dubai", "city": "Manchester", "proposed": "Sexy Fish"},
  {"name": "Sexy Fish Dubai", "city": "Miami", "proposed": "Sexy Fish"},
  {"name": "Sushi Kanesaka Palace Hotel Tokyo", "city": "London", "proposed": "Sushi Kanesaka Palace Hotel"},
  {"name": "Sushi Kanesaka Palace Hotel Tokyo", "city": "Seoul", "proposed": "Sushi Kanesaka Palace Hotel"},
  {"name": "The Diplomat Hong Kong", "city": "Milwaukee", "proposed": "The Diplomat"},
  {"name": "Vetri Cucina Las Vegas", "city": "Philadelphia", "proposed": "Vetri Cucina"},
  {"name": "WAGYUMAFIA Hong Kong", "city": "Tokyo", "proposed": "WAGYUMAFIA"},
  {"name": "Yong Fu Hong Kong", "city": "Shanghai", "proposed": "Yong Fu"},
  {"name": "壽司芳 台北 Sushiyoshi Taipei", "city": "Hong Kong", "proposed": "壽司芳 台北 Sushiyoshi"},
  {"name": "ARMANI/RISTORANTE PARIS", "city": "New York", "proposed": "ARMANI/RISTORANTE"},
  {"name": "Dry Martini Barcelona", "city": "Sorrento", "proposed": "Dry Martini"},
  {"name": "ESPLANADE Saarbrücken", "city": "Desenzano del Garda", "proposed": "ESPLANADE"},
  {"name": "El Gato Negro Tapas Manchester", "city": "Vilnius", "proposed": "El Gato Negro Tapas"},
  {"name": "Flower Drum Restaurant Melbourne", "city": "Hong Kong", "proposed": "Flower Drum Restaurant"},
  {"name": "Ginza Sushi Ichi Singapore", "city": "Tokyo", "proposed": "Ginza Sushi Ichi"},
  {"name": "Harry's Piccolo Trieste", "city": "Porec", "proposed": "Harry's Piccolo"},
  {"name": "Hoppers Doha", "city": "London", "proposed": "Hoppers"},
  {"name": "Hoppers Doha", "city": "Tokyo", "proposed": "Hoppers"},
  {"name": "Jamavar Doha", "city": "Dubai", "proposed": "Jamavar"},
  {"name": "Jamavar Doha", "city": "London", "proposed": "Jamavar"},
  {"name": "Jamavar Doha", "city": "Bengaluru", "proposed": "Jamavar"},
  {"name": "Kaiten Sushi Ginza Onodera Kyoto", "city": "Tokyo", "proposed": "Kaiten Sushi Ginza Onodera"},
  {"name": "La Becasse Aachen", "city": "Osaka", "proposed": "La Becasse"},
  {"name": "L’Orangerie-restaurant Menton", "city": "Pornic", "proposed": "L’Orangerie-restaurant"},
  {"name": "L’Orangerie-restaurant Menton", "city": "Paris", "proposed": "L’Orangerie-restaurant"},
  {"name": "Restaurant Allium, Quimper", "city": "Penrith", "proposed": "Restaurant Allium"},
  {"name": "YOSHINO • NEW YORK", "city": "Tokyo", "proposed": "YOSHINO"},
  {"name": "estiatorio Milos Las Vegas", "city": "New York", "proposed": "estiatorio Milos"},
  {"name": "KEI Collection PARIS", "city": "Tokyo", "proposed": "KEI Collection"},
  {"name": "Morimoto Maui", "city": "Wailea", "proposed": "Morimoto"},
  {"name": "Morimoto Maui", "city": "Las Vegas", "proposed": "Morimoto"},
  {"name": "Morimoto Maui", "city": "Philadelphia", "proposed": "Morimoto"},
  {"name": "Kabuki Madrid", "city": "Milan", "proposed": "Kabuki"},
];

/** Carried forward verbatim from ApplyMasterFixes.gs — do not swap for plain string compare. */
function normalize_(s) {
  var str = String(s || '').trim().toLowerCase();
  str = str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  str = str.replace(/[\u2018\u2019\u02BC\u00B4\u0060]/g, "'");
  return str;
}

function loadVenues_() {
  var ss = SpreadsheetApp.openById(SHEET_ID);
  var sh = ss.getSheetByName(VENUES_TAB);
  if (!sh) throw new Error('Tab "' + VENUES_TAB + '" not found.');
  var values = sh.getDataRange().getValues();
  var header = values[0];
  var col = {};
  for (var c = 0; c < header.length; c++) col[String(header[c]).trim()] = c;
  ['name', 'city_display', 'slug'].forEach(function (k) {
    if (col[k] === undefined) throw new Error('Missing column: ' + k);
  });
  return { ss: ss, sh: sh, values: values, header: header, col: col };
}

/** Build the plan: for each rename row, find its venue row(s) and classify. */
function buildPlan_(v) {
  var col = v.col, rows = v.values;

  // index: normalized "name||city" -> [rowIndex,...]
  var idx = {};
  // per-city set of normalized names (to detect post-rename duplicates)
  var cityNames = {};
  for (var r = 1; r < rows.length; r++) {
    var nm = normalize_(rows[r][col['name']]);
    var ct = normalize_(rows[r][col['city_display']]);
    if (!nm) continue;
    (idx[nm + '||' + ct] = idx[nm + '||' + ct] || []).push(r);
    (cityNames[ct] = cityNames[ct] || {})[nm] = true;
  }

  var plan = [];
  for (var i = 0; i < RENAMES.length; i++) {
    var item = RENAMES[i];
    var key = normalize_(item.name) + '||' + normalize_(item.city);
    var hits = idx[key] || [];
    var status, note = '', rowNum = '', slug = '';

    if (hits.length === 0) {
      status = 'NO_MATCH';
      note = 'No row with this exact name+city in live sheet (already renamed? name drifted?)';
    } else if (hits.length > 1) {
      status = 'MULTI_MATCH';
      note = hits.length + ' rows share this name+city — skipped for safety, resolve by hand';
      rowNum = hits.map(function (x) { return x + 1; }).join(',');
    } else {
      var r0 = hits[0];
      rowNum = r0 + 1;
      slug = rows[r0][col['slug']];
      if (normalize_(rows[r0][col['name']]) === normalize_(item.proposed)) {
        status = 'NOOP';
        note = 'Name already matches proposed — nothing to do';
      } else {
        status = 'OK';
        var ct = normalize_(item.city);
        if (cityNames[ct] && cityNames[ct][normalize_(item.proposed)]) {
          note = 'Heads-up: another venue in ' + item.city + ' already named "' +
                 item.proposed + '" — this becomes a merge candidate later (rename still safe)';
        }
      }
    }
    plan.push({
      status: status, row: rowNum, ridx: (hits.length === 1 ? hits[0] : null),
      current: item.name, city: item.city,
      proposed: item.proposed, slug: slug, note: note
    });
  }
  return plan;
}

function writeReportTab_(ss, prefix, plan) {
  var tabName = prefix + '-' + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyy-MM-dd-HHmm');
  var sh = ss.insertSheet(tabName);
  var out = [['status', 'row', 'current_name', 'city', 'proposed_name', 'slug', 'note']];
  plan.forEach(function (p) {
    out.push([p.status, p.row, p.current, p.city, p.proposed, p.slug, p.note]);
  });
  sh.getRange(1, 1, out.length, out[0].length).setValues(out);
  sh.setFrozenRows(1);
  return tabName;
}

function summarize_(plan) {
  var c = {};
  plan.forEach(function (p) { c[p.status] = (c[p.status] || 0) + 1; });
  return c;
}

/** STEP 1 — DRY RUN. Read-only. Mutates nothing. */
function previewRenames() {
  var v = loadVenues_();
  var plan = buildPlan_(v);
  var tab = writeReportTab_(v.ss, 'RenamePreview', plan);
  var c = summarize_(plan);
  Logger.log('DRY RUN complete. Preview tab: ' + tab);
  Logger.log('Total rename rows: ' + plan.length);
  Logger.log('  OK (will rename): ' + (c['OK'] || 0));
  Logger.log('  NOOP (already done): ' + (c['NOOP'] || 0));
  Logger.log('  NO_MATCH (needs a look): ' + (c['NO_MATCH'] || 0));
  Logger.log('  MULTI_MATCH (skipped): ' + (c['MULTI_MATCH'] || 0));
  Logger.log('Nothing was changed. Review the "' + tab + '" tab.');
  Logger.log('If it looks right: set CONFIRM_LIVE_RUN = true, then run applyRenamesLive().');
}

/** STEP 2 — LIVE. Changes ONLY the name column, only for OK rows. */
function applyRenamesLive() {
  if (CONFIRM_LIVE_RUN !== true) {
    throw new Error('Safety gate: set CONFIRM_LIVE_RUN = true at the top of the script, save, then run again.');
  }
  var v = loadVenues_();
  var plan = buildPlan_(v);
  var col = v.col, rows = v.values;

  // Read the ENTIRE name column (including header row) so array index k
  // maps 1:1 to values row k (spreadsheet row k+1). No off-by-one.
  var nameColIndex = col['name'] + 1; // 1-based column for getRange
  var nameRange = v.sh.getRange(1, nameColIndex, rows.length, 1);
  var nameVals = nameRange.getValues(); // nameVals[k][0] === rows[k][name]

  var applied = 0;
  plan.forEach(function (p) {
    if (p.status !== 'OK' || p.ridx === null) return;
    nameVals[p.ridx][0] = p.proposed; // p.ridx is the 0-based values index
    applied++;
  });

  nameRange.setValues(nameVals); // single mutation, header row unchanged

  // Report AFTER mutation (if this line times out, the renames still succeeded).
  var tab = writeReportTab_(v.ss, 'RenameLiveRun', plan);
  Logger.log('LIVE RUN complete. Renamed ' + applied + ' venue name(s).');
  Logger.log('Report tab: ' + tab);
  Logger.log('If the report tab is empty due to a Sheets timeout, ignore it — verify by');
  Logger.log('spot-checking a few renamed rows directly in the venues tab.');
}
