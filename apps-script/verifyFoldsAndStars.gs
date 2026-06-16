/**
 * Read-only verification after the alias folds + merge.
 * Confirms: (A) every folded SOURCE city_slug is now gone (0 rows),
 *           (B) probe venues each resolve to ONE active row in the expected
 *               city, with Michelin intact and a sane award-source list.
 * Writes nothing. Just logs.
 */
function verifyFoldsAndStars() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var vv = ss.getSheetByName('venues').getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iName = H['name'], iCity = H['city_slug'], iType = H['type'], iAw = H['awards_json'];

  function awards(j) { try { return JSON.parse(j || '[]'); } catch (e) { return []; } }
  function srcList(a) { return a.map(function (x) { return String(x.source || ''); }); }
  function hasMich(a) { return srcList(a).some(function (s) { return s.toLowerCase().indexOf('michelin') !== -1; }); }

  // (A) folded source slugs must be empty now
  var foldedSources = ['beverly-hills','queens','west-hollywood','coral-gables',
                       'vila-nova-de-gaia','santa-coloma-de-gramenet','monte-carlo'];
  // also confirm the marquee sources stayed gone
  var marqueeSources = ['gentofte','maidenhead','grange-over-sands','newton-in-cartmel',
                        'collonges-au-mont-dor','leith','pocantico-hills','ixelles','anderlecht'];
  var slugCount = {};
  for (var r = 1; r < vv.length; r++) { var c = String(vv[r][iCity] || '').trim(); if (c) slugCount[c] = (slugCount[c] || 0) + 1; }

  var L = ['=== verifyFoldsAndStars ==='];
  L.push('-- (A) folded SOURCE slugs (each should be 0) --');
  foldedSources.concat(marqueeSources).forEach(function (s) {
    L.push('  ' + (slugCount[s] ? 'STILL PRESENT (' + slugCount[s] + '!): ' : 'gone: ') + s);
  });

  // (B) probes: [label, name substring, expected city_slug]
  var probes = [
    ['Spago (BH->LA)',           'spago',                 'los-angeles'],
    ['Somni (WeHo->LA)',         'somni',                 'los-angeles'],
    ['Zaab Zaab (Queens->NY)',   'zaab',                  'new-york'],
    ['Yeatman (Gaia->Porto)',    'yeatman',               'porto'],
    ['Lluerna (SCdG->BCN)',      'lluerna',               'barcelona'],
    ['Pavyllon (MC->Monaco)',    'pavyllon',              'monaco'],
    ['Jordnaer (3*)',            'jordn',                 'copenhagen'],
    ['Fat Duck (3*)',            'fat duck',              'bray'],
    ["L'Enclume (3*)",           'enclume',               'cartmel'],
    ['Forest Side (Grasmere+Windermere->Ambleside)', 'forest side', 'ambleside']
  ];
  L.push('\n-- (B) probe venues (expect exactly 1 active row, Michelin where applicable) --');
  probes.forEach(function (p) {
    var hits = [];
    for (var r = 1; r < vv.length; r++) {
      var nm = String(vv[r][iName] || '');
      if (nm.toLowerCase().indexOf(p[1]) !== -1) {
        var a = awards(vv[r][iAw]);
        hits.push({ name: nm, city: String(vv[r][iCity] || ''), type: String(vv[r][iType] || ''), mich: hasMich(a), n: a.length, srcs: srcList(a) });
      }
    }
    L.push('\n  ' + p[0] + '  (expect city=' + p[2] + ')');
    if (!hits.length) { L.push('    NO MATCH'); return; }
    hits.forEach(function (h) {
      var flag = (h.city !== p[2]) ? '  <-- city mismatch' : '';
      L.push('    "' + h.name + '" | city=' + h.city + flag + ' | ' + h.type + ' | michelin=' + (h.mich ? 'YES' : 'no') + ' | awards=' + h.n);
      L.push('       sources: ' + h.srcs.join(' ; '));
    });
    if (hits.length > 1) L.push('    NOTE: ' + hits.length + ' rows matched this name (check if same venue or distinct).');
  });
  Logger.log(L.join('\n'));
}
