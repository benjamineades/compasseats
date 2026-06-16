/**
 * City-alias generator v2 — geocode-validated.
 * =============================================================================
 * Fixes the v1 flaw: instead of trusting venue-derived centroids (which sit ON
 * the mis-pin when a city has one contaminated venue), this geocodes each
 * city's REAL location, independent of the venues, and validates adjacency
 * against that. A mis-pin (Domodossola sharing a Chicago place_id) lands
 * thousands of km away and is flagged, never aliased.
 *
 * TWO STEPS:
 *   1. geocodeAliasCities()      — geocode every city in a cross-city group;
 *                                  cached + resumable. Repeat until "remaining: 0".
 *   2. generateCityAliasesV2()   — classify and write a paste-ready, SPACE-FORM
 *                                  alias block to the "alias_proposals" tab,
 *                                  plus a log of conflicts / gray zone / mis-pins.
 *
 * SAFE: read-only on venues. Writes only to helper tabs (geo_city_cache,
 * alias_proposals). Touches nothing in reshape until you paste the block.
 *
 * Needs GEOAPIFY_KEY in Script Properties (the geocoder's key).
 */

var AV2_CACHE_TAB = 'geo_city_cache';
var AV2_BATCH     = 350;    // geocodes per run (stays under the 6-min limit)
var AV2_DELAY     = 250;    // ms between calls (safe for Geoapify free tier)
var AV2_NEAR_KM   = 20;     // <= this from the real place = same locale, alias
var AV2_FAR_KM    = 60;    // >  this = different place, mis-pin (geo cleanup)
var AV2_COARSE    = { state: 1, county: 1, country: 1, region: 1, province: 1 };

// ---- STEP 1: geocode the cities in cross-city groups (cached, resumable) ----
function geocodeAliasCities() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var key = PropertiesService.getScriptProperties().getProperty('GEOAPIFY_KEY');
  if (!key) throw new Error('No GEOAPIFY_KEY in Script Properties.');

  var v = ss.getSheetByName('venues');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iId = H['id'], iCity = H['city_slug'], iDisp = H['city_display'], iCountry = H['country'];

  var cityByPid = {}, slugInfo = {};
  for (var r = 1; r < vv.length; r++) {
    var cs = String(vv[r][iCity] || '').trim();
    if (cs && !slugInfo[cs]) slugInfo[cs] = { disp: String(vv[r][iDisp] || '').trim(), country: String(vv[r][iCountry] || '').trim() };
    var id = String(vv[r][iId] || '').trim(); if (!id || !cs) continue;
    (cityByPid[id] = cityByPid[id] || {})[cs] = true;
  }
  var need = {};
  Object.keys(cityByPid).forEach(function (id) {
    var cs = Object.keys(cityByPid[id]); if (cs.length < 2) return;
    cs.forEach(function (c) { need[c] = true; });
  });

  var cache = ss.getSheetByName(AV2_CACHE_TAB), done = {};
  if (!cache) {
    cache = ss.insertSheet(AV2_CACHE_TAB);
    cache.getRange(1, 1, 1, 6).setValues([['city_slug', 'query', 'lat', 'lng', 'result_type', 'when']]).setFontWeight('bold');
    cache.setFrozenRows(1);
  } else {
    var cv = cache.getDataRange().getValues();
    for (var i = 1; i < cv.length; i++) if (cv[i][0]) done[String(cv[i][0])] = true;
  }

  var todo = Object.keys(need).filter(function (c) { return !done[c]; });
  var rows = [], looked = 0, today = new Date().toISOString().slice(0, 10);
  for (var t = 0; t < todo.length; t++) {
    if (looked >= AV2_BATCH) break;
    var cs2 = todo[t], info = slugInfo[cs2] || {};
    var q = (info.disp || cs2.replace(/-/g, ' ')) + (info.country ? (', ' + info.country) : '');
    var g = aliasGeoapify_(q, key);
    looked++; Utilities.sleep(AV2_DELAY);
    rows.push(g ? [cs2, q, g.lat, g.lng, g.type, today] : [cs2, q, '', '', 'NORESULT', today]);
  }
  if (rows.length) cache.getRange(cache.getLastRow() + 1, 1, rows.length, 6).setValues(rows);

  var remaining = todo.length - looked;
  var msg = 'geocodeAliasCities\ndistinct cross-city cities: ' + Object.keys(need).length +
    '\ngeocoded this run: ' + looked + '\nremaining: ' + Math.max(0, remaining) + '\n\n' +
    (remaining > 0 ? 'Run geocodeAliasCities AGAIN to continue.' : 'Done — now run generateCityAliasesV2.');
  Logger.log(msg); SpreadsheetApp.getUi().alert(msg);
}

function aliasGeoapify_(query, key) {
  var url = 'https://api.geoapify.com/v1/geocode/search?text=' + encodeURIComponent(query) +
            '&format=geojson&limit=1&apiKey=' + encodeURIComponent(key);
  try {
    var resp = UrlFetchApp.fetch(url, { muteHttpExceptions: true });
    if (resp.getResponseCode() !== 200) return null;
    var d = JSON.parse(resp.getContentText());
    if (!d.features || !d.features.length) return null;
    var p = d.features[0].properties || {};
    if (p.lat === undefined || p.lon === undefined) return null;
    return { lat: p.lat, lng: p.lon, type: String(p.result_type || '') };
  } catch (e) { return null; }
}

// ---- STEP 2: classify + write paste-ready alias block ----
function generateCityAliasesV2() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var v = ss.getSheetByName('venues');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iId = H['id'], iName = H['name'], iCity = H['city_slug'], iLat = H['lat'], iLng = H['lng'], iAwards = H['awards_json'];

  var cache = ss.getSheetByName(AV2_CACHE_TAB);
  if (!cache) throw new Error('No geo_city_cache. Run geocodeAliasCities first.');
  var cv = cache.getDataRange().getValues(), geo = {};
  for (var i = 1; i < cv.length; i++) {
    var cs = String(cv[i][0]); if (!cs) continue;
    var la = Number(cv[i][2]), ln = Number(cv[i][3]);
    geo[cs] = { lat: la, lng: ln, type: String(cv[i][4] || ''), ok: isFinite(la) && isFinite(ln) };
  }

  function mich(j) { try { var a = JSON.parse(j || '[]'); for (var k = 0; k < a.length; k++) if (String(a[k].source || '').toLowerCase().indexOf('michelin') !== -1) return true; } catch (e) {} return false; }
  var cityCount = {}, pid = {};
  for (var r = 1; r < vv.length; r++) {
    var cs2 = String(vv[r][iCity] || '').trim(); if (cs2) cityCount[cs2] = (cityCount[cs2] || 0) + 1;
    var id = String(vv[r][iId] || '').trim(); if (!id) continue;
    var la2 = Number(vv[r][iLat]), ln2 = Number(vv[r][iLng]);
    if (!pid[id]) pid[id] = { lat: la2, lng: ln2, cities: {}, m: {}, name: String(vv[r][iName] || '') };
    if (cs2) pid[id].cities[cs2] = true;
    if (cs2 && mich(vv[r][iAwards])) pid[id].m[cs2] = true;
  }

  function km(a, b) {
    var R = 6371, d1 = (b.lat - a.lat) * Math.PI / 180, d2 = (b.lng - a.lng) * Math.PI / 180;
    var s = Math.sin(d1 / 2) * Math.sin(d1 / 2) + Math.cos(a.lat * Math.PI / 180) * Math.cos(b.lat * Math.PI / 180) * Math.sin(d2 / 2) * Math.sin(d2 / 2);
    return Math.round(R * 2 * Math.atan2(Math.sqrt(s), Math.sqrt(1 - s)));
  }

  var props = {}, gray = [], misPins = [], michCount = 0, clean = 0;
  Object.keys(pid).forEach(function (id) {
    var g = pid[id], cities = Object.keys(g.cities); if (cities.length < 2) return;
    var P = { lat: g.lat, lng: g.lng }; if (!isFinite(P.lat) || !isFinite(P.lng)) return;
    var hasM = Object.keys(g.m).length > 0; if (hasM) michCount++;

    var near = [], far = [], gr = [];
    cities.forEach(function (cs) {
      var gc = geo[cs];
      if (!gc || !gc.ok) { gr.push([cs, 'no-geocode']); return; }
      if (AV2_COARSE[gc.type]) { gr.push([cs, 'coarse:' + gc.type]); return; }
      var d = km(gc, P);
      if (d <= AV2_NEAR_KM) near.push(cs);
      else if (d > AV2_FAR_KM) far.push([cs, d]);
      else gr.push([cs, d + 'km']);
    });

    if (near.length >= 2) {
      var canon = near[0];
      near.forEach(function (cs) { if ((cityCount[cs] || 0) > (cityCount[canon] || 0)) canon = cs; });
      near.forEach(function (cs) {
        if (cs === canon) return;
        props[cs.replace(/-/g, ' ')] = { target: canon.replace(/-/g, ' '), name: g.name, mich: hasM, cnt: (cityCount[cs] || 0), tcnt: (cityCount[canon] || 0) };
      });
      clean++;
    }
    far.forEach(function (f) { misPins.push([g.name, f[0], f[1], 'near=' + near.join('/')]); });
    gr.forEach(function (x) { gray.push([g.name, x[0], x[1], hasM ? '[MICH]' : '']); });
  });

  var targets = {}; Object.keys(props).forEach(function (s) { targets[props[s].target] = true; });
  var conflicts = []; Object.keys(props).forEach(function (s) { if (targets[s]) conflicts.push("'" + s + "' is both a source and a target"); });

  var srcs = Object.keys(props).sort(function (a, b) { if (props[a].mich !== props[b].mich) return props[a].mich ? -1 : 1; return a < b ? -1 : 1; });
  var prop = ss.getSheetByName('alias_proposals'); if (prop) prop.clear(); else prop = ss.insertSheet('alias_proposals');
  prop.getRange(1, 1, 1, 2).setValues([['paste_into_CITY_ALIASES_  (copy this column, rows 2+)', 'note']]).setFontWeight('bold');
  var pr = srcs.map(function (s) { var p = props[s]; return ["  '" + s + "': '" + p.target + "',", p.name + (p.mich ? ' [MICHELIN]' : '') + ' (' + s + ' ' + p.cnt + ' -> ' + p.target + ' ' + p.tcnt + ')']; });
  if (pr.length) prop.getRange(2, 1, pr.length, 2).setValues(pr);
  prop.setFrozenRows(1);

  var L = ['=== generateCityAliasesV2 ==='];
  L.push('clean true-split groups: ' + clean + '  |  proposed alias entries: ' + srcs.length + '  (full block in "alias_proposals" tab, column A rows 2+)');
  L.push('groups touching Michelin: ' + michCount);
  L.push('gray-zone/coarse (manual): ' + gray.length + '  |  mis-pins (geo cleanup): ' + misPins.length + '  |  conflicts: ' + conflicts.length);
  L.push('\n--- SAMPLE proposed aliases (first 30; full list in the tab) ---');
  srcs.slice(0, 30).forEach(function (s) { var p = props[s]; L.push("  '" + s + "': '" + p.target + "',   // " + p.name + (p.mich ? ' [MICH]' : '')); });
  L.push('\n--- CONFLICTS to resolve by hand (' + conflicts.length + ') ---');
  conflicts.slice(0, 40).forEach(function (c) { L.push('  ' + c); });
  L.push('\n--- GRAY ZONE / COARSE LABELS, not auto-aliased (' + gray.length + ') ---');
  gray.slice(0, 60).forEach(function (x) { L.push('  ' + x[0] + '  "' + x[1] + '" ' + x[2] + ' ' + x[3]); });
  if (gray.length > 60) L.push('  ... (+' + (gray.length - 60) + ' more)');
  L.push('\n--- MIS-PINS far from place, geo cleanup not alias (' + misPins.length + ') ---');
  misPins.slice(0, 60).forEach(function (m) { L.push('  ' + m[0] + '  far="' + m[1] + '" ' + m[2] + 'km'); });
  if (misPins.length > 60) L.push('  ... (+' + (misPins.length - 60) + ' more)');
  Logger.log(L.join('\n'));
}
