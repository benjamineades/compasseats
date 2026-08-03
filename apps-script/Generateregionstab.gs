/**
 * generateRegionsTab.gs
 *
 * Reads the "city_regions" tab (City | Country | Region) and the live
 * "cities" tab, then writes a "regions" tab that sync-sheet.ts can read
 * to produce data/regions.json.
 *
 * Run order: after reshapeCompassEats + generateCitiesTab, before preflightPublish.
 *
 * The "city_regions" tab has three columns:
 *   A: City       — display name matching the cities tab
 *   B: Country    — country string (for disambiguation)
 *   C: Region     — region display name, e.g. "Tuscany"
 *
 * The output "regions" tab has one row per region:
 *   slug | display | country | center_lat | center_lng | venue_count | city_slugs_json
 *
 * city_slugs_json is a JSON array of {slug, display, country, country_code,
 * venue_count, lat, lng, venues} objects — one entry per city in that region.
 * sync-sheet.ts reads this column and deserialises it into the Region type.
 *
 * ADDED July 1, 2026: each city object now also carries a `venues` array
 * (slug, name, type) — the actual restaurants/bars in that city, sorted
 * alphabetically. This powers the region-page "expand a city to see its
 * venues" feature. Pulled from the live "venues" tab, active status only.
 * Requires a matching update to RegionCitySchema in src/lib/schema.ts (see
 * handoff notes) or the website's build step will silently discard this
 * field — zod strips unrecognized object keys by default.
 *
 * FIXED August 2, 2026: the summary used to be shown with
 * SpreadsheetApp.getUi().alert(), which only works when the script is run
 * from a menu inside the open spreadsheet. Run from the Apps Script editor
 * it throws "Cannot call SpreadsheetApp.getUi() from this context" AFTER all
 * the real work has already finished — so the run was marked Failed even
 * though the regions tab wrote correctly. The summary now goes to
 * Logger.log() only, which works in every context.
 */

var CITY_REGIONS_TAB   = 'city_regions';   // source: your city→region mapping
var CITIES_TAB_GEN     = 'cities';         // written by generateCitiesTab
var VENUES_TAB_GEN     = 'venues';         // written by reshapeCompassEats
var REGIONS_OUTPUT_TAB = 'regions';        // written by this script

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

function generateRegionsTab() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  // 1. Load the cities tab (slug, display, country, country_code, lat, lng, venue_count)
  var citiesSheet = ss.getSheetByName(CITIES_TAB_GEN);
  if (!citiesSheet) throw new Error('Tab "' + CITIES_TAB_GEN + '" not found. Run generateCitiesTab first.');

  var citiesVals = citiesSheet.getDataRange().getValues();
  var CH = {};
  citiesVals[0].forEach(function (h, i) { CH[String(h).trim().toLowerCase()] = i; });

  // Build lookup: display_name (lowercased) -> city object
  var byDisplay = {};
  for (var r = 1; r < citiesVals.length; r++) {
    var row = citiesVals[r];
    var disp = String(row[CH['display']] || '').trim();
    if (!disp) continue;
    byDisplay[disp.toLowerCase()] = {
      slug:         String(row[CH['slug']]         || '').trim().toLowerCase(),
      display:      disp,
      country:      String(row[CH['country']]      || '').trim(),
      country_code: String(row[CH['country_code']] || '').trim().toUpperCase(),
      venue_count:  Number(row[CH['venue_count']]  || 0),
      lat:          parseFloat(row[CH['lat']])  || 0,
      lng:          parseFloat(row[CH['lng']])  || 0,
    };
  }

  // 1b. Load the venues tab and build city_slug -> [{slug, name, type}, ...]
  // Active venues only, alphabetical by name.
  var venuesByCitySlug = buildVenuesByCitySlug_(ss);

  // 2. Load the city_regions tab
  var crSheet = ss.getSheetByName(CITY_REGIONS_TAB);
  if (!crSheet) throw new Error('Tab "' + CITY_REGIONS_TAB + '" not found. Create it from Cities_Regions_FINAL.csv.');

  var crVals = crSheet.getDataRange().getValues();
  // Detect header row
  var dataStart = 0;
  if (String(crVals[0][0]).trim().toLowerCase() === 'city') dataStart = 1;

  // Accumulate: regionName -> [cityObject, ...]
  var regionMembers = {}; // region display name -> array of city objects
  var unmatched = [];

  for (var i = dataStart; i < crVals.length; i++) {
    var crow = crVals[i];
    var cityDisp   = String(crow[0] || '').trim();
    var regionDisp = String(crow[2] || '').trim();
    if (!cityDisp || !regionDisp) continue;

    var cityObj = byDisplay[cityDisp.toLowerCase()];
    if (!cityObj) {
      unmatched.push(cityDisp + ' (' + regionDisp + ')');
      continue;
    }
    // Attach this city's venue list. Clone the base object first so the same
    // city appearing in two regions (rare, but possible) doesn't share array
    // references across regions.
    var cityObjWithVenues = {
      slug: cityObj.slug,
      display: cityObj.display,
      country: cityObj.country,
      country_code: cityObj.country_code,
      venue_count: cityObj.venue_count,
      lat: cityObj.lat,
      lng: cityObj.lng,
      venues: venuesByCitySlug[cityObj.slug] || [],
    };

    if (!regionMembers[regionDisp]) regionMembers[regionDisp] = [];
    regionMembers[regionDisp].push(cityObjWithVenues);
  }

  // 3. Build region rows
  var regionRows = [];

  for (var regionName in regionMembers) {
    var members = regionMembers[regionName];
    var slug = slugifyRegion_(regionName);

    // Sort cities by venue_count desc
    members.sort(function (a, b) { return b.venue_count - a.venue_count; });

    // Centroid
    var latSum = 0, lngSum = 0;
    members.forEach(function (c) { latSum += c.lat; lngSum += c.lng; });
    var centerLat = Math.round((latSum / members.length) * 1e6) / 1e6;
    var centerLng = Math.round((lngSum / members.length) * 1e6) / 1e6;

    // Total venue count
    var venueCount = members.reduce(function (s, c) { return s + c.venue_count; }, 0);

    // Primary country (most frequent)
    var cCounts = {};
    members.forEach(function (c) { cCounts[c.country] = (cCounts[c.country] || 0) + 1; });
    var primaryCountry = Object.keys(cCounts).sort(function (a, b) { return cCounts[b] - cCounts[a]; })[0] || '';

    regionRows.push([
      slug,
      regionName,
      primaryCountry,
      centerLat,
      centerLng,
      venueCount,
      members.length,
      JSON.stringify(members),   // city_slugs_json (now includes .venues per city)
    ]);
  }

  // Sort by venue count desc
  regionRows.sort(function (a, b) { return b[5] - a[5]; });

  // 4. Write the regions tab
  var HEADERS = [
    'slug', 'display', 'country', 'center_lat', 'center_lng',
    'venue_count', 'city_count', 'cities_json'
  ];
  writeTabGen_(ss, REGIONS_OUTPUT_TAB, HEADERS, regionRows);

  var totalVenuesEmbedded = 0;
  regionRows.forEach(function (rr) {
    JSON.parse(rr[7]).forEach(function (c) { totalVenuesEmbedded += (c.venues || []).length; });
  });

  var msg =
    'generateRegionsTab done.\n' +
    'Regions written: ' + regionRows.length + '\n' +
    'Cities matched:  ' + (Object.keys(byDisplay).length - unmatched.length) + '\n' +
    'Venue entries embedded across all regions: ' + totalVenuesEmbedded + '\n' +
    (unmatched.length ? 'Unmatched cities (' + unmatched.length + '):\n  ' + unmatched.slice(0, 20).join('\n  ') : 'All cities matched OK.');

  Logger.log(msg);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Reads the "venues" tab and groups active venues by city_slug into a slim
 * shape: [{slug, name, type}, ...], sorted alphabetically by name.
 */
function buildVenuesByCitySlug_(ss) {
  var sheet = ss.getSheetByName(VENUES_TAB_GEN);
  if (!sheet) throw new Error('Tab "' + VENUES_TAB_GEN + '" not found. Run reshapeCompassEats first.');

  var vals = sheet.getDataRange().getValues();
  var VH = {};
  vals[0].forEach(function (h, i) { VH[String(h).trim().toLowerCase()] = i; });

  var required = ['slug', 'name', 'city_slug', 'type', 'status'];
  for (var k = 0; k < required.length; k++) {
    if (!(required[k] in VH)) {
      throw new Error('venues tab is missing expected column: ' + required[k]);
    }
  }

  var byCity = {};
  for (var r = 1; r < vals.length; r++) {
    var row = vals[r];
    var status = String(row[VH['status']] || 'active').trim().toLowerCase();
    if (status !== 'active') continue; // skip closed/unverified

    var citySlug = String(row[VH['city_slug']] || '').trim().toLowerCase();
    var vSlug    = String(row[VH['slug']] || '').trim().toLowerCase();
    var vName    = String(row[VH['name']] || '').trim();
    var vType    = String(row[VH['type']] || '').trim().toLowerCase();
    if (!citySlug || !vSlug || !vName) continue;

    if (!byCity[citySlug]) byCity[citySlug] = [];
    byCity[citySlug].push({ slug: vSlug, name: vName, type: vType });
  }

  // Sort each city's venue list alphabetically by name
  for (var cs in byCity) {
    byCity[cs].sort(function (a, b) { return a.name.localeCompare(b.name); });
  }

  return byCity;
}

/**
 * Turn a region display name into a URL-safe slug.
 * "Napa Valley" -> "napa-valley"
 * "Côte d'Azur" -> "cote-dazur"
 */
function slugifyRegion_(name) {
  var s = name.toLowerCase();
  // Strip accents
  s = s.replace(/[àáâãäå]/g, 'a')
       .replace(/[èéêë]/g, 'e')
       .replace(/[ìíîï]/g, 'i')
       .replace(/[òóôõö]/g, 'o')
       .replace(/[ùúûü]/g, 'u')
       .replace(/[ý]/g, 'y')
       .replace(/[ñ]/g, 'n')
       .replace(/[ç]/g, 'c')
       .replace(/[ø]/g, 'o')
       .replace(/[æ]/g, 'ae')
       .replace(/[ß]/g, 'ss')
       .replace(/[ð]/g, 'd')
       .replace(/[þ]/g, 'th');
  // Remove apostrophes
  s = s.replace(/[''']/g, '');
  // Non-alphanumeric -> space
  s = s.replace(/[^a-z0-9]+/g, ' ').trim();
  // Spaces -> hyphens
  s = s.replace(/\s+/g, '-');
  return s;
}

function writeTabGen_(ss, name, headers, rows) {
  var sheet = ss.getSheetByName(name);
  if (sheet) sheet.clear();
  else sheet = ss.insertSheet(name);
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
  if (rows.length) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
  sheet.setFrozenRows(1);
}
