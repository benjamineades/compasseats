/**
 * CompassEats — Sheet Reshape (Google Apps Script)
 * =================================================
 * Merges the award tabs + "Places Enrichment" into two output tabs:
 *
 *   venues            complete venues (have placeId + lat/lng + city) — publishable
 *   needs_enrichment  venues missing geo data — to re-run through Places later
 *
 * CHANGED (June 3, 2026):
 *   - Added "Bar Awards" (slug "__bars__") AND "Restaurant Awards"
 *     (slug "__restaurants__") as source tabs, so venues ingested by the
 *     bar- and restaurant-ingest tools are folded into venues like every
 *     other source and survive reshape.
 *   - Added all bar source slugs to BAR_SOURCES so they type as "bar".
 *   - cuisine / price_band from Restaurant Awards flow into
 *     venues.cuisine_tags / venues.price_tier.
 *   >>> THIS IS THE FINAL VERSION — reads BOTH awards tabs. If your installed
 *       reshape's SOURCE_MAP has no 'Restaurant Awards' line, it is OUTDATED
 *       and restaurants will silently disappear. Use this file.
 *
 * >>> PATCHED July 21, 2026 (handoff section 6): writeTab_() still clears and
 *     fully rebuilds the venues tab from scratch every run. price_tier now
 *     comes from the Restaurant Awards tab's price_band column FIRST, and
 *     falls back to a new "price_level" column on Places Enrichment when the
 *     award tab has none. This is what lets a Google-Places price backfill
 *     survive reshape. BEFORE running this version for the first time:
 *       1. Add a column called "price_level" as the LAST column on the
 *          "Places Enrichment" tab. As of July 21 2026 the tab's last
 *          column is "lastVerified" — price_level goes right after that
 *          one, not after "businessStatus".
 *       2. Run migratePriceToEnrichment() ONCE (see bottom of this file) to
 *          copy whatever price_tier values already exist in `venues` (from
 *          the completed backfill) into that new column.
 *       3. Only then run reshapeCompassEats() again.
 *     Skipping steps 1–2 means the fallback column is empty and reshape will
 *     silently drop the backfilled prices, same as before this patch.
 *
 * >>> PATCHED July 23, 2026: splits 7 confirmed real city-name collisions
 *     (two different real places that happened to share one city_slug) into
 *     separate slugs — baltimore/baltimore-ie, birmingham/birmingham-al,
 *     venice/venice-fl, cambridge/cambridge-ma/cambridge-on, cordoba/
 *     cordoba-ar, la-paz/la-paz-mx, munster/munster-fr. See
 *     CITY_DISAMBIGUATE_ below for the full list and the country rules.
 *     generateCitiesTab.gs needs NO changes — it already computes each
 *     city_slug's centroid independently, so the new slugs get correct
 *     centroids automatically on its next run. Names, awards, and blurbs
 *     are untouched by this — it only changes city_slug/city_display and
 *     each venue's resulting coordinates via the normal per-city centroid.
 *
 * >>> THIS IS THE FULLY COMBINED VERSION as of July 23, 2026: the price-
 *     survival fix (above) PLUS this city-split fix PLUS the migration
 *     helper fixes at the bottom of the file (v4 — see comments there).
 *     If you've already run migratePriceToEnrichment() successfully from
 *     the previous file, you do not need to run it again before reshape —
 *     just paste this in and run reshapeCompassEats().
 *
 * HOW TO RUN
 *   1. Open your Google Sheet.
 *   2. Extensions → Apps Script.
 *   3. Delete any boilerplate, paste this whole file, Save.
 *   4. Run → reshapeCompassEats. Authorize when prompted (first run only).
 *   5. Check the two new tabs. Re-running overwrites them (safe, idempotent).
 *
 * Your original award tabs are never modified — only read.
 *
 * The "venues" tab columns match src/lib/schema.ts (SheetRowSchema), so
 * scripts/sync-sheet.ts can read it directly. awards_json holds a JSON
 * array per the schema.
 */

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

// Maps a source TAB NAME → [schema source slug, default year (or null = per-row)]
// Tab-name matching is tolerant of apostrophes/spacing/case (see findSheet_).
var SOURCE_MAP = {
'Michelin Guide':            ['michelin', null],
  'Worlds 50 Best':            ['__50best__', null], // special: routes by Type column
  'Best Chef Awards':          ['best-chef-awards', null],
  'James Beard Awards':        ['james-beard', null],
  'Pinnacle Guide':            ['pinnacle-guide', null],
  'Spirited Awards':           ['spirited-awards', null],
  'OAD North America 2026':    ['oad', 2026],
  'OAD South America 2026':    ['oad', 2026],
  'OAD Asia 2025':             ['oad', 2025],
  'OAD Europe 2025':           ['oad', 2025],
  'OAD Japan 2025':            ['oad', 2025],
  'OAD North America 2025':    ['oad', 2025],
  'OAD South America 2025':    ['oad', 2025],
  '101 Best Steakhouses 2026': ['101-best-steakhouses', 2026],
  '101 Best Steakhouses 2025': ['101-best-steakhouses', 2025],
  'Bar Awards':                ['__bars__', null],  // bar-ingest output
  'Restaurant Awards':         ['__restaurants__', null] // restaurant-ingest output
};

var BAR_SOURCES = {
  'pinnacle-guide': true,
  'spirited-awards': true,
  'worlds-50-best-bars': true,
  'worlds-50-best-bars-51-100': true,
  'north-america-50-best-bars': true,
  'north-america-50-best-bars-51-100': true,
  'asia-50-best-bars': true,
  'asia-50-best-bars-51-100': true,
  'top-500-bars': true
};

var ENRICHMENT_TAB = 'Places Enrichment';
var VENUES_TAB = 'venues';
var NEEDS_TAB = 'needs_enrichment';
var TODAY = new Date().toISOString().slice(0, 10);

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

function stripAccents_(s) {
  return s.normalize('NFKD').replace(/[\u0300-\u036f]/g, '');
}
function normKey_(name) {
  if (!name) return '';
  var s = stripAccents_(String(name)).toLowerCase();
  // Strip apostrophes BEFORE the alphanum sweep so "tetsuya's" → "tetsuyas"
  s = s.replace(/['\u2018\u2019\u02BC`]/g, '');
  // Convert ampersands to "and" so "jigger & pony" → "jigger and pony"
  s = s.replace(/&/g, ' and ');
  // Strip Unicode fractions and superscripts so "8½" → "8" and "Tanière³" → "taniere"
  s = s.replace(/[\u00BC-\u00BE\u2150-\u215E]/g, '');           // ¼ ½ ¾ ⅓ ⅔ etc.
  s = s.replace(/[\u00B2\u00B3\u00B9\u2070-\u2079]/g, '');      // ² ³ ¹ ⁰ ⁴-⁹
  s = s.replace(/[^a-z0-9]+/g, ' ');
  return s.replace(/\s+/g, ' ').trim();
}

// City-name aliases — localized spellings + verified typos from source award tabs.
// Maps a normalized variant → canonical normalized city key. Applied in cityKey_.
// Added June 7, 2026 — resolves localized-name / typo duplicate-key collisions
// (La Liste / Restaurant Awards use native names; OAD tabs carry typos).
// VERIFIED against actual source-tab strings. Do NOT add region/country names
// here (Switzerland, Somerset, etc.) — those are per-venue source errors, fixed
// on the award tab itself, not via a global alias.
var CITY_ALIASES_ = {
  'atherton': 'redwood city',
  'bangalore': 'bengaluru',
  'barangaroo': 'sydney',
  'beverly hills': 'los angeles',
  'blackburn': 'langho',
  'bourguillon': 'fribourg',
  'bramboden': 'romoos',
  'castel verruca': 'merano',
  'castiglion del bosco': 'montalcino',
  'central': 'hong kong',
  'coral gables': 'miami',
  'cupar': 'peat inn',
  'durtol': 'clermont ferrand',
  'echaurren': 'ezcaray',
  'eghezee': 'liernu',
  'exmouth': 'lympstone',
  'fordwich': 'canterbury',
  'freienfeld bei sterzing': 'mules',
  'friuli venezia': 'trieste',
  'giza': 'cairo',
  'grasmere': 'ambleside',
  'hexham': 'wall',
  'hythe': 'saltwood',
  'iwade': 'wakayama',
  'javea': 'xabia',
  'jordan station': 'lincoln',
  'koksijde': 'sint idesbald',
  'lagundo': 'algund',
  'lamporecchio': 'vinci',
  'lens': 'crans montana',
  'lherbaudiere': 'noirmoutier en lile',
  'loughborough': 'mountsorrel',
  'lower beeding': 'horsham',
  'marina del cantone': 'massa lubrense',
  'marzocca': 'senigallia',
  'mazzorbo': 'venice',
  'monmouth': 'whitebrook',
  'monte carlo': 'monaco',
  'moutfort': 'oetrange',
  'nerano': 'massa lubrense',
  'noirmoutier': 'noirmoutier en lile',
  'nonoichi': 'kanazawa',
  'ormskirk': 'aughton',
  'our': 'paliseul',
  'profondeville': 'arbre',
  'pyla sur mer': 'la teste de buch',
  'queens': 'new york',
  'rantum': 'sylt',
  'raxo': 'poio',
  'ripponlea': 'melbourne',
  'runate': 'canneto sulloglio',
  'saint bon tarentaise': 'courchevel',
  'saint ghislain': 'baudour',
  'saint martin duriage': 'uriage les bains',
  'san juan bautista la raya': 'oaxaca',
  'san pedro garza garcia': 'monterrey',
  'san pietro allolmo': 'milan',
  'san pietro allolmo cornaredo': 'milan',
  'sandweiler': 'findel',
  'sankt niklausen': 'wilderswil',
  'santa coloma de gramenet': 'barcelona',
  'santa cristina d aspromonte': 'santa cristina daspromonte',
  'sedlec u mikulova': 'hlohovec',
  'silvaplana': 'saint moritz',
  'sint kruis': 'bruges',
  'sorengo': 'lugano',
  'south wales': 'pontyclun',
  'suita': 'osaka',
  'surfside': 'miami',
  'surry hills': 'sydney',
  'taguig': 'manila',
  'techendorf': 'weissensee',
  'tinnum': 'sylt',
  'tinqueux': 'reims',
  'trucco': 'ventimiglia',
  'uccle': 'brussels',
  'udine': 'godia',
  'vila nova de gaia': 'porto',
  'waregem': 'beveren leie',
  'west hollywood': 'los angeles',
  'whitstable': 'seasalter',
  'windermere': 'ambleside',
  'woluwe saint pierre': 'brussels',
  'zingem': 'ouwegem',
  'gentofte': 'copenhagen',            // Restaurant Jordnaer (3*)
  'maidenhead': 'bray',                // The Waterside Inn (3*) + The Fat Duck (3*)
  'grange over sands': 'cartmel',      // L'Enclume (3*)
  'newton in cartmel': 'cartmel',      // Heft (same Cartmel cluster)
  'collonges au mont dor': 'lyon',     // Restaurant Paul Bocuse (3*)
  'leith': 'edinburgh',                // The Kitchin
  'pocantico hills': 'tarrytown',      // Blue Hill at Stone Barns (2*)
  'ixelles': 'brussels',               // Humus x Hortense
  'anderlecht': 'brussels',            // La Paix
  'akirkeby': 'aakirkeby',
  'anterwp': 'antwerp',
  'antwerpen': 'antwerp',
  'apatamonasterio': 'axpe',
  'atxondo': 'axpe',
  'aumont aubrac': 'peyre en aubrac',
  'autrans meaudre en vercors': 'correncon en vercors',
  'bad peterstal': 'bad peterstal griesbach',
  'barranco': 'lima',
  'beograd': 'belgrade',
  'bowness on windermere': 'windermere',
  'brugge': 'bruges',
  'bruxelles': 'brussels',
  'carmel': 'carmel by the sea',
  'cartagena de indias': 'cartagena',
  'castel del sangro': 'castel di sangro',
  'castellammare di stabia': 'castellamare di stabia',
  'cioccaro': 'cioccaro di penango',
  'cornaredo': 'milan',
  'courchevel 1850': 'courchevel',
  'cracow': 'krakow',
  'curtiba': 'curitiba',
  'dc': 'washington dc',
  'deidenheim': 'deidesheim',
  'donostia': 'san sebastian',
  'donostia san sebastian': 'san sebastian',
  'dublin 2': 'dublin',
  'dublin city': 'dublin',
  'east wallhouses': 'newcastle',
  'eijsden margraten': 'eijsden',
  'el puerto de santa maria': 'cadiz',
  'errenteria': 'san sebastian',
  'firenze': 'florence',
  'frankfurt on the main': 'frankfurt',
  'freiburg': 'freiburg im breisgau',
  'gipuzkoa': 'san sebastian',
  'glasgow city': 'glasgow',
  'gothenberg': 'gothenburg',
  'gronigen': 'groningen',
  'guetaria': 'getaria',
  'guia de isora tenerife': 'guia de isora',
  'hameau de st marcel saint martin de belleville': 'saint martin de belleville',
  'hannover': 'hanover',
  'heidelburg': 'heidelberg',
  'heist': 'knokke heist',
  'isola vulcano': 'vulcanello',
  'urla': 'izmir',
  'jiminez de jamuz': 'jimenez de jamuz',
  'knokke': 'knokke heist',
  'konstanz': 'constance',
  'kruisem': 'kruishoutem',
  'l herbaudiere': 'noirmoutier',
  'la madelaine sous montreuil': 'montreuil',
  'lasarte': 'san sebastian',
  'lasarte oria': 'san sebastian',
  'lech am arlberg': 'lech',
  'lisboa': 'lisbon',
  'luzern': 'lucerne',
  'macao': 'macau',
  'makati': 'manila',
  'makati city': 'manila',
  'makati metro manila': 'manila',
  'malfa salina': 'malfa',
  'mallorca': 'alcudia',
  'manhattan': 'new york',
  'manilla': 'manila',
  'marrakesh': 'marrakech',
  'metro manila': 'manila',
  'miami beach': 'miami',
  'mieming': 'obermieming',
  'milano': 'milan',
  'miraflores': 'lima',
  'molnlycke': 'malfa',
  'montemerano manciano': 'montemerano',
  'montemor o novo alentejo': 'montemor o novo',
  'new taipei': 'taipei',
  'new york city': 'new york',
  'newcastle upon tyne': 'newcastle',
  'noirmoutier en l ile': 'noirmoutier',
  'oaxaca de juarez': 'oaxaca',
  'oberlech': 'lech',
  'old amersham': 'amersham',
  'oldsted': 'oldstead',
  'pontevedra': 'poio',
  'port d alcudia': 'alcudia',
  'puerta de santa maria': 'cadiz',
  'quebec city': 'quebec',
  'rickenbach sz': 'rickenbach',
  'rubano': 'padua',
  'rio de janiero': 'rio de janeiro',
  'saint martin d uriage': 'uriage les bains',
  'saint petersbourg': 'saint petersburg',
  'saint remy de provence': 'saint remy',
  'san pietro all olmo cornaredo': 'milan',
  'san salvador de poio': 'poio',
  'sankt gallen': 'st gallen',
  'sarmeola di rubano': 'padua',
  'schloss bensberg': 'bergisch gladbach',
  'schwyz': 'rickenbach',
  'sentjost nad horjulom': 'horjul',
  'shenzen': 'shenzhen',
  'simrisham': 'simrishamn',
  'sint kwintens lennik': 'lennik',
  'skillinge': 'simrishamn',
  'st anton em arlburg': 'sankt anton am arlberg',
  'starnberg': 'carmel by the sea',
  'stavenger': 'stavanger',
  'sutp nar mevkii urla': 'izmir',
  'tallin': 'tallinn',
  'tel aviv jaffo': 'tel aviv',
  'telese terme': 'telese',
  'tirolo': 'tirol',
  'torino': 'turin',
  'urdaitz': 'urdaniz',
  'vaihingen an der enz rosswag': 'vaihingen an der enz',
  'valenica': 'valencia',
  'valle de guadalupe': 'guadalupe',
  'venezia': 'venice',
  'vitacura': 'santiago',
  'vulcano island': 'vulcanello',
  'vysoky ujezd u berouna': 'vysoky ujezd',
  'washington': 'washington dc',
  'washington dc metro': 'washington dc',
  'wien': 'vienna',
  // Batch 7 (Jul 19) — verified spelling/typo folds, each carried by one venue.
  'sankt moritz': 'saint moritz',   // Da Vittorio at Carlton Hotel St. Moritz (Michelin: Saint Moritz)
  'ninjang': 'nanjing',             // 江南小灶 JiangNan Wok — "Ninjang" is a garbled Nanjing
  'koln': 'cologne',
  'st helena': 'saint helena',      // Press Restaurant (Wine Spectator Grand Award, Napa Valley)

  // Batch 3 — dead-safe spelling-variant folds (verified against geo_audit /
  // Places Enrichment, July 3, 2026). Each pair is the SAME real city, just a
  // native-language or full-vs-short spelling — zero risk of merging two
  // different places. Clears 30 venues across 4 aliases.
  'munchen': 'munich',
  'nurnberg': 'nuremberg',
  'lindau im bodensee': 'lindau',
  'frankfurt am main': 'frankfurt',

  // Batch 3b — surfaced by re-auditing against LIVE data after Batch 3a (the
  // prior geo_audit tab this project was working from had gone stale and was
  // hiding these). Same standard: same real place, different label, verified
  // parent has far more venues than the variant. July 3, 2026.
  'brooklyn': 'new york',                 // NYC borough (queens/manhattan already aliased — brooklyn was missing)
  'cuauhtemoc': 'mexico city',             // Mexico City borough (alcaldía)
  'miguel hidalgo': 'mexico city',         // Mexico City borough (alcaldía)
  'alvaro obregon': 'mexico city',         // Mexico City borough (alcaldía)
  'washington d c': 'washington dc',       // "Washington, D.C." (with periods) normalizes differently than "Washington"
  'penang': 'george town',                 // Penang = island/state; George Town is the actual city

  // Batch 4 — one-off green folds (verified July 4, 2026 against the live
  // venues tab: each source label below is carried by EXACTLY ONE venue and
  // shares that venue's place_id with the target city, so the alias renames
  // only that single restaurant — zero collateral damage to other venues.
  // Clears 24 restaurants (26 alias entries; two venues had two stray labels).
  'schwarzenburg': 'grub',                 // Landgasthaus Bären Grub
  'utzenstorf': 'grub',                    // Landgasthaus Bären Grub
  'berghaupten': 'sonnenbuhl',             // Restaurant Hirsch
  'ellwangen': 'sonnenbuhl',               // Restaurant Hirsch
  'huelva': 'linares de la sierra',        // Arrieros
  'gro heubach': 'freiamt',                // Gasthaus Zur Krone
  'dellach': 'maria worth',                // Gourmet Restaurant Hubert Wallner
  'sulzbach laufen': 'staufen im breisgau',// Hotel-Restaurant Die Krone
  'unternberg': 'neufelden',               // Hotel-Restaurant Mühltalhof
  'westerlo': 'tongerlo',                  // Maison Colette
  'fohr wyk': 'wyk',                       // Restaurant Alt Wyk
  'santanna': 'marina di bibbona',         // Restaurant La Pineta
  'grisons': 'furstenau',                  // Restaurant OZ (Andreas Caminada cluster)
  'ebersecken': 'wengi bei buren',         // Restaurant Sonne Scheunenberg
  'ollon': 'crissier',                     // Restaurant de l'Hotel de Ville de Crissier
  'vernazza': 'marina di gioiosa ionica',  // Ristorante Gambero
  'santa maria annunziata': 'tavarnelle val di pesa', // Ristorante La Torre
  'treviglio': 'scorze',                   // Ristorante San Martino
  'sicily': 'licata',                      // Ristorante la Madia
  'corral del risco': 'punta de mita',     // Rubra
  'naurath': 'naurath wald',               // Ruessels Landhaus
  'halle': 'halle saale',                  // Speiseberg
  'collingwood': 'creemore',               // The Pine
  'oudenberg': 'oudenburg',                // Willem Hiele
  'powys': 'machynlleth',                  // Ynyshir Restaurant & Rooms
  'rugen': 'ostseebad binz',               // freustil
// Batch 7 (Jul 19) — verified spelling/typo folds, each carried by one venue.
  'sankt moritz': 'saint moritz',   // Da Vittorio at Carlton Hotel St. Moritz (Michelin: Saint Moritz)
  'ninjang': 'nanjing',             // 江南小灶 JiangNan Wok — "Ninjang" is a garbled Nanjing
 'koln': 'cologne',
  };

// Normalizes a city string to its canonical key, applying the alias map.
function cityKey_(city) {
  var k = normKey_(city || '');
  return CITY_ALIASES_[k] ? CITY_ALIASES_[k] : k;
}

// CITY_DISAMBIGUATE_ — ADDED July 23 2026. For city NAMES that legitimately
// refer to more than one real place. Only fires for the exact keys listed
// here; every other city is completely unaffected. Each entry lists country
// strings that route to a DIFFERENT slug; any country not listed falls
// through to the default (unchanged) slug, which stays the more prominent /
// higher-venue-count real city. See CompassEats-City-Identity-Collision-
// Handoff.md (July 20 2026), section 2b, for the research behind this list.
// Do NOT add entries here for cities that are just spelling/label variants
// of ONE real place — that's what CITY_ALIASES_ above is for. This map is
// only for genuinely different places that happen to share a name.
var CITY_DISAMBIGUATE_ = {
  'baltimore':  { 'ireland': 'baltimore-ie' },                        // default: Baltimore, MD (US)
  'birmingham': { 'united states': 'birmingham-al', 'usa': 'birmingham-al', 'us': 'birmingham-al' }, // default: Birmingham, UK
  'venice':     { 'united states': 'venice-fl', 'usa': 'venice-fl', 'us': 'venice-fl' },             // default: Venice, Italy
  'cambridge':  { 'united states': 'cambridge-ma', 'usa': 'cambridge-ma', 'us': 'cambridge-ma',
                  'canada': 'cambridge-on' },                          // default: Cambridge, UK
  'cordoba':    { 'argentina': 'cordoba-ar' },                         // default: Córdoba, Spain
  'la paz':     { 'mexico': 'la-paz-mx' },                             // default: La Paz, Bolivia
  'munster':    { 'france': 'munster-fr' }                            // default: Münster, Germany
};

// Given an already-alias-resolved city key and the venue's raw country string,
// returns a DIFFERENT slug key only for the confirmed collisions above. Every
// other city passes through unchanged, so this cannot affect any other slug.
function disambiguateCityKey_(ck, countryRaw) {
  var rule = CITY_DISAMBIGUATE_[ck];
  if (!rule) return ck;
  var c = normKey_(countryRaw || '');
  for (var variant in rule) {
    if (c === variant || c.indexOf(variant) !== -1) return rule[variant];
  }
  return ck; // country didn't match a listed variant -> stays the default city
}

var CITY_DISPLAY_ = {
  'aix-en-provence': 'Aix-en-Provence',
  'ambleside': 'Ambleside',
  'antwerp': 'Antwerp',
  'azay-le-rideau': 'Azay-le-Rideau',
  'bad-neuenahr-ahrweiler': 'Bad Neuenahr-Ahrweiler',
  'baden-baden': 'Baden-Baden',
  'barcelona': 'Barcelona',
  'belgrade': 'Belgrade',
  'bengaluru': 'Bengaluru',
  'bourg-charente': 'Bourg-Charente',
  'bruges': 'Bruges',
  'brussels': 'Brussels',
  'cadiz': 'Cádiz',
  'cairo': 'Cairo',
  'cancun': 'Cancún',
  'canterbury': 'Canterbury',
  'cartmel': 'Cartmel',
  'clermont-ferrand': 'Clermont-Ferrand',
  'conques-en-rouergue': 'Conques-en-Rouergue',
  'copenhagen': 'Copenhagen',
  'correncon-en-vercors': 'Corrençon-en-Vercors',
  'courchevel': 'Courchevel',
  'dublin': 'Dublin',
  'edinburgh': 'Edinburgh',
  'evian-les-bains': 'Évian-les-Bains',
  'frankfurt': 'Frankfurt',
  'glasgow': 'Glasgow',
  'gothenburg': 'Gothenburg',
  'grenzach-wyhlen': 'Grenzach-Wyhlen',
  'grindavik': 'Grindavík',
  'guadalupe': 'Guadalupe',
  'hong-kong': 'Hong Kong',
  'horsham': 'Horsham',
  'izmir': 'İzmir',
  'knokke-heist': 'Knokke-Heist',
  'la-teste-de-buch': 'La Teste-de-Buch',
  'les-sables-dolonne': 'Les Sables-d\'Olonne',
  'lisbon': 'Lisbon',
  'lisle-sur-la-sorgue': 'L\'Isle-sur-la-Sorgue',
  'los-angeles': 'Los Angeles',
  'lyon': 'Lyon',
  'macau': 'Macau',
  'malaga': 'Málaga',
  'manila': 'Manila',
  'marcq-en-bar-ul': 'Marcq-en-Barœul',
  'marrakech': 'Marrakech',
  'massa-lubrense': 'Massa Lubrense',
  'merida': 'Mérida',
  'miami': 'Miami',
  'milan': 'Milan',
  'monaco': 'Monaco',
  'montemor-o-novo': 'Montemor-o-Novo',
  'monterrey': 'Monterrey',
  'montreal': 'Montréal',
  'montreuil': 'Montreuil',
  'munster': 'Münster',
  'new-york': 'New York',
  'newcastle': 'Newcastle upon Tyne',
  'noirmoutier-en-lile': 'Noirmoutier-en-l\'Île',
  'oaxaca': 'Oaxaca',
  'paliseul': 'Paliseul',
  'panama-city': 'Panama City',
  'peyre-en-aubrac': 'Aumont-Aubrac',
  'poio': 'Pontevedra',
  'porto': 'Porto',
  'puy-en-velay': 'Puy-en-Velay',
  'redwood-city': 'Redwood City',
  'reims': 'Reims',
  'riga': 'Riga',
  'rio-de-janeiro': 'Rio de Janeiro',
  'rottach-egern': 'Rottach-Egern',
  'saint-bonnet-le-froid': 'Saint-Bonnet-le-Froid',
  'saint-emilion': 'Saint-Émilion',
  'saint-petersburg': 'Saint Petersburg',
  'saint-remy': 'Saint-Rémy',
  'san-jose': 'San José',
  'san-sebastian': 'San Sebastián',
  'sankt-anton-am-arlberg': 'Sankt Anton am Arlberg',
  'senigallia': 'Senigallia',
  'serralunga-dalba': 'Serralunga d\'Alba',
  'sydney': 'Sydney',
  'sylt': 'Sylt',
  'taipei': 'Taipei',
  'talloires-montmin': 'Talloires-Montmin',
  'tbilisi': 'Tbilisi',
  'tel-aviv': 'Tel Aviv',
  'urdaniz': 'Urdániz',
  'uriage-les-bains': 'Uriage-les-Bains',
  'valencia': 'Valencia',
  'venice': 'Venice',
  'venice-fl': 'Venice, Florida',        // ADDED July 23 2026 — split from 'venice' (Italy)
  'washington-dc': 'Washington',
  'zurich': 'Zürich',
  // ADDED August 2 2026 — the seven city-collision splits need DISTINCT display
  // names, not just distinct slugs. Two reasons: (1) generateRegionsTab matches
  // cities to regions by DISPLAY NAME, so two cities sharing one name silently
  // collide there and the region gets whichever sorts last (this actually
  // happened: Veneto picked up Venice, Florida). (2) Without distinct labels the
  // split is invisible to visitors — two separate city pages both reading
  // "Venice". The more prominent / higher-venue-count city keeps the plain name;
  // the split side carries the qualifier.
  'baltimore-ie': 'Baltimore, Ireland',
  'birmingham-al': 'Birmingham, Alabama',
  'cambridge-ma': 'Cambridge, Massachusetts',
  'cambridge-on': 'Cambridge, Ontario',
  'cordoba-ar': 'Córdoba, Argentina',
  'la-paz-mx': 'La Paz, Mexico',
  'munster-fr': 'Munster, France',
};

// Slugs whose CITY_DISPLAY_ value is DELIBERATELY a qualified form of the raw
// city name ("Venice, Florida" for raw "Venice"). Without this, cityDisplay_
// sees display != raw and helpfully derives a neighborhood — so every venue in
// Venice FL would get a neighborhood of "Venice". These are the only slugs
// where that inference should be skipped; the general logic is untouched.
var CITY_DISPLAY_QUALIFIED_ = {
  'baltimore-ie': 1, 'birmingham-al': 1, 'venice-fl': 1, 'cambridge-ma': 1,
  'cambridge-on': 1, 'cordoba-ar': 1, 'la-paz-mx': 1, 'munster-fr': 1
};

// Canonical display label + true town for a venue, given its city_slug and raw source city.
// Returns {display, neighborhood}. If the slug has a canonical label and the raw city
// differs from it (ignoring accents/case), the raw city is preserved as the neighborhood.
function cityDisplay_(cslug, rawCity) {
  var canon = CITY_DISPLAY_[cslug];
  if (!canon) return { display: rawCity || '', neighborhood: '' };
  // Deliberately-qualified split cities ("Venice, Florida" for raw "Venice"):
  // the difference is intentional, not a neighborhood signal.
  if (CITY_DISPLAY_QUALIFIED_[cslug]) return { display: canon, neighborhood: '' };
  var a = normKey_(canon), b = normKey_(rawCity || '');
  // Suppress pseudo-neighborhoods that are just the canonical name with a generic
  // suffix/prefix (e.g. "New York City" vs "New York", "Dublin City" vs "Dublin",
  // "Glasgow City", "Donostia / San Sebastián" containing "San Sebastián").
  var bStripped = b.replace(/\b(city|stad|cidade|ciudad|metro|greater)\b/g, ' ').replace(/\s+/g, ' ').trim();
  var pseudo = (b === a) || (bStripped === a) || (b.indexOf(a) !== -1 && (b.length - a.length) <= 12 && /\b(city|metro|greater|jaffo|de juarez)\b/.test(b));
  var hood = (b && b !== a && !pseudo) ? rawCity : '';
  return { display: canon, neighborhood: hood };
}


function slugify_(name, fallbackSeed) {
  var s = name ? stripAccents_(String(name)).toLowerCase() : '';
  s = s.replace(/[^a-z0-9]+/g, '-');
  s = s.replace(/-+/g, '-').replace(/^-|-$/g, '');
  if (s && /^[a-z]/.test(s)) return s;
  // Name had no ASCII characters (CJK/Thai/etc.) → derive from the seed
  if (fallbackSeed) {
    var tail = String(fallbackSeed).toLowerCase().replace(/[^a-z0-9]+/g, '').slice(-6);
    if (tail) return 'venue-' + tail;
  }
  return '';
}

/** Loose tab-name match: ignores apostrophes, case, extra spaces. */
function looseName_(s) {
  return String(s).toLowerCase().replace(/[''`]/g, '').replace(/\s+/g, ' ').trim();
}

function findSheet_(ss, wantName) {
  var want = looseName_(wantName);
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    if (looseName_(sheets[i].getName()) === want) return sheets[i];
  }
  return null;
}

function toInt_(v) {
  if (v === null || v === undefined || v === '') return null;
  var n = Number(v);
  return isNaN(n) ? null : Math.round(n);
}

function splitLocation_(loc) {
  if (!loc) return [null, null];
  var parts = String(loc).split(',').map(function (p) { return p.trim(); });
  if (parts.length === 1) return [parts[0], null];
  return [parts[0], parts[parts.length - 1]];
}

function parseAddrCityCountry_(addr) {
  if (!addr) return [null, null];
  var parts = String(addr).split(',').map(function (p) { return p.trim(); });
  if (parts.length < 2) return [null, null];
  var country = parts[parts.length - 1];
  var city = parts[parts.length - 2].replace(/^\d{4,}\s*/, '').replace(/\s*\d{4,}$/, '');
  return [city || null, country || null];
}

// ---------------------------------------------------------------------------
// Per-tab row parsers → { name, city, country, cuisine?, force_type?, award{} }
// ---------------------------------------------------------------------------

function parseRow_(tabName, slug, defYear, row) {
  function v(i) { return row[i] === undefined ? null : row[i]; }

  if (slug === 'michelin') {
    var loc = splitLocation_(v(2));
    return { name: v(1), city: loc[0], country: loc[1], cuisine: v(4),
      award: { source: 'michelin', year: 2025,
               category: v(0) ? String(v(0)).trim() : 'Selected' } };
  }
  if (slug === '__50best__') {
    var isBar = String(v(2)).trim().toLowerCase() === 'bar';
    var src = isBar ? 'worlds-50-best-bars' : 'worlds-50-best-restaurants';
    var city = v(4), country = v(5);
    if (city && String(city).indexOf(',') >= 0) {
      var sp = splitLocation_(city); city = sp[0]; country = country || sp[1];
    }
    var rank = toInt_(v(1));
    return { name: v(3), city: city, country: country,
      force_type: isBar ? 'bar' : 'restaurant',
      award: { source: src, year: toInt_(v(0)) || 2025,
               category: rank ? ('No. ' + rank) : 'Listed', rank: rank } };
  }
  if (slug === '__bars__') {
    // "Bar Awards" tab written by the bar-ingest tool.
    // Columns: source_slug, year, rank, name, city, country, category_override
    var bsrc = String(v(0) || '').trim();
    if (!bsrc) return null;
    var brank = toInt_(v(2));
    var bcat = v(6) ? String(v(6)).trim() : (brank ? ('No. ' + brank) : 'Listed');
    return { name: v(3), city: v(4), country: v(5), force_type: 'bar',
      award: { source: bsrc, year: toInt_(v(1)) || 2025,
               category: bcat, rank: brank } };
  }
  if (slug === '__restaurants__') {
    // "Restaurant Awards" tab written by the restaurant-ingest tool.
    // Columns: source_slug, year, rank, name, city, country,
    //          category_override, cuisine, price_band
    var rsrc = String(v(0) || '').trim();
    if (!rsrc) return null;
    var rrank = toInt_(v(2));
    var rcat = v(6) ? String(v(6)).trim() : (rrank ? ('No. ' + rrank) : 'Listed');
    return { name: v(3), city: v(4), country: v(5),
      cuisine: v(7) ? String(v(7)).trim() : null,
      price_band: v(8) ? String(v(8)).trim() : null,
      force_type: 'restaurant',
      award: { source: rsrc, year: toInt_(v(1)) || 2025,
               category: rcat, rank: rrank } };
  }
  if (slug === 'best-chef-awards') {
    var loc2 = splitLocation_(v(4));
    var k = toInt_(v(3));
    return { name: v(2), city: loc2[0], country: loc2[1],
      award: { source: 'best-chef-awards', year: toInt_(v(0)) || 2025,
               category: k ? (k + '-Knife') : 'Recognized' } };
  }
  if (slug === 'james-beard') {
    return { name: v(3), city: v(4), country: 'United States',
      award: { source: 'james-beard', year: toInt_(v(0)) || 2025,
               category: v(1) ? String(v(1)).trim() : 'Award' } };
  }
  if (slug === 'pinnacle-guide') {
    var p = toInt_(v(0));
    return { name: v(2), city: v(3), country: v(4), force_type: 'bar',
      award: { source: 'pinnacle-guide', year: toInt_(v(1)) || 2026,
               category: p ? (p + '-Pin') : 'Recognized', rank: p } };
  }
  if (slug === 'spirited-awards') {
    return { name: v(2), city: v(3), country: v(5), force_type: 'bar',
      award: { source: 'spirited-awards', year: toInt_(v(0)) || 2024,
               category: v(1) ? String(v(1)).trim() : 'Award' } };
  }
  if (slug === 'oad') {
    var r = toInt_(v(0));
    return { name: v(1), city: v(2), country: v(4), cuisine: v(5),
      award: { source: 'oad', year: defYear,
               category: r ? ('No. ' + r) : 'Listed', rank: r } };
  }
  if (slug === '101-best-steakhouses') {
    // 2026 layout: Rank, Restaurant, City, Country | 2025 layout: Rank, Restaurant, Location
    var r2 = toInt_(v(0));
    var name, city, country;
    if (v(3) !== null && v(3) !== '') { // has Country col → 2026 layout
      name = v(1); city = v(2); country = v(3);
    } else {
      name = v(1); var loc3 = splitLocation_(v(2)); city = loc3[0]; country = loc3[1];
    }
    return { name: name, city: city, country: country,
      award: { source: '101-best-steakhouses', year: defYear,
               category: r2 ? ('No. ' + r2) : 'Listed', rank: r2 } };
  }
  return null;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function reshapeCompassEats() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var log = []; Logger.log('ALIAS KEYS AT RUNTIME: ' + Object.keys(CITY_ALIASES_).length);

  // 1) Enrichment lookup: normalizedKey → geo
  var enrichSheet = findSheet_(ss, ENRICHMENT_TAB);
  if (!enrichSheet) throw new Error('Could not find a "' + ENRICHMENT_TAB + '" tab.');
  var enrichVals = enrichSheet.getDataRange().getValues();
  var enrich = {};
  for (var i = 1; i < enrichVals.length; i++) {
    var er = enrichVals[i];
    var key = er[0];
    if (!key) continue;
    var placeId = er[3];
    if (!(key in enrich) || (placeId && !enrich[key].place_id)) {
      enrich[key] = {
        canonical: er[1], place_id: placeId,
        lat: er[4], lng: er[5], photo: er[6],
        address: er[7], status: er[8],
        // ADDED July 21 2026: durable price fallback (see handoff §6).
        // Places Enrichment columns are: key, canonicalName, sheetName,
        // placeId, lat, lng, photoName, formattedAddress, businessStatus,
        // lastVerified (confirmed from live sheet screenshot, July 21 2026).
        // price_level goes AFTER lastVerified, so it's index 10, not 9.
        price_level: er[10] || null
      };
    }
  }
 log.push('Enrichment keys: ' + Object.keys(enrich).length);

  // 1b) Load the closed-venue exclusion list (if the tab exists)
  var closedSet = {};
  var closedSheet = findSheet_(ss, 'closed_venues');
  if (closedSheet) {
    var closedVals = closedSheet.getDataRange().getValues();
    for (var ci = 1; ci < closedVals.length; ci++) {
      var cn = closedVals[ci][0];
      var cc = closedVals[ci][1];
      if (cn) {
        closedSet[normKey_(cn) + '|' + normKey_(cc || '')] = true;
      }
    }
  }
  log.push('Closed-venue exclusions: ' + Object.keys(closedSet).length);

  // 2) Walk award tabs → accumulate venues by identity (placeId || normKey)
  var venues = {};
  var unmatched = 0;
  var closedExcluded = 0;

  for (var tabName in SOURCE_MAP) {
    var sheet = findSheet_(ss, tabName);
    if (!sheet) { log.push('SKIP (tab not found): ' + tabName); continue; }
    var slug = SOURCE_MAP[tabName][0];
    var defYear = SOURCE_MAP[tabName][1];
    var vals = sheet.getDataRange().getValues();

    for (var rI = 1; rI < vals.length; rI++) {
      var row = vals[rI];
      if (!row || row.join('') === '') continue;
      var rec = parseRow_(tabName, slug, defYear, row);
      if (!rec || !rec.name) continue;

      var nk = normKey_(rec.name);
      var ck = cityKey_(rec.city || '');   // canonicalized city key (applies alias map)
      var geo = enrich[nk + '|' + ck] || enrich[nk] || null;
      // Identity = name + city so same-name venues in different cities never
      // merge. Awards/type land in the bucket matching their own city.
      // Geo (place_id) is still attached, but does NOT collapse two cities into one.
      var identity = nk + '|' + ck;
      if (!geo) unmatched++;

      if (!venues[identity]) {
        var vtype = rec.force_type ||
          (BAR_SOURCES[rec.award.source] ? 'bar' : 'restaurant');
        var city = rec.city, country = rec.country;
        if (geo && geo.address) {
          var ac = parseAddrCityCountry_(geo.address);
          city = city || ac[0]; country = country || ac[1];
        }
        venues[identity] = {
          name: (geo && geo.canonical) ? geo.canonical : rec.name,
          city: city, country: country, type: vtype,
          cuisine: rec.cuisine || null,
          // ADDED July 21 2026: fall back to Places Enrichment's price when the
          // award tab (Restaurant Awards) has no price_band of its own — this is
          // what keeps a Google-Places price backfill alive across reshape runs.
          price_band: rec.price_band || (geo && geo.price_level) || null,
          place_id: geo ? geo.place_id : null,
          lat: (geo && geo.lat !== '') ? geo.lat : null,
          lng: (geo && geo.lng !== '') ? geo.lng : null,
          address: geo ? geo.address : null,
          status_raw: geo ? geo.status : null,
          awards: []
        };
      }
      var V = venues[identity];
      if (rec.force_type === 'bar' || BAR_SOURCES[rec.award.source]) V.type = 'bar';
      if (rec.cuisine && !V.cuisine) V.cuisine = rec.cuisine;
      if (rec.price_band && !V.price_band) V.price_band = rec.price_band;
      V.awards.push(rec.award);
    }
    log.push('Parsed: ' + tabName);
  }

  // 3) Split into complete vs needs-enrichment, build rows
  var venueRows = [];
  var needsRows = [];
  var slugSeen = {};
  var cityCount = {};

  for (var id in venues) {
    var v = venues[id];

    // dedupe awards
    var seen = {}, awards = [];
    for (var a = 0; a < v.awards.length; a++) {
      var aw = v.awards[a];
      var sig = aw.source + '|' + aw.year + '|' + aw.category;
      if (seen[sig]) continue;
      seen[sig] = true;
      var clean = { source: aw.source, year: aw.year, category: aw.category };
      if (aw.rank) clean.rank = aw.rank;
      awards.push(clean);
    }
 var awardsJson = JSON.stringify(awards);

    // Skip venues marked closed in the closed_venues tab
    var closedKey = normKey_(v.name || '') + '|' + normKey_(v.city || '');
    if (closedSet[closedKey]) {
      closedExcluded++;
      continue;
    }

    var complete = v.place_id && v.lat !== null && v.lat !== '' &&
                   v.lng !== null && v.lng !== '' && v.city;

    if (!complete) {
      needsRows.push([
        v.name || '', v.city || '', v.country || '', v.type,
        awards.length, awardsJson,
        v.place_id || '', (v.lat === null ? '' : v.lat),
        (v.lng === null ? '' : v.lng),
        v.place_id ? 'has placeId, missing coords' :
          (v.city ? 'no placeId' : 'no placeId + no city')
      ]);
      continue;
    }

    var cslug = slugify_(disambiguateCityKey_(cityKey_(v.city), v.country), v.place_id);
    var base = slugify_(v.name);
    if (!base) {
      // CJK/Thai/non-Latin name → build a stable, valid slug from city + placeId tail
      var pidTail = String(v.place_id).toLowerCase().replace(/[^a-z0-9]+/g, '').slice(-6);
      base = (cslug || 'venue') + '-' + pidTail;
    }
    var skey = cslug + '/' + base;
    slugSeen[skey] = (slugSeen[skey] || 0) + 1;
    var vslug = slugSeen[skey] === 1 ? base : base + '-' + slugSeen[skey];
    var status = 'active';
    if (v.status_raw && v.status_raw !== 'OPERATIONAL') status = 'closed';

    cityCount[cslug] = (cityCount[cslug] || 0) + 1;

    var disp_ = cityDisplay_(cslug, v.city);

    venueRows.push([
      v.place_id,          // id
      vslug,               // slug
      v.name,              // name
      cslug,               // city_slug
      disp_.display,       // city_display
      v.country || '',     // country
      disp_.neighborhood,  // neighborhood
      v.type,              // type
      v.lat,               // lat
      v.lng,               // lng
      v.address || '',     // address
      '',                  // phone
      '',                  // website
      '',                  // reservation_url
      '',                  // hours_json
      v.price_band || '',  // price_tier
      v.cuisine || '',     // cuisine_tags
      '',                  // blurb_short
      '',                  // blurb_long
      '',                  // chef
      awardsJson,          // awards_json
      '',                  // photo_url (Places photoName needs resolving)
      status,              // status
      TODAY                // last_verified
    ]);
  }

  // 4) Write tabs
  var VENUE_HEADERS = ['id','slug','name','city_slug','city_display','country',
    'neighborhood','type','lat','lng','address','phone','website',
    'reservation_url','hours_json','price_tier','cuisine_tags','blurb_short',
    'blurb_long','chef','awards_json','photo_url','status','last_verified'];
  var NEEDS_HEADERS = ['name','city','country','type','award_count',
    'awards_json','place_id','lat','lng','reason'];

  writeTab_(ss, VENUES_TAB, VENUE_HEADERS, venueRows);
  writeTab_(ss, NEEDS_TAB, NEEDS_HEADERS, needsRows);

  var barCount = venueRows.filter(function (r) { return r[7] === 'bar'; }).length;
var msg =
    'Done.\n' +
    'venues tab:           ' + venueRows.length + ' rows\n' +
    '  of which bars:      ' + barCount + '\n' +
    'needs_enrichment tab: ' + needsRows.length + ' rows\n' +
    'distinct cities:      ' + Object.keys(cityCount).length + '\n' +
    'award rows unmatched: ' + unmatched + '\n' +
    'closed excluded:      ' + closedExcluded;
  Logger.log(log.join('\n'));
  Logger.log(msg);
}

function writeTab_(ss, name, headers, rows) {
  var sheet = ss.getSheetByName(name);
  if (sheet) sheet.clear();
  else sheet = ss.insertSheet(name);
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
  if (rows.length) {
    sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  }
  sheet.setFrozenRows(1);
}

// ---------------------------------------------------------------------------
// ONE-TIME CLEANUP — run this once, BEFORE re-running migratePriceToEnrichment
// ---------------------------------------------------------------------------
//
// The July 23 run of migratePriceToEnrichment (the version just above this
// comment used to be a bug) created some rows it shouldn't have: 2 pairs of
// duplicate keys (two different venues sharing a name both got the identical
// plain key instead of being told apart), and ~60 rows with a blank key (from
// venues rows that have a price but no name at all). This deletes every row
// that matches that run's exact "I only wrote a key, a name, and a price"
// signature, confirmed to sit in one contiguous block at the bottom of the
// sheet. Nothing else is touched -- any row with a placeId, coordinates, an
// address, a sheetName, or a lastVerified date is left completely alone.
function cleanupMigrationStubs() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var enrichSheet = findSheet_(ss, ENRICHMENT_TAB);
  if (!enrichSheet) throw new Error('Could not find a "' + ENRICHMENT_TAB + '" tab.');
  var vals = enrichSheet.getDataRange().getValues();
  var headers = vals[0];
  var placeIdCol = headers.indexOf('placeId');
  var latCol = headers.indexOf('lat');
  var lngCol = headers.indexOf('lng');
  var addrCol = headers.indexOf('formattedAddress');
  var sheetNameCol = headers.indexOf('sheetName');
  var statusCol = headers.indexOf('businessStatus');
  var verifiedCol = headers.indexOf('lastVerified');

  function isStub(r) {
    return !r[placeIdCol] && !r[latCol] && !r[lngCol] && !r[addrCol] &&
           !r[sheetNameCol] && !r[statusCol] && !r[verifiedCol];
  }

  var stubRows = []; // 1-indexed sheet row numbers
  for (var i = 1; i < vals.length; i++) {
    if (isStub(vals[i])) stubRows.push(i + 1);
  }

  if (stubRows.length === 0) {
    Logger.log('No stub rows found -- nothing to clean up.');
    return;
  }

  var minRow = stubRows[0], maxRow = stubRows[stubRows.length - 1];
  var contiguous = (stubRows.length === (maxRow - minRow + 1));

  if (contiguous) {
    enrichSheet.deleteRows(minRow, stubRows.length);
  } else {
    stubRows.sort(function(a, b) { return b - a; }); // bottom-up so row numbers don't shift
    for (var d = 0; d < stubRows.length; d++) enrichSheet.deleteRow(stubRows[d]);
  }

  Logger.log('Deleted ' + stubRows.length + ' stub rows (sheet rows ' + minRow + '-' + maxRow +
    (contiguous ? ', one contiguous block' : ', scattered') + '). ' +
    'These only ever held a name key and a price, nothing else, so nothing real was lost. ' +
    'Run migratePriceToEnrichment again to regenerate them correctly.');
}

// ---------------------------------------------------------------------------
// ONE-TIME MIGRATION — run this exactly once, BEFORE the next reshape run
// ---------------------------------------------------------------------------
//
// Copies whatever price_tier values already sit in the `venues` tab (written
// there by the Google Places price backfill, priceBackfillPhase1.gs) into the
// new "price_level" column on Places Enrichment, matched by the SAME
// normKey_(name) + '|' + cityKey_(city) key the reshape lookup already uses.
// Safe to re-run — it only ever fills in a blank price_level cell, it never
// overwrites one that already has a value, and it never touches any other
// column. Does not modify the `venues` tab at all.
//
// HOW TO RUN
//   1. Do the manual step first: add a column named "price_level" as the
//      LAST column on the "Places Enrichment" tab.
//   2. Run → cleanupMigrationStubs (safe no-op if there's nothing to clean).
//   3. Run → migratePriceToEnrichment. Check the execution log for a summary.
//   4. Only after "ambiguous / duplicate" is 0 (or you've reviewed the list
//      logged separately) should you run reshapeCompassEats().
//
// FIXED July 23, 2026 (v2): the original version only ever looked up rows by
// "name|city". Most Places Enrichment rows are keyed by NAME ALONE, so v2
// added a plain-name fallback and a "create a new row" fallback for venues
// with no Enrichment row at all.
//
// FIXED July 23, 2026 (v3): v2's "create a new row" step didn't check
// whether ANOTHER venue in the same run already needed a new row under that
// same plain name -- two different real venues sharing a name (e.g. two
// different "Temple of Heaven"s) could both get a row with the identical
// key, which a later lookup can't tell apart. v3 collects every venue that
// needs a new row first, THEN checks: if a name is only needed once, it gets
// the plain key same as before; if 2+ venues share a name, every one of them
// gets a "name|city" key instead, so nothing collides. v3 also skips venues
// with a blank name (nothing to key them by) instead of creating junk rows
// under an empty key, and if a name matches 2+ existing rows but exactly one
// of them already has a price (i.e. someone already resolved it by hand,
// same as the Le Pavillon NYC case), it uses that one instead of re-flagging
// it as ambiguous every time this runs.
function migratePriceToEnrichment() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  var venuesSheet = ss.getSheetByName(VENUES_TAB);
  if (!venuesSheet) throw new Error('Could not find the "' + VENUES_TAB + '" tab.');
  var venuesVals = venuesSheet.getDataRange().getValues();
  var vHeaders = venuesVals[0];
  var nameCol = vHeaders.indexOf('name');
  var cityDisplayCol = vHeaders.indexOf('city_display');
  var priceCol = vHeaders.indexOf('price_tier');
  if (nameCol < 0 || cityDisplayCol < 0 || priceCol < 0) {
    throw new Error('Expected columns name / city_display / price_tier not found in venues tab.');
  }

  var enrichSheet = findSheet_(ss, ENRICHMENT_TAB);
  if (!enrichSheet) throw new Error('Could not find a "' + ENRICHMENT_TAB + '" tab.');
  var enrichRange = enrichSheet.getDataRange();
  var enrichVals = enrichRange.getValues();
  var eHeaders = enrichVals[0];
  var ePriceCol = eHeaders.indexOf('price_level');
  var eCanonicalCol = eHeaders.indexOf('canonicalName');
  if (ePriceCol < 0) {
    throw new Error('No "price_level" column found on Places Enrichment. ' +
      'Add it as the last column first, then re-run this function.');
  }

  var exactKeyToRow = {};
  var nameOnlyToRows = {};
  for (var i = 1; i < enrichVals.length; i++) {
    var k = enrichVals[i][0];
    if (!k) continue;
    exactKeyToRow[k] = i;
    var namePart = (String(k).indexOf('|') !== -1) ? String(k).split('|')[0] : k;
    if (!nameOnlyToRows[namePart]) nameOnlyToRows[namePart] = [];
    nameOnlyToRows[namePart].push(i);
  }

  var filled = 0, alreadyHadValue = 0, ambiguous = 0, blankPrice = 0, blankName = 0, rawFallbackCount = 0;
  var updates = [];
  var ambiguousLog = [];
  var toCreate = []; // { nameKey, cityKey, vName, price } -- resolved to real rows in a second pass

  for (var r = 1; r < venuesVals.length; r++) {
    var price = venuesVals[r][priceCol];
    if (price === '' || price === null || price === undefined) { blankPrice++; continue; }

    var vName = venuesVals[r][nameCol];
    if (!vName) { blankName++; continue; }

    var vCity = venuesVals[r][cityDisplayCol];
    var nameKey = normKey_(vName);
    if (!nameKey) {
      // normKey_ strips every character that isn't a-z or 0-9, so a name
      // written entirely in a non-Latin script (Japanese, Chinese, etc.)
      // collapses to an empty string -- which would make every such venue
      // collide with every other one. That's a deeper, separate bug in
      // normKey_ itself (used everywhere in this file, not just here) and
      // needs its own careful fix + validation pass, not a same-day patch.
      // For now: fall back to the trimmed raw name so these venues at least
      // don't collide with EACH OTHER during this migration.
      nameKey = String(vName).trim();
      rawFallbackCount++;
    }
    var cKey = cityKey_(vCity);
    var exactKey = nameKey + '|' + cKey;

    var eIdx;
    if (exactKeyToRow[exactKey] !== undefined) {
      eIdx = exactKeyToRow[exactKey];
    } else if (exactKeyToRow[nameKey] !== undefined) {
      eIdx = exactKeyToRow[nameKey];
    } else {
      var candidates = nameOnlyToRows[nameKey];
      if (candidates && candidates.length === 1) {
        eIdx = candidates[0];
      } else if (candidates && candidates.length > 1) {
        var withPrice = candidates.filter(function(idx) { return !!enrichVals[idx][ePriceCol]; });
        if (withPrice.length === 1) {
          eIdx = withPrice[0]; // already resolved by hand -- use it, don't re-flag
        } else {
          ambiguous++;
          ambiguousLog.push(vName + ' (' + vCity + ')');
          continue;
        }
      } else {
        eIdx = undefined;
      }
    }

    if (eIdx !== undefined) {
      if (enrichVals[eIdx][ePriceCol]) { alreadyHadValue++; continue; }
      updates.push([eIdx, price]);
    } else {
      toCreate.push({ nameKey: nameKey, cityKey: cKey, vName: vName, price: price });
    }
  }

  // Names needed only once get a plain key; names shared by 2+ new rows get
  // "name|city" so they never collide with each other.
  var nameCounts = {};
  for (var t = 0; t < toCreate.length; t++) {
    nameCounts[toCreate[t].nameKey] = (nameCounts[toCreate[t].nameKey] || 0) + 1;
  }

  var newRows = [];
  var created = 0;
  var usedKeys = {};
  for (var t2 = 0; t2 < toCreate.length; t2++) {
    var item = toCreate[t2];
    var newKey = (nameCounts[item.nameKey] > 1) ? (item.nameKey + '|' + item.cityKey) : item.nameKey;
    if (usedKeys[newKey]) {
      ambiguous++;
      ambiguousLog.push(item.vName + ' -- same name AND city already queued, review');
      continue;
    }
    usedKeys[newKey] = true;
    var newRow = new Array(eHeaders.length).fill('');
    newRow[0] = newKey;
    if (eCanonicalCol >= 0) newRow[eCanonicalCol] = item.vName;
    newRow[ePriceCol] = item.price;
    newRows.push(newRow);
    created++;
  }

  for (var u = 0; u < updates.length; u++) {
    var rowIdx = updates[u][0];
    var val = updates[u][1];
    enrichSheet.getRange(rowIdx + 1, ePriceCol + 1).setValue(val);
    filled++;
  }

  if (newRows.length > 0) {
    var startRow = enrichSheet.getLastRow() + 1;
    enrichSheet.getRange(startRow, 1, newRows.length, eHeaders.length).setValues(newRows);
  }

  var msg =
    'Migration done.\n' +
    'venues rows with a price_tier value: ' + (filled + alreadyHadValue + created + ambiguous + blankName) + '\n' +
    'matched an existing Enrichment row, price copied in: ' + filled + '\n' +
    'Enrichment row already had a price (left alone):     ' + alreadyHadValue + '\n' +
    'no matching row -- created a new minimal row:        ' + created + '\n' +
    'ambiguous / duplicate -- SKIPPED, review:             ' + ambiguous + '\n' +
    'has a price but no name at all -- SKIPPED:            ' + blankName + '\n' +
    'non-Latin name, used raw-text fallback key (see notes above function): ' + rawFallbackCount + '\n' +
    'venues rows with blank price_tier:                    ' + blankPrice;
  Logger.log(msg);
  if (ambiguousLog.length) {
    Logger.log('Ambiguous / duplicate venues, first 40:\n' + ambiguousLog.slice(0, 40).join('\n'));
  }
}
