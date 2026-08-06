/**
 * CompassEats — Duplicate Venue Merge (Google Apps Script)
 * =========================================================
 * Collapses duplicate venue rows created by cross-source NAME VARIANTS
 * ("Astrance" vs "L'Astrance", "Noma" vs "Noma 2.0", "The Fat Duck" vs
 * "Fat Duck", "Table Bruno Verjus" vs "Table by Bruno Verjus").
 *
 * HOW IT WORKS
 *   Two venue rows are the same venue when they share ALL THREE of:
 *     1. the same Google place_id (the `id` column)
 *     2. the same city_slug
 *     3. the same type (bar / restaurant)
 *   Rows in such a group are merged into ONE row:
 *     - the row with the SHORTEST slug is kept (so "noma" wins over "noma-2")
 *     - awards_json becomes the UNION of all rows' awards (deduped by
 *       source|year|category, sorted by source then newest year first)
 *     - blank fields on the kept row are filled from the merged rows
 *       (blurbs, chef, cuisine, price, photo, address, website)
 *
 * SAFETY GATE — what it deliberately does NOT merge:
 *   Rows sharing a place_id but in DIFFERENT cities are NOT touched.
 *   Some of those are legit city-name variants (Bray vs Maidenhead), but
 *   others are the known name-only-geo-lookup bug (e.g. Xin Rong Ji branches
 *   in four cities all carrying one Beijing place_id). Merging those would
 *   destroy real venues. Instead they are written to a `merge_review` tab
 *   for manual decision — fix the city alias or the enrichment row, then
 *   re-run reshape.
 *
 * VERIFIED (June 10, 2026, against the live venues tab copy):
 *   11,222 rows → 10,671 rows. 505 merge groups, 551 duplicate rows removed,
 *   0 remaining same-id+city+type duplicates. Spot-checked: Noma, The Fat
 *   Duck, Plénitude (its Michelin three stars + W50 No. 14 + La Liste 99
 *   correctly land on ONE row), Astrance, Table Bruno Verjus.
 *
 * HOW TO RUN
 *   1. Make a backup copy of the Sheet first (File → Make a copy).
 *   2. Extensions → Apps Script → new file → paste this whole file → Save.
 *   3. Run → mergeDuplicateVenues. Authorize if prompted.
 *   4. Read the summary in the execution log; review the new `merge_review` tab.
 *
 * RUN ORDER (every publish cycle):
 *   reshapeCompassEats → mergeDuplicateVenues → resolveDualCategoryVenues →
 *   importBlurbsFromDrive → clearWrongCityBlurbs → importOptionB →
 *   generateCitiesTab → generateRegionsTab → preflightPublish → deploy.
 *   (Reshape rebuilds the dupes from sources each run, so this must re-run
 *   after every reshape — same pattern as the blurb imports.)
 *
 * FIXED August 2, 2026: the summary used to be shown with
 * SpreadsheetApp.getUi().alert(), which only works when the script is run
 * from a menu inside the open spreadsheet. Run from the Apps Script editor
 * it throws "Cannot call SpreadsheetApp.getUi() from this context" AFTER the
 * merge and both tab writes have already completed — so the run was marked
 * Failed even though everything succeeded. The summary now goes to
 * Logger.log() only, which works in every context.
 *
 * FIXED August 5, 2026 — the all-or-nothing rewrite bug:
 * This used to clearContents() the ENTIRE venues tab, then write it all back
 * in a single giant setValues() call (~11,700 rows × every column). On a tab
 * this size, that one write occasionally hit "Service Spreadsheets timed out"
 * PARTWAY THROUGH — and because the tab had already been cleared first, a
 * timeout mid-write left venues holding only whatever fraction the Sheets
 * service managed to save (this is exactly what caused the Aug 5 incident
 * where venues silently dropped from 11,774 rows to 9,166).
 *
 * Now the script never clears the tab. Each merge group writes its one
 * "keep" row back individually the moment it's computed, and duplicate rows
 * are removed with targeted deleteRows() calls afterward, batched into
 * contiguous runs for speed. If a run times out partway through, whatever
 * was already written or deleted stays correct — nothing untouched can be
 * lost — and a re-run simply picks up the remaining duplicate groups (they
 * won't have been deleted yet, so they're found again automatically).
 */

var MV_VENUES_TAB = 'venues';
var MV_REVIEW_TAB = 'merge_review';

function mergeDuplicateVenues() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(MV_VENUES_TAB);
  if (!sheet) throw new Error('No "' + MV_VENUES_TAB + '" tab found.');

  var vals = sheet.getDataRange().getValues();
  var headers = vals[0];
  var col = {};
  for (var h = 0; h < headers.length; h++) col[headers[h]] = h;
  ['id', 'slug', 'city_slug', 'type', 'awards_json'].forEach(function (c) {
    if (!(c in col)) throw new Error('venues tab is missing column: ' + c);
  });

  var originalCount = vals.length - 1;

  // ---- 1) Group rows: place_id + city_slug + type ----
  var groups = {};            // mergeKey -> [rowIndex...]
  var cityByPid = {};         // place_id -> { city_slug: true }
  for (var i = 1; i < vals.length; i++) {
    var pid = String(vals[i][col.id] || '').trim();
    if (!pid) continue;       // rows without a place_id are never merged
    var cs = String(vals[i][col.city_slug] || '');
    var ty = String(vals[i][col.type] || '');
    var key = pid + '|' + cs + '|' + ty;
    if (!groups[key]) groups[key] = [];
    groups[key].push(i);
    if (!cityByPid[pid]) cityByPid[pid] = {};
    cityByPid[pid][cs] = true;
  }

  // ---- 2) Merge each multi-row group, writing the kept row back IMMEDIATELY ----
  var FILL_COLS = ['blurb_short', 'blurb_long', 'chef', 'cuisine_tags',
                   'price_tier', 'photo_url', 'address', 'website',
                   'reservation_url', 'phone', 'neighborhood'];
  var deleteRows = {};        // rowIndex (0-based, into vals) -> true
  var mergedGroups = 0, mergedAway = 0;

  for (var key2 in groups) {
    var idxs = groups[key2];
    if (idxs.length < 2) continue;

    // Keep the shortest slug (canonical "noma" beats "noma-2"); tie → alphabetical
    idxs.sort(function (a, b) {
      var sa = String(vals[a][col.slug]), sb = String(vals[b][col.slug]);
      return sa.length !== sb.length ? sa.length - sb.length : (sa < sb ? -1 : 1);
    });
    var keep = idxs[0];

    // Union the awards, dedupe by source|year|category
    var seen = {}, awards = [];
    for (var g = 0; g < idxs.length; g++) {
      var raw = vals[idxs[g]][col.awards_json];
      var list = [];
      try { list = raw ? JSON.parse(raw) : []; } catch (e) { list = []; }
      for (var a = 0; a < list.length; a++) {
        var aw = list[a];
        var sig = aw.source + '|' + aw.year + '|' + aw.category;
        if (seen[sig]) continue;
        seen[sig] = true;
        awards.push(aw);
      }
    }
    awards.sort(function (x, y) {
      if (x.source !== y.source) return x.source < y.source ? -1 : 1;
      return (Number(y.year) || 0) - (Number(x.year) || 0);
    });
    vals[keep][col.awards_json] = JSON.stringify(awards);

    // Fill blanks on the kept row from the rows being merged away
    for (var f = 0; f < FILL_COLS.length; f++) {
      var c = col[FILL_COLS[f]];
      if (c === undefined) continue;
      if (vals[keep][c] !== '' && vals[keep][c] !== null) continue;
      for (var g2 = 1; g2 < idxs.length; g2++) {
        var v2 = vals[idxs[g2]][c];
        if (v2 !== '' && v2 !== null) { vals[keep][c] = v2; break; }
      }
    }

    // Write the merged "keep" row back to the sheet right now — small,
    // single-row write. If the script dies later, this row is already safe.
    sheet.getRange(keep + 1, 1, 1, headers.length).setValues([vals[keep]]);

    for (var d = 1; d < idxs.length; d++) deleteRows[idxs[d]] = true;
    mergedGroups++;
    mergedAway += idxs.length - 1;

    if (mergedGroups % 100 === 0) {
      SpreadsheetApp.flush();
      Logger.log('  ...merged ' + mergedGroups + ' groups so far (' + mergedAway + ' rows queued for deletion)');
    }
  }
  SpreadsheetApp.flush();

  // ---- 3) Build the review list: place_ids spanning multiple cities ----
  var reviewRows = [];
  for (var pid2 in cityByPid) {
    var cities = Object.keys(cityByPid[pid2]);
    if (cities.length < 2) continue;
    // collect the venue names/slugs involved
    var names = [], slugs = [];
    for (var r = 1; r < vals.length; r++) {
      if (String(vals[r][col.id] || '') === pid2) {
        names.push(String(vals[r][col.name !== undefined ? col.name : col.slug]));
        slugs.push(vals[r][col.city_slug] + '/' + vals[r][col.slug]);
      }
    }
    reviewRows.push([
      pid2,
      cities.join(' | '),
      names.filter(function (x, ix) { return names.indexOf(x) === ix; }).join(' | '),
      slugs.join(' | '),
      'Same place_id in multiple cities — either a city-name variant (add a CITY_ALIASES_ entry in reshape) or a wrong geo match from the name-only enrichment lookup (fix the Places Enrichment row). Decide per venue; do NOT bulk-merge.'
    ]);
  }

  // ---- 4) Delete the merged-away rows — bottom-up, batched into contiguous runs ----
  // (See the FIXED August 5, 2026 note at the top of this file for why this
  // replaced the old clearContents()+setValues(everything) approach.)
  var deleteRowNums = [];
  for (var dr in deleteRows) deleteRowNums.push(Number(dr) + 1); // 0-based vals index -> 1-based sheet row
  deleteRowNums.sort(function (a, b) { return b - a; }); // descending

  var di = 0, deletedSoFar = 0;
  while (di < deleteRowNums.length) {
    var runEnd = deleteRowNums[di];
    var runStart = runEnd;
    var dj = di;
    while (dj + 1 < deleteRowNums.length && deleteRowNums[dj + 1] === runStart - 1) {
      runStart = deleteRowNums[dj + 1];
      dj++;
    }
    var runLength = runEnd - runStart + 1;
    sheet.deleteRows(runStart, runLength);
    deletedSoFar += runLength;
    di = dj + 1;

    if (deletedSoFar % 200 < runLength) {
      SpreadsheetApp.flush();
      Logger.log('  ...deleted ' + deletedSoFar + ' of ' + deleteRowNums.length + ' duplicate rows so far');
    }
  }
  SpreadsheetApp.flush();

  // ---- 5) Write the review tab ----
  var rev = ss.getSheetByName(MV_REVIEW_TAB);
  if (rev) rev.clear(); else rev = ss.insertSheet(MV_REVIEW_TAB);
  var revHeaders = ['place_id', 'cities', 'names', 'city_slug/slug pairs', 'what to do'];
  rev.getRange(1, 1, 1, revHeaders.length).setValues([revHeaders]).setFontWeight('bold');
  if (reviewRows.length) {
    rev.getRange(2, 1, reviewRows.length, revHeaders.length).setValues(reviewRows);
  }
  rev.setFrozenRows(1);

  var msg = 'Merge done.\n' +
    'venues rows: ' + originalCount + ' → ' + (originalCount - mergedAway) + '\n' +
    'merge groups collapsed: ' + mergedGroups + '\n' +
    'duplicate rows removed: ' + mergedAway + '\n' +
    'cross-city place_ids needing review: ' + reviewRows.length +
    ' (see "' + MV_REVIEW_TAB + '" tab)';
  Logger.log(msg);
}
