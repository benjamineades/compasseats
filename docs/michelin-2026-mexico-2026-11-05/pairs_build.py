#!/usr/bin/env python3
"""Make pairs.tsv from the list read and the live read. Name key first, then the hand list by card path.
Fields: card path, venue id or NEW, award id or -, how."""
import collections, re, unicodedata
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
live = []
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live.append(dict(v=p[0], a=p[1], cat=p[2], city=p[5], st=p[6], name='|'.join(p[10:])))
HAND = {'koli-cocina-de-origen': 've_f28f78f215', 'damiana': 've_b52256698b', 'alcalde-1243800': 've_a7517b2452', 'ha-1208266': 've_f81f010a30', 'cocina-de-autor-riviera-maya': 've_ca7c0fada5',
 'cocina-de-autor-los-cabos': 've_2c1f062cbf', 'lunario': 've_27c9173de4', 'gaba': 've_ab5a360f69', 'rosetta': 've_703961ccfa', 'los-danzantes-oaxaca': 've_f5d6f5d521', 'la-once-mil': 've_6eaa2b6f54',
 'ixi-im': 've_f5762ac8d8', 'humo-y-sal': 've_e71b270074', 'cocina-de-campo-by-agricole': 've_bb91783d56', 'metate': 've_9cc7566b9d', 'comal-oculto': 've_ef14273320', 'tierra-del-sol': 've_2e42ae66e2',
 'sabina': 've_b04067d16f', 'tacos-los-alexis': 've_f1a3b8b43c', 'tacos-charly': 've_29005d67b2', 'mestixa': 've_4b376309e6'}
EXIST = {'em': 've_4e1b67f3e8', 'fauna-1208366': 've_649178d372'}
NEW = {'la-barra-de-huniik', 'vica', 'icu', 'cultivo', 'pueblo-pibil', 'taquerias-kisin', 'tacos-y-gorditas-elvira', 'semitas-beto', 'palreal', 'los-camellos', 'moyuelo', 'jacinto-y-yo', 'el-bambis-cafe', 'el-guero-marinero', 'molino-el-pujol', 'restaurante-casareyna', 'pancho-maiz'}
L = {l['v']: l for l in live}; used = {}; out = []
for line in open('relay-mx-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n'):
    x = dec(line).split(' | '); path = x[1].split('/restaurant/')[1]
    if path in NEW: out.append((path, 'NEW', '-', 'new-venue')); continue
    if path in EXIST: out.append((path, EXIST[path], '-', 'venue, no Michelin row')); continue
    if path in HAND: v = HAND[path]; how = 'hand'
    else:
        m = [l for l in live if key(l['name']) == key(x[2])]
        assert len(m) == 1, x; v = m[0]['v']; how = 'same name'
    assert v not in used, x; used[v] = path; l = L[v]; assert l['st'] == 'active', x
    if l['cat'] != x[0]: how += ' tier ' + l['cat'] + ' to ' + x[0]
    out.append((path, v, l['a'], how))
print('live not paired', [(l['name'], l['cat'], l['st'], l['a']) for l in live if l['v'] not in used])
print(collections.Counter(o[3].split(' tier')[0] for o in out), len(out))
print('tier changes', [o for o in out if 'tier' in o[3]])
open('pairs.tsv', 'w').write('\n'.join('\t'.join(o) for o in out))
