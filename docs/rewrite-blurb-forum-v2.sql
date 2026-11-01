-- rewrite-blurb-forum-v2.sql  (built by docs/forum-blurb-build/build_forum_blurb_v2.py; do not edit by hand)
-- Open item 1: Forum blurb. Ben's choices Nov 1 14:01 ET: A1 (draft as is), B1 (version 2, status rewritten, 4 source URLs),
-- C1 (database only), D1 (venues.chef unchanged), E1 (1 ledger row).
-- One transaction. Writes: 1 UPDATE on blurbs (trigger writes 1 audit row), 1 INSERT on source_capture_ledger.
-- Gates: ledger max 211, audit max 121,933, blurbs 142, old Forum row md5 b310ca68e92a826262fb7dc6e97df728.
DO $do$
DECLARE
  v_old_md5 text;
  v_new_md5 text;
  v_cnt int;
  v_ledger_id bigint;
BEGIN
  -- pre-gates
  IF (SELECT max(id) FROM source_capture_ledger) <> 211 THEN RAISE EXCEPTION 'gate: ledger max is not 211'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 121933 THEN RAISE EXCEPTION 'gate: audit max is not 121933'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'gate: blurbs count is not 142'; END IF;
  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||coalesce(sources::text,'NULL'))
    INTO v_old_md5 FROM blurbs WHERE venue_id = 've_fe4ae32eec';
  IF v_old_md5 IS DISTINCT FROM 'b310ca68e92a826262fb7dc6e97df728' THEN
    RAISE EXCEPTION 'gate: old Forum row md5 is %', v_old_md5;
  END IF;

  -- write 1: the blurb
  UPDATE blurbs
     SET short   = 'Yeung Koon-yat, Hong Kong''s "abalone king," made Forum famous with abalone braised for 12 to 14 hours. It''s still the dish to order at this three-star Causeway Bay classic.',
         long    = 'It took Yeung Koon-yat 3 years to learn how to cook abalone, and the method he settled on is still why people book Forum. Dried Japanese abalone goes into a clay pot on a bed of bamboo shoots and spare ribs, with chicken on top, and braises for 12 to 14 hours. The dish carries his name: Ah Yat''s abalone. He cooked it for Deng Xiaoping in 1984 and for Jacques Chirac in 1995. Yeung died in 2023, at 90. Chef Adam Wong, at Forum for more than 30 years and named as his culinary heir, keeps the Cantonese classics on the menu, and the dining room has barely changed. It holds 3 Michelin stars. Order the abalone, then the Ah Yat fried rice, which has a following of its own.',
         version = 2,
         status  = 'rewritten',
         sources = '["https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/forum","https://en.wikipedia.org/wiki/Forum_Restaurant","https://scmp.com/lifestyle/food-drink/article/3271544/celebrating-hong-kongs-abalone-king-yeung-koon-yat-chef-adam-wong-recalls-his-mentor","https://100toptables.scmp.com/restaurants-profile-2026/forum-restaurant"]'::jsonb
   WHERE venue_id = 've_fe4ae32eec';
  GET DIAGNOSTICS v_cnt = ROW_COUNT;
  IF v_cnt <> 1 THEN RAISE EXCEPTION 'post: blurb rows updated %', v_cnt; END IF;

  -- write 2: the ledger row
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('compasseats', 'blurb', 1, 'blurb:rewrite-forum-ve_fe4ae32eec | open item 1 (Ben, Nov 1 14:01 ET "A1, B1, C1, D1, E1"): Option B blurb v2 for Forum (Hong Kong), rewritten from fetched sources per the Option B runbook + humanizer layer; name "Forum" now used | version 1 -> 2, status needs_rewrite -> rewritten, sources = 4 URLs (Michelin card, Wikipedia, SCMP 2024, SCMP 100 Top Tables 2026) | C1 database only (Sheet / ImportOptionB.gs unchanged); D1 venues.chef unchanged | draft docs/forum-blurb-build/draft-forum-blurb-v2.txt sha256 bf3cccf3...f7acc7')
  RETURNING id INTO v_ledger_id;

  -- post-checks
  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||sources::text)
    INTO v_new_md5 FROM blurbs WHERE venue_id = 've_fe4ae32eec';
  IF v_new_md5 IS DISTINCT FROM '523fd41f18ba8380b85e1db41bf1a526' THEN RAISE EXCEPTION 'post: new Forum row md5 is %', v_new_md5; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'post: blurbs count changed'; END IF;
  IF (SELECT count(*) FROM blurbs WHERE status = 'rewritten') <> 1 THEN RAISE EXCEPTION 'post: rewritten count is not 1'; END IF;
  SELECT count(*) INTO v_cnt FROM audit_log WHERE id > 121933;
  IF v_cnt <> 1 THEN RAISE EXCEPTION 'post: new audit rows %', v_cnt; END IF;
  SELECT count(*) INTO v_cnt FROM audit_log
   WHERE id > 121933 AND table_name = 'blurbs' AND action = 'UPDATE' AND row_pk = 've_fe4ae32eec'
     AND (old_row->>'version') = '1' AND (new_row->>'version') = '2';
  IF v_cnt <> 1 THEN RAISE EXCEPTION 'post: audit row for blurbs UPDATE not found'; END IF;
  SELECT count(*) INTO v_cnt FROM source_capture_ledger WHERE id > 211;
  IF v_cnt <> 1 OR v_ledger_id IS NULL THEN RAISE EXCEPTION 'post: new ledger rows %', v_cnt; END IF;
  RAISE NOTICE 'OK: ledger id %, new row md5 %', v_ledger_id, v_new_md5;
END
$do$;
