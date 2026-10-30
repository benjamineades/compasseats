"""Build the open-items block 1 files (Oct 30, 2026): rename batch 31 (Forentum, Les Fresques), its slug file,
and the Telluride city fix. Run from /home/claude/work with fresh.json and oldcity.json (pulled from the session
transcript by grab.py; markers = the live md5 / the old city id).

  python3 build_open_items_b1.py build       -> decisions txt, CSV, rename SQL, check.sql
  python3 build_open_items_b1.py slug FP      -> slug SQL (after the read-only check gives FP)
  python3 build_open_items_b1.py city FPC FPV -> city SQL (after the read-only check gives the 2 city fingerprints)

Name guards: each new name, lower case, accents removed, spaces to '-', equals the last part of its Michelin 2026
card URL, and equals the card h1 read Oct 30 (minus the " - Château des Vigiers" suffix for Les Fresques, rule R5,
which agrees with the site, rule R1).
"""
import json, hashlib, csv, io, sys, unicodedata

KEY = 'rename-open-items-b1-2026-10-30'
DATE = '2026-10-30'
BEN = "Ben Oct 30 19:46 ET 'Go' (items 1-4), 19:50 ET 'All recommended' (1 = A, 2 = A, 3 = A, 4 = A)"
LIVE_MD5 = '84ff07c365ad979620e198f514f27fe3'
OLD_CITY = 'ci_b8de1219b5'
NEW_CITY_SLUG = 'telluride'
NEW_CITY_DISP = 'Telluride'
ROCKY = 'rg_50e244d435'
VENUE_T = 've_b44e9a2762'

# counts at the fresh read (Oct 30 23:43-23:52 UTC)
B = dict(venues=11304, awards=23353, slugs=12913, nc=1609, listings=11304, blurbs=142, rb=16, rr=1194,
         led_n=120, led_max=164, aud_n=113691, aud_max=118975, cities=3263, aliases=261, redirects=9,
         cls=24005, rocky=6)

ROWS = [  # ordered by venue_id; card h1 and site reads Oct 30 (WebFetch, Ben approved each)
    dict(line=1, venue_id='ve_04c2784726', expected='Lavello', new='Forentum', source='michelin',
         url='https://guide.michelin.com/us/en/basilicata/lavello/restaurant/forentum',
         card_h1='Forentum',
         site='Forentum (title "Home - Forentum", logo alt, footer); "Antica Cantina Forentum a Lavello" (H4) [https://www.forentum.it]',
         rule='rule R1 (site has one form = card h1); our name was the town name',
         slug_note='new slug lavello/forentum is already a non-canonical slug of this venue: reuse'),
    dict(line=2, venue_id='ve_e574aeb7fd', expected='Restaurant Les Fresques une étoile Michelin depuis plus de 10 ans',
         new='Les Fresques', source='michelin',
         url='https://guide.michelin.com/us/en/nouvelle-aquitaine/monestier/restaurant/les-fresques',
         card_h1='Les Fresques - Château des Vigiers',
         site='LES FRESQUES (main menu, section heading); Les Fresques (second menu "Les Fresques, Restaurant Étoilé") [https://vigiers.com/]',
         rule='rule R1 + R3 (site writes Les Fresques in normal case and in capitals) = card h1 minus the hotel suffix (R5); our name had a tagline appended',
         slug_note='new slug monestier/les-fresques (insert)'),
]


def md5(s): return hashlib.md5(s.encode()).hexdigest()
def q(s): return "'" + s.replace("'", "''") + "'"


def url_key(name):
    s = unicodedata.normalize('NFD', name.lower())
    s = ''.join(ch for ch in s if unicodedata.category(ch) != 'Mn')
    return '-'.join(s.split())


def slug_rule(name):  # same as SQL: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g'))
    s = unicodedata.normalize('NFD', name.lower())
    s = ''.join(ch for ch in s if unicodedata.category(ch) != 'Mn')
    out, prev = [], False
    for ch in s:
        if ('a' <= ch <= 'z') or ('0' <= ch <= '9'):
            out.append(ch); prev = False
        elif not prev:
            out.append('-'); prev = True
    return ''.join(out).strip('-')


def note(r):
    return (f'Open items block 1 ({DATE}); live "{r["expected"]}"; card h1 "{r["card_h1"]}"; site read: {r["site"]}; '
            f'{r["rule"]}; new name = Michelin 2026 card name; Michelin card {r["url"]}; {BEN}; read Oct 30')


def load_fresh():
    d = json.load(open('fresh.json'))[0]
    live = [ln.split('|') for ln in d['venues_txt'].split('\n')]
    names = {v[0]: v[1] for v in live}
    for r in ROWS:
        assert names[r['venue_id']] == r['expected'], r['venue_id']
        assert unicodedata.is_normalized('NFC', r['expected']) and unicodedata.is_normalized('NFC', r['new'])
    got = md5('\n'.join(f'{r["venue_id"]}|{names[r["venue_id"]]}' for r in sorted(ROWS, key=lambda r: r['venue_id'])))
    assert got == LIVE_MD5 == d['rename_live_md5'], got
    return d


def guards():
    for r in ROWS:
        assert url_key(r['new']) == r['url'].rstrip('/').split('/')[-1], r['new']
        assert r['card_h1'].startswith(r['new']), r['new']
        assert r['new'] != r['expected'] and r['new'] == r['new'].strip()


def sql_values():
    out = []
    for r in ROWS:
        out.append(f"    ({r['line']}, {q(r['venue_id'])}, {q(r['expected'])}, {q(r['new'])}, {q(r['source'])}, {q(r['url'])}, {q(note(r))})")
    return ',\n'.join(out)


def fps():
    s = sorted(ROWS, key=lambda r: r['venue_id'])
    return dict(
        exp=md5('\n'.join(f"{r['venue_id']}|{r['expected']}" for r in s)),
        new=md5('\n'.join(f"{r['venue_id']}|{r['new']}" for r in s)),
        rows=md5('\n'.join(f"{r['line']}|{r['venue_id']}|{r['expected']}|{r['new']}|{r['source']}|{r['url']}" for r in s)),
        notes=md5('\n'.join(f"{r['venue_id']}|{note(r)}" for r in s)),
    )


def build():
    d = load_fresh(); guards(); f = fps()
    # decisions file
    lines = [f'# Open items block 1, decisions and reads ({DATE})', f'# {BEN}',
             '# Item 1 Telleruide: city ci_b8de1219b5 "Telleruide" (1 venue, 221 South Oak ve_b44e9a2762, OAD 2026 No. 606, no URL).',
             '#   Site https://www.221southoak.com/ : "221 South Oak Street, Telluride, Colorado"; title "221 South Oak | Telluride Restaurant";',
             '#   "Closed For Offseason, We Reopen 12/11" (seasonal; status stays active). Decision A: new city Telluride, venue moved,',
             '#   new slug telluride/221-south-oak, old slug non-canonical, old city row deleted, alias telleruide -> Telluride.',
             '# Item 4 Paloma Taqueria ve_3fad690140: card (Bib 2026, 28 Helwick Street, Wānaka) shows no closure; site notice',
             '#   "Closed for Refurbishment ... back open on June 30" (date passed; old notice). Decision A: no write, item closed.',
             '#   Card and site both write Wānaka (supports the city-label item).',
             'line|venue_id|expected_name|new_name|source|card_url|card_h1|site_read|rule']
    for r in ROWS:
        lines.append('|'.join([str(r['line']), r['venue_id'], r['expected'], r['new'], r['source'], r['url'], r['card_h1'], r['site'], r['rule']]))
    open(f'open-items-b1-decisions-{DATE}.txt', 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    # CSV (rename job input form)
    buf = io.StringIO(); w = csv.writer(buf, lineterminator='\n')
    w.writerow(['venue_id', 'expected_name', 'new_name', 'source_id', 'source_url', 'note'])
    for r in ROWS: w.writerow([r['venue_id'], r['expected'], r['new'], r['source'], r['url'], note(r)])
    open(f'open-items-b1-{DATE}.csv', 'w', encoding='utf-8').write(buf.getvalue())
    # read-only check: proposed slug plan, collisions, city fingerprints
    vals = ', '.join(f"({q(r['venue_id'])}, {q(r['new'])})" for r in ROWS)
    chk = f"""-- CHECK31-{f['new']}
WITH p(venue_id, new_name) AS (VALUES {vals}),
plan AS (
  SELECT v.id venue_id, p.new_name, s.city_slug, s.slug old_slug,
         trim(both '-' from regexp_replace(lower(f_unaccent(p.new_name)), '[^a-z0-9]+', '-', 'g')) new_slug
    FROM p JOIN venues v ON v.id = p.venue_id
    JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical)
SELECT 'CHECK31-{f['new']}' marker,
  (SELECT md5(string_agg(venue_id||'|'||new_name||'|'||city_slug||'|'||old_slug||'|'||new_slug, E'\\n' ORDER BY venue_id)) FROM plan WHERE new_slug <> old_slug) slug_fp,
  (SELECT count(*) FROM plan WHERE new_slug <> old_slug) slug_plan_n,
  (SELECT string_agg(city_slug||'/'||old_slug||' -> '||new_slug, '; ' ORDER BY venue_id) FROM plan) slug_plan,
  (SELECT count(*) FROM plan WHERE new_slug = '') empty_n,
  (SELECT count(*) FROM plan p2 JOIN slugs s ON s.property_id='eats' AND s.city_slug=p2.city_slug AND s.slug=p2.new_slug AND (s.venue_id<>p2.venue_id OR s.is_canonical)) in_use_other,
  (SELECT md5(string_agg(p2.venue_id||'|'||p2.city_slug||'|'||p2.new_slug, E'\\n' ORDER BY p2.venue_id)) FROM plan p2 JOIN slugs s ON s.property_id='eats' AND s.venue_id=p2.venue_id AND s.city_slug=p2.city_slug AND s.slug=p2.new_slug AND NOT s.is_canonical) reuse_fp,
  (SELECT count(*) FROM redirects d, plan p2 WHERE d.from_path IN ('/'||p2.city_slug||'/'||p2.new_slug, '/venue/'||p2.city_slug||'/'||p2.new_slug)) in_redirects,
  (SELECT count(*) FROM p JOIN venues v ON v.id=p.venue_id JOIN venues o ON o.city_id=v.city_id AND o.id<>v.id AND norm_key(o.name)=norm_key(p.new_name)) norm_collisions,
  (SELECT string_agg(p.venue_id||':'||norm_key(p.new_name), ',' ORDER BY p.venue_id) FROM p) new_norm_keys,
  (SELECT md5(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count) FROM cities c WHERE c.id='{OLD_CITY}') city_fp,
  (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key) FROM venues v WHERE v.id='{VENUE_T}') venue_fp,
  (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) FROM venues v WHERE v.id='{VENUE_T}') t_new_slug,
  (SELECT count(*) FROM slugs s WHERE s.property_id='eats' AND s.city_slug='{NEW_CITY_SLUG}') t_slugs_in_new_city,
  (SELECT count(*) FROM redirects d WHERE d.from_path LIKE '/{NEW_CITY_SLUG}/%' OR d.from_path LIKE '/telleruide/%' OR d.to_path LIKE '/telleruide/%') t_redirects;
"""
    open('check31.sql', 'w', encoding='utf-8').write(chk)
    # rename SQL
    rename = RENAME_TMPL
    for k, v in dict(KEY=KEY, VALUES=sql_values(), EXP=f['exp'], NEW=f['new'], ROWS=f['rows'], NOTES=f['notes'],
                     VEN=B['venues'], AWD=B['awards'], SLG=B['slugs'], LST=B['listings'], BLB=B['blurbs'],
                     RB=B['rb'], RB2=B['rb'] + 1, RR=B['rr'], RR2=B['rr'] + 2, LEDN=B['led_n'], LEDN2=B['led_n'] + 1,
                     LEDMAX=B['led_max'], LEDMAX2=B['led_max'] + 1, AUDN=B['aud_n'], AUDMAX=B['aud_max'],
                     AUDMAX2=B['aud_max'] + 2, READ=d['read_at']).items():
        rename = rename.replace('{{' + k + '}}', str(v))
    assert '{{' not in rename
    open(f'rename-open-items-b1-{DATE}.sql', 'w', encoding='utf-8').write(rename)
    print('rename fps', f)
    print('check marker', f'CHECK31-{f["new"]}')


def slug(fp):
    f = fps()
    reuse_fp = md5('ve_04c2784726|lavello|forentum')
    plan_expect = '\n'.join(sorted([
        f've_04c2784726|Forentum|lavello|lavello|{slug_rule("Forentum")}',
        f've_e574aeb7fd|Les Fresques|monestier|{slug_rule(ROWS[1]["expected"])}|{slug_rule("Les Fresques")}']))
    assert md5(plan_expect) == fp, (md5(plan_expect), fp)
    a1n, a1max = B['aud_n'] + 2, B['aud_max'] + 2
    s = SLUG_TMPL
    for k, v in dict(KEY=KEY, FP=fp, REUSE=reuse_fp, SLG=B['slugs'], NC=B['nc'], SLG2=B['slugs'] + 1, NC2=B['nc'] + 1,
                     CAN=B['venues'], VEN=B['venues'], AWD=B['awards'], LST=B['listings'], BLB=B['blurbs'],
                     AUDN=a1n, AUDMAX=a1max, AUDMAX2=a1max + 4).items():
        s = s.replace('{{' + k + '}}', str(v))
    assert '{{' not in s
    open(f'slugs-rename-open-items-b1-{DATE}.sql', 'w', encoding='utf-8').write(s)
    print('slug file written; plan', plan_expect.replace('\n', ' ; '))


def city(fpc, fpv):
    old = json.load(open('oldcity.json'))
    row = json.loads([r for r in old if r['k'] == 'old_city_row'][0]['info'])
    ven = json.loads([r for r in old if r['k'] == 'venue_row'][0]['info'])
    c = row
    calc_c = md5('|'.join([c['id'], c['slug'], c['display'], c['country'], c['country_iso'], c['kind'], c['region_id'] or '-',
                           '-' if c['lat'] is None else str(c['lat']), '-' if c['lng'] is None else str(c['lng']), str(c['venues_count'])]))
    calc_v = md5('|'.join([ven['id'], ven['name'], ven['status'], ven['city_id'], ven['norm_key']]))
    assert calc_c == fpc, (calc_c, fpc)
    assert calc_v == fpv, (calc_v, fpv)
    assert c['id'] == OLD_CITY and c['region_id'] == ROCKY and ven['id'] == VENUE_T and ven['city_id'] == OLD_CITY
    new_id = 'ci_' + md5(NEW_CITY_SLUG)[:10]
    vslug = slug_rule(ven['name'])
    a2n, a2max = B['aud_n'] + 2 + 4, B['aud_max'] + 2 + 4
    s = CITY_TMPL
    for k, v in dict(NEWID=new_id, NEWSLUG=NEW_CITY_SLUG, NEWDISP=NEW_CITY_DISP, OLDID=OLD_CITY, ROCKY=ROCKY, VEN_ID=VENUE_T,
                     VSLUG=vslug, OLDVSLUG='telleruide-kzwzua', FPC=fpc, FPV=fpv, VCOUNT=c['venues_count'],
                     CIT=B['cities'], ALI=B['aliases'], ALI2=B['aliases'] + 1, RED=B['redirects'],
                     SLG=B['slugs'] + 1, NC=B['nc'] + 1, SLG2=B['slugs'] + 2, NC2=B['nc'] + 2, CAN=B['venues'],
                     VEN=B['venues'], AWD=B['awards'], LST=B['listings'], CLS=B['cls'], ROCKYN=B['rocky'],
                     AUDN=a2n, AUDMAX=a2max, AUDMAX2=a2max + 6).items():
        s = s.replace('{{' + k + '}}', str(v))
    assert '{{' not in s
    open(f'cities-telluride-fix-{DATE}.sql', 'w', encoding='utf-8').write(s)
    print('city file written; new id', new_id, 'venue slug', vslug)


RENAME_TMPL = open('tmpl_rename.sql', encoding='utf-8').read() if len(sys.argv) > 1 else ''
SLUG_TMPL = open('tmpl_slug.sql', encoding='utf-8').read() if len(sys.argv) > 1 else ''
CITY_TMPL = open('tmpl_city.sql', encoding='utf-8').read() if len(sys.argv) > 1 else ''

if __name__ == '__main__':
    cmd = sys.argv[1]
    if cmd == 'build': build()
    elif cmd == 'slug': slug(sys.argv[2])
    elif cmd == 'city': city(sys.argv[2], sys.argv[3])
