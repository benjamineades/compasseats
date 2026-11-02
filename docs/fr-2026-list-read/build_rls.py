import hashlib
sql='''-- rls-three-tables-2026-11-02.sql
-- CompassEats, Nov 2 2026. Open item 19 of handoff-open-items-g1-h1-done-2026-11-02.md. Ben: Nov 2 10:21 ET "1A". This file runs only after his "go".
-- Turns on Row Level Security on award_categories, rename_batches, rename_rows, the last 3 public tables with RLS off.
-- No policy is added: the other 21 public tables have RLS on and 0 policies. anon and authenticated then get no rows from these 3 tables.
-- The owner postgres (the SUPABASE_DB_URL jobs) and supabase_read_only_user have BYPASSRLS, and RLS is not forced. Rows do not change.
-- Undo: ALTER TABLE public.<table> DISABLE ROW LEVEL SECURITY; for each table. No ledger row (not a publisher job). No audit row (DDL).
-- Dry run: send the DO block through the Read connector. It stops at the first ALTER with "read-only transaction".
BEGIN;
DO $fix$
DECLARE n bigint; a_max bigint;
  t constant text[] := ARRAY['award_categories','rename_batches','rename_rows'];
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM pg_class c JOIN pg_namespace ns ON ns.oid=c.relnamespace WHERE ns.nspname='public' AND c.relkind='r' AND c.relrowsecurity) <> 21 THEN RAISE EXCEPTION 'RLS on before'; END IF;
  IF (SELECT count(*) FROM pg_class c JOIN pg_namespace ns ON ns.oid=c.relnamespace WHERE ns.nspname='public' AND c.relkind='r' AND NOT c.relrowsecurity AND c.relname = ANY (t) AND pg_get_userbyid(c.relowner)='postgres' AND NOT c.relforcerowsecurity) <> 3 THEN RAISE EXCEPTION 'target tables before'; END IF;
  IF (SELECT count(*) FROM pg_policies WHERE schemaname='public') <> 0 THEN RAISE EXCEPTION 'policies before'; END IF;
  IF (SELECT count(*) FROM award_categories) <> AC OR (SELECT count(*) FROM rename_batches) <> 24 OR (SELECT count(*) FROM rename_rows) <> 1285 THEN RAISE EXCEPTION 'rows before'; END IF;
  SELECT max(id) INTO a_max FROM audit_log;
  -- WRITE
  ALTER TABLE public.award_categories ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.rename_batches ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.rename_rows ENABLE ROW LEVEL SECURITY;
  -- POST gates
  IF (SELECT count(*) FROM pg_class c JOIN pg_namespace ns ON ns.oid=c.relnamespace WHERE ns.nspname='public' AND c.relkind='r' AND NOT c.relrowsecurity) <> 0 THEN RAISE EXCEPTION 'RLS off after'; END IF;
  IF (SELECT count(*) FROM pg_class c JOIN pg_namespace ns ON ns.oid=c.relnamespace WHERE ns.nspname='public' AND c.relkind='r' AND c.relrowsecurity) <> 24 THEN RAISE EXCEPTION 'RLS on after'; END IF;
  IF (SELECT count(*) FROM award_categories) <> AC OR (SELECT count(*) FROM rename_batches) <> 24 OR (SELECT count(*) FROM rename_rows) <> 1285 THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT max(id) FROM audit_log) IS DISTINCT FROM a_max THEN RAISE EXCEPTION 'audit moved'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
import sys
sql=sql.replace('<> AC','<> '+sys.argv[1])
open(sys.argv[2],'w',encoding='utf-8',newline='\n').write(sql)
print(hashlib.sha256(sql.encode()).hexdigest())
