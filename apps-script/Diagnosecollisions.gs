/**
 * diagnoseCollisions() — READ-ONLY analysis (no API cost, no data changes).
 * ======================================================================
 * Lists every remaining cross-city pin collision (same Google place `id`
 * under 2+ distinct city_slugs) into a fresh `collision_diagnose` tab, and
 * pops a summary that splits them into:
 *
 *   MIXED  — one pin shared by 2+ DIFFERENT venue names  → poisoning (the old
 *            bug stamped one restaurant's identity onto another). Fix = remove
 *            the bad Places Enrichment row / re-pin the wrong one.
 *   SAME   — one pin, SAME name across cities            → genuine branch that
 *            still shares a pin, or a city-label alias. Fix = re-pin per city.
 *
 * Only ADDS the `collision_diagnose` tab. Never edits venues or anything else.
 * Export that tab afterward and it becomes the cleanup worklist.
 */
function diagnoseCollisions() {
  var ss = SpreadsheetApp.getActive();
  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab.');
  var vv = v.getDataRange().getValues();
  var H = {};
  vv[0].forEach(function (h, i) { H[String(h).trim().toLowerCase()] = i; });

  function col(cands) {
    for (var i = 0; i < cands.length; i++) if (cands[i] in H) return H[cands[i]];
    return -1;
  }
  var iId    = col(['id', 'place_id', 'google_place_id', 'placeid']);
  var iName  = col(['name']);
  var iCityS = col(['city_slug', 'cityslug']);
  var iCityD = col(['city_display', 'citydisplay', 'city']);
  var iSlug  = col(['slug']);
  var iAddr  = col(['address', 'formattedaddress', 'formatted_address']);

  if (iId < 0 || iName < 0 || iCityS < 0) {
    throw new Error('venues tab missing id/name/city_slug. Headers: ' + Object.keys(H).join(', '));
  }
  function norm(s) {
    return String(s || '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').replace(/\s+/g, ' ').trim();
  }

  // group rows by pin id
  var groups = {}; // id -> [rowObj,...]
  for (var r = 1; r < vv.length; r++) {
    var id = String(vv[r][iId] || '').trim();
    if (!id) continue;
    var obj = {
      id: id,
      name: String(vv[r][iName] || '').trim(),
      cityD: iCityD >= 0 ? String(vv[r][iCityD] || '').trim() : '',
      cityS: String(vv[r][iCityS] || '').trim(),
      slug: iSlug >= 0 ? String(vv[r][iSlug] || '').trim() : '',
      addr: iAddr >= 0 ? String(vv[r][iAddr] || '').trim() : ''
    };
    (groups[id] = groups[id] || []).push(obj);
  }

  // keep only groups spanning 2+ distinct city_slugs; classify each
  var out = [];
  var nMixed = 0, nSame = 0, rowsMixed = 0, rowsSame = 0;
  var examplesMixed = [], examplesSame = [];

  Object.keys(groups).forEach(function (id) {
    var rows = groups[id];
    var cities = {}; rows.forEach(function (o) { cities[o.cityS] = true; });
    if (Object.keys(cities).length < 2) return; // not a cross-city collision

    var names = {}; rows.forEach(function (o) { names[norm(o.name)] = true; });
    var distinctNames = Object.keys(names).length;
    var category = distinctNames > 1 ? 'MIXED' : 'SAME';
    if (category === 'MIXED') { nMixed++; rowsMixed += rows.length; }
    else { nSame++; rowsSame += rows.length; }

    // build an example line for the summary
    var ex = rows.map(function (o) { return o.name + ' @ ' + (o.cityD || o.cityS); }).join('  |  ');
    if (category === 'MIXED' && examplesMixed.length < 5) examplesMixed.push('• ' + ex);
    if (category === 'SAME'  && examplesSame.length  < 5) examplesSame.push('• ' + ex);

    rows.forEach(function (o) {
      out.push([category, id, Object.keys(cities).length, distinctNames,
                o.name, o.cityD, o.cityS, o.slug, o.addr]);
    });
  });

  // sort MIXED first, then by pin so group members sit together
  out.sort(function (a, b) {
    if (a[0] !== b[0]) return a[0] === 'MIXED' ? -1 : 1;
    return a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0;
  });

  // write the tab
  var tab = ss.getSheetByName('collision_diagnose');
  if (tab) tab.clear(); else tab = ss.insertSheet('collision_diagnose');
  var header = ['category', 'pin_id', 'n_cities', 'n_distinct_names',
                'name', 'city_display', 'city_slug', 'slug', 'address'];
  tab.getRange(1, 1, 1, header.length).setValues([header]).setFontWeight('bold');
  tab.setFrozenRows(1);
  if (out.length) tab.getRange(2, 1, out.length, header.length).setValues(out);

  var msg = '=== Collision Diagnosis ===\n\n' +
    'Total cross-city pin collisions: ' + (nMixed + nSame) + ' groups\n\n' +
    'MIXED (different names on one pin = POISONING): ' + nMixed + ' groups, ' + rowsMixed + ' rows\n' +
    'SAME  (same name across cities = branch/alias): ' + nSame + ' groups, ' + rowsSame + ' rows\n\n' +
    'Full listing written to the `collision_diagnose` tab.\n\n' +
    '--- sample MIXED (poisoning) ---\n' + (examplesMixed.join('\n') || '(none)') + '\n\n' +
    '--- sample SAME (branch/alias) ---\n' + (examplesSame.join('\n') || '(none)');
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
