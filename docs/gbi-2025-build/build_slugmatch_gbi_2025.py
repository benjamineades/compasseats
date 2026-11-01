# Builds the read-only slug match query from the link map (no hand typing).
import hashlib
lk = 'links-gbi-2025-archive-20250211.txt'
raw = open(lk, 'rb').read(); sha = hashlib.sha256(raw).hexdigest()
vals = []
for line in raw.decode('ascii').splitlines():
    seq, slug, path = line.split('|')
    vals.append("(%d,'%s')" % (int(seq), slug.lower().replace("'", "''")))
sql = f"""-- GB&I 2025 slug match (read-only). links sha256 {sha}
WITH l(seq, slug) AS (VALUES {','.join(vals)}),
 a AS (SELECT DISTINCT lower(substring(split_part(a.source_url,'?',1) from '/restaurant/([^/]+)/?$')) slug, a.venue_id
         FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
        WHERE a.source_id='michelin' AND a.source_url ~ '/restaurant/' AND c.country_iso IN ('GB','IE','JE')),
 m AS (SELECT l.seq, l.slug, count(a.venue_id) n, min(a.venue_id) vid FROM l LEFT JOIN a ON a.slug=l.slug GROUP BY 1,2)
SELECT m.seq, m.slug, m.n, m.vid, v.name, v.status FROM m LEFT JOIN venues v ON v.id=m.vid WHERE m.n<>1 ORDER BY m.seq;
"""
open('slugmatch-query-gbi-2025.sql', 'w').write(sql)
print(sha); print(sql[-600:])
