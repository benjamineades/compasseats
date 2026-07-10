/**
 * CompassEats — Cross-City Collision Verification Fix (Step B, batch 1)
 * =======================================================================
 * fixCollisionVerificationLabels.gs — July 9, 2026 (rev 3)
 *
 * WHY REV 3
 *   Rev 2 had a real logic bug: it treated a venue as "already done" if ANY
 *   row for that venue already held the target city. But these venues appear
 *   under several award sources — e.g. "Herons" has one correct la-liste row
 *   ("Cary") AND seven wrong Forbes rows ("Raleigh-Durham, North Carolina").
 *   Rev 2 saw the correct row and skipped the seven wrong ones — exactly the
 *   rows that make it a collision. Rev 3 fixes EVERY wrong row regardless of
 *   whether another row is already correct.
 *
 * TWO MATCH MODES (per edit, in the list below)
 *   mode:'exact'    -> change only rows whose city currently equals oldCity.
 *                      (63 solid cases where the wrong label is known exactly.)
 *   mode:'anywrong' -> single-location venue: set EVERY row for this venue in
 *                      this tab to newCity, except rows already = newCity.
 *                      (8 cases whose wrong label drifted across earlier fixes
 *                      — e.g. The French Laundry, where "Napa"/"Napa,
 *                      California" must become the more specific "Yountville".)
 *                      Safe because each was verified single-location.
 *
 * SAFETY
 *   - Only ever writes the city cell. No deletes. Only the 8 named tabs.
 *   - Tolerant venue-name match (curly vs straight quotes folded, whitespace
 *     collapsed, case-insensitive; accents kept — they distinguish cities).
 *   - Every SKIP logs the exact city text the sheet holds now, so nothing is
 *     a black box.
 *
 * RUN
 *   1. Apps Script → open fixCollisionVerificationLabels → replace all with
 *      this → Save.
 *   2. Run → fixCollisionVerificationLabels. Authorize if asked. (If it times
 *      out, just run again — that's a transient Google hiccup.)
 *   3. Read popup, open "collision_label_fix_log", paste it back for review
 *      BEFORE running reshape / merge.
 */

var CVL_LOG_TAB = 'collision_label_fix_log';

var CVL_EDITS = [
  { tab: 'OAD Europe 2025', name: 'Can Jubany', oldCity: 'Bacoli', newCity: 'Calldetenes', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'De Gieser Wildeman', oldCity: 'aachen, Netherlands', newCity: 'Noordeloos', mode: 'exact' },
  { tab: 'OAD Europe 2025', name: 'Fagn', oldCity: 'London', newCity: 'Trondheim', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'John\'s House', oldCity: 'Dorking, United Kingdom', newCity: 'Loughborough', mode: 'exact' },
  { tab: 'OAD Europe 2025', name: 'Kommilfoo', oldCity: 'London', newCity: 'Antwerp', mode: 'exact' },
  { tab: 'Best Chef Awards', name: 'La Petite Colombe', oldCity: 'Cape Town, South Africa', newCity: 'Franschhoek', mode: 'exact' },
  { tab: 'OAD Europe 2025', name: 'Moments', oldCity: 'Aughton', newCity: 'Barcelona', mode: 'exact' },
  { tab: 'OAD Europe 2025', name: 'Mraz & Sohn', oldCity: 'Munich', newCity: 'Vienna', mode: 'exact' },
  { tab: 'OAD North America 2026', name: 'Omakase @ Barracks Row', oldCity: 'New York', newCity: 'Washington', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Manresa', oldCity: 'San Francisco', newCity: 'Los Gatos', mode: 'anywrong' },
  { tab: 'Worlds 50 Best', name: 'Chainaya Tea & Cocktails', oldCity: 'Athens', newCity: 'Moscow', mode: 'exact' },
  { tab: 'Restaurant Awards', name: '1919 Restaurant', oldCity: 'Puerto Rico', newCity: 'San Juan', mode: 'exact' },
  { tab: 'Worlds 50 Best', name: 'L\'Auberge de l\'Ill', oldCity: 'Alsace', newCity: 'Illhaeusern', mode: 'exact' },
  { tab: 'OAD North America 2026', name: 'Blue by Eric Ripert', oldCity: 'Georgetown', newCity: 'Cayman Islands', mode: 'exact' },
  { tab: 'OAD North America 2025', name: 'Blue by Eric Ripert', oldCity: 'Georgetown', newCity: 'Cayman Islands', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Blue by Eric Ripert', oldCity: 'George Town', newCity: 'Cayman Islands', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Blue Hill at Stone Barns', oldCity: 'Hudson Valley, New York', newCity: 'Tarrytown', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Caruso\'s', oldCity: 'Montecito, CA, United States', newCity: 'Santa Barbara', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Caruso\'s', oldCity: 'Montecito', newCity: 'Santa Barbara', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Coast', oldCity: 'Watch Hill, Rhode Island', newCity: 'Westerly', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Cocina de Autor', oldCity: 'Los Cabos', newCity: 'Cabo San Lucas', mode: 'exact' },
  { tab: 'Best Chef Awards', name: 'Conservatorium', oldCity: 'Ciudad Colón, Costa Rica', newCity: 'San José', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Forge', oldCity: 'Richmond', newCity: 'Middleton Tyas', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Harrimans Grill', oldCity: 'Northern Virginia', newCity: 'Middleburg', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Herons', oldCity: 'Raleigh-Durham, North Carolina', newCity: 'Cary', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Ixi\'im', oldCity: 'Merida, Mexico', newCity: 'Chocholá', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Kai Restaurant', oldCity: 'Phoenix', newCity: 'Chandler', mode: 'anywrong' },
  { tab: 'OAD Japan 2025', name: 'L\'évo', oldCity: 'Nanto', newCity: 'Toyama', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'L\'évo', oldCity: 'Nanto', newCity: 'Toyama', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'L’évo', oldCity: 'Nanto', newCity: 'Toyama', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'La Bòria', oldCity: 'Privas', newCity: 'Veyras', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'La Cuisine Rademacher', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'La Mer', oldCity: 'Oahu, Hawaii', newCity: 'Honolulu', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'La Rei Natura by Michelangelo Mammoliti', oldCity: 'Piedmont, Italy', newCity: 'Serralunga d\'Alba', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Lautrec', oldCity: 'Laurel Highlands, Pennsylvania', newCity: 'Farmington', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Le Moissonnier Bistro', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Auberge du Père Bise', oldCity: 'Talloires', newCity: 'Talloires-Montmin', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Madera', oldCity: 'San José', newCity: 'Menlo Park', mode: 'anywrong' },
  { tab: 'Michelin Guide', name: 'Maximo', oldCity: 'Houston, TX, United States', newCity: 'West University Place', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Mil', oldCity: 'Cusco', newCity: 'Moray', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Mugen', oldCity: 'Oahu, Hawaii', newCity: 'Honolulu', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Orchids', oldCity: 'Oahu, Hawaii', newCity: 'Honolulu', mode: 'exact' },
  { tab: 'Best Chef Awards', name: 'Ox & Klee', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Ox & Klee', oldCity: 'Cologne', newCity: 'Köln', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Pottkind', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'La Société', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'La Société', oldCity: 'Cologne', newCity: 'Köln', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'maximilian lorenz', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Don Alfonso 1890', oldCity: 'Sant\'Agata sui Due Golfi, Italy', newCity: 'Massa Lubrense', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Sahila - The Restaurant', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Salt', oldCity: 'Amelia Island', newCity: 'Fernandina Beach', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Sierra Mar Restaurant', oldCity: 'Monterey, Carmel and Big Sur, California', newCity: 'Big Sur', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Søllerød Kro', oldCity: 'Copenhagen, Denmark', newCity: 'Holte', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'taku', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Terre', oldCity: 'Cork', newCity: 'Castlemartyr', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'The Angel at Hetton', oldCity: 'Skipton', newCity: 'Hetton', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'The Elderberry House', oldCity: 'Tahoe and Yosemite, California', newCity: 'Oakhurst', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'The Fearrington House Restaurant', oldCity: 'Raleigh-Durham, North Carolina', newCity: 'Pittsboro', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'The French Laundry', oldCity: 'Napa', newCity: 'Yountville', mode: 'anywrong' },
  { tab: 'Restaurant Awards', name: 'The Inn at Little Washington', oldCity: 'Northern Virginia, District of Columbia', newCity: 'Washington', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'The Ocean Room', oldCity: 'Charleston', newCity: 'Kiawah Island', mode: 'anywrong' },
  { tab: 'Restaurant Awards', name: 'The Pines Modern Steakhouse', oldCity: 'Los Angeles', newCity: 'Inland Empire, California', mode: 'anywrong' },
  { tab: 'Restaurant Awards', name: 'The Restaurant at JUSTIN', oldCity: 'Monterey, Carmel and Big Sur, California', newCity: 'Paso Robles', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'The Village Pub', oldCity: 'San Francisco', newCity: 'Woodside', mode: 'anywrong' },
  { tab: 'Restaurant Awards', name: 'The White Barn Inn Restaurant', oldCity: 'The Kennebunks, Maine', newCity: 'Kennebunk', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Twenty-Eight Atlantic', oldCity: 'Cape Cod, Massachusetts', newCity: 'Harwich', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Yanagiya', oldCity: 'Mizunami', newCity: 'Gifu', mode: 'exact' },
  { tab: 'Michelin Guide', name: 'Zur Tant', oldCity: 'Cologne, Germany', newCity: 'Köln', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Aubergine at L\'Auberge Carmel', oldCity: 'Monterey, Carmel and Big Sur, California', newCity: 'Carmel by the Sea', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'Restaurante HA\'', oldCity: 'Riviera Maya', newCity: 'Playa del Carmen', mode: 'exact' },
  { tab: 'Restaurant Awards', name: 'SingleThread Farms Restaurant', oldCity: 'Sonoma', newCity: 'Healdsburg', mode: 'anywrong' },
];

function fixCollisionVerificationLabels() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  var byTab = {};
  for (var i = 0; i < CVL_EDITS.length; i++) {
    var e = CVL_EDITS[i];
    (byTab[e.tab] = byTab[e.tab] || []).push(e);
  }

  var logRows = [];
  var editsApplied = 0, rowsChanged = 0, skipped = 0;

  for (var tabName in byTab) {
    var sheet = resolveSheet_(ss, tabName);
    if (!sheet) {
      byTab[tabName].forEach(function (e) {
        logRows.push(['SKIP (tab not found — check exact tab name)', tabName, e.name, e.oldCity, e.newCity, '']);
        skipped++;
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
        skipped++;
      });
      continue;
    }

    byTab[tabName].forEach(function (e) {
      var wantName = normStr_(e.name);
      var wantOld = normStr_(e.oldCity);
      var wantNew = normStr_(e.newCity);

      var toChange = [];
      var citiesSeen = {};
      var alreadyTarget = 0;

      for (var r = 1; r < vals.length; r++) {
        if (normStr_(vals[r][nameCol]) !== wantName) continue;
        var rcRaw = String(vals[r][cityCol] || '').trim();
        var rc = normStr_(rcRaw);
        citiesSeen[rcRaw] = (citiesSeen[rcRaw] || 0) + 1;
        if (rc === wantNew) { alreadyTarget++; continue; }
        if (e.mode === 'anywrong') {
          toChange.push(r);                    // any non-target row for this venue
        } else if (rc === wantOld) {
          toChange.push(r);                    // exact old-label rows only
        }
      }

      if (toChange.length > 0) {
        var rowNums = [];
        for (var mi = 0; mi < toChange.length; mi++) {
          var rr = toChange[mi];
          sheet.getRange(rr + 1, cityCol + 1).setValue(e.newCity);
          rowNums.push(rr + 1);
          rowsChanged++;
        }
        logRows.push(['APPLIED (' + toChange.length + ' row' + (toChange.length > 1 ? 's' : '') + ')',
          tabName, e.name, e.oldCity, e.newCity, rowNums.join(', ')]);
        editsApplied++;
        return;
      }

      var seen = Object.keys(citiesSeen);
      if (seen.length === 0) {
        logRows.push(['SKIP (venue not found in this tab)', tabName, e.name, e.oldCity, e.newCity, '']);
      } else if (alreadyTarget > 0) {
        logRows.push(['OK (already ' + e.newCity + ')', tabName, e.name, e.oldCity, e.newCity, '']);
      } else {
        logRows.push(['SKIP (sheet city is: ' + seen.join(' | ') + ')', tabName, e.name, e.oldCity, e.newCity, '']);
      }
      skipped++;
    });
  }

  var log = ss.getSheetByName(CVL_LOG_TAB);
  if (log) log.clear(); else log = ss.insertSheet(CVL_LOG_TAB);
  var logHeaders = ['result', 'tab', 'name', 'old city', 'new city', 'row'];
  log.getRange(1, 1, 1, logHeaders.length).setValues([logHeaders]).setFontWeight('bold');
  if (logRows.length) log.getRange(2, 1, logRows.length, logHeaders.length).setValues(logRows);
  log.setFrozenRows(1);

  var msg = 'fixCollisionVerificationLabels complete.\n' +
    'Unique corrections in list: ' + CVL_EDITS.length + '\n' +
    'Corrections applied: ' + editsApplied + '\n' +
    'Individual rows changed: ' + rowsChanged + '\n' +
    'Skipped: ' + skipped + '\n\n' +
    'Open "' + CVL_LOG_TAB + '". SKIP rows show the city the sheet actually\n' +
    'holds; OK rows were already correct.\n\n' +
    'Paste the log back for review BEFORE running reshape / merge.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

/** Find a sheet by name, tolerant of curly/straight apostrophe differences
 *  (e.g. list says "Worlds 50 Best" but the tab is "World's 50 Best"). */
function resolveSheet_(ss, tabName) {
  var direct = ss.getSheetByName(tabName);
  if (direct) return direct;
  var target = normStr_(tabName);
  var all = ss.getSheets();
  for (var i = 0; i < all.length; i++) {
    if (normStr_(all[i].getName()) === target) return all[i];
  }
  return null;
}

/** Fold curly quotes/apostrophes to straight, collapse whitespace, lowercase. */
function normStr_(s) {
  return String(s == null ? '' : s)
    .replace(/[\u2018\u2019\u02BC\u2032]/g, "'")
    .replace(/[\u201C\u201D]/g, '"')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}
