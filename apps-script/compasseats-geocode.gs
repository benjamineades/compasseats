/**
 * compasseats-geocode.gs
 *
 * Geoapify-powered geocoder for CompassEats. Fills in lat/lng on any row
 * across `venues` and `needs_enrichment` that has a name + at least one
 * address-like field but no coordinates.
 *
 * Setup (one-time):
 *   1. Paste this file into the Sheet's Apps Script editor (Extensions → Apps Script)
 *   2. Save
 *   3. Run `setGeoapifyKey()` once from the editor — it'll prompt you for the key
 *      via a dialog inside the Sheet, then store it in Script Properties.
 *   4. Reload the Sheet. A new "CompassEats" menu appears with two items:
 *        • "Geocode missing venues (dry run)" — logs what it WOULD do, no writes
 *        • "Geocode missing venues (live)"    — does the writes
 *
 * Run from menu. Watch progress in View → Execution log.
 *
 * Notes:
 *   - Skips any row that already has lat AND lng populated
 *   - Skips rows with no name (blank rows)
 *   - Skips rows with no address AND no city (not enough to query)
 *   - Rate-limited to 4 requests/sec to stay under Geoapify's 5 rps free-tier limit
 *   - Writes results to the Sheet immediately after each call, so a crash or
 *     the 6-minute Apps Script timeout doesn't lose progress — just re-run.
 *   - Low-confidence results (<0.5) are logged at the end for manual review.
 */

// ----- config -----

const TABS_TO_PROCESS = ['needs_enrichment', 'venues'];
const RATE_LIMIT_MS = 250; // 4 rps
const LOW_CONFIDENCE_THRESHOLD = 0.5;

// Headers we read from. Lookups are case-insensitive and trimmed.
const COL = {
  name: 'name',
  address: 'address',
  city: 'city_display',
  country: 'country',
  lat: 'lat',
  lng: 'lng',
};

// ----- menu -----

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('CompassEats')
    .addItem('Geocode missing venues (dry run)', 'geocodeMissing_DryRun')
    .addItem('Geocode missing venues (live)', 'geocodeMissing_Live')
    .addSeparator()
    .addItem('Set Geoapify API key…', 'setGeoapifyKey')
    .addSeparator()
    .addItem('Fill hero photos (batch)', 'fillHeroPhotosBatch')
    .addItem('Reset hero progress', 'resetHeroProgress')
    .addToUi();
}

function geocodeMissing_DryRun() { runGeocoder_(true); }
function geocodeMissing_Live()   { runGeocoder_(false); }

// ----- API key -----

function setGeoapifyKey() {
  const ui = SpreadsheetApp.getUi();
  const resp = ui.prompt(
    'Geoapify API key',
    'Paste your Geoapify server key (stored in Script Properties, not in the script body):',
    ui.ButtonSet.OK_CANCEL
  );
  if (resp.getSelectedButton() !== ui.Button.OK) return;
  const key = resp.getResponseText().trim();
  if (!key) {
    ui.alert('Empty key — nothing saved.');
    return;
  }
  PropertiesService.getScriptProperties().setProperty('GEOAPIFY_KEY', key);
  ui.alert('✓ Geoapify key saved.');
}

function getGeoapifyKey_() {
  const key = PropertiesService.getScriptProperties().getProperty('GEOAPIFY_KEY');
  if (!key) {
    throw new Error('No Geoapify key set. Run "Set Geoapify API key…" from the CompassEats menu first.');
  }
  return key;
}

// ----- main -----

function runGeocoder_(isDryRun) {
  const key = getGeoapifyKey_();
  const ss = SpreadsheetApp.getActiveSpreadsheet();

  const startedAt = new Date();
  Logger.log('🧭 CompassEats geocoding pass — %s', isDryRun ? 'DRY RUN' : 'LIVE');
  Logger.log('Started: %s', startedAt.toISOString());

  let totalScanned = 0;
  let totalToGeocode = 0;
  let totalSuccess = 0;
  let totalFailed = 0;
  const lowConfidenceFlags = [];

  for (const tabName of TABS_TO_PROCESS) {
    const sheet = ss.getSheetByName(tabName);
    if (!sheet) {
      Logger.log('⚠ Tab "%s" not found — skipping.', tabName);
      continue;
    }

    Logger.log('\n── Tab: %s ──', tabName);

    const lastRow = sheet.getLastRow();
    const lastCol = sheet.getLastColumn();
    if (lastRow < 2) {
      Logger.log('  (empty — skipping)');
      continue;
    }

    const headerRow = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
    const idx = findColumns_(headerRow, tabName);
    if (!idx) continue; // findColumns_ logs the error

    const data = sheet.getRange(2, 1, lastRow - 1, lastCol).getValues();
    totalScanned += data.length;

    // Identify rows that need geocoding.
    const needGeo = [];
    for (let i = 0; i < data.length; i++) {
      const row = data[i];
      const name = String(row[idx.name] || '').trim();
      const address = String(row[idx.address] || '').trim();
      const city = String(row[idx.city] || '').trim();
      const country = String(row[idx.country] || '').trim();
      const lat = String(row[idx.lat] || '').trim();
      const lng = String(row[idx.lng] || '').trim();

      if (!name) continue;                         // blank row
      if (!address && !city) continue;             // not enough to query
      if (lat && lng) continue;                    // already done

      needGeo.push({
        sheetRow: i + 2, // 1-indexed; +1 for header
        name, address, city, country,
      });
    }

    totalToGeocode += needGeo.length;
    Logger.log('  %s rows total, %s need geocoding', data.length, needGeo.length);

    if (needGeo.length === 0) continue;

    // Process each row, rate-limited.
    for (let i = 0; i < needGeo.length; i++) {
      const v = needGeo[i];
      const query = [v.name, v.address, v.city, v.country].filter(Boolean).join(', ');

      let result;
      try {
        result = geocodeOne_(query, key);
      } catch (err) {
        Logger.log('  [%s/%s] %s (%s) — ERROR: %s', i + 1, needGeo.length, v.name, v.city, err.message);
        totalFailed++;
        Utilities.sleep(RATE_LIMIT_MS);
        continue;
      }

      if (!result) {
        Logger.log('  [%s/%s] %s (%s) — no result', i + 1, needGeo.length, v.name, v.city);
        totalFailed++;
        Utilities.sleep(RATE_LIMIT_MS);
        continue;
      }

      Logger.log(
        '  [%s/%s] %s (%s) → %s, %s (conf %s)',
        i + 1, needGeo.length, v.name, v.city,
        result.lat.toFixed(5), result.lon.toFixed(5), result.confidence.toFixed(2)
      );
      totalSuccess++;

      if (result.confidence < LOW_CONFIDENCE_THRESHOLD) {
        lowConfidenceFlags.push({
          tab: tabName, row: v.sheetRow, name: v.name, city: v.city,
          confidence: result.confidence, formatted: result.formatted,
        });
      }

      if (!isDryRun) {
        // lat and lng must be adjacent in your schema (lat then lng).
        // Verify before writing — if they're not, fall back to two writes.
        if (idx.lng === idx.lat + 1) {
          sheet.getRange(v.sheetRow, idx.lat + 1, 1, 2).setValues([[result.lat, result.lon]]);
        } else {
          sheet.getRange(v.sheetRow, idx.lat + 1).setValue(result.lat);
          sheet.getRange(v.sheetRow, idx.lng + 1).setValue(result.lon);
        }
      }

      Utilities.sleep(RATE_LIMIT_MS);
    }
  }

  // Summary.
  const elapsed = ((new Date() - startedAt) / 1000).toFixed(1);
  Logger.log('\n📊 Summary');
  Logger.log('  Rows scanned: %s', totalScanned);
  Logger.log('  Rows that needed geocoding: %s', totalToGeocode);
  Logger.log('  Geocoded successfully: %s', totalSuccess);
  Logger.log('  Failed: %s', totalFailed);
  Logger.log('  Elapsed: %ss', elapsed);
  Logger.log('  Mode: %s', isDryRun ? 'DRY RUN (no writes)' : 'LIVE');

  if (lowConfidenceFlags.length > 0) {
    Logger.log('\n⚠ %s low-confidence results (<%s) — eyeball these:',
      lowConfidenceFlags.length, LOW_CONFIDENCE_THRESHOLD);
    for (const f of lowConfidenceFlags) {
      Logger.log('  %s row %s: %s (%s) → "%s" (conf %s)',
        f.tab, f.row, f.name, f.city, f.formatted, f.confidence.toFixed(2));
    }
  }

  // Show a toast in the Sheet so user knows it's done without opening logs.
  const msg = isDryRun
    ? `Dry run: ${totalSuccess} would be geocoded, ${totalFailed} failed.`
    : `Geocoded ${totalSuccess} rows, ${totalFailed} failed. ${lowConfidenceFlags.length} flagged.`;
  SpreadsheetApp.getActiveSpreadsheet().toast(msg, 'CompassEats geocoder', 10);
}

// ----- column lookup -----

function findColumns_(headerRow, tabName) {
  const normalized = headerRow.map(h => String(h || '').trim().toLowerCase());
  const findIdx = (name) => {
    const i = normalized.indexOf(name.toLowerCase());
    if (i === -1) {
      Logger.log('  ⚠ Tab "%s" is missing required column "%s" — skipping this tab.', tabName, name);
      return -1;
    }
    return i;
  };

  const idx = {
    name: findIdx(COL.name),
    address: findIdx(COL.address),
    city: findIdx(COL.city),
    country: findIdx(COL.country),
    lat: findIdx(COL.lat),
    lng: findIdx(COL.lng),
  };

  // All six must exist.
  if (Object.values(idx).some(v => v === -1)) return null;
  return idx;
}

// ----- Geoapify call -----

function geocodeOne_(query, apiKey) {
  const url =
    'https://api.geoapify.com/v1/geocode/search' +
    '?text=' + encodeURIComponent(query) +
    '&format=geojson' +
    '&limit=1' +
    '&apiKey=' + encodeURIComponent(apiKey);

  const res = UrlFetchApp.fetch(url, {
    muteHttpExceptions: true,
    method: 'get',
  });

  const code = res.getResponseCode();
  if (code !== 200) {
    throw new Error('Geoapify HTTP ' + code + ': ' + res.getContentText().slice(0, 200));
  }

  const data = JSON.parse(res.getContentText());
  const feature = data && data.features && data.features[0];
  if (!feature) return null;

  const props = feature.properties || {};
  const lat = props.lat;
  const lon = props.lon;
  if (typeof lat !== 'number' || typeof lon !== 'number') return null;

  const confidence =
    (props.rank && typeof props.rank.confidence === 'number' && props.rank.confidence) ||
    (typeof props.confidence === 'number' && props.confidence) ||
    0;

  return {
    lat,
    lon,
    confidence,
    formatted: props.formatted || '',
  };
}
