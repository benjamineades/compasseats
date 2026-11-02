"""Build the Italy 2025 card-link match query (read-only) from the relay. No retyped rows.

Usage: python3 -I build_match_it_2025.py  -> writes match-query-it-2025.sql
Source: Michelin it/it article "Tutte le stelle della Guida MICHELIN Italia 2025!",
archive capture 20241105213726 (ceremony day, Nov 5, 2024, Parma).
"""
import hashlib, json, pathlib

here = pathlib.Path(__file__).parent
relay = (here / "relay-it-2025-archive-20241105.txt").read_text(encoding="ascii")
RELAY_SHA = hashlib.sha256(relay.encode()).hexdigest()
assert RELAY_SHA == "d5c2a9ebda5f251167ad8460c457a30ca133cd2ff4c0747e9f128f1a29b25b39", RELAY_SHA

CAT = {"3": "Three Stars", "2": "Two Stars", "1": "One Star"}
rows = []
for ln in relay.splitlines()[1:]:
    n, stars, region, city, name, new, moved, path = ln.split("|")
    slug = path.rsplit("/ristorante/", 1)[1].lower()
    rows.append([int(n), CAT[stars], slug])
assert len(rows) == 393
lit = json.dumps(rows, ensure_ascii=True).replace("'", "''")

sql = f"""-- Italy 2025 card-link match (read-only). relay sha256 {RELAY_SHA}
WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug FROM jsonb_array_elements('{lit}'::jsonb) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante|ristorante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/(restaurant|restaurante|ristorante)/' AND c.country_iso IN ('IT', 'SM')),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq)
SELECT p.seq, p.cat, p.slug, coalesce(t1.n, 0) n_venues, t1.vid,
       v.name vname, v.status, c.display city,
       (SELECT string_agg(a.year || ' ' || a.category, ', ' ORDER BY a.year, a.category) FROM awards a
         WHERE a.venue_id = t1.vid AND a.source_id = 'michelin') mich
  FROM p LEFT JOIN t1 USING (seq) LEFT JOIN venues v ON v.id = t1.vid LEFT JOIN cities c ON c.id = v.city_id
 ORDER BY p.seq;
"""
(here / "match-query-it-2025.sql").write_text(sql, encoding="ascii")
print("rows", len(rows), "sql bytes", len(sql))
