"""Write the read-only match query for the Taiwan 2025 relay (no hand-retyped names)."""
import json, pathlib, hashlib
here = pathlib.Path(__file__).parent
relay = here / "relay-tw-2025-archive-20251115192102.txt"
raw = relay.read_text(encoding="ascii")
rows = []
for ln in raw.splitlines():
    seq, cat, city, name, mark = ln.split("|")
    name = name.encode("ascii").decode("unicode_escape")
    rows.append([int(seq), city, cat, name, mark])
pj = json.dumps(rows, ensure_ascii=True).replace("'", "''")
q = f"""-- Taiwan 2025 match query (read-only). relay sha256 {hashlib.sha256(raw.encode()).hexdigest()}
WITH p AS (SELECT (e->>0)::int seq, e->>1 city, e->>2 cat, e->>3 nm, e->>4 mark
             FROM jsonb_array_elements('{pj}'::jsonb) e),
  c(city, city_id) AS (VALUES ('Taipei','ci_39139f000b'),('Taichung','ci_6d39e9b076'),('Kaohsiung','ci_c65258d965')),
  pk AS (SELECT p.*, c.city_id, norm_key(p.nm) k1, norm_key(regexp_replace(p.nm, '\\s*\\([^)]*\\)\\s*$', '')) k2 FROM p JOIN c USING (city)),
  vk AS (SELECT v.id, v.city_id, v.name, v.status, coalesce(v.norm_key, norm_key(v.name)) k1,
                norm_key(regexp_replace(v.name, '\\s*\\([^)]*\\)\\s*$', '')) k2
           FROM venues v WHERE v.city_id IN ('ci_39139f000b','ci_6d39e9b076','ci_c65258d965')),
  t1 AS (SELECT pk.seq, count(*) n, min(vk.id) vid FROM pk JOIN vk ON vk.city_id=pk.city_id AND vk.k1=pk.k1 GROUP BY pk.seq),
  t2 AS (SELECT pk.seq, count(*) n, min(vk.id) vid FROM pk JOIN vk ON vk.city_id=pk.city_id AND vk.k2=pk.k2 GROUP BY pk.seq),
  r AS (SELECT pk.seq, pk.city, pk.cat, pk.nm, pk.mark,
          CASE WHEN t1.n=1 THEN t1.vid WHEN t1.n IS NULL AND t2.n=1 THEN t2.vid END vid,
          CASE WHEN t1.n=1 THEN 't1' WHEN t1.n IS NULL AND t2.n=1 THEN 't2' WHEN coalesce(t1.n,t2.n,0)>1 THEN 'multi' ELSE 'none' END how
        FROM pk LEFT JOIN t1 USING (seq) LEFT JOIN t2 USING (seq))
SELECT r.seq, r.city, r.cat, r.nm, r.mark, r.how, r.vid, v.name vname, v.status,
  (SELECT string_agg(a.id||':'||a.category||':'||coalesce(left(a.source_url,40),'null'), ' ; ') FROM awards a
     WHERE a.venue_id=r.vid AND a.source_id='michelin' AND a.year=2025) m2025,
  (SELECT string_agg(a.category, ',') FROM awards a WHERE a.venue_id=r.vid AND a.source_id='michelin' AND a.year=2026) m2026
FROM r LEFT JOIN venues v ON v.id=r.vid ORDER BY r.seq;
"""
(here / "match-query-tw-2025.sql").write_text(q, encoding="utf-8")
print(len(rows), "rows; query bytes", len(q))
