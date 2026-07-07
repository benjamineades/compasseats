/**
 * CompassEats — Region Match Retry  (drafted July 2, 2026)
 * =============================================================================
 * Re-geocodes the 18 regions that Region-Match-Cleanup.gs already found and
 * rejected — either Google silently matched the whole COUNTRY instead of the
 * actual place (e.g. "Lake District" -> matched all of "United Kingdom"), or
 * it matched a small, unrelated, same-named place (e.g. "Mosel" -> a district
 * in Saxony; "Rocky Mountains" -> a small town in Oklahoma).
 *
 * This file adds ONE new function, rgnRetryBadRegions(). It's meant to live
 * in the SAME Apps Script project as Region-Match.gs and
 * Region-Match-Cleanup.gs — it reuses their shared variables
 * (RGN_GEO_CACHE_TAB, RGN_GEOCODE_DELAY_MS, RGN_REGION_LIST) and their
 * geocode helper (rgnGeocodeQuery_). Add this as a THIRD script file in
 * that same project — don't start a new project.
 *
 * WHAT IT DOES
 *   For each of the 18 regions below, tries a more specific search phrase
 *   (adding the state/province/wine-region context that was missing the
 *   first time) and OVERWRITES that region's existing row in
 *   region_geo_cache in place — it never adds a duplicate row.
 *
 *   A region's status only flips back to "OK" if the new result is verified
 *   to NOT be another bare-country match (the same check proven out in the
 *   cleanup pass, with an accent-folding fix so "Türkiye" is correctly
 *   recognized as the country "Turkey"). If it's still just the whole
 *   country, the row stays REJECTED_WRONG_PLACE exactly as before, and
 *   rgnMatchCitiesToRegions() keeps skipping it automatically.
 *
 * WHAT IT CAN'T DO
 *   The automatic check only catches "still collapsed to the whole
 *   country." For "Mosel" and "Rocky Mountains" specifically — which
 *   grabbed a small WRONG place, not the whole country — the script can't
 *   tell on its own whether the new result is correct. If either comes
 *   back marked OK below, glance at its formatted_address in
 *   region_geo_cache before trusting it.
 *
 * HONEST LIMITS
 *   "Rocky Mountains" and "Greek Islands" genuinely span far too many
 *   separate places for one Google bounding box to represent well — this
 *   retries them with narrower phrasing, but don't expect a real fix.
 *   "Italian Lakes" has the same multi-place problem (Como, Garda, and
 *   Maggiore span three different Italian regions) and may land the same
 *   way. A permanent "can't be matched this way" result for any of these
 *   three is a legitimate, expected outcome — not a bug.
 *
 * ALSO WATCH FOR
 *   If "Keihanshin" comes back with a real boundary this time, treat it
 *   like the existing "Kyoto Prefecture" caution: it covers the
 *   Osaka-Kyoto-Kobe area, which may already be covered by a live "Kansai"
 *   region. Check for overlap before accepting its suggestions.
 *
 * RUN: rgnRetryBadRegions()   (once)
 * THEN: rgnMatchCitiesToRegions() to generate suggestion rows for anything
 * newly recovered (safe — already-suggested pairs are skipped automatically).
 * Then do the planned review pass in region_match_review.
 */

var RGN_RETRY_QUERIES = [
  ["Val d'Orcia",           "Val d'Orcia, Province of Siena, Tuscany, Italy"],
  ['Chianti',               'Chianti wine region, Tuscany, Italy'],
  ['Italian Lakes',         'Italian Lake District, Lombardy, Italy'],
  ['Franconia',             'Franconia, Bavaria, Germany'],
  ['Baltic Coast',          'German Baltic Sea coast, Mecklenburg-Vorpommern, Germany'],
  ['Lake District',         'Lake District National Park, Cumbria, England'],
  ['Austrian Alps',         'Austrian Alps, Tyrol, Austria'],
  ['Dalmatia',              'Dalmatia, Split-Dalmatia County, Croatia'],
  ['Greek Islands',         'Aegean Islands, Greece'],
  ['Okanagan Valley',       'Okanagan Valley, British Columbia, Canada'],
  ['Niagara Peninsula',     'Niagara Peninsula, Ontario, Canada'],
  ['Chilean Lake District', 'Chilean Lake District, Los Lagos Region, Chile'],
  ['Keihanshin',            'Keihanshin metropolitan area, Osaka Prefecture, Japan'],
  ['Aegean Coast',          'Aegean Region, Turkey'],
  ['Atlas Mountains',       'High Atlas Mountains, Marrakesh-Safi, Morocco'],
  ['Yarra Valley',          'Yarra Valley wine region, Victoria, Australia'],
  ['Rocky Mountains',       'Rocky Mountains range, United States'],
  ['Mosel',                 'Mosel Valley wine region, Rhineland-Palatinate, Germany'],
];

function rgnRetryBadRegions() {
  var ss = SpreadsheetApp.getActive();
  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  if (!key) throw new Error('No PLACES_API_KEY in Script Properties.');

  var cache = ss.getSheetByName(RGN_GEO_CACHE_TAB);
  if (!cache) throw new Error('No "' + RGN_GEO_CACHE_TAB + '" tab. Run rgnGeocodeRegions first.');

  // Original country hint for each region, straight from the master list —
  // used below to check whether a retry result is STILL just the whole
  // country (the exact bug we're retrying to fix).
  var hintByName = {};
  RGN_REGION_LIST.forEach(function (r) { hintByName[r[0]] = r[1]; });

  // Find each region's existing row number so we overwrite it in place
  // instead of appending a duplicate.
  var cv = cache.getDataRange().getValues();
  var rowByName = {};
  for (var i = 1; i < cv.length; i++) {
    rowByName[String(cv[i][0])] = i + 1; // sheet rows are 1-indexed
  }

  var today = new Date().toISOString().slice(0, 10);
  var fixed = [], stillBad = [], noBounds = [], notFound = [], missingRow = [];

  for (var t = 0; t < RGN_RETRY_QUERIES.length; t++) {
    var name = RGN_RETRY_QUERIES[t][0];
    var newQuery = RGN_RETRY_QUERIES[t][1];
    var rowNum = rowByName[name];
    if (!rowNum) { missingRow.push(name); continue; }

    var res = rgnGeocodeQuery_(newQuery, key);
    Utilities.sleep(RGN_GEOCODE_DELAY_MS);

    var countryHint = hintByName[name] || '';
    var stillCountry = !!(res && countryHint &&
      rgnFoldCountryName_(res.formattedAddress) === rgnFoldCountryName_(countryHint));

    if (!res) {
      notFound.push(name);
      cache.getRange(rowNum, 2, 1, 10).setValues([[
        newQuery, 'NOT_FOUND', '', '', '', '', '', '', '', today
      ]]);
    } else if (stillCountry) {
      stillBad.push(name + ' (still -> ' + res.formattedAddress + ')');
      cache.getRange(rowNum, 2, 1, 10).setValues([[
        newQuery, 'REJECTED_WRONG_PLACE', res.formattedAddress, '', '', '', '', '', '', today
      ]]);
    } else if (!res.bounds) {
      noBounds.push(name + ' (' + res.formattedAddress + ', no box)');
      cache.getRange(rowNum, 2, 1, 10).setValues([[
        newQuery, 'NO_BOUNDS', res.formattedAddress, '', '', '', '', res.lat, res.lng, today
      ]]);
    } else {
      fixed.push(name + ' -> ' + res.formattedAddress);
      cache.getRange(rowNum, 2, 1, 10).setValues([[
        newQuery, 'OK', res.formattedAddress,
        res.bounds.sw_lat, res.bounds.sw_lng, res.bounds.ne_lat, res.bounds.ne_lng,
        res.lat, res.lng, today
      ]]);
    }
  }

  var doubleCheck = fixed.filter(function (f) {
    return f.indexOf('Mosel') === 0 || f.indexOf('Rocky Mountains') === 0;
  });

  var msg = 'rgnRetryBadRegions\n' +
    'attempted: ' + RGN_RETRY_QUERIES.length + ' of the 18 confirmed-bad regions\n\n' +
    'RECOVERED, now OK (' + fixed.length + '):\n' + (fixed.length ? '  ' + fixed.join('\n  ') : '  (none)') + '\n\n' +
    'STILL COLLAPSED TO THE WHOLE COUNTRY (' + stillBad.length + '):\n' + (stillBad.length ? '  ' + stillBad.join('\n  ') : '  (none)') + '\n\n' +
    'FOUND, BUT NO USABLE BOUNDARY (' + noBounds.length + '):\n' + (noBounds.length ? '  ' + noBounds.join('\n  ') : '  (none)') + '\n\n' +
    'NOT FOUND AT ALL (' + notFound.length + '):\n' + (notFound.length ? '  ' + notFound.join(', ') : '  (none)') + '\n\n' +
    (missingRow.length ? 'WARNING - no existing cache row found for: ' + missingRow.join(', ') + '\n\n' : '') +
    (doubleCheck.length ? '*** DOUBLE-CHECK BEFORE TRUSTING: ' + doubleCheck.join('; ') + ' — the script can only rule out a whole-country match, not another wrong small place. Glance at the formatted_address before accepting suggestions from these. ***\n\n' : '') +
    'NEXT: run rgnMatchCitiesToRegions(), then do the planned review pass.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// Lowercases, strips accents, and folds known country-name aliases so
// "Türkiye" (what Google returns) correctly matches "Turkey" (the hint
// used in RGN_REGION_LIST). Same idea as the check proven out during the
// cleanup pass.
function rgnFoldCountryName_(s) {
  if (!s) return '';
  var noAccents = s.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  var lower = noAccents.trim().toLowerCase();
  var aliases = { 'turkiye': 'turkey' };
  return aliases[lower] || lower;
}
