/**
 * CompassEats — Price Tier Backfill, Phase 1
 * Written July 20, 2026
 *
 * SCOPE: only venues that (a) have no price_tier value yet, AND (b) already
 * have a Google place ID on file (the `id` column in the venues tab). These
 * are the cheapest possible lookups — one "give me the price level" call per
 * venue, reusing an ID we already paid to find once. As of the last live
 * export this was 7,150 venues.
 *
 * NOT in scope: the ~829 venues missing price_tier that have no place ID at
 * all. Those need a full place search first (a different, pricier call) and
 * some portion may already be closed/unenrichable — check overlap with
 * closed_venues / needs_enrichment before spending anything on that group.
 * That's a separate, later task.
 *
 * BEFORE RUNNING ANYTHING:
 * 1. Set PLACES_API_KEY below — either point it at your existing Script
 *    Properties key name, or paste your key directly if you'd rather not
 *    use Script Properties for this one.
 * 2. Confirm price_tier survives a reshape run (see handoff doc). If you're
 *    not sure, run this AFTER your next reshape, not before.
 *
 * HOW TO USE:
 * Step 1 — run priceBackfillDryRun(). It does NOT touch the Sheet. It counts
 *   how many venues qualify, pulls 20 REAL Google lookups (this costs a few
 *   cents, unavoidable — it's the only way to show you real data before you
 *   commit), writes them to a new "price_backfill_preview" tab, and prints
 *   the full-run cost estimate to the execution log.
 * Step 2 — open price_backfill_preview and check the mapping looks right.
 * Step 3 — run priceBackfillLive() to actually write price_tier values.
 *   It processes PRICE_BATCH_SIZE rows per run (default 400) to stay under
 *   Apps Script's execution time limit. It's safe to just run it again and
 *   again — it automatically skips any row that already has a price_tier,
 *   so it always picks up where the last run left off. Keep running it
 *   until the log says "Processed this run: 0".
 */

var PRICE_SHEET_ID = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
var PLACES_API_KEY = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY'); // <-- confirm this property name matches your existing setup
var PRICE_BATCH_SIZE = 400;

// Google price_level (0-4) -> CompassEats price_tier (1-4).
// 0 = "Free" is left blank on purpose — essentially never applies to a
// restaurant or cocktail bar, so a Free result is flagged for a human look
// rather than guessed into a tier.
function mapGooglePriceToTier_(level) {
  if (level === 1 || level === 2 || level === 3 || level === 4) return level;
  return '';
}

function fetchGooglePriceLevel_(placeId) {
  var url = 'https://maps.googleapis.com/maps/api/place/details/json'
    + '?place_id=' + encodeURIComponent(placeId)
    + '&fields=price_level'
    + '&key=' + PLACES_API_KEY;

  try {
    var resp = UrlFetchApp.fetch(url, { muteHttpExceptions: true });
    var json = JSON.parse(resp.getContentText());

    if (json.status !== 'OK') {
      return { raw: json.status, mappedTier: '', note: 'Google API status: ' + json.status };
    }
    var level = json.result && json.result.price_level;
    if (level === undefined || level === null) {
      return { raw: '(none)', mappedTier: '', note: 'Google has no price data for this place' };
    }
    var mapped = mapGooglePriceToTier_(level);
    var note = (level === 0) ? 'Google returned "Free" — left blank for manual review' : '';
    return { raw: level, mappedTier: mapped, note: note };
  } catch (e) {
    return { raw: 'ERROR', mappedTier: '', note: e.message };
  }
}

function isClosed_(statusValue) {
  return typeof statusValue === 'string' && statusValue.toLowerCase().indexOf('closed') !== -1;
}

function getBackfillCandidates_(data, idx) {
  var candidates = [];
  for (var r = 1; r < data.length; r++) {
    var row = data[r];
    var priceTier = row[idx['price_tier']];
    var placeId = row[idx['id']];
    var status = idx['status'] !== undefined ? row[idx['status']] : '';
    if ((priceTier === '' || priceTier === null) && placeId && !isClosed_(status)) {
      candidates.push(r);
    }
  }
  return candidates;
}

/**
 * DRY RUN — no writes to the Sheet. Pulls a small real sample so you can
 * check the mapping before spending on the full set.
 */
function priceBackfillDryRun() {
  if (!PLACES_API_KEY) {
    Logger.log('ERROR: PLACES_API_KEY is empty. Set the Script Property or paste your key in directly, then re-run.');
    return;
  }

  var ss = SpreadsheetApp.openById(PRICE_SHEET_ID);
  var venuesSheet = ss.getSheetByName('venues');
  var data = venuesSheet.getDataRange().getValues();
  var header = data[0];
  var idx = {};
  header.forEach(function (h, i) { idx[h] = i; });

  var candidates = getBackfillCandidates_(data, idx);
  Logger.log('Venues missing price_tier WITH a place_id on file (and not closed): ' + candidates.length);

  var sampleSize = Math.min(20, candidates.length);
  var preview = [['row', 'name', 'city_display', 'place_id', 'google_price_level', 'mapped_price_tier', 'note']];

  for (var i = 0; i < sampleSize; i++) {
    var r = candidates[i];
    var row = data[r];
    var result = fetchGooglePriceLevel_(row[idx['id']]);
    preview.push([r + 1, row[idx['name']], row[idx['city_display']], row[idx['id']], result.raw, result.mappedTier, result.note]);
    Utilities.sleep(100);
  }

  var previewSheet = ss.getSheetByName('price_backfill_preview') || ss.insertSheet('price_backfill_preview');
  previewSheet.clearContents();
  previewSheet.getRange(1, 1, preview.length, preview[0].length).setValues(preview);

  // Worst-case estimate: assumes no free monthly allowance remains.
  var billable = Math.max(0, candidates.length - 1000);
  var estCost = (billable / 1000) * 5.00;
  var sampleCost = (sampleSize / 1000) * 5.00;

  Logger.log('=== DRY RUN COMPLETE ===');
  Logger.log('Sample of ' + sampleSize + ' real lookups written to the "price_backfill_preview" tab. Check the mapped_price_tier column before going live.');
  Logger.log('This dry run itself billed ~$' + sampleCost.toFixed(2) + ' for the sample.');
  Logger.log('Estimated cost for the FULL run of ' + candidates.length + ' venues (worst case, no free allowance left): $' + estCost.toFixed(2));
}

/**
 * LIVE RUN — spends real money and writes to the venues tab.
 * Only run after reviewing price_backfill_preview from priceBackfillDryRun().
 * Processes PRICE_BATCH_SIZE rows per call, then stops — just run it again
 * to continue. Safe to re-run repeatedly; it always skips rows that already
 * have a price_tier.
 */
function priceBackfillLive() {
  if (!PLACES_API_KEY) {
    Logger.log('ERROR: PLACES_API_KEY is empty. Set the Script Property or paste your key in directly, then re-run.');
    return;
  }

  var ss = SpreadsheetApp.openById(PRICE_SHEET_ID);
  var venuesSheet = ss.getSheetByName('venues');
  var data = venuesSheet.getDataRange().getValues();
  var header = data[0];
  var idx = {};
  header.forEach(function (h, i) { idx[h] = i; });

  var candidates = getBackfillCandidates_(data, idx);
  var batch = candidates.slice(0, PRICE_BATCH_SIZE);

  var updated = 0, skippedFree = 0, skippedNoData = 0, errors = 0;

  batch.forEach(function (r) {
    var row = data[r];
    var result = fetchGooglePriceLevel_(row[idx['id']]);

    if (result.mappedTier !== '') {
      venuesSheet.getRange(r + 1, idx['price_tier'] + 1).setValue(result.mappedTier);
      updated++;
    } else if (result.raw === 0) {
      skippedFree++;
    } else if (result.raw === '(none)') {
      skippedNoData++;
    } else {
      errors++;
      Logger.log('Row ' + (r + 1) + ' (' + row[idx['name']] + '): ' + result.note);
    }

    Utilities.sleep(100);
  });

  Logger.log('=== LIVE BATCH COMPLETE ===');
  Logger.log('Processed this run: ' + batch.length);
  Logger.log('price_tier written: ' + updated);
  Logger.log('Skipped — Google says "Free": ' + skippedFree);
  Logger.log('Skipped — Google has no price data: ' + skippedNoData);
  Logger.log('Errors: ' + errors);
  Logger.log('Remaining candidates after this batch: ' + (candidates.length - batch.length));
  Logger.log('Run priceBackfillLive() again to continue. When "Processed this run" reads 0, you are done.');
}
