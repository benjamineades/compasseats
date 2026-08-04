/**
 * CompassEats — Geo Enrichment (Google Apps Script)
 * =================================================
 * Fills the gap nothing else does: takes venues sitting in `needs_enrichment`
 * (reason "no placeId") and looks each one up in Google Places by name+city,
 * then appends a row to the `Places Enrichment` tab. On the next reshape,
 * those venues inherit geo and graduate into `venues`.
 *
 * READS:   enrichment_audit  (prestige-ordered worklist; run auditEnrichment first)
 * WRITES:  Places Enrichment  (new geo rows — the 10-column shape reshape expects)
 *          enrichment_review  (ambiguous matches parked for your eyeball)
 * NEVER touches: venues, needs_enrichment, or any award tab.
 *
 * ── KEY HANDLING (read this) ───────────────────────────────────────────────
 *   The API key is NOT in this file. Store it once in Script Properties:
 *     Apps Script editor → Project Settings (gear) → Script Properties →
 *     Add property:  name = PLACES_API_KEY   value = <your key>
 *   Rotate any key that was ever pasted into chat or hardcoded elsewhere.
 *
 * ── RESUMABLE ──────────────────────────────────────────────────────────────
 *   Each run processes up to BATCH_LIMIT venues, top of the prestige list
 *   first. It skips any venue whose normalizedKey is ALREADY in
 *   Places Enrichment (or already parked in enrichment_review), so you can
 *   run it repeatedly and it picks up where it left off. Apps Script caps a
 *   run at ~6 min; with a per-call delay that's comfortably under BATCH_LIMIT.
 *
 * ── SAFETY GATE ────────────────────────────────────────────────────────────
 *   Places lookups usually return the right venue first, but not always
 *   (common names, moved/closed spots, ambiguous cities). A wrong match =
 *   a wrong pin on the live map. So:
 *     - If the returned displayName normalizes to (or closely contains) the
 *       queried name  →  written straight to Places Enrichment.
 *     - Otherwise  →  written to enrichment_review with both names side by
 *       side, for you to accept or reject manually. Nothing ambiguous is
 *       trusted silently.
 *
 * ── COST (UPDATED August 4, 2026) ───────────────────────────────────────────
 *   Old approach: one Text Search (New) call per venue, requesting
 *   name/address/location/status/PHOTOS in a single field mask. Because
 *   `photos` is an Atmosphere-tier field, that pulled every call into
 *   Google's most expensive Text Search SKU — roughly $32–40 per 1,000
 *   requests — even though the photo data was never used anywhere. Your
 *   live site gets photos from a completely separate system (the
 *   owner-filtered Places photo Worker, `compasseats-venue-photo`), which
 *   fetches a photo fresh at view time using only the venue's placeId. Photos
 *   captured here never reached that pipeline — it was paying premium
 *   pricing for a field nothing downstream read.
 *
 *   New approach: two cheap calls per venue instead of one expensive one.
 *     1. Text Search, field mask `places.id` ONLY — this is Google's
 *        IDs-only SKU, free/near-free, just resolves the query to a place_id.
 *     2. Place Details, field mask limited to Basic Data
 *        (`id,displayName,formattedAddress,location,businessStatus`) — no
 *        photos, no ratings/reviews. Bills at the low Basic/Essentials tier,
 *        roughly $5 per 1,000 requests.
 *   Net effect: same name, address, coordinates, and business status as
 *   before, same accuracy (the field mask doesn't change which place Google
 *   considers the best match — only what data comes back about it), same
 *   safety-gate logic — at roughly 85% less cost. Nothing downstream needs
 *   to change: new venues still get a placeId, so the photo Worker still
 *   finds photos for them automatically.
 *
 *   Recommended first run after this change: MAX_TO_PROCESS = 200 to spot-
 *   check match quality before running the full backlog.
 *
 * ── HOW TO RUN ─────────────────────────────────────────────────────────────
 *   1. Store PLACES_API_KEY in Script Properties (see above).
 *   2. Run auditEnrichment first so enrichment_audit is fresh.
 *   3. Select geoEnrich → ▶ Run. Read the log. Repeat to continue.
 *   4. When done, run reshapeCompassEats to graduate enriched venues.
 *   5. Review the enrichment_review tab; for good matches, copy the row into
 *      Places Enrichment (or use acceptReviewRow helpers later).
 */

// ── Config ──────────────────────────────────────────────────────────────────
var MAX_TO_PROCESS = 200;   // hard cap on venues looked up THIS RUN (cost control). Raise once happy.
var BATCH_LIMIT    = 200;   // safety cap to stay under the 6-min execution limit
var CALL_DELAY_MS  = 120;   // pause between API calls (politeness / rate smoothing)
var MIN_PRESTIGE   = 0;     // skip venues below this prestige_score (0 = process all)

var AUDIT_TAB      = 'enrichment_audit';
var ENRICHMENT_TAB = 'Places Enrichment';
var REVIEW_TAB     = 'enrichment_review';
var CLOSED_TAB     = 'closed_venues';

// Places Enrichment column order — MUST match the existing tab + reshape's reader.
var ENRICH_HEADERS = ['normalizedKey', 'canonicalName', 'sheetName', 'placeId',
  'lat', 'lng', 'photoName', 'formattedAddress', 'businessStatus', 'lastVerified'];

// First column is `decision` — you type ACCEPT or REJECT, then run acceptReviewRows().
var REVIEW_HEADERS = ['decision', 'queried_name', 'queried_city', 'returned_name',
  'normalizedKey', 'placeId', 'lat', 'lng', 'formattedAddress',
  'businessStatus', 'photoName', 'match_note', 'prestige', 'sources'];

var TODAY_GEO = new Date().toISOString().slice(0, 10);

// ── main ──────────────────────────────────────────────────────────────────
function geoEnrich() {
  var ss = SpreadsheetApp.getActive();

  var key = PropertiesService.getScriptProperties().getProperty('PLACES_API_KEY');
  if (!key) {
    throw new Error('No PLACES_API_KEY in Script Properties. ' +
      'Project Settings (gear) → Script Properties → add PLACES_API_KEY.');
  }

  var audit = ss.getSheetByName(AUDIT_TAB);
  if (!audit) throw new Error('No `' + AUDIT_TAB + '` tab. Run auditEnrichment first.');

  // --- read the prestige-ordered worklist ---
  var av = audit.getDataRange().getValues();
  var ah = {};
  for (var c = 0; c < av[0].length; c++) ah[String(av[0][c]).trim()] = c;
  var iName = ah['name'], iCity = ah['city'], iReason = ah['reason'],
      iPrestige = ah['prestige_score'], iSources = ah['sources'];

  // --- build the "already done" set: keys already in Places Enrichment + review ---
  var done = {};
  var esheet = findSheetLooseGeo_(ss, ENRICHMENT_TAB);
  if (!esheet) {
    // create it with headers if missing
    esheet = ss.insertSheet(ENRICHMENT_TAB);
    esheet.getRange(1, 1, 1, ENRICH_HEADERS.length).setValues([ENRICH_HEADERS]).setFontWeight('bold');
    esheet.setFrozenRows(1);
  } else {
    var evals = esheet.getDataRange().getValues();
    for (var r = 1; r < evals.length; r++) {
      var k = evals[r][0];
      if (k) done[String(k)] = true;
    }
  }
  var review = ss.getSheetByName(REVIEW_TAB);
  if (review) {
    var rvals = review.getDataRange().getValues();
    var rkCol = 4; // normalizedKey position in REVIEW_HEADERS (after the new `decision` col)
    for (var rr = 1; rr < rvals.length; rr++) {
      var rk = rvals[rr][rkCol];
      if (rk) done[String(rk)] = true;
    }
  }

  // --- walk the worklist, top prestige first (audit is already sorted) ---
  var enrichRows = [];   // straight to Places Enrichment
  var reviewRows = [];   // parked for manual review
  var closedRows = [];   // permanently-closed → closed_venues
  var looked = 0, accepted = 0, parked = 0, notFound = 0, skippedDone = 0, skippedLowP = 0, closedCount = 0;

  for (var i = 1; i < av.length; i++) {
    if (looked >= MAX_TO_PROCESS || looked >= BATCH_LIMIT) break;

    var reason = String(av[i][iReason] || '');
    if (reason.indexOf('no placeId') !== 0) continue; // only "no placeId" / "no placeId + no city"

    var name = String(av[i][iName] || '').trim();
    var city = String(av[i][iCity] || '').trim();
    if (!name) continue;

    var prestige = Number(av[i][iPrestige]) || 0;
    if (prestige < MIN_PRESTIGE) { skippedLowP++; continue; }

    var nk = normKeyGeo_(name);
    // FIXED July 1, 2026: this used to be keyed by name ALONE (`done[nk]`),
    // which meant every city-variant of a shared name (chain branches like
    // Da Vittorio in Brusaporto/Shanghai/Sankt Moritz, or coincidental
    // name twins like the several unrelated "Atelier Restaurant"s) collapsed
    // onto whichever city got searched first — the other cities silently
    // inherited that first city's placeId and address. Reshape.gs already
    // prefers a `name|city` composite key over the bare name
    // (`enrich[nk + '|' + ck] || enrich[nk]`, line ~650) specifically to
    // support this; geo-enrich just wasn't writing that composite key. Now
    // it does, using the SAME cityKey_() (with the CITY_ALIASES_ map) that
    // reshape uses, so the two line up exactly. Old bare-name rows already in
    // Places Enrichment are untouched and still work as reshape's fallback.
    var ck = cityKey_(city);
    var compositeKey = nk + '|' + ck;
    if (done[compositeKey]) { skippedDone++; continue; }
    done[compositeKey] = true; // guard against dup work within this run

    // --- cheap two-step lookup: free/near-free ID search, then Basic-data Details ---
    var query = city ? (name + ', ' + city) : name;
    var result = placesLookupCheap_(query, key);
    looked++;
    Utilities.sleep(CALL_DELAY_MS);

    if (!result) { notFound++; continue; }

    var sources = String(av[i][iSources] || '');
    var retName = result.displayName || '';
    var retNk = normKeyGeo_(retName);

    // --- Closed venues: route permanently-closed straight to a closed list ---
    if (result.status === 'CLOSED_PERMANENTLY') {
      closedRows.push([name, city, 'CLOSED_PERMANENTLY (Google)', TODAY_GEO]);
      closedCount++;
      continue;
    }

    // --- Safety gate ---
    // Name check: returned name matches (equals or one contains the other).
    var nameMatch = retNk === nk ||
                    retNk.indexOf(nk) >= 0 || nk.indexOf(retNk) >= 0;
    // City check: returned address mentions the queried city (when we have one).
    var addrNorm = normKeyGeo_(result.address || '');
    var cityNorm = normKeyGeo_(city);
    var cityMatch = !cityNorm || addrNorm.indexOf(cityNorm) >= 0;

    // Accept only when BOTH name and city agree. This catches same-name-wrong-city
    // and right-place-renamed-but-wrong-city cases that name-only would wave through.
    var matched = nameMatch && cityMatch;

    if (matched) {
      enrichRows.push([
        compositeKey,             // normalizedKey — now name|city, matches reshape's lookup
        retName || name,          // canonicalName
        'geo-enrich',             // sheetName (provenance)
        result.placeId,           // placeId
        result.lat,               // lat
        result.lng,               // lng
        result.photoName || '',   // photoName — intentionally always blank now, see cost note above;
                                   // the live photo Worker resolves photos separately by placeId
        result.address || '',     // formattedAddress
        result.status || '',      // businessStatus
        TODAY_GEO                 // lastVerified
      ]);
      accepted++;
    } else {
      // Build a specific note so you know WHY it parked.
      var note = !nameMatch && !cityMatch ? 'name + city mismatch — verify'
               : !nameMatch ? 'name mismatch — verify'
               : 'city mismatch — verify (name ok)';
      if (result.status && result.status !== 'OPERATIONAL') {
        note += ' [' + result.status + ']';
      }
      reviewRows.push([
        '', // decision column — you fill: ACCEPT or REJECT
        name, city, retName, compositeKey, result.placeId, result.lat, result.lng,
        result.address || '', result.status || '', result.photoName || '',
        note, prestige, sources
      ]);
      parked++;
    }
  }

  // --- write accepted rows to Places Enrichment ---
  if (enrichRows.length) {
    var last = esheet.getLastRow();
    esheet.getRange(last + 1, 1, enrichRows.length, ENRICH_HEADERS.length).setValues(enrichRows);
  }

  // --- write parked rows to enrichment_review ---
  if (reviewRows.length) {
    if (!review) {
      review = ss.insertSheet(REVIEW_TAB);
      review.getRange(1, 1, 1, REVIEW_HEADERS.length).setValues([REVIEW_HEADERS]).setFontWeight('bold');
      review.setFrozenRows(1);
    }
    var rlast = review.getLastRow();
    review.getRange(rlast + 1, 1, reviewRows.length, REVIEW_HEADERS.length).setValues(reviewRows);
  }

  // --- write permanently-closed venues to closed_venues ---
  if (closedRows.length) {
    var closed = findSheetLooseGeo_(ss, CLOSED_TAB);
    if (!closed) {
      closed = ss.insertSheet(CLOSED_TAB);
      closed.getRange(1, 1, 1, 4).setValues([['name', 'city', 'reason', 'flagged']])
        .setFontWeight('bold');
      closed.setFrozenRows(1);
    }
    var clast = closed.getLastRow();
    closed.getRange(clast + 1, 1, closedRows.length, 4).setValues(closedRows);
  }

  var remaining = countRemaining_(av, ah, done);
  var msg =
    'Geo enrichment run complete.\n' +
    'venues looked up this run:   ' + looked + '\n' +
    '  → accepted (to Places Enrichment): ' + accepted + '\n' +
    '  → parked (to enrichment_review):   ' + parked + '\n' +
    '  → closed (to closed_venues):       ' + closedCount + '\n' +
    '  → no Places result:                ' + notFound + '\n' +
    'skipped (already done):      ' + skippedDone + '\n' +
    (skippedLowP ? ('skipped (below MIN_PRESTIGE): ' + skippedLowP + '\n') : '') +
    '\nApprox. still to process:    ' + remaining + '\n\n' +
    (looked >= MAX_TO_PROCESS || looked >= BATCH_LIMIT
      ? 'Hit the per-run cap — run geoEnrich again to continue.\n'
      : 'Worklist exhausted for current caps.\n') +
    '\nNEXT: review the enrichment_review tab, then run reshapeCompassEats\n' +
    'to graduate the accepted venues into the venues tab.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// ── Process your decisions in enrichment_review ────────────────────────────
// After eyeballing enrichment_review, type ACCEPT or REJECT in the `decision`
// column (column A) of the rows you've judged, then run this. ACCEPTED rows are
// copied into Places Enrichment (so reshape will pick them up); both ACCEPTED
// and REJECTED rows are then removed from the review tab. Rows you left blank
// stay put for later. Re-run reshapeCompassEats afterward.
function acceptReviewRows() {
  var ss = SpreadsheetApp.getActive();
  var review = ss.getSheetByName(REVIEW_TAB);
  if (!review) throw new Error('No `' + REVIEW_TAB + '` tab.');

  var esheet = findSheetLooseGeo_(ss, ENRICHMENT_TAB);
  if (!esheet) throw new Error('No `' + ENRICHMENT_TAB + '` tab.');

  var rv = review.getDataRange().getValues();
  if (rv.length < 2) { SpreadsheetApp.getUi().alert('Review tab is empty.'); return; }

  // Column positions in REVIEW_HEADERS
  var D = 0, NAME = 1, CITY = 2, RETNAME = 3, NK = 4, PID = 5, LAT = 6, LNG = 7,
      ADDR = 8, STATUS = 9, PHOTO = 10;

  var toEnrich = [];
  var keepRows = [rv[0]]; // header
  var accepted = 0, rejected = 0, left = 0;

  for (var i = 1; i < rv.length; i++) {
    var row = rv[i];
    var decision = String(row[D] || '').trim().toUpperCase();
    if (decision === 'ACCEPT') {
      // Rebuild the SAME name|city composite key the main geoEnrich loop and
      // reshape.gs use, so an approved-from-review row can never re-introduce a
      // bare-name collision. Falls back to the bare name only when there is no
      // city (matching reshape's `enrich[nk+'|'+ck] || enrich[nk]` fallback).
      var aNk = normKeyGeo_(String(row[NAME] || ''));
      var aCk = cityKey_(String(row[CITY] || ''));
      var aKey = aCk ? (aNk + '|' + aCk) : aNk;
      toEnrich.push([
        aKey,                            // normalizedKey (name|city composite)
        row[RETNAME] || row[NAME],       // canonicalName
        'geo-enrich-reviewed',           // sheetName (provenance)
        row[PID],                        // placeId
        row[LAT], row[LNG],              // lat, lng
        row[PHOTO] || '',                // photoName
        row[ADDR] || '',                 // formattedAddress
        row[STATUS] || '',               // businessStatus
        new Date().toISOString().slice(0, 10) // lastVerified
      ]);
      accepted++;
    } else if (decision === 'REJECT') {
      rejected++;
      // dropped — not kept, not enriched
    } else {
      keepRows.push(row); // blank/other — leave for later
      left++;
    }
  }

  if (toEnrich.length) {
    var last = esheet.getLastRow();
    esheet.getRange(last + 1, 1, toEnrich.length, ENRICH_HEADERS.length).setValues(toEnrich);
  }

  // Rewrite the review tab with only the rows left undecided
  review.clear();
  review.getRange(1, 1, 1, REVIEW_HEADERS.length).setValues([REVIEW_HEADERS]).setFontWeight('bold');
  review.setFrozenRows(1);
  if (keepRows.length > 1) {
    review.getRange(2, 1, keepRows.length - 1, REVIEW_HEADERS.length)
      .setValues(keepRows.slice(1));
  }

  var msg =
    'Review decisions processed.\n' +
    'ACCEPT → Places Enrichment: ' + accepted + '\n' +
    'REJECT → dropped:           ' + rejected + '\n' +
    'left undecided (kept):      ' + left + '\n\n' +
    'NEXT: run reshapeCompassEats to graduate the accepted venues.';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// ── Pre-fill review decisions with smart suggestions ───────────────────────
// Scans enrichment_review and writes a SUGGESTION into the decision column:
//   ACCEPT?  — returned name strongly resembles the queried name (shared words
//              or one contains the other). Almost always the right venue that
//              only parked over a city-format quirk or a name-formatting diff.
//   REJECT?  — returned name shares NO words with the queried name.
//   (blank)  — ambiguous; partial overlap. Decide by hand.
// The "?" marks these as SUGGESTIONS. Scan them, fix any you disagree with,
// then run convertSuggestions() to finalize, then acceptReviewRows().
function suggestReviewDecisions() {
  var ss = SpreadsheetApp.getActive();
  var review = ss.getSheetByName(REVIEW_TAB);
  if (!review) throw new Error('No `' + REVIEW_TAB + '` tab.');
  var rv = review.getDataRange().getValues();
  if (rv.length < 2) { SpreadsheetApp.getUi().alert('Review tab is empty.'); return; }

  var NAME = 1, RETNAME = 3;
  var acc = 0, rej = 0, amb = 0;
  for (var i = 1; i < rv.length; i++) {
    var existing = String(rv[i][0] || '').trim();
    if (existing) continue; // don't overwrite a decision you've already made
    var qn = normKeyGeo_(rv[i][NAME]);
    var rn = normKeyGeo_(rv[i][RETNAME]);
    var sub = qn && rn && (qn.indexOf(rn) >= 0 || rn.indexOf(qn) >= 0);
    var ov = tokenOverlap_(qn, rn);
    var suggestion;
    if (sub || ov >= 0.5) { suggestion = 'ACCEPT?'; acc++; }
    else if (ov === 0)    { suggestion = 'REJECT?'; rej++; }
    else                  { suggestion = ''; amb++; }
    if (suggestion) review.getRange(i + 1, 1).setValue(suggestion);
  }

  var msg =
    'Suggestions written to the decision column:\n' +
    '  ACCEPT?  (strong name match): ' + acc + '\n' +
    '  REJECT?  (no shared words):   ' + rej + '\n' +
    '  left blank (ambiguous):       ' + amb + '\n\n' +
    'Scan & correct any you disagree with (especially same-chain different-branch\n' +
    'cases). Then run convertSuggestions(), then acceptReviewRows().';
  Logger.log(msg);
  SpreadsheetApp.getUi().alert(msg);
}

// Turns confirmed "ACCEPT?"/"REJECT?" suggestions into final decisions.
// Run AFTER you've scanned and fixed any suggestions you disagreed with.
function convertSuggestions() {
  var ss = SpreadsheetApp.getActive();
  var review = ss.getSheetByName(REVIEW_TAB);
  if (!review) throw new Error('No `' + REVIEW_TAB + '` tab.');
  var rv = review.getDataRange().getValues();
  var n = 0;
  for (var i = 1; i < rv.length; i++) {
    var d = String(rv[i][0] || '').trim();
    if (d === 'ACCEPT?') { review.getRange(i + 1, 1).setValue('ACCEPT'); n++; }
    else if (d === 'REJECT?') { review.getRange(i + 1, 1).setValue('REJECT'); n++; }
  }
  SpreadsheetApp.getUi().alert('Converted ' + n + ' suggestions to final decisions.\n' +
    'Now run acceptReviewRows().');
}

function tokenOverlap_(a, b) {
  var ta = a ? a.split(' ') : [], tb = b ? b.split(' ') : [];
  if (!ta.length || !tb.length) return 0;
  var setB = {}; for (var i = 0; i < tb.length; i++) setB[tb[i]] = true;
  var shared = 0, seen = {};
  for (var j = 0; j < ta.length; j++) {
    if (setB[ta[j]] && !seen[ta[j]]) { shared++; seen[ta[j]] = true; }
  }
  return shared / Math.min(ta.length, tb.length);
}

// ── Places lookup (UPDATED August 4, 2026 — cheap two-step version) ────────
// Step 1: Text Search, field mask `places.id` only. This is Google's IDs-only
// SKU — free/near-free — and just resolves the query to the best-matching
// place_id. Requesting fewer fields does NOT change which place Google picks
// as the top match, only what data comes back about it, so match quality is
// identical to the old single-call approach.
function placesTextSearchIdOnly_(query, key) {
  var url = 'https://places.googleapis.com/v1/places:searchText';
  var payload = { textQuery: query, maxResultCount: 1 };
  var resp;
  try {
    resp = UrlFetchApp.fetch(url, {
      method: 'post',
      contentType: 'application/json',
      payload: JSON.stringify(payload),
      muteHttpExceptions: true,
      headers: {
        'X-Goog-Api-Key': key,
        'X-Goog-FieldMask': 'places.id'
      }
    });
  } catch (e) {
    return null;
  }
  if (resp.getResponseCode() !== 200) return null;
  var data;
  try { data = JSON.parse(resp.getContentText()); } catch (e) { return null; }
  if (!data.places || !data.places.length) return null;
  return data.places[0].id || null;
}

// Step 2: Place Details, field mask limited to Basic Data — name, address,
// coordinates, business status. No photos, no ratings/reviews (those are
// Atmosphere-tier and bill much higher). Bills at the low Basic/Essentials
// tier, roughly $5/1,000 instead of the old $32–40/1,000.
function placeDetailsBasic_(placeId, key) {
  var url = 'https://places.googleapis.com/v1/places/' + encodeURIComponent(placeId);
  var fieldMask = 'id,displayName,formattedAddress,location,businessStatus';
  var resp;
  try {
    resp = UrlFetchApp.fetch(url, {
      method: 'get',
      muteHttpExceptions: true,
      headers: {
        'X-Goog-Api-Key': key,
        'X-Goog-FieldMask': fieldMask
      }
    });
  } catch (e) {
    return null;
  }
  if (resp.getResponseCode() !== 200) return null;
  var p;
  try { p = JSON.parse(resp.getContentText()); } catch (e) { return null; }
  if (!p || !p.id) return null;

  var loc = p.location || {};
  return {
    placeId: p.id || '',
    displayName: (p.displayName && p.displayName.text) ? p.displayName.text : '',
    lat: (loc.latitude !== undefined) ? loc.latitude : '',
    lng: (loc.longitude !== undefined) ? loc.longitude : '',
    address: p.formattedAddress || '',
    status: p.businessStatus || '',
    photoName: ''   // intentionally never fetched — see cost note at top of file
  };
}

// Combines the two cheap calls into the exact same shape the old single-call
// placesTextSearch_() used to return, so the rest of geoEnrich() needed no
// other changes. Returns null if either step fails or finds nothing.
function placesLookupCheap_(query, key) {
  var placeId = placesTextSearchIdOnly_(query, key);
  if (!placeId) return null;
  Utilities.sleep(CALL_DELAY_MS);
  return placeDetailsBasic_(placeId, key);
}

// ── helpers ──────────────────────────────────────────────────────────────
// normKeyGeo_ MUST mirror reshape.gs normKey_ so keys line up for matching.
function normKeyGeo_(name) {
  if (!name) return '';
  var s = String(name).normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  s = s.replace(/['\u2018\u2019\u02BC`]/g, '');           // apostrophes
  s = s.replace(/&/g, ' and ');                            // ampersand
  s = s.replace(/[\u00BC-\u00BE\u2150-\u215E]/g, '');      // fractions
  s = s.replace(/[\u00B2\u00B3\u00B9\u2070-\u2079]/g, ''); // superscripts
  s = s.replace(/[^a-z0-9]+/g, ' ');
  return s.replace(/\s+/g, ' ').trim();
}

function countRemaining_(av, ah, done) {
  var iName = ah['name'], iCity = ah['city'], iReason = ah['reason'];
  var n = 0;
  for (var i = 1; i < av.length; i++) {
    var reason = String(av[i][iReason] || '');
    if (reason.indexOf('no placeId') !== 0) continue;
    var name = String(av[i][iName] || '').trim();
    if (!name) continue;
    // Mirror the main loop's dedup key exactly (name|city composite) so the
    // "already done" count matches what geoEnrich will actually process.
    var ck = cityKey_(String(av[i][iCity] || '').trim());
    var key = ck ? (normKeyGeo_(name) + '|' + ck) : normKeyGeo_(name);
    if (!done[key]) n++;
  }
  return n;
}

function findSheetLooseGeo_(ss, wantName) {
  var want = String(wantName).toLowerCase().replace(/[''`]/g, '').replace(/\s+/g, ' ').trim();
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    var n = sheets[i].getName().toLowerCase().replace(/[''`]/g, '').replace(/\s+/g, ' ').trim();
    if (n === want) return sheets[i];
  }
  return null;
}
