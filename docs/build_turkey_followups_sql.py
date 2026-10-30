# build_turkey_followups_sql.py: Turkey 2026 follow-ups (Efendy, Lucien Arkas = LA Mahzen, Sankai status). Oct 30, 2026.
import hashlib, sys
rows = [
 ("ve_51ce2088a5","10663","relabel","https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy","Bib Gourmand"),
 ("ve_f088b7a06a","5648","status","active","One Star"),
 ("ve_f8013e6d34","10686","relabel","https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen","Bib Gourmand"),
]
relay = "\n".join("|".join(r) for r in rows)
sha = hashlib.sha256(relay.encode()).hexdigest(); md = hashlib.md5(relay.encode()).hexdigest()
open("michelin-turkey-2026-followups-relay-2026-10-30.txt","w",encoding="utf-8",newline="").write(relay)
sql = f"""-- michelin-turkey-2026-followups-2026-10-30.sql
-- Turkey 2026 follow-ups after the Turkey relabel (ledger 155-156). Ben's choices Oct 30, 14:31 ET, "A" for all.
-- Edition: The MICHELIN Guide Turkiye 2026 selection, published Dec 4, 2025:
-- https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-michelin-guide-turkiye-reveals-its-2026-restaurant-selection
-- W1 Efendy Istanbul ve_51ce2088a5, award 10663: year 2025 -> 2026, source_url NULL -> archive URL. Live card 404 (Oct 30).
--    web.archive.org captures Jan 6, Jan 13 (/en/) and Jan 28, 2026 (/de/de/): card id 1209218 "EFENDY", Bib, dateAwarded 2026,
--    CAT_P02, Nisbetiye Caddesi No:13, Levent. Venue status stays active (no closure evidence; recheck later).
-- W2 Lucien Arkas Baglari ve_f8013e6d34, award 10686: year 2025 -> 2026, source_url NULL -> LA Mahzen card URL (card 1208310,
--    Bib, dateAwarded 2026, Torbali, Izmir). Pairing proof: card text names the Domaine Lucien Arkas vineyards; card website link
--    lawines.com.tr/restaurant.aspx has the title "Lucien Arkas Baglari"; card named LA Mahzen since at least Aug 24, 2024
--    (archive). Venue name stays (venue's own spelling, ruling Oct 10). D4 promote of LA Mahzen is cancelled.
-- W3 Sankai by Nagaya ve_f088b7a06a: status closed -> active. Live card One Star 2026, no closure note; venue site no closure
--    notice; no closure found by web search. Closed status came from the Aug 14 sheet load (audit 4862). Ruling Oct 10.
-- No price change: Efendy and Lucien Arkas keep their legacy price rows (later P2 batch, D5). Sankai has no price row.
-- Relay sha256 {sha} (inside this file).
-- Guards: counts before (price 7714, ledger max 156, audit max 118694); relay md5 {md}; each row as read before the build;
-- URLs not in use. Post-checks: price 7714; ledgers 157 (award) and 158 (venue status); audit 118695 to 118697:
-- 2 awards UPDATE + 1 status-only venues UPDATE, nothing else; Turkey Michelin rows after: 2026 = 55, 2025 = 0; closed venues 367.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r${relay}$r$;
  v_upd int;
  v_lid1 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7714 THEN RAISE EXCEPTION 'price count before is not 7714'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 156 THEN RAISE EXCEPTION 'ledger max before is not 156'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118694 THEN RAISE EXCEPTION 'audit max before is not 118694'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 368 THEN RAISE EXCEPTION 'closed venues before is not 368'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF md5(rel_txt) <> '{md}' THEN RAISE EXCEPTION 'relay md5'; END IF;

  -- rows as read before the build
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
       WHERE c.country_iso = 'TR' AND a.source_id = 'michelin' AND a.year = 2025 AND a.source_url IS NULL
         AND a.category = 'Bib Gourmand' AND v.status = 'active'
         AND ((a.id = 10663 AND a.venue_id = 've_51ce2088a5') OR (a.id = 10686 AND a.venue_id = 've_f8013e6d34'))) <> 2
    THEN RAISE EXCEPTION 'award rows 10663/10686 changed since the read'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'michelin' AND venue_id IN ('ve_51ce2088a5', 've_f8013e6d34')) <> 2
    THEN RAISE EXCEPTION 'other Michelin rows on W1/W2 venues'; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id = v.city_id JOIN awards a ON a.venue_id = v.id
       WHERE v.id = 've_f088b7a06a' AND v.status = 'closed' AND c.country_iso = 'TR' AND a.id = 5648 AND a.year = 2026
         AND a.category = 'One Star' AND a.source_url = 'https://guide.michelin.com/us/en/istanbul-province/istanbul/restaurant/sankai-by-nagaya')
    THEN RAISE EXCEPTION 'Sankai row changed since the read'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url IN (
       'https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy',
       'https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen'))
    THEN RAISE EXCEPTION 'a URL is already in use'; END IF;

  -- W1 + W2
  UPDATE awards a SET year = 2026, source_url = split_part(l, '|', 4)
    FROM regexp_split_to_table(rel_txt, E'\\n') AS l
   WHERE split_part(l, '|', 3) = 'relabel' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 1)
     AND a.source_id = 'michelin' AND a.year = 2025 AND a.source_url IS NULL AND a.category = split_part(l, '|', 5);
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> 2 THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 2,
          'relabel:michelin-turkey-2026-followups-2026-10-30 | rule 2.1.7, Turkey 2026 (Dec 4, 2025) | award 10663 Efendy Istanbul: '
          || 'archive URL (card 1209218 Bib 2026, captures Jan 6/13/28 2026; live card 404) | award 10686 Lucien Arkas Baglari = LA Mahzen '
          || 'card 1208310 (card text names Domaine Lucien Arkas; card site link title Lucien Arkas Baglari); name unchanged, D4 promote '
          || 'cancelled | Ben "A" Oct 30 14:31 ET | relay md5 {md}')
  RETURNING id INTO v_lid1;

  -- W3 (status only; no ledger row: SLOW&LOW, De Groene Lantaarn and Regent precedent)
  IF (SELECT md5(to_jsonb(v)::text) FROM venues v WHERE v.id = 've_f088b7a06a') IS DISTINCT FROM '666fed8cd33fd973391ed253f8ab4f9a'
    THEN RAISE EXCEPTION 'Sankai venue row md5 changed since the read'; END IF;
  UPDATE venues SET status = 'active' WHERE id = 've_f088b7a06a' AND status = 'closed';
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> 1 THEN RAISE EXCEPTION 'venue rows updated: %', v_upd; END IF;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7714 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> 157 OR (SELECT max(id) FROM source_capture_ledger) <> 157 THEN RAISE EXCEPTION 'ledger ids %', v_lid1; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118694) <> 3 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118694 AND table_name = 'awards' AND action = 'UPDATE' AND row_pk IN ('10663', '10686')) <> 2
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118694 AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = 've_f088b7a06a'
         AND old_row->>'status' = 'closed' AND new_row->>'status' = 'active' AND (old_row - 'status') = (new_row - 'status')) <> 1
    THEN RAISE EXCEPTION 'audit venues UPDATE row'; END IF;
  IF (SELECT count(*) FROM awards a JOIN regexp_split_to_table(rel_txt, E'\\n') AS l ON a.id = split_part(l, '|', 2)::bigint
       WHERE split_part(l, '|', 3) = 'relabel' AND a.year = 2026 AND a.source_url = split_part(l, '|', 4)) <> 2
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT status::text FROM venues WHERE id = 've_f088b7a06a') <> 'active' THEN RAISE EXCEPTION 'Sankai status after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 367 THEN RAISE EXCEPTION 'closed venues after'; END IF;
  IF (SELECT count(*) FILTER (WHERE a.year = 2026) * 1000 + count(*) FILTER (WHERE a.year = 2025)
        FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
       WHERE a.source_id = 'michelin' AND c.country_iso = 'TR') <> 55000
    THEN RAISE EXCEPTION 'Turkey Michelin rows by year after'; END IF;
END
$do$;
COMMIT;
"""
open("michelin-turkey-2026-followups-2026-10-30.sql","w",encoding="utf-8").write(sql)
print(sha, md)
