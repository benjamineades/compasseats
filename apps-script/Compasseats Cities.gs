/**
 * CompassEats — Cities Tab Generator (Google Apps Script)
 * =======================================================
 * Reads the "venues" tab (produced by compasseats-reshape.gs) and builds a
 * "cities" tab matching src/lib/schema.ts (CitySchema).
 *
 * For each distinct city_slug it:
 *   - takes display name + country from the venues
 *   - computes lat/lng as the MEDIAN of that city's venue coordinates.
 *     The median ignores mislabeled / cross-city-collision venues (e.g. a
 *     Singapore venue listed under Los Angeles) that would otherwise drag a
 *     plain average far off the real city. This keeps the map pin AND the
 *     city hero-photo lookup (which rejects a photo more than ~80km from the
 *     city's coordinates) anchored on the true city center.
 *   - counts venues
 *   - guesses country_code from country name (common cases; editable)
 *
 * Columns you must finish by hand (left blank or best-effort):
 *   country_code   guessed for ~60 common countries; verify the rest
 *   timezone       BLANK — required for "Open Today"; fill per city
 *   region         BLANK — optional
 *   blurb          BLANK — optional editorial intro
 *   hero_image_url BLANK — optional
 *
 * HOW TO RUN
 *   1. Run compasseats-reshape.gs FIRST so the "venues" tab exists.
 *   2. Paste this into the same Apps Script project (add a new file, or
 *      append below the reshape code — function names don't collide).
 *   3. Run → generateCitiesTab. Re-running overwrites the cities tab.
 *
 * Idempotent: existing manual edits to country_code/timezone/blurb are
 * PRESERVED on re-run by matching on slug (see preserveManual_).
 *
 * FIXED August 2, 2026: the summary used to be shown with
 * SpreadsheetApp.getUi().alert(), which only works when the script is run
 * from a menu inside the open spreadsheet. Run from the Apps Script editor
 * it throws "Cannot call SpreadsheetApp.getUi() from this context" AFTER all
 * the real work has already finished — so the run was marked Failed even
 * though the cities tab wrote correctly. The summary now goes to
 * Logger.log() only, which works in every context.
 */

var CITIES_TAB = 'cities';
var VENUES_TAB_SRC = 'venues';

// Minimal country → ISO-3166 alpha-2 map for the countries most common in
// fine-dining guides. Anything not here is left blank for you to fill.
var COUNTRY_CODE = {
  // Existing common set
  'united states': 'US', 'usa': 'US', 'united states of america': 'US',
  'united kingdom': 'GB', 'uk': 'GB', 'england': 'GB', 'scotland': 'GB', 'wales': 'GB', 'northern ireland': 'GB',
  'france': 'FR', 'italy': 'IT', 'spain': 'ES', 'germany': 'DE', 'portugal': 'PT',
  'switzerland': 'CH', 'austria': 'AT', 'belgium': 'BE', 'netherlands': 'NL', 'the netherlands': 'NL',
  'denmark': 'DK', 'sweden': 'SE', 'norway': 'NO', 'finland': 'FI', 'iceland': 'IS',
  'ireland': 'IE', 'poland': 'PL', 'czech republic': 'CZ', 'czechia': 'CZ',
  'greece': 'GR', 'turkey': 'TR', 'türkiye': 'TR', 'russia': 'RU', 'hungary': 'HU', 'croatia': 'HR',
  'slovenia': 'SI', 'estonia': 'EE', 'lithuania': 'LT', 'latvia': 'LV',
  'luxembourg': 'LU', 'monaco': 'MC',
  'japan': 'JP', 'china': 'CN', 'hong kong': 'HK', 'taiwan': 'TW', 'macau': 'MO', 'macao': 'MO',
  'south korea': 'KR', 'korea': 'KR', 'thailand': 'TH', 'vietnam': 'VN', 'viet nam': 'VN',
  'singapore': 'SG', 'malaysia': 'MY', 'indonesia': 'ID', 'philippines': 'PH',
  'india': 'IN', 'cambodia': 'KH', 'sri lanka': 'LK',
  'united arab emirates': 'AE', 'uae': 'AE', 'qatar': 'QA', 'saudi arabia': 'SA',
  'bahrain': 'BH', 'kuwait': 'KW', 'oman': 'OM', 'lebanon': 'LB', 'israel': 'IL',
  'australia': 'AU', 'new zealand': 'NZ',
  'mexico': 'MX', 'canada': 'CA', 'brazil': 'BR', 'argentina': 'AR', 'chile': 'CL',
  'peru': 'PE', 'colombia': 'CO', 'uruguay': 'UY', 'ecuador': 'EC',
  'south africa': 'ZA', 'morocco': 'MA', 'egypt': 'EG', 'mauritius': 'MU',
  // Expanded coverage
  'andorra': 'AD', 'malta': 'MT', 'cyprus': 'CY', 'slovakia': 'SK', 'romania': 'RO',
  'bulgaria': 'BG', 'serbia': 'RS', 'bosnia and herzegovina': 'BA', 'montenegro': 'ME',
  'north macedonia': 'MK', 'macedonia': 'MK', 'albania': 'AL', 'kosovo': 'XK',
  'ukraine': 'UA', 'belarus': 'BY', 'moldova': 'MD', 'georgia': 'GE', 'armenia': 'AM',
  'azerbaijan': 'AZ', 'kazakhstan': 'KZ', 'uzbekistan': 'UZ',
  'liechtenstein': 'LI', 'san marino': 'SM', 'gibraltar': 'GI',
  'jordan': 'JO', 'iraq': 'IQ', 'iran': 'IR', 'syria': 'SY', 'yemen': 'YE',
  'ghana': 'GH', 'nigeria': 'NG', 'kenya': 'KE', 'tanzania': 'TZ', 'uganda': 'UG',
  'ethiopia': 'ET', 'senegal': 'SN', "cote d'ivoire": 'CI', 'ivory coast': 'CI',
  'rwanda': 'RW', 'tunisia': 'TN', 'algeria': 'DZ', 'namibia': 'NA', 'botswana': 'BW',
  'zimbabwe': 'ZW', 'zambia': 'ZM', 'mozambique': 'MZ', 'cameroon': 'CM',
  'seychelles': 'SC', 'maldives': 'MV',
  'nepal': 'NP', 'bangladesh': 'BD', 'pakistan': 'PK',
  'myanmar': 'MM', 'laos': 'LA', 'brunei': 'BN', 'mongolia': 'MN',
  'costa rica': 'CR', 'panama': 'PA', 'guatemala': 'GT', 'el salvador': 'SV',
  'honduras': 'HN', 'nicaragua': 'NI', 'belize': 'BZ',
  'cuba': 'CU', 'dominican republic': 'DO', 'puerto rico': 'PR', 'jamaica': 'JM',
  'trinidad and tobago': 'TT', 'barbados': 'BB', 'bahamas': 'BS',
  'bolivia': 'BO', 'paraguay': 'PY', 'venezuela': 'VE', 'guyana': 'GY',
  'fiji': 'FJ', 'french polynesia': 'PF', 'new caledonia': 'NC'
};

/** Median of a numeric array. Robust to outliers, unlike the mean. */
function median_(arr) {
  if (!arr.length) return NaN;
  var a = arr.slice().sort(function (x, y) { return x - y; });
  var m = Math.floor(a.length / 2);
  return a.length % 2 ? a[m] : (a[m - 1] + a[m]) / 2;
}

function generateCitiesTab() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var vsheet = ss.getSheetByName(VENUES_TAB_SRC);
  if (!vsheet) throw new Error('No "' + VENUES_TAB_SRC + '" tab. Run the reshape script first.');

  var vals = vsheet.getDataRange().getValues();
  var headers = vals[0];
  var col = {};
  for (var h = 0; h < headers.length; h++) col[headers[h]] = h;
  ['city_slug', 'city_display', 'country', 'lat', 'lng'].forEach(function (c) {
    if (col[c] === undefined) throw new Error('venues tab missing column: ' + c);
  });

  // Aggregate per city_slug. Collect every coordinate so we can take the
  // median (not a running average) — outliers no longer drag the center.
  var agg = {}; // slug -> { display, country, lats:[], lngs:[] }
  for (var i = 1; i < vals.length; i++) {
    var row = vals[i];
    var slug = row[col['city_slug']];
    if (!slug) continue;
    var lat = Number(row[col['lat']]);
    var lng = Number(row[col['lng']]);
    if (!agg[slug]) {
      agg[slug] = {
        display: row[col['city_display']] || slug,
        country: row[col['country']] || '',
        lats: [], lngs: []
      };
    }
    var a = agg[slug];
    if (!isNaN(lat) && !isNaN(lng)) { a.lats.push(lat); a.lngs.push(lng); }
    // prefer a non-empty country if the first row lacked one
    if (!a.country && row[col['country']]) a.country = row[col['country']];
  }

  // Preserve any manual edits from an existing cities tab
  var manual = preserveManual_(ss);

  var CITY_HEADERS = ['slug', 'display', 'country', 'country_code', 'region',
    'lat', 'lng', 'timezone', 'blurb', 'hero_image_url', 'venue_count'];

  var rows = [];
  var slugs = Object.keys(agg).sort();
  for (var s = 0; s < slugs.length; s++) {
    var slug = slugs[s];
    var a = agg[slug];
    var n = a.lats.length;
    var lat = n ? +(median_(a.lats)).toFixed(6) : '';
    var lng = n ? +(median_(a.lngs)).toFixed(6) : '';
    var cc = COUNTRY_CODE[String(a.country).toLowerCase().trim()] || '';
    var m = manual[slug] || {};
    rows.push([
      slug,
      a.display,
      a.country,
      m.country_code || cc,         // keep manual override if present
      m.region || '',
      lat,
      lng,
      m.timezone || '',             // keep manual timezone
      m.blurb || '',                // keep manual blurb
      m.hero_image_url || '',       // keep manual hero
      n
    ]);
  }

  var sheet = ss.getSheetByName(CITIES_TAB);
  if (sheet) sheet.clear();
  else sheet = ss.insertSheet(CITIES_TAB);
  sheet.getRange(1, 1, 1, CITY_HEADERS.length).setValues([CITY_HEADERS]).setFontWeight('bold');
  if (rows.length) sheet.getRange(2, 1, rows.length, CITY_HEADERS.length).setValues(rows);
  sheet.setFrozenRows(1);

  var withCC = rows.filter(function (r) { return r[3]; }).length;
  var msg =
    'Done.\n' +
    'cities tab: ' + rows.length + ' cities\n' +
    'country_code auto-filled: ' + withCC + ' / ' + rows.length + '\n' +
    'timezone: BLANK (fill these for "Open Today")\n' +
    'lat/lng: MEDIAN of each city\'s venues (robust to outliers)';
  Logger.log(msg);
}

/** Read existing cities tab (if any) so re-runs don't wipe manual columns. */
function preserveManual_(ss) {
  var sheet = ss.getSheetByName(CITIES_TAB);
  var out = {};
  if (!sheet) return out;
  var vals = sheet.getDataRange().getValues();
  if (vals.length < 2) return out;
  var h = {};
  for (var i = 0; i < vals[0].length; i++) h[vals[0][i]] = i;
  for (var r = 1; r < vals.length; r++) {
    var slug = vals[r][h['slug']];
    if (!slug) continue;
    out[slug] = {
      country_code: h['country_code'] !== undefined ? vals[r][h['country_code']] : '',
      region: h['region'] !== undefined ? vals[r][h['region']] : '',
      timezone: h['timezone'] !== undefined ? vals[r][h['timezone']] : '',
      blurb: h['blurb'] !== undefined ? vals[r][h['blurb']] : '',
      hero_image_url: h['hero_image_url'] !== undefined ? vals[r][h['hero_image_url']] : ''
    };
  }
  return out;
}
