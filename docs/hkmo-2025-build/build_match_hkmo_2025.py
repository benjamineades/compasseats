"""Build a read-only match query: 2025 archive relay rows (stars, Bib, Green Star) -> HK/MO venues."""
import hashlib, sys
RELAY = sys.argv[1]
OUT = sys.argv[2]
raw = open(RELAY, encoding='ascii').read()
assert hashlib.sha256(raw.encode()).hexdigest() == '02bf30b13374118617211cf4973146b8048784e3717366e6aabcff5a9c0ca81b'
rows = []
for line in raw.splitlines():
    seq, region, cat, name, tag = line.split('|')
    if cat == 'Selected':
        continue
    name = name.encode('ascii').decode('unicode_escape').replace(' ', ' ')
    rows.append((int(seq), region, cat, name))
q = lambda s: "'" + s.replace("'", "''") + "'"
vals = ',\n'.join(f"({s},{q(r)},{q(c)},{q(n)})" for s, r, c, n in rows)
sql = f"""with r(seq,region,cat,name) as (values
{vals}),
c(region,city_id) as (values ('Hong Kong','ci_1b1537ad28'),('Macau','ci_9690a92f29')),
rk as (select r.*, c.city_id, norm_key(r.name) k1,
  norm_key(regexp_replace(r.name,'\\s*\\([^)]*\\)\\s*$','')) k2 from r join c using(region)),
vk as (select v.id, v.name, v.status, v.city_id, v.norm_key k1,
  norm_key(regexp_replace(v.name,'\\s*\\([^)]*\\)\\s*$','')) k2 from venues v where v.city_id in ('ci_1b1537ad28','ci_9690a92f29')),
m as (select rk.seq, vk.id, case when vk.k1=rk.k1 then 1 else 2 end tier
  from rk join vk on vk.city_id=rk.city_id and (vk.k1=rk.k1 or vk.k2=rk.k2))
select rk.seq, rk.region, rk.cat, rk.name,
  (select min(tier) from m where m.seq=rk.seq) tier,
  (select count(distinct id) from m where m.seq=rk.seq) n_venues,
  (select string_agg(distinct m.id||' '||v.name||' ['||v.status||'] 2026:'||coalesce((select string_agg(a.category,'+' order by a.category) from awards a where a.venue_id=v.id and a.source_id='michelin' and a.year=2026),'-')
     ||' 2025:'||coalesce((select string_agg(a.id||':'||a.category,'+') from awards a where a.venue_id=v.id and a.source_id='michelin' and a.year=2025),'-'),' ; ')
     from m join venues v on v.id=m.id where m.seq=rk.seq) venues
from rk order by rk.seq;
"""
open(OUT, 'w').write(sql)
print(len(rows), 'rows;', hashlib.sha256(sql.encode()).hexdigest())
