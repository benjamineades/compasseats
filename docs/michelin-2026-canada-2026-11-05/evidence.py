#!/usr/bin/env python3
"""Address test, price compare, tier and edition test, evidence CSV. Old addresses are from data/venues.json and are not written."""
import collections, csv, json, re, unicodedata
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
def low(s):
    s = unicodedata.normalize('NFKD', s.lower()); return ''.join(c for c in s if not unicodedata.combining(c))
pg = {l.split('\t')[0]: l.split('\t') for l in open('venue-pages-read-2026-11-05.tsv', encoding='utf8').read().split('\n')}
assert len(pg) == 109 and all(p[1] == '200' and p[2] == '2026' and p[4] == '' for p in pg.values())
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[0]] = dict(award=p[1], cat=p[2], city=p[5], price=p[7], name='|'.join(p[10:]))
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv').read().split('\n')}
old = collections.defaultdict(list)
for v in json.load(open('../../data/venues.json', encoding='utf8')):
    if v.get('country') == 'Canada': old[key(v['name'])].append(v)
rows = []; gr = collections.Counter(); ad = collections.Counter(); weak = []; pdiff = []; nop = []; gc = collections.Counter()
for line in open('relay-ca-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n'):
    cat, href, name, loc, pr = dec(line).split(' | '); path = href.split('/restaurant/')[1]; _, v, a, how, guide = pairs[path]
    sym = pr.split(' · ')[0]; page = pg[path][5]; gc[(guide, cat)] += 1; note = ''
    if v == 'NEW':
        g = 'new venue'; gr[g] += 1; nm = ''; p = ''
    else:
        lv = live[v]; nm = lv['name']; p = lv['price']
        g = 'same name' if key(nm) == key(name) else 'name differs'; gr[g] += 1
        o = [x for x in old.get(key(nm), []) if x.get('city_slug') == lv['city']] or old.get(key(nm), [])
        if not o: r = 'no old address'
        else:
            oa = o[0].get('address') or ''
            pc = re.search(r'([A-Z]\d[A-Z]) ?(\d[A-Z]\d)', page); opc = re.search(r'([A-Z]\d[A-Z]) ?(\d[A-Z]\d)', oa)
            num = re.search(r'\d+', page.split(',')[1] if page.startswith(('The ', '3rd')) else page)
            if pc and opc and pc.group(0).replace(' ', '') == opc.group(0).replace(' ', ''): r = 'same postcode'
            elif num and re.search(r'\b' + num.group(0) + r'\b', oa): r = 'same street number'
            else: r = 'different'
            note = f'old address {oa}'
            if r == 'different': weak.append((name, nm, page, oa))
        ad[(guide, r)] += 1; note = (r + '; ' + note).strip('; ')
        if p and p != sym: pdiff.append((name, p, sym, cat))
        if lv['cat'] != cat: note += f"; tier {lv['cat']} to {cat}"
    if not p: nop.append(name)
    rows.append([guide, g, cat, name, sym, 'https://guide.michelin.com' + href, page, '' if v == 'NEW' else v, nm, '' if a == '-' else a, p, note])
print(sorted(gc.items())); print(gr); print(sorted(ad.items()))
print('address different', len(weak)); [print(' ', w) for w in weak]
print('price differs', len(pdiff), pdiff); print('no price', nop)
extra = [
 ['toronto', 'left the guide, reopened', 'One Star 2025', 'Aburi Hana', '', '', '', 've_7b26d42de5', 'Aburi Hana', '8665', '$$$$', 'card 404; closed nearly a year, reopened Sep 17, 2026 with a new concept: https://streetsoftoronto.com/food/restaurants/zero-new-stars-and-a-major-loss-everything-that-went-down-at-torontos-2026-michelin-ceremony/'],
 ['toronto', 'left the guide, status closed already', 'One Star 2025', 'Hexagon', '', '', '', 've_14deab4c46', 'Hexagon Restaurant', '6969', '$$$', 'card 404; closed earlier in 2026, same source as Aburi Hana'],
 ['vancouver', 'dropped to Selected', 'One Star 2025', 'Barbara', '', 'https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/barbara', '305 E. Pender St., Vancouver, V6A 0J3, Canada', 've_8d50ba8fd5', 'Barbara', '8835', '$$$$', 'on the Selected list; Oct 10 ruling: stays active'],
 ['vancouver', 'left the guide, closed per press', 'Bib Gourmand 2025', 'Fable Kitchen', '', '', '', 've_3160c0aec9', 'Fable Kitchen', '12794', '$$', 'card 404; closes Sep 20, 2026 per Daily Hive of Sep 2, 2026: https://dailyhive.com/vancouver/fable-kitchen-vancouver-2026; absent because closed: https://dailyhive.com/vancouver/michelin-guide-vancouver-dropped-restaurants'],
]
with open('michelin-2026-canada-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n'); w.writerow(['guide', 'group', 'category', 'card_name', 'card_price', 'card_url', 'card_address', 'venue_id', 'venue_name', 'award_id_2025', 'venue_price', 'note'])
    for r in sorted(rows, key=lambda r: (r[0], r[2], r[3])) + extra: w.writerow(r)
