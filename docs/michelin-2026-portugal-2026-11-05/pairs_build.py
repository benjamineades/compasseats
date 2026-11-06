#!/usr/bin/env python3
"""Make pairs.tsv from the list read and the live read. Name key first, then the hand list by card path."""
import collections, re, unicodedata
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
live = []
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live.append(dict(v=p[0], a=p[1], cat=p[2], city=p[5], st=p[6], name='|'.join(p[10:])))
HAND = {'vila-foz': 've_02ec8f0c23', 'vinha': 've_06c15a6bb1', 'schisto': 've_1465ed893a', 'esporao': 've_1cb90206e2', 'solar-do-bacalhau': 've_32b9d20f06', 'olaias': 've_3d5550286a',
 'casa-chef-victor-felisberto': 've_578415de8d', 'the-yeatman': 've_63b7b5b6e1', 'patio-44': 've_683132f77c', 'william216831': 've_6fce85097f', '2monkeys': 've_7f24200a5a', 'a-cozinha': 've_7f5e557320',
 'eon': 've_82e0750c94', 'desarma': 've_83dcfcb027', 'solar-do-forcado': 've_985b6561a5', 'camelo': 've_9c5faf9b1a', 'oficio': 've_9c9425eedd', 'g-pousada': 've_a5a73f1b60', 'flora-1210835': 've_cdb234e39f',
 'casal-da-penha': 've_d8936e2258', 'ocean216602': 've_d92c6ae3a5', 'mesa15': 've_db6cfedd9b', 'sala1154759': 've_fd3f9b0e88', 'yoso-1214668': 've_de4fd42462', 'o-balcao': 've_e46916cd7e', 'gusto378372': 've_e78a5228c4',
 'machado': 've_e87afefdc9', 'blind': 've_ebdea8383b', 'antiqvvm': 've_f322c5f6d8', 'dori': 've_f590bedecd'}
NEW = {'a-cozinha-do-paco'}
L = {l['v']: l for l in live}; used = {}; out = []
for line in open('relay-pt-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n'):
    x = dec(line).split(' | '); path = x[1].split('/restaurant/')[1]
    if path in NEW: out.append((path, 'NEW', '-', 'new-venue')); continue
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
