/**
 * ONE-TIME revert (fast version) — removes this session's collision rows from
 * Places Enrichment, returning the tab to its pre-collision (clean) state.
 *
 * Deletes ONLY rows tagged 'collision-fix' or 'collision-fix-reviewed'
 * (the 424 rows added this session). Keeps the older 'geo-requery' rows,
 * all name-only enrichment rows, and the header.
 *
 * Reads only the 10 real columns (avoids the bloated used-range that timed
 * out the previous version), rewrites the kept rows, and removes the surplus
 * trailing rows in a single call. Runs in seconds.
 *
 * After running, re-run the normal pipeline. Blurbs return to ~10,119.
 * No publish needed — the live site already matches the clean state.
 */
function removeCollisionFixRows() {
  var ss = SpreadsheetApp.getActive();
  var sh = ss.getSheetByName('Places Enrichment');
  if (!sh) throw new Error('No "Places Enrichment" tab found.');

  var lastRow = sh.getLastRow();
  if (lastRow < 2) throw new Error('Places Enrichment looks empty — aborting.');

  var COLS = 10;                                            // the real schema width
  var data = sh.getRange(1, 1, lastRow, COLS).getValues();  // bounded read (fast)
  var tags = { 'collision-fix': true, 'collision-fix-reviewed': true };

  var keep = [data[0]];                                     // header
  var removed = 0;
  for (var i = 1; i < data.length; i++) {
    if (tags[String(data[i][2])]) removed++;                // col C = tag
    else keep.push(data[i]);
  }

  if (removed === 0) {
    SpreadsheetApp.getUi().alert('No collision rows found — nothing removed.');
    return;
  }

  sh.getRange(1, 1, keep.length, COLS).setValues(keep);     // bounded write (fast)
  var surplus = lastRow - keep.length;
  if (surplus > 0) sh.deleteRows(keep.length + 1, surplus); // single call

  SpreadsheetApp.getUi().alert(
    'Removed ' + removed + ' collision rows (expected 424).\n' +
    'Kept ' + (keep.length - 1) + ' enrichment rows.\n\n' +
    'Now re-run the pipeline:\n' +
    'reshapeCompassEats -> mergeDuplicateVenues -> importBlurbsFromDrive ->\n' +
    'clearWrongCityBlurbs -> importOptionB -> generateCitiesTab -> preflightPublish\n\n' +
    'Expect blurbs back to ~10,119. No publish needed.');
}
