/**
 * CompassEats — Merge the 4 SAFE duplicate rows (gate blocker fix)
 * ------------------------------------------------------------------
 * preflightPublish flagged 10 duplicate city/slug keys. Investigation
 * split them into two groups:
 *   • 4 are TRUE duplicates of the same real venue (this script).
 *   • 6 are two DIFFERENT real venues wrongly sharing a place_id
 *     (NOT touched here — they need a split, handled separately).
 *
 * This script ONLY handles the 4 safe pairs below. For each it keeps a
 * PRIMARY row, folds in any non-conflicting awards from the duplicate,
 * then deletes the duplicate row. It changes nothing else.
 *
 * Why not just re-run mergeDuplicateVenues? Because a blind place_id
 * merge would ALSO collapse the 6 identity-collision pairs (e.g. merge
 * Brooklyn's River Café into London's), corrupting real data. This
 * targeted script avoids that.
 *
 * Award conflict rule: if the duplicate has an award with the same
 * source+year+category as the primary but a DIFFERENT rank, the
 * primary's value wins and the duplicate's is dropped (and reported).
 *
 * TWO FUNCTIONS (same pattern as the rename script):
 *   1) previewSafeMerges()   -> READ-ONLY. Writes a 'SafeMergePreview-<time>'
 *                               tab. Mutates nothing.
 *   2) applySafeMergesLive()  -> Applies. Gated behind CONFIRM_LIVE_RUN.
 * ------------------------------------------------------------------
 */

var SHEET_ID   = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
var VENUES_TAB = 'venues';

// ----> Leave false for the dry run. Flip to true ONLY to apply. <----
var CONFIRM_LIVE_RUN = false;

// The 4 confirmed-safe pairs. keep_country (optional) forces which row
// is primary; otherwise the row with more awards is primary (tie -> first).
var MERGES = [
  { city_slug: 'sydney',    slug: 'eau-de-vie-sydney' },
  { city_slug: 'hong-kong', slug: 'coa' },
  { city_slug: 'new-delhi', slug: 'pco-bar' },
  { city_slug: 'aachen',    slug: 'bistro-quellenhof', keep_country: 'Germany' }
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

function parseAwards_(s) {
  if (!s) return [];
  try { var a = JSON.parse(s); return Array.isArray(a) ? a : []; }
  catch (e) { return null; } // null signals unparseable
}

// Conflict key is source+year: a ranked list (top-500, 50 Best, OAD) can only
// place a venue at ONE position per year, so two entries sharing source+year
// are a conflict, even though the rank is baked into the `category` string.
function awardKey_(a)     { return normalize_(a.source) + '|' + a.year; }
function awardFullKey_(a) { return awardKey_(a) + '|' + normalize_(a.category) + '|' + (a.rank === undefined ? '' : a.rank); }

/** Build a plan describing each merge without changing anything. */
function buildPlan_(v) {
  var rows = v.values, col = v.col;
  var plan = [];

  MERGES.forEach(function (m) {
    var hits = [];
    for (var r = 1; r < rows.length; r++) {
      if (normalize_(rows[r][col['city_slug']]) === normalize_(m.city_slug) &&
          normalize_(rows[r][col['slug']])       === normalize_(m.slug)) {
        hits.push(r);
      }
    }
    var entry = { key: m.city_slug + '/' + m.slug, status: '', note: '',
                  primaryRow: '', dropRow: '', mergedAwards: '', dropped: [] };

    if (hits.length !== 2) {
      entry.status = (hits.length === 1 ? 'ALREADY_SINGLE' : 'UNEXPECTED_' + hits.length);
      entry.note = 'Expected exactly 2 rows, found ' + hits.length + ' — skipped.';
      plan.push(entry); return;
    }

    // choose primary
    var a = hits[0], b = hits[1];
    var pri, dup;
    if (m.keep_country) {
      if (normalize_(rows[a][col['country']]) === normalize_(m.keep_country)) { pri = a; dup = b; }
      else if (normalize_(rows[b][col['country']]) === normalize_(m.keep_country)) { pri = b; dup = a; }
      else { entry.status = 'KEEP_COUNTRY_NOT_FOUND'; entry.note = 'Neither row has country ' + m.keep_country; plan.push(entry); return; }
    } else {
      var awA = parseAwards_(rows[a][col['awards_json']]) || [];
      var awB = parseAwards_(rows[b][col['awards_json']]) || [];
      if (awB.length > awA.length) { pri = b; dup = a; } else { pri = a; dup = b; }
    }

    var priAwards = parseAwards_(rows[pri][col['awards_json']]);
    var dupAwards = parseAwards_(rows[dup][col['awards_json']]);
    if (priAwards === null || dupAwards === null) {
      entry.status = 'UNPARSEABLE_AWARDS'; entry.note = 'awards_json did not parse — skipped for safety.';
      plan.push(entry); return;
    }

    // union with conflict resolution (primary wins on same source+year+category)
    var byKey = {};       // source|year|category -> award (from primary)
    var byFull = {};      // full key incl rank    -> true
    priAwards.forEach(function (aw) { byKey[awardKey_(aw)] = aw; byFull[awardFullKey_(aw)] = true; });

    var merged = priAwards.slice();
    dupAwards.forEach(function (aw) {
      if (byFull[awardFullKey_(aw)]) return;            // exact dup, silently skip
      var k = awardKey_(aw);
      if (byKey[k]) {                                   // same source+year+cat, different rank => conflict
        entry.dropped.push(aw.source + ' ' + aw.year + ' ' + aw.category +
          ' rank ' + aw.rank + ' (kept primary rank ' + byKey[k].rank + ')');
      } else {
        merged.push(aw); byKey[k] = aw; byFull[awardFullKey_(aw)] = true;  // genuinely new
      }
    });

    entry.status = 'OK';
    entry.primaryRow = pri + 1;
    entry.dropRow = dup + 1;
    entry.primaryName = rows[pri][col['name']] + '  [' + rows[pri][col['country']] + ']';
    entry.dropName = rows[dup][col['name']] + '  [' + rows[dup][col['country']] + ']';
    entry.priCount = priAwards.length;
    entry.mergedCount = merged.length;
    entry._priRowIdx = pri;
    entry._mergedJson = JSON.stringify(merged);
    entry.mergedAwards = merged.map(function (x) { return x.source + '·' + x.year + '·' + x.category + (x.rank!==undefined?('·#'+x.rank):''); }).join('  |  ');
    plan.push(entry);
  });
  return plan;
}

function writeReport_(ss, prefix, plan) {
  var name = prefix + '-' + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyy-MM-dd-HHmm');
  var sh = ss.insertSheet(name);
  var out = [['pair', 'status', 'keep_row', 'keep_name', 'delete_row', 'delete_name',
              'awards_before', 'awards_after', 'dropped_conflicts', 'note']];
  plan.forEach(function (p) {
    out.push([p.key, p.status, p.primaryRow, p.primaryName || '', p.dropRow, p.dropName || '',
              p.priCount === undefined ? '' : p.priCount,
              p.mergedCount === undefined ? '' : p.mergedCount,
              (p.dropped && p.dropped.length) ? p.dropped.join(' ; ') : '',
              p.note]);
  });
  sh.getRange(1, 1, out.length, out[0].length).setValues(out);
  sh.setFrozenRows(1);
  return name;
}

/** STEP 1 — DRY RUN. Read-only. */
function previewSafeMerges() {
  var v = loadVenues_();
  var plan = buildPlan_(v);
  var tab = writeReport_(v.ss, 'SafeMergePreview', plan);
  var ok = plan.filter(function (p) { return p.status === 'OK'; }).length;
  Logger.log('DRY RUN complete. Preview tab: ' + tab);
  Logger.log('Pairs ready to merge (OK): ' + ok + ' of ' + MERGES.length);
  plan.forEach(function (p) {
    if (p.status !== 'OK') Logger.log('  NEEDS ATTENTION — ' + p.key + ': ' + p.status + ' ' + p.note);
  });
  Logger.log('Nothing changed. Review the tab, then set CONFIRM_LIVE_RUN = true and run applySafeMergesLive().');
}

/** STEP 2 — LIVE. Sets merged awards on primary, deletes duplicate rows. */
function applySafeMergesLive() {
  if (CONFIRM_LIVE_RUN !== true) {
    throw new Error('Safety gate: set CONFIRM_LIVE_RUN = true, save, then run again.');
  }
  var v = loadVenues_();
  var plan = buildPlan_(v);
  var col = v.col;
  var awardsColOneBased = col['awards_json'] + 1;

  // 1) write merged awards onto each primary row (row numbers still valid — no deletes yet)
  var deleteRowNums = [];
  plan.forEach(function (p) {
    if (p.status !== 'OK') return;
    v.sh.getRange(p.primaryRow, awardsColOneBased).setValue(p._mergedJson);
    deleteRowNums.push(p.dropRow);
  });

  // 2) delete duplicate rows bottom-up so indices don't shift
  deleteRowNums.sort(function (a, b) { return b - a; });
  deleteRowNums.forEach(function (rn) { v.sh.deleteRow(rn); });

  var tab = writeReport_(v.ss, 'SafeMergeLiveRun', plan);
  Logger.log('LIVE RUN complete. Merged ' + deleteRowNums.length + ' duplicate pair(s).');
  Logger.log('Rows deleted: ' + deleteRowNums.length + '. Report tab: ' + tab);
  Logger.log('Verify by re-running preflightPublish — duplicate count should drop by ' + deleteRowNums.length + '.');
}
