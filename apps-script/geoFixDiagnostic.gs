/**
 * geoFixDiagnostic() — READ-ONLY. Makes NO edits to any tab.
 *
 * Purpose: confirm the per-city geo contamination on real rows and capture a
 * row-count baseline BEFORE the per-city geo fix, so we can verify nothing
 * regresses afterward.
 *
 * How to run:
 *   1. Open the Apps Script editor for the CompassEats sheet.
 *   2. Add this as a new file (or paste it at the bottom of any existing one).
 *   3. Select "geoFixDiagnostic" in the function dropdown and click Run.
 *   4. Open the execution log (View → Logs, or the run panel) and copy ALL of
 *      the output back to me.
 *
 * It only calls getValues / getLastRow / Logger.log. It writes nothing.
 */
function geoFixDiagnostic() {
  var ss = SpreadsheetApp.getActive();
  var out = [];
  function line(s) { out.push(s); }

  // ── 1) Row-count baseline ────────────────────────────────────────────────
  function rowCount(tab) {
    var sh = ss.getSheetByName(tab);
    if (!sh) return tab + ': (tab NOT FOUND)';
    return tab + ': ' + Math.max(0, sh.getLastRow() - 1) + ' rows';
  }
  line('=== ROW COUNTS (baseline — these should hold after the fix) ===');
  line(rowCount('venues'));
  line(rowCount('needs_enrichment'));
  line(rowCount('Places Enrichment'));
  line(rowCount('enrichment_review'));
  line(rowCount('closed_venues'));

  // Probe terms. Matched as lowercase SUBSTRINGS so accent/space quirks still
  // hit (e.g. "Jordnær" normalizes to "jordn r", "Fat Duck" to "fat duck").
  var probes = ['atlas', 'bacchanalia', 'jordn', 'fat duck'];

  // ── 2) Places Enrichment: how many rows per probe, and do namesakes share one? ──
  var pe = ss.getSheetByName('Places Enrichment');
  if (pe) {
    // Columns: normalizedKey(0) canonicalName(1) sheetName(2) placeId(3)
    //          lat(4) lng(5) photoName(6) formattedAddress(7) businessStatus(8) lastVerified(9)
    var pv = pe.getDataRange().getValues();
    for (var p = 0; p < probes.length; p++) {
      var needle = probes[p];
      line('');
      line('=== Places Enrichment — normalizedKey contains "' + needle + '" ===');
      var hits = 0;
      for (var r = 1; r < pv.length; r++) {
        var keyA = String(pv[r][0] || '').toLowerCase();
        if (keyA.indexOf(needle) === -1) continue;
        hits++;
        line('  key="' + pv[r][0] + '" | name="' + pv[r][1] + '" | placeId=' +
             pv[r][3] + ' | addr="' + pv[r][7] + '"');
      }
      if (!hits) line('  (no matching rows)');
      else line('  --> ' + hits + ' row(s). One row shared by venues in different cities = the contamination.');
    }
  } else {
    line('');
    line('Places Enrichment tab NOT FOUND — check the exact tab name.');
  }

  // ── 3) venues: how many venue rows per probe, and under which city_slugs ──
  var v = ss.getSheetByName('venues');
  if (v) {
    var vv = v.getDataRange().getValues();
    var hdr = vv[0].map(function (h) { return String(h).toLowerCase(); });
    var iName = hdr.indexOf('name');
    var iCity = hdr.indexOf('city_slug');
    for (var q = 0; q < probes.length; q++) {
      var needle2 = probes[q];
      line('');
      line('=== venues — name contains "' + needle2 + '" ===');
      var h2 = 0;
      for (var rr = 1; rr < vv.length; rr++) {
        var nm = String(vv[rr][iName] || '').toLowerCase();
        if (nm.indexOf(needle2) === -1) continue;
        h2++;
        line('  name="' + vv[rr][iName] + '" | city_slug="' + vv[rr][iCity] + '"');
      }
      if (!h2) line('  (no matching rows)');
    }
  } else {
    line('');
    line('venues tab NOT FOUND — check the exact tab name.');
  }

  Logger.log(out.join('\n'));
}
