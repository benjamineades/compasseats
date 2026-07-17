/**
 * CompassEats-ApplyMasterFixes.gs
 *
 * Applies the consolidated collision-cleanup worklist (identity-corruption fixes,
 * REMOVE-verdict resolutions, and the 29-row + 150-row REPIN batches) to the
 * live `venues` tab.
 *
 * HOW TO USE:
 * 1. Import CompassEats-Master-Fix-Worklist.csv into a NEW tab in this sheet
 *    named exactly "Master-Fix-Worklist" (File > Import > Insert new sheet).
 * 2. Run `previewMasterFixes()` first. This NEVER touches the venues tab --
 *    it only writes a report to a new "DryRun-Preview-<timestamp>" tab so you
 *    can review every change before anything happens for real.
 * 3. Review the preview tab. Check the "match_status" column especially --
 *    anything other than "OK" means that row was not found/applied.
 * 4. Only when you're satisfied: set CONFIRM_LIVE_RUN to true below, then run
 *    `applyMasterFixesLive()`. This is a separate function on purpose --
 *    there is no single switch that both previews and applies.
 *
 * MATCHING: rows are matched against `venues` by (name, city_display), exactly
 * as those fields appear in the CSV's current_name / current_city columns.
 * This mirrors the name+city pairs already verified against Google Places
 * and raw award-source data this session -- nothing here re-derives identity,
 * it just applies what's already been decided.
 *
 * ACTIONS supported (see the `action` column):
 *   REMOVE            - delete the row entirely
 *   RENAME_ONLY        - change `name` only
 *   REPIN               - change place_id/lat/lng only (id, address left as-is
 *                          unless you extend this script -- see NOTE below)
 *   RENAME_REPIN        - change `name` AND place_id/lat/lng
 *   RENAME_CITY_ONLY    - change city_display/city_slug only (pin untouched)
 *   RESLUG              - change `slug` (and optionally `name`) only
 *   RESTRUCTURE         - full identity change: slug, name, type, city_slug,
 *                          city_display, country, place_id, lat, lng
 *
 * NOTE: REPIN does not currently update the `id` (place_id) or `address`
 * columns beyond what's listed below -- extend the ACTION_HANDLERS map if
 * your venues tab schema needs `id` synced to new_place_id, or `address`
 * regenerated. Check your actual column headers before a live run.
 *
 * SAFETY:
 * - previewMasterFixes() is 100% read-only against `venues`.
 * - applyMasterFixesLive() refuses to run unless CONFIRM_LIVE_RUN === true.
 * - REMOVE rows are deleted bottom-up after all other edits, to avoid index
 *   shifting mid-run.
 */

// ============================== CONFIG ==============================
var VENUES_TAB_NAME = 'venues';
var WORKLIST_TAB_NAME = 'Master-Fix-Worklist';
var CONFIRM_LIVE_RUN = false; // set to true only when you are ready to apply for real

// ============================ ENTRY POINTS ============================

function previewMasterFixes() {
  var result = runMasterFixes_({ dryRun: true });
  writeReport_(result, 'DryRun-Preview');
  Logger.log('Dry run complete. Rows processed: %s. See the new "DryRun-Preview-..." tab.', result.length);
}

function applyMasterFixesLive() {
  if (CONFIRM_LIVE_RUN !== true) {
    throw new Error(
      'CONFIRM_LIVE_RUN is not set to true. This is a safety stop -- ' +
      'open the script, set CONFIRM_LIVE_RUN = true, and re-run applyMasterFixesLive() ' +
      'only after you have reviewed a DryRun-Preview tab.'
    );
  }
  var result = runMasterFixes_({ dryRun: false });
  writeReport_(result, 'LiveRun-Report');
  Logger.log('Live run complete. Rows processed: %s. See the new "LiveRun-Report-..." tab.', result.length);
}

// ============================ CORE LOGIC ============================

function runMasterFixes_(opts) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var venuesSheet = ss.getSheetByName(VENUES_TAB_NAME);
  var worklistSheet = ss.getSheetByName(WORKLIST_TAB_NAME);

  if (!venuesSheet) throw new Error('Could not find a tab named "' + VENUES_TAB_NAME + '"');
  if (!worklistSheet) {
    throw new Error(
      'Could not find a tab named "' + WORKLIST_TAB_NAME + '". ' +
      'Import CompassEats-Master-Fix-Worklist.csv as a new tab with this exact name first.'
    );
  }

  var venuesData = venuesSheet.getDataRange().getValues();
  var venuesHeader = venuesData[0];
  var col = headerIndexMap_(venuesHeader);

  var requiredCols = ['name', 'city_display', 'city_slug', 'slug', 'type', 'country', 'lat', 'lng'];
  requiredCols.forEach(function (c) {
    if (col[c] === undefined) {
      throw new Error('venues tab is missing an expected column: "' + c + '". Check your schema before proceeding.');
    }
  });

  var worklistData = worklistSheet.getDataRange().getValues();
  var wHeader = worklistData[0];
  var wCol = headerIndexMap_(wHeader);

  var results = [];
  var rowsToRemove = []; // 1-indexed sheet row numbers, collected for bottom-up deletion

  for (var i = 1; i < worklistData.length; i++) {
    var wRow = worklistData[i];
    var currentName = String(wRow[wCol['current_name']] || '').trim();
    var currentCity = String(wRow[wCol['current_city']] || '').trim();
    var action = String(wRow[wCol['action']] || '').trim().toUpperCase();

    if (!currentName || !action) continue; // skip blank rows

    var matchRowIndex = findVenueRow_(venuesData, col, currentName, currentCity);

    var record = {
      current_name: currentName,
      current_city: currentCity,
      action: action,
      match_status: 'NOT_FOUND',
      sheet_row: null,
      before: null,
      after: null,
      note: wRow[wCol['note']] || ''
    };

    if (matchRowIndex === -1) {
      results.push(record);
      continue;
    }

    record.match_status = 'OK';
    record.sheet_row = matchRowIndex + 1; // convert to 1-indexed for human-readable report
    var venueRow = venuesData[matchRowIndex];
    record.before = snapshotRow_(venueRow, col);

    var newValues = {
      name: wRow[wCol['new_name']],
      slug: wRow[wCol['new_slug']],
      type: wRow[wCol['new_type']],
      city_slug: wRow[wCol['new_city_slug']],
      city_display: wRow[wCol['new_city_display']],
      country: wRow[wCol['new_country']],
      place_id: wRow[wCol['new_place_id']],
      lat: wRow[wCol['new_lat']],
      lng: wRow[wCol['new_lng']]
    };

    var after = applyAction_(action, venueRow, col, newValues);
    record.after = after ? snapshotRow_(after, col) : 'REMOVE (row deleted)';

    if (!opts.dryRun) {
      if (action === 'REMOVE') {
        rowsToRemove.push(matchRowIndex + 1); // 1-indexed sheet row
      } else {
        writeRowBack_(venuesSheet, matchRowIndex + 1, venueRow, col);
      }
    }

    results.push(record);
  }

  if (!opts.dryRun && rowsToRemove.length > 0) {
    rowsToRemove.sort(function (a, b) { return b - a; }); // descending, so earlier deletes don't shift later ones
    rowsToRemove.forEach(function (r) {
      venuesSheet.deleteRow(r);
    });
  }

  return results;
}

function applyAction_(action, venueRow, col, nv) {
  switch (action) {
    case 'REMOVE':
      return null; // caller handles deletion separately

    case 'RENAME_ONLY':
      if (nv.name) venueRow[col['name']] = nv.name;
      return venueRow;

    case 'REPIN':
      if (nv.place_id && col['id'] !== undefined) venueRow[col['id']] = nv.place_id;
      if (nv.lat) venueRow[col['lat']] = nv.lat;
      if (nv.lng) venueRow[col['lng']] = nv.lng;
      return venueRow;

    case 'RENAME_REPIN':
      if (nv.name) venueRow[col['name']] = nv.name;
      if (nv.place_id && col['id'] !== undefined) venueRow[col['id']] = nv.place_id;
      if (nv.lat) venueRow[col['lat']] = nv.lat;
      if (nv.lng) venueRow[col['lng']] = nv.lng;
      return venueRow;

    case 'RENAME_CITY_ONLY':
      if (nv.city_display) venueRow[col['city_display']] = nv.city_display;
      if (nv.city_slug) venueRow[col['city_slug']] = nv.city_slug;
      if (nv.name) venueRow[col['name']] = nv.name; // some city-only rows also carry a minor name cleanup
      return venueRow;

    case 'RESLUG':
      if (nv.slug) venueRow[col['slug']] = nv.slug;
      if (nv.name) venueRow[col['name']] = nv.name;
      return venueRow;

    case 'RESTRUCTURE':
      if (nv.slug) venueRow[col['slug']] = nv.slug;
      if (nv.name) venueRow[col['name']] = nv.name;
      if (nv.type) venueRow[col['type']] = nv.type;
      if (nv.city_slug) venueRow[col['city_slug']] = nv.city_slug;
      if (nv.city_display) venueRow[col['city_display']] = nv.city_display;
      if (nv.country) venueRow[col['country']] = nv.country;
      if (nv.place_id && col['id'] !== undefined) venueRow[col['id']] = nv.place_id;
      if (nv.lat) venueRow[col['lat']] = nv.lat;
      if (nv.lng) venueRow[col['lng']] = nv.lng;
      return venueRow;

    default:
      throw new Error('Unknown action "' + action + '" -- add a handler in applyAction_ before running.');
  }
}

// ============================ HELPERS ============================

function headerIndexMap_(header) {
  var map = {};
  header.forEach(function (h, i) {
    if (h) map[String(h).trim()] = i;
  });
  return map;
}

function findVenueRow_(venuesData, col, name, city) {
  var normName = normalize_(name);
  var normCity = normalize_(city);
  for (var i = 1; i < venuesData.length; i++) {
    var row = venuesData[i];
    var rName = normalize_(row[col['name']]);
    var rCity = normalize_(row[col['city_display']]);
    if (rName === normName && rCity === normCity) return i;
  }
  return -1;
}

function normalize_(s) {
  return String(s || '').trim().toLowerCase();
}

function snapshotRow_(row, col) {
  return {
    name: row[col['name']],
    slug: row[col['slug']],
    type: row[col['type']],
    city_slug: row[col['city_slug']],
    city_display: row[col['city_display']],
    country: row[col['country']],
    id: col['id'] !== undefined ? row[col['id']] : undefined,
    lat: row[col['lat']],
    lng: row[col['lng']]
  };
}

function writeRowBack_(sheet, sheetRowNumber, rowValues, col) {
  // Write only the columns we might have touched, to minimize risk of clobbering
  // anything else in the row (e.g. awards_json, blurb fields).
  var colsToWrite = ['name', 'slug', 'type', 'city_slug', 'city_display', 'country', 'id', 'lat', 'lng'];
  colsToWrite.forEach(function (c) {
    if (col[c] !== undefined) {
      sheet.getRange(sheetRowNumber, col[c] + 1).setValue(rowValues[col[c]]);
    }
  });
}

function writeReport_(results, prefix) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var timestamp = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'yyyy-MM-dd-HHmm');
  var sheetName = (prefix + '-' + timestamp).substring(0, 31); // sheet name length limit
  var sheet = ss.insertSheet(sheetName);

  var headers = ['current_name', 'current_city', 'action', 'match_status', 'sheet_row', 'before', 'after', 'note'];
  sheet.appendRow(headers);

  results.forEach(function (r) {
    sheet.appendRow([
      r.current_name,
      r.current_city,
      r.action,
      r.match_status,
      r.sheet_row || '',
      r.before ? JSON.stringify(r.before) : '',
      r.after ? JSON.stringify(r.after) : '',
      r.note
    ]);
  });

  sheet.setFrozenRows(1);

  var notFoundCount = results.filter(function (r) { return r.match_status !== 'OK'; }).length;
  Logger.log('Report written to tab "%s". %s of %s rows NOT matched -- check those before trusting this run.',
    sheetName, notFoundCount, results.length);
}
