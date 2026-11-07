"""Independent check of a version folder. Uses no code from the publish job.

usage: python3 -I verify.py <tree> <version> <psql dsn>
"""
import hashlib, json, os, re, subprocess, sys
tree, ver, dsn = sys.argv[1:4]
d = os.path.join(tree, "versions", ver)
m = json.load(open(os.path.join(d, "manifest.json")))
bad = 0
for f in m["files"]:
    b = open(os.path.join(d, f["path"]), "rb").read()
    if hashlib.sha256(b).hexdigest() != f["sha256"] or len(b) != f["bytes"]:
        bad += 1
on_disk = sum(len(fs) for _, _, fs in os.walk(d)) - 1
data = sorted(f"{f['path']} {f['sha256']}" for f in m["files"] if f["path"] != "manifest.json" and not f["path"].startswith("report/"))
content = hashlib.sha256(("\n".join(data) + "\n").encode()).hexdigest()
print(f"manifest files {len(m['files'])}, on disk {on_disk} (+manifest), sha256 mismatches {bad}")
print(f"content hash recomputed {content == m['content_sha256']}: {content}")

def sql(q):
    return subprocess.run(["psql", dsn, "-tA", "-c", q], capture_output=True, text=True, check=True).stdout.strip()

idx = json.load(open(os.path.join(d, "index.json")))
city_files = os.listdir(os.path.join(d, "venues"))
venues, awards, prices, blurbs, natives = 0, 0, 0, 0, 0
google = 0
for name in city_files:
    t = open(os.path.join(d, "venues", name), encoding="utf-8").read()
    if re.search(r"ChIJ[0-9A-Za-z_-]{8,}", t) or re.search(r"googleusercontent|googleapis|gstatic|ggpht|maps\.google", t, re.I):
        google += 1
    for v in json.loads(t)["venues"]:
        venues += 1; awards += len(v["awards"]); prices += v["price"] is not None
        blurbs += v["blurb"] is not None; natives += v["name_native"] is not None
for name in ["index.json", "cities.json", "regions.json", "redirects.json", "attribution.json"]:
    t = open(os.path.join(d, name), encoding="utf-8").read()
    if re.search(r"ChIJ[0-9A-Za-z_-]{8,}", t): google += 1
pub = "join listings l on l.venue_id = {}.venue_id and l.property_id = 'eats' and l.published"
rows = [
    ("venues in index.json", len(idx), sql("select count(*) from venues v join listings l on l.venue_id=v.id and l.property_id='eats' and l.published where v.status='active'")),
    ("venue rows in city files", venues, sql("select count(*) from listings where property_id='eats' and published")),
    ("city files", len(city_files), sql("select count(distinct v.city_id) from venues v join listings l on l.venue_id=v.id and l.property_id='eats' and l.published")),
    ("award rows", awards, sql("select count(*) from awards a " + pub.format("a") + " join award_sources s on s.slug=a.source_id and s.status='active'")),
    ("price rows", prices, sql("select count(*) from price p " + pub.format("p"))),
    ("blurbs published", blurbs, sql("select count(*) from blurbs b " + pub.format("b") + " where b.status <> 'needs_rewrite'")),
    ("native names", natives, sql("select count(*) from venues v join listings l on l.venue_id=v.id and l.property_id='eats' and l.published where v.name_native is not null")),
    ("redirects", len(json.load(open(os.path.join(d, "redirects.json")))), sql("select (select count(*) from redirects) + (select count(*) from slugs s join listings l on l.venue_id=s.venue_id and l.property_id='eats' and l.published where not s.is_canonical and not exists (select 1 from redirects r join slugs c on c.venue_id=s.venue_id and c.is_canonical where r.from_path='/'||s.city_slug||'/'||s.slug and r.to_path='/'||c.city_slug||'/'||c.slug))")),
    ("files with a Google value", google, "0"),
]
for name, files_n, db_n in rows:
    print(f"{name:28} files {files_n:>7}  database {db_n:>7}  {'MATCH' if str(files_n) == str(db_n) else 'DIFFERS'}")
