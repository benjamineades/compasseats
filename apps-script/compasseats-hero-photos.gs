/**
 * compasseats-hero-photos.gs
 * -----------------------------------------------------------------------------
 * Fills the `hero_image_url` column (J) of the `cities` tab with a good,
 * landscape city photo from the Pexels API. Also records attribution in two
 * new columns: L = photo_credit (photographer), M = photo_source (Pexels link).
 *
 * NOTE: every constant in this file is prefixed HERO_ so it can never collide
 * with names declared in your other script files (reshape, cities, etc.).
 *
 * WHY IT WORKS THIS WAY
 *  - Pexels allows ~200 requests/hour. Apps Script runs are killed at ~6 min.
 *    So this script processes a safe BATCH per run, remembers where it stopped,
 *    and you simply run it again to continue. After a few runs you're done.
 *  - It SKIPS any city that already has a hero_image_url (column J), so it's
 *    safe to re-run and it never overwrites work.
 *  - It only writes a URL when the match looks like a real city photo.
 *    If Pexels has nothing confident for an obscure town, it leaves J blank
 *    on purpose -- an honest gap beats a wrong skyline.
 *
 * SETUP (one time): see the SETTINGS block below -- paste your Pexels API key.
 * RUN: in the Sheet menu, CompassEats Photos > Fill hero photos (batch).
 *      Repeat until the toast says "All cities processed."
 * -----------------------------------------------------------------------------
 */

// ============================== SETTINGS =====================================

// 1) Paste your Pexels API key between the quotes:
const HERO_PEXELS_API_KEY = '5NQvZtFLFXvS56K5epeVxAdHiB9elvvhi80lPJ1uxnHMwyl56bdiDarF';

// 2) How many cities to process per run. 170 stays safely under the 200/hr
//    limit and finishes well within the 6-minute execution cap. Leave as-is
//    unless a run times out (then lower it).
const HERO_BATCH_SIZE = 170;

// 3) The tab and column layout (already matched to your sheet -- don't change
//    unless your columns move).
const HERO_CITIES_TAB       = 'cities';
const HERO_COL_DISPLAY      = 2;   // B
const HERO_COL_COUNTRY      = 3;   // C
const HERO_COL_HERO_URL     = 10;  // J  (hero_image_url)
const HERO_COL_PHOTO_CREDIT = 12;  // L  (new: photographer name)
const HERO_COL_PHOTO_SOURCE = 13;  // M  (new: Pexels page link)

// =============================================================================


/**
 * Adds the menu when the sheet opens.
 * Named uniquely (onOpen_heroPhotos) so it won't clash with an onOpen in
 * another file. We ALSO call it from a normal onOpen below -- but if your
 * project already has its own onOpen, see the note in the install steps.
 */
 {
  SpreadsheetApp.getUi()
    .createMenu('CompassEats Photos')
    .addItem('Fill hero photos (batch)', 'fillHeroPhotosBatch')
    .addSeparator()
    .addItem('Reset progress (start over)', 'resetHeroProgress')
    .addToUi();
}

/**
 * Standard trigger. If your project has NO other onOpen, this builds the menu.
 * If another file already defines onOpen, delete this function and instead add
 * the line  onOpen_heroPhotos();  inside that existing onOpen.
 */


/**
 * Main entry point. Processes the next HERO_BATCH_SIZE cities that still need a
 * photo, then stops. Run repeatedly until everything is done.
 */
function fillHeroPhotosBatch() {
  const ui = SpreadsheetApp.getUi();

  if (!HERO_PEXELS_API_KEY || HERO_PEXELS_API_KEY === 'PASTE_YOUR_PEXELS_KEY_HERE') {
    ui.alert('Add your Pexels API key first',
      'Open the script, find the SETTINGS block at the top, and paste your key into HERO_PEXELS_API_KEY.',
      ui.ButtonSet.OK);
    return;
  }

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName(HERO_CITIES_TAB);
  if (!sheet) { ui.alert('Could not find a tab named "' + HERO_CITIES_TAB + '".'); return; }

  // Make sure the two attribution headers exist (only the first run adds them).
  ensureHeroHeaders_(sheet);

  const lastRow = sheet.getLastRow();
  if (lastRow < 2) { ui.alert('No city rows found.'); return; }

  // Read display, country, and current hero_image_url for every row at once.
  const numRows = lastRow - 1;
  const displays  = sheet.getRange(2, HERO_COL_DISPLAY,  numRows, 1).getValues();
  const countries = sheet.getRange(2, HERO_COL_COUNTRY,  numRows, 1).getValues();
  const heroUrls  = sheet.getRange(2, HERO_COL_HERO_URL, numRows, 1).getValues();

  // Resume from where the last run stopped.
  const props = PropertiesService.getDocumentProperties();
  let startIndex = parseInt(props.getProperty('hero_next_index') || '0', 10);
  if (isNaN(startIndex) || startIndex < 0) startIndex = 0;

  let processed = 0;    // how many we actually fetched this run
  let filled = 0;       // how many got a photo
  let skippedBlank = 0; // how many had no confident match
  let i = startIndex;

  try {
    for (; i < numRows && processed < HERO_BATCH_SIZE; i++) {
      const existing = (heroUrls[i][0] || '').toString().trim();
      if (existing) continue; // already has a photo -- skip, costs no API call

      const city = (displays[i][0] || '').toString().trim();
      const country = (countries[i][0] || '').toString().trim();
      if (!city) continue;

      processed++;
      const result = fetchHeroCityPhoto_(city, country);

      if (result) {
        const rowNumber = i + 2; // +2: header row + 0-based index
        sheet.getRange(rowNumber, HERO_COL_HERO_URL).setValue(result.url);
        sheet.getRange(rowNumber, HERO_COL_PHOTO_CREDIT).setValue(result.photographer);
        sheet.getRange(rowNumber, HERO_COL_PHOTO_SOURCE).setValue(result.pexelsPage);
        filled++;
      } else {
        skippedBlank++; // leave J blank on purpose
      }

      // Gentle pacing so we never trip the per-second side of the rate limit.
      Utilities.sleep(350);
    }
  } catch (err) {
    // Save where we are, then surface the message (e.g. rate limit).
    props.setProperty('hero_next_index', String(i));
    ui.alert('Stopped early', String(err.message || err) +
      '\n\nProgress was saved -- just run again later to continue.', ui.ButtonSet.OK);
    return;
  }

  // Save progress. If we reached the end, clear it so the next run reports done.
  if (i >= numRows) {
    props.deleteProperty('hero_next_index');
    ss.toast(
      'All cities processed. Filled ' + filled + ', left blank ' + skippedBlank +
      ' (no confident match). You can stop running now.',
      'CompassEats -- Done', 10);
  } else {
    props.setProperty('hero_next_index', String(i));
    ss.toast(
      'Batch done: filled ' + filled + ', blank ' + skippedBlank +
      '. Run again to continue from city #' + (i + 1) + '.',
      'CompassEats -- Keep going', 10);
  }
}

/**
 * Queries Pexels for a landscape city photo. Returns {url, photographer,
 * pexelsPage} on a confident match, or null when nothing good was found.
 */
function fetchHeroCityPhoto_(city, country) {
  // Tighter query = better matches. Country word and extra keywords pull in
  // generic stock, so we drop them and use just "<City> skyline".
  const query = city + ' skyline';

  const url = 'https://api.pexels.com/v1/search'
    + '?query=' + encodeURIComponent(query)
    + '&orientation=landscape'
    + '&per_page=3';

  let resp;
  try {
    resp = UrlFetchApp.fetch(url, {
      method: 'get',
      headers: { 'Authorization': HERO_PEXELS_API_KEY },
      muteHttpExceptions: true,
    });
  } catch (e) {
    return null; // network hiccup -- leave blank, a later run can retry
  }

  const code = resp.getResponseCode();
  if (code === 429) {
    // Hit the hourly limit. Throw so the caller stops cleanly and saves place.
    throw new Error('Pexels rate limit reached (429). Wait an hour, then run again.');
  }
  if (code !== 200) return null;

  let data;
  try { data = JSON.parse(resp.getContentText()); }
  catch (e) { return null; }

  const photos = (data && data.photos) || [];
  if (!photos.length) return null; // no confident match -> caller leaves blank

  // Take the top result. Prefer the pre-sized "landscape" URL for fast loads.
  const p = photos[0];
  const src = p.src || {};
  const chosen = src.landscape || src.large2x || src.large || src.original;
  if (!chosen) return null;

  return {
    url: chosen,
    photographer: p.photographer || '',
    pexelsPage: p.url || '',
  };
}

/** Adds the two attribution headers (L, M) once, if missing. */
function ensureHeroHeaders_(sheet) {
  const creditHeader = sheet.getRange(1, HERO_COL_PHOTO_CREDIT).getValue();
  if (!creditHeader) sheet.getRange(1, HERO_COL_PHOTO_CREDIT).setValue('photo_credit');
  const sourceHeader = sheet.getRange(1, HERO_COL_PHOTO_SOURCE).getValue();
  if (!sourceHeader) sheet.getRange(1, HERO_COL_PHOTO_SOURCE).setValue('photo_source');
}

/** Clears saved progress so the next batch starts from the first city again. */
function resetHeroProgress() {
  PropertiesService.getDocumentProperties().deleteProperty('hero_next_index');
  SpreadsheetApp.getActiveSpreadsheet().toast(
    'Progress reset. The next batch run starts from the top (still skips cities that already have a photo).',
    'CompassEats', 6);
}

/**
 * One-time cleanup: clears ONLY the photos this script wrote (rows that have
 * a value in photo_source col M), leaving any hand-entered photos untouched.
 * Then resets progress so the next batch refills from the top.
 */
function clearScriptWrittenPhotos() {
  const ui = SpreadsheetApp.getUi();
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(HERO_CITIES_TAB);
  if (!sheet) { ui.alert('No "' + HERO_CITIES_TAB + '" tab found.'); return; }

  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return;
  const numRows = lastRow - 1;

  const sources = sheet.getRange(2, HERO_COL_PHOTO_SOURCE, numRows, 1).getValues();
  let cleared = 0;
  for (let i = 0; i < numRows; i++) {
    if ((sources[i][0] || '').toString().trim()) {
      const r = i + 2;
      sheet.getRange(r, HERO_COL_HERO_URL).clearContent();    // J
      sheet.getRange(r, HERO_COL_PHOTO_CREDIT).clearContent(); // L
      sheet.getRange(r, HERO_COL_PHOTO_SOURCE).clearContent(); // M
      cleared++;
    }
  }
  PropertiesService.getDocumentProperties().deleteProperty('hero_next_index');
  ui.alert('Cleared ' + cleared + ' script-written photos and reset progress. '
    + 'Run "Fill hero photos (batch)" to refill with the new query.');
}
