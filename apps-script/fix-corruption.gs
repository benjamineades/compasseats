/**
 * CompassEats — one-time country-string corruption fix
 * A past manual Find&Replace turned "USA"->"United States" and
 * "UK"->"United Kingdom" with Match Case OFF and no whole-cell match,
 * expanding u-s-a / u-k inside real words (Busan, Ragusa, Nusara, Dukes...).
 * This repairs ONLY glued occurrences and leaves real country values alone.
 * RUN ONCE, then run the pipeline in the order shown in the popup.
 */
function fixCountryCorruption() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  // Tabs + the columns that can carry the corruption.
  // We deliberately never touch a "country" column (real "United States").
  var TARGETS = {
    'Michelin Guide':     ['Name', 'Location'],
    'Worlds 50 Best':     ['Name'],
    'Best Chef Awards':   ['Name', 'Location', 'Chef'],
    'James Beard Awards': ['Name'],
    'Spirited Awards':    ['Name']
  };

  // Only replace when the phrase is glued to a non-space char (the corruption).
  function repair(s) {
    if (s === null || s === undefined) return s;
    return String(s)
      .replace(/(\S)united states/gi, '$1usa')
      .replace(/(\S)united kingdom/gi, '$1uk');
  }

  var report = [], totalCells = 0;
  for (var tabName in TARGETS) {
    var sheet = findTabCE_(ss, tabName);
    if (!sheet) { report.push('SKIP (not found): ' + tabName); continue; }
    var rng = sheet.getDataRange(), vals = rng.getValues(), headers = vals[0];
    var col = {};
    for (var h = 0; h < headers.length; h++) col[String(headers[h]).trim()] = h;
    var changed = 0, cols = TARGETS[tabName];
    for (var r = 1; r < vals.length; r++) {
      for (var c = 0; c < cols.length; c++) {
        var ci = col[cols[c]];
        if (ci === undefined) continue;
        var after = repair(vals[r][ci]);
        if (after !== vals[r][ci]) { vals[r][ci] = after; changed++; }
      }
    }
    if (changed) rng.setValues(vals);
    totalCells += changed;
    report.push(tabName + ': ' + changed + ' cell(s) fixed');
  }

  // Places Enrichment: delete the rows whose match KEY was corrupted.
  // Several matched the WRONG place (Nusara -> a US Embassy), so they must
  // be re-enriched cleanly rather than kept.
  var pe = findTabCE_(ss, 'Places Enrichment'), peDeleted = 0;
  if (pe) {
    var pv = pe.getDataRange().getValues();
    var bad = /(\S)united (states|kingdom)|united (states|kingdom)(\S)/i;
    for (var i = pv.length - 1; i >= 1; i--) {
      if (bad.test(String(pv[i][0] || ''))) { pe.deleteRow(i + 1); peDeleted++; }
    }
  }

  var msg =
    'Country-corruption fix complete.\n\n' + report.join('\n') +
    '\n\nSource cells fixed: ' + totalCells +
    '\nPlaces Enrichment rows deleted (will re-enrich): ' + peDeleted +
    '\n\nNEXT, in this order:\n' +
    '  1) reshapeCompassEats   (clean names + cities)\n' +
    '  2) geoEnrich            (re-fetch geo for the cleared venues)\n' +
    '  3) reshapeCompassEats   (fold the new geo back in)\n' +
    '  4) generateCitiesTab    (rebuild the cities tab)\n' +
    '  5) publish';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// Loose tab finder (tolerates apostrophes/case/spacing). Unique name, no collisions.
function findTabCE_(ss, wantName) {
  var norm = function (x) {
    return String(x).toLowerCase().replace(/['\u2019`]/g, '').replace(/\s+/g, ' ').trim();
  };
  var want = norm(wantName), sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    if (norm(sheets[i].getName()) === want) return sheets[i];
  }
  return null;
}
