/**
 * generateCityAliases() — READ-ONLY. Writes nothing. Prints a proposed
 * CITY_ALIASES_ block plus review lists, for you to inspect before pasting
 * anything into reshape.
 *
 * WHAT IT DOES
 *   Recomputes the cross-city place_id groups straight from the venues tab
 *   (same logic the merge uses), then for each group measures how far each
 *   city label sits from the place's real location (city centroid vs the
 *   place_id's own coordinate). It splits each group into:
 *     • ADJACENT labels  -> one real place under nearby labels = a TRUE SPLIT.
 *                            Proposes aliasing the smaller labels into the
 *                            busiest one (the canonical metro).
 *     • FAR labels       -> a different place still sharing this place_id from
 *                            a parked re-query (Xin Rong Ji pattern). FLAGGED
 *                            for a geo fix — never aliased.
 *   Michelin-resolving merges (the hidden-stars wins) are listed first.
 *
 * THRESHOLDS (distances shown so you can eyeball edge cases):
 *   NEAR_KM  = same place, alias.   FAR_KM = different place, flag.
 *   Anything between is printed in a GRAY-ZONE list for manual judgement.
 *
 * Reuses normKey_ from the project (for Michelin detection only).
 * RUN: generateCityAliases -> read the log -> we review before applying.
 */

var NEAR_KM = 50;    // <= this from the real place = treat as the same locale
var FAR_KM  = 150;   // >  this = a mis-pin (different place), flag for geo fix

function generateCityAliases() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName('venues');
  if (!sheet) throw new Error('No venues tab.');
  var vals = sheet.getDataRange().getValues();
  var H = {}; vals[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iId = H['id'], iSlug = H['slug'], iName = H['name'], iCity = H['city_slug'],
      iLat = H['lat'], iLng = H['lng'], iAwards = H['awards_json'];

  // Pass 1: per-city centroid + count; per place_id its coord + the cities it spans.
  var citySum = {};   // city_slug -> {latSum,lngSum,n}
  var pid = {};       // place_id  -> {lat,lng, cities:{city_slug:true}, michelinCities:{}, name}
  for (var i = 1; i < vals.length; i++) {
    var cs = String(vals[i][iCity] || '').trim();
    var la = Number(vals[i][iLat]), ln = Number(vals[i][iLng]);
    if (cs && isFinite(la) && isFinite(ln)) {
      if (!citySum[cs]) citySum[cs] = { latSum: 0, lngSum: 0, n: 0 };
      citySum[cs].latSum += la; citySum[cs].lngSum += ln; citySum[cs].n++;
    }
    var id = String(vals[i][iId] || '').trim();
    if (!id) continue;
    if (!pid[id]) pid[id] = { lat: la, lng: ln, cities: {}, mich: {}, name: String(vals[i][iName] || '') };
    if (cs) pid[id].cities[cs] = true;
    // Michelin on this row?
    var hasM = false;
    try {
      var arr = JSON.parse(vals[i][iAwards] || '[]');
      for (var a = 0; a < arr.length; a++)
        if (String(arr[a].source || '').toLowerCase().indexOf('michelin') !== -1) { hasM = true; break; }
    } catch (e) {}
    if (hasM && cs) pid[id].mich[cs] = true;
  }
  var centroid = {};
  Object.keys(citySum).forEach(function (cs) {
    centroid[cs] = { lat: citySum[cs].latSum / citySum[cs].n, lng: citySum[cs].lngSum / citySum[cs].n, n: citySum[cs].n };
  });

  function km(a, b) {
    if (!a || !b) return null;
    var R = 6371, dLat = (b.lat - a.lat) * Math.PI / 180, dLng = (b.lng - a.lng) * Math.PI / 180;
    var s = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(a.lat * Math.PI / 180) * Math.cos(b.lat * Math.PI / 180) *
            Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return Math.round(R * 2 * Math.atan2(Math.sqrt(s), Math.sqrt(1 - s)));
  }

  // Pass 2: classify each cross-city place_id group.
  var aliasProps = {};   // sourceCity -> {target, why, michelin}
  var grayZone = [];     // ambiguous distance, manual
  var misPins = [];      // far labels = geo fix
  var cleanGroups = 0, michGroups = 0;

  Object.keys(pid).forEach(function (id) {
    var g = pid[id];
    var cities = Object.keys(g.cities);
    if (cities.length < 2) return;
    var P = { lat: g.lat, lng: g.lng };

    var near = [], far = [], gray = [];
    cities.forEach(function (cs) {
      var d = km(centroid[cs], P);
      if (d === null) { gray.push([cs, 'no-coords']); return; }
      if (d <= NEAR_KM) near.push(cs);
      else if (d > FAR_KM) far.push([cs, d]);
      else gray.push([cs, d + 'km']);
    });

    var hasMich = Object.keys(g.mich).length > 0;
    if (hasMich) michGroups++;

    // canonical among the NEAR labels = busiest city
    if (near.length >= 2) {
      var canon = near[0];
      near.forEach(function (cs) { if ((centroid[cs] ? centroid[cs].n : 0) > (centroid[canon] ? centroid[canon].n : 0)) canon = cs; });
      near.forEach(function (cs) {
        if (cs === canon) return;
        aliasProps[cs] = { target: canon, why: g.name + (hasMich ? ' [MICHELIN]' : ''),
                           michelin: hasMich, cnt: (centroid[cs] ? centroid[cs].n : 0), tcnt: (centroid[canon] ? centroid[canon].n : 0) };
      });
      cleanGroups++;
    }
    far.forEach(function (f) { misPins.push([id, g.name, f[0], f[1], 'near=' + near.join('/')]); });
    gray.forEach(function (gr) { grayZone.push([id, g.name, gr[0], gr[1], 'near=' + near.join('/'), hasMich]); });
  });

  // Detect conflicts: a city used as BOTH a source and a target, or mapped to >1 target.
  var targets = {}; Object.keys(aliasProps).forEach(function (s) { targets[aliasProps[s].target] = true; });
  var conflicts = [];
  Object.keys(aliasProps).forEach(function (s) { if (targets[s]) conflicts.push(s + ' is both a source and a target'); });

  // ---- Build report ----
  var L = [];
  L.push('=== CITY ALIAS PROPOSALS (read-only) ===');
  L.push('cross-city place_id groups with >=2 near labels (true splits): ' + cleanGroups);
  L.push('  of those resolving a Michelin venue: ' + michGroups);
  L.push('proposed alias entries: ' + Object.keys(aliasProps).length +
         '  |  gray-zone (manual): ' + grayZone.length + '  |  mis-pins (geo fix): ' + misPins.length);
  L.push('');

  // Alias block — Michelin first
  L.push("--- PROPOSED CITY_ALIASES_ ENTRIES (paste-ready; review first) ---");
  var srcs = Object.keys(aliasProps).sort(function (a, b) {
    if (aliasProps[a].michelin !== aliasProps[b].michelin) return aliasProps[a].michelin ? -1 : 1;
    return a < b ? -1 : 1;
  });
  srcs.slice(0, 400).forEach(function (s) {
    var p = aliasProps[s];
    L.push("  '" + s + "': '" + p.target + "',   // " + p.why + "  (" + s + ' ' + p.cnt + ' -> ' + p.target + ' ' + p.tcnt + ')');
  });
  if (srcs.length > 400) L.push('  … (' + (srcs.length - 400) + ' more)');

  L.push('');
  L.push('--- CONFLICTS to resolve by hand (' + conflicts.length + ') ---');
  conflicts.slice(0, 50).forEach(function (c) { L.push('  ' + c); });

  L.push('');
  L.push('--- GRAY ZONE: ' + NEAR_KM + '-' + FAR_KM + 'km, decide by hand (' + grayZone.length + ') ---');
  grayZone.slice(0, 80).forEach(function (g) {
    L.push('  ' + g[1] + '  city="' + g[2] + '" dist=' + g[3] + (g[5] ? ' [MICHELIN]' : '') + '  ' + g[4]);
  });
  if (grayZone.length > 80) L.push('  … (' + (grayZone.length - 80) + ' more)');

  L.push('');
  L.push('--- MIS-PINS: far label sharing a place_id, needs geo fix NOT alias (' + misPins.length + ') ---');
  misPins.slice(0, 80).forEach(function (m) {
    L.push('  ' + m[1] + '  far-city="' + m[2] + '" ' + m[3] + 'km from place  (' + m[4] + ')');
  });
  if (misPins.length > 80) L.push('  … (' + (misPins.length - 80) + ' more)');

  Logger.log(L.join('\n'));
}
