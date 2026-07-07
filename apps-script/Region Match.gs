/**
 * CompassEats — Region Matcher  (drafted July 1, 2026)
 * =============================================================================
 * Scans every city in the "cities" tab that ISN'T already in "city_regions"
 * and checks whether it falls inside one of ~170 named travel regions
 * (Tuscany, Napa Valley, Queenstown-Lakes District, etc. — the list from
 * Ben's "Major Travel Regions of the World" reference). Writes SUGGESTIONS
 * to a review tab. Never writes to city_regions directly.
 *
 * THREE STEPS, RUN IN THIS ORDER:
 *
 *   1. rgnGeocodeRegions()        — one-time (per region) Google lookup to
 *      find each region's map boundary. Resumable: run again if it stops
 *      partway through; it skips regions already looked up. Writes to a new
 *      "region_geo_cache" tab.
 *
 *   2. rgnMatchCitiesToRegions()  — pure math, no API calls. Checks every
 *      unmapped city's lat/lng (from the "cities" tab) against every region
 *      boundary from step 1. Writes one row per match to a new
 *      "region_match_review" tab, decision column left BLANK.
 *
 *   3. (You) open "region_match_review", type ACCEPT in the decision column
 *      for every row you agree with. You can also edit the region_candidate
 *      cell before accepting if you want to correct the name.
 *
 *   4. rgnApplyRegionMatches()    — reads only the rows marked ACCEPT, adds
 *      them to "city_regions", then clears those rows from the review tab
 *      (safe to re-run rgnMatchCitiesToRegions later — already-mapped and
 *      already-suggested pairs are skipped, never duplicated).
 *
 *   THEN: run generateRegionsTab as usual.
 *
 * REQUIRES: the "Geocoding API" must be enabled for the same Google Cloud
 * project as your existing PLACES_API_KEY (Places and Geocoding are billed
 * and toggled separately, even though it's one API key). If step 1 fails
 * with REQUEST_DENIED, that's almost certainly it — turn it on in Google
 * Cloud Console, no key change needed.
 *
 * HONEST LIMITS (read before trusting a big ACCEPT batch):
 *   • Official regions (Tuscany, Bavaria, Catalonia) usually geocode with a
 *     clean, accurate boundary. High confidence.
 *   • Informal tourism/wine regions (Chianti, Cotswolds, "Wine Country") are
 *     areas people agree exist, not administrative boundaries — Google's
 *     box for these is rougher, sometimes tiny, sometimes too generous.
 *   • Some names on the list may not resolve to a usable boundary at all
 *     (a point with no bounds, or no result). Step 1's summary tells you
 *     which ones — those simply can't be used for matching, and no
 *     suggestions will ever come from them.
 *   • A city can legitimately match MORE than one region (Napa the city
 *     matches both "Napa Valley" and the broader "Wine Country (Northern
 *     California)"). Both will appear as separate suggestion rows — that's
 *     expected, not a bug. Accept one, both, or neither.
 *   • Watch for a name on this list that's really the SAME place as a
 *     region you already have live under a different name — e.g. "Kyoto
 *     Prefecture" is on this list, but your live regions tab already has
 *     that area folded into "Kansai". If you see a suggestion like that,
 *     either skip it or hand-edit the region_candidate cell to say "Kansai"
 *     before accepting, so you don't end up with two overlapping regions.
 *   • A small number of regions straddle the international date line (Fiji
 *     is the one on this list) — the matching math below accounts for that,
 *     but treat Fiji's matches with extra scrutiny.
 */

var RGN_GEO_CACHE_TAB = 'region_geo_cache';
var RGN_REVIEW_TAB    = 'region_match_review';
var RGN_CITIES_TAB    = 'cities';
var RGN_CITY_REGIONS_TAB = 'city_regions';

var RGN_MAX_GEOCODE_PER_RUN = 150;
var RGN_GEOCODE_DELAY_MS    = 150;

// ---------------------------------------------------------------------------
// Master region list — [display name, query hint]. Hint is just extra text
// added to the search query to help Google find the right place; it is NOT
// written anywhere. Blank hint = name alone is unambiguous or genuinely
// cross-border (e.g. Patagonia, Sahara Desert).
// Sourced from "Major Travel Regions of the World" (Ben's reference doc),
// deduplicated (a few names like Bavarian Alps appeared in two sections).
// ---------------------------------------------------------------------------
var RGN_REGION_LIST = [
  // --- Europe: Italy ---
  ['Tuscany','Italy'], ["Val d'Orcia",'Italy'], ['Chianti','Italy'], ['Umbria','Italy'],
  ['Piedmont','Italy'], ['Lake Como','Italy'], ['Italian Lakes','Italy'], ['Dolomites','Italy'],
  ['Amalfi Coast','Italy'], ['Italian Riviera','Italy'], ['Cinque Terre','Italy'], ['Puglia','Italy'],
  ['Sicily','Italy'], ['Sardinia','Italy'], ['Veneto','Italy'], ['Friuli-Venezia Giulia','Italy'],
  // --- Europe: France ---
  ['Champagne','France'], ['Burgundy','France'], ['Bordeaux','France'], ['Loire Valley','France'],
  ['Provence','France'], ['French Riviera','France'], ['Normandy','France'], ['Brittany','France'],
  ['Alsace','France'], ['Dordogne','France'], ['Languedoc','France'], ['Auvergne','France'],
  ['French Basque Country','France'], ['Corsica','France'],
  // --- Europe: Spain ---
  ['Basque Country','Spain'], ['Catalonia','Spain'], ['Costa Brava','Spain'], ['Andalusia','Spain'],
  ['La Rioja','Spain'], ['Galicia','Spain'], ['Asturias','Spain'], ['Balearic Islands','Spain'],
  ['Canary Islands','Spain'],
  // --- Europe: Portugal ---
  ['Douro Valley','Portugal'], ['Alentejo','Portugal'], ['Algarve','Portugal'], ['Madeira','Portugal'],
  ['Azores','Portugal'],
  // --- Europe: Germany ---
  ['Black Forest','Germany'], ['Bavaria','Germany'], ['Bavarian Alps','Germany'], ['Franconia','Germany'],
  ['Mosel','Germany'], ['Rhine Valley','Germany'], ['Lake Constance','Germany'],
  ['Saxon Switzerland','Germany'], ['Baltic Coast','Germany'],
  // --- Europe: United Kingdom ---
  ['Cotswolds','United Kingdom'], ['Lake District','United Kingdom'], ['Cornwall','United Kingdom'],
  ['Scottish Highlands','United Kingdom'], ['Isle of Skye','United Kingdom'],
  ['Yorkshire Dales','United Kingdom'], ['Norfolk Coast','United Kingdom'],
  // --- Europe: Alpine (cross-border, Bavarian Alps already listed above) ---
  ['Swiss Alps','Switzerland'], ['French Alps','France'], ['Austrian Alps','Austria'], ['Tyrol','Austria'],
  // --- Europe: other ---
  ['Dalmatia','Croatia'], ['Istria','Croatia'], ['Peloponnese','Greece'], ['Greek Islands','Greece'],
  ['Santorini','Greece'], ['Cyclades','Greece'], ['Slovenian Alps','Slovenia'], ['Transylvania','Romania'],
  ['Lapland',''],
  // --- North America: United States ---
  ['Napa Valley','United States'], ['Sonoma County','United States'],
  ['Wine Country (Northern California)','United States'], ['Santa Ynez Valley','United States'],
  ['Monterey Peninsula','United States'], ['Hudson Valley','United States'], ['Hamptons','United States'],
  ['Finger Lakes','United States'], ['Charleston Lowcountry','United States'], ['Nantucket','United States'],
  ['Cape Cod','United States'], ['Maui','United States'],
  ['Aspen and Roaring Fork Valley','United States'], ['Rocky Mountains','United States'],
  ['Florida Keys','United States'], ['Outer Banks','United States'],
  // --- North America: Canada ---
  ['Okanagan Valley','Canada'], ['Vancouver Island','Canada'], ['Canadian Rockies','Canada'],
  ['Prince Edward County','Canada'], ['Niagara Peninsula','Canada'],
  // --- North America: Mexico ---
  ['Baja California','Mexico'], ['Yucatán Peninsula','Mexico'], ['Riviera Maya','Mexico'],
  ['Los Cabos','Mexico'], ['Valle de Guadalupe','Mexico'],
  // --- South America ---
  ['Patagonia',''], ['Mendoza','Argentina'], ['Atacama Desert','Chile'],
  ['Chilean Lake District','Chile'], ['Sacred Valley','Peru'], ['Amazon Rainforest',''],
  ['Galápagos Islands','Ecuador'], ['Pantanal',''],
  // --- Asia: Japan ---
  ['Kyoto Prefecture','Japan'], ['Keihanshin','Japan'], ['Japanese Alps','Japan'], ['Hokkaido','Japan'],
  ['Setouchi Region','Japan'], ['Kyushu','Japan'], ['Okinawa','Japan'],
  // --- Asia: other ---
  ['Bali','Indonesia'], ['Phuket','Thailand'], ['Chiang Mai Region','Thailand'], ['Kerala','India'],
  ['Goa','India'], ['Rajasthan','India'], ['Cappadocia','Turkey'], ['Aegean Coast','Turkey'],
  ['Ubud','Indonesia'],
  // --- Middle East ---
  ['Wadi Rum','Jordan'], ['Dead Sea',''], ['Musandam Peninsula','Oman'], ['Dhofar','Oman'],
  ['Negev Desert','Israel'],
  // --- Africa ---
  ['Cape Winelands','South Africa'], ['Garden Route','South Africa'],
  ['Kruger National Park region','South Africa'], ['Atlas Mountains','Morocco'], ['Sahara Desert',''],
  ['Serengeti','Tanzania'], ['Ngorongoro Conservation Area','Tanzania'], ['Okavango Delta','Botswana'],
  ['Zanzibar','Tanzania'],
  // --- Oceania & Islands ---
  ['Maldives',''], ['French Polynesia',''], ['Bora Bora','French Polynesia'], ['Fiji',''],
  ['Seychelles',''], ['Whitsunday Islands','Australia'],
  // --- Australia ---
  ['Margaret River','Australia'], ['Barossa Valley','Australia'], ['Yarra Valley','Australia'],
  ['Hunter Valley','Australia'], ['Tasmania','Australia'], ['Great Barrier Reef','Australia'],
  // --- New Zealand ---
  ['Marlborough','New Zealand'], ['Central Otago','New Zealand'],
  ['Queenstown-Lakes District','New Zealand'], ['Fiordland','New Zealand'],
];

// ---------------------------------------------------------------------------
// STEP 1 — geocode each region once, cache its bounding box
// ---------------------------------------------------------------------------
function rgnGeocodeRegions() {
  var ss = SpreadsheetApp.getActive();
  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  if (!key) throw new Error('No PLACES_API_KEY in Script Properties.');

  var cache = ss.getSheetByName(RGN_GEO_CACHE_TAB);
  if (!cache) {
    cache = ss.insertSheet(RGN_GEO_CACHE_TAB);
    cache.getRange(1, 1, 1, 11).setValues([[
      'region_name', 'query_used', 'status', 'formatted_address',
      'sw_lat', 'sw_lng', 'ne_lat', 'ne_lng', 'center_lat', 'center_lng', 'checked'
    ]]).setFontWeight('bold');
    cache.setFrozenRows(1);
  }

  var have = {};
  var cv = cache.getDataRange().getValues();
  for (var i = 1; i < cv.length; i++) { if (cv[i][0]) have[String(cv[i][0])] = true; }

  var todo = RGN_REGION_LIST.filter(function (r) { return !have[r[0]]; });
  var looked = 0;
  var newRows = [];
  var today = new Date().toISOString().slice(0, 10);

  for (var t = 0; t < todo.length; t++) {
    if (looked >= RGN_MAX_GEOCODE_PER_RUN) break;
    var name = todo[t][0], hint = todo[t][1];
    var query = hint ? (name + ', ' + hint) : name;
    var res = rgnGeocodeQuery_(query, key);
    looked++; Utilities.sleep(RGN_GEOCODE_DELAY_MS);

    if (!res) {
      newRows.push([name, query, 'NOT_FOUND', '', '', '', '', '', '', '', today]);
    } else if (!res.bounds) {
      newRows.push([name, query, 'NO_BOUNDS', res.formattedAddress, '', '', '', '', res.lat, res.lng, today]);
    } else {
      newRows.push([
        name, query, 'OK', res.formattedAddress,
        res.bounds.sw_lat, res.bounds.sw_lng, res.bounds.ne_lat, res.bounds.ne_lng,
        res.lat, res.lng, today
      ]);
    }
  }

  if (newRows.length) {
    var last = cache.getLastRow();
    cache.getRange(last + 1, 1, newRows.length, 11).setValues(newRows);
  }

  var remaining = todo.length - looked;
  var okCount = newRows.filter(function (r) { return r[2] === 'OK'; }).length;
  var noBoundsCount = newRows.filter(function (r) { return r[2] === 'NO_BOUNDS'; }).length;
  var notFoundCount = newRows.filter(function (r) { return r[2] === 'NOT_FOUND'; }).length;

  var msg = 'rgnGeocodeRegions\n' +
    'looked up this run: ' + looked + '\n' +
    '  OK (usable boundary): ' + okCount + '\n' +
    '  NO_BOUNDS (found, but no box — cannot be used for matching): ' + noBoundsCount + '\n' +
    '  NOT_FOUND: ' + notFoundCount + '\n' +
    'remaining to look up: ' + Math.max(0, remaining) + '\n\n' +
    (remaining > 0
      ? 'Run rgnGeocodeRegions again to continue.'
      : 'Done — all regions attempted. NEXT: run rgnMatchCitiesToRegions().');
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

function rgnGeocodeQuery_(query, key) {
  var url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' +
    encodeURIComponent(query) + '&key=' + key;
  var resp;
  try {
    resp = UrlFetchApp.fetch(url, { muteHttpExceptions: true });
  } catch (e) {
    return null;
  }
  var data = JSON.parse(resp.getContentText());
  if (data.status !== 'OK' || !data.results || !data.results.length) return null;

  var top = data.results[0];
  var geo = top.geometry || {};
  var loc = geo.location || {};
  var out = {
    formattedAddress: top.formatted_address || '',
    lat: loc.lat, lng: loc.lng,
    bounds: null
  };
  // Prefer "bounds" (a true administrative/feature boundary) over "viewport"
  // (which Google returns for almost everything, including single points,
  // and is often just an arbitrary map-display rectangle around a pin).
  var box = geo.bounds || null;
  if (box) {
    out.bounds = {
      sw_lat: box.southwest.lat, sw_lng: box.southwest.lng,
      ne_lat: box.northeast.lat, ne_lng: box.northeast.lng
    };
  }
  return out;
}

// ---------------------------------------------------------------------------
// STEP 2 — match every unmapped city against every region's box (no API calls)
// ---------------------------------------------------------------------------
function rgnMatchCitiesToRegions() {
  var ss = SpreadsheetApp.getActive();

  var citiesSheet = ss.getSheetByName(RGN_CITIES_TAB);
  if (!citiesSheet) throw new Error('No "' + RGN_CITIES_TAB + '" tab. Run generateCitiesTab first.');
  var cv = citiesSheet.getDataRange().getValues();
  var CH = {}; cv[0].forEach(function (h, i) { CH[String(h).trim().toLowerCase()] = i; });

  var crSheet = ss.getSheetByName(RGN_CITY_REGIONS_TAB);
  var alreadyMapped = {}; // cityDisplay.toLowerCase() -> true (matches generateRegionsTab's own lookup key)
  if (crSheet) {
    var crv = crSheet.getDataRange().getValues();
    for (var i = 1; i < crv.length; i++) {
      var cd = String(crv[i][0] || '').trim().toLowerCase();
      if (cd) alreadyMapped[cd] = true;
    }
  }

  var cacheSheet = ss.getSheetByName(RGN_GEO_CACHE_TAB);
  if (!cacheSheet) throw new Error('No "' + RGN_GEO_CACHE_TAB + '" tab. Run rgnGeocodeRegions first.');
  var boxv = cacheSheet.getDataRange().getValues();
  var boxes = [];
  for (var b = 1; b < boxv.length; b++) {
    var row = boxv[b];
    if (row[2] !== 'OK') continue; // only usable boundaries
    boxes.push({
      name: row[0],
      sw_lat: Number(row[4]), sw_lng: Number(row[5]),
      ne_lat: Number(row[6]), ne_lng: Number(row[7]),
      center_lat: Number(row[8]), center_lng: Number(row[9])
    });
  }

  var reviewSheet = ss.getSheetByName(RGN_REVIEW_TAB);
  if (!reviewSheet) {
    reviewSheet = ss.insertSheet(RGN_REVIEW_TAB);
    reviewSheet.getRange(1, 1, 1, 6).setValues([[
      'decision', 'city', 'country', 'region_candidate', 'dist_to_region_center_km', 'note'
    ]]).setFontWeight('bold');
    reviewSheet.setFrozenRows(1);
  }
  var existingPairs = {};
  var rv = reviewSheet.getDataRange().getValues();
  for (var p = 1; p < rv.length; p++) {
    var pk = String(rv[p][1] || '').toLowerCase() + '|' + String(rv[p][3] || '').toLowerCase();
    if (pk !== '|') existingPairs[pk] = true;
  }

  var newSuggestions = [];
  var citiesChecked = 0;

  for (var r = 1; r < cv.length; r++) {
    var row = cv[r];
    var disp = String(row[CH['display']] || '').trim();
    if (!disp) continue;
    if (alreadyMapped[disp.toLowerCase()]) continue; // don't re-suggest what's already mapped

    var lat = parseFloat(row[CH['lat']]);
    var lng = parseFloat(row[CH['lng']]);
    if (isNaN(lat) || isNaN(lng)) continue;
    citiesChecked++;

    for (var x = 0; x < boxes.length; x++) {
      var bx = boxes[x];
      if (isNaN(bx.sw_lat) || isNaN(bx.ne_lat)) continue;
      var latIn = lat >= bx.sw_lat && lat <= bx.ne_lat;
      // Longitude: handle boxes that cross the 180° line (Fiji) where
      // sw_lng ends up numerically greater than ne_lng.
      var lngIn = bx.sw_lng <= bx.ne_lng
        ? (lng >= bx.sw_lng && lng <= bx.ne_lng)
        : (lng >= bx.sw_lng || lng <= bx.ne_lng);
      if (!latIn || !lngIn) continue;

      var pairKey = disp.toLowerCase() + '|' + bx.name.toLowerCase();
      if (existingPairs[pairKey]) continue;
      existingPairs[pairKey] = true;

      var dist = rgnHaversine_(lat, lng, bx.center_lat, bx.center_lng);
      newSuggestions.push([
        '', disp, String(row[CH['country']] || ''), bx.name,
        Math.round(dist * 10) / 10, 'inside region boundary'
      ]);
    }
  }

  if (newSuggestions.length) {
    var last = reviewSheet.getLastRow();
    reviewSheet.getRange(last + 1, 1, newSuggestions.length, 6).setValues(newSuggestions);
  }

  var msg = 'rgnMatchCitiesToRegions\n' +
    'unmapped cities checked: ' + citiesChecked + '\n' +
    'usable region boundaries: ' + boxes.length + ' (of ' + RGN_REGION_LIST.length + ' total on the list)\n' +
    'new suggestions written:  ' + newSuggestions.length + '\n\n' +
    'Open "' + RGN_REVIEW_TAB + '", type ACCEPT next to any row you agree with\n' +
    '(edit the region_candidate cell first if you want to correct a name),\n' +
    'then run rgnApplyRegionMatches().';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

function rgnHaversine_(lat1, lng1, lat2, lng2) {
  var R = 6371;
  var dLat = (lat2 - lat1) * Math.PI / 180;
  var dLng = (lng2 - lng1) * Math.PI / 180;
  var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// ---------------------------------------------------------------------------
// STEP 3 — apply approved rows to city_regions
// ---------------------------------------------------------------------------
function rgnApplyRegionMatches() {
  var ss = SpreadsheetApp.getActive();
  var review = ss.getSheetByName(RGN_REVIEW_TAB);
  if (!review) throw new Error('No "' + RGN_REVIEW_TAB + '" tab.');

  var crSheet = ss.getSheetByName(RGN_CITY_REGIONS_TAB);
  if (!crSheet) throw new Error('No "' + RGN_CITY_REGIONS_TAB + '" tab.');

  var existing = {};
  var crv = crSheet.getDataRange().getValues();
  for (var i = 1; i < crv.length; i++) {
    var k = String(crv[i][0] || '').toLowerCase() + '|' + String(crv[i][2] || '').toLowerCase();
    if (k !== '|') existing[k] = true;
  }

  var rv = review.getDataRange().getValues();
  var toAdd = [], keepRows = [rv[0]];
  var applied = 0, skippedDup = 0, left = 0;

  for (var r = 1; r < rv.length; r++) {
    var row = rv[r];
    var decision = String(row[0] || '').trim().toUpperCase();
    if (decision !== 'ACCEPT') { keepRows.push(row); left++; continue; }

    var city = String(row[1] || '').trim();
    var country = String(row[2] || '').trim();
    var region = String(row[3] || '').trim(); // read live — respects any manual edit
    if (!city || !region) { keepRows.push(row); left++; continue; }

    var key = city.toLowerCase() + '|' + region.toLowerCase();
    if (existing[key]) { skippedDup++; continue; } // drop row, already mapped
    existing[key] = true;
    toAdd.push([city, country, region]);
    applied++;
  }

  if (toAdd.length) {
    var last = crSheet.getLastRow();
    crSheet.getRange(last + 1, 1, toAdd.length, 3).setValues(toAdd);
  }

  review.clear();
  review.getRange(1, 1, 1, 6).setValues([keepRows[0]]).setFontWeight('bold');
  review.setFrozenRows(1);
  if (keepRows.length > 1) {
    review.getRange(2, 1, keepRows.length - 1, 6).setValues(keepRows.slice(1));
  }

  var msg = 'rgnApplyRegionMatches\n' +
    'added to city_regions:        ' + applied + '\n' +
    'skipped (already mapped):     ' + skippedDup + '\n' +
    'left undecided in review tab: ' + left + '\n\n' +
    'NEXT: run generateRegionsTab, then republish JSON as usual.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

function rgnGeocodeDiagnostic() {
  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  var url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' +
    encodeURIComponent('Tuscany, Italy') + '&key=' + key;
  var resp = UrlFetchApp.fetch(url, { muteHttpExceptions: true });
  var raw = resp.getContentText();
  Logger.log(raw);
  SpreadsheetApp.getUi().alert(raw.substring(0, 1500));
}

function rgnClearFailedCache() {
  var ss = SpreadsheetApp.getActive();
  var cache = ss.getSheetByName(RGN_GEO_CACHE_TAB);
  var vals = cache.getDataRange().getValues();
  var keep = [vals[0]];
  var removed = 0;
  for (var i = 1; i < vals.length; i++) {
    if (vals[i][2] === 'NOT_FOUND') { removed++; continue; }
    keep.push(vals[i]);
  }
  cache.clear();
  cache.getRange(1, 1, keep.length, keep[0].length).setValues(keep);
  cache.setFrozenRows(1);
  SpreadsheetApp.getUi().alert('Removed ' + removed + ' failed NOT_FOUND rows. Re-run rgnGeocodeRegions now.');
}

function rgnRebuildCacheHeader() {
  var ss = SpreadsheetApp.getActive();
  var cache = ss.getSheetByName(RGN_GEO_CACHE_TAB);
  if (!cache) cache = ss.insertSheet(RGN_GEO_CACHE_TAB);
  cache.clear();
  cache.getRange(1, 1, 1, 11).setValues([[
    'region_name', 'query_used', 'status', 'formatted_address',
    'sw_lat', 'sw_lng', 'ne_lat', 'ne_lng', 'center_lat', 'center_lng', 'checked'
  ]]).setFontWeight('bold');
  cache.setFrozenRows(1);
  SpreadsheetApp.getUi().alert('Cache tab reset with header only. Now run rgnGeocodeRegions from scratch.');
}

/**
 * CompassEats — Region Match Cleanup  (drafted July 2, 2026)
 * =============================================================================
 * Removes suggestion rows generated from 18 regions whose Google geocode
 * result was NOT the intended place — either it silently fell back to
 * matching the entire COUNTRY (e.g. "Lake District" -> matched "United
 * Kingdom" as a whole, "Chianti" -> matched "Italy" as a whole), or it
 * matched a small, unrelated, same-named place instead (e.g. "Mosel" ->
 * matched a district in Saxony, nowhere near the actual Mosel wine valley;
 * "Rocky Mountains" -> matched a small town in Oklahoma).
 *
 * These 18 regions account for 3,299 of the 3,681 suggestions currently in
 * region_match_review (89.6%) — almost entirely explained by "Lake District"
 * alone matching every city in the UK (1,465 rows).
 *
 * SAFE: only removes rows from region_match_review where decision is still
 * blank (nothing you've already typed ACCEPT on is touched — though as of
 * this writing nothing has been accepted yet). Does not delete anything from
 * region_geo_cache — just relabels those 18 rows' status so
 * rgnMatchCitiesToRegions() skips them automatically on any future run.
 *
 * RUN: rgnPurgeBadRegionMatches()   (once)
 * THEN: review the remaining ~382 rows in region_match_review as planned.
 */

var RGN_CONFIRMED_BAD_REGIONS = [
  "Val d'Orcia", 'Chianti', 'Italian Lakes',           // -> collapsed to "Italy"
  'Franconia', 'Baltic Coast',                         // -> collapsed to "Germany"
  'Lake District',                                     // -> collapsed to "United Kingdom"
  'Austrian Alps',                                     // -> collapsed to "Austria"
  'Dalmatia',                                          // -> collapsed to "Croatia"
  'Greek Islands',                                     // -> collapsed to "Greece"
  'Okanagan Valley', 'Niagara Peninsula',              // -> collapsed to "Canada"
  'Chilean Lake District',                             // -> collapsed to "Chile"
  'Keihanshin',                                        // -> collapsed to "Japan"
  'Aegean Coast',                                      // -> collapsed to "Türkiye"
  'Atlas Mountains',                                   // -> collapsed to "Morocco"
  'Yarra Valley',                                      // -> collapsed to "Australia"
  'Rocky Mountains',                                   // -> matched Rocky Mountain, OK, USA (wrong place)
  'Mosel',                                             // -> matched Zwickau-Mosel, Saxony (wrong place)
];

function rgnPurgeBadRegionMatches() {
  var ss = SpreadsheetApp.getActive();
  var badSet = {};
  RGN_CONFIRMED_BAD_REGIONS.forEach(function (n) { badSet[n] = true; });

  // 1) Strip bad-region rows out of region_match_review
  var review = ss.getSheetByName(RGN_REVIEW_TAB);
  if (!review) throw new Error('No "' + RGN_REVIEW_TAB + '" tab.');
  var rv = review.getDataRange().getValues();
  var keep = [rv[0]];
  var removed = 0, keptAccepted = 0;
  for (var i = 1; i < rv.length; i++) {
    var row = rv[i];
    var region = String(row[3] || '');
    var decision = String(row[0] || '').trim().toUpperCase();
    if (badSet[region]) {
      removed++;
      if (decision === 'ACCEPT') keptAccepted++; // flagged below — should be 0
      continue;
    }
    keep.push(row);
  }
  review.clear();
  review.getRange(1, 1, 1, keep[0].length).setValues([keep[0]]).setFontWeight('bold');
  review.setFrozenRows(1);
  if (keep.length > 1) {
    review.getRange(2, 1, keep.length - 1, keep[0].length).setValues(keep.slice(1));
  }

  // 2) Relabel those regions' status in region_geo_cache so future matching
  //    runs skip them automatically (rgnMatchCitiesToRegions only reads
  //    status === 'OK').
  var cache = ss.getSheetByName(RGN_GEO_CACHE_TAB);
  var cv = cache.getDataRange().getValues();
  var relabeled = 0;
  for (var c = 1; c < cv.length; c++) {
    if (badSet[cv[c][0]]) {
      cache.getRange(c + 1, 3).setValue('REJECTED_WRONG_PLACE');
      relabeled++;
    }
  }

  var msg = 'rgnPurgeBadRegionMatches\n' +
    'suggestion rows removed:        ' + removed + '\n' +
    'regions relabeled in cache:     ' + relabeled + ' (of ' + RGN_CONFIRMED_BAD_REGIONS.length + ' targeted)\n' +
    (keptAccepted > 0
      ? '\n*** WARNING: ' + keptAccepted + ' of the removed rows had already been marked ACCEPT — check city_regions for anything that needs to be undone. ***\n'
      : 'None of the removed rows had been accepted — nothing in city_regions is affected.\n') +
    '\nNEXT: review the remaining rows in ' + RGN_REVIEW_TAB + '.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
