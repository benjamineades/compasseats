/**
 * geoSplitScan() — READ-ONLY. Makes NO edits to any tab.
 *
 * Purpose: enumerate the venues where the SAME slug is filed under two or more
 * different city labels AND a Michelin award sits on some of those labels but
 * not others. That is the exact "hidden stars" signature — the page renders one
 * city's row and misses the Michelin that bound to the other.
 *
 * It sorts the findings into two buckets:
 *   • SAME-COUNTRY  → almost certainly one real venue under two city spellings
 *                     (e.g. Gentofte / Copenhagen). These are the CITY_ALIASES_
 *                     merge candidates.
 *   • CROSS-COUNTRY → same name, different countries = different restaurants
 *                     (e.g. Bacchanalia Atlanta / London). NOT alias material —
 *                     these belong to the separate per-city geo fix.
 *
 * How to run:
 *   1. Open the Apps Script editor for the CompassEats sheet.
 *   2. Add this as a new file (or paste at the bottom of any existing one).
 *   3. Select "geoSplitScan" in the function dropdown and click Run.
 *   4. Open the execution log and copy ALL of the output back to me.
 *
 * Reads only. Writes nothing.
 */
function geoSplitScan() {
  var ss = SpreadsheetApp.getActive();
  var v = ss.getSheetByName('venues');
  if (!v) { Logger.log('venues tab NOT FOUND — check the exact tab name.'); return; }

  var vv = v.getDataRange().getValues();
  var hdr = vv[0].map(function (h) { return String(h).toLowerCase(); });
  var iSlug    = hdr.indexOf('slug');
  var iName    = hdr.indexOf('name');
  var iCity    = hdr.indexOf('city_slug');
  var iCountry = hdr.indexOf('country');
  var iAwards  = hdr.indexOf('awards_json');

  // Group rows by slug. For each slug, track per-city info.
  // groups[slug] = { name, cities: { citySlug: { country, michelin, rows } } }
  var groups = {};
  for (var r = 1; r < vv.length; r++) {
    var slug = String(vv[r][iSlug] || '').trim();
    if (!slug) continue;
    var citySlug = String(vv[r][iCity] || '').trim();
    var country  = String(vv[r][iCountry] || '').trim();

    // Does this row carry a Michelin award?
    var hasMich = false;
    try {
      var arr = JSON.parse(vv[r][iAwards] || '[]');
      for (var a = 0; a < arr.length; a++) {
        if (String(arr[a].source || '').toLowerCase().indexOf('michelin') !== -1) { hasMich = true; break; }
      }
    } catch (e) { /* unparseable awards cell — treat as no michelin */ }

    if (!groups[slug]) groups[slug] = { name: String(vv[r][iName] || ''), cities: {} };
    var c = groups[slug].cities;
    if (!c[citySlug]) c[citySlug] = { country: country, michelin: false, rows: 0 };
    c[citySlug].rows += 1;
    if (hasMich) c[citySlug].michelin = true;
    if (!c[citySlug].country && country) c[citySlug].country = country;
  }

  // Keep only slugs that (a) span >=2 city labels and (b) have Michelin on a
  // proper subset of them (some yes, some no) — the star-hiding signature.
  var sameCountry = [];
  var crossCountry = [];
  Object.keys(groups).forEach(function (slug) {
    var cities = groups[slug].cities;
    var labels = Object.keys(cities);
    if (labels.length < 2) return;

    var withM = 0, withoutM = 0, countrySet = {};
    labels.forEach(function (ls) {
      if (cities[ls].michelin) withM++; else withoutM++;
      countrySet[(cities[ls].country || '').toLowerCase()] = true;
    });
    if (withM < 1 || withoutM < 1) return; // not a hiding split

    var rec = { slug: slug, name: groups[slug].name, cities: cities, labels: labels };
    if (Object.keys(countrySet).length === 1) sameCountry.push(rec);
    else crossCountry.push(rec);
  });

  // ── Build the report ─────────────────────────────────────────────────────
  var out = [];
  out.push('=== HIDDEN-MICHELIN SPLIT SCAN (read-only) ===');
  out.push('SUMMARY: ' + (sameCountry.length + crossCountry.length) +
           ' Michelin-hiding split slugs total | ' +
           sameCountry.length + ' SAME-COUNTRY (alias candidates) | ' +
           crossCountry.length + ' CROSS-COUNTRY (geo workstream, do NOT alias)');

  function dumpCity(rec) {
    rec.labels.forEach(function (ls) {
      var c = rec.cities[ls];
      out.push('   city_slug="' + ls + '"  country="' + c.country + '"  michelin=' +
               (c.michelin ? 'YES' : 'no') + '  rows=' + c.rows);
    });
  }

  out.push('');
  out.push('--- SAME-COUNTRY — ALIAS CANDIDATES (' + sameCountry.length + ') ---');
  sameCountry.sort(function (a, b) { return a.slug < b.slug ? -1 : 1; });
  var CAP = 250;
  sameCountry.slice(0, CAP).forEach(function (rec) {
    out.push('slug="' + rec.slug + '"  name="' + rec.name + '"');
    dumpCity(rec);
  });
  if (sameCountry.length > CAP) out.push('… (' + (sameCountry.length - CAP) + ' more — rerun with a higher cap if needed)');

  out.push('');
  out.push('--- CROSS-COUNTRY — geo issues, NOT alias material (' + crossCountry.length + ') ---');
  crossCountry.sort(function (a, b) { return a.slug < b.slug ? -1 : 1; });
  crossCountry.slice(0, 80).forEach(function (rec) {
    out.push('slug="' + rec.slug + '"  name="' + rec.name + '"');
    dumpCity(rec);
  });
  if (crossCountry.length > 80) out.push('… (' + (crossCountry.length - 80) + ' more)');

  Logger.log(out.join('\n'));
}
