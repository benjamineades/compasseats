/**
 * CompassEats — Session Scope Report  (READ-ONLY, no cost, safe to re-run)
 * ======================================================================
 * Counts exactly what is sitting in each work bucket right now, from LIVE data:
 *
 *   1. PARKED       — rows in `enrichment_review` waiting for your ACCEPT/REJECT
 *   2. NEEDS ENRICH — rows in `enrichment_audit` still with no Google pin
 *   3. COLLISIONS   — cross-city Google Place ID collisions, computed FRESH
 *                     from the live `venues` tab (group by id, count distinct
 *                     city_slug > 1). Also shows what `merge_review` currently
 *                     says, for cross-check — the venues-derived number wins.
 *
 * Touches nothing. Just reads and reports. Run it, read the popup, paste it back.
 */
function sessionScopeReport() {
  var ss = SpreadsheetApp.getActive();
  var lines = [];
  var allTabs = ss.getSheets().map(function (s) { return s.getName(); });

  // ---- helper: find a tab by any of several candidate names (loose match) ----
  function findTab(cands) {
    for (var c = 0; c < cands.length; c++) {
      var want = cands[c].toLowerCase().replace(/\s+/g, ' ').trim();
      for (var i = 0; i < allTabs.length; i++) {
        if (allTabs[i].toLowerCase().replace(/\s+/g, ' ').trim() === want) {
          return ss.getSheetByName(allTabs[i]);
        }
      }
    }
    return null;
  }
  // ---- helper: header-name -> column index map ----
  function headerMap(sheet) {
    var v = sheet.getDataRange().getValues();
    if (!v.length) return { h: {}, rows: 0, values: v };
    var h = {};
    for (var c = 0; c < v[0].length; c++) h[String(v[0][c]).trim().toLowerCase()] = c;
    return { h: h, rows: Math.max(0, v.length - 1), values: v };
  }
  function firstCol(h, cands) {
    for (var i = 0; i < cands.length; i++) {
      if (cands[i].toLowerCase() in h) return h[cands[i].toLowerCase()];
    }
    return -1;
  }

  // ===================== 1. PARKED (enrichment_review) =====================
  var review = findTab(['enrichment_review']);
  if (review) {
    var rInfo = headerMap(review);
    // count how many already carry a decision vs blank (still to judge)
    var dCol = firstCol(rInfo.h, ['decision']);
    var decided = 0, blank = 0;
    for (var r = 1; r < rInfo.values.length; r++) {
      var d = dCol >= 0 ? String(rInfo.values[r][dCol] || '').trim() : '';
      if (d) decided++; else blank++;
    }
    lines.push('PARKED (enrichment_review): ' + rInfo.rows + ' rows'
      + '  [' + blank + ' still to judge, ' + decided + ' already marked]');
  } else {
    lines.push('PARKED (enrichment_review): TAB NOT FOUND');
  }

  // ===================== 2. NEEDS ENRICHMENT (enrichment_audit) =====================
  var audit = findTab(['enrichment_audit', 'needs_enrichment']);
  if (audit) {
    var aInfo = headerMap(audit);
    var reasonCol = firstCol(aInfo.h, ['reason']);
    var noPin = 0;
    if (reasonCol >= 0) {
      for (var a = 1; a < aInfo.values.length; a++) {
        var reason = String(aInfo.values[a][reasonCol] || '');
        if (reason.indexOf('no placeId') === 0) noPin++;
      }
      lines.push('NEEDS ENRICH (' + audit.getName() + '): ' + aInfo.rows
        + ' rows total, ' + noPin + " with reason 'no placeId' (what geoEnrich processes)");
    } else {
      lines.push('NEEDS ENRICH (' + audit.getName() + '): ' + aInfo.rows
        + ' rows total (no `reason` column found — cannot split)');
    }
  } else {
    lines.push('NEEDS ENRICH: TAB NOT FOUND (looked for enrichment_audit / needs_enrichment)');
  }

  // ===================== 3. COLLISIONS (fresh from venues) =====================
  var venues = findTab(['venues']);
  if (venues) {
    var vInfo = headerMap(venues);
    var idCol   = firstCol(vInfo.h, ['id', 'place_id', 'google_place_id', 'placeid']);
    var cityCol = firstCol(vInfo.h, ['city_slug', 'cityslug', 'city']);
    if (idCol >= 0 && cityCol >= 0) {
      var idToCities = {};
      for (var vv = 1; vv < vInfo.values.length; vv++) {
        var id = String(vInfo.values[vv][idCol] || '').trim();
        var cs = String(vInfo.values[vv][cityCol] || '').trim();
        if (!id || !cs) continue;
        if (!idToCities[id]) idToCities[id] = {};
        idToCities[id][cs] = true;
      }
      var groups = 0, rowsInvolved = 0;
      for (var k in idToCities) {
        var n = Object.keys(idToCities[k]).length;
        if (n > 1) { groups++; rowsInvolved += n; }
      }
      lines.push('COLLISIONS (live venues, by ' + Object.keys(vInfo.h)[idCol]
        + ' \u00D7 ' + Object.keys(vInfo.h)[cityCol] + '): '
        + groups + ' cross-city groups, spanning ' + rowsInvolved + ' venue rows');
    } else {
      lines.push('COLLISIONS: venues tab found but could not locate id/city_slug columns'
        + ' (headers: ' + Object.keys(vInfo.h).join(', ') + ')');
    }
    lines.push('   venues tab total rows: ' + vInfo.rows);
  } else {
    lines.push('COLLISIONS: `venues` TAB NOT FOUND');
  }

  // cross-check against merge_review
  var mr = findTab(['merge_review']);
  if (mr) {
    var mInfo = headerMap(mr);
    lines.push('   (cross-check) merge_review currently holds: ' + mInfo.rows + ' rows');
  } else {
    lines.push('   (cross-check) merge_review: TAB NOT FOUND');
  }

  // ===================== output =====================
  var out = '=== CompassEats Session Scope ===\n\n' + lines.join('\n')
    + '\n\n--- all tab names ---\n' + allTabs.join(', ');
  Logger.log(out);
  SpreadsheetApp.getUi().alert(out);
}
