#!/usr/bin/env python3
"""Make pairs.tsv from the list read and the live read. Hand lines are listed by card slug.
Columns: card slug, venue id or NEW, 2025 award id or -, how."""
import re, unicodedata, collections
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
live = [l.split('|') for l in open('live-read.txt', encoding='utf8').read().strip().split('\n')]
assert len(live) == 126
L = {l[0]: l for l in live}
cards = [dec(l).split(' | ') for l in open('relay-sg-2026-list-pages-2026-11-05.txt', encoding='ascii').read().split('\n')]
assert len(cards) == 142
HAND = {
 'shoukouwa': 've_40613faa1f', 'labyrinth': 've_50c31e03ce', 'whitegrass': 've_389c4c4217', 'jag': 've_cb49debd91', 'born': 've_8e7c1c6608',
 'lei-garden-501509': 've_88810fb0a1', 'shisen-hanten': 've_c87089f0b5', 'cut': 've_a29b63593f', 'hill-street-tai-hwa-pork-noodle': 've_c2e6c8acfb',
 'nae-um': 've_c1a6e2e265', 'indocafe-the-white-house': 've_b20d4e0428', 'the-coconut-club-1195654': 've_bc1a078378', 'anglo-indian-shenton-way': 've_85732683a4',
 'song-kee-teochew-fish-porridge': 've_aab14ed20a', 'wok-hei-hor-fun': 've_a2a73f2890', 'kok-sen': 've_e43b00d099', 'song-fa-bak-kut-teh-new-bridge-road': 've_a17ba076bd',
 'outram-park-fried-kway-teow': 've_b1b42b2c4c', 'ji-ji-noodle-house': 've_9d877ca6fd', 'lian-he-ben-ji-claypot': 've_fda8c4766c', 'hui-wei-chilli-ban-mian': 've_45d3f61ccf',
 'boon-tong-kee-balestier-road': 've_0127e72f1b', 'kelantan-kway-chap-pig-organ-soup': 've_e1dc8f6877', 'jian-bo-tiong-bahru-shui-kueh': 've_e2325ed446',
 'han-kee': 've_307e81d7e0', 'heng': 've_4deb0c2986', 'heng-kee': 've_6b337647ff', 'hong-heng-fried-sotong-prawn-mee': 've_548686853a', 'hong-kong-yummy-soup': 've_ae801a7622',
 'hoo-kee-bak-chang': 've_2cffb4557a', 'lagnaa': 've_23cace31ff', 'yhingthai-palace': 've_21dcfa3295', 'du-du-shou-shi': 've_2c4893da5a', 'ru-ji-kitchen': 've_5f96bf1fa5',
 'mp-thai': 've_f28a629cb4', 'sik-bao-sin-desmond-s-creation': 've_b9c64072fb', 'sin-huat-eating-house': 've_38ccf6662d', 'singapore-fried-hokkien-mee': 've_69c36a3edf',
 'zhi-wei-xian-zion-road-big-prawn-noodle': 've_48a9a096b3', 'un-yang-kor-dai': 've_cf392c5f30', 'tai-seng-fish-soup': 've_67c75dd2eb', 'kwee-heng': 've_435bae01ed',
 'bismillah-biryani': 've_8db5a2e230',
}
NEWROW = {'imperial-treasure-fine-teochew-cuisine-orchard': 've_bf2230cf37'}
NEWVENUE = {'1887-by-andre', 'tenshima', 'jin-ting-wan', 'sushi-kimura-1247953', 'loca-niru', 'yong-fu-1218314', 'cherry-garden-by-chef-fei',
            'rajarani-thosai', 'hup-kee-fried-oyster-omelette', 'seng-kee-black-chicken-herbal-soup', 'boon-keng-road-fish-head-bee-hoon',
            'yi-pin-wei-braised-duck%EF%BC%8Ekway-chap', 'xiangyee', 'jia-xiang', 'tian-nan-xing-minced-pork-noodle', 'king-of-laksa', 'xiu-ji-ikan-bilis-yong-tau-fu'}
assert len(NEWVENUE) == 17
byk = {}
for l in live:
    byk.setdefault(key(l[12]), []).append(l)
used = {}; out = []
for c in cards:
    p = c[1].split('/restaurant/')[1]
    if p in NEWVENUE: out.append((p, 'NEW', '-', 'new-venue')); continue
    if p in NEWROW: out.append((p, NEWROW[p], '-', 'new-row')); continue
    if p in HAND:
        v = HAND[p]; how = 'hand'
    else:
        m = byk.get(key(c[2]))
        assert m and len(m) == 1, ('no exact pair', c[2])
        v = m[0][0]; how = 'exact'
    assert v not in used, (p, v); used[v] = p
    out.append((p, v, L[v][1], how))
left = [l for l in live if l[0] not in used]
print('live rows with no card:', [(l[1], l[0], l[2], l[12]) for l in left])
assert len(left) == 2
cl = {c[1].split('/restaurant/')[1]: c for c in cards}
print('tier change:', [(cl[r[0]][2], L[r[1]][2], cl[r[0]][0]) for r in out if r[2] != '-' and L[r[1]][2] != cl[r[0]][0]])
for r in out:
    if r[3] == 'hand':
        print('hand', cl[r[0]][2], '<=', L[r[1]][12])
open('pairs.tsv', 'w').write('\n'.join('\t'.join(r) for r in out))
print(collections.Counter(r[3] for r in out), len(out))
