#!/usr/bin/env python3
"""Make pairs.tsv from the list read and the live read. Name key first, then the hand list by card path."""
import collections, re, unicodedata
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
live = []
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live.append(dict(v=p[0], a=p[1], cat=p[2], city=p[5], st=p[6], name='|'.join(p[10:])))
HAND = {'farmer-s-apprentice': 've_2540ccab0a', 'lunch-lady': 've_fd25bd01e7', 'phnom-penh': 've_bfcac91803', 'seaport-city-seafood': 've_847c1983f8',
 'campechano': 've_919de817cb', 'indian-street-food-company': 've_b31e8f3690', 'ricky-olivia': 've_b65ef42b07', 'the-cottage-cheese': 've_e3e5905165', 'tiflisi': 've_1f862bbd2a',
 'le-petit-alep': 've_12dda1d3e0', 'limbo': 've_75c8b8bbf9', 'parapluie-1216819': 've_8123febfee', 'baumier': 've_59ded0d1f8', 'battuto': 've_925de5d611', 'melba': 've_f216403682',
 'ouroboros': 've_72503c667d', 'torii-buvette-japonaise': 've_6f413685d3', 'losange': 've_eb2c82682d', 'okeya-kyujiro': 've_108ef51bf4', 'st-lawrence': 've_2c33752f07', 'sushi-hyun': 've_63b570ba6f',
 'edulis': 've_53f1658223', 'kaiseki-yu-zen-hashimoto': 've_5b05e05457', 'jerome-ferrer-europea': 've_9a5fc5a478', 'mastard': 've_ab4f160bc9', 'laurie-raphael': 've_0240c86817', 'le-clan': 've_1f7aadbfff',
 'narval': 've_f255e32faa', 'auberge-saint-mathieu': 've_49ad9513d3', 'taniere': 've_443da5bf6f'}
NEW = {'chef-s-choice-chinese-cuisine', 'kavita', 'rpm-bakehouse', 'les-incompetents', 'antylia', 'golden-horseshoe-barbecue', 'the-lunch-lady-of-saigon'}
L = {l['v']: l for l in live}; used = {}; out = []
for line in open('relay-ca-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n'):
    x = dec(line).split(' | '); path = x[1].split('/restaurant/')[1]; guide = {'quebec': 'quebec', 'ontario': 'toronto', 'british-columbia': 'vancouver'}[x[1].split('/')[3]]
    if path in NEW: out.append((path, 'NEW', '-', 'new-venue', guide)); continue
    if path in HAND: v = HAND[path]; how = 'hand'
    else:
        m = [l for l in live if key(l['name']) == key(x[2])]
        assert len(m) == 1, x; v = m[0]['v']; how = 'same name'
    assert v not in used, x; used[v] = path; l = L[v]; assert l['st'] == 'active', x
    if l['cat'] != x[0]: how += ' tier ' + l['cat'] + ' to ' + x[0]
    out.append((path, v, l['a'], how, guide))
print('live not paired', [(l['name'], l['cat'], l['st']) for l in live if l['v'] not in used])
print(collections.Counter((o[4], o[3].split(' tier')[0]) for o in out), len(out))
print([o for o in out if 'tier' in o[3]])
open('pairs.tsv', 'w').write('\n'.join('\t'.join(o) for o in out))
