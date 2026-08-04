/**
 * exportMichelinNeedsPrice_v2.gs
 * READ-ONLY. Creates/overwrites tab "price_needed_michelin".
 * Reads: venues, Places Enrichment. Writes: nothing else.
 */
function exportMichelinNeedsPrice_v2() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  function keyOf(name, city) {
    var n = String(name || '').toLowerCase().replace(/[^a-z0-9]/g, '');
    if (!n) n = String(name || '').trim().toLowerCase();   // non-Latin fallback
    var c = String(city || '').toLowerCase().replace(/[^a-z0-9]/g, '');
    return n + '|' + c;
  }
  function findCol(head, names) {
    for (var i = 0; i < names.length; i++) {
      var idx = head.indexOf(names[i]);
      if (idx > -1) return idx;
    }
    return -1;
  }

  // ---- Places Enrichment: which venues already have a price? ----
  var pe = ss.getSheetByName('Places Enrichment');
  var priced = {};
  var pricedCount = 0;
  if (!pe) {
    Logger.log('WARN: no tab named "Places Enrichment" — skipping the dedupe check.');
  } else {
    var pd = pe.getDataRange().getValues();
    var ph = pd[0].map(function (h) { return String(h).trim().toLowerCase(); });
    Logger.log('PE HEADERS: ' + ph.join(' | '));
    var pName  = findCol(ph, ['name', 'venue_name']);
    var pCity  = findCol(ph, ['city', 'city_display', 'city_slug']);
    var pPrice = findCol(ph, ['price_level', 'price_tier', 'price']);
    Logger.log('PE COLS -> name:' + pName + ' city:' + pCity + ' price:' + pPrice);
    if (pName > -1 && pPrice > -1) {
      for (var i = 1; i < pd.length; i++) {
        if (String(pd[i][pPrice] || '').trim() === '') continue;
        priced[keyOf(pd[i][pName], pCity > -1 ? pd[i][pCity] : '')] = true;
        pricedCount++;
      }
    } else {
      Logger.log('WARN: could not locate name/price on Places Enrichment. Send me PE HEADERS above.');
    }
  }
  Logger.log('Places Enrichment rows carrying a price: ' + pricedCount);

  // ---- venues ----
  var sh = ss.getSheetByName('venues');
  var data = sh.getDataRange().getValues();
  var head = data[0].map(function (h) { return String(h).trim().toLowerCase(); });

  var cName  = findCol(head, ['name']);
  var cCity  = findCol(head, ['city_display', 'city']);
  var cSlug  = findCol(head, ['city_slug']);
  var cCtry  = findCol(head, ['country']);
  var cPrice = findCol(head, ['price_tier']);
  var cAward = findCol(head, ['awards_json', 'awards']);
  Logger.log('V COLS -> name:' + cName + ' city:' + cCity + ' slug:' + cSlug +
             ' country:' + cCtry + ' price:' + cPrice + ' awards:' + cAward);
  if (cAward < 0) { Logger.log('ERROR: no awards column found. Stopping.'); return; }

  var out = [['name', 'city', 'country', 'city_slug', 'match_key']];
  var michelinMissing = 0, alreadyPriced = 0;

  for (var r = 1; r < data.length; r++) {
    var row = data[r];
    if (String(row[cPrice] || '').trim() !== '') continue;
    if (String(row[cAward] || '').toLowerCase().indexOf('michelin') === -1) continue;
    michelinMissing++;

    var k = keyOf(row[cName], row[cCity]);
    if (priced[k]) { alreadyPriced++; continue; }

    out.push([row[cName], row[cCity], row[cCtry], row[cSlug], k]);
  }

  var tab = ss.getSheetByName('price_needed_michelin');
  if (tab) { tab.clear(); } else { tab = ss.insertSheet('price_needed_michelin'); }
  tab.getRange(1, 1, out.length, out[0].length).setValues(out);

  Logger.log('--- RESULT ---');
  Logger.log('Michelin venues with blank price_tier: ' + michelinMissing);
  Logger.log('  ...already priced in Places Enrichment: ' + alreadyPriced);
  Logger.log('  ...genuinely need harvesting: ' + (out.length - 1));
}
