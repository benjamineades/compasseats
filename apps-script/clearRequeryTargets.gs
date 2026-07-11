/**
 * clearRequeryTargets.gs  [pair-targeted]
 * ----------------------------------------------------------------------------
 * Removes ONLY the 197 mispinned rows' existing pins from 'Places Enrichment'
 * and clears their 'geo_requery_done' entries, so the next geoRequeryCollisions
 * run re-looks-up exactly those rows. Correct-home pins are never touched.
 *
 * Uses TARGET_PAIRS from geoRequeryCollisions.gs and the project's own
 * normKey_/cityKey_ so keys match what reshape uses.
 *
 * SAFE: backs up every removed row to 'geo_cleared_backup' first; reshape falls
 * back to each venue's current pin. DRY_RUN = true first.
 *
 * ORDER:  clearRequeryTargets (preview -> live)  ->  geoRequeryCollisions
 * ----------------------------------------------------------------------------
 */

var CLEAR_DRY_RUN = false;   // <-- flip to false only after reading the preview log

function clearRequeryTargets() {
  var ss = SpreadsheetApp.getActive();
  if (typeof TARGET_PAIRS === 'undefined' || !TARGET_PAIRS.length) {
    throw new Error('TARGET_PAIRS empty/undefined. Install the pair-targeted geoRequeryCollisions.gs first.');
  }
  var pairSet = {}; TARGET_PAIRS.forEach(function (p) { pairSet[p[0] + '||' + String(p[1]).trim().toLowerCase()] = true; });

  var v = ss.getSheetByName('venues');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iSlug = H['slug'], iName = H['name'], iCityDisp = H['city_display'];

  var wantKeys = {};
  for (var r = 1; r < vv.length; r++) {
    var slug = String(vv[r][iSlug] || '').trim();
    var cd = String(vv[r][iCityDisp] || '').trim();
    if (!pairSet[slug + '||' + cd.toLowerCase()]) continue;
    var nm = String(vv[r][iName] || '').trim();
    if (!nm || !cd) continue;
    wantKeys[normKey_(nm) + '|' + cityKey_(cd)] = true;
  }
  var nWant = Object.keys(wantKeys).length;

  var esheet = ss.getSheetByName('Places Enrichment');
  var ev = esheet.getDataRange().getValues();
  var removeRows = [];
  for (var er = 1; er < ev.length; er++) { if (wantKeys[String(ev[er][0])]) removeRows.push(er); }

  var logSheet = ss.getSheetByName('geo_requery_done');
  var removeLog = [];
  if (logSheet) {
    var lv = logSheet.getDataRange().getValues();
    for (var lr = 1; lr < lv.length; lr++) { if (wantKeys[String(lv[lr][0])]) removeLog.push(lr); }
  }

  Logger.log('=== clearRequeryTargets ' + (CLEAR_DRY_RUN ? '(DRY RUN — no changes)' : '(LIVE)') + ' ===');
  Logger.log('mispinned pairs: ' + TARGET_PAIRS.length + '  ->  distinct name|city keys: ' + nWant);
  Logger.log('Places Enrichment rows to clear: ' + removeRows.length);
  Logger.log('geo_requery_done rows to clear:  ' + removeLog.length);
  if (CLEAR_DRY_RUN) { Logger.log('DRY RUN complete. Set CLEAR_DRY_RUN = false to apply, then run geoRequeryCollisions.'); return; }

  if (removeRows.length) {
    var bak = ss.getSheetByName('geo_cleared_backup');
    if (!bak) { bak = ss.insertSheet('geo_cleared_backup'); bak.appendRow(ev[0]); bak.setFrozenRows(1); }
    var backup = removeRows.map(function (i) { return ev[i]; });
    bak.getRange(bak.getLastRow() + 1, 1, backup.length, ev[0].length).setValues(backup);
  }
  removeRows.sort(function (a, b) { return b - a; }).forEach(function (i) { esheet.deleteRow(i + 1); });
  if (logSheet) removeLog.sort(function (a, b) { return b - a; }).forEach(function (i) { logSheet.deleteRow(i + 1); });

  Logger.log('Applied. Cleared ' + removeRows.length + ' enrichment rows (backed up to geo_cleared_backup) and '
    + removeLog.length + ' log rows.');
  Logger.log('NEXT: run geoRequeryCollisions — it should show ~' + nWant + ' targets.');
}
