/**
 * CompassEats — split/reattribute the 3 remaining identity-collision clones.
 * Clears the last 3 preflightPublish duplicate-key failures.
 *
 * SAFE BY DEFAULT: CONFIRM_LIVE_RUN = false runs a DRY RUN (writes nothing).
 * Review the log, then flip to true and run again to apply.
 * Only touches the 3 clone rows; the 3 correct originals are never matched.
 */
function splitIdentityCollisions() {
  const CONFIRM_LIVE_RUN = false;   // <-- leave false for the dry run

  const SHEET_ID = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
  const TAB = 'venues';

  const FIXES = [
    {
      label: 'River Cafe  ->  Brooklyn (New York)',
      identify: { slug: 'the-river-cafe', city_slug: 'london', neighborhood: 'Brooklyn' },
      set: {
        id: 'ChIJ2QZOdTpawokRU_eN_EPJaX8',
        city_slug: 'new-york',
        city_display: 'New York',
        lat: 40.7038342,
        lng: -73.9947936,
        address: '1 Water St, Brooklyn, NY 11201, USA',
        blurb_short: '',
        blurb_long: ''
      }
    },
    {
      label: 'MIURA  ->  Beverly Hills (Los Angeles)',
      identify: { slug: 'miura-hotel', city_slug: 'celadna', neighborhood: 'Beverly Hills' },
      set: {
        id: 'ChIJ_5ydTHu7woARcQmby2lfPME',
        slug: 'miura',
        city_slug: 'los-angeles',
        city_display: 'Los Angeles',
        lat: 34.0674249,
        lng: -118.4006047,
        address: '218 N Rodeo Dr #2f, Beverly Hills, CA 90210, USA',
        cuisine_tags: 'Japanese',
        blurb_short: '',
        blurb_long: ''
      }
    },
    {
      label: "AMANO clone  ->  A'mano, Christchurch (reattribution)",
      identify: { slug: 'amano-mexican', city_slug: 'caldwell', country: 'New Zealand' },
      set: {
        id: 'ChIJffZqR9qJMW0RRCM_iqQBkxI',
        slug: 'amano',
        name: "A'mano",
        city_slug: 'christchurch',
        city_display: 'Christchurch',
        lat: -43.534326,
        lng: 172.6419482,
        address: '6/150 Lichfield Street, Christchurch 8011, New Zealand',
        cuisine_tags: 'Italian',
        blurb_short: '',
        blurb_long: ''
      }
    }
  ];

  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sheet = ss.getSheetByName(TAB);
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  function col(name) { return headers.indexOf(name); }

  const cSlug = col('slug');
  const cCity = col('city_slug');

  // Every referenced column must exist
  const needed = {};
  FIXES.forEach(function(f){
    Object.keys(f.identify).forEach(function(k){ needed[k] = true; });
    Object.keys(f.set).forEach(function(k){ needed[k] = true; });
  });
  const missing = Object.keys(needed).filter(function(k){ return col(k) === -1; });
  if (missing.length) { Logger.log('ABORT — missing columns: ' + missing.join(', ')); return; }

  // Count every existing city_slug/slug key (for collision check)
  const keyCount = {};
  for (var r = 1; r < data.length; r++) {
    var k = String(data[r][cCity]).trim() + '/' + String(data[r][cSlug]).trim();
    keyCount[k] = (keyCount[k] || 0) + 1;
  }

  Logger.log(CONFIRM_LIVE_RUN ? '### LIVE RUN — writing changes ###' : '### DRY RUN — writing nothing ###');
  Logger.log('');

  var planned = [], blocked = 0;

  FIXES.forEach(function(fix) {
    var matches = [];
    for (var r = 1; r < data.length; r++) {
      var ok = true;
      for (var field in fix.identify) {
        if (String(data[r][col(field)]).trim() !== String(fix.identify[field]).trim()) { ok = false; break; }
      }
      if (ok) matches.push(r);
    }

    Logger.log('=================================================');
    Logger.log('FIX: ' + fix.label);

    if (matches.length !== 1) {
      Logger.log('  !! Expected exactly 1 matching row, found ' + matches.length + ' — SKIPPING.');
      blocked++; Logger.log(''); return;
    }

    var rowIdx = matches[0], sheetRow = rowIdx + 1;
    var newCity = fix.set.city_slug !== undefined ? fix.set.city_slug : String(data[rowIdx][cCity]).trim();
    var newSlug = fix.set.slug !== undefined ? fix.set.slug : String(data[rowIdx][cSlug]).trim();
    var oldKey = String(data[rowIdx][cCity]).trim() + '/' + String(data[rowIdx][cSlug]).trim();
    var newKey = newCity + '/' + newSlug;

    Logger.log('  Sheet row: ' + sheetRow);
    Logger.log('  Key: ' + oldKey + '   ->   ' + newKey);

    var conflict = (keyCount[newKey] || 0) - (newKey === oldKey ? 1 : 0);
    if (conflict > 0) {
      Logger.log('  !! BLOCKED — ' + conflict + ' other row(s) already use "' + newKey + '". Not applying.');
      blocked++; Logger.log(''); return;
    }

    Logger.log('  Changes:');
    for (var f in fix.set) {
      var ci = col(f), before = data[rowIdx][ci], after = fix.set[f];
      var b = (before === '' || before === null) ? '(empty)' : String(before);
      var a = (after === '' || after === null) ? '(blank it)' : String(after);
      if (String(before) !== String(after)) {
        Logger.log('     ' + f + ':  ' + trunc(b) + '   ->   ' + trunc(a));
      }
    }
    planned.push({ fix: fix, sheetRow: sheetRow });
    Logger.log('');
  });

  Logger.log('=================================================');
  Logger.log('Summary: ' + planned.length + ' fix(es) ready, ' + blocked + ' blocked/skipped.');
  Logger.log('');

  if (!CONFIRM_LIVE_RUN) {
    Logger.log('DRY RUN complete. Nothing was written.');
    Logger.log('If the 3 fixes look right, set CONFIRM_LIVE_RUN = true and run again.');
    return;
  }

  planned.forEach(function(p) {
    for (var f in p.fix.set) {
      sheet.getRange(p.sheetRow, col(f) + 1).setValue(p.fix.set[f]);
    }
    Logger.log('APPLIED row ' + p.sheetRow + ' — ' + p.fix.label);
  });
  Logger.log('');
  Logger.log('### LIVE RUN complete — ' + planned.length + ' row(s) updated. ###');
  Logger.log('Set CONFIRM_LIVE_RUN back to false, then run preflightPublish.');
}

function trunc(s) { s = String(s); return s.length > 80 ? s.substring(0, 77) + '...' : s; }
