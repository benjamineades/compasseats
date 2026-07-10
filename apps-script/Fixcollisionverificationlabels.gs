/**
 * CompassEats — Cross-City Collision Verification Fix (Step B, batch 1)
 * =======================================================================
 * fixCollisionVerificationLabels.gs — July 9, 2026
 *
 * WHAT THIS FIXES
 *   The Cowork verification pass on the 236 merge_review groups (281 far-city
 *   rows) came back with 63 ALIAS + 22 PHANTOM decisions. Tracing each of
 *   those 85 to the exact source award-tab row (not just the venues tab)
 *   turned up 145 individual source rows across 8 different tabs that carry
 *   a wrong or region-label city name for a real, single-location venue.
 *   Every one of these 145 was independently re-verified against BOTH the
 *   venue's real address country AND an exact re-derivation of reshape's own
 *   slugify_() logic, so the "old city" text this script looks for should
 *   match the live sheet exactly.
 *
 * WHAT IT DOES
 *   - For each entry below: finds EVERY row in the named tab whose name AND
 *     city cell match { name, oldCity } EXACTLY, and overwrites ONLY that
 *     city cell with newCity.
 *   - Multiple matches are EXPECTED and correct: award tabs (especially the
 *     Forbes-fed "Restaurant Awards") carry one row per award year, so a
 *     single venue like "Herons / Raleigh-Durham, North Carolina" legitimately
 *     appears 7 times (2020-2026). All of them are the same physical venue and
 *     all should get the same corrected city — so the script updates them all.
 *   - If a row can't be found with that exact (name, oldCity) pair — because
 *     the sheet changed since this list was built (e.g. a prior fix already
 *     renamed it) — it is SKIPPED, not guessed at, and logged for review.
 *   - Logs every successful edit AND every skip to a
 *     "collision_label_fix_log" tab. Nothing is silent.
 *   - Touches NOTHING else: no deletes, no other columns, no other tabs.
 *
 * WHAT IS DELIBERATELY EXCLUDED FROM THIS BATCH (see session notes / the
 * companion worklist for the full list and reasoning):
 *   - 4 cases (Bistro Quellenhof, Masterpiece, Table & Main, SOURCE at
 *     Gilpin Hotel) where every source row already has the CORRECT city —
 *     the duplicate is coming from a stray Places Enrichment/geo-requery-
 *     review row, not a source-tab typo. Needs enrichment-tab cleanup, not
 *     this kind of fix.
 *   - 3 cases (Tales by Chapter, Restaurant Troisgros Le Bois sans
 *     feuilles, Tohru*** - Fine Dining) where automatic name-matching only
 *     found an unrelated same-ish-named venue. Excluded rather than risk a
 *     wrong edit — needs a human look.
 *   - 12 cases where no source row could be traced at all — several
 *     confirmed as live symptoms of the still-open root-cause bug from the
 *     very first handoff (bare-name-key fallback in the enrichment lookup).
 *
 * HOW TO RUN
 *   1. Extensions → Apps Script → + → Script → name it
 *      fixCollisionVerificationLabels → paste this whole file → Save.
 *   2. Run → fixCollisionVerificationLabels. Authorize if prompted.
 *   3. Read the alert; review the "collision_label_fix_log" tab — check the
 *      "skipped / mismatch" rows especially, there should be few or none.
 *   4. THEN run reshapeCompassEats → mergeDuplicateVenues as usual.
 */

var CVL_LOG_TAB = 'collision_label_fix_log';

var CVL_EDITS = [
  { tab: 'OAD Europe 2025', name: 'Can Jubany', oldCity: 'Bacoli', newCity: 'Calldetenes' },
  { tab: 'Michelin Guide', name: 'De Gieser Wildeman', oldCity: 'aachen, Netherlands', newCity: 'Noordeloos' },
  { tab: 'OAD Europe 2025', name: 'Fagn', oldCity: 'London', newCity: 'Trondheim' },
  { tab: 'Michelin Guide', name: 'John\'s House', oldCity: 'Dorking, United Kingdom', newCity: 'Loughborough' },
  { tab: 'OAD Europe 2025', name: 'Kommilfoo', oldCity: 'London', newCity: 'Antwerp' },
  { tab: 'Best Chef Awards', name: 'La Petite Colombe', oldCity: 'Cape Town, South Africa', newCity: 'Franschhoek' },
  { tab: 'OAD Europe 2025', name: 'Moments', oldCity: 'Aughton', newCity: 'Barcelona' },
  { tab: 'OAD Europe 2025', name: 'Mraz & Sohn', oldCity: 'Munich', newCity: 'Vienna' },
  { tab: 'OAD North America 2026', name: 'Omakase @ Barracks Row', oldCity: 'New York', newCity: 'Washington' },
  { tab: 'Restaurant Awards', name: 'Manresa', oldCity: 'San Francisco', newCity: 'Los Gatos' },
  { tab: 'Worlds 50 Best', name: 'Chainaya Tea & Cocktails', oldCity: 'Athens', newCity: 'Moscow' },
  { tab: 'Restaurant Awards', name: '1919 Restaurant', oldCity: 'Puerto Rico', newCity: 'San Juan' },
  { tab: 'Worlds 50 Best', name: 'L\'Auberge de l\'Ill', oldCity: 'Alsace', newCity: 'Illhaeusern' },
  { tab: 'OAD North America 2026', name: 'Blue by Eric Ripert', oldCity: 'Georgetown', newCity: 'Cayman Islands' },
  { tab: 'OAD North America 2025', name: 'Blue by Eric Ripert', oldCity: 'Georgetown', newCity: 'Cayman Islands' },
  { tab: 'Restaurant Awards', name: 'Blue by Eric Ripert', oldCity: 'George Town', newCity: 'Cayman Islands' },
  { tab: 'Restaurant Awards', name: 'Blue Hill at Stone Barns', oldCity: 'Hudson Valley, New York', newCity: 'Tarrytown' },
  { tab: 'Michelin Guide', name: 'Caruso\'s', oldCity: 'Montecito, CA, United States', newCity: 'Santa Barbara' },
  { tab: 'Restaurant Awards', name: 'Caruso\'s', oldCity: 'Montecito', newCity: 'Santa Barbara' },
  { tab: 'Restaurant Awards', name: 'Coast', oldCity: 'Watch Hill, Rhode Island', newCity: 'Westerly' },
  { tab: 'Restaurant Awards', name: 'Cocina de Autor', oldCity: 'Los Cabos', newCity: 'Cabo San Lucas' },
  { tab: 'Best Chef Awards', name: 'Conservatorium', oldCity: 'Ciudad Colón, Costa Rica', newCity: 'San José' },
  { tab: 'Restaurant Awards', name: 'Forge', oldCity: 'Richmond', newCity: 'Middleton Tyas' },
  { tab: 'Restaurant Awards', name: 'Harrimans Grill', oldCity: 'Northern Virginia', newCity: 'Middleburg' },
  { tab: 'Restaurant Awards', name: 'Herons', oldCity: 'Raleigh-Durham, North Carolina', newCity: 'Cary' },
  { tab: 'Michelin Guide', name: 'Ixi\'im', oldCity: 'Merida, Mexico', newCity: 'Chocholá' },
  { tab: 'Restaurant Awards', name: 'Kai Restaurant', oldCity: 'Phoenix', newCity: 'Chandler' },
  { tab: 'OAD Japan 2025', name: 'L\'évo', oldCity: 'Nanto', newCity: 'Toyama' },
  { tab: 'Restaurant Awards', name: 'L\'évo', oldCity: 'Nanto', newCity: 'Toyama' },
  { tab: 'Restaurant Awards', name: 'L’évo', oldCity: 'Nanto', newCity: 'Toyama' },
  { tab: 'Restaurant Awards', name: 'La Bòria', oldCity: 'Privas', newCity: 'Veyras' },
  { tab: 'Michelin Guide', name: 'La Cuisine Rademacher', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'La Mer', oldCity: 'Oahu, Hawaii', newCity: 'Honolulu' },
  { tab: 'Michelin Guide', name: 'La Rei Natura by Michelangelo Mammoliti', oldCity: 'Piedmont, Italy', newCity: 'Serralunga d\'Alba' },
  { tab: 'Restaurant Awards', name: 'Lautrec', oldCity: 'Laurel Highlands, Pennsylvania', newCity: 'Farmington' },
  { tab: 'Michelin Guide', name: 'Le Moissonnier Bistro', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'Auberge du Père Bise', oldCity: 'Talloires', newCity: 'Talloires-Montmin' },
  { tab: 'Restaurant Awards', name: 'Madera', oldCity: 'San José', newCity: 'Menlo Park' },
  { tab: 'Michelin Guide', name: 'Maximo', oldCity: 'Houston, TX, United States', newCity: 'West University Place' },
  { tab: 'Restaurant Awards', name: 'Mil', oldCity: 'Cusco', newCity: 'Moray' },
  { tab: 'Restaurant Awards', name: 'Mugen', oldCity: 'Oahu, Hawaii', newCity: 'Honolulu' },
  { tab: 'Restaurant Awards', name: 'Orchids', oldCity: 'Oahu, Hawaii', newCity: 'Honolulu' },
  { tab: 'Best Chef Awards', name: 'Ox & Klee', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'Ox & Klee', oldCity: 'Cologne', newCity: 'Köln' },
  { tab: 'Michelin Guide', name: 'Pottkind', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Michelin Guide', name: 'La Société', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'La Société', oldCity: 'Cologne', newCity: 'Köln' },
  { tab: 'Michelin Guide', name: 'maximilian lorenz', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Michelin Guide', name: 'Don Alfonso 1890', oldCity: 'Sant\'Agata sui Due Golfi, Italy', newCity: 'Massa Lubrense' },
  { tab: 'Michelin Guide', name: 'Sahila - The Restaurant', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'Salt', oldCity: 'Amelia Island', newCity: 'Fernandina Beach' },
  { tab: 'Restaurant Awards', name: 'Sierra Mar Restaurant', oldCity: 'Monterey, Carmel and Big Sur, California', newCity: 'Big Sur' },
  { tab: 'Michelin Guide', name: 'Søllerød Kro', oldCity: 'Copenhagen, Denmark', newCity: 'Holte' },
  { tab: 'Michelin Guide', name: 'taku', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'Terre', oldCity: 'Cork', newCity: 'Castlemartyr' },
  { tab: 'Restaurant Awards', name: 'The Angel at Hetton', oldCity: 'Skipton', newCity: 'Hetton' },
  { tab: 'Restaurant Awards', name: 'The Elderberry House', oldCity: 'Tahoe and Yosemite, California', newCity: 'Oakhurst' },
  { tab: 'Restaurant Awards', name: 'The Fearrington House Restaurant', oldCity: 'Raleigh-Durham, North Carolina', newCity: 'Pittsboro' },
  { tab: 'Restaurant Awards', name: 'The French Laundry', oldCity: 'Napa', newCity: 'Yountville' },
  { tab: 'Restaurant Awards', name: 'The Inn at Little Washington', oldCity: 'Northern Virginia, District of Columbia', newCity: 'Washington' },
  { tab: 'Restaurant Awards', name: 'The Ocean Room', oldCity: 'Charleston', newCity: 'Kiawah Island' },
  { tab: 'Restaurant Awards', name: 'The Pines Modern Steakhouse', oldCity: 'Los Angeles', newCity: 'Inland Empire, California' },
  { tab: 'Restaurant Awards', name: 'The Restaurant at JUSTIN', oldCity: 'Monterey, Carmel and Big Sur, California', newCity: 'Paso Robles' },
  { tab: 'Restaurant Awards', name: 'The Village Pub', oldCity: 'San Francisco', newCity: 'Woodside' },
  { tab: 'Restaurant Awards', name: 'The White Barn Inn Restaurant', oldCity: 'The Kennebunks, Maine', newCity: 'Kennebunk' },
  { tab: 'Restaurant Awards', name: 'The White Barn Inn Restaurant', oldCity: 'Coastal Maine', newCity: 'Kennebunk' },
  { tab: 'Restaurant Awards', name: 'Twenty-Eight Atlantic', oldCity: 'Cape Cod, Massachusetts', newCity: 'Harwich' },
  { tab: 'Restaurant Awards', name: 'Yanagiya', oldCity: 'Mizunami', newCity: 'Gifu' },
  { tab: 'Michelin Guide', name: 'Zur Tant', oldCity: 'Cologne, Germany', newCity: 'Köln' },
  { tab: 'Restaurant Awards', name: 'Aubergine at L\'Auberge Carmel', oldCity: 'Monterey, Carmel and Big Sur, California', newCity: 'Carmel by the Sea' },
  { tab: 'Restaurant Awards', name: 'Restaurante HA\'', oldCity: 'Riviera Maya', newCity: 'Playa del Carmen' },
  { tab: 'Restaurant Awards', name: 'SingleThread Farms Restaurant', oldCity: 'Sonoma', newCity: 'Healdsburg' },
];

function fixCollisionVerificationLabels() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  // Group edits by tab so each tab's data is only read once.
  var byTab = {};
  for (var i = 0; i < CVL_EDITS.length; i++) {
    var e = CVL_EDITS[i];
    (byTab[e.tab] = byTab[e.tab] || []).push(e);
  }

  var logRows = [];
  var editsApplied = 0, rowsChanged = 0, skippedNotFound = 0;

  for (var tabName in byTab) {
    var sheet = ss.getSheetByName(tabName);
    if (!sheet) {
      byTab[tabName].forEach(function (e) {
        logRows.push(['SKIP (tab not found)', tabName, e.name, e.oldCity, e.newCity, '']);
        skippedNotFound++;
      });
      continue;
    }
    var vals = sheet.getDataRange().getValues();
    var headers = vals[0];
    var nameCol = -1, cityCol = -1;
    for (var h = 0; h < headers.length; h++) {
      var hn = String(headers[h]).trim().toLowerCase();
      if (hn === 'name' || hn === 'restaurant') nameCol = h;
      if (hn === 'city' || hn === 'location') cityCol = h;
    }
    if (nameCol === -1 || cityCol === -1) {
      byTab[tabName].forEach(function (e) {
        logRows.push(['SKIP (name/city column not found)', tabName, e.name, e.oldCity, e.newCity, '']);
        skippedNotFound++;
      });
      continue;
    }

    byTab[tabName].forEach(function (e) {
      var matchedRows = [];
      for (var r = 1; r < vals.length; r++) {
        var rowName = String(vals[r][nameCol] || '').trim();
        var rowCity = String(vals[r][cityCol] || '').trim();
        if (rowName === e.name && rowCity === e.oldCity) matchedRows.push(r);
      }
      if (matchedRows.length === 0) {
        logRows.push(['SKIP (not found — may already be fixed)', tabName, e.name, e.oldCity, e.newCity, '']);
        skippedNotFound++;
        return;
      }
      // Update EVERY matching row (same venue repeated across award years).
      var rowNums = [];
      for (var mi = 0; mi < matchedRows.length; mi++) {
        var rr = matchedRows[mi];
        sheet.getRange(rr + 1, cityCol + 1).setValue(e.newCity);
        rowNums.push(rr + 1);
        rowsChanged++;
      }
      logRows.push(['APPLIED (' + matchedRows.length + ' row' + (matchedRows.length > 1 ? 's' : '') + ')',
        tabName, e.name, e.oldCity, e.newCity, rowNums.join(', ')]);
      editsApplied++;
    });
  }

  var log = ss.getSheetByName(CVL_LOG_TAB);
  if (log) log.clear(); else log = ss.insertSheet(CVL_LOG_TAB);
  var logHeaders = ['result', 'tab', 'name', 'old city', 'new city', 'row'];
  log.getRange(1, 1, 1, logHeaders.length).setValues([logHeaders]).setFontWeight('bold');
  if (logRows.length) {
    log.getRange(2, 1, logRows.length, logHeaders.length).setValues(logRows);
  }
  log.setFrozenRows(1);

  var msg = 'fixCollisionVerificationLabels complete.\n' +
    'Unique venue-city corrections: ' + CVL_EDITS.length + '\n' +
    'Corrections applied: ' + editsApplied + ' (expected 72)\n' +
    'Individual rows changed: ' + rowsChanged + ' (venues repeat across award years)\n' +
    'Skipped - not found: ' + skippedNotFound + '\n\n' +
    '(A few "not found" skips are normal — some Forbes rows were already\n' +
    'relabeled by the earlier fixForbesCityLabels run.)\n\n' +
    'Full record in the "' + CVL_LOG_TAB + '" tab.\n\n' +
    'NEXT: run reshapeCompassEats, then mergeDuplicateVenues.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}
