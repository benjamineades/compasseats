-- CHECK31-9b41317fde1616ba243ee3daa1e9b7d5
WITH p(venue_id, new_name) AS (VALUES ('ve_04c2784726', 'Forentum'), ('ve_e574aeb7fd', 'Les Fresques')),
plan AS (
  SELECT v.id venue_id, p.new_name, s.city_slug, s.slug old_slug,
         trim(both '-' from regexp_replace(lower(f_unaccent(p.new_name)), '[^a-z0-9]+', '-', 'g')) new_slug
    FROM p JOIN venues v ON v.id = p.venue_id
    JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical)
SELECT 'CHECK31-9b41317fde1616ba243ee3daa1e9b7d5' marker,
  (SELECT md5(string_agg(venue_id||'|'||new_name||'|'||city_slug||'|'||old_slug||'|'||new_slug, E'\n' ORDER BY venue_id)) FROM plan WHERE new_slug <> old_slug) slug_fp,
  (SELECT count(*) FROM plan WHERE new_slug <> old_slug) slug_plan_n,
  (SELECT string_agg(city_slug||'/'||old_slug||' -> '||new_slug, '; ' ORDER BY venue_id) FROM plan) slug_plan,
  (SELECT count(*) FROM plan WHERE new_slug = '') empty_n,
  (SELECT count(*) FROM plan p2 JOIN slugs s ON s.property_id='eats' AND s.city_slug=p2.city_slug AND s.slug=p2.new_slug AND (s.venue_id<>p2.venue_id OR s.is_canonical)) in_use_other,
  (SELECT md5(string_agg(p2.venue_id||'|'||p2.city_slug||'|'||p2.new_slug, E'\n' ORDER BY p2.venue_id)) FROM plan p2 JOIN slugs s ON s.property_id='eats' AND s.venue_id=p2.venue_id AND s.city_slug=p2.city_slug AND s.slug=p2.new_slug AND NOT s.is_canonical) reuse_fp,
  (SELECT count(*) FROM redirects d, plan p2 WHERE d.from_path IN ('/'||p2.city_slug||'/'||p2.new_slug, '/venue/'||p2.city_slug||'/'||p2.new_slug)) in_redirects,
  (SELECT count(*) FROM p JOIN venues v ON v.id=p.venue_id JOIN venues o ON o.city_id=v.city_id AND o.id<>v.id AND norm_key(o.name)=norm_key(p.new_name)) norm_collisions,
  (SELECT string_agg(p.venue_id||':'||norm_key(p.new_name), ',' ORDER BY p.venue_id) FROM p) new_norm_keys,
  (SELECT md5(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count) FROM cities c WHERE c.id='ci_b8de1219b5') city_fp,
  (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key) FROM venues v WHERE v.id='ve_b44e9a2762') venue_fp,
  (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) FROM venues v WHERE v.id='ve_b44e9a2762') t_new_slug,
  (SELECT count(*) FROM slugs s WHERE s.property_id='eats' AND s.city_slug='telluride') t_slugs_in_new_city,
  (SELECT count(*) FROM redirects d WHERE d.from_path LIKE '/telluride/%' OR d.from_path LIKE '/telleruide/%' OR d.to_path LIKE '/telleruide/%') t_redirects;
