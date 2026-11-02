-- fix-status-sweep-7-active-2026-11-02.sql
-- CompassEats, Nov 2 2026. Closed-venue sweep, item 6. Ben: 15:22 ET "1A, 2A, 3A, 4A, 5A". This file runs only after his "go".
-- Scope: 7 venues, status closed to active and listings.published false to true, in one transaction, with city counts.
-- Groups: Group 1 dated 2026 evidence or own site with season or booking (3). Group 2 undated or 2025 evidence, no closure news (4; Ben 1A).
-- Other 117 venues of the 124: no change. Evidence for all 124: docs/closed-sweep-2026-11-02/closed-sweep-item6-evidence-2026-11-02.csv.
-- Award rows, names, slugs and price do not change (Ben 4A: rename read is separate). No ledger row (status precedent). No live page changes: the live site reads the Sheet.
-- Expected after: venues 11,294 (active 10,997, closed 297); cities sum 10,997; closed published 0; active not published 0; audit_log +21 (cities 7, listings 7, venues 7).
--
--   Group 1 | ve_62570bae63 | Chez Vrony | OPEN_SEASONAL/strong | Own site chezvrony.ch lists 2026 seasons: summer 20 Jun to 11 Oct 2026 and winter 28 Nov 2026 to 11 Apr 2027, daily 11:30-16:00, online booking, no closure notice. Zermatt Tourism article (2025-07-17) and a Michelin card show it as a live listing. Today (2 Nov) falls in the gap between seasons. | https://www.chezvrony.ch https://zermatt.swiss/ztm/zermatt-tourism-meets/chez-vrony https://guide.michelin.com/ch/de/wallis/zermatt/restaurant/chez-vrony
--   Group 1 | ve_4aa5923e99 | Talavera | OPEN/medium | Four Seasons Resort Scottsdale own Talavera page lists dinner Wed-Sun 5-9pm with a Reserve a Table button and no closure notice; page footer carries 2026 copyright. Dining overview lists Talavera as the resort's signature restaurant. | https://www.fourseasons.com/scottsdale/dining/restaurants/talavera/ https://www.fourseasons.com/scottsdale/dining/
--   Group 1 | ve_c71805d8dd | The Union Trading Company Bar | OPEN/medium | Second read: The Spirits Business (30 Jun 2026) names Union Trading Company as a current Yao Lu venue in Shanghai. That's (31 Jul 2025) lists its 11th anniversary guest week. A Sep 2023 Wanderlog review says it moved to 306 Hengshan Rd, which can explain the closed flag. | https://www.thespiritsbusiness.com/?p=915429 https://www.thatsmags.com/shanghai/post/39384/the-buzz-shanghai-cocktail-calendar-august-2025 https://wanderlog.com/place/details/119793/the-union-trading-company-bar
--   Group 2 | ve_e5e9d66f60 | D.F. Cantina by Barbary Coast | OPEN/medium | Time Out Singapore page for Deadfall Cantina (first published 2024-09-04, last updated 2026-08-08) lists current hours at 16 North Canal Road and says Deadfall Cantina sits downstairs from Barbary Coast. Page does not say 'D.F. Cantina'; The Drinks Business (Oct 2024) titled an article on 'DF Cantina' in Singapore (not opened). | https://www.timeout.sg/bars/deadfall-cantina https://www.thedrinksbusiness.com/2024/10/df-cantina-taps-into-singapore-growing-thirst-for-agave/
--   Group 2 | ve_e1e3a5810d | Drink | OPEN/medium | Boston.com (2021-12-02) reports Drink at 348 Congress St reopened 2021-11-18 after a July renovation closure. The bar's own site drinkfortpoint.com is live with 'open nightly 4pm-1am', food service hours and a Tiki Sundays note, no closure notice (undated). | https://www.boston.com/food/breweries-bars/2021/12/02/fort-point-drink-cocktail-bar-menu/ http://drinkfortpoint.com/ https://www.opentable.co.uk/r/drink-boston
--   Group 2 | ve_5b37d2dbd7 | Floreria Atlantico Barcelona | OPEN/medium | Falstaff (2025 cocktail bar ranking, score 85) lists it as open, saying it opened about two years earlier. The World's 50 Best Discovery page and Difford's list current hours (Wed-Sun) at Av. del Marques de l'Argentera 19, with no closure note (undated). | https://www.falstaff.com/en/bars/floreria-atlantico-1 https://www.the50.com/discovery/Establishments/Spain/Barcelona/Florer%C3%ADa-Atl%C3%A1ntico-Barcelona.html https://www.diffordsguide.com/bars/z260yz/florera-atlntico-barcelona
--   Group 2 | ve_d9cd4fd552 | Sherry Butt | OPEN/medium | The Paris tourist office listing (parisjetaime.com) shows 20 rue Beautreillis with hours and an empty closings section; mesprestiges.com lists it with a phone number and 'last reviewed May 2026'. Privateaser also lists it with no closure notice. | https://parisjetaime.com/eng/restaurant/sherry-butt-p620 https://mesprestiges.com/en/paris/places/sherry-butt https://www.privateaser.com/lieu/41078-sherry-butt

BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text;
  va constant text[] := ARRAY['ve_4aa5923e99','ve_5b37d2dbd7','ve_62570bae63','ve_c71805d8dd','ve_d9cd4fd552','ve_e1e3a5810d','ve_e5e9d66f60'];
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11294 OR (SELECT count(*) FROM venues WHERE status='active') <> 10990 OR (SELECT count(*) FROM venues WHERE status='closed') <> 304 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10990 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11294 OR (SELECT count(*) FROM listings WHERE property_id <> 'eats') <> 0 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13019 OR (SELECT count(*) FROM price) <> 7727 THEN RAISE EXCEPTION 'awards slugs price before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 237 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118806 OR aud_max <> 124320 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (va);
  IF s IS DISTINCT FROM '9fa058a0174517fa1e2c6984d8c7d2b7' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(c.id||'|'||c.venues_count, E'\n' ORDER BY c.id COLLATE "C")) INTO s FROM cities c WHERE c.id IN (SELECT DISTINCT city_id FROM venues WHERE id = ANY (va));
  IF s IS DISTINCT FROM '1fbabdd9692ad422217dad08860184e6' THEN RAISE EXCEPTION 'city fingerprint %', s; END IF;
  -- WRITE
  UPDATE venues SET status='active' WHERE id = ANY (va) AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=true WHERE venue_id = ANY (va) AND NOT published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=112 WHERE id='ci_22638a3131' AND venues_count=111;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_22638a3131 %', n; END IF;
  UPDATE cities SET venues_count=15 WHERE id='ci_6aecdfe8b0' AND venues_count=14;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_6aecdfe8b0 %', n; END IF;
  UPDATE cities SET venues_count=5 WHERE id='ci_8012e949be' AND venues_count=4;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_8012e949be %', n; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_c3e9bb7d26' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_c3e9bb7d26 %', n; END IF;
  UPDATE cities SET venues_count=214 WHERE id='ci_ccbee73cd8' AND venues_count=213;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_ccbee73cd8 %', n; END IF;
  UPDATE cities SET venues_count=206 WHERE id='ci_d3197fb64e' AND venues_count=205;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_d3197fb64e %', n; END IF;
  UPDATE cities SET venues_count=73 WHERE id='ci_dea56e47f1' AND venues_count=72;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_dea56e47f1 %', n; END IF;
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11294 OR (SELECT count(*) FROM venues WHERE status='active') <> 10997 OR (SELECT count(*) FROM venues WHERE status='closed') <> 297 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10997 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND NOT l.published) <> 297 THEN RAISE EXCEPTION 'closed not published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13019 OR (SELECT count(*) FROM price) <> 7727 THEN RAISE EXCEPTION 'awards slugs price after'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 237 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=7,listings:UPDATE=7,venues:UPDATE=7' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (va) AND (old_row-'status')=(new_row-'status') AND old_row->>'status'='closed' AND new_row->>'status'='active') <> 7 THEN RAISE EXCEPTION 'audit status rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='listings' AND row_pk = ANY (va) AND (old_row-'published')=(new_row-'published') AND old_row->>'published'='false' AND new_row->>'published'='true') <> 7 THEN RAISE EXCEPTION 'audit published rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
