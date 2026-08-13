-- ============================================================================
-- COMPASS NETWORK — CANONICAL SCHEMA v1.0 · August 13, 2026
-- Encodes Re-Architecture Plan v1.14 §4 + Phase 1 Schema Map v1.7 (signed off).
-- Run ONCE on a fresh Supabase project, in the SQL Editor.
-- Runs as one transaction: it lands whole, or not at all.
-- ============================================================================
BEGIN;

-- ---------- extensions + normaliser ----------
CREATE EXTENSION IF NOT EXISTS unaccent;

-- unaccent() is not IMMUTABLE by default; this wrapper is, so it can back
-- generated columns. Standard, safe pattern.
CREATE OR REPLACE FUNCTION f_unaccent(text)
  RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
  AS $$ SELECT public.unaccent('public.unaccent', $1) $$;

-- THE one normalisation rule (settled Aug 11): NFKD-fold accents, lowercase,
-- strip non-alphanumerics. Used for the stored norm_key and the dedupe gate.
CREATE OR REPLACE FUNCTION norm_key(text)
  RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
  AS $$ SELECT regexp_replace(lower(f_unaccent($1)), '[^a-z0-9]+', '', 'g') $$;

-- ---------- enums (structural vocabularies; google is not a value) ----------
CREATE TYPE venue_category  AS ENUM ('restaurant','bar');
CREATE TYPE venue_status    AS ENUM ('active','closed');
CREATE TYPE city_kind       AS ENUM ('city','destination_region');
CREATE TYPE geo_precision   AS ENUM ('venue','venue_low','street','neighbourhood','city');
CREATE TYPE accept_gate_t   AS ENUM ('agreement','strong_poi','exact_name','ingest','manual');
CREATE TYPE geo_source_t    AS ENUM ('venue_site','guide_ingest','overture','geoapify','tomtom','manual');
CREATE TYPE price_source_t  AS ENUM ('legacy_guide','guide_ingest','venue_site','manual');
CREATE TYPE price_method_t  AS ENUM ('published_symbol','menu_derived');
CREATE TYPE source_status_t AS ENUM ('active','suspended');
CREATE TYPE label_column_t  AS ENUM ('neighborhood','city_display','country');
CREATE TYPE batch_status_t  AS ENUM ('staged','approved','promoted','rejected');

-- ---------- properties (D9: N properties, not two) ----------
CREATE TABLE properties (
  id       text PRIMARY KEY CHECK (id ~ '^[a-z][a-z0-9-]*$'),
  display  text NOT NULL,
  domain   text
);
INSERT INTO properties (id, display, domain) VALUES
  ('eats',  'CompassEats',  'compasseats.com'),
  ('local', 'Compass Local','local.compasseats.com');

-- ---------- regions / cities ----------
CREATE TABLE regions (
  id      text PRIMARY KEY CHECK (id ~ '^rg_[a-z0-9]+$'),
  slug    text NOT NULL UNIQUE,
  display text NOT NULL
);

CREATE TABLE cities (
  id           text PRIMARY KEY CHECK (id ~ '^ci_[a-z0-9]+$'),
  slug         text NOT NULL UNIQUE,
  display      text NOT NULL,
  -- F39: country derives ONCE PER CITY from open geo resolution, never from venue rows.
  country      text,
  country_iso  char(2),
  kind         city_kind NOT NULL DEFAULT 'city',   -- Response F: destination regions flagged
  region_id    text REFERENCES regions(id),
  lat          double precision,
  lng          double precision,
  -- Request 43: an empty city is a query, not a discovery (refreshed by job).
  venues_count integer NOT NULL DEFAULT 0
);
COMMENT ON COLUMN cities.kind IS
  'destination_region rows are excluded from city-centroid geo fallback (Plan §6).';

-- Aliases as constrained rows. The CHECK kills the two measured defect classes
-- structurally: apostrophe-form keys cannot exist, and the PK kills duplicates.
CREATE TABLE city_aliases (
  alias   text PRIMARY KEY CHECK (alias ~ '^[a-z0-9 ]+$' AND alias = btrim(alias)),
  city_id text NOT NULL REFERENCES cities(id)
);

-- ---------- award sources (the single origin; canonical seed = 23) ----------
CREATE TABLE award_sources (
  slug                  text PRIMARY KEY CHECK (slug ~ '^[a-z0-9][a-z0-9-]*$'),
  display               text NOT NULL,
  status                source_status_t NOT NULL DEFAULT 'active',  -- suspension switch (D10)
  capture_permission    boolean NOT NULL DEFAULT false,             -- the ONLY gate for guide backfill (D10)
  attribution_required  text,
  geo_capable           boolean NOT NULL DEFAULT false,
  price_capable         boolean NOT NULL DEFAULT false,
  -- Display rule decided Aug 11: ranks above this render the extended-list label.
  render_extended_above integer
);
COMMENT ON TABLE award_sources IS
  'Single origin: ingest arrays, Award Radar prompt, Watch List, BAR_SOURCES all derive from here.';

INSERT INTO award_sources (slug, display, render_extended_above) VALUES
  ('michelin',                          'Michelin Guide',                          NULL),
  ('worlds-50-best-restaurants',        'The World''s 50 Best Restaurants',        50),
  ('worlds-50-best-bars',               'The World''s 50 Best Bars',               50),
  ('asia-50-best-restaurants',          'Asia''s 50 Best Restaurants',             50),
  ('asia-50-best-bars',                 'Asia''s 50 Best Bars',                    50),
  ('north-america-50-best-restaurants', 'North America''s 50 Best Restaurants',    50),
  ('north-america-50-best-bars',        'North America''s 50 Best Bars',           50),
  ('latin-america-50-best-restaurants', 'Latin America''s 50 Best Restaurants',    50),
  ('mena-50-best-restaurants',          'MENA''s 50 Best Restaurants',             50),
  ('africa-50-best-restaurants',        'Africa''s 50 Best Restaurants',           50),
  ('europe-50-best-bars',               'Europe''s 50 Best Bars',                  50),
  ('james-beard',                       'James Beard Foundation Awards',           NULL),
  ('best-chef-awards',                  'The Best Chef Awards',                    NULL),
  ('spirited-awards',                   'Spirited Awards — Tales of the Cocktail', NULL),
  ('pinnacle-guide',                    'The Pinnacle Guide',                      NULL),
  ('oad',                               'OAD — Opinionated About Dining',          NULL),
  ('la-liste',                          'La Liste',                                NULL),
  ('gault-millau',                      'Gault & Millau',                          NULL),
  ('tabelog',                           'Tabelog',                                 NULL),
  ('forbes-travel-guide',               'Forbes Travel Guide',                     NULL),
  ('wine-spectator',                    'Wine Spectator',                          NULL),
  ('top-500-bars',                      'Top 500 Bars',                            NULL),
  ('101-best-steakhouses',              '101 Best Steakhouses',                    NULL);

-- ---------- venues ----------
CREATE TABLE venues (
  id            text PRIMARY KEY CHECK (id ~ '^ve_[a-z0-9]+$'),
  name          text NOT NULL CHECK (btrim(name) <> ''),
  name_native   text,
  category      venue_category NOT NULL,
  city_id       text NOT NULL REFERENCES cities(id),
  status        venue_status NOT NULL DEFAULT 'active',
  chef          text,                       -- Option B hand-authored (137 rows)
  gers_id       text,                       -- Overture external join key
  cuisine_tags  text[],
  cuisine_source   text,                    -- 'legacy_guide' for migrated values
  cuisine_publisher text REFERENCES award_sources(slug),
  last_verified date,
  norm_key      text GENERATED ALWAYS AS (norm_key(name)) STORED
);
CREATE INDEX venues_normkey_city ON venues (norm_key, city_id);
COMMENT ON COLUMN venues.norm_key IS
  'Dedupe gate key: collisions within a city stage into merge_review at promote; never a hard block (legitimate shared names exist).';

-- Rename protection: names drive nothing structurally any more, but silent
-- renames orphaned content historically. Renames need the job flag set.
CREATE OR REPLACE FUNCTION guard_venue_rename() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.name IS DISTINCT FROM OLD.name
     AND coalesce(current_setting('app.allow_rename', true), '') <> 'on' THEN
    RAISE EXCEPTION 'Venue renames run only through the rename job (set app.allow_rename).';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER trg_venue_rename BEFORE UPDATE ON venues
  FOR EACH ROW EXECUTE FUNCTION guard_venue_rename();

-- ---------- listings (multi-property membership) ----------
CREATE TABLE listings (
  venue_id    text NOT NULL REFERENCES venues(id),
  property_id text NOT NULL REFERENCES properties(id),
  trust_tier  text,          -- Compass Local: charted / institution
  published   boolean NOT NULL DEFAULT true,
  PRIMARY KEY (venue_id, property_id)
);

-- ---------- awards (the crown jewels) ----------
CREATE TABLE awards (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  venue_id    text NOT NULL REFERENCES venues(id),
  source_id   text NOT NULL REFERENCES award_sources(slug),
  year        integer CHECK (year BETWEEN 1900 AND 2100),
  rank        integer CHECK (rank IS NULL OR rank > 0),
  category    text,
  distinction text,
  source_url  text,
  -- The fold invariant (Addendum B): a double ingest can never publish twice again.
  CONSTRAINT awards_no_dupes UNIQUE NULLS NOT DISTINCT
    (venue_id, source_id, year, rank, category, distinction)
);

-- ---------- slugs / redirects (every URL the site has ever answered) ----------
CREATE TABLE slugs (
  property_id  text NOT NULL REFERENCES properties(id),
  city_slug    text NOT NULL,
  slug         text NOT NULL,
  venue_id     text NOT NULL REFERENCES venues(id),
  is_canonical boolean NOT NULL DEFAULT true,
  PRIMARY KEY (property_id, city_slug, slug)
);
CREATE TABLE redirects (
  from_path text PRIMARY KEY,
  to_path   text NOT NULL
);

-- ---------- geo (no Google value can exist: the enum is the wall) ----------
CREATE TABLE geo (
  venue_id    text PRIMARY KEY REFERENCES venues(id),
  lat         double precision CHECK (lat BETWEEN -90 AND 90),
  lng         double precision CHECK (lng BETWEEN -180 AND 180),
  precision   geo_precision NOT NULL,
  accept_gate accept_gate_t,
  in_gate_a   boolean, in_gate_b boolean, in_gate_c boolean,
  source      geo_source_t NOT NULL,
  publisher   text REFERENCES award_sources(slug),
  source_url  text,
  captured_at timestamptz NOT NULL DEFAULT now(),
  confidence  real,
  agreement   boolean,
  -- venue_low means the C-only rows, nothing wider (ratified Aug 10/11).
  CONSTRAINT venue_low_is_gate_c CHECK
    (precision <> 'venue_low' OR accept_gate = 'exact_name')
);

-- ---------- addresses ----------
CREATE TABLE addresses (
  venue_id      text PRIMARY KEY REFERENCES venues(id),
  raw           text,
  street        text, postal_code text, locality text,
  native_script text,
  source        geo_source_t NOT NULL,
  publisher     text REFERENCES award_sources(slug),
  source_url    text,
  captured_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------- price (value-shape rule: symbols in, integers never) ----------
CREATE TABLE price (
  venue_id    text PRIMARY KEY REFERENCES venues(id),
  tier        smallint NOT NULL CHECK (tier BETWEEN 1 AND 4),
  symbol_raw  text CHECK (symbol_raw IS NULL OR symbol_raw !~ '^[0-9]+$'),
  currency    text,
  source      price_source_t NOT NULL,
  method      price_method_t NOT NULL,
  publisher   text REFERENCES award_sources(slug),
  source_url  text,
  captured_at timestamptz NOT NULL DEFAULT now(),
  confidence  real
);

-- ---------- hours (days-open only; Tonight mode's honest floor) ----------
CREATE TABLE hours (
  venue_id    text PRIMARY KEY REFERENCES venues(id),
  days_open   jsonb,
  source      geo_source_t,
  source_url  text,
  confidence  real,
  captured_at timestamptz
);

-- ---------- blurbs (141 Option B records import flagged for rewrite) ----------
CREATE TABLE blurbs (
  venue_id  text PRIMARY KEY REFERENCES venues(id),
  short     text,
  long      text,
  method    text NOT NULL DEFAULT 'option_b',
  version   integer NOT NULL DEFAULT 1,
  status    text NOT NULL DEFAULT 'needs_rewrite',
  sources   jsonb
);

-- ---------- photo_refs (THE one Google quarantine: placeId only) ----------
CREATE TABLE photo_refs (
  venue_id        text PRIMARY KEY REFERENCES venues(id),
  google_place_id text,
  photo_url       text CHECK (photo_url IS NULL OR
                    photo_url !~* '(googleusercontent|googleapis|gstatic|ggpht|maps\.google)'),
  credit          text,
  credit_url      text,
  license         text
);
COMMENT ON TABLE photo_refs IS
  'The only table permitted a Google value (place_id, for the live photo Worker). Wrong placeIds were dropped by the ratified triage; a placeId shown wrong is dropped, never re-looked-up.';

-- ---------- city_label_source (publisher city strings, D/E: one mechanism, one home) ----------
CREATE TABLE city_label_source (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  venue_id    text NOT NULL REFERENCES venues(id),
  label       text NOT NULL,
  from_column label_column_t NOT NULL,
  publisher   text REFERENCES award_sources(slug),
  note        text
);

-- ---------- ingest staging (provenance is born here) ----------
CREATE TABLE ingest_batches (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_id   text REFERENCES award_sources(slug),
  list_year   integer,
  status      batch_status_t NOT NULL DEFAULT 'staged',
  created_at  timestamptz NOT NULL DEFAULT now(),
  approved_at timestamptz,
  note        text
);
CREATE TABLE ingest_rows (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  batch_id   bigint NOT NULL REFERENCES ingest_batches(id),
  raw        jsonb NOT NULL,
  validation jsonb,
  verdict    text
);

-- ---------- audit log (silent mutation is a contradiction in terms) ----------
CREATE TABLE audit_log (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  table_name text NOT NULL,
  row_pk     text,
  action     text NOT NULL,
  old_row    jsonb,
  new_row    jsonb,
  at         timestamptz NOT NULL DEFAULT now()
);
CREATE OR REPLACE FUNCTION audit_row() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  VALUES (TG_TABLE_NAME,
          coalesce(to_jsonb(NEW)->>'id', to_jsonb(NEW)->>'venue_id',
                   to_jsonb(OLD)->>'id', to_jsonb(OLD)->>'venue_id'),
          TG_OP,
          CASE WHEN TG_OP <> 'INSERT' THEN to_jsonb(OLD) END,
          CASE WHEN TG_OP <> 'DELETE' THEN to_jsonb(NEW) END);
  RETURN coalesce(NEW, OLD);
END $$;
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['venues','awards','cities','geo','addresses','price',
                           'blurbs','photo_refs','slugs','award_sources','listings']
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_audit_%s AFTER INSERT OR UPDATE OR DELETE ON %I
         FOR EACH ROW EXECUTE FUNCTION audit_row()', t, t);
  END LOOP;
END $$;

-- ---------- exposure: current view + cumulative ledger (D10, Article 7(5)) ----------
CREATE TABLE source_capture_ledger (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  publisher   text NOT NULL REFERENCES award_sources(slug),
  field_type  text NOT NULL,       -- award / address / geo / price / cuisine / label
  items       integer NOT NULL,
  captured_at timestamptz NOT NULL DEFAULT now(),
  job         text
);
CREATE VIEW source_exposure AS
  SELECT source_id AS publisher, 'award'   AS field_type, count(*) AS items FROM awards    GROUP BY 1
  UNION ALL
  SELECT publisher,              'geo',                   count(*)          FROM geo       WHERE publisher IS NOT NULL GROUP BY 1
  UNION ALL
  SELECT publisher,              'address',               count(*)          FROM addresses WHERE publisher IS NOT NULL GROUP BY 1
  UNION ALL
  SELECT publisher,              'price',                 count(*)          FROM price     WHERE publisher IS NOT NULL GROUP BY 1
  UNION ALL
  SELECT cuisine_publisher,      'cuisine',               count(*)          FROM venues    WHERE cuisine_publisher IS NOT NULL GROUP BY 1;

COMMIT;
-- Expected result: success with no rows returned. Verify with:
--   SELECT count(*) FROM award_sources;   -- expect 23
