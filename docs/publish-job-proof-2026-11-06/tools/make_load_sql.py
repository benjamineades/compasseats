"""Turn the decoded export parts into one SQL file of COPY blocks for the local copy.

usage: python3 -I make_load_sql.py <export dir> <out.sql>
"""
import json, sys, glob

exp, out = sys.argv[1], sys.argv[2]

def load(name):
    rows = []
    for p in sorted(glob.glob(f"{exp}/{name}.*.json")):
        rows += json.load(open(p))
    return rows

def cell(v, kind=None):
    if v is None:
        return r"\N"
    if isinstance(v, bool):
        return "t" if v else "f"
    if kind == "json":
        v = json.dumps(v, ensure_ascii=False)
    elif kind == "array":
        # text[]: {"a","b"}
        v = "{" + ",".join('"' + str(x).replace("\\", "\\\\").replace('"', '\\"') + '"' for x in v) + "}"
    s = str(v)
    return s.replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n").replace("\r", "\\r")

TABLES = [
    ("award_sources", "slug, display, status, capture_permission, attribution_required, geo_capable, price_capable, render_extended_above", {}),
    ("regions", "id, slug, display", {}),
    ("cities", "id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count", {}),
    ("venues", "id, name, name_native, category, city_id, status, chef, gers_id, cuisine_tags, cuisine_source, cuisine_publisher, last_verified", {8: "array"}),
    ("listings", "venue_id, property_id, trust_tier, published", {}),
    ("slugs", "property_id, city_slug, slug, venue_id, is_canonical", {}),
    ("redirects", "from_path, to_path", {}),
    ("awards", "id, venue_id, source_id, year, rank, category, distinction, source_url", {}),
    ("price", "venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence", {}),
    ("blurbs", "venue_id, short, long, method, version, status, sources", {6: "json"}),
    ("ledger", "id, publisher, field_type, items, captured_at, job", {}),
]
TARGET = {"ledger": "source_capture_ledger"}

lines = [
    "-- Local throwaway copy of the live tables the publish job reads. Built from a",
    "-- read-only export through the Supabase Read connector. Never the live project.",
    "begin;",
    "set session_replication_role = replica;  -- no audit triggers, no FK order needed",
    "delete from award_sources;",
]
counts = {}
for name, cols, kinds in TABLES:
    rows = load(name)
    counts[name] = len(rows)
    lines.append(f"copy {TARGET.get(name, name)} ({cols}) from stdin;")
    for r in rows:
        lines.append("\t".join(cell(v, kinds.get(i)) for i, v in enumerate(r)))
    lines.append("\\.")
lines += [
    "-- audit_log: 1 marker row at the live last id, so the manifest shows the live id.",
    "-- The live table holds 129,216 rows; they are not copied.",
    "insert into audit_log (id, table_name, row_pk, action) overriding system value",
    "  values (135045, 'local_copy_marker', null, 'MARKER');",
    "set session_replication_role = origin;",
    "commit;",
]
open(out, "w").write("\n".join(lines) + "\n")
print(json.dumps(counts))
