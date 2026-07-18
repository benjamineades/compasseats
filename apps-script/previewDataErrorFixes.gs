/**
 * CompassEats — Fix the 3 data-error duplicate rows (gate blocker, batch 2)
 * ------------------------------------------------------------------
 * Of the original 10 preflightPublish duplicate-key failures:
 *   • 4 already merged (CompassEats-MergeSafeDupes.gs) — DONE.
 *   • 3 are handled here — confirmed data/import errors, NOT real
 *     second venues. Verified against Michelin's own site and the
 *     Latin America's 50 Best 2025 press release before writing this.
 *   • 3 remain (River Café, Miura, Amano) — genuine identity
 *     collisions needing a real split + fresh Places lookup. NOT
 *     touched by this script — handled separately.
 *
 * What this script does, per pair:
 *   1. tokyo/aoyama-sushi-umi — the "Panama" row's Latin America's
 *      50 Best award belongs to a different real restaurant ("Umi",
 *      Panama City) that isn't Aoyama Sushi Umi. Delete that row.
 *   2. saint-malo/doma-... — the "United States" row is a phantom;
 *      no real second Doma exists. Delete that row.
 *   3. chengdu/yuzhilan-fabrics — same real restaurant, one row has
 *      a stale/wrong Michelin rating. Michelin's 2026 announcement
 *      confirms Yu Zhi Lan has held Two Stars continuously since
 *      2022. Keep the Two-Stars row's awards, rename it to the
 *      correct name "Yu Zhi Lan", delete the wrong "One Star" row.
 *
 * TWO FUNCTIONS, same pattern as before:
 *   1) previewDataErrorFixes()  -> READ-ONLY. Writes a preview tab.
 *   2) applyDataErrorFixesLive() -> Applies. Gated behind CONFIRM_LIVE_RUN.
 * ------------------------------------------------------------------
 */

var SHEET_ID   = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
var VENUES_TAB = 'venues';

// ----> Leave false for the dry run. Flip to true ONLY to apply. <----
var CONFIRM_LIVE_RUN = false;

// action: 'delete_by_country' removes the row matching drop_country.
// action: 'keep_rename_delete_other' keeps the row matching keep_country,
//   renames it to correct_name, and deletes the other row.
var FIXES = [
  { city_slug: 'tokyo', slug: 'aoyama-sushi-umi',
    action: 'delete_by_country', drop_country: 'Panama',
    reason: 'Latin America 50 Best #72 belongs to a different restaurant ("Umi", Panama City), not this Tokyo sushi spot.' },

  { city_slug: 'saint-malo', slug: 'doma-cuisine-d-humeur-vins-chines',
    action: 'delete_by_country', drop_country: 'United States',
    reason: 'No real second "Doma" found in the US — phantom row, OAD #548 does not belong here.' },

  { city_slug: 'chengdu', slug: 'yuzhilan-fabrics',
    action: 'keep_rename_delete_other', keep_country: 'China', keep_award_count: 3,
    correct_name: 'Yu Zhi Lan',
    reason: 'Michelin confirms Two Stars held continuously since 2022 — the "One Star" row is stale/wrong.' }
];

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
  ['slug', 'city_slug', 'name', 'country', 'awards_json'].forEach(function (k) {
    if (col[k] === undefined) throw new Error('Missing column: ' + k);
  });
  return { ss: ss, sh: sh, values: values, header: header, col: col };
}

function buildPlan_(v) {
  var rows = v.values, col = v.col;
  var plan = [];

  FIXES.forEach(function (f) {
    var hits = [];
    for (var r = 1; r < rows.length; r++) {
      if (normalize_(rows[r][col['city_slug']]) === normalize_(f.city_slug) &&
          normalize_(rows[r][col['slug']])       === normalize_(f.slug)) {
        hits.push(r);
      }
    }
    var entry = { key: f.city_slug + '/' + f.slug, action: f.action, reason: f.reason,
                  status: '', note: '', keepRow: '', dropRow: '', renameTo: '' };

    if (hits.length !== 2) {
      entry.status = 'UNEXPECTED_ROW_COUNT';
      entry.note = 'Expected 2 rows, found ' + hits.length + ' — skipped.';
      plan.push(entry); return;
    }

    var a = hits[0], b = hits[1];

    if (f.action === 'delete_by_country') {
      var dropIdx = (normalize_(rows[a][col['country']]) === normalize_(f.drop_country)) ? a
                  : (normalize_(rows[b][col['country']]) === normalize_(f.drop_country)) ? b : -1;
      if (dropIdx === -1) {
        entry.status = 'COUNTRY_NOT_FOUND';
        entry.note = 'Neither row has country "' + f.drop_country + '" — skipped for safety.';
        plan.push(entry); return;
      }
      var keepIdx = (dropIdx === a) ? b : a;
      entry.status = 'OK';
      entry.keepRow = keepIdx + 1; entry.keepName = rows[keepIdx][col['name']] + ' [' + rows[keepIdx][col['country']] + ']';
      entry.dropRow = dropIdx + 1; entry.dropName = rows[dropIdx][col['name']] + ' [' + rows[dropIdx][col['country']] + ']';
      entry._deleteRowNum = dropIdx + 1;
      plan.push(entry); return;
    }

    if (f.action === 'keep_rename_delete_other') {
      var keepIdx2 = (normalize_(rows[a][col['country']]) === normalize_(f.keep_country)) ? a
                   : (normalize_(rows[b][col['country']]) === normalize_(f.keep_country)) ? b : -1;
      if (keepIdx2 === -1) {
        entry.status = 'COUNTRY_NOT_FOUND';
        entry.note = 'Neither row has country "' + f.keep_country + '" — skipped for safety.';
        plan.push(entry); return;
      }
      var dropIdx2 = (keepIdx2 === a) ? b : a;
      entry.status = 'OK';
      entry.keepRow = keepIdx2 + 1; entry.keepName = rows[keepIdx2][col['name']] + ' [' + rows[keepIdx2][col['country']] + ']';
      entry.dropRow = dropIdx2 + 1; entry.dropName = rows[dropIdx2][col['name']] + ' [' + rows[dropIdx2][col['country']] + ']';
      entry.renameTo = f.correct_name;
      entry._deleteRowNum = dropIdx2 + 1;
      entry._renameRowNum = keepIdx2 + 1;
      entry._renameTo = f.correct_name;
      plan.push(entry); return;
    }

    entry.status = 'UNKNOWN_ACTION';
    plan.push(entry);
  });
  return plan;
}

function writeReport_(ss, prefix, plan) {
  var name = prefix + '-' + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyy-MM-dd-HHmm');
  var sh = ss.insertSheet(name);
  var out = [['pair', 'action', 'status', 'keep_row', 'keep_name', 'rename_to', 'delete_row', 'delete_name', 'reason', 'note']];
  plan.forEach(function (p) {
    out.push([p.key, p.action, p.status, p.keepRow, p.keepName || '', p.renameTo || '',
              p.dropRow, p.dropName || '', p.reason || '', p.note || '']);
  });
  sh.getRange(1, 1, out.length, out[0].length).setValues(out);
  sh.setFrozenRows(1);
  return name;
}

/** STEP 1 — DRY RUN. Read-only. */
function previewDataErrorFixes() {
  var v = loadVenues_();
  var plan = buildPlan_(v);
  var tab = writeReport_(v.ss, 'DataErrorFixPreview', plan);
  var ok = plan.filter(function (p) { return p.status === 'OK'; }).length;
  Logger.log('DRY RUN complete. Preview tab: ' + tab);
  Logger.log('Fixes ready (OK): ' + ok + ' of ' + FIXES.length);
  plan.forEach(function (p) {
    if (p.status !== 'OK') Logger.log('  NEEDS ATTENTION — ' + p.key + ': ' + p.status + ' ' + p.note);
  });
  Logger.log('Nothing changed. Review the tab, then set CONFIRM_LIVE_RUN = true and run applyDataErrorFixesLive().');
}

/** STEP 2 — LIVE. Renames the keep-row where needed, deletes the bad row. */
function applyDataErrorFixesLive() {
  if (CONFIRM_LIVE_RUN !== true) {
    throw new Error('Safety gate: set CONFIRM_LIVE_RUN = true, save, then run again.');
  }
  var v = loadVenues_();
  var plan = buildPlan_(v);
  var col = v.col;
  var nameColOneBased = col['name'] + 1;

  // 1) apply renames first (row numbers still valid — no deletes yet)
  var deleteRowNums = [];
  plan.forEach(function (p) {
    if (p.status !== 'OK') return;
    if (p._renameRowNum) {
      v.sh.getRange(p._renameRowNum, nameColOneBased).setValue(p._renameTo);
    }
    deleteRowNums.push(p._deleteRowNum);
  });

  // 2) delete bottom-up so row indices don't shift
  deleteRowNums.sort(function (a, b) { return b - a; });
  deleteRowNums.forEach(function (rn) { v.sh.deleteRow(rn); });

  var tab = writeReport_(v.ss, 'DataErrorFixLiveRun', plan);
  Logger.log('LIVE RUN complete. Fixed ' + deleteRowNums.length + ' pair(s).');
  Logger.log('Rows deleted: ' + deleteRowNums.length + '. Report tab: ' + tab);
  Logger.log('Verify by re-running preflightPublish — duplicate count should drop by ' + deleteRowNums.length + ' more.');
}
