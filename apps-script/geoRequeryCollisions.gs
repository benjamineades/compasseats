/**
 * geoRequeryCollisions() — FULL RUN (resumable).  [pair-targeted build]
 * =============================================================================
 * Re-looks up a specific set of MISPINNED venue rows as "Name, City" and appends
 * a Places Enrichment row keyed  normKey_(name) + '|' + cityKey_(city).
 *
 * THIS BUILD targets exactly the 197 mispinned (slug, city) rows from the
 * collision worklist — NOT whole slugs — so correct-home rows are never touched.
 *
 * Also: the appended row stores the venue's OWN name (tg.name), never Google's
 * returned displayName (which previously leaked into slug -> broke blurb keying).
 *
 * SAFE: append-only; reshape falls back to a venue's current pin; resumable via
 * 'geo_requery_done'. A result is only ACCEPTED when the returned address
 * actually contains the target city (so it can't grab another wrong pin).
 *
 * RUN:  clearRequeryTargets (once)  ->  geoRequeryCollisions  (repeat until 0)
 *       -> then reshapeCompassEats.
 */

var TARGET_PAIRS = JSON.parse(`[["agave-restaurante","Ubon Ratchathani"],["alto-ristorante","Caracas"],["alto-ristorante","Cervia"],["alto-ristorante","Hong Kong"],["amano-mexican","Christchurch"],["amelia-by-paulo-airaudo","Dubai"],["ancestral-restaurante","La Paz"],["anima-milano-enrico-bartolini","Tuttlingen"],["aoyama-sushi-umi","Panama City"],["aria-restaurant","Atlanta"],["armani-ristorante-paris","Dubai"],["armani-ristorante-paris","New York"],["atelier-restaurant","Auckland"],["atelier-restaurant","Domodossola"],["atelier-restaurant","Ottawa"],["auberge-de-l-ill","Sapporo"],["aulis-london","Phang-Nga"],["avant","Shenzhen"],["bagatelle","Dole"],["beefbar-hong-kong","Monaco"],["beluga-mediterranean-restaurant","Maastricht"],["berenjak-dubai","London"],["bistro-quellenhof","Noordeloos"],["blossom-restaurant","Las Vegas"],["blossom-restaurant","Shanghai"],["boucherie-august","Augsburg"],["boucherie-august","Jakarta"],["boucherie-august","New Orleans"],["cafe-boulud-at-maison-barnes","Palm Beach"],["cafe-boulud-at-maison-barnes","Toronto"],["carbone-new-york","Hong Kong"],["carbone-new-york","Las Vegas"],["cheval-blanc-restaurant","Basel"],["cheval-blanc-restaurant","Illschwang"],["chez-philippe-bar-grill","Memphis"],["coa","Shanghai"],["coro-restaurant","Orvieto"],["crystal-jade-restaurant","Hong Kong"],["cut-by-wolfgang-puck","Las Vegas"],["cut-by-wolfgang-puck","Los Angeles"],["cut-by-wolfgang-puck","New York"],["da-terra-restaurant","Nara"],["da-vittorio","Sankt Moritz"],["dadong-roast-duck-restaurant","Shanghai"],["dialog-in-the-dark-japan","Los Angeles"],["dill-restaurant","Lewes"],["doma-cuisine-d-humeur-vins-chines","Miami"],["dry-martini-barcelona","Sorrento"],["eau-de-vie-sydney","Melbourne"],["edo-restaurant","Crans Montana"],["el-gato-negro-tapas-manchester","Vilnius"],["elcielo-restaurant-washington-d-c","Bogotá"],["elements-deli-restaurant-lounge","Princeton"],["esplanade-saarbrucken","Desenzano del Garda"],["estiatorio-milos-las-vegas","Miami"],["estiatorio-milos-las-vegas","New York"],["flower-drum-restaurant-melbourne","Hong Kong"],["ginza-sushi-ichi-singapore","Tokyo"],["goat-bangkok","Auckland"],["gourmetrestaurant-le-pavillon-martin-herrmann","New York"],["gucci-osteria-da-massimo-bottura","Los Angeles"],["guido-restaurant","Fontanafredda"],["hangzhou-at-west-lake-four-seasons-hotel-chinese-food-restaurant","Tokyo"],["hangzhou-at-west-lake-four-seasons-hotel-chinese-food-restaurant","Vught"],["hangzhou-at-west-lake-four-seasons-hotel-chinese-food-restaurant","Waasmunster"],["harmonie-restaurant","Lichtenberg"],["harry-s-piccolo-trieste","Porec"],["hong-kong-uc7ud0","Hong Kong"],["hoppers-doha","London"],["hoppers-doha","Tokyo"],["hotel-restaurant-adler-daniel-otto-fehrenbacher","Ried Muotathal"],["howard-s-gourmet","Beijing"],["hutong-new-york","London"],["igniv-andermatt-by-andreas-caminada","Bad Ragaz"],["igniv-bangkok","Bad Ragaz"],["igniv-bangkok","Zürich"],["imperial-treasure-fine-chinese-cuisine","Shanghai"],["imperial-treasure-fine-chinese-cuisine-tsim-sha-tsui","Guangzhou"],["imperial-treasure-fine-chinese-cuisine-tsim-sha-tsui","Shanghai"],["imperial-treasure-fine-teochew-cuisine","Guangzhou"],["inaba-japanese-restaurant","Honolulu"],["indochine-restaurant","Stellenbosch"],["isshisouden-nakamura","Tokyo"],["ivy-sydney","Los Angeles"],["iwasaki-restaurante-japones","Kyoto"],["jamavar-doha","Bengaluru"],["jamavar-doha","Dubai"],["jamavar-doha","London"],["joel-robuchon","Paris"],["joel-robuchon","Taipei"],["julia-restaurante","Tokyo"],["kabuto-edomae-sushi","San Francisco"],["kaiten-sushi-ginza-onodera-kyoto","Tokyo"],["kalustyan-s","Doha"],["kappo-japanese-cuisine","Madrid"],["l-amitie-cheongdam","Tokyo"],["l-aparte","Montrabé"],["l-echappee-belle-hotel-restaurant","Lanaye"],["l-epicurien","Herve"],["l-orangerie-restaurant-menton","Paris"],["l-orangerie-restaurant-menton","Pornic"],["la-becasse-aachen","Osaka"],["la-mar-cevicheria-peruana","Miami"],["la-villa-restaurant","Melfi"],["labs-house","Taipei"],["lyla-restaurant-rooms","Tokyo"],["macau-3bt2d8","Macau"],["man-ho-chinese-restaurant","Hangzhou"],["meta-restaurant","Lugano"],["mirabelle-salle-a-manger","Bekkjarvik"],["mirabelle-salle-a-manger","Vail and Beaver Creek, Colorado"],["miura-hotel","Los Angeles"],["molino-de-urdaniz","Urdániz"],["morimoto-maui","Las Vegas"],["morimoto-maui","Philadelphia"],["mother-bakery-cafe-south-slope","Toronto"],["mott-32-las-vegas","Hong Kong"],["mott-32-las-vegas","Toronto"],["mott-32-las-vegas","Vancouver"],["nara-prison-museum-by-hoshino-resorts","Tokyo"],["narisawa","Shanghai"],["nikuya-tanaka-ginza","Singapore"],["nobu-london-old-park-lane","New York"],["nub-restaurante","Nakhon Ratchasima"],["ox-belfast","Darmstadt"],["ox-belfast","Portland"],["ox-belfast","Reykjavík"],["oxalis","Schluchsee"],["pco-bar","Mumbai"],["perilla-korean-steakhouse","London"],["poggio-rosso-ristorante","Milan"],["primo-restaurant","Orlando"],["putien-kitchener-road","Hong Kong"],["restaurant-allium-quimper","Penrith"],["restaurant-apicius","Bad Zwischenahn"],["restaurant-apicius","Clermont-Ferrand"],["restaurant-apicius","Paris"],["restaurant-apicius","Tokyo"],["restaurant-belveder","Osaka"],["restaurant-demo","Santiago"],["restaurant-demo","Vilnius"],["restaurant-ergo","Dubai"],["restaurant-est","Tokyo"],["restaurant-fleur-de-sel","Honfleur"],["restaurant-focus-atelier","Canterbury"],["restaurant-guy-savoy","Las Vegas"],["restaurant-jan-jan-hartwig","Nice"],["restaurant-marie","Amsterdam"],["restaurant-nuance","Plomeur"],["restaurant-petrus","London"],["restaurante-alameda","Hondarribia"],["restaurante-carmen","Lima"],["restaurante-montia","Desenzano del Garda"],["restaurante-pabu","San Francisco"],["restaurante-toki","Tokyo"],["ristorante-agora","London"],["ristorante-il-moro","Los Angeles"],["salmon-guru-a-contracorriente","Dubai"],["salmon-guru-a-contracorriente","Milan"],["schwarzer-adler-restaurant","Vogtsburg im Kaiserstuhl"],["seed-library-nyc","London"],["sexy-fish-dubai","London"],["sexy-fish-dubai","Manchester"],["sexy-fish-dubai","Miami"],["smoked-room-madrid-fire-omakase-by-dani-garcia","Dubai"],["sorrel-restaurant","San Francisco"],["spago","Maui"],["sublime-restaurante","Tokyo"],["sundays-restaurant","Queenstown"],["sushi-kanesaka-palace-hotel-tokyo","London"],["sushi-kanesaka-palace-hotel-tokyo","Seoul"],["sushi-saito-thailand","Tokyo"],["sushi-zo","New York"],["sushiyoshi-taipei","Hong Kong"],["taian-men","Guangzhou"],["tan","Beijing"],["tea-cocktails","Athens"],["temple-of-heaven","Kyoto"],["terra-sg","Sarentino"],["the-bazaar-by-jose-andres","New York"],["the-bulgari-bar","Milan"],["the-bulgari-bar","Rome"],["the-diplomat-hong-kong","Milwaukee"],["the-river-cafe","Calgary"],["the-river-cafe","New York"],["traube-blansingen","Trimbach"],["tschuggen-grand-hotel-arosa","Ascona"],["u-s-embassy-consulate-in-the-republic-of-korea","Busan"],["uchi-austin","Miami"],["vetri-cucina-las-vegas","Philadelphia"],["wagyumafia-hong-kong","Tokyo"],["xinrongji","Hong Kong"],["yong-fu-hong-kong","Shanghai"],["yoshino-new-york","Tokyo"],["yu-zhi-lan","Chengdu"],["yunico-japanese-fine-dining","Osaka"],["yuzhilan-fabrics","Hangzhou"]]`);   // [[slug, city], ...] — the mispinned rows to re-pin
function targetPairSet_() {
  var m = {}; TARGET_PAIRS.forEach(function (p) { m[p[0] + '||' + String(p[1]).trim().toLowerCase()] = true; });
  return m;
}

var MAX_REQUERY   = 400;   // lookups per run (cost + 6-min-limit control)
var REQUERY_DELAY = 120;   // ms between API calls
var REQUERY_LOG_TAB = 'geo_requery_done';

function geoRequeryCollisions() {
  var ss = SpreadsheetApp.getActive();
  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  if (!key) throw new Error('No PLACES_API_KEY in Script Properties.');

  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab.');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iSlug = H['slug'], iName = H['name'], iCityDisp = H['city_display'];

  var pairSet = targetPairSet_();
  var useTargets = TARGET_PAIRS.length > 0;

  // "done" = keys already in Places Enrichment + keys already attempted (log tab).
  var esheet = ss.getSheetByName('Places Enrichment');
  if (!esheet) throw new Error('No Places Enrichment tab.');
  var done = {};
  var ev = esheet.getDataRange().getValues();
  for (var er = 1; er < ev.length; er++) { var k = ev[er][0]; if (k) done[String(k)] = true; }

  var logSheet = ss.getSheetByName(REQUERY_LOG_TAB);
  if (!logSheet) {
    logSheet = ss.insertSheet(REQUERY_LOG_TAB);
    logSheet.getRange(1, 1, 1, 3).setValues([['key', 'result', 'when']]).setFontWeight('bold');
    logSheet.setFrozenRows(1);
  } else {
    var lv = logSheet.getDataRange().getValues();
    for (var lr = 1; lr < lv.length; lr++) { var lk = lv[lr][0]; if (lk) done[String(lk)] = true; }
  }

  // Build unique remaining targets (only the mispinned pairs).
  var targets = {}; // key -> {name, city}
  for (var rr = 1; rr < vv.length; rr++) {
    var slug = String(vv[rr][iSlug] || '').trim(); if (!slug) continue;
    var cd = String(vv[rr][iCityDisp] || '').trim();
    if (useTargets) { if (!pairSet[slug + '||' + cd.toLowerCase()]) continue; }
    var nm = String(vv[rr][iName] || '').trim();
    if (!nm || !cd) continue;
    var keyNC = normKey_(nm) + '|' + cityKey_(cd);
    if (done[keyNC]) continue;
    if (!targets[keyNC]) targets[keyNC] = { name: nm, city: cd };
  }
  var keys = Object.keys(targets);
  var totalRemaining = keys.length;

  var enrichRows = [], logRows = [];
  var looked = 0, accepted = 0, parked = 0, notFound = 0;
  var today = new Date().toISOString().slice(0, 10);

  for (var t = 0; t < keys.length; t++) {
    if (looked >= MAX_REQUERY) break;
    var tg = targets[keys[t]];
    var res = placesTextSearch_(tg.name + ', ' + tg.city, key);
    looked++; Utilities.sleep(REQUERY_DELAY);

    if (!res) { notFound++; logRows.push([keys[t], 'NORESULT', today]); continue; }

    var nk = normKey_(tg.name);
    var retNk = normKey_(res.displayName || '');
    var nameMatch = retNk === nk || retNk.indexOf(nk) >= 0 || nk.indexOf(retNk) >= 0;
    var cityNorm = normKey_(tg.city);
    var cityMatch = !cityNorm || normKey_(res.address || '').indexOf(cityNorm) >= 0;

    if (nameMatch && cityMatch) {
      // Store the venue's OWN name — never Google's displayName.
      enrichRows.push([keys[t], tg.name, 'geo-requery', res.placeId,
        res.lat, res.lng, res.photoName || '', res.address || '', res.status || '', today]);
      logRows.push([keys[t], 'ACCEPT', today]);
      accepted++;
    } else {
      logRows.push([keys[t], 'PARK', today]);
      parked++;
    }
  }

  if (enrichRows.length) {
    var last = esheet.getLastRow();
    esheet.getRange(last + 1, 1, enrichRows.length, ENRICH_HEADERS.length).setValues(enrichRows);
  }
  if (logRows.length) {
    var llast = logSheet.getLastRow();
    logSheet.getRange(llast + 1, 1, logRows.length, 3).setValues(logRows);
  }

  var remainingAfter = totalRemaining - looked;
  var msg = 'geoRequeryCollisions (mispinned pairs)\n' +
    'remaining targets at start: ' + totalRemaining + '\n' +
    'looked up this run: ' + looked + '  |  accepted: ' + accepted +
    '  |  parked: ' + parked + '  |  no result: ' + notFound + '\n' +
    'remaining targets now: ' + Math.max(0, remainingAfter) + '\n\n' +
    (remainingAfter > 0 ? 'Run geoRequeryCollisions AGAIN to continue.'
                        : 'Done - all targets attempted. NEXT: run reshapeCompassEats.');
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
