/**
 * CompassEats — Geo & Dupe Audit (READ-ONLY)
 * Issue A: rows sharing a place_id across different city_slugs (wrong pin).
 * Issue B: same name+city appearing as 2+ rows (split same venue).
 * Writes `geo_audit` and `dupe_audit`. Touches nothing else.
 */
function auditGeoAndDupes() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab.');
  var vals = v.getDataRange().getValues();
  var H = {}; for (var c = 0; c < vals[0].length; c++) H[vals[0][c]] = c;

  var byId = {};       // place_id -> [ {name, city_slug, type, lat, lng} ]
  var byNameCity = {}; // nk(name)|city_slug -> count + sample

  for (var i = 1; i < vals.length; i++) {
    var row = vals[i];
    var id = row[H['id']];
    var name = row[H['name']];
    var cs = row[H['city_slug']];
    var nk = normKey_(name); // reshape's helper, shared in project scope

    if (id) {
      if (!byId[id]) byId[id] = [];
      byId[id].push({ name: name, city_slug: cs, type: row[H['type']],
                      lat: row[H['lat']], lng: row[H['lng']] });
    }
    var key = nk + '|' + cs;
    if (!byNameCity[key]) byNameCity[key] = [];
    byNameCity[key].push({ name: name, city_slug: cs, slug: row[H['slug']],
                           awards: row[H['awards_json']] });
  }

  // Issue A
  var geoOut = [['place_id', 'distinct_cities', 'rows', 'detail']];
  for (var id2 in byId) {
    var grp = byId[id2];
    var cities = {}; for (var g = 0; g < grp.length; g++) cities[grp[g].city_slug] = true;
    if (Object.keys(cities).length >= 2) {
      var detail = grp.map(function (x) {
        return x.name + ' [' + x.city_slug + '] (' + x.lat + ',' + x.lng + ')';
      }).join('  ||  ');
      geoOut.push([id2, Object.keys(cities).length, grp.length, detail]);
    }
  }

  // Issue B
  var dupeOut = [['name', 'city_slug', 'row_count', 'slugs']];
  for (var k in byNameCity) {
    var arr = byNameCity[k];
    if (arr.length >= 2) {
      dupeOut.push([arr[0].name, arr[0].city_slug, arr.length,
                    arr.map(function (x) { return x.slug; }).join(', ')]);
    }
  }

  writeAudit_(ss, 'geo_audit', geoOut);
  writeAudit_(ss, 'dupe_audit', dupeOut);

  SpreadsheetApp.getUi().alert(
    'Geo & dupe audit complete.\n\n' +
    'Issue A (wrong pin — shared place_id across cities): ' + (geoOut.length - 1) + ' place_ids\n' +
    'Issue B (split same venue — name+city dupes): ' + (dupeOut.length - 1) + ' groups\n\n' +
    'See the geo_audit and dupe_audit tabs.');
}

function writeAudit_(ss, name, out) {
  var sh = ss.getSheetByName(name);
  if (sh) sh.clear(); else sh = ss.insertSheet(name);
  sh.getRange(1, 1, out.length, out[0].length).setValues(out);
  sh.getRange(1, 1, 1, out[0].length).setFontWeight('bold');
  sh.setFrozenRows(1);
  sh.setColumnWidth(out[0].length, 600);
}
