/****************************************************************************************
 * CompassEats — Blurb Generator (compasseats-blurbs.gs)
 * --------------------------------------------------------------------------------------
 * Generates blurb_short / blurb_long for venues in the `venues` tab using the Anthropic
 * API, with three voice templates chosen automatically per venue:
 *
 *   Tier 1 (rich)      — famous venues; may use real known detail. ~1,272 venues.
 *   Tier 2 (grounded)  — long-tail restaurants; STRICT no-invention. ~7,954 venues.
 *   Bars               — accolade-first, long blurb only.
 *
 * HOW TO USE  (step by step — no coding needed):
 *   1.  Open your Google Sheet → Extensions → Apps Script.
 *   2.  Click the + next to "Files", choose "Script", name it  compasseats-blurbs
 *   3.  Delete the sample code in it, paste THIS entire file in, click the save icon.
 *   4.  Get an Anthropic API key from console.anthropic.com (Settings → API Keys).
 *   5.  In Apps Script left menu click the gear (Project Settings) → scroll to
 *       "Script Properties" → Add script property:
 *            Property:  ANTHROPIC_API_KEY      Value:  (paste your key)
 *       Click "Save script properties".
 *   6.  Back in the editor, pick the function  testTenBlurbs  from the dropdown at top,
 *       click "Run". First run asks permission — click through Allow.
 *   7.  It writes 10 sample blurbs to a NEW tab called  Blurb Test  so it never touches
 *       your live `venues` data. Read them there, tell Claude what to tune.
 *
 *   When the voice is locked, run  generateAllBlurbs  to fill the real `venues` tab in
 *   safe batches (it picks up where it left off and can be re-run).
 ****************************************************************************************/

// ----- CONFIG ---------------------------------------------------------------
var MODEL          = 'claude-sonnet-4-5-20250929'; // good quality/cost for prose
var BATCH_SIZE     = 25;        // venues per run of generateAllBlurbs (Sheets has a 6-min limit)
var SHEET_VENUES   = 'venues';
var SHEET_TEST     = 'Blurb Test';
var COL_BY_NAME    = {};        // filled at runtime

// ----- THE THREE TEMPLATES --------------------------------------------------
// Edit the wording here if Claude suggests tuning. {placeholders} are filled per venue.

var T_BANNED = 'Never use these words/phrases: curated, top 10, users rated, hidden gem, ' +
               'nestled, tucked away, boasts, eatery, foodie. Spell Michelin as ' +
               '"two/three Michelin stars" in words, never star glyphs.';

var T_VOCAB  = 'Use this vocabulary naturally where it fits: charted, point you to, ' +
               'worth the detour, roam, worth building a night around.';

var T_VOCAB_NOTE = 'The signature vocabulary (charted, point you to, worth the detour, roam) ' +
               'is seasoning, not filler — at most one, only where it lands naturally.';

function promptTier1(v) {
  return 'You are writing for CompassEats, a restaurant and bar guide with the voice of a ' +
    'well-traveled friend who always knows the spot — warm, confident, effortless, never salesy.\n\n' +
    'Write about ' + v.name + ' in ' + v.city + (v.country ? ', ' + v.country : '') +
    '. Type: ' + v.type + (v.cuisine ? '. Cuisine: ' + v.cuisine : '') + '.\n' +
    'Its accolades: ' + v.awards + '\n\n' +
    'This is a celebrated venue, written to feel premium. Write a SHORT blurb (about 15 words) ' +
    'and a LONG blurb (about 55-75 words) that make a reader want to go.\n\n' +
    'ABSOLUTE RULE — do not state any of the following, because you cannot verify them and must not ' +
    'guess: (1) the name of any chef, owner, or person; (2) the name of any specific dish, drink, or ' +
    'menu item; (3) any physical/setting detail (views, gardens, the room, decor, location specifics ' +
    'like "above the port"); (4) any number you were not given (course counts, acreage, years in ' +
    'business, seat counts). If you are even slightly unsure a detail is true of THIS EXACT venue, ' +
    'leave it out. A warm, slightly general blurb is the goal; one invented fact is a failure.\n\n' +
    'Build the blurb from only: the city and country, the kind of cuisine, and the prestige of the ' +
    'recognition (worded as trust, not a list). You may speak generally about ambition, seasonality, ' +
    'and craft in the abstract, but never assert a concrete unverifiable fact.\n\n' +
    'STYLE DISCIPLINE (important — avoids a robotic, repetitive feel across many venues):\n' +
    '- The FIRST sentence must lead with the city, the country, or the cuisine — a real anchor. ' +
    'Do NOT open with "This is the kind of place…", "When you…", or any generic frame.\n' +
    '- Do NOT use the construction "[City]\'s most celebrated table/kitchen/restaurant" or any close ' +
    'variant ("most celebrated", "most renowned", "standard-bearer", "finest table"). It has become ' +
    'a formula. Vary the GRAMMATICAL SHAPE of the opener between venues — sometimes a place, sometimes ' +
    'the cuisine, sometimes the dish-type, sometimes a plain declarative about the city. No two should ' +
    'feel stamped from the same mold.\n' +
    '- Use AT MOST ONE of these signature phrases in the whole blurb, and only if it fits naturally: ' +
    'charted, point you to, worth the detour, worth building a night around, roam. Never stack them.\n' +
    '- Do not pile up intensifiers ("worth the detour, worth the occasion, worth every bit…"). ' +
    'Say it once, with confidence.\n' +
    '- Treat the cuisine as CONTEXT to describe naturally, never a label to print verbatim. ' +
    'Write "creative cooking" or "a modern grill", not "a Contemporary restaurant" or "Creative cuisine".\n\n' +
    T_VOCAB_NOTE + ' ' + T_BANNED + '\n\n' +
    'Return ONLY raw JSON, no markdown, no backticks: {"blurb_short":"...","blurb_long":"..."}';
}

function promptTier2(v) {
  return 'You are writing for CompassEats, a guide with the voice of a well-traveled friend — ' +
    'warm, confident, effortless.\n\n' +
    'Write about ' + v.name + ' in ' + v.city + (v.country ? ', ' + v.country : '') +
    (v.cuisine ? '. Cuisine: ' + v.cuisine : '') + '.\n' +
    'Its accolades: ' + v.awards + '\n\n' +
    'CRITICAL: You know NOTHING about this specific venue beyond the facts above. Do NOT invent a ' +
    'chef, a dish, a room, decor, a history, a view, or an atmosphere. Every word must be true given ' +
    'ONLY the city, the cuisine, and the accolades. If you find yourself reaching for a concrete ' +
    'detail, stop — you do not have it.\n\n' +
    'Build warmth from PLACE and CUISINE, not invention: where it is, what kind of cooking it does, ' +
    'and the trust of its recognition. Do not read as a list of awards — weave the recognition in ' +
    'naturally as the reason to trust the pick. Write a SHORT blurb (about 15 words) and a LONG ' +
    'blurb (about 40-55 words).\n\n' +
    T_VOCAB + ' ' + T_BANNED + '\n\n' +
    'Return ONLY raw JSON, no markdown, no backticks: {"blurb_short":"...","blurb_long":"..."}';
}

function promptBar(v) {
  return 'You are writing for CompassEats, a guide with the voice of a well-traveled friend.\n\n' +
    'Write about the BAR ' + v.name + ' in ' + v.city + (v.country ? ', ' + v.country : '') + '.\n' +
    'Its accolades: ' + v.awards + '\n\n' +
    'A top-ranked bar is a reliable bet — the ranking IS the recommendation. Lead with the accolade ' +
    'as the reason to go, then make it inviting. Do NOT invent signature drinks, the room, or ' +
    'atmosphere — you do not know them. Keep it to the ranking, the city, and genuine warmth.\n\n' +
    'Write ONLY a long blurb (about 35-50 words). Leave the short blurb empty.\n\n' +
    T_VOCAB + ' ' + T_BANNED + '\n\n' +
    'Return ONLY raw JSON, no markdown, no backticks: {"blurb_short":"","blurb_long":"..."}';
}

// ----- TIER ROUTING (mirrors the agreed definition) -------------------------
function pickTemplate(v) {
  if (v.type === 'bar') return { tier: 'bar', prompt: promptBar(v) };
  if (isTier1(v))       return { tier: 'rich', prompt: promptTier1(v) };
  return                       { tier: 'grounded', prompt: promptTier2(v) };
}

function isTier1(v) {
  var aw = v.awardsArr || [];
  if (aw.length >= 6) return true;                       // most-accoladed safety net
  for (var i = 0; i < aw.length; i++) {
    var s = aw[i].source, cat = (aw[i].category || ''), rank = aw[i].rank;
    if (s === 'michelin' && (cat.indexOf('Three') > -1 || cat.indexOf('Two') > -1)) return true;
    if (s === 'best-chef-awards' && cat.charAt(0) === '3') return true;
    if (s === 'la-liste' && rank && rank <= 100) return true;
    if (s === 'worlds-50-best-restaurants' || s === 'worlds-50-best-bars') return true; // full 50
    if (s.indexOf('oad') === 0 && rank && rank <= 50) return true;
    if (s.indexOf('50-best') > -1 && s.indexOf('worlds') === -1 && rank && rank <= 10) return true;
  }
  return false;
}

// ----- SHEET HELPERS --------------------------------------------------------
function getVenuesSheet_() {
  var sh = SpreadsheetApp.getActive().getSheetByName(SHEET_VENUES);
  if (!sh) throw new Error('No "' + SHEET_VENUES + '" tab found.');
  return sh;
}

function readHeader_(sh) {
  var hdr = sh.getRange(1, 1, 1, sh.getLastColumn()).getValues()[0];
  COL_BY_NAME = {};
  for (var i = 0; i < hdr.length; i++) COL_BY_NAME[hdr[i]] = i;
  ['name','city_display','country','type','cuisine_tags','awards_json',
   'blurb_short','blurb_long'].forEach(function(c){
    if (COL_BY_NAME[c] === undefined) throw new Error('Missing column: ' + c);
  });
}

function rowToVenue_(row) {
  var awardsArr = [];
  try { awardsArr = JSON.parse(row[COL_BY_NAME['awards_json']] || '[]'); } catch (e) {}
  return {
    name:       row[COL_BY_NAME['name']],
    city:       row[COL_BY_NAME['city_display']],
    country:    row[COL_BY_NAME['country']],
    type:       row[COL_BY_NAME['type']],
    cuisine:    row[COL_BY_NAME['cuisine_tags']],
    awards:     awardsToProse_(awardsArr),
    awardsArr:  awardsArr
  };
}

// Turn the raw awards JSON into a clean human string for the prompt (newest year per source).
function awardsToProse_(arr) {
  if (!arr || !arr.length) return '(none on file)';
  var bySource = {};
  arr.forEach(function(a){
    var k = a.source;
    if (!bySource[k] || (a.year || 0) > (bySource[k].year || 0)) bySource[k] = a;
    // track count of years for longevity hints
    bySource[k]._years = (bySource[k]._years || 0) + 1;
  });
  var parts = [];
  for (var k in bySource) {
    var a = bySource[k];
    var label = a.source + (a.category ? ' (' + a.category + ')' : '') +
                (a._years > 1 ? ', ' + a._years + ' years' : '') +
                (a.year ? ', most recent ' + a.year : '');
    parts.push(label);
  }
  return parts.join('; ');
}

// ----- ANTHROPIC CALL -------------------------------------------------------
function callClaude_(prompt) {
  var key = PropertiesService.getScriptProperties().getProperty('ANTHROPIC_API_KEY');
  if (!key) throw new Error('Set ANTHROPIC_API_KEY in Project Settings → Script Properties.');
  var payload = {
    model: MODEL,
    max_tokens: 400,
    messages: [{ role: 'user', content: prompt }]
  };
  var res = UrlFetchApp.fetch('https://api.anthropic.com/v1/messages', {
    method: 'post',
    contentType: 'application/json',
    headers: { 'x-api-key': key, 'anthropic-version': '2023-06-01' },
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  });
  var code = res.getResponseCode();
  var body = res.getContentText();
  if (code !== 200) throw new Error('API ' + code + ': ' + body);
  var data = JSON.parse(body);
  var text = (data.content || []).filter(function(b){return b.type==='text';})
                                 .map(function(b){return b.text;}).join('');
  text = text.replace(/```json/gi,'').replace(/```/g,'').trim();
  return JSON.parse(text); // {blurb_short, blurb_long}
}

// ----- PUBLIC: RICH-TIER-ONLY RE-TEST ---------------------------------------
// Cheap focused pass — just the distinct rich venues that showed the verbal tic.
// Writes to the same "Blurb Test" tab so you can compare against the last run.
function testRichOnly() {
  var sh = getVenuesSheet_();
  readHeader_(sh);
  var values = sh.getRange(2, 1, sh.getLastRow()-1, sh.getLastColumn()).getValues();
  var wanted = ['Piazza Duomo','Zilte','Grand Hotel Les Trois Rois',
                'SingleThread Farm - Restaurant - Inn','Don Julio Parrilla','Le Clos Des Sens'];
  var picks = [];
  values.forEach(function(r){
    if (wanted.indexOf(r[COL_BY_NAME['name']]) > -1) picks.push(r);
  });

  var out = [['tier','name','city','type','blurb_short','blurb_long']];
  picks.forEach(function(r){
    var v = rowToVenue_(r);
    var t = pickTemplate(v);
    try {
      var b = callClaude_(t.prompt);
      out.push([t.tier, v.name, v.city, v.type, b.blurb_short || '', b.blurb_long || '']);
    } catch (e) {
      out.push([t.tier, v.name, v.city, v.type, 'ERROR', String(e)]);
    }
    Utilities.sleep(600);
  });

  var test = SpreadsheetApp.getActive().getSheetByName(SHEET_TEST)
          || SpreadsheetApp.getActive().insertSheet(SHEET_TEST);
  test.clear();
  test.getRange(1,1,out.length,out[0].length).setValues(out);
  test.setFrozenRows(1);
  Logger.log('Rich re-test done — see the "' + SHEET_TEST + '" tab.');
}

// ----- PUBLIC: 10-VENUE TEST ------------------------------------------------
// Writes to a separate "Blurb Test" tab. Never edits live data.
function testTenBlurbs() {
  var sh = getVenuesSheet_();
  readHeader_(sh);
  var values = sh.getRange(2, 1, sh.getLastColumn() ? sh.getLastRow()-1 : 0, sh.getLastColumn()).getValues();

  // Deliberately varied + long-tail-heavy picks (by name match; falls back to first N if absent)
  var wanted = ['Le Clos Des Sens','Madeo Restaurant','LA TABLE DES AMIS - BONNIEUX',
                'Grand Hotel Les Trois Rois','Don Julio Parrilla','Zilte','Piazza Duomo',
                'SingleThread Farm - Restaurant - Inn','Sastrería Martinez, Bar oculto'];
  var picks = [];
  values.forEach(function(r){
    if (wanted.indexOf(r[COL_BY_NAME['name']]) > -1) picks.push(r);
  });
  // pad to 10 with the first rows that have awards, so we always get a full sample
  for (var i = 0; i < values.length && picks.length < 10; i++) {
    if (picks.indexOf(values[i]) === -1 && values[i][COL_BY_NAME['awards_json']]) picks.push(values[i]);
  }

  var out = [['tier','name','city','type','blurb_short','blurb_long']];
  picks.slice(0,10).forEach(function(r){
    var v = rowToVenue_(r);
    var t = pickTemplate(v);
    try {
      var b = callClaude_(t.prompt);
      out.push([t.tier, v.name, v.city, v.type, b.blurb_short || '', b.blurb_long || '']);
    } catch (e) {
      out.push([t.tier, v.name, v.city, v.type, 'ERROR', String(e)]);
    }
    Utilities.sleep(600);
  });

  var test = SpreadsheetApp.getActive().getSheetByName(SHEET_TEST)
          || SpreadsheetApp.getActive().insertSheet(SHEET_TEST);
  test.clear();
  test.getRange(1,1,out.length,out[0].length).setValues(out);
  test.setFrozenRows(1);
  Logger.log('Done — see the "' + SHEET_TEST + '" tab.');
}

// ----- PUBLIC: FULL RUN (safe, resumable, batched) --------------------------
// Run repeatedly. Each run fills up to BATCH_SIZE venues that are still blank.
function generateAllBlurbs() {
  var sh = getVenuesSheet_();
  readHeader_(sh);
  var last = sh.getLastRow();
  if (last < 2) return;
  var rng = sh.getRange(2, 1, last-1, sh.getLastColumn());
  var values = rng.getValues();

  var done = 0;
  for (var i = 0; i < values.length && done < BATCH_SIZE; i++) {
    var r = values[i];
    var isBar = r[COL_BY_NAME['type']] === 'bar';
    var hasLong  = !!r[COL_BY_NAME['blurb_long']];
    if (hasLong) continue;                 // already done — skip (resumable)
    if (!r[COL_BY_NAME['awards_json']]) continue; // no accolade, not charted, skip

    var v = rowToVenue_(r);
    var t = pickTemplate(v);
    try {
      var b = callClaude_(t.prompt);
      r[COL_BY_NAME['blurb_short']] = isBar ? '' : (b.blurb_short || '');
      r[COL_BY_NAME['blurb_long']]  = b.blurb_long || '';
      done++;
    } catch (e) {
      // leave blank, will retry next run; log to see in Executions
      Logger.log('Failed ' + v.name + ': ' + e);
    }
    Utilities.sleep(600);
  }
  rng.setValues(values);
  Logger.log('Filled ' + done + ' blurbs this run. Re-run to continue.');
}// ----- STAGE 1: EXPORT venues that need blurbs (for the Batch API run) -------
function exportVenuesForBatch() {
  var sh = getVenuesSheet_();
  readHeader_(sh);
  var last = sh.getLastRow();
  var values = sh.getRange(2, 1, last - 1, sh.getLastColumn()).getValues();

  var out = [];
  values.forEach(function(r) {
    if (r[COL_BY_NAME['blurb_long']]) return;        // already has a blurb — skip
    if (!r[COL_BY_NAME['awards_json']]) return;      // no accolade — not charted, skip
    var v = rowToVenue_(r);
    out.push({
      slug:    r[COL_BY_NAME['slug']] || '',
      name:    v.name,
      city:    v.city,
      country: v.country,
      type:    v.type,
      cuisine: v.cuisine,
      awards:  v.awards,
      tier:    pickTemplate(v).tier
    });
  });

  var json = JSON.stringify(out, null, 0);
  var blob = Utilities.newBlob(json, 'application/json', 'venues_for_batch.json');
  var file = DriveApp.createFile(blob);
  Logger.log(
    'Exported ' + out.length + ' venues.\n' +
    'A file named "venues_for_batch.json" is now in your Google Drive (top level).\n' +
    'Download it from Drive to your Mac\'s Downloads folder for the next stage.'
  );
}// ----- STAGE 5: IMPORT finished blurbs from blurbs_final.csv in Drive --------
function importBlurbsFromDrive() {
  var files = DriveApp.getFilesByName('blurbs_final.csv');
  if (!files.hasNext()) throw new Error('blurbs_final.csv not found in Drive.');
  var csv = files.next().getBlob().getDataAsString();
  var data = Utilities.parseCsv(csv);
  // build slug -> {short, long}
  var map = {};
  for (var i = 1; i < data.length; i++) {
    map[data[i][0]] = { s: data[i][1], l: data[i][2] };
  }

  var sh = getVenuesSheet_();
  readHeader_(sh);
  var last = sh.getLastRow();
  var rng = sh.getRange(2, 1, last - 1, sh.getLastColumn());
  var values = rng.getValues();

  var filled = 0;
  for (var r = 0; r < values.length; r++) {
    var slug = values[r][COL_BY_NAME['slug']];
    var m = map[slug];
    if (!m) continue;
    if (m.s) values[r][COL_BY_NAME['blurb_short']] = m.s;
    if (m.l) values[r][COL_BY_NAME['blurb_long']]  = m.l;
    filled++;
  }
  rng.setValues(values);
  Logger.log('Filled blurbs on ' + filled + ' venue rows.');
}
