#!/usr/bin/env python3
"""Build fixtures/ingest/michelin-2026-hong-kong-macau-decisions.csv (Nov 1, 2026).

Ben, Nov 1 10:14 ET: D1-D9 all recommended (D2 = A, D3 = A, D4 = B, D5 = A).
Inputs: the fixture CSV, relay-pairs.txt (line|how|venue_id|award_id|city_id) and
relay-venue-names.txt (venue_id|stored name, Nov 1 Read-connector read).
One decision line per row that the exact name key does not pair: 60 `use:` + 6 `new`.
Usage: python3 -I build_decisions_hkmo_2026_11_01.py <repo root>
"""
import csv, hashlib, io, os, sys
root = sys.argv[1]
CSV = os.path.join(root, 'fixtures/ingest/michelin-2026-hong-kong-macau.csv')
RELAY = os.path.join(root, 'docs/hkmo-2026-build/relay-pairs.txt')
NAMES = os.path.join(root, 'docs/hkmo-2026-build/relay-venue-names.txt')
OUT = os.path.join(root, 'fixtures/ingest/michelin-2026-hong-kong-macau-decisions.csv')
assert hashlib.sha256(open(CSV, 'rb').read()).hexdigest() == '32d9839c1ffcd5029eab8a3ae1abbf91db977eec6302481850324b1aac20adbb'
assert hashlib.sha256(open(RELAY, 'rb').read()).hexdigest() == '8916d57069ca9e4cf3bcf1e195351830a3653a2782e72927613f4030dc4d6fcb'
rows = list(csv.DictReader(open(CSV, encoding='utf-8', newline='')))
relay = [l.split('|') for l in open(RELAY, encoding='utf-8').read().splitlines()]
names = dict(l.split('|', 1) for l in open(NAMES, encoding='utf-8').read().splitlines())
NEW = {
    9: 'D2 = A (Ben, Nov 1): no venue named Lai Ching Heen; the Two Stars row 18227 sits on Hong Kong "Lai Heen" ve_d970e6b8ab (Michelin has Lai Heen only in Macau); new venue, row 18227 to the cleanup',
    92: 'D4 = B (Ben, Nov 1): only candidate "3D Inn Hong Kong - Dragon" ve_be7682ae49 (a hotel-type name, row 10532 only); new venue, row 10532 to the contamination register',
    95: 'D3 = A (Ben, Nov 1): no venue; legacy row on "Eaton HK" ve_25ab6083a0 (10535) is another business name; new venue, row to the contamination register',
    122: 'D3 = A (Ben, Nov 1): no venue; legacy row on "Ying Kee Noodle" ve_d179ef70d6 (10534) not proven; new venue, row to the contamination register',
    128: 'D3 = A (Ben, Nov 1): no venue; "Sang Kee Restaurant" ve_721a2d6fc2 is the card Sang Kee (line 118); new venue',
    139: 'D3 = A (Ben, Nov 1): no venue; new venue',
}
SPECIAL = {
    140: 'log part 5: the URL cafe-hunan-western-district redirects to prof-chan-s-western-district; 2026 article name "Cafe Hunan (Western District)"',
    20: 'card name key is also on 3 venues in other cities (Atelier branches); this Hong Kong Two Stars venue is "Joel Robuchon" (log part 12)',
}
out = []
for i, (r, (line, how, vid, aid, cid)) in enumerate(zip(rows, relay), start=1):
    assert int(line) == i
    if how == 'pair':
        why = SPECIAL.get(i, 'only candidate in the card city')
        dec = f'use:{vid}'
        reason = (f'(pair) same city ({r["city_label"]}); stored name "{names[vid]}"; legacy row {aid} {r["category"]} '
                  f'relabelled to 2026 with this card URL (ledger 197); {why}; name to the rename batch')
    elif how == 'new':
        dec = 'new'; reason = '(new) ' + NEW[i]
    else:
        continue
    out.append({'line': str(i), 'venue_name': r['venue_name'], 'city_label': r['city_label'], 'decision': dec, 'reason': reason})
assert sum(1 for o in out if o['decision'].startswith('use:')) == 60
assert sum(1 for o in out if o['decision'] == 'new') == 6
assert set(int(o['line']) for o in out if o['decision'] == 'new') == set(NEW)
assert len({o['decision'] for o in out if o['decision'].startswith('use:')}) == 60
buf = io.StringIO()
w = csv.DictWriter(buf, fieldnames=['line', 'venue_name', 'city_label', 'decision', 'reason'], quoting=csv.QUOTE_ALL, lineterminator='\r\n')
w.writeheader(); w.writerows(out)
open(OUT, 'w', encoding='utf-8', newline='').write(buf.getvalue())
print('wrote', OUT, len(out), 'lines', hashlib.sha256(buf.getvalue().encode()).hexdigest())
