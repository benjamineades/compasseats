/**
 * clearRequeryTargets.gs
 * ----------------------------------------------------------------------------
 * Unblocks the BRANCH/POISON re-pin. Those 158 venues already have (wrong)
 * pins on file, so geoRequeryCollisions skips them as "done". This removes
 * ONLY those venues' existing pins from 'Places Enrichment' and clears their
 * entries from 'geo_requery_done', so the very next geoRequeryCollisions run
 * looks them up fresh.
 *
 * Uses the SAME TARGET_SLUGS list defined in geoRequeryCollisions.gs, and the
 * project's own normKey_/cityKey_ so the keys match exactly what reshape uses.
 *
 * SAFE:
 *   • Backs up every removed Places Enrichment row to 'geo_cleared_backup'
 *     before deleting (undo = copy them back).
 *   • Reshape falls back to each venue's current pin, so nothing goes geo-less.
 *   • DRY_RUN = true first: counts what it WOULD clear, changes nothing.
 *
 * ORDER:  clearRequeryTargets (preview -> live)  ->  geoRequeryCollisions
 * ----------------------------------------------------------------------------
 */

var CLEAR_DRY_RUN = true;   // <-- flip to false only after reading the preview log

function clearRequeryTargets() {
  var ss = SpreadsheetApp.getActive();
  if (typeof TARGET_SLUGS === 'undefined' || !TARGET_SLUGS.length) {
    throw new Error('TARGET_SLUGS is empty/undefined. Install the corrected geoRequeryCollisions.gs first.');
  }

  // 1) Compute the name|city keys for the target slugs, using project functions.
  var v = ss.getSheetByName('venues');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iSlug = H['slug'], iName = H['name'], iCityDisp = H['city_display'];
  var targetSet = {}; TARGET_SLUGS.forEach(function (s) { targetSet[s] = true; });

  var wantKeys = {};
  for (var r = 1; r < vv.length; r++) {
    var slug = String(vv[r][iSlug] || '').trim();
    if (!targetSet[slug]) continue;
    var nm = String(vv[r][iName] || '').trim();
    var cd = String(vv[r][iCityDisp] || '').trim();
    if (!nm || !cd) continue;
    wantKeys[normKey_(nm) + '|' + cityKey_(cd)] = true;
  }
  var nWant = Object.keys(wantKeys).length;

  // 2) Find matching rows in Places Enrichment.
  var esheet = ss.getSheetByName('Places Enrichment');
  var ev = esheet.getDataRange().getValues();
  var removeRows = [];   // 0-based indices into ev
  for (var er = 1; er < ev.length; er++) {
    if (wantKeys[String(ev[er][0])]) removeRows.push(er);
  }

  // 3) Find matching rows in geo_requery_done.
  var logSheet = ss.getSheetByName('geo_requery_done');
  var removeLog = [];
  if (logSheet) {
    var lv = logSheet.getDataRange().getValues();
    for (var lr = 1; lr < lv.length; lr++) {
      if (wantKeys[String(lv[lr][0])]) removeLog.push(lr);
    }
  }

  Logger.log('=== clearRequeryTargets ' + (CLEAR_DRY_RUN ? '(DRY RUN — no changes)' : '(LIVE)') + ' ===');
  Logger.log('target slugs: ' + TARGET_SLUGS.length + '  ->  distinct name|city keys: ' + nWant);
  Logger.log('Places Enrichment rows to clear: ' + removeRows.length);
  Logger.log('geo_requery_done rows to clear:  ' + removeLog.length);

  if (CLEAR_DRY_RUN) {
    Logger.log('DRY RUN complete. Set CLEAR_DRY_RUN = false to apply, then run geoRequeryCollisions.');
    return;
  }

  // 4a) Back up the enrichment rows we're about to delete.
  if (removeRows.length) {
    var bak = ss.getSheetByName('geo_cleared_backup');
    if (!bak) { bak = ss.insertSheet('geo_cleared_backup'); bak.appendRow(ev[0]); bak.setFrozenRows(1); }
    var backup = removeRows.map(function (i) { return ev[i]; });
    bak.getRange(bak.getLastRow() + 1, 1, backup.length, ev[0].length).setValues(backup);
  }

  // 4b) Delete enrichment rows (bottom-up so indices hold).
  removeRows.sort(function (a, b) { return b - a; }).forEach(function (i) { esheet.deleteRow(i + 1); });

  // 4c) Delete log rows (bottom-up).
  if (logSheet) removeLog.sort(function (a, b) { return b - a; }).forEach(function (i) { logSheet.deleteRow(i + 1); });

  Logger.log('Applied. Cleared ' + removeRows.length + ' enrichment rows (backed up to geo_cleared_backup) and '
    + removeLog.length + ' log rows.');
  Logger.log('NEXT: run geoRequeryCollisions — it should now show ~' + nWant + ' targets.');
}
