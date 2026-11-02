"""Build fixtures/ingest/michelin-2026-switzerland-decisions.csv for stage run 2 of batch 20.

Inputs (read-only copies made in this session):
  staged20.json  = ingest_rows of batch 20 (line, verdict, reason, city, venue, candidates), read Nov 2 23:40 UTC
  legacy.json    = all venues in CH and LI cities with their Michelin rows, read Nov 2 23:40 UTC
  the Cowork log = the 18 new 2026 cards (part 4); The Japanese Restaurant moved from Two to Three Stars
Rules (Ben, Nov 2): 11:40 "3A" (two categories on one address: the second card becomes a new venue, under-merge);
18:09 "1A, 2A, 3A" (Ollon new; pair to the venue whose name and city match the card; CAAA -> ve_3b12809d9f);
18:17 "2A" (Ebersecken new).
Each use: must be a candidate that the match test found for that line (a venue in the resolved city with a free
2025 Michelin row of the card's 2025 category, or with no Michelin row for a 2026 newcomer). The script stops if not.

Run: python3 -I build_decisions_ch_2026_11_02.py <staged20.json> <legacy.json> <log.md> <out.csv>
"""
import csv
import json
import re
import sys
from collections import Counter

st_p, lg_p, log_p, out_p = sys.argv[1:5]
st = json.load(open(st_p, encoding="utf-8"))
lg = {v["id"]: v for v in json.load(open(lg_p, encoding="utf-8"))}
assert len(st) == 225 and Counter(r["verdict"] for r in st) == Counter(match=96, new_venue=88, review_venue=41)

log = open(log_p, encoding="utf-8").read()
part4 = log.split("Named 2026 changes")[1].split("Note: a second card")[0]
NEW26 = {re.search(r"https://guide\.michelin\.com/us/en/(\S+) \|", l).group(1)
         for l in part4.splitlines() if ", new |" in l and "Three Stars, new" not in l}
assert len(NEW26) == 18
PRE = "https://guide.michelin.com/us/en/"


def y25(r):
    p = r["url"][len(PRE):]
    if p in NEW26:
        return None
    if p == "uri/andermatt/restaurant/the-japanese-restaurant":
        return "Two Stars"
    return r["cat"]


TWIN = "3A twin (Ben Nov 2 11:40): two categories on one address, this card becomes a new venue (under-merge)"
NEW = {
    31: "1A (Ben 18:09): Ollon card is a new venue in the new city Ollon; One Star 2025 (archive 20260128201135); row 231 moves here in the cleanup",
    34: "2025 One Star with no legacy row in Basel (the free Basel One Star row went to Ackermannshof)",
    39: "2025 One Star (archive 20251110102357) with no legacy row; new city Ballaigues",
    78: "2026 newcomer (log part 4); new city Morbio Inferiore", 79: "2026 newcomer (log part 4); new city Gonten",
    90: "2026 newcomer (log part 4); no Zermatt venue of that name", 91: "2026 newcomer (log part 4); no Berne venue of that name",
    97: "2026 newcomer (log part 4); new city Oberwil", 98: "2026 newcomer (log part 4); no Zurich venue of that name",
    123: TWIN + "; the Bib card 'Birdy's by Achtien' matched the legacy venue by exact name (line 224)",
    138: TWIN + "; the One Star card Njørden keeps ve_063365e885",
    148: "2026 newcomer (log part 4); new city Messen",
    154: TWIN + "; the One Star card Panorama - Cayenne keeps ve_e412256f8a",
    165: "2026 newcomer (log part 4); no Zurich venue of that name", 176: "2026 newcomer (log part 4); no Zurich venue of that name",
    180: "2026 newcomer (log part 4); new city Gonten", 183: "2026 newcomer (log part 4); new city Celerina",
    184: "2026 newcomer (log part 4); new city Pfaffnau", 185: "2026 newcomer (log part 4); new city Stans",
    186: "2026 newcomer (log part 4); new city Buchs", 187: "2026 newcomer (log part 4); new city Intragna",
    188: "2026 newcomer (log part 4); no Zurich venue of that name",
    200: "2025 Bib (archive 20260111022911) with no legacy row; new city Schwarzenburg (wrong alias to Grub deleted in write 1)",
    202: TWIN + "; the One Star card Wiesner Mysterion - Wiesner - Zauber keeps ve_b0b6289cfe",
    208: TWIN + "; the One Star card Château Attisholz - Le feu keeps ve_46053b218b",
    211: "2025 Bib with no legacy row; new city Utzenstorf (wrong alias to Grub deleted in write 1)",
    212: "2026 newcomer (log part 4); ve_8c8a10de1e Gupf is the One Star Gasthaus Zum Gupf (line 73), a different restaurant",
    214: TWIN + "; the One Star card Alpenblick - Stuba keeps ve_7561fa5d25",
    220: TWIN + "; the One Star card Schlüssel - Nidbergstube keeps ve_27a2d86ff0",
    222: "2A (Ben 18:17): 2025 Bib (archive 20251208045545); new city Ebersecken; row 9048 moves here in the cleanup",
}
USE = {
    5: "ve_a024c1df89", 8: "ve_9bd0fbec42", 10: "ve_dcfa59471a", 13: "ve_360a80b032", 15: "ve_bd812d0ff0",
    16: "ve_01c783d370", 17: "ve_ae81ba57b5", 18: "ve_1489b03a45", 23: "ve_579505f292", 28: "ve_0b50291587",
    29: "ve_b69774d8b6", 30: "ve_07fdc406cd", 32: "ve_6dfe615691", 33: "ve_2b2dbfb9bf", 36: "ve_6521db946e",
    37: "ve_3bd1317f1c", 40: "ve_d7d236223f", 45: "ve_9acda23640", 46: "ve_363cdb21ff", 47: "ve_719794767d",
    49: "ve_063365e885", 51: "ve_1a8e759931", 52: "ve_614ef54974", 53: "ve_d92707d46d", 54: "ve_a95e4d1fd2",
    55: "ve_341bc10299", 61: "ve_3ae5d0df0b", 62: "ve_fff99c3357", 65: "ve_16ad2ecf9a", 68: "ve_07c58c3cc2",
    70: "ve_30a31d4e84", 72: "ve_d9a2af4de3", 73: "ve_8c8a10de1e", 75: "ve_cbdc6c829b", 76: "ve_6d8608e5bc",
    77: "ve_06e7909221", 83: "ve_c923c2a1be", 84: "ve_46053b218b", 85: "ve_88b7d09578", 86: "ve_8bc081e1b7",
    87: "ve_b8fe5cdaeb", 88: "ve_157d527091", 93: "ve_1ff8df1642", 96: "ve_8875fb8787", 99: "ve_9e9ca98fc6",
    100: "ve_972ceacb75", 102: "ve_7561fa5d25", 104: "ve_a98d36a359", 107: "ve_9bee700c20", 108: "ve_b0b6289cfe",
    111: "ve_da2116f2fa", 116: "ve_5144bb9225", 117: "ve_80d0054396", 119: "ve_f0ca488fd0", 120: "ve_3b12809d9f",
    122: "ve_f3e4ce992e", 126: "ve_e412256f8a", 127: "ve_58207f74b9", 128: "ve_98a21f8fa8", 129: "ve_e14c24e574",
    130: "ve_dd38531f8f", 131: "ve_27a2d86ff0",
    149: "ve_2bec51b859", 150: "ve_7bb31146bb", 152: "ve_24270e9ae9", 153: "ve_a9da585c25", 155: "ve_f022d54c53",
    156: "ve_82ef3df931", 158: "ve_8f85789bec", 159: "ve_af85a36ec0", 160: "ve_2949d340bd", 161: "ve_c670f5d3a0",
    164: "ve_7e95e4eb62", 166: "ve_991ee558ec", 167: "ve_b374e99c35", 168: "ve_26c585f1a3", 169: "ve_ea0bc2ee9c",
    171: "ve_0fdc7bdb6e", 174: "ve_ed815f15fb", 177: "ve_84891f3ea7", 178: "ve_59b228c72a", 179: "ve_27907ac388",
    189: "ve_55b47250ad", 191: "ve_ffc19aeb13", 192: "ve_6a05813773", 195: "ve_c69f4777fa", 196: "ve_9dbfd4baab",
    197: "ve_7e4b97f994", 198: "ve_62ffe749b7", 199: "ve_e48844ec79", 203: "ve_eaeac5a4c3", 204: "ve_cd936acefb",
    207: "ve_787c43dc24", 209: "ve_016ad6629e", 213: "ve_9d2037d9e3", 215: "ve_4b848ba4c5", 216: "ve_0453a355cc",
    219: "ve_3b661056f4", 223: "ve_1eed8640fe",
}
NOTE = {
    10: "2A (Ben 18:09): name and city match; Carlton Hotel St. Moritz LHW ve_7c75b49d07 (Two Stars 2940) to the cleanup list",
    18: "2A (Ben 18:09): Schwyz venue (slug /rickenbach/); Restaurant Magdalena Lucerne ve_7d4e3b91ec to the cleanup list",
    120: "3A (Ben 18:09): CAAA twin; ve_3996e732ef (slug -bar) stays",
    158: "status file (Ben 17:26 1A): this venue goes active and is renamed Colani Bistrot",
    5: "row 231 (One Star) on this venue moves to Ollon in the cleanup",
    93: "row 9048 (Bib) on this venue moves to Ebersecken in the cleanup",
    130: "Hotel Alpenblick holds One Star 9059 and Bib 9060; the Bib card goes to ve_59b228c72a (line 178)",
    178: "Swiss Bistro im Hotel Alpenblick holds its own Bib 12947",
}
# Ben 2A (18:09): pair to the venue whose name and city match the card, even when the 2025 row sits on a hotel venue.
# Line 10 Da Vittorio ve_dcfa59471a has no Michelin row; the Two Stars 2025 row 2940 stays on Carlton ve_7c75b49d07.
BEN_2A_NO_ROW = {10}
assert not set(USE) & set(NEW)
nonmatch = {r["line"]: r for r in st if r["verdict"] != "match"}
assert set(USE) | set(NEW) == set(nonmatch), sorted(set(nonmatch) ^ (set(USE) | set(NEW)))

# every use: must be a match-test candidate of that line
used = set()
for r in st:
    if r["verdict"] == "match":
        v = lg[r["venue_id"]]
        ids = [m["id"] for m in (v["mich"] or []) if m["cat"] == y25(r) and m["year"] == 2025]
        if ids:
            used.add(ids[0])
take = {}
for line in sorted(USE):
    r, vid = nonmatch[line], USE[line]
    v = lg[vid]
    assert v["city_id"] == r["city_id"], (line, "city")
    c = y25(r)
    free = [m for m in (v["mich"] or []) if m["year"] == 2025 and m["cat"] == c and m["id"] not in used]
    if c is None or line in BEN_2A_NO_ROW:
        assert not v["mich"], (line, "newcomer on a venue with Michelin rows")
    else:
        assert free, (line, vid, "no free 2025 row of the category")
        used.add(free[0]["id"])
        take[line] = free[0]["id"]
# no venue carries two rows of this batch
vc = Counter([USE[l] for l in USE] + [r["venue_id"] for r in st if r["verdict"] == "match"])
assert max(vc.values()) == 1, [k for k, n in vc.items() if n > 1]

rows = []
for line in sorted(nonmatch):
    r = nonmatch[line]
    if line in USE:
        v = lg[USE[line]]
        why = (f"(pair) \"{v['name']}\": same city ({r['city_slug']}), legacy 2025 {y25(r) or 'none'}"
               + (f" row {take[line]}" if line in take else "") + f", 2026 {r['cat']}; stage {r['verdict']}"
               + (f"/{r['reason']}" if r["reason"] else ""))
        if line in NOTE:
            why += "; " + NOTE[line]
        rows.append([line, r["name"], r["city_slug"], f"use:{USE[line]}", why])
    else:
        rows.append([line, r["name"], r["city_slug"], "new", f"(new) {NEW[line]}; stage {r['verdict']}"])

with open(out_p, "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f, quoting=csv.QUOTE_ALL, lineterminator="\n")
    w.writerow(["line", "venue_name", "city_label", "decision", "reason"])
    w.writerows(rows)
print("rows", len(rows), "use", len(USE), "new", len(NEW), "legacy rows taken", len(take))
print("expected after run 2: match", 96 + len(USE), "new_venue", len(NEW), "review 0")
