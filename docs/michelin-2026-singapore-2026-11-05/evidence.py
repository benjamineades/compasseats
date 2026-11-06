#!/usr/bin/env python3
"""Pair test by postcode, tier test, price compare, name groups, evidence CSV. Old addresses come from data/venues.json and are not written."""
import collections, csv, hashlib, json, re, sys, unicodedata
S = sys.argv[1]
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
raw = open('venue-pages-read-2026-11-05.tsv', encoding='utf8').read()
esc = ''.join(c if ord(c) < 128 else '\\u%04x' % ord(c) for c in raw)
print('venue pages sha (browser form)', hashlib.sha256(esc.encode()).hexdigest())
pg = {l.split('\t')[0]: l.split('\t')[1:] for l in raw.strip().split('\n')}
assert len(pg) == 142
cards = json.load(open(S + '/cards.json'))
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[0]] = dict(award=p[1], cat=p[2], price=p[7], name='|'.join(p[12:]))
old = [v for v in json.load(open('../../data/venues.json', encoding='utf8')) if v.get('country') == 'Singapore']
oldby = {}
for v in old: oldby.setdefault(key(v['name']), []).append(v)
EXTRA = {'ve_bf2230cf37': 'Imperial Treasure Fine Teochew Cuisine'}
TIER = {'Three Stars': 'Three Stars', 'Two Stars': 'Two Stars', 'One Star': 'One Star', 'Bib Gourmand': 'Bib Gourmand'}
rows = []; gr = collections.Counter(); addr = collections.Counter(); mis = []; pd = []; nop = []
for c in cards:
    a = pg[c['path']]
    assert a[1] == '2026' and TIER[c['cat']] in a[2], c
    lv = live.get(c['venue']); nm = lv['name'] if lv else EXTRA.get(c['venue'], c['name'])
    if c['how'] == 'new-venue': g = 'new venue'
    elif c['how'] == 'new-row': g = 'live venue, new row'
    elif key(c['name']) == key(nm): g = 'same name'
    else: g = 'name differs'
    gr[g] += 1; note = ''
    if g != 'same name' and c['how'] != 'new-venue':
        pc = re.search(r'(\d{6}), Singapore$', a[0]).group(1)
        o = oldby.get(key(nm), [])
        if not o: addr['no old address'] += 1; note = 'no old address'
        else:
            oa = o[0].get('address') or ''
            r = 'same postcode' if pc in oa else 'different'
            addr[r] += 1; note = f'old address {oa}: {r}'
            if r != 'same postcode': mis.append((c['name'], nm, a[0], oa))
    p = lv['price'] if lv else ''
    if lv and p and p != c['sym']: pd.append((c['name'], p, c['sym'], c['cat']))
    if not p: nop.append((c['name'], c['sym']))
    if lv and lv['cat'] != c['cat']: note = (note + f"; tier {lv['cat']} to {c['cat']}").strip('; ')
    rows.append([g, c['cat'], c['name'], c['sym'], c['url'], a[0], c['venue'], nm, c['award'] if c['award'] != '-' else '', p, c.get('slug', ''), note])
print(gr, addr)
print('address differs', len(mis)); [print(' ', m) for m in mis]
print('price differs', len(pd), pd)
print('no price', len(nop), nop)
extra = [
 ['left the guide, closed per press', 'One Star 2025', 'Alma', '', '', '', 've_8b5854c9bd', 'Alma by Juan Amador', '', '', '', 'card 404; last day Aug 15, 2025, reopening as a new concept was announced: https://www.asiaone.com/lifestyle/michelin-starred-restaurant-alma-juan-amador-announces-closure-last-day-aug-15'],
 ['left the guide, closed per press', 'One Star 2025', 'Esora', '', '', '', 've_72e993e4a4', 'Esora', '', '', '', 'card 404; final service Dec 29, 2025: https://omakasesingapore.com/esora-mohamed-sultan-singapore-closed-review/'],
 ['left the guide, status closed already', 'One Star 2025', 'Euphoria', '', '', '', 've_719d6d86e0', 'Euphoria', '', '', '', 'card 404; last day Aug 3, 2025: https://www.thepeakmagazine.com.sg/lifestyle/restaurant-euphoria-closes-down-michelin-star'],
 ['left the guide, no venue', 'One Star 2025', 'Chaleur', '', '', '', '', '', '', '', '', 'card 404; closed in 2025: https://e.vnexpress.net/news/travel/food-recipes/4-michelin-starred-restaurants-in-singapore-removed-from-2026-list-after-closures-5105419.html'],
 ['left the guide, no closure report', 'Bib Gourmand 2025', 'Eminent Frog Porridge & Seafood (Lor 19)', '', '', '', 've_3c60e6d1a2', 'Eminent Frog Porridge & Seafood', '12186', '$', '', 'card 404; not on the Selected list; row stays as 2025 history'],
 ['left the guide, no closure report', 'Bib Gourmand 2025', 'Soon Huat', '', '', '', 've_d6a6b6aac1', 'Soon Huat Goldsmith Pte Ltd', '12240', '$', '', 'card 404; not on the Selected list; row stays as 2025 history; the live name is wrong'],
]
with open('michelin-2026-singapore-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n'); w.writerow(['group', 'category', 'card_name', 'card_price', 'card_url', 'card_address', 'venue_id', 'venue_name', 'award_id_2025', 'venue_price', 'new_slug', 'note'])
    for r in sorted(rows, key=lambda r: (r[1], r[2])) + extra: w.writerow(r)
