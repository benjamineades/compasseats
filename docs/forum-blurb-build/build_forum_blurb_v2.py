"""Build docs/rewrite-blurb-forum-v2.sql from draft-forum-blurb-v2.txt (no hand-retyped text)."""
import hashlib, json, re, sys, pathlib
here = pathlib.Path(__file__).parent
draft = (here / "draft-forum-blurb-v2.txt").read_text(encoding="utf-8")
venue = re.search(r"^venue_id: (\S+)$", draft, re.M).group(1)
short = re.search(r"^short: (.*)$", draft, re.M).group(1)
long_ = re.search(r"^long: (.*)$", draft, re.M).group(1)
assert venue == "ve_fe4ae32eec" and len(short) <= 180 and "—" not in short + long_
assert all(ord(c) < 128 for c in short + long_)
sources = [
    "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/forum",
    "https://en.wikipedia.org/wiki/Forum_Restaurant",
    "https://scmp.com/lifestyle/food-drink/article/3271544/celebrating-hong-kongs-abalone-king-yeung-koon-yat-chef-adam-wong-recalls-his-mentor",
    "https://100toptables.scmp.com/restaurants-profile-2026/forum-restaurant",
]
src_json = json.dumps(sources, separators=(",", ":"))
q = lambda t: "'" + t.replace("'", "''") + "'"
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
new_md5 = md5(f"{short}|{long_}|option_b|2|rewritten|{json.dumps(sources)}")  # jsonb::text form: ", " separators
draft_sha = hashlib.sha256(draft.encode()).hexdigest()
job = (f"blurb:rewrite-forum-{venue} | open item 1 (Ben, Nov 1 14:01 ET \"A1, B1, C1, D1, E1\"): Option B blurb v2 for Forum "
       f"(Hong Kong), rewritten from fetched sources per the Option B runbook + humanizer layer; name \"Forum\" now used | "
       f"version 1 -> 2, status needs_rewrite -> rewritten, sources = 4 URLs (Michelin card, Wikipedia, SCMP 2024, SCMP 100 Top Tables 2026) | "
       f"C1 database only (Sheet / ImportOptionB.gs unchanged); D1 venues.chef unchanged | draft docs/forum-blurb-build/draft-forum-blurb-v2.txt sha256 {draft_sha[:8]}...{draft_sha[-6:]}")
sql = f"""-- rewrite-blurb-forum-v2.sql  (built by docs/forum-blurb-build/build_forum_blurb_v2.py; do not edit by hand)
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
    INTO v_old_md5 FROM blurbs WHERE venue_id = {q(venue)};
  IF v_old_md5 IS DISTINCT FROM 'b310ca68e92a826262fb7dc6e97df728' THEN
    RAISE EXCEPTION 'gate: old Forum row md5 is %', v_old_md5;
  END IF;

  -- write 1: the blurb
  UPDATE blurbs
     SET short   = {q(short)},
         long    = {q(long_)},
         version = 2,
         status  = 'rewritten',
         sources = {q(src_json)}::jsonb
   WHERE venue_id = {q(venue)};
  GET DIAGNOSTICS v_cnt = ROW_COUNT;
  IF v_cnt <> 1 THEN RAISE EXCEPTION 'post: blurb rows updated %', v_cnt; END IF;

  -- write 2: the ledger row
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('compasseats', 'blurb', 1, {q(job)})
  RETURNING id INTO v_ledger_id;

  -- post-checks
  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||sources::text)
    INTO v_new_md5 FROM blurbs WHERE venue_id = {q(venue)};
  IF v_new_md5 IS DISTINCT FROM '{new_md5}' THEN RAISE EXCEPTION 'post: new Forum row md5 is %', v_new_md5; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'post: blurbs count changed'; END IF;
  IF (SELECT count(*) FROM blurbs WHERE status = 'rewritten') <> 1 THEN RAISE EXCEPTION 'post: rewritten count is not 1'; END IF;
  SELECT count(*) INTO v_cnt FROM audit_log WHERE id > 121933;
  IF v_cnt <> 1 THEN RAISE EXCEPTION 'post: new audit rows %', v_cnt; END IF;
  SELECT count(*) INTO v_cnt FROM audit_log
   WHERE id > 121933 AND table_name = 'blurbs' AND action = 'UPDATE' AND row_pk = {q(venue)}
     AND (old_row->>'version') = '1' AND (new_row->>'version') = '2';
  IF v_cnt <> 1 THEN RAISE EXCEPTION 'post: audit row for blurbs UPDATE not found'; END IF;
  SELECT count(*) INTO v_cnt FROM source_capture_ledger WHERE id > 211;
  IF v_cnt <> 1 OR v_ledger_id IS NULL THEN RAISE EXCEPTION 'post: new ledger rows %', v_cnt; END IF;
  RAISE NOTICE 'OK: ledger id %, new row md5 %', v_ledger_id, v_new_md5;
END
$do$;
"""
out = here.parent / "rewrite-blurb-forum-v2.sql"
out.write_text(sql, encoding="utf-8")
print("new_md5", new_md5)
print("sha256", hashlib.sha256(sql.encode()).hexdigest(), "lines", sql.count("\n"))
