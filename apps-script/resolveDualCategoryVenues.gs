/**
 * resolveDualCategoryVenues.gs
 * ----------------------------------------------------------------------------
 * Post-reshape cleanup for the handful of venues that are notable as BOTH a
 * restaurant AND a cocktail bar, and therefore get emitted as two rows
 * (a base slug + a "-2" slug) that mergeDuplicateVenues correctly refuses to
 * collapse (because collapsing would lose one side's accolades).
 *
 * Run this RIGHT AFTER mergeDuplicateVenues, every publish. It is idempotent
 * (safe to run twice) and only ever touches the explicitly-listed venues below.
 *
 * Two behaviours:
 *   SPLIT  -> keep two listings. Restaurant listing keeps the clean base slug;
 *             the second row becomes "<base>-bar" typed 'bar'. Every award is
 *             re-routed to the correct side by its award family, so mis-filed
 *             awards get fixed automatically.
 *   MERGE  -> collapse to one listing. Keep the clean base-slug row, set its
 *             type to the chosen primary, union both rows' awards, delete the
 *             other row.
 *
 * SAFETY: leave DRY_RUN = true for the first run. It changes nothing and logs
 * exactly what it WOULD do. Read the log, confirm, then set DRY_RUN = false.
 * ----------------------------------------------------------------------------
 */

var DUALCAT_DRY_RUN = true;                 // <-- flip to false only after you've read the preview log
var DUALCAT_SPREADSHEET_ID = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
var DUALCAT_SHEET_NAME = 'venues';

/** SPLIT: one physical venue, two real listings (restaurant + bar). */
var DUALCAT_SPLIT = [
  { name: 'Moebius Milano',          city: 'Milan',       base: 'moebius-milano' },
  { name: 'Zuma Dubai',              city: 'Dubai',       base: 'zuma-dubai' },
  { name: "Duddell's",               city: 'Hong Kong',   base: 'duddell-s' },
  { name: 'Lobster Bar and Grill',   city: 'Hong Kong',   base: 'lobster-bar-and-grill' },
  { name: 'CAAA by Pietro Catalano', city: 'Lucerne',     base: 'caaa-by-pietro-catalano' },
  { name: 'Mesa by José Avillez',    city: 'Macau',       base: 'mesa-by-jose-avillez' }
];

/** MERGE: really one listing; keep clean slug, set primary type, union awards. */
var DUALCAT_MERGE = [
  { name: 'French 75 Bar',           city: 'New Orleans', base: 'french-75-bar',           primary: 'bar' },
  { name: 'Identidad Cocktail Bar',  city: 'San Juan',    base: 'identidad-cocktail-bar',  primary: 'bar' },
  { name: 'Bar Les Ambassadeurs',    city: 'Paris',       base: 'bar-les-ambassadeurs',    primary: 'bar' },
  { name: 'Compère Lapin',           city: 'New Orleans', base: 'compere-lapin',           primary: 'restaurant' },
  { name: 'Keens Steakhouse',        city: 'New York',    base: 'keens-steakhouse',        primary: 'restaurant' },
  { name: 'Aman Venice',             city: 'Venice',      base: 'aman-venice',             primary: 'restaurant' },
  { name: 'Restaurant Kronenhalle',  city: 'Zürich',      base: 'restaurant-kronenhalle',  primary: 'restaurant' }
];

/** Classify an award as belonging to the 'bar' or 'restaurant' side. */
function dualcat_awardFamily_(a) {
  var src = String(a.source || '').toLowerCase();
  var cat = String(a.category || '').toLowerCase();
  if (src.indexOf('best-bars') !== -1) return 'bar';              // *-50-best-bars, incl. 51-100 editions
  if (src === 'top-500-bars' || src === 'pinnacle-guide' || src === 'spirited-awards') return 'bar';
  if (src === 'james-beard' && cat.indexOf('bar') !== -1) return 'bar'; // e.g. "Outstanding Bar Program", "Best New Bar"
  return 'restaurant';
}

function dualcat_parseAwards_(s) {
  if (!s) return [];
  try { var v = JSON.parse(s); return Array.isArray(v) ? v : []; }
  catch (e) { Logger.log('  ! could not parse awards_json: ' + s); return []; }
}

function dualcat_sig_(a) {
  return [a.source, a.year, a.category, (a.rank == null ? '' : a.rank)].join('|');
}

function dualcat_union_(listA, listB) {
  var seen = {}, out = [];
  listA.concat(listB).forEach(function (a) {
    var k = dualcat_sig_(a);
    if (!seen[k]) { seen[k] = true; out.push(a); }
  });
  return out;
}

function dualcat_norm_(s) { return String(s == null ? '' : s).trim().toLowerCase(); }

function resolveDualCategoryVenues() {
  var ss = SpreadsheetApp.openById(DUALCAT_SPREADSHEET_ID);
  var sh = ss.getSheetByName(DUALCAT_SHEET_NAME);
  if (!sh) { Logger.log('ABORT: sheet "' + DUALCAT_SHEET_NAME + '" not found.'); return; }

  var rng = sh.getDataRange();
  var values = rng.getValues();
  var header = values[0];
  var col = {};
  header.forEach(function (h, i) { col[String(h).trim()] = i; });
  ['slug', 'name', 'city_display', 'type', 'awards_json'].forEach(function (c) {
    if (col[c] === undefined) { throw new Error('Missing expected column: ' + c); }
  });

  // Index data rows (skip header) by name|city.
  var byKey = {};
  for (var r = 1; r < values.length; r++) {
    var row = values[r];
    var key = dualcat_norm_(row[col.name]) + '||' + dualcat_norm_(row[col.city_display]);
    (byKey[key] = byKey[key] || []).push(r); // store 0-based index into `values`
  }

  var rowsToDelete = [];   // 0-based indices into `values`
  var writes = [];         // { r, c, value }
  var log = [];

  function findGroup(cfg) {
    var key = dualcat_norm_(cfg.name) + '||' + dualcat_norm_(cfg.city);
    return (byKey[key] || []).slice();
  }

  // ---- SPLIT ----
  DUALCAT_SPLIT.forEach(function (cfg) {
    var idxs = findGroup(cfg);
    if (idxs.length === 0) { log.push('SKIP (no match): ' + cfg.name + ' / ' + cfg.city); return; }

    // restaurant row = the one whose slug is exactly the base; bar row = the other.
    var restIdx = null, barIdx = null;
    idxs.forEach(function (i) {
      if (String(values[i][col.slug]).trim() === cfg.base) restIdx = i; else barIdx = i;
    });
    if (restIdx === null || barIdx === null) {
      log.push('SKIP (need exactly base + one other row): ' + cfg.name + ' -> slugs ' +
        idxs.map(function (i) { return values[i][col.slug]; }).join(', '));
      return;
    }

    // Gather ALL awards from both rows, then route by family.
    var all = dualcat_parseAwards_(values[restIdx][col.awards_json])
      .concat(dualcat_parseAwards_(values[barIdx][col.awards_json]));
    var restAwards = [], barAwards = [];
    all.forEach(function (a) {
      (dualcat_awardFamily_(a) === 'bar' ? barAwards : restAwards).push(a);
    });
    restAwards = dualcat_union_(restAwards, []);
    barAwards = dualcat_union_(barAwards, []);

    if (restAwards.length === 0 || barAwards.length === 0) {
      log.push('WARN (one side has no awards after routing, LEAVING UNTOUCHED): ' + cfg.name +
        ' rest=' + restAwards.length + ' bar=' + barAwards.length);
      return;
    }

    var barSlug = cfg.base + '-bar';
    writes.push({ r: restIdx, c: col.type, value: 'restaurant' });
    writes.push({ r: restIdx, c: col.awards_json, value: JSON.stringify(restAwards) });
    writes.push({ r: barIdx, c: col.slug, value: barSlug });
    writes.push({ r: barIdx, c: col.type, value: 'bar' });
    writes.push({ r: barIdx, c: col.awards_json, value: JSON.stringify(barAwards) });

    log.push('SPLIT: ' + cfg.name + ' (' + cfg.city + ')  restaurant[' + cfg.base + ']=' +
      restAwards.length + ' awards | bar[' + barSlug + ']=' + barAwards.length + ' awards');
  });

  // ---- MERGE ----
  DUALCAT_MERGE.forEach(function (cfg) {
    var idxs = findGroup(cfg);
    if (idxs.length === 0) { log.push('SKIP (no match): ' + cfg.name + ' / ' + cfg.city); return; }
    if (idxs.length === 1) { log.push('OK (already merged): ' + cfg.name); 
      // still enforce type on the survivor
      writes.push({ r: idxs[0], c: col.type, value: cfg.primary });
      return;
    }

    var keepIdx = null, dropIdx = null;
    idxs.forEach(function (i) {
      if (String(values[i][col.slug]).trim() === cfg.base) keepIdx = i; else dropIdx = i;
    });
    if (keepIdx === null) { // no clean base slug present; keep the first, drop the rest
      keepIdx = idxs[0]; dropIdx = idxs[1];
    }

    var merged = dualcat_union_(
      dualcat_parseAwards_(values[keepIdx][col.awards_json]),
      dualcat_parseAwards_(values[dropIdx][col.awards_json])
    );
    writes.push({ r: keepIdx, c: col.type, value: cfg.primary });
    writes.push({ r: keepIdx, c: col.awards_json, value: JSON.stringify(merged) });
    rowsToDelete.push(dropIdx);

    log.push('MERGE: ' + cfg.name + ' (' + cfg.city + ')  keep[' + cfg.base + '] type=' +
      cfg.primary + ' awards=' + merged.length + '  drop slug=' + values[dropIdx][col.slug]);
  });

  // ---- report / apply ----
  Logger.log('=== resolveDualCategoryVenues ' + (DUALCAT_DRY_RUN ? '(DRY RUN — no changes written)' : '(LIVE)') + ' ===');
  log.forEach(function (l) { Logger.log(l); });
  Logger.log('Cell updates: ' + writes.length + ' | rows to delete: ' + rowsToDelete.length);

  if (DUALCAT_DRY_RUN) { Logger.log('DRY RUN complete. Set DUALCAT_DRY_RUN = false to apply.'); return; }

  // Apply cell writes first (indices still valid because we delete afterwards).
  writes.forEach(function (w) {
    sh.getRange(w.r + 1, w.c + 1).setValue(w.value); // +1: sheet is 1-based
  });
  // Delete rows bottom-up so indices don't shift.
  rowsToDelete.sort(function (a, b) { return b - a; }).forEach(function (i) {
    sh.deleteRow(i + 1);
  });
  Logger.log('Applied. ' + writes.length + ' cells updated, ' + rowsToDelete.length + ' rows deleted.');
}
