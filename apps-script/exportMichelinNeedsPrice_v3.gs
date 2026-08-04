/**
 * exportMichelinNeedsPrice_v3.gs
 * READ-ONLY. Diagnoses the Places Enrichment join key, then writes
 * tab "price_needed_michelin". Writes nothing else.
 */
function exportMichelinNeedsPrice_v3() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  function strip(s) {
    var v = String(s || '').toLowerCase().replace(/[^a-z0-9]/g, '');
    return v || String(s || '').trim().toLowerCase();  // non-Latin fallback
  }

  // ---- Load Places Enrichment ----
  var pe = ss.getSheetByName('Places Enrichment');
  if (!pe) { Logger.log('ERROR: no "Places Enrichment" tab.'); return; }
  var pd = pe.getDataRange().getValues();
  var ph = pd[0].map(function (h) { return String(h).trim().toLowerCase(); });
  var pKey   = ph.indexOf('normalizedkey');
  var pPrice = ph.indexOf('price_level');
  if (pKey < 0 || pPrice < 0) { Logger.log('ERROR: missing normalizedkey or price_level.'); return; }

  var peAll = {}, pePriced = {}, pricedRows = 0;
  for (var i = 1; i < pd.length; i++) {
    var k = String(pd[i][pKey] || '').trim().toLowerCase();
    if (!k) continue;
    peAll[k] = true;
    if (String(pd[i][pPrice] || '').trim() !== '') { pePriced[k] = true; pricedRows++; }
  }
  Logger.log('PE rows total: ' + (pd.length - 1) + ' | carrying a price_level: ' + pricedRows);
  Logger.log('PE key samples: ');
  for (var s = 1; s <= 5 && s < pd.length; s++) {
    Logger.log('   [' + pd[s][pKey] + ']   name=[' + pd[s][ph.indexOf('canonicalname')] + ']');
  }

  // ---- Load venues ----
  var sh = ss.getSheetByName('venues');
  var vd = sh.getDataRange().getValues();
  var vh = vd[0].map(function (h) { return String(h).trim().toLowerCase(); });
  var vName = vh.indexOf('name');
  var vDisp = vh.indexOf('city_display');
  var vSlug = vh.indexOf('city_slug');
  var vCtry = vh.indexOf('country');
  var vPrice = vh.indexOf('price_tier');
  var vAward = vh.indexOf('awards_json');

  // ---- Candidate key builders ----
  var candidates = {
    'A name|city_display':  function (r) { return strip(r[vName]) + '|' + strip(r[vDisp]); },
    'B namecity_display':   function (r) { return strip(r[vName]) + strip(r[vDisp]); },
    'C name only':          function (r) { return strip(r[vName]); },
    'D name|city_slug':     function (r) { return strip(r[vName]) + '|' + strip(r[vSlug]); },
    'E name::city_display': function (r) { return strip(r[vName]) + '::' + strip(r[vDisp]); },
    'F name_city_display':  function (r) { return strip(r[vName]) + '_' + strip(r[vDisp]); }
  };

  var scores = {}, best = null, bestHits = -1;
  Logger.log('--- JOIN KEY TEST (hits against ' + Object.keys(peAll).length + ' PE keys) ---');
  for (var label in candidates) {
    var hits = 0;
    for (var r = 1; r < vd.length; r++) {
      if (peAll[candidates[label](vd[r])]) hits++;
    }
    scores[label] = hits;
    var pct = Math.round(hits / (vd.length - 1) * 1000) / 10;
    Logger.log('  ' + label + ' -> ' + hits + ' hits (' + pct + '%)');
    if (hits > bestHits) { bestHits = hits; best = label; }
  }
  Logger.log('WINNER: ' + best + ' with ' + bestHits + ' hits');

  if (bestHits < (vd.length - 1) * 0.5) {
    Logger.log('!! Best candidate matches under 50% of venues. Key format is something else.');
    Logger.log('!! Writing the tab WITHOUT the dedupe. Send me this log before running Cowork.');
  }

  // ---- Build output using the winning key ----
  var keyFn = candidates[best];
  var out = [['name', 'city', 'country', 'city_slug', 'match_key']];
  var michelinMissing = 0, alreadyPriced = 0;

  for (var r2 = 1; r2 < vd.length; r2++) {
    var row = vd[r2];
    if (String(row[vPrice] || '').trim() !== '') continue;
    if (String(row[vAward] || '').toLowerCase().indexOf('michelin') === -1) continue;
    michelinMissing++;
    var k2 = keyFn(row);
    if (pePriced[k2]) { alreadyPriced++; continue; }
    out.push([row[vName], row[vDisp], row[vCtry], row[vSlug], k2]);
  }

  var tab = ss.getSheetByName('price_needed_michelin');
  if (tab) { tab.clear(); } else { tab = ss.insertSheet('price_needed_michelin'); }
  tab.getRange(1, 1, out.length, out[0].length).setValues(out);

  Logger.log('--- RESULT ---');
  Logger.log('Michelin venues with blank price_tier: ' + michelinMissing);
  Logger.log('  ...already priced in Places Enrichment: ' + alreadyPriced);
  Logger.log('  ...genuinely need harvesting: ' + (out.length - 1));
}
