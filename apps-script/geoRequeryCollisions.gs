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
 * RUN:  clearRequeryTargets (once)  ->  geoRequeryDiagnose (read-only, check
 *       real name/city text first)  ->  geoRequeryCollisionsPreview (dry run,
 *       no cost)  ->  geoRequeryCollisions  (repeat until 0)
 *       -> then reshapeCompassEats.
 *
 * PATCH Aug 6, 2026 (a): fixed a matching bug — the target-pair check compared
 * against each row's SLUG, but the pair list is keyed by NAME. Since a slug
 * (e.g. "taian-table") never equals a name (e.g. "Taian Table"), the live run
 * would have matched none of the 12 target pairs and silently done nothing.
 * Now matches on name, same as targetPairSet_() builds it. Added
 * geoRequeryCollisionsPreview(), a read-only dry run with no API calls and no
 * writes.
 *
 * PATCH Aug 6, 2026 (b): preview run found 11 of 12 pairs have NO matching row
 * in venues at all by exact name+city — added geoRequeryDiagnose(), a read-only
 * scan that reports the real name/city_display text for anything resembling
 * the 12 target venues, so the mismatch (spelling, accents, or the row not
 * existing yet) can be seen directly instead of guessed at. Also wrapped the
 * alert() popups in try/catch since running from the editor without the Sheet
 * open in a tab throws "Cannot call SpreadsheetApp.getUi()" — harmless, the
 * Logger.log output is unaffected and is what matters.
 */

var TARGET_PAIRS = [
  ['Taian Table',                                    'Guangzhou'],
  ['Imperial Treasure Fine Chinese Cuisine Guangzhou','Guangzhou'],
  ['Imperial Treasure Fine Teochew Cuisine',          'Guangzhou'],
  ['La Mar',                                          'Miami'],
  ['Sexy Fish',                                       'London'],
  ['Sexy Fish',                                       'Manchester'],
  ['Sexy Fish',                                       'Miami'],
  ['The Ivy',                                         'Los Angeles'],
  ['Avant',                                           'Shenzhen'],
  ["L'Aparté",                                        'Montrabé'],
  ['Sublime',                                         'Tokyo'],
  ['Spice Market',                                    'Doha']
];
function targetPairSet_() {
  var m = {}; TARGET_PAIRS.forEach(function (p) { m[p[0] + '||' + String(p[1]).trim().toLowerCase()] = true; });
  return m;
}

var MAX_REQUERY   = 400;   // lookups per run (cost + 6-min-limit control)
var REQUERY_DELAY = 120;   // ms between API calls
var REQUERY_LOG_TAB = 'geo_requery_done';

function safeAlert_(msg) {
  try { SpreadsheetApp.getUi().alert(msg); } catch (e) { /* no UI in this run context — Logger.log already has it */ }
}

/**
 * READ-ONLY DIAGNOSTIC. No writes, no API calls. Scans the venues tab for any
 * row whose name loosely resembles one of the 12 target venues, and prints out
 * exactly what's stored: name, city_display, city_slug, slug, id. Use this to
 * see the REAL text before trying to match it exactly.
 */
function geoRequeryDiagnose() {
  var ss = SpreadsheetApp.getActive();
  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab.');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iSlug = H['slug'], iName = H['name'], iCityDisp = H['city_display'], iCitySlug = H['city_slug'], iId = H['id'];

  var needles = [
    'taian table', 'imperial treasure', 'la mar', 'sexy fish',
    'the ivy', 'avant', 'apart', 'sublime', 'spice market'
  ];

  var lines = [];
  for (var rr = 1; rr < vv.length; rr++) {
    var nm = String(vv[rr][iName] || '');
    var nmLower = nm.toLowerCase();
    for (var n = 0; n < needles.length; n++) {
      if (nmLower.indexOf(needles[n]) >= 0) {
        lines.push(
          'row ' + (rr + 1) +
          ' | name: "' + nm + '"' +
          ' | city_display: "' + String(vv[rr][iCityDisp] || '') + '"' +
          ' | city_slug: "' + String(vv[rr][iCitySlug] || '') + '"' +
          ' | slug: "' + String(vv[rr][iSlug] || '') + '"' +
          ' | id: "' + String(vv[rr][iId] || '') + '"'
        );
        break;
      }
    }
  }

  var msg = lines.length ? lines.join('\n') : 'No rows found containing any of the target names — none of these venues currently exist in venues at all under a recognizable name.';
  Logger.log(msg);
  safeAlert_(msg.length > 1500 ? (msg.slice(0, 1500) + '\n... (see Execution log for full list)') : msg);
}

function geoRequeryCollisionsPreview() {
  var ss = SpreadsheetApp.getActive();

  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab.');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iSlug = H['slug'], iName = H['name'], iCityDisp = H['city_display'];

  var pairSet = targetPairSet_();

  var esheet = ss.getSheetByName('Places Enrichment');
  if (!esheet) throw new Error('No Places Enrichment tab.');
  var done = {};
  var ev = esheet.getDataRange().getValues();
  for (var er = 1; er < ev.length; er++) { var k = ev[er][0]; if (k) done[String(k)] = true; }

  var logSheet = ss.getSheetByName(REQUERY_LOG_TAB);
  if (logSheet) {
    var lv = logSheet.getDataRange().getValues();
    for (var lr = 1; lr < lv.length; lr++) { var lk = lv[lr][0]; if (lk) done[String(lk)] = true; }
  }

  var foundPairs = {};
  var targets = {};

  for (var rr = 1; rr < vv.length; rr++) {
    var slug = String(vv[rr][iSlug] || '').trim(); if (!slug) continue;
    var cd = String(vv[rr][iCityDisp] || '').trim();
    var nm = String(vv[rr][iName] || '').trim();
    if (!nm || !cd) continue;
    var pk = nm + '||' + cd.toLowerCase();
    if (!pairSet[pk]) continue;

    foundPairs[pk] = true;
    var keyNC = normKey_(nm) + '|' + cityKey_(cd);
    if (!targets[keyNC]) targets[keyNC] = { name: nm, city: cd, row: rr + 1, willSkip: !!done[keyNC] };
  }

  var lines = [];
  lines.push('=== PREVIEW ONLY — no API calls made, nothing written ===\n');

  TARGET_PAIRS.forEach(function (p) {
    var pk = p[0] + '||' + String(p[1]).trim().toLowerCase();
    if (!foundPairs[pk]) {
      lines.push('NO MATCH IN venues TAB: "' + p[0] + '" / "' + p[1] + '" — check exact spelling, accents, or apostrophe type against the venues tab name column.');
    }
  });

  var keys = Object.keys(targets);
  var toQuery = keys.filter(function (k) { return !targets[k].willSkip; });
  var alreadyDone = keys.filter(function (k) { return targets[k].willSkip; });

  lines.push('\nMatched venue rows: ' + keys.length + ' (out of ' + TARGET_PAIRS.length + ' pairs in TARGET_PAIRS)');
  lines.push('Would query (paid call) this run: ' + toQuery.length);
  lines.push('Already have an enrichment/log entry, would be skipped: ' + alreadyDone.length);

  lines.push('\n--- Would query ---');
  toQuery.forEach(function (k) { lines.push('  ' + targets[k].name + ' / ' + targets[k].city + '  (row ' + targets[k].row + ')'); });

  if (alreadyDone.length) {
    lines.push('\n--- Already done, would be skipped ---');
    alreadyDone.forEach(function (k) { lines.push('  ' + targets[k].name + ' / ' + targets[k].city + '  (row ' + targets[k].row + ')'); });
  }

  var msg = lines.join('\n');
  Logger.log(msg);
  safeAlert_(msg);
}

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

  var targets = {};
  for (var rr = 1; rr < vv.length; rr++) {
    var slug = String(vv[rr][iSlug] || '').trim(); if (!slug) continue;
    var cd = String(vv[rr][iCityDisp] || '').trim();
    var nm = String(vv[rr][iName] || '').trim();
    if (!nm || !cd) continue;
    if (useTargets) { if (!pairSet[nm + '||' + cd.toLowerCase()]) continue; }
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
  safeAlert_(msg);
}
