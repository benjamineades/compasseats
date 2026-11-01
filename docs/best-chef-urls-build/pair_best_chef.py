"""Pair live Best Chef award rows (db-rows.txt) to list entries (list-2024.txt, list-2025.txt).

Output: pairs.tsv (one line per award row) and a summary on stdout.
Levels: L1 name+city+knives; L2 name+knives (city differs); L3 city+knives, name contains;
K = name (+city) match but knives differ; NONE = no entry.
"""
import re, sys, unicodedata, collections

def key(s):
    s = re.sub(r'\([^)]*\)', '', s).lower()
    for a, b in (('ı', 'i'), ('ł', 'l'), ('đ', 'd'), ('ð', 'd'), ('œ', 'oe'), ('ø', 'o'), ('æ', 'ae'), ('ß', 'ss')):
        s = s.replace(a, b)
    s = unicodedata.normalize('NFD', s)
    s = ''.join(ch for ch in s if not unicodedata.combining(ch))
    return re.sub(r'[^a-z0-9]+', '', s)

lists = collections.defaultdict(list)  # year -> entries
for y in (2024, 2025):
    for line in open(f'list-{y}.txt', encoding='utf-8').read().split('\n'):
        yr, kn, nk, ck, cid = line.split('|')
        lists[int(yr)].append(dict(kn=kn, nk=nk, ck=ck, cid=cid))

rows = []
for line in open('db-rows.txt', encoding='utf-8').read().split('\n'):
    p = line.split('|')
    aid, yr, kn = p[:3]
    city, status = p[-2:]
    name = '|'.join(p[3:-2])
    rows.append(dict(aid=int(aid), yr=int(yr), kn=kn, name=name, city=city, ck=city.replace('-', ''), nk=key(name), status=status))

def find(r):
    L = lists[r['yr']]
    c = [e for e in L if e['nk'] == r['nk'] and e['ck'] == r['ck'] and e['kn'] == r['kn']]
    if c: return 'L1', c
    c = [e for e in L if e['nk'] == r['nk'] and e['kn'] == r['kn']]
    if c: return 'L2', c
    c = [e for e in L if e['ck'] == r['ck'] and e['kn'] == r['kn'] and len(e['nk']) >= 3 and len(r['nk']) >= 3
         and (e['nk'] in r['nk'] or r['nk'] in e['nk'])]
    if c: return 'L3', c
    c = [e for e in L if e['nk'] == r['nk'] and (e['ck'] == r['ck'])]
    if c: return 'K', c
    c = [e for e in L if e['nk'] == r['nk']]
    if c: return 'K', c
    return 'NONE', []

# Manual pairs (award id -> chef id), read Nov 1 2026 on the results pages: name forms the key test missed.
MANUAL = {
    33: '19970', 625: '19713', 626: '19713', 675: '19880', 886: '19747', 887: '19747', 966: '19784', 967: '19784',
    1685: '19951', 1812: '25018', 1813: '25018', 1896: '24907', 2127: '19867', 2149: '19998', 2150: '19998',
    2443: '20679', 2444: '20679', 2867: '25180', 2868: '25180', 3448: '29723', 4321: '25033', 4322: '25033',
    4945: '25124', 5142: '25139', 5143: '25139', 5313: '24920', 5314: '24920', 5537: '24852',
    6066: '29717',   # Tom Aikens; the 2024 card shows restaurant "Tohru in der Schreiberei", London (site error)
    6194: '24880', 6548: '24777', 7138: '24810', 7419: '25008', 7682: '24851', 7821: '25076',
    7937: '19941', 7938: '19941', 8752: '29706', 9183: '19965', 9184: '19965', 15626: '19927', 15627: '19927',
    15630: '19929', 15631: '19929', 15669: '19981', 15670: '19981', 15758: '24787', 15759: '24787',
    15788: '24812', 15880: '24879', 15964: '24941', 16030: '24993', 16031: '24993', 16170: '25096', 16171: '25096',
    16039: '24997',  # "Beijing 1996" = Chef 1996 (Liang Dee), not Jing (25177 belongs to venue Jing)
}
# Held: no list entry proves the row on this venue.
HOLD = {
    3453: 'Flores Raras (Valencia) 2025 2-Knife: no entry; nearest = Luis Valls, El Poblet (former workplace)',
    15690: 'Ensue (Shenzhen) 2025 2-Knife: Ensue is 1 knife (row 15691); Shenzhen 2-knife entry = Fumee (Reina Chen), no row',
    15727: '8 1/2 Otto e Mezzo BOMBANA (Macau) 2025 2-Knife: entry = Umberto Bombana, Hong Kong (Alexandra House)',
    15997: "Fo'ao Vaperse Hotel (Guangzhou) 2025 1-Knife: no entry; unused Guangzhou entry = Rever (Julien Xu)",
    16190: 'The Fellas (Shanghai) 2025 1-Knife: no entry; unused Shanghai entries = 102 House (closed), Scilla',
}
byid = {y: {e['cid']: e for e in lists[y]} for y in lists}

out = []
use = collections.Counter()
for r in sorted(rows, key=lambda r: r['aid']):
    if r['aid'] in HOLD:
        lvl, c = 'HOLD', []
    elif r['aid'] in MANUAL:
        e = byid[r['yr']][MANUAL[r['aid']]]
        assert e['kn'] == r['kn'], (r['aid'], e)
        lvl, c = 'MANUAL', [e]
    else:
        lvl, c = find(r)
    if r['aid'] == 16329:  # La Docena, Guadalajara: 2 chef cards (29682, 29734), one restaurant
        c = c[:1]
    cids = ','.join(e['cid'] for e in c)
    for e in c: use[(r['yr'], e['cid'])] += 1
    out.append((r['aid'], r['yr'], r['kn'], lvl, r['name'], r['city'], r['status'], cids,
                HOLD.get(r['aid']) or ';'.join(f"{e['kn']}|{e['nk']}|{e['ck']}" for e in c)))

with open('pairs.tsv', 'w', encoding='utf-8') as f:
    f.write('award_id\tyear\tknives\tlevel\tname\tcity\tstatus\tchef_ids\tlist_entries\n')
    for o in out: f.write('\t'.join(map(str, o)) + '\n')

cnt = collections.Counter((o[1], o[3]) for o in out)
for k in sorted(cnt): print(k, cnt[k])
multi = [o for o in out if ',' in o[7]]
print('rows with >1 candidate entry:', len(multi))
shared = {k: v for k, v in use.items() if v > 1}
print('list entries used by >1 row:', len(shared))
for y in (2024, 2025):
    unused = [e for e in lists[y] if (y, e['cid']) not in use]
    print(y, 'list entries with no row:', len(unused))
