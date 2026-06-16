/**
 * CompassEats — Collision Audit (READ-ONLY diagnostic)
 * Finds venues whose awards came from same-name venues in DIFFERENT cities.
 * Writes a `collision_audit` tab. Touches nothing else.
 */
function auditCollisions() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab. Run reshape first.');

  // Index the raw award tabs by normalized name -> set of cities that name appears in.
  // We reuse the same SOURCE_MAP + parseRow_ from reshape (same project, shared scope).
  var nameCities = {}; // normName -> { cityNorm: true }
  for (var tabName in SOURCE_MAP) {
    var sheet = findSheet_(ss, tabName);
    if (!sheet) continue;
    var slug = SOURCE_MAP[tabName][0];
    var defYear = SOURCE_MAP[tabName][1];
    var vals = sheet.getDataRange().getValues();
    for (var i = 1; i < vals.length; i++) {
      var row = vals[i];
      if (!row || row.join('') === '') continue;
      var rec = parseRow_(tabName, slug, defYear, row);
      if (!rec || !rec.name) continue;
      var nk = normKey_(rec.name);
      var ck = normKey_(rec.city || '');
      if (!nameCities[nk]) nameCities[nk] = {};
      if (ck) nameCities[nk][ck] = true;
    }
  }

  // Any normalized name that appears in 2+ distinct cities is a collision risk.
  var out = [['normalized_name', 'distinct_city_count', 'cities']];
  var keys = Object.keys(nameCities).sort();
  var risk = 0;
  for (var k = 0; k < keys.length; k++) {
    var cities = Object.keys(nameCities[keys[k]]);
    if (cities.length >= 2) {
      out.push([keys[k], cities.length, cities.join(' | ')]);
      risk++;
    }
  }

  var sheet = ss.getSheetByName('collision_audit');
  if (sheet) sheet.clear(); else sheet = ss.insertSheet('collision_audit');
  sheet.getRange(1, 1, out.length, 3).setValues(out);
  sheet.getRange(1, 1, 1, 3).setFontWeight('bold');
  sheet.setFrozenRows(1);
  sheet.setColumnWidth(1, 240);
  sheet.setColumnWidth(3, 500);

  SpreadsheetApp.getUi().alert(
    'Collision audit complete.\n\n' +
    'Names appearing in 2+ cities (collision risk): ' + risk + '\n\n' +
    'These are every venue name where reshape\'s name-only matching could ' +
    'staple one city\'s awards onto another. Open the collision_audit tab.');
}
