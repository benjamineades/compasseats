"""Decode a saved Read-connector result and store each column as an export part.

usage: python3 -I decode.py <saved result file> <export dir> <part tag>
Each column of the single result row is written to <export dir>/<column>.<part tag>.json
"""
import json, re, sys, hashlib

src, outdir, tag = sys.argv[1], sys.argv[2], sys.argv[3]
outer = json.load(open(src))
text = outer["result"] if isinstance(outer, dict) else outer
m = re.search(r"<untrusted-data-([0-9a-f-]+)>\n(.*)\n</untrusted-data-\1>", text, re.S)
rows = json.loads(m.group(2))
assert len(rows) == 1, len(rows)
for col, val in rows[0].items():
    val = val if val is not None else []
    path = f"{outdir}/{col}.{tag}.json"
    with open(path, "w") as f:
        json.dump(val, f, ensure_ascii=False)
    print(col, len(val), hashlib.sha256(open(path, "rb").read()).hexdigest()[:16])
