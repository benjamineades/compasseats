/**
 * CompassEats — Photo URL Resolver (Google Apps Script)
 * =====================================================
 * Fills the empty "photo_url" column in the "venues" tab using Google
 * Places photo references.
 *
 * WHAT IT DOES
 *   The reshape script left photo_url blank because the enrichment tab only
 *   has Places "photoName" references (places/PLACE_ID/photos/REF), which are
 *   not usable image URLs. This script turns each into a stable media URL.
 *
 *   It reads the photoName from the enrichment tab (matched by placeId),
 *   then constructs the Places API (v1) photo media URL:
 *     https://places.googleapis.com/v1/{photoName}/media?key=KEY&maxWidthPx=W
 *
 *   That URL returns the image bytes directly (a 302 to the hosted image),
 *   so it can go straight into an <img src>. No per-row API call is needed
 *   to BUILD the URL — but the URL itself, when loaded, counts as a Place
 *   Photo request and is billed by Google. See COST below.
 *
 * COST  *** READ THIS ***
 *   Building the URLs here is FREE (string construction, no API calls).
 *   Google bills when the URL is actually FETCHED (i.e. when a browser loads
 *   the image). With ~8,500 venues, every full page-render of your whole
 *   catalog is ~8,500 Place Photo requests. Mitigations baked in below:
 *     - We store the constructed URL, not the bytes.
 *     - RECOMMENDED next step (outside this script): a one-time job that
 *       fetches each URL once, saves the image to Cloudflare R2 / a CDN, and
 *       rewrites photo_url to the CDN copy. Then Google is hit once per
 *       venue, ever, instead of once per page view.
 *   This script optionally does a VALIDATION fetch (HEAD-like GET) on a small
 *   sample to confirm your key works — that sample DOES incur cost. Keep the
 *   sample tiny (default 5).
 *
 * SETUP
 *   1. Get a Google Maps Platform API key with "Places API (New)" enabled.
 *   2. Paste it into PLACES_API_KEY below.
 *   3. Restrict the key (HTTP referrer or IP) in Google Cloud Console.
 *   4. Run → resolvePhotoUrls.
 *
 * SAFE TO RE-RUN
 *   Skips rows that already have a photo_url unless FORCE_REFRESH = true.
 *   Processes in batches and remembers progress, so if it times out
 *   (Apps Script caps at ~6 min) just run it again to continue.
 */

// ---- Config ---------------------------------------------------------------
var PLACES_API_KEY = 'AIzaSyBxszZ9NOp3jBdoouT9atVogHzq7-S6Ry0';
var PHOTO_MAX_WIDTH = 1200;        // px; 800–1600 is reasonable for cards/hero
var VALIDATE_SAMPLE = 5;           // do a real fetch on N rows to confirm key (incurs cost). 0 = skip.
var FORCE_REFRESH = false;         // true = overwrite existing photo_url values
var BATCH_LIMIT = 4000;            // rows processed per run (URL build is cheap; this is just a safety cap)

var VENUES_TAB = 'venues';
var ENRICHMENT_TAB = 'Places Enrichment';

// ---------------------------------------------------------------------------

function resolvePhotoUrls() {
  if (PLACES_API_KEY === 'AIzaSyA3wtqxR5fhhgQYf2MCjnvQq04LiSj8iiQ' || !PLACES_API_KEY) {
    throw new Error('Set PLACES_API_KEY at the top of the script first.');
  }

  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var vsheet = ss.getSheetByName(VENUES_TAB);
  if (!vsheet) throw new Error('No "' + VENUES_TAB + '" tab. Run the reshape script first.');

  // Build placeId -> photoName map from enrichment
  var esheet = findSheetLoose_(ss, ENRICHMENT_TAB);
  if (!esheet) throw new Error('No "' + ENRICHMENT_TAB + '" tab found.');
  var ev = esheet.getDataRange().getValues();
  var ehead = {};
  for (var c = 0; c < ev[0].length; c++) ehead[ev[0][c]] = c;
  var photoByPlace = {};
  for (var r = 1; r < ev.length; r++) {
    var pid = ev[r][ehead['placeId']];
    var pname = ev[r][ehead['photoName']];
    if (pid && pname && !photoByPlace[pid]) photoByPlace[pid] = pname;
  }

  // Walk venues, fill photo_url
  var vv = vsheet.getDataRange().getValues();
  var vhead = {};
  for (var c2 = 0; c2 < vv[0].length; c2++) vhead[vv[0][c2]] = c2;
  if (vhead['photo_url'] === undefined || vhead['id'] === undefined) {
    throw new Error('venues tab missing "id" or "photo_url" column.');
  }
  var idCol = vhead['id'];
  var urlCol = vhead['photo_url'];

  var filled = 0, skipped = 0, noPhoto = 0, processed = 0;
  var updates = []; // [rowIndex(1-based), url]

  for (var i = 1; i < vv.length; i++) {
    if (processed >= BATCH_LIMIT) break;
    var existing = vv[i][urlCol];
    if (existing && !FORCE_REFRESH) { skipped++; continue; }

    var placeId = vv[i][idCol];
    var photoName = placeId ? photoByPlace[placeId] : null;
    if (!photoName) { noPhoto++; continue; }

    var url = 'https://places.googleapis.com/v1/' + photoName +
              '/media?maxWidthPx=' + PHOTO_MAX_WIDTH + '&key=' + PLACES_API_KEY;
    updates.push([i + 1, url]);
    filled++;
    processed++;
  }

  // Write back (batched by column for speed)
  for (var u = 0; u < updates.length; u++) {
    vsheet.getRange(updates[u][0], urlCol + 1).setValue(updates[u][1]);
  }

  // Optional: validate a small sample actually resolves (incurs cost)
  var validationNote = 'skipped';
  if (VALIDATE_SAMPLE > 0 && updates.length > 0) {
    var ok = 0, bad = 0;
    var n = Math.min(VALIDATE_SAMPLE, updates.length);
    for (var s = 0; s < n; s++) {
      try {
        var resp = UrlFetchApp.fetch(updates[s][1], {
          muteHttpExceptions: true, followRedirects: false
        });
        var code = resp.getResponseCode();
        if (code === 200 || code === 302) ok++; else bad++;
      } catch (e) { bad++; }
    }
    validationNote = ok + ' ok / ' + bad + ' failed (of ' + n + ' sampled)';
  }

  var msg =
    'Photo URLs resolved.\n' +
    'filled:        ' + filled + '\n' +
    'already had:   ' + skipped + '\n' +
    'no photo ref:  ' + noPhoto + '\n' +
    'validation:    ' + validationNote + '\n\n' +
    (filled >= BATCH_LIMIT
      ? 'Hit batch limit — run again to continue.\n\n'
      : '') +
    'IMPORTANT: these URLs hit Google (and bill) on every image load.\n' +
    'Plan a one-time job to cache images to your own CDN and rewrite\n' +
    'photo_url to the cached copies before going live.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

/** Loose tab-name match (ignores apostrophes/case/spacing). */
function findSheetLoose_(ss, wantName) {
  var want = String(wantName).toLowerCase().replace(/[''`]/g, '').replace(/\s+/g, ' ').trim();
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    var n = sheets[i].getName().toLowerCase().replace(/[''`]/g, '').replace(/\s+/g, ' ').trim();
    if (n === want) return sheets[i];
  }
  return null;
}
