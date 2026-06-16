/**
 * CompassEats — Enrichment Audit  (REPLACES compasseats-audit-unmatched.gs)
 * =========================================================================
 * Reads the `needs_enrichment` tab (produced by reshape.gs) and writes a
 * triage-ready `enrichment_audit` tab, sorted by award prestige so you fix
 * the highest-impact venues first.
 *
 * UPDATED June 3, 2026:
 *   PRESTIGE table expanded to cover every source now live in the pipeline
 *   (regional 50 Best bars & restaurants, the 51–100 extensions, La Liste,
 *   Gault & Millau, Tabelog, Forbes). Previously these all fell back to
 *   weight 1 and sorted as low as an unranked listing, so high-value new
 *   venues (e.g. a La Liste 99.5/100) didn't float to the top of the queue.
 *   shortenSource_ extended so the new sources display compactly.
 *
 * WHY THIS REPLACES THE OLD AUDIT
 *   The old script tried to re-match award rows against `venues` using a
 *   different slug logic than reshape. Reshape doesn't match award rows
 *   against `venues` at all — it groups rows into venues by name, then
 *   looks up geo in `Places Enrichment`. So the right audit target is
 *   the rows already in `needs_enrichment`, each of which reshape
 *   has *already classified* via the `reason` column.
 *
 * OUTPUT COLUMNS (enrichment_audit tab)
 *   priority           1 = fix first, ascending
 *   name, city, country, type
 *   reason             reshape's own classification:
 *                       "has placeId, missing coords" (easiest)
 *                       "no placeId" (has city — Places lookup needed)
 *                       "no placeId + no city" (hardest)
 *   award_count        how many awards this venue holds
 *   prestige_score     weighted by source (Michelin > W50 > etc.)
 *   top_award          the single most prestigious award held
 *   sources            compact list of award sources
 *   place_id           if reshape found one (for the "missing coords" rows)
 *   suggested_action   literal next step for this row
 *
 * COLOR CODING by reason
 *   green   = has placeId, missing coords (cheapest fix — re-enrich)
 *   yellow  = no placeId (has city; needs a Places lookup)
 *   red     = no placeId + no city (needs manual research)
 *
 * HOW TO RUN
 *   1. In Apps Script, add a new file: compasseats-enrichment-audit.gs
 *   2. Paste this whole script, save.
 *   3. Select `auditEnrichment` from the function dropdown → ▶ Run.
 *   4. Open the new `enrichment_audit` tab.
 *
 * SAFETY
 *   - Reads from: needs_enrichment
 *   - Writes ONLY to: enrichment_audit
 *   - Never touches any award tab, venues, or needs_enrichment.
 */

// ─── Prestige weights (matches the source slugs used in awards_json) ──────
// Any source NOT listed here falls back to weight 1. Keep this in sync with
// AWARD_SOURCES in schema.ts whenever a new source is added.
var PRESTIGE = {
  // ── Restaurants ──────────────────────────────────────────
  'michelin': 10,
  'worlds-50-best-restaurants': 9,
  'worlds-50-best-restaurants-51-100': 8,
  'la-liste': 8,
  'james-beard': 8,
  'asia-50-best-restaurants': 7,
  'latin-america-50-best-restaurants': 7,
  'north-america-50-best-restaurants': 7,
  'mena-50-best-restaurants': 7,
  'africa-50-best-restaurants': 7,
  'asia-50-best-restaurants-51-100': 6,
  'best-chef-awards': 6,
  'gault-millau': 6,
  'tabelog': 5,
  'forbes-travel-guide': 5,
  'oad': 4,
  '101-best-steakhouses': 3,
  // ── Bars ─────────────────────────────────────────────────
  'worlds-50-best-bars': 9,
  'worlds-50-best-bars-51-100': 8,
  'spirited-awards': 7,
  'north-america-50-best-bars': 7,
  'asia-50-best-bars': 7,
  'north-america-50-best-bars-51-100': 6,
  'asia-50-best-bars-51-100': 6,
  'pinnacle-guide': 5,
};

var REASON_COLOR = {
  'has placeId, missing coords': '#E3F0D5', // green
  'no placeId':                  '#FBF3D2', // yellow
  'no placeId + no city':        '#F7D4D4', // red
};

var REASON_ACTION = {
  'has placeId, missing coords':
    'Re-enrich this placeId via Places API — coords are the only missing piece.',
  'no placeId':
    'Search Google Places for "{name}, {city}" and add the placeId+geo to Places Enrichment.',
  'no placeId + no city':
    'Research which city this venue is in, then look it up on Places. Hardest to fix.',
};

// ─── main ─────────────────────────────────────────────────────────────────

function auditEnrichment() {
  var ss = SpreadsheetApp.getActive();
  var src = ss.getSheetByName('needs_enrichment');
  if (!src) {
    throw new Error('No `needs_enrichment` tab. Run reshape.gs first.');
  }

  var data = src.getDataRange().getValues();
  if (data.length < 2) {
    Logger.log('needs_enrichment is empty — nothing to audit.');
    return;
  }

  var headers = data[0].map(function (h) { return String(h).trim(); });
  var col = function (name) { return headers.indexOf(name); };

  var iName    = col('name');
  var iCity    = col('city');
  var iCountry = col('country');
  var iType    = col('type');
  var iCount   = col('award_count');
  var iAwards  = col('awards_json');
  var iPlaceId = col('place_id');
  var iReason  = col('reason');

  var rows = [];
  for (var r = 1; r < data.length; r++) {
    var row = data[r];
    var awards = parseJson_(row[iAwards]);
    var prestige = 0;
    var topAward = null;
    var topScore = -1;

    for (var a = 0; a < awards.length; a++) {
      var aw = awards[a];
      var s = String(aw.source || '');
      var w = PRESTIGE[s] || 1;
      prestige += w;
      // tiebreak: prefer ranked awards over generic
      var hasRank = aw.rank != null;
      var effective = w * 10 + (hasRank ? (50 - Math.min(50, aw.rank || 50)) : 0);
      if (effective > topScore) {
        topScore = effective;
        topAward = formatAward_(aw);
      }
    }

    var sources = uniqueSources_(awards).map(shortenSource_).join(', ');
    var name = row[iName] || '';
    var city = row[iCity] || '';
    var reason = row[iReason] || '';
    var actionTpl = REASON_ACTION[reason] || '';
    var action = actionTpl
      .replace('{name}', name)
      .replace('{city}', city || '(unknown city)');

    rows.push({
      prestige: prestige,
      awardCount: Number(row[iCount]) || 0,
      data: [
        0,                              // priority — assigned after sort
        name,
        city,
        row[iCountry] || '',
        row[iType] || '',
        reason,
        Number(row[iCount]) || 0,
        prestige,
        topAward || '',
        sources,
        row[iPlaceId] || '',
        action,
      ],
      reason: reason,
    });
  }

  // Sort: prestige DESC, then award_count DESC, then name
  rows.sort(function (a, b) {
    if (b.prestige !== a.prestige) return b.prestige - a.prestige;
    if (b.awardCount !== a.awardCount) return b.awardCount - a.awardCount;
    return String(a.data[1]).localeCompare(String(b.data[1]));
  });

  // Assign priority 1..N
  rows.forEach(function (r, i) { r.data[0] = i + 1; });

  // Build output sheet
  var out = ss.getSheetByName('enrichment_audit');
  if (out) out.clear(); else out = ss.insertSheet('enrichment_audit');

  var outHeaders = [
    'priority', 'name', 'city', 'country', 'type',
    'reason', 'award_count', 'prestige_score',
    'top_award', 'sources', 'place_id', 'suggested_action',
  ];
  out.getRange(1, 1, 1, outHeaders.length).setValues([outHeaders])
    .setFontWeight('bold').setBackground('#F1ECE0');
  out.setFrozenRows(1);

  if (rows.length) {
    var values = rows.map(function (r) { return r.data; });
    out.getRange(2, 1, values.length, outHeaders.length).setValues(values);

    // Color rows by reason
    for (var r2 = 0; r2 < rows.length; r2++) {
      var fill = REASON_COLOR[rows[r2].reason];
      if (fill) {
        out.getRange(2 + r2, 1, 1, outHeaders.length).setBackground(fill);
      }
    }
  }

  out.setColumnWidth(1, 70);
  out.setColumnWidth(2, 240);
  out.setColumnWidth(3, 140);
  out.setColumnWidth(4, 110);
  out.setColumnWidth(5, 90);
  out.setColumnWidth(6, 200);
  out.setColumnWidth(7, 100);
  out.setColumnWidth(8, 110);
  out.setColumnWidth(9, 200);
  out.setColumnWidth(10, 240);
  out.setColumnWidth(11, 280);
  out.setColumnWidth(12, 440);

  // Log summary
  var byReason = {};
  rows.forEach(function (r) { byReason[r.reason] = (byReason[r.reason] || 0) + 1; });
  Logger.log('');
  Logger.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  Logger.log(' Enrichment audit: ' + rows.length + ' rows');
  Logger.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  Object.keys(REASON_COLOR).forEach(function (k) {
    var n = byReason[k] || 0;
    Logger.log('  ' + pad_(k, 30) + lpad_(n, 5));
  });
  Logger.log('');
  Logger.log(' Top 5 by prestige (these fix the most):');
  rows.slice(0, 5).forEach(function (r, i) {
    Logger.log('  ' + (i + 1) + '. ' + r.data[1] + '  (prestige ' + r.prestige +
               ', ' + r.awardCount + ' awards)');
  });
  Logger.log('');
  Logger.log('✓ Written to `enrichment_audit` tab.');
}

// ─── helpers ──────────────────────────────────────────────────────────────

function parseJson_(s) {
  if (!s) return [];
  try { return JSON.parse(s); } catch (e) { return []; }
}

function uniqueSources_(awards) {
  var seen = {}, out = [];
  for (var i = 0; i < awards.length; i++) {
    var s = String(awards[i].source || '');
    if (!seen[s] && s) { seen[s] = true; out.push(s); }
  }
  return out;
}

function shortenSource_(s) {
  return s
    // regional 50 Best (do the long, specific replacements FIRST)
    .replace('worlds-50-best-restaurants-51-100', 'w50-rest 51-100')
    .replace('worlds-50-best-restaurants', 'w50-rest')
    .replace('worlds-50-best-bars-51-100', 'w50-bars 51-100')
    .replace('worlds-50-best-bars', 'w50-bars')
    .replace('north-america-50-best-restaurants', 'na50-rest')
    .replace('latin-america-50-best-restaurants', 'latam50-rest')
    .replace('asia-50-best-restaurants-51-100', 'asia50-rest 51-100')
    .replace('asia-50-best-restaurants', 'asia50-rest')
    .replace('mena-50-best-restaurants', 'mena50-rest')
    .replace('africa-50-best-restaurants', 'africa50-rest')
    .replace('north-america-50-best-bars-51-100', 'na50-bars 51-100')
    .replace('north-america-50-best-bars', 'na50-bars')
    .replace('asia-50-best-bars-51-100', 'asia50-bars 51-100')
    .replace('asia-50-best-bars', 'asia50-bars')
    // other sources
    .replace('best-chef-awards', 'best-chef')
    .replace('101-best-steakhouses', '101-steak')
    .replace('pinnacle-guide', 'pinnacle')
    .replace('spirited-awards', 'spirited')
    .replace('james-beard', 'jbf')
    .replace('gault-millau', 'gault-millau')
    .replace('forbes-travel-guide', 'forbes')
    .replace('la-liste', 'la-liste');
}

function formatAward_(aw) {
  var src = shortenSource_(String(aw.source || ''));
  var year = aw.year ? (' ' + aw.year) : '';
  var cat = aw.category ? (' · ' + aw.category) : '';
  return src + year + cat;
}

function pad_(s, n) {
  s = String(s);
  while (s.length < n) s += ' ';
  return s;
}

function lpad_(s, n) {
  s = String(s);
  while (s.length < n) s = ' ' + s;
  return s;
}
