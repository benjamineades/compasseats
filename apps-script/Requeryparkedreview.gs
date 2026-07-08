/**
 * requeryParkedReview.gs  —  companion to geoRequeryCollisions.gs
 * =============================================================================
 * geoRequeryCollisions() discards the Google candidate for any venue it PARKS
 * (it only logs the key as 'PARK' in geo_requery_done), so there's nothing to
 * review. This file re-queries those parked venues ONCE, captures the full
 * candidate, and writes it to a `requery_review` tab for eyeballing.
 *
 * Reuses the project's placesTextSearch_, normKey_, cityKey_, and reads the
 * same 'geo_requery_done' + 'venues' + 'Places Enrichment' tabs.
 *
 * FLOW:
 *   1. requeryParkedToReview()   → re-queries parked keys, fills requery_review
 *   2. (review the tab — Claude or you type ACCEPT / REJECT in column A)
 *   3. acceptRequeryReview()     → writes ACCEPTs into Places Enrichment
 *   4. reshapeCompassEats()      → graduates them onto correct pins
 *
 * COST: one Places call per parked key (~91). Run requeryParkedToReview ONCE.
 * If you need a clean re-run, delete the requery_review tab first (this func
 * appends).
 */

var REQUERY_REVIEW_TAB = 'requery_review';

function requeryParkedToReview() {
  var ss = SpreadsheetApp.getActive();
  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  if (!key) throw new Error('No PLACES_API_KEY in Script Properties.');

  // 1) gather the PARK keys from the requery log
  var log = ss.getSheetByName('geo_requery_done');
  if (!log) throw new Error('No geo_requery_done tab. Run geoRequeryCollisions first.');
  var lv = log.getDataRange().getValues();
  var parkKeys = {};
  for (var r = 1; r < lv.length; r++) {
    if (lv[r][0] && String(lv[r][1]).toUpperCase() === 'PARK') parkKeys[String(lv[r][0])] = true;
  }

  // 2) map each PARK composite key back to a real name + city from venues
  var v = ss.getSheetByName('venues');
  if (!v) throw new Error('No venues tab.');
  var vv = v.getDataRange().getValues();
  var H = {}; vv[0].forEach(function (h, i) { H[String(h).toLowerCase()] = i; });
  var iName = H['name'], iCityDisp = H['city_display'];
  var targets = {}; // key -> {name, city}
  for (var rr = 1; rr < vv.length; rr++) {
    var nm = String(vv[rr][iName] || '').trim();
    var cd = String(vv[rr][iCityDisp] || '').trim();
    if (!nm || !cd) continue;
    var k = normKey_(nm) + '|' + cityKey_(cd);
    if (parkKeys[k] && !targets[k]) targets[k] = { name: nm, city: cd };
  }

  // 3) re-query each parked target, capturing the full candidate
  var keys = Object.keys(targets);
  var out = [];
  for (var t = 0; t < keys.length; t++) {
    var tg = targets[keys[t]];
    var res = placesTextSearch_(tg.name + ', ' + tg.city, key);
    Utilities.sleep(120);
    if (!res) {
      out.push(['', tg.name, tg.city, '(no result)', '', '', '', '', '', keys[t], 'Google returned nothing']);
      continue;
    }
    var nk = normKey_(tg.name), retNk = normKey_(res.displayName || '');
    var nameMatch = retNk === nk || retNk.indexOf(nk) >= 0 || nk.indexOf(retNk) >= 0;
    var cityNorm = normKey_(tg.city);
    var cityMatch = !cityNorm || normKey_(res.address || '').indexOf(cityNorm) >= 0;
    var note = (!nameMatch && !cityMatch) ? 'name + city string mismatch'
             : (!nameMatch) ? 'name string mismatch'
             : 'city string mismatch (name ok)';
    if (res.status && res.status !== 'OPERATIONAL') note += ' [' + res.status + ']';
    out.push(['', tg.name, tg.city, res.displayName || '', res.address || '',
              res.status || '', res.placeId || '', res.lat, res.lng, keys[t], note]);
  }

  // 4) write to requery_review
  var headers = ['decision', 'queried_name', 'queried_city', 'returned_name',
    'returned_address', 'businessStatus', 'placeId', 'lat', 'lng',
    'composite_key', 'match_note'];
  var rev = ss.getSheetByName(REQUERY_REVIEW_TAB);
  if (!rev) {
    rev = ss.insertSheet(REQUERY_REVIEW_TAB);
    rev.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
    rev.setFrozenRows(1);
  }
  if (out.length) {
    rev.getRange(rev.getLastRow() + 1, 1, out.length, headers.length).setValues(out);
  }

  var msg = 'requeryParkedToReview complete.\n' +
    'parked keys re-queried:            ' + keys.length + '\n' +
    'rows written to ' + REQUERY_REVIEW_TAB + ': ' + out.length + '\n\n' +
    'NEXT: review the ' + REQUERY_REVIEW_TAB + ' tab (send it to Claude, or type\n' +
    'ACCEPT / REJECT in column A yourself), then run acceptRequeryReview().';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

/**
 * acceptRequeryReview() — reads requery_review, and for every row marked ACCEPT
 * in column A, appends a proper name|city-keyed row to Places Enrichment (tagged
 * 'geo-requery-review'). REJECT rows are ignored. Blank rows are left for later.
 * Run reshapeCompassEats afterward to graduate the accepted fixes.
 */
function acceptRequeryReview() {
  var ss = SpreadsheetApp.getActive();
  var rev = ss.getSheetByName(REQUERY_REVIEW_TAB);
  if (!rev) throw new Error('No ' + REQUERY_REVIEW_TAB + ' tab.');
  var esheet = ss.getSheetByName('Places Enrichment');
  if (!esheet) throw new Error('No Places Enrichment tab.');

  var rv = rev.getDataRange().getValues();
  // requery_review cols: 0 decision,1 qname,2 qcity,3 rname,4 raddr,5 status,6 placeId,7 lat,8 lng,9 key,10 note
  var today = new Date().toISOString().slice(0, 10);
  var add = [], accepted = 0, rejected = 0, blank = 0;
  for (var r = 1; r < rv.length; r++) {
    var dec = String(rv[r][0]).trim().toUpperCase();
    if (dec === 'ACCEPT') {
      // Places Enrichment shape: normalizedKey, canonicalName, sheetName, placeId,
      //                          lat, lng, photoName, formattedAddress, businessStatus, lastVerified
      add.push([rv[r][9], rv[r][3] || rv[r][1], 'geo-requery-review', rv[r][6],
                rv[r][7], rv[r][8], '', rv[r][4], rv[r][5], today]);
      accepted++;
    } else if (dec === 'REJECT') {
      rejected++;
    } else {
      blank++;
    }
  }
  if (add.length) {
    esheet.getRange(esheet.getLastRow() + 1, 1, add.length, add[0].length).setValues(add);
  }
  var msg = 'acceptRequeryReview complete.\n' +
    'ACCEPT → written to Places Enrichment: ' + accepted + '\n' +
    'REJECT (skipped):                      ' + rejected + '\n' +
    'blank (left for later):                ' + blank + '\n\n' +
    'NEXT: run reshapeCompassEats to graduate the accepted fixes.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
