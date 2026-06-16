/**
 * geoRequeryCollisions() — FULL RUN (resumable).
 * =============================================================================
 * For every venue whose slug is filed under two or more city labels, re-looks
 * it up as "Name, City" and appends a Places Enrichment row keyed
 *   normKey_(name) + '|' + cityKey_(city)   — exactly what reshape looks up.
 *
 * SAFE BY DESIGN:
 *   • APPEND-ONLY to Places Enrichment. Never edits or deletes.
 *   • Accepted rows tagged 'geo-requery' in the sheetName column (undo = filter
 *     + delete those; or restore the backup copy).
 *   • Reshape fallback means any venue without a new row keeps its current geo.
 *   • RESUMABLE: every attempt (accept / park / no-result) is recorded in a
 *     'geo_requery_done' tab and skipped next run, so re-running advances
 *     through the list and finishes — it never loops on parked rows.
 *
 * COST CONTROL: up to MAX_REQUERY lookups per run. The summary prints
 * "remaining targets now: N" — keep running until N reaches 0 (or a run looks
 * up fewer than the cap).
 *
 * Requires PLACES_API_KEY in Script Properties.
 * Reuses placesTextSearch_, normKey_, cityKey_, ENRICH_HEADERS from the project.
 *
 * RUN:  geoRequeryCollisions  (repeat until "remaining targets now: 0")
 *       -> then reshapeCompassEats.
 */

var TARGET_SLUGS  = [];    // EMPTY = full collision set. (Put slugs here to restrict.)
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
  var iSlug = H['slug'], iName = H['name'], iCitySlug = H['city_slug'], iCityDisp = H['city_display'];

  // 1) Collision slugs: same slug under >=2 distinct city_slugs.
  var bySlug = {};
  for (var r = 1; r < vv.length; r++) {
    var s = String(vv[r][iSlug] || '').trim(); if (!s) continue;
    (bySlug[s] = bySlug[s] || {})[String(vv[r][iCitySlug] || '').trim()] = true;
  }
  var collisionSlugs = {};
  Object.keys(bySlug).forEach(function (s) { if (Object.keys(bySlug[s]).length >= 2) collisionSlugs[s] = true; });
  var useTargets = TARGET_SLUGS.length > 0;

  // 2) "done" = keys already in Places Enrichment + keys already attempted (log tab).
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

  // 3) Build unique remaining targets.
  var targets = {}; // key -> {name, city}
  for (var rr = 1; rr < vv.length; rr++) {
    var slug = String(vv[rr][iSlug] || '').trim(); if (!slug) continue;
    if (useTargets) { if (TARGET_SLUGS.indexOf(slug) === -1) continue; }
    else { if (!collisionSlugs[slug]) continue; }
    var nm = String(vv[rr][iName] || '').trim();
    var cd = String(vv[rr][iCityDisp] || '').trim();
    if (!nm || !cd) continue;
    var keyNC = normKey_(nm) + '|' + cityKey_(cd);
    if (done[keyNC]) continue;
    if (!targets[keyNC]) targets[keyNC] = { name: nm, city: cd };
  }
  var keys = Object.keys(targets);
  var totalRemaining = keys.length;

  // 4) Query up to MAX_REQUERY, collect rows.
  var enrichRows = [], logRows = [];
  var looked = 0, accepted = 0, parked = 0, notFound = 0;
  var today = new Date().toISOString().slice(0, 10);

  for (var t = 0; t < keys.length; t++) {
    if (looked >= MAX_REQUERY) break;
    var tg = targets[keys[t]];
    var res = placesTextSearch_(tg.name + ', ' + tg.city, key);
    looked++; Utilities.sleep(REQUERY_DELAY);

    if (!res) {
      notFound++; logRows.push([keys[t], 'NORESULT', today]); continue;
    }
    var nk = normKey_(tg.name);
    var retNk = normKey_(res.displayName || '');
    var nameMatch = retNk === nk || retNk.indexOf(nk) >= 0 || nk.indexOf(retNk) >= 0;
    var cityNorm = normKey_(tg.city);
    var cityMatch = !cityNorm || normKey_(res.address || '').indexOf(cityNorm) >= 0;

    if (nameMatch && cityMatch) {
      enrichRows.push([keys[t], res.displayName || tg.name, 'geo-requery', res.placeId,
        res.lat, res.lng, res.photoName || '', res.address || '', res.status || '', today]);
      logRows.push([keys[t], 'ACCEPT', today]);
      accepted++;
    } else {
      logRows.push([keys[t], 'PARK', today]);
      parked++;
    }
  }

  // 5) Write accepted geo rows, then log every attempt.
  if (enrichRows.length) {
    var last = esheet.getLastRow();
    esheet.getRange(last + 1, 1, enrichRows.length, ENRICH_HEADERS.length).setValues(enrichRows);
  }
  if (logRows.length) {
    var llast = logSheet.getLastRow();
    logSheet.getRange(llast + 1, 1, logRows.length, 3).setValues(logRows);
  }

  var remainingAfter = totalRemaining - looked;
  var msg = 'geoRequeryCollisions ' + (useTargets ? '(restricted)' : '(FULL collision set)') + '\n' +
    'remaining targets at start: ' + totalRemaining + '\n' +
    'looked up this run: ' + looked + '  |  accepted: ' + accepted +
    '  |  parked: ' + parked + '  |  no result: ' + notFound + '\n' +
    'remaining targets now: ' + Math.max(0, remainingAfter) + '\n\n' +
    (remainingAfter > 0
      ? 'Run geoRequeryCollisions AGAIN to continue.'
      : 'Done - all collision targets attempted. NEXT: run reshapeCompassEats.');
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

/**
 * verifyRequeryProof() - READ-ONLY. Prints the proof venues' geo after reshape
 * (still works as a spot-check; edit the slug list to inspect others).
 */
function verifyRequeryProof() {
  var ss = SpreadsheetApp.getActive();
  var v = ss.getSheetByName('venues');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iSlug = H['slug'], iName = H['name'], iCity = H['city_slug'],
      iAddr = H['address'], iLat = H['lat'], iLng = H['lng'];
  var check = ['canon', 'restaurant-jordn-r', 'the-fat-duck', 'bacchanalia', 'atlas'];
  var out = ['=== REQUERY SPOT-CHECK - venue geo after reshape ==='];
  for (var r = 1; r < vv.length; r++) {
    var slug = String(vv[r][iSlug] || '').trim();
    if (check.indexOf(slug) === -1) continue;
    out.push('slug="' + slug + '"  city_slug="' + vv[r][iCity] +
             '"   addr="' + vv[r][iAddr] + '"   (' + vv[r][iLat] + ', ' + vv[r][iLng] + ')');
  }
  Logger.log(out.join('\n'));
}
