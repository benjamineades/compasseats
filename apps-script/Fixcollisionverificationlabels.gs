/**
 * CompassEats — Cross-City Collision Verification Fix (Step B, batch 1)
 * =======================================================================
 * fixCollisionVerificationLabels.gs — July 9, 2026 (rev 2)
 *
 * WHAT THIS FIXES
 *   The Cowork verification pass on the merge_review collisions produced 63
 *   ALIAS + 22 PHANTOM decisions for real, single-location venues that carry
 *   a wrong or region-level city label in a source award tab. Tracing those
 *   to source rows gave 72 unique venue+city corrections across 8 tabs.
 *   Fixing the label at the SOURCE row (not the venues tab) is the durable
 *   fix — the venues tab is rebuilt from these tabs on every reshape.
 *
 * REV 2 — why this version exists
 *   Rev 1 matched the city cell as an EXACT full string and skipped any
 *   ambiguous/curly-apostrophe/whitespace difference, which caused all 72 to
 *   skip on the live sheet. Rev 2:
 *     - Matches the venue NAME tolerantly (curly vs straight apostrophes and
 *       quotes folded, whitespace collapsed, case-insensitive). Accents are
 *       kept, since they distinguish real cities.
 *     - Updates every row for that venue whose city STILL equals the old
 *       label (venues repeat once per award year — all should change).
 *     - If it changes nothing, it logs WHY using the city the sheet actually
 *       holds right now — so a skip is self-explaining, never a black box.
 *     - Never edits a row that is already the target city.
 *   Nothing is deleted; only the city cell is ever written; only these 8 tabs
 *   are touched.
 *
 * HOW TO RUN
 *   1. Extensions → Apps Script → open the fixCollisionVerificationLabels
 *      file → replace its whole contents with this → Save.
 *   2. Run → fixCollisionVerificationLabels. Authorize if prompted.
 *   3. Read the popup, then open "collision_label_fix_log" and skim it.
 *      Paste the log back for review BEFORE running reshape/merge.
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

  var byTab = {};
  for (var i = 0; i < CVL_EDITS.length; i++) {
    var e = CVL_EDITS[i];
    (byTab[e.tab] = byTab[e.tab] || []).push(e);
  }

  var logRows = [];
  var editsApplied = 0, rowsChanged = 0, skipped = 0;

  for (var tabName in byTab) {
    var sheet = ss.getSheetByName(tabName);
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

      var matchedRows = [];
      var citiesSeen = {};
      var alreadyTarget = 0;

      for (var r = 1; r < vals.length; r++) {
        if (normStr_(vals[r][nameCol]) !== wantName) continue;
        var rcRaw = String(vals[r][cityCol] || '').trim();
        var rc = normStr_(rcRaw);
        citiesSeen[rcRaw] = (citiesSeen[rcRaw] || 0) + 1;
        if (rc === wantNew) { alreadyTarget++; continue; }
        if (rc === wantOld) matchedRows.push(r);
      }

      if (matchedRows.length > 0) {
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
        return;
      }

      var seen = Object.keys(citiesSeen);
      if (seen.length === 0) {
        logRows.push(['SKIP (venue not found in this tab)', tabName, e.name, e.oldCity, e.newCity, '']);
      } else if (alreadyTarget > 0 && seen.length === 1) {
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
    'Open "' + CVL_LOG_TAB + '". Every SKIP now shows the city the sheet\n' +
    'actually holds for that venue, so mismatches explain themselves.\n\n' +
    'Paste the log back for review BEFORE running reshape / merge.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

/** Fold curly quotes/apostrophes to straight, collapse whitespace, lowercase.
 *  Accents kept on purpose (they distinguish real cities). */
function normStr_(s) {
  return String(s == null ? '' : s)
    .replace(/[\u2018\u2019\u02BC\u2032]/g, "'")
    .replace(/[\u201C\u201D]/g, '"')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}
