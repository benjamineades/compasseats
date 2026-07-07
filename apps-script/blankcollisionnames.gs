/**
 * ONE-TIME cleanup — fixes a side effect of this session's collision re-query.
 *
 * The collision rows wrote Google's place name into canonicalName (col B).
 * Reshape uses that as the venue name, which changed slugs and broke blurb
 * matching (blurbs are keyed by slug). This blanks canonicalName on ONLY the
 * rows this session added (tagged 'collision-fix' / 'collision-fix-reviewed')
 * so reshape falls back to each venue's editorial/award name — restoring the
 * original slug (and blurbs) while keeping the corrected place_id/lat/lng.
 *
 * The older 'geo-requery' rows and all name-only rows are left untouched.
 *
 * Run once, then re-run the normal pipeline.
 */
function blankCollisionFixNames() {
  var ss = SpreadsheetApp.getActive();
  var sh = ss.getSheetByName('Places Enrichment');
  if (!sh) throw new Error('No "Places Enrichment" tab found.');

  var rng = sh.getDataRange();
  var vals = rng.getValues();
  var tags = { 'collision-fix': true, 'collision-fix-reviewed': true };
  var n = 0;

  for (var i = 1; i < vals.length; i++) {
    var sheetName = String(vals[i][2]);     // col C
    if (tags[sheetName] && vals[i][1] !== '') {
      vals[i][1] = '';                       // blank canonicalName (col B)
      n++;
    }
  }

  rng.setValues(vals);
  SpreadsheetApp.getUi().alert(
    'Blanked canonicalName on ' + n + ' collision-fix rows.\n\n' +
    'Now re-run the pipeline:\n' +
    'reshapeCompassEats → mergeDuplicateVenues → importBlurbsFromDrive →\n' +
    'clearWrongCityBlurbs → importOptionB → generateCitiesTab → preflightPublish');
}
