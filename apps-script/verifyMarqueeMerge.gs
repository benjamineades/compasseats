/**
 * verifyMarqueeMerge() — READ-ONLY. Confirms the marquee true-splits merged
 * into one venue each, with their Michelin award intact.
 *
 * After the alias block + reshape, each famous venue below should show ONE
 * active row with michelin=YES (the stars are restored in the data). If a
 * venue still shows two rows, its alias didn't take — tell me which.
 *
 * (Live-site stars are a separate downstream step: regenerate the JSON and
 * publish as usual. This only confirms the underlying data is fixed.)
 */
function verifyMarqueeMerge() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var v = ss.getSheetByName('venues');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iName = H['name'], iCity = H['city_slug'], iStatus = H['status'], iAwards = H['awards_json'];

  function hasMich(j) {
    try { var a = JSON.parse(j || '[]'); for (var i = 0; i < a.length; i++)
      if (String(a[i].source || '').toLowerCase().indexOf('michelin') !== -1) return true; } catch (e) {}
    return false;
  }

  var probes = ['jordn', 'fat duck', 'enclume', 'waterside', 'bocuse',
                'kitchin', 'blue hill', 'paix', 'humus'];
  var out = ['=== MARQUEE MERGE CHECK (after alias + reshape) ==='];
  probes.forEach(function (p) {
    out.push('--- "' + p + '" ---');
    var any = false;
    for (var r = 1; r < vv.length; r++) {
      var nm = String(vv[r][iName] || '').toLowerCase();
      if (nm.indexOf(p) === -1) continue;
      any = true;
      out.push('  name="' + vv[r][iName] + '"  city_slug="' + vv[r][iCity] +
               '"  status=' + vv[r][iStatus] + '  michelin=' + (hasMich(vv[r][iAwards]) ? 'YES' : 'no'));
    }
    if (!any) out.push('  (none found)');
  });
  Logger.log(out.join('\n'));
}
