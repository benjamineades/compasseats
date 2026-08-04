/**
 * exportMichelinNeedsPrice.gs
 * READ-ONLY. Creates/overwrites a tab called "price_needed_michelin".
 * Touches nothing else.
 */
function exportMichelinNeedsPrice() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sh = ss.getSheetByName('venues');
  if (!sh) { Logger.log('ERROR: no tab named "venues"'); return; }

  var data = sh.getDataRange().getValues();
  var head = data[0].map(function (h) { return String(h).trim().toLowerCase(); });
  Logger.log('HEADERS: ' + head.join(' | '));

  function col(names) {
    for (var i = 0; i < names.length; i++) {
      var idx = head.indexOf(names[i]);
      if (idx > -1) return idx;
    }
    return -1;
  }

  var cName  = col(['name', 'venue_name']);
  var cCity  = col(['city', 'city_display']);
  var cSlug  = col(['city_slug']);
  var cCtry  = col(['country']);
  var cPrice = col(['price_tier', 'price_level', 'price']);
  var cAward = col(['awards', 'award_sources', 'accolades', 'source_slug']);

  Logger.log('COLS -> name:' + cName + ' city:' + cCity + ' country:' + cCtry +
             ' price:' + cPrice + ' awards:' + cAward);

  if (cName < 0 || cPrice < 0) {
    Logger.log('ERROR: could not find a name or price column. Send me the HEADERS line above.');
    return;
  }

  var out = [['name', 'city', 'country', 'city_slug']];
  var scanned = 0;
  for (var r = 1; r < data.length; r++) {
    var row = data[r];
    if (String(row[cPrice] || '').trim() !== '') continue;
    var awardText = cAward > -1 ? String(row[cAward] || '') : row.join(' ');
    if (awardText.toLowerCase().indexOf('michelin') === -1) continue;
    scanned++;
    out.push([
      row[cName],
      cCity > -1 ? row[cCity] : '',
      cCtry > -1 ? row[cCtry] : '',
      cSlug > -1 ? row[cSlug] : ''
    ]);
  }

  var tab = ss.getSheetByName('price_needed_michelin');
  if (tab) { tab.clear(); } else { tab = ss.insertSheet('price_needed_michelin'); }
  tab.getRange(1, 1, out.length, out[0].length).setValues(out);

  Logger.log('DONE. ' + scanned + ' Michelin venues missing a price tier -> tab "price_needed_michelin"');
}
