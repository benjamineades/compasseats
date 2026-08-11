/**
 * phase1aPassTwo.gs — CompassEats · Phase 1a, second pass  v2
 * ------------------------------------------------------------------
 * Reads the RAW `venues` tab directly with getDataRange().getValues(),
 * per the Aug 10 response: pass one validated the publish path; this
 * pass validates the source. No exports, no export-of-export.
 *
 * READ-ONLY. Writes nothing. Safe to run any number of times.
 *
 * FIXED IN v2 (three bugs, all of which would have produced misleading
 * output rather than errors — the failure mode this project keeps hitting):
 *
 *   1. DIACRITICS. v1's slugify ran /[^a-z0-9]+/ over a string that still
 *      contained accented characters, so "São Paulo" became "s-o-paulo",
 *      never matching the expected "sao-paulo". Every accented city in the
 *      top-30 list would have flagged INVESTIGATE with a delta equal to its
 *      whole count. Now normalises NFKD and strips combining marks first,
 *      matching normKeyR_ in the ingest tools.
 *
 *   2. WHOLE-ROW SUBSTRING SEARCH. v1 scanned the entire joined row for
 *      each source slug. This is a documented dead end: an earlier audit
 *      script did exactly this for "michelin" and produced 111 false
 *      positives. It matters more here — "tabelog" appears in any
 *      tabelog.com URL sitting in a website, geo_source_url or notes
 *      column, so a source that was never ingested would report as
 *      present. Now searches the awards_json column specifically, and
 *      falls back to whole-row only if that column is absent, saying so
 *      loudly.
 *
 *   3. GUESSED ENRICHMENT SEMANTICS. v1 counted any non-empty value that
 *      was not "no" or "false" as needing enrichment. If the matched
 *      column is geo_status with values like "ok", every healthy row
 *      counts and the number is meaningless. Now reports the actual value
 *      distribution and lets a human read it.
 *
 * WHAT IT PRINTS
 *   1. The tab's headers (schema-drift visibility)
 *   2. Total rows + status counts vs the published expectation
 *   3. Fully blank rows inside the data range (structural-drop smell)
 *   4. Blank required fields: name / city / country
 *   5. Duplicate normalised name+city count on the raw tab
 *   6. Enrichment column value distribution
 *   7. awards_json occurrences of the sources absent from publish
 *   8. Top-30 city counts vs published
 *
 * HOW TO RUN
 *   Extensions -> Apps Script -> new Script file -> paste -> save ->
 *   select phase1aPassTwo -> Run -> paste the execution log.
 * ------------------------------------------------------------------
 */

var P1A2_TAB_ = 'venues';
var P1A2_EXPECT_TOTAL_ = 10912;
var P1A2_EXPECT_STATUS_ = { active: 10551, closed: 361 };
var P1A2_EXPECT_CITY_ = {
  'tokyo':587,'new-york':347,'hong-kong':262,'london':246,'paris':200,
  'singapore':198,'kyoto':196,'osaka':154,'seoul':124,'bangkok':119,
  'los-angeles':116,'taipei':106,'shanghai':98,'chicago':82,'dubai':82,
  'san-francisco':77,'madrid':76,'barcelona':72,'sao-paulo':71,'toronto':70,
  'washington-dc':68,'mexico-city':67,'beijing':66,'miami':63,'macau':61,
  'copenhagen':59,'guangzhou':57,'milan':53,'las-vegas':47,'vancouver':45
};
var P1A2_MISSING_SOURCES_ = [
  'tabelog',
  'africa-50-best-restaurants',
  'worlds-50-best-restaurants-51-100',
  'worlds-50-best-bars-51-100'
];

// ---------------------------------------------------------------------------

function p1a2Strip_(s) {
  // NFKD + strip combining marks, so accented characters survive as their
  // base letters instead of being deleted by the a-z0-9 filter.
  return String(s || '').normalize('NFKD').replace(/[\u0300-\u036f]/g, '');
}

function p1a2Slug_(s) {
  var t = p1a2Strip_(s).toLowerCase();
  t = t.replace(/['\u2018\u2019\u02BC`]/g, '');   // drop apostrophes, don't hyphenate them
  t = t.replace(/&/g, ' and ');
  t = t.replace(/[^a-z0-9]+/g, '-');
  return t.replace(/^-+|-+$/g, '');
}

function p1a2Name_(s) {
  var t = p1a2Strip_(s).toLowerCase();
  return t.replace(/[^a-z0-9]+/g, '');
}

// ---------------------------------------------------------------------------

function phase1aPassTwo() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sh = ss.getSheetByName(P1A2_TAB_);
  if (!sh) {
    Logger.log('STOP: no tab named "' + P1A2_TAB_ + '".');
    Logger.log('Tabs found: ' + ss.getSheets().map(function (x) { return x.getName(); }).join(' | '));
    return;
  }

  var values = sh.getDataRange().getValues();
  if (values.length < 2) { Logger.log('STOP: "' + P1A2_TAB_ + '" has no data rows.'); return; }

  var head = values[0].map(function (h) { return String(h).trim(); });
  var low = head.map(function (h) { return h.toLowerCase(); });

  Logger.log('=== PHASE 1a PASS TWO v2 — raw venues tab, read-only ===');
  Logger.log('Headers (' + head.length + '): ' + head.join(' | '));

  function findCol(cands) {
    for (var i = 0; i < cands.length; i++) {
      var j = low.indexOf(cands[i]);
      if (j >= 0) return j;
    }
    return -1;
  }

  var cName    = findCol(['name', 'venue_name', 'venue']);
  var cCity    = findCol(['city_slug', 'city', 'city_display']);
  var cCountry = findCol(['country']);
  var cStatus  = findCol(['status']);
  var cEnrich  = findCol(['needs_enrichment', 'enrichment', 'geo_status']);
  var cAwards  = findCol(['awards_json', 'awards']);

  Logger.log('Columns used — name: ' + (cName >= 0 ? head[cName] : 'NOT FOUND') +
             ' | city: ' + (cCity >= 0 ? head[cCity] : 'NOT FOUND') +
             ' | country: ' + (cCountry >= 0 ? head[cCountry] : 'NOT FOUND') +
             ' | status: ' + (cStatus >= 0 ? head[cStatus] : 'NOT FOUND') +
             ' | enrichment: ' + (cEnrich >= 0 ? head[cEnrich] : 'NOT FOUND') +
             ' | awards: ' + (cAwards >= 0 ? head[cAwards] : 'NOT FOUND'));

  if (cAwards < 0) {
    Logger.log('');
    Logger.log('WARNING: no awards_json column found. The absent-source scan below');
    Logger.log('falls back to scanning the WHOLE ROW, which is a known false-positive');
    Logger.log('trap (an earlier audit did this for "michelin" and returned 111 false');
    Logger.log('hits). Treat any non-zero result below as unverified until the real');
    Logger.log('column name is confirmed.');
  }

  var total = 0, blankRows = 0;
  var missName = 0, missCity = 0, missCountry = 0;
  var statusCount = {}, cityCount = {}, dupKey = {}, enrichDist = {};
  var srcHits = {};
  P1A2_MISSING_SOURCES_.forEach(function (s) { srcHits[s] = 0; });

  for (var r = 1; r < values.length; r++) {
    var row = values[r];
    var joined = row.join('\u0001');
    if (joined.replace(/\u0001/g, '').trim() === '') { blankRows++; continue; }
    total++;

    // --- absent-source scan: awards_json only, per the documented dead end ---
    var haystack = (cAwards >= 0 ? String(row[cAwards] || '') : joined).toLowerCase();
    P1A2_MISSING_SOURCES_.forEach(function (s) {
      if (haystack.indexOf(s) >= 0) srcHits[s]++;
    });

    if (cName >= 0 && String(row[cName]).trim() === '') missName++;
    if (cCity >= 0 && String(row[cCity]).trim() === '') missCity++;
    if (cCountry >= 0 && String(row[cCountry]).trim() === '') missCountry++;

    // --- enrichment: report the distribution, do not guess the semantics ---
    if (cEnrich >= 0) {
      var ev = String(row[cEnrich]).trim();
      var key = ev === '' ? '(blank)' : ev;
      enrichDist[key] = (enrichDist[key] || 0) + 1;
    }

    var st = cStatus >= 0 ? String(row[cStatus]).trim().toLowerCase() : '(no status col)';
    statusCount[st] = (statusCount[st] || 0) + 1;

    if (cCity >= 0) {
      var cs = p1a2Slug_(row[cCity]);
      cityCount[cs] = (cityCount[cs] || 0) + 1;
      if (cName >= 0) {
        var k = p1a2Name_(row[cName]) + '@' + cs;
        dupKey[k] = (dupKey[k] || 0) + 1;
      }
    }
  }

  var dupGroups = 0, dupRows = 0;
  for (var k2 in dupKey) if (dupKey[k2] > 1) { dupGroups++; dupRows += dupKey[k2]; }

  Logger.log('');
  Logger.log('Rows: ' + total + '  (published expectation: ' + P1A2_EXPECT_TOTAL_ +
             ')  blank rows inside range: ' + blankRows);
  Logger.log('Status counts: ' + JSON.stringify(statusCount) +
             '  (published: ' + JSON.stringify(P1A2_EXPECT_STATUS_) + ')');
  Logger.log('Blank required fields — name: ' + missName + '  city: ' + missCity +
             '  country: ' + missCountry);
  Logger.log('Duplicate normalised name+city on RAW tab: ' + dupGroups + ' groups / ' +
             dupRows + ' rows  (published pass found 15 / 30)');

  Logger.log('');
  if (cEnrich >= 0) {
    Logger.log('Enrichment column "' + head[cEnrich] + '" value distribution:');
    var ekeys = Object.keys(enrichDist).sort(function (a, b) { return enrichDist[b] - enrichDist[a]; });
    ekeys.slice(0, 12).forEach(function (k) { Logger.log('  ' + enrichDist[k] + '  ' + k); });
    if (ekeys.length > 12) Logger.log('  ... plus ' + (ekeys.length - 12) + ' more distinct values');
    Logger.log('  (expect roughly 59 rows in whatever value means "needs enrichment")');
  } else {
    Logger.log('Enrichment column not found — tell Claude the column name.');
  }

  Logger.log('');
  Logger.log('Absent-source scan — searched ' +
             (cAwards >= 0 ? 'the "' + head[cAwards] + '" column only' : 'THE WHOLE ROW (unverified, see warning above)'));
  Logger.log('  0 = never ingested;  >0 = present in source but lost at publish');
  P1A2_MISSING_SOURCES_.forEach(function (s) { Logger.log('  ' + s + ': ' + srcHits[s]); });

  Logger.log('');
  Logger.log('Top-30 city check (raw vs published active). Small deltas can be city');
  Logger.log('aliases; large deltas are the signal:');
  var flagged = 0;
  for (var city in P1A2_EXPECT_CITY_) {
    var got = cityCount[city] || 0;
    var exp = P1A2_EXPECT_CITY_[city];
    var d = got - exp;
    if (Math.abs(d) > Math.max(3, Math.round(exp * 0.05))) {
      Logger.log('  INVESTIGATE ' + city + ': raw ' + got + ' vs published ' + exp +
                 ' (delta ' + d + ')');
      flagged++;
    }
  }
  if (!flagged) Logger.log('  all 30 within tolerance');

  Logger.log('');
  Logger.log('Done. Nothing was written. Paste this log back to Claude.');
}
