"""Build docs/cities-display-waiheke-wanaka-dakovo-2026-10-30.sql (Ben Oct 30 20:53 ET 'A': display name only).
Input: cities3.json (Read connector, Oct 31 ~00:55 UTC, pulled by grab.py). New displays come from the Michelin 2026
card address lines read Oct 30 (WebFetch): Mudbrick 'Waiheke Island', Bistro Loora 'Đakovo', Paloma Taqueria 'Wānaka'.
Guards: the new display, lower case and accents off, starts with the old display in lower case; the card URL path has
the city segment of the new display (spaces to '-', accents off)."""
import json, hashlib, unicodedata
rows = {r['info'].split('|')[0]: r['info'].split('|') for r in json.load(open('cities3.json')) if r['k'] == 'city'}
PLAN = [  # id, new display, card url (city segment), card address quote
    ('ci_d43edfbc8a', 'Waiheke Island', 'https://guide.michelin.com/us/en/north-island/waiheke-island_2305319/restaurant/mudbrick', '126 Church Bay Road, Oneroa, Waiheke Island, 1971, New Zealand'),
    ('ci_daf6d172be', 'Wānaka', 'https://guide.michelin.com/us/en/south-island/wanaka_2306683/restaurant/paloma-taqueria', '28 Helwick Street, Wānaka, 9305, New Zealand'),
    ('ci_f568968b3d', 'Đakovo', 'https://guide.michelin.com/us/en/osijek-baranja/dakovo_1784403/restaurant/bistro-loora', 'Ul. Ivana Pavla II 5, Đakovo, 31400, Croatia'),
]
def plain(s):
    s = unicodedata.normalize('NFD', s.replace('Đ', 'D').replace('đ', 'd').lower())
    return ''.join(c for c in s if unicodedata.category(c) != 'Mn')
md5 = lambda s: hashlib.md5(s.encode()).hexdigest()
q = lambda s: "'" + s.replace("'", "''") + "'"
for cid, new, url, addr in PLAN:
    old = rows[cid][2]
    assert unicodedata.is_normalized('NFC', new) and new in addr
    assert plain(new).startswith(old.lower()), (new, old)
    assert '/' + plain(new).replace(' ', '-') + '_' in url, (new, url)
old_fp = md5('\n'.join('|'.join(rows[c][:8]) for c, *_ in sorted(PLAN)))
new_fp = md5('\n'.join(f'{c}|{n}' for c, n, *_ in sorted(PLAN)))
vals = ',\n    '.join(f"({q(c)}, {q(rows[c][2])}, {q(n)}, {q(u)})" for c, n, u, _ in sorted(PLAN))
sql = open('tmpl_city_labels.sql', encoding='utf-8').read()
for k, v in dict(VALUES=vals, OLDFP=old_fp, NEWFP=new_fp).items():
    sql = sql.replace('{{' + k + '}}', v)
assert '{{' not in sql
open('cities-display-waiheke-wanaka-dakovo-2026-10-30.sql', 'w', encoding='utf-8').write(sql)
print('old_fp', old_fp, 'new_fp', new_fp)
