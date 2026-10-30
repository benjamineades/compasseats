#!/usr/bin/env python3
"""Pair Turkey Michelin award rows (DB file) with Turkey star/Bib cards (card file) by name + distinction.
Usage: pair_turkey.py DB_FILE CARD_FILE OUT_PAIRS
DB line: award_id|venue_id|name|status|city|year|category|source_url|price_rows
Card line (tab): card_id<TAB>name<TAB>city<TAB>distinction<TAB>CAT_P0n<TAB>card URL
Out line: venue_id|award_id|card_id|match class|db name|card name   (sorted by venue_id)"""
import sys, unicodedata, re
DIST = {'bib': 'Bib Gourmand', '1 star': 'One Star', '2 star': 'Two Stars', '3 star': 'Three Stars'}
STOP = {'restaurant','restorant','restoran','ristorante','ristorente','butik','boutique','otel','hotel','istanbul','izmir',
        'bodrum','urla','bitez','tarihi','ugur','the','by','and','ve','evi'}
def key(s, stop=True):
    s = s.replace('ı','i').replace('İ','I').replace('’',"'")
    s = unicodedata.normalize('NFKD', s.lower()); s = ''.join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r'\(.*?\)', ' ', s); s = re.sub(r"[^a-z0-9]+", ' ', s)
    w = s.split()
    return [x for x in w if not (stop and x in STOP)]
db = [l.split('|') for l in open(sys.argv[1], encoding='utf-8').read().split('\n')]
cards = [l.split('\t') for l in open(sys.argv[2], encoding='utf-8').read().split('\n')]
assert len(db) == 55 and len(cards) == 54
out = []; used = set()
# manual pair (spelling): only Istanbul Bib card left; venue site uses both spellings, address Tersane Cd. No:24
MANUAL = {'ve_465ee2066b': ('1195449', 'manual-spelling')}
for d in db:
    aid, vid, name, st, city, yr, cat = d[:7]
    dk = key(name); cands = []
    if vid in MANUAL:
        c = next(c for c in cards if c[0] == MANUAL[vid][0]); assert DIST[c[3]] == cat
        cands = [(c, MANUAL[vid][1])]
    for c in cards:
        if vid in MANUAL or DIST[c[3]] != cat: continue
        ck = key(c[1])
        if dk == ck: cands.append((c, 'exact-key'))
        elif ck and (set(ck) <= set(dk) or set(dk) <= set(ck)): cands.append((c, 'subset-key'))
    if len(cands) == 1:
        c, cls = cands[0]
        assert c[0] not in used, (name, c[1]); used.add(c[0])
        out.append('|'.join([vid, aid, c[0], cls, name, c[1]]))
    else:
        print('NO UNIQUE MATCH:', name, cat, [x[0][1] for x in cands])
open(sys.argv[3], 'w', encoding='utf-8').write('\n'.join(sorted(out)))
print('paired', len(out), '| cards unused:', [c[1] for c in cards if c[0] not in used])
