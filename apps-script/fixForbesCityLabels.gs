/**
 * CompassEats — Forbes City-Label Fix (Google Apps Script)
 * =========================================================
 * fixForbesCityLabels.gs — July 8, 2026
 *
 * WHAT THIS FIXES
 *   The Forbes Travel Guide ingest used "City, State/Province" labels
 *   ("New York City, New York", "Las Vegas, Nevada", ...). Reshape slugifies
 *   those into NEW city slugs (new-york-city-new-york, las-vegas-nevada),
 *   creating duplicate venue rows and fragmented city pages alongside the
 *   real ones (new-york, las-vegas). Deleting the duplicate venue rows is
 *   futile — reshape rebuilds them from this source tab every run. The
 *   durable fix (per the standing rule in Reshape.gs: labels containing
 *   region/country names are fixed at the award-row level, NOT via
 *   CITY_ALIASES_) is to rewrite the city cells here in "Restaurant Awards".
 *
 * WHAT IT DOES
 *   - Scans the "Restaurant Awards" tab.
 *   - ONLY touches rows where source_slug === 'forbes-travel-guide'.
 *   - Rewrites the city cell ONLY on an exact, full-string match against the
 *     verified map below (42 labels, 676 rows expected).
 *   - Logs every change (row #, venue name, old label, new label) to a
 *     "city_label_fix_log" tab so nothing is silent.
 *   - Touches NOTHING else: no deletes, no other columns, no other sources.
 *
 * WHAT IT DELIBERATELY SKIPS (left as-is, logged in the worklist doc):
 *   - Destination-region labels (e.g. "Monterey, Carmel and Big Sur,
 *     California", "Raleigh-Durham, North Carolina") — need per-venue
 *     judgment, follow-up item.
 *   - "City, State" labels with NO existing canonical city page (e.g.
 *     "Sedona, Arizona") — they render fine, just verbose; follow-up item.
 *   - Labels that already resolve via existing aliases (e.g.
 *     "Washington, D.C.").
 *
 * EVERY mapping below was verified against the live data on July 8, 2026:
 * either the same Google place_id exists under both labels (collision-proof:
 * definitionally the same city), or the canonical city's venue addresses
 * contain the state AND the cities-tab country matches. Same-name traps were
 * checked (canonical "toledo" is Toledo, SPAIN — so "Toledo, Ohio" is
 * deliberately NOT in this map; canonical "portland" was verified as Oregon).
 *
 * HOW TO RUN
 *   1. Extensions → Apps Script → + → Script → name it fixForbesCityLabels
 *      → paste this whole file → Save.
 *   2. Run → fixForbesCityLabels. Authorize if prompted.
 *   3. Read the alert; review the "city_label_fix_log" tab.
 *   4. THEN re-run: reshapeCompassEats → mergeDuplicateVenues (the fix only
 *      takes effect through reshape).
 */

var FCL_SOURCE_TAB = 'Restaurant Awards';
var FCL_LOG_TAB = 'city_label_fix_log';
var FCL_ONLY_SOURCE = 'forbes-travel-guide';

// Verified label → canonical label (42 entries, July 8 2026)
var FCL_MAP = {
  'Amelia Island, Florida': 'Amelia Island',
  'Aspen, Colorado': 'Aspen',
  'Atlanta, Georgia': 'Atlanta',
  'Austin, Texas': 'Austin',
  'Baltimore, Maryland': 'Baltimore',
  'Boston, Massachusetts': 'Boston',
  'Boulder, Colorado': 'Boulder',
  'Charleston, South Carolina': 'Charleston',
  'Chicago, Illinois': 'Chicago',
  'Dallas, Texas': 'Dallas',
  'Houston, Texas': 'Houston',
  'Las Vegas, Nevada': 'Las Vegas',
  'Los Angeles, California': 'Los Angeles',
  'Maui, Hawaii': 'Maui',
  'Memphis, Tennessee': 'Memphis',
  'Miami, Florida': 'Miami',
  'Montreal, Quebec': 'Montréal',
  'Mystic, Connecticut': 'Mystic',
  'Nantucket, Massachusetts': 'Nantucket',
  'Napa, California': 'Napa',
  'Nashville, Tennessee': 'Nashville',
  'New Orleans, Louisiana': 'New Orleans',
  'New York City, New York': 'New York',
  'Newport, Rhode Island': 'Newport',
  'Orlando, Florida': 'Orlando',
  'Palm Beach, Florida': 'Palm Beach',
  'Palm Springs, California': 'Palm Springs',
  'Park City, Utah': 'Park City',
  'Philadelphia, Pennsylvania': 'Philadelphia',
  'Phoenix, Arizona': 'Phoenix',
  'Portland, Oregon': 'Portland',
  'San Diego, California': 'San Diego',
  'San Francisco, California': 'San Francisco',
  'San Jose, California': 'San José',
  'Santa Barbara, California': 'Santa Barbara',
  'Santa Fe, New Mexico': 'Santa Fe',
  'Scottsdale, Arizona': 'Scottsdale',
  'Sonoma, California': 'Sonoma',
  'Tampa, Florida': 'Tampa',
  'Toronto, Ontario': 'Toronto',
  'Vancouver, Alberta': 'Vancouver',   // Forbes data error — no such place; venue is Vancouver BC
  'Vancouver, British Columbia': 'Vancouver'
};

function fixForbesCityLabels() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(FCL_SOURCE_TAB);
  if (!sheet) throw new Error('No "' + FCL_SOURCE_TAB + '" tab found.');

  var vals = sheet.getDataRange().getValues();
  var headers = vals[0];
  var col = {};
  for (var h = 0; h < headers.length; h++) col[headers[h]] = h;
  ['source_slug', 'name', 'city'].forEach(function (c) {
    if (!(c in col)) throw new Error(FCL_SOURCE_TAB + ' is missing column: ' + c);
  });

  var logRows = [];
  var perLabel = {};
  var changed = 0, forbesRows = 0;

  for (var i = 1; i < vals.length; i++) {
    var src = String(vals[i][col.source_slug] || '').trim();
    if (src !== FCL_ONLY_SOURCE) continue;
    forbesRows++;
    var city = String(vals[i][col.city] || '').trim();
    if (!FCL_MAP.hasOwnProperty(city)) continue;
    var target = FCL_MAP[city];
    logRows.push([i + 1, String(vals[i][col.name] || ''), city, target]);
    perLabel[city] = (perLabel[city] || 0) + 1;
    // write just the one cell (row i+1, city column) — surgical, no bulk rewrite
    sheet.getRange(i + 1, col.city + 1).setValue(target);
    changed++;
  }

  // Write the log tab
  var log = ss.getSheetByName(FCL_LOG_TAB);
  if (log) log.clear(); else log = ss.insertSheet(FCL_LOG_TAB);
  var logHeaders = ['row #', 'venue name', 'old city label', 'new city label'];
  log.getRange(1, 1, 1, logHeaders.length).setValues([logHeaders]).setFontWeight('bold');
  if (logRows.length) {
    log.getRange(2, 1, logRows.length, logHeaders.length).setValues(logRows);
  }
  log.setFrozenRows(1);

  var perLabelLines = [];
  Object.keys(perLabel).sort().forEach(function (k) {
    perLabelLines.push('  ' + k + ' → ' + FCL_MAP[k] + ': ' + perLabel[k]);
  });

  var msg = 'fixForbesCityLabels complete.\n' +
    'Forbes rows scanned: ' + forbesRows + '\n' +
    'city labels rewritten: ' + changed + ' (expected 676)\n' +
    'distinct labels fixed: ' + Object.keys(perLabel).length + ' (expected 42)\n\n' +
    'Full row-by-row record in the "' + FCL_LOG_TAB + '" tab.\n\n' +
    'NEXT: run reshapeCompassEats, then mergeDuplicateVenues.';
  Logger.log(msg + '\n\nPer label:\n' + perLabelLines.join('\n'));
  SpreadsheetApp.getUi().alert(msg);
}
