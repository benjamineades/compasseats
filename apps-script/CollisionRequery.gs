/**
 * CompassEats — Collision Re-query  (composite name|city geo override)
 * =====================================================================
 * THE PROBLEM THIS FIXES
 *   `Places Enrichment` is keyed by normalizedKey = the venue NAME ONLY.
 *   So every same-named venue across different cities (e.g. ALBA in Doha,
 *   Alacant, St-Peter-Port) collapses onto ONE geo row and inherits ONE
 *   place_id. Re-running geoEnrich can't fix it — its "done" set is also
 *   name-only, so it skips the duplicates.
 *
 * THE FIX (no change to reshape, normKey_, or geoEnrich)
 *   Reshape already looks up geo as:  enrich[name|city] || enrich[name]
 *   (Reshape.gs line ~650). It PREFERS a composite name|city key and only
 *   falls back to name-only. So if we add composite-keyed rows to
 *   `Places Enrichment` — one per (name, city) that currently collides,
 *   each with its OWN correct place_id — reshape picks them up automatically
 *   and the collisions disappear. Venues that don't collide are untouched.
 *
 * HOW IT WORKS
 *   1. Walks the award tabs (same SOURCE_MAP + parseRow_ as reshape) and
 *      finds every venue NAME that appears in 2+ cities — the collision set.
 *   2. For each (name, city) in that set, does a Google Places Text Search
 *      for "name, city" and applies a safety gate (returned name must match
 *      AND the returned address must mention the city).
 *   3. Accepted matches are written as composite rows
 *      ( normalizedKey = normKey_(name) + '|' + cityKey_(city) ) into
 *      `Places Enrichment`. Ambiguous ones are parked in `collision_review`.
 *
 * REUSES (all live in this same project's shared scope):
 *   SOURCE_MAP, parseRow_, findSheet_, normKey_, cityKey_  (Reshape.gs)
 *   placesTextSearch_                                       (geo-enrich.gs)
 *   PLACES_API_KEY                                          (Script Properties)
 *
 * COST: one Places Text Search per (name, city) ≈ $32 / 1,000. The full
 *   collision set is ~926 calls (~$30). Capped per run + resumable, so you
 *   control the spend. Start with the DRY RUN to verify match quality.
 *
 * RUN ORDER
 *   A. requeryCollisions_DryRun()  → previews into `collision_review`,
 *      writes NOTHING live. Eyeball the matches.
 *   B. requeryCollisions_Live()    → writes accepted composite rows into
 *      `Places Enrichment`; parks ambiguous ones in `collision_review`.
 *      Resumable — run again to continue past the per-run cap.
 *   C. (optional) acceptCollisionReviews() → after you set ACCEPT in the
 *      `decision` column of any parked rows, copies them in too.
 *   D. reshapeCompassEats → mergeDuplicateVenues → (blurb steps) →
 *      generateCitiesTab → preflightPublish → regenerate JSON → publish.
 */

// ── Config ───────────────────────────────────────────────────────────────
var COL_ENRICHMENT_TAB    = 'Places Enrichment';
var COL_REVIEW_TAB        = 'collision_review';
var COL_MAX_CALLS_DRYRUN  = 25;    // small first batch to verify quality (~$0.80)
var COL_MAX_CALLS_LIVE    = 250;   // per-run cap (stay under 6-min limit); resumable
var COL_CALL_DELAY_MS     = 120;
var COL_TODAY             = new Date().toISOString().slice(0, 10);

// Places Enrichment column order — MUST match the existing tab + reshape's reader.
var COL_ENRICH_HEADERS = ['normalizedKey', 'canonicalName', 'sheetName', 'placeId',
  'lat', 'lng', 'photoName', 'formattedAddress', 'businessStatus', 'lastVerified'];

// collision_review: `decision` first so acceptCollisionReviews() can read it.
var COL_REVIEW_HEADERS = ['decision', 'queried_name', 'queried_city', 'returned_name',
  'composite_key', 'placeId', 'lat', 'lng', 'photoName', 'formattedAddress',
  'businessStatus', 'note'];

// ── Public entry points ────────────────────────────────────────────────────
function requeryCollisions_DryRun() { runCollisionRequery_(true); }
function requeryCollisions_Live()   { runCollisionRequery_(false); }

// ── Build the collision worklist from the award tabs ────────────────────────
// nk -> { ck -> {name, city} }, keeping only names that appear in 2+ cities.
function buildCollisionWorklist_(ss) {
  var map = {};
  for (var tabName in SOURCE_MAP) {
    var sheet = findSheet_(ss, tabName);
    if (!sheet) continue;
    var slug = SOURCE_MAP[tabName][0];
    var defYear = SOURCE_MAP[tabName][1];
    var vals = sheet.getDataRange().getValues();
    for (var i = 1; i < vals.length; i++) {
      var row = vals[i];
      if (!row || row.join('') === '') continue;
      var rec = parseRow_(tabName, slug, defYear, row);
      if (!rec || !rec.name || !rec.city) continue;
      var nk = normKey_(rec.name);
      var ck = cityKey_(rec.city);
      if (!nk || !ck) continue;
      if (!map[nk]) map[nk] = {};
      if (!map[nk][ck]) map[nk][ck] = { name: rec.name, city: rec.city };
    }
  }
  var work = [];
  for (var n in map) {
    var cks = Object.keys(map[n]);
    if (cks.length < 2) continue;            // not a collision — single city
    for (var c = 0; c < cks.length; c++) {
      var ck2 = cks[c];
      work.push({
        key: n + '|' + ck2, nk: n, ck: ck2,
        name: map[n][ck2].name, city: map[n][ck2].city
      });
    }
  }
  return work;
}

// ── Core ────────────────────────────────────────────────────────────────────
function runCollisionRequery_(dryRun) {
  var ss = SpreadsheetApp.getActive();
  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  if (!key) throw new Error('No PLACES_API_KEY in Script Properties. ' +
    'Project Settings (gear) → Script Properties → add PLACES_API_KEY.');

  var esheet = findSheet_(ss, COL_ENRICHMENT_TAB);
  if (!esheet) throw new Error('No "' + COL_ENRICHMENT_TAB + '" tab. Run geoEnrich once first.');

  var work = buildCollisionWorklist_(ss);

  // resumability: composite keys already in Places Enrichment (live only)
  var done = {};
  var evals = esheet.getDataRange().getValues();
  for (var r = 1; r < evals.length; r++) {
    var k = String(evals[r][0] || '');
    if (k.indexOf('|') >= 0) done[k] = true;
  }

  var maxCalls = dryRun ? COL_MAX_CALLS_DRYRUN : COL_MAX_CALLS_LIVE;
  var previewRows = [];   // dry-run + parked rows (collision_review shape)
  var enrichRows  = [];   // accepted (Places Enrichment shape) — live only
  var looked = 0, accepted = 0, parked = 0, notFound = 0, skippedDone = 0, closedCt = 0;

  for (var i = 0; i < work.length; i++) {
    if (looked >= maxCalls) break;
    var w = work[i];
    if (!dryRun && done[w.key]) { skippedDone++; continue; }

    var result = placesTextSearch_(w.name + ', ' + w.city, key);
    looked++;
    Utilities.sleep(COL_CALL_DELAY_MS);

    if (!result) {
      notFound++;
      previewRows.push(['NOT_FOUND', w.name, w.city, '', w.key, '', '', '', '', '', '', 'no Places result']);
      continue;
    }

    var retName = result.displayName || '';
    var retNk = normKey_(retName);
    var nameMatch = retNk === w.nk || retNk.indexOf(w.nk) >= 0 || w.nk.indexOf(retNk) >= 0;
    var addrNorm = normKey_(result.address || '');
    var cityNorm = normKey_(w.city);
    var cityMatch = !cityNorm || addrNorm.indexOf(cityNorm) >= 0;
    var isClosed = result.status === 'CLOSED_PERMANENTLY';

    var decision = isClosed ? 'PARK_CLOSED' : ((nameMatch && cityMatch) ? 'ACCEPT' : 'PARK');
    var note = isClosed ? 'CLOSED_PERMANENTLY (Google)'
      : (decision === 'ACCEPT' ? 'name + city match'
        : (!nameMatch && !cityMatch ? 'name + city mismatch — verify'
          : (!nameMatch ? 'name mismatch — verify' : 'city mismatch — verify (name ok)')));

    var reviewRow = [decision, w.name, w.city, retName, w.key, result.placeId,
      result.lat, result.lng, result.photoName || '', result.address || '',
      result.status || '', note];

    if (decision === 'ACCEPT') {
      accepted++;
      if (dryRun) {
        previewRows.push(reviewRow);
      } else {
        enrichRows.push([w.key, retName || w.name, 'collision-fix', result.placeId,
          result.lat, result.lng, result.photoName || '', result.address || '',
          result.status || '', COL_TODAY]);
      }
    } else {
      if (isClosed) closedCt++; else parked++;
      // parked rows go to collision_review in BOTH modes (for your eyeball)
      previewRows.push(reviewRow);
    }
  }

  // ----- write Places Enrichment (live, accepted only) -----
  if (!dryRun && enrichRows.length) {
    var last = esheet.getLastRow();
    esheet.getRange(last + 1, 1, enrichRows.length, COL_ENRICH_HEADERS.length).setValues(enrichRows);
  }

  // ----- write collision_review -----
  var review = ss.getSheetByName(COL_REVIEW_TAB);
  if (dryRun) {
    // fresh preview each dry run
    if (review) review.clear(); else review = ss.insertSheet(COL_REVIEW_TAB);
    review.getRange(1, 1, 1, COL_REVIEW_HEADERS.length).setValues([COL_REVIEW_HEADERS]).setFontWeight('bold');
    review.setFrozenRows(1);
    if (previewRows.length) {
      review.getRange(2, 1, previewRows.length, COL_REVIEW_HEADERS.length).setValues(previewRows);
    }
  } else if (previewRows.length) {
    // append parked rows for manual handling
    if (!review) {
      review = ss.insertSheet(COL_REVIEW_TAB);
      review.getRange(1, 1, 1, COL_REVIEW_HEADERS.length).setValues([COL_REVIEW_HEADERS]).setFontWeight('bold');
      review.setFrozenRows(1);
    }
    var rlast = review.getLastRow();
    review.getRange(rlast + 1, 1, previewRows.length, COL_REVIEW_HEADERS.length).setValues(previewRows);
  }

  var remaining = 0;
  for (var j = 0; j < work.length; j++) if (!done[work[j].key]) remaining++;
  remaining -= looked;
  if (remaining < 0) remaining = 0;

  var msg = (dryRun ? 'DRY RUN — nothing written live.\n\n' : 'LIVE run complete.\n\n') +
    'collision (name,city) groups total: ' + work.length + '\n' +
    'looked up this run:                 ' + looked + '\n' +
    '  → would-accept / accepted:        ' + accepted + '\n' +
    '  → parked (ambiguous):             ' + parked + '\n' +
    '  → closed (Google):                ' + closedCt + '\n' +
    '  → no Places result:               ' + notFound + '\n' +
    (dryRun ? '' : ('skipped (already done):             ' + skippedDone + '\n')) +
    'still to process (next runs):       ' + remaining + '\n\n' +
    (dryRun
      ? 'Open the collision_review tab and check the matches. If they look\nright, run requeryCollisions_Live().'
      : (remaining > 0
        ? 'Hit the per-run cap — run requeryCollisions_Live() again to continue.'
        : 'Worklist exhausted. Next: reshapeCompassEats → full pipeline → publish.'));
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// ── Optional: accept manually-reviewed parked rows ──────────────────────────
// After a LIVE run, type ACCEPT in the `decision` column of any parked rows
// you've verified, then run this to copy them into Places Enrichment.
function acceptCollisionReviews() {
  var ss = SpreadsheetApp.getActive();
  var review = ss.getSheetByName(COL_REVIEW_TAB);
  if (!review) throw new Error('No "' + COL_REVIEW_TAB + '" tab.');
  var esheet = findSheet_(ss, COL_ENRICHMENT_TAB);
  if (!esheet) throw new Error('No "' + COL_ENRICHMENT_TAB + '" tab.');
  var rv = review.getDataRange().getValues();
  if (rv.length < 2) { SpreadsheetApp.getUi().alert('collision_review is empty.'); return; }

  // column positions in COL_REVIEW_HEADERS
  var D = 0, QNAME = 1, RETNAME = 3, CKEY = 4, PID = 5, LAT = 6, LNG = 7,
    PHOTO = 8, ADDR = 9, STATUS = 10;
  var toEnrich = [], keep = [rv[0]];
  var acc = 0, rej = 0, left = 0;
  for (var i = 1; i < rv.length; i++) {
    var row = rv[i];
    var d = String(row[D] || '').trim().toUpperCase();
    if (d === 'ACCEPT') {
      toEnrich.push([row[CKEY], row[RETNAME] || row[QNAME], 'collision-fix-reviewed',
        row[PID], row[LAT], row[LNG], row[PHOTO] || '', row[ADDR] || '',
        row[STATUS] || '', COL_TODAY]);
      acc++;
    } else if (d === 'REJECT') { rej++; }
    else { keep.push(row); left++; }
  }
  if (toEnrich.length) {
    var last = esheet.getLastRow();
    esheet.getRange(last + 1, 1, toEnrich.length, COL_ENRICH_HEADERS.length).setValues(toEnrich);
  }
  review.clear();
  review.getRange(1, 1, 1, COL_REVIEW_HEADERS.length).setValues([COL_REVIEW_HEADERS]).setFontWeight('bold');
  review.setFrozenRows(1);
  if (keep.length > 1) review.getRange(2, 1, keep.length - 1, COL_REVIEW_HEADERS.length).setValues(keep.slice(1));

  SpreadsheetApp.getUi().alert('ACCEPT → Places Enrichment: ' + acc + '\n' +
    'REJECT → dropped: ' + rej + '\nleft undecided: ' + left +
    '\n\nNext: reshapeCompassEats.');
}
