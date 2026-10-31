-- city_venue_counts: live venue counts per city (open items block 4, item 2, option B part 2; Ben, Oct 31, 2026).
-- The view counts at read time, so it cannot drift. cities.venues_count stays as a stored copy
-- (recounted once on Oct 31, 2026 by docs/cities-venues-count-recount-2026-10-31.sql).
-- security_invoker = true: a reader sees only what the RLS rules on cities and venues let that reader see.
-- No data changes, no audit rows.
CREATE VIEW public.city_venue_counts WITH (security_invoker = true) AS
SELECT c.id          AS city_id,
       c.slug,
       c.display,
       c.country_iso,
       count(v.id) FILTER (WHERE v.status = 'active')::int AS active_venues,
       count(v.id)::int                                    AS all_venues
  FROM public.cities c
  LEFT JOIN public.venues v ON v.city_id = c.id
 GROUP BY c.id, c.slug, c.display, c.country_iso;

COMMENT ON VIEW public.city_venue_counts IS
  'Live venue counts per city (active_venues = venues with status active). Use this, not the stored cities.venues_count.';
