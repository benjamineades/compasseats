/**
 * phase1aPassTwo.gs — CompassEats · Phase 1a, second pass
 * ------------------------------------------------------------------
 * Reads the RAW `venues` tab directly with getDataRange().getValues(),
 * per the Aug 10 response: pass one validated the publish path; this
 * pass validates the source. No exports, no export-of-export.
 *
 * READ-ONLY. Writes nothing. Safe to run any number of times.
 *
 * WHAT IT PRINTS
 *   1. The tab's headers (schema-drift visibility)
 *   2. Total rows + status counts vs the published expectation
 *   3. Fully blank rows inside the data range (structural-drop smell)
 *   4. Blank required fields: name / city / country
 *   5. Duplicate normalised name+city count on the raw tab
 *   6. needs_enrichment count (expect 59)
 *   7. Raw-tab occurrences of the four sources absent from publish:
 *      tabelog, africa-50-best-restaurants,
 *      worlds-50-best-restaurants-51-100, worlds-50-best-bars-51-100
 *      (any count > 0 here = in source but lost at publish; 0 = never ingested)
 *   8. Top-30 city counts vs published (aliases can cause small deltas;
 *      big deltas are the signal)
 *
 * HOW TO RUN
 *   Extensions -> Apps Script -> new Script file -> paste -> save ->
 *   select phase1aPassTwo -> Run -> paste the execution log.
 * ------------------------------------------------------------------
 */

var P1A2_TAB_ = 'venues';
var P1A2_EXPECT_TOTAL_ = 10912;
var P1A2_EXPECT_STATUS_ = {"active": 10551, "closed": 361};
var P1A2_EXPECT_CITY_ = {'tokyo': 587, 'new-york': 347, 'hong-kong': 262, 'london': 246, 'paris': 200, 'singapore': 198, 'kyoto': 196, 'osaka': 154, 'seoul': 124, 'bangkok': 119, 'los-angeles': 116, 'taipei': 106, 'shanghai': 98, 'chicago': 82, 'dubai': 82, 'san-francisco': 77, 'madrid': 76, 'barcelona': 72, 'sao-paulo': 71, 'toronto': 70, 'washington-dc': 68, 'mexico-city': 67, 'beijing': 66, 'miami': 63, 'macau': 61, 'copenhagen': 59, 'guangzhou': 57, 'milan': 53, 'las-vegas': 47, 'vancouver': 45};
var P1A2_MISSING_SOURCES_ = ['tabelog','africa-50-best-restaurants','worlds-50-best-restaurants-51-100','worlds-50-best-bars-51-100'];

function phase1aPassTwo() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sh = ss.getSheetByName(P1A2_TAB_);
  if (!sh) {
    Logger.log('STOP: no tab named "' + P1A2_TAB_ + '".');
    Logger.log('Tabs found: ' + ss.getSheets().map(function(x){return x.getName();}).join(' | '));
    return;
  }
  var values = sh.getDataRange().getValues();
  var head = values[0].map(function(h){ return String(h).trim(); });
  var low = head.map(function(h){ return h.toLowerCase(); });
  Logger.log('=== PHASE 1a PASS TWO — raw venues tab, read-only ===');
  Logger.log('Headers (' + head.length + '): ' + head.join(' | '));

  function findCol(cands) {
    for (var i = 0; i < cands.length; i++) {
      var j = low.indexOf(cands[i]);
      if (j >= 0) return j;
    }
    return -1;
  }
  var cName = findCol(['name','venue_name','venue']);
  var cCity = findCol(['city_slug','city','city_display']);
  var cCountry = findCol(['country']);
  var cStatus = findCol(['status']);
  var cEnrich = findCol(['needs_enrichment','enrichment','geo_status']);

  var total = 0, blankRows = 0;
  var missName = 0, missCity = 0, missCountry = 0, enrich = 0;
  var statusCount = {};
  var cityCount = {};
  var dupKey = {};
  var srcHits = {};
  P1A2_MISSING_SOURCES_.forEach(function(s){ srcHits[s] = 0; });

  function normName(s) {
    return String(s || '').toLowerCase().replace(/[^a-z0-9]+/g, '');
  }
  function slugify(s) {
    return String(s || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  }

  for (var r = 1; r < values.length; r++) {
    var row = values[r];
    var joined = row.join('\u0001');
    if (joined.replace(/\u0001/g, '').trim() === '') { blankRows++; continue; }
    total++;
    var lowJoined = joined.toLowerCase();
    P1A2_MISSING_SOURCES_.forEach(function(s){ if (lowJoined.indexOf(s) >= 0) srcHits[s]++; });

    if (cName >= 0 && String(row[cName]).trim() === '') missName++;
    if (cCity >= 0 && String(row[cCity]).trim() === '') missCity++;
    if (cCountry >= 0 && String(row[cCountry]).trim() === '') missCountry++;
    if (cEnrich >= 0 && String(row[cEnrich]).trim() !== '' && String(row[cEnrich]).toLowerCase() !== 'no' && String(row[cEnrich]).toLowerCase() !== 'false') enrich++;

    var st = cStatus >= 0 ? String(row[cStatus]).trim().toLowerCase() : '(no status col)';
    statusCount[st] = (statusCount[st] || 0) + 1;

    if (cCity >= 0) {
      var cs = slugify(row[cCity]);
      cityCount[cs] = (cityCount[cs] || 0) + 1;
      if (cName >= 0) {
        var k = normName(row[cName]) + '@' + cs;
        dupKey[k] = (dupKey[k] || 0) + 1;
      }
    }
  }

  var dupGroups = 0, dupRows = 0;
  for (var k2 in dupKey) if (dupKey[k2] > 1) { dupGroups++; dupRows += dupKey[k2]; }

  Logger.log('');
  Logger.log('Rows: ' + total + '  (published expectation: ' + P1A2_EXPECT_TOTAL_ + ')  blank rows inside range: ' + blankRows);
  Logger.log('Status counts: ' + JSON.stringify(statusCount) + '  (published: ' + JSON.stringify(P1A2_EXPECT_STATUS_) + ')');
  Logger.log('Blank required fields — name: ' + missName + '  city: ' + missCity + '  country: ' + missCountry);
  Logger.log('Duplicate normalised name+city on RAW tab: ' + dupGroups + ' groups / ' + dupRows + ' rows  (published pass found 15 / 30)');
  Logger.log('needs_enrichment-style rows: ' + (cEnrich >= 0 ? enrich + '  (expect ~59)' : 'column not found — tell Claude the column name'));
  Logger.log('');
  Logger.log('Absent-source scan (0 = never ingested; >0 = in source but lost at publish):');
  P1A2_MISSING_SOURCES_.forEach(function(s){ Logger.log('  ' + s + ': ' + srcHits[s]); });
  Logger.log('');
  Logger.log('Top-30 city check (raw vs published active). Small deltas can be city aliases; large deltas are the signal:');
  var flagged = 0;
  for (var city in P1A2_EXPECT_CITY_) {
    var got = cityCount[city] || 0;
    var exp = P1A2_EXPECT_CITY_[city];
    var d = got - exp;
    if (Math.abs(d) > Math.max(3, Math.round(exp * 0.05))) {
      Logger.log('  INVESTIGATE ' + city + ': raw ' + got + ' vs published ' + exp + ' (delta ' + d + ')');
      flagged++;
    }
  }
  if (!flagged) Logger.log('  all 30 within tolerance');
  Logger.log('');
  Logger.log('Done. Nothing was written. Paste this log back to Claude.');
}
