#!/usr/bin/env python3
"""Article list test, change tests, 2025 edition test, address test, price compare, city compare, evidence CSV. Old addresses are from data/venues.json and are not written."""
import collections, csv, json, re, unicodedata
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
pg = {l.split('\t')[0]: [dec(x) for x in l.split('\t')] for l in open('venue-pages-read-2026-11-05.tsv', encoding='ascii').read().split('\n')}
assert len(pg) == 91 and all(p[1] == '200' and p[2] == '2026' and p[4] == '' for p in pg.values())
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[0]] = dict(award=p[1], cat=p[2], city=p[5], price=p[7], name='|'.join(p[10:]))
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv').read().split('\n')}
cards = [dec(x).split(' | ') for x in open('relay-mx-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n')]
TM = {'Two Stars': 'a Two Stars', 'One Star': 'a One Star', 'Bib Gourmand': 'a Bib Gourmand'}
for c in cards:
    assert TM[c[0]] in pg[c[1].split('/restaurant/')[1]][3], c
print('tier on venue page agrees, population', len(cards))
# Article paths as read in the browser, Nov 5, 2026.
STAR = "pujol quintonil animalon cocina-de-autor-los-cabos conchas-de-piedra damiana lunario olivea-farm-to-table alcalde-1243800 xokol em esquina-comun expendio-de-maiz gaba la-once-mil masala-y-maiz maximo rosetta sud-777 pangea koli-cocina-de-origen levadura-de-olla-restaurante los-danzantes-oaxaca cocina-de-autor-riviera-maya ha-1208266 le-chique huniik ixi-im la-barra-de-huniik".split()
NEWB = "cultivo el-bambis-cafe el-guero-marinero fauna-1208366 icu jacinto-y-yo los-camellos moyuelo palreal pancho-maiz pueblo-pibil restaurante-casareyna semitas-beto tacos-y-gorditas-elvira vica taquerias-kisin".split()
OLDB = "carmelita-molino-y-cocina casa-marcelo-1210913 humo-y-sal la-cocina-de-dona-esthela la-concheria sabina villa-torel cocina-de-campo-by-agricole flora-s-field-kitchen metate aleli-rooftop caracol-de-mar comal-oculto comedor-jacinta contramar el-vilsito filigrana fugaz galanga-thai-house galea jowong la-89 los-consentidos-del-barrio molino-el-pujol pargot pink-rambo plonk raiz-1208231 siembra-tortilleria tacos-charly tacos-del-valle tacos-los-alexis taqueria-el-jarocho taqueria-los-cocuyos taqueria-los-milanesos ultramarinos-demar vigneron tacos-dona-mary-la-gritona la-olla labo-fermento las-quince-letras tierra-del-sol xaok axiote-cocina-de-mexico cetli mestixa punta-corcho".split()
site = {c[1].split('/restaurant/')[1]: c for c in cards}
print('star article', len(STAR), 'not on site', [s for s in STAR if s not in site], 'site star not article', [k for k, c in site.items() if c[0] != 'Bib Gourmand' and k not in STAR])
ab = NEWB + OLDB
print('bib article', len(ab), 'new', len(NEWB), 'not on site', [s for s in ab if s not in site], 'site bib not article', [k for k, c in site.items() if c[0] == 'Bib Gourmand' and k not in ab])
# Three named promotions, then the whole change tests.
NEWS = ['alcalde-1243800', 'xokol', 'gaba', 'la-once-mil', 'huniik', 'ixi-im', 'la-barra-de-huniik']
def inlive(p, t):
    v = pairs[p][1]; return v in live and live[v]['cat'] == t
print('new stars 2026, population', len(NEWS), 'in live at One Star', [p for p in NEWS if inlive(p, 'One Star')], 'not', [p for p in NEWS if not inlive(p, 'One Star')])
print('new Bibs 2026, population', len(NEWB), 'in live at Bib', [p for p in NEWB if inlive(p, 'Bib Gourmand')])
old = collections.defaultdict(list)
for v in json.load(open('../../data/venues.json', encoding='utf8')):
    if v.get('country') == 'Mexico': old[key(v['name'])].append(v)
def norm(s): return re.sub(r'[^a-z0-9]', '', unicodedata.normalize('NFKD', s.lower()).encode('ascii', 'ignore').decode())
rows = []; gr = collections.Counter(); ad = collections.Counter(); weak = []; pdiff = []; cdiff = []; nop = []
RELABEL = {'alcalde-1243800', 'xokol', 'gaba', 'la-once-mil', 'huniik', 'ixi-im'}
for cat, href, name, loc, pr in cards:
    path = href.split('/restaurant/')[1]; _, v, a, how = pairs[path]; sym = pr.split(' · ')[0]; page = pg[path][5]; note = ''; nm = ''; p = ''; city = loc.split(', ')[0]
    act = 'relabel 2025 to 2026' if path in RELABEL else 'new 2026 row'
    if v == 'NEW': g = 'new venue'; gr[g] += 1
    elif v not in live: g = 'live venue, no Michelin row'; gr[g] += 1; nop.append(name)
    else:
        lv = live[v]; nm = lv['name']; p = lv['price']; g = 'same name' if key(nm) == key(name) else 'name differs'; gr[g] += 1
        o = old.get(key(nm), [])
        if not o: r = 'no old address'
        else:
            cand = [x.get('address') or '' for x in o]
            pc = re.search(r'\b(\d{5})\b', page); street = norm(page.split(',')[0])[:10]
            nums = [x for x in re.findall(r'\b\d+[A-Z]?\b', page.split(',')[0])]
            def t(oa):
                opc = re.search(r'\b(\d{5})\b', oa)
                if pc and opc and pc.group(1) == opc.group(1): return 'same postcode'
                if nums and re.search(r'\b' + nums[0] + r'\b', oa): return 'same street number'
                if street and street in norm(oa): return 'same street'
                return 'different'
            rs = [t(a2) for a2 in cand]
            order = ['same postcode', 'same street number', 'same street', 'different']
            r = min(rs, key=order.index); oa = cand[rs.index(r)]; note = f'old address {oa}'
            if r == 'different': weak.append((name, nm, page, oa))
        ad[r] += 1; note = (r + '; ' + note).strip('; ')
        if p and p != sym: pdiff.append((name, p, sym, cat))
        if not p: nop.append(name)
        M = {'miguelhildalgo': 'mexicocity', 'cuauhtemoc': 'mexicocity', 'alvaroobregon': 'mexicocity', 'sanpedrogarzagarcia': 'monterrey', 'valledeguadalupe': 'guadalupe'}
        cs = key(city); cs = M.get(cs, cs)
        if key(lv['city']) != cs: cdiff.append((name, lv['city'], city)); note += f"; city {lv['city']} vs card {city}"
    rows.append([g, act, cat, name, sym, 'https://guide.michelin.com' + href, page, '' if v == 'NEW' else v, nm, '' if a == '-' else a, p, note])
print(gr, sum(gr.values())); print(ad, sum(ad.values())); print('address different', len(weak)); [print(' ', w) for w in weak]
print('price differs', len(pdiff)); [print(' ', x) for x in pdiff]; print('no price', nop); print('city differs', cdiff)
print('name differs', [(r[3], r[8]) for r in rows if r[0] == 'name differs'])
extra = [
 ['article, no card', 'new 2026 row, article URL', 'Bib Gourmand', 'Pink Rambo', '', 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/mexico-s-most-affordable-restaurants-in-2026', '', 've_55222b26b4', 'Pink Rambo', '9966', '$$', 'row 9966 stays 2025; card 404 on Nov 5, 2026; not on the Selected list; in the Bib article of May 20, 2026; 0 CDX captures in 2026'],
 ['left the guide', 'row stays 2025', 'Bib Gourmand', 'Voraz', '', '', '', 've_4bbcc58a9b', 'Voraz', '9974', '$$', 'Bib 2025 article; card 404 on Nov 5, 2026; not on the Selected list; not in the 2026 article'],
 ['Selected 2026', 'row stays 2025', 'Bib Gourmand', 'Alfonsina', '', 'https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/alfonsina', '', 've_1d246aac4c', 'Alfonsina', '11477', '$$', 'on the 2026 Selected list'],
 ['Selected 2026', 'row stays 2025', 'One Star', 'Taquería El Califa de León', '', 'https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/taqueria-el-califa-de-leon', '', 've_914842591c', 'El Califa de León', '4704', '$', 'One Star 2025; on the 2026 Selected list'],
]
with open('michelin-2026-mexico-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n'); w.writerow(['group', 'action', 'category', 'card_name', 'card_price', 'url', 'card_address', 'venue_id', 'venue_name', 'award_id', 'venue_price', 'note'])
    for r in sorted(rows, key=lambda r: (r[2], r[3])) + extra: w.writerow(r)
