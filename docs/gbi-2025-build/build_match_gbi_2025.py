# Builds the read-only GB&I 2025 match query from the relay file (no hand typing).
import hashlib, json, sys
relay = 'relay-gbi-2025-archive-20250211.txt'
raw = open(relay, 'rb').read()
sha = hashlib.sha256(raw).hexdigest()
rows = []
for line in raw.decode('ascii').splitlines():
    seq, cat, city, name, mark = line.split('|')
    rows.append([int(seq), cat, city, name, mark])
# json with \u escapes kept as JSON escapes; Postgres jsonb decodes them.
arr = '[' + ', '.join('[%d, "%s", "%s", "%s", "%s"]' % (r[0], r[1], r[2], r[3], r[4]) for r in rows) + ']'
json.loads(arr)  # check
arr = arr.replace("'", "''")
sql = f"""-- GB&I 2025 match query (read-only). relay sha256 {sha}
WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city, e->>3 nm, e->>4 mark FROM jsonb_array_elements('{arr}'::jsonb) e),
  pk AS (SELECT p.*, norm_key(p.nm) k1, norm_key(regexp_replace(p.nm, '\\s*\\([^)]*\\)\\s*$', '')) k2 FROM p),
  vk AS (SELECT v.id, v.name, v.status, c.display cdisp, coalesce(v.norm_key, norm_key(v.name)) k1
           FROM venues v JOIN cities c ON c.id=v.city_id WHERE c.country IN ('United Kingdom','Ireland')),
  cand AS (SELECT pk.seq, vk.id, vk.name, vk.status, vk.cdisp, (lower(vk.cdisp)=lower(pk.city)) samecity
             FROM pk JOIN vk ON vk.k1=pk.k1 OR vk.k1=pk.k2)
SELECT pk.seq, pk.cat, pk.city, pk.nm, pk.mark, pk.k1 IS NULL nullkey,
  (SELECT count(*) FROM cand WHERE cand.seq=pk.seq) ncand,
  (SELECT count(*) FROM cand WHERE cand.seq=pk.seq AND samecity) nsame,
  (SELECT string_agg(id||'|'||name||'|'||cdisp||'|'||status, ' ; ') FROM cand WHERE cand.seq=pk.seq) cands
FROM pk ORDER BY pk.seq;
"""
open('match-query-gbi-2025.sql', 'w').write(sql)
print(sha, len(rows))
