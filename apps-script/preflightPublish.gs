/**
 * Read-only pre-publish check. Mirrors the two build-FAILING checks in
 * scripts/sync-sheet.ts so we catch problems in the Sheet before deploying:
 *   (1) duplicate venue keys  -> key = city_slug/slug   (sync line ~360)
 *   (2) orphan city_slug      -> venue city_slug not present in cities tab (line ~383)
 * Run AFTER generateCitiesTab. Writes nothing.
 */
function preflightPublish() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  var vv = ss.getSheetByName('venues').getDataRange().getValues();
  var VH = {}; vv[0].forEach(function (h, i) { VH[String(h).toLowerCase()] = i; });
  var iSlug = VH['slug'], iCity = VH['city_slug'], iName = VH['name'];

  var cvv = ss.getSheetByName('cities').getDataRange().getValues();
  var CH = {}; cvv[0].forEach(function (h, i) { CH[String(h).toLowerCase()] = i; });
  var iCSlug = CH['slug'];
  var citySlugs = {};
  for (var r = 1; r < cvv.length; r++) {
    var s = String(cvv[r][iCSlug] || '').trim().toLowerCase();
    if (s) citySlugs[s] = true;
  }

  var seen = {}, dupes = {}, orphans = {}, total = 0;
  for (var r2 = 1; r2 < vv.length; r2++) {
    var slug = String(vv[r2][iSlug] || '').trim().toLowerCase();
    var city = String(vv[r2][iCity] || '').trim().toLowerCase();
    if (!slug && !city) continue;
    total++;
    var key = city + '/' + slug;
    if (seen[key]) dupes[key] = (dupes[key] || 1) + 1; else seen[key] = 1;
    if (city && !citySlugs[city]) {
      if (!orphans[city]) orphans[city] = [];
      if (orphans[city].length < 5) orphans[city].push(String(vv[r2][iName] || ''));
    }
  }

  var dupKeys = Object.keys(dupes), orphCities = Object.keys(orphans);
  var L = ['=== preflightPublish ==='];
  L.push('venues checked: ' + total + '  |  cities tab slugs: ' + Object.keys(citySlugs).length);
  L.push('');
  L.push('(1) DUPLICATE city/slug keys: ' + dupKeys.length + (dupKeys.length ? '   <-- MUST FIX (build will fail)' : '   OK'));
  dupKeys.slice(0, 40).forEach(function (k) { L.push('     ' + k + '  (x' + (dupes[k]) + ')'); });
  L.push('');
  L.push('(2) ORPHAN city_slugs not in cities tab: ' + orphCities.length + (orphCities.length ? '   <-- MUST FIX (build will fail)' : '   OK'));
  orphCities.slice(0, 40).forEach(function (c) { L.push('     ' + c + '  e.g. ' + orphans[c].join(', ')); });
  L.push('');
  L.push(dupKeys.length || orphCities.length ? '>>> Resolve the above before publishing.' : '>>> Clean — safe to publish.');
  Logger.log(L.join('\n'));
}
