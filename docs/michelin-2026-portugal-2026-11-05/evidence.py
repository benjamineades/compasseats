#!/usr/bin/env python3
"""Article list test, 2026 change test, address test, price compare, city compare, evidence CSV. Old addresses are from data/venues.json and are not written."""
import collections, csv, json, re, unicodedata
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
pg = {l.split('\t')[0]: [dec(x) for x in l.split('\t')] for l in open('venue-pages-read-2026-11-05.tsv', encoding='ascii').read().split('\n')}
assert len(pg) == 78 and all(p[1] == '200' and p[2] == '2026' and p[4] == '' for p in pg.values())
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[0]] = dict(award=p[1], cat=p[2], city=p[5], price=p[7], name='|'.join(p[10:]))
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv').read().split('\n')}
cards = [dec(x).split(' | ') for x in open('relay-pt-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n')]
# Star article of March 10, 2026, as read. Two Stars, then One Star. * = new.
TWO = ["Vila Joya","Il Gallo d'Oro","Casa de Chá da Boa Nova","Henrique Sá Pessoa","Belcanto","Fifty Seconds*","Ocean","Antiqvvm","The Yeatman Gastronomic R."]
ONE = ["Gusto by Heinz Beck","Largo do Paço*","Palatial","G Pousada","Fortaleza do Guincho","Kappo*","A Cozinha do Paço*","Alameda*","Desarma","William","A Cozinha","Bon Bon","2Monkeys","CURA","Encanto","EPUR","Feitoria","Grenache","Kabuki Lisboa","Kanazawa","Loco","Marlene","SÁLA de João Sá","YŌSO","MAPA*","Mesa de Lemos","Schistó*","Vista","Blind","dop*","Éon*","Euskalduna Studio","Gastro by Elemento*","In Diferente*","Pedro Lemos","Le Monument","Vila Foz","Herdade do Esporão","Ó Balcão","Lab by Sergi Arola","Midori","A Ver Tavira","Oculto","Vinha"]
c2 = {key(c[2]) for c in cards if c[0] == 'Two Stars'}; c1 = {key(c[2]) for c in cards if c[0] == 'One Star'}
print('article Two', len(TWO), 'missing on site', [n for n in TWO if key(n.strip('*')) not in c2], 'site not article', c2 - {key(n.strip('*')) for n in TWO})
print('article One', len(ONE), 'missing on site', [n for n in ONE if key(n.strip('*')) not in c1], 'site not article', c1 - {key(n.strip('*')) for n in ONE})
new = [(n.strip('*'), 'Two Stars') for n in TWO if n.endswith('*')] + [(n.strip('*'), 'One Star') for n in ONE if n.endswith('*')] + [('Mesa15', 'Bib Gourmand'), ('Taberna Sakra', 'Bib Gourmand')]
byname = {key(c[2]): c for c in cards}; hit = []; miss = []
for n, t in new:
    c = byname[key(n)]; pa = c[1].split('/restaurant/')[1]; v = pairs[pa][1]
    (hit if v != 'NEW' and live[v]['cat'] == t else miss).append(n)
print('2026 change test, population', len(new), 'in live rows at that tier', len(hit), 'not', miss)
# Arkhe = One Star in the 2025 article, not on the site list and not in the live rows.
print('Arkhe in live', any(key(l['name']).startswith('arkhe') for l in live.values()), 'on site', any(key(c[2]).startswith('arkhe') for c in cards))
old = collections.defaultdict(list)
for v in json.load(open('../../data/venues.json', encoding='utf8')):
    if v.get('country') == 'Portugal': old[key(v['name'])].append(v)
def norm(s): return re.sub(r'[^a-z0-9]', '', unicodedata.normalize('NFKD', s.lower()).encode('ascii', 'ignore').decode())
rows = []; gr = collections.Counter(); ad = collections.Counter(); weak = []; pdiff = []; cdiff = []; nop = []
PM = str.maketrans('€', '$')
for cat, href, name, loc, pr in cards:
    path = href.split('/restaurant/')[1]; _, v, a, how = pairs[path]; sym = pr.split(' · ')[0]; page = pg[path][5]; note = ''; nm = ''; p = ''; city = loc.split(', ')[0]
    if v == 'NEW': g = 'new venue'; gr[g] += 1
    else:
        lv = live[v]; nm = lv['name']; p = lv['price']; g = 'same name' if key(nm) == key(name) else 'name differs'; gr[g] += 1
        o = old.get(key(nm), [])
        if not o: r = 'no old address'
        else:
            oa = o[0].get('address') or ''
            pc = re.search(r'\b(\d{4})[- ](\d{3})\b', page); opc = re.search(r'\b(\d{4})[- ](\d{3})\b', oa)
            nums = [x for x in re.findall(r'\b\d+[A-Z]?\b', page.split(',')[0])]
            if pc and opc and pc.groups() == opc.groups(): r = 'same postcode'
            elif nums and re.search(r'\b' + nums[0] + r'\b', oa): r = 'same street number'
            elif pc and opc and pc.group(1) == opc.group(1): r = 'same first 4 of postcode'
            elif norm(page.split(',')[0])[:12] and norm(page.split(',')[0])[:12] in norm(oa): r = 'same street'
            else: r = 'different'
            note = f'old address {oa}'
            if r in ('different',): weak.append((name, nm, page, oa))
        ad[r] += 1; note = (r + '; ' + note).strip('; ')
        if p and p != sym.translate(PM): pdiff.append((name, p, sym, cat))
        if not p: nop.append(name)
        cs = key(city); M = {'lisbon': 'lisbon', 'guimaraes': 'guimaraes', 'portimao': 'portimao'}
        if key(lv['city']) != cs: cdiff.append((name, lv['city'], city)); note += f"; city {lv['city']} vs card {city}"
    rows.append([g, cat, name, sym, 'https://guide.michelin.com' + href, page, '' if v == 'NEW' else v, nm, '' if a == '-' else a, p, note])
print(gr, sum(gr.values())); print(ad, sum(ad.values())); print('address different', len(weak)); [print(' ', w) for w in weak]
print('price differs', len(pdiff)); [print(' ', x) for x in pdiff]; print('no price', nop); print('city differs', cdiff)
print('name differs', [(r[2], r[7]) for r in rows if r[0] == 'name differs'])
extra = [['left the guide', 'Bib Gourmand', 'O Tipico', '', 'https://web.archive.org/web/20260601200735id_/https://guide.michelin.com/pt/pt_PT/aveiro-region/gueda/restaurant/o-tipico', 'Rua Doutor Manuel Alegre 42, Águeda, 3750-139, Portugal', 've_eb0e147299', 'O Tipico', '13031', '$', 'card 404 on Nov 5, 2026; capture June 1, 2026 says 2026 MICHELIN Guide and Bib Gourmand; Noticias de Agueda Apr 4, 2026 renewal; TripAdvisor shows open, 1 visitor Sep 28, 2026 found it closed']]
with open('michelin-2026-portugal-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n'); w.writerow(['group', 'category', 'card_name', 'card_price', 'url', 'card_address', 'venue_id', 'venue_name', 'award_id', 'venue_price', 'note'])
    for r in sorted(rows, key=lambda r: (r[1], r[2])) + extra: w.writerow(r)
