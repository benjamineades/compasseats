-- Seed data for the ingest tests. A small, hand-built stand-in for the live
-- database: the cities the acceptance batch needs, a few venues that exercise
-- match / duplicate / subsume / same-name-elsewhere / slug-collision, and the
-- category vocabulary those sources use.
--
-- Nothing here is copied from production rows; it is the shapes that matter.

INSERT INTO cities (id, slug, display, country, country_iso) VALUES
  ('ci_dea56e47f1', 'barcelona',        'Barcelona',        'Spain',     'ES'),
  ('ci_d3197fb64e', 'singapore',        'Singapore',        'Singapore', 'SG'),
  ('ci_6742923575', 'lima',             'Lima',             'Peru',      'PE'),
  ('ci_354b500e3a', 'chengdu',          'Chengdu',          'China',     'CN'),
  ('ci_60d99e58d6', 'rome',             'Rome',             'Italy',     'IT'),
  ('ci_002aaa1d1e', 'mexico-city',      'Mexico City',      'Mexico',    'MX'),
  ('ci_ccbee73cd8', 'paris',            'Paris',            'France',    'FR'),
  ('ci_1111111111', 'jimenez-de-jamuz', 'Jiménez de Jamuz', 'Spain',     'ES'),
  ('ci_2222222222', 'london',           'London',           'United Kingdom', 'GB'),
  ('ci_3333333333', 'new-york',         'New York',         'United States',  'US'),
  -- the same name in two countries: the slug-split class
  ('ci_4444444444', 'san-jose-ca',      'San Jose',         'United States',  'US'),
  ('ci_5555555555', 'san-jose-cr',      'San Jose',         'Costa Rica',     'CR');

INSERT INTO city_aliases (alias, city_id) VALUES
  ('cdmx', 'ci_002aaa1d1e'),
  ('roma', 'ci_60d99e58d6');

-- venues -------------------------------------------------------------------
-- Tallow        : the exact-key match target in London
-- Brine x2      : the same name twice in London - ambiguous in city
-- Brine (NY)    : and again elsewhere, which on its own never blocks a match
-- Aurum (NY)    : a name that exists ONLY in another city
-- The Anchor    : owns a slug, for the incumbent rule
-- Pinnacle Room : holds a 3-Pin, for the subsume rule
INSERT INTO venues (id, name, category, city_id, status) VALUES
  ('ve_aaaaaaaaa1', 'Tallow',        'restaurant', 'ci_2222222222', 'active'),
  ('ve_bbbbbbbbb2', 'Brine',         'bar',        'ci_2222222222', 'active'),
  ('ve_fffffffff6', 'Brine',         'bar',        'ci_2222222222', 'active'),
  ('ve_ccccccccc3', 'Brine',         'bar',        'ci_3333333333', 'active'),
  ('ve_ggggggggg7', 'Aurum',         'bar',        'ci_3333333333', 'active'),
  ('ve_ddddddddd4', 'The Anchor',    'bar',        'ci_2222222222', 'active'),
  ('ve_eeeeeeeee5', 'Pinnacle Room', 'restaurant', 'ci_2222222222', 'active');

INSERT INTO listings (venue_id, property_id, published) VALUES
  ('ve_aaaaaaaaa1', 'eats', true),
  ('ve_bbbbbbbbb2', 'eats', true),
  ('ve_fffffffff6', 'eats', true),
  ('ve_ccccccccc3', 'eats', true),
  ('ve_ggggggggg7', 'eats', true),
  ('ve_ddddddddd4', 'eats', true),
  ('ve_eeeeeeeee5', 'eats', true);

INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES
  ('eats', 'london',   'tallow',        've_aaaaaaaaa1', true),
  ('eats', 'london',   'brine',         've_bbbbbbbbb2', true),
  ('eats', 'london',   'brine-2',       've_fffffffff6', true),
  ('eats', 'new-york', 'brine',         've_ccccccccc3', true),
  ('eats', 'new-york', 'aurum',         've_ggggggggg7', true),
  ('eats', 'london',   'the-anchor',    've_ddddddddd4', true),
  ('eats', 'london',   'pinnacle-room', 've_eeeeeeeee5', true);

-- awards --------------------------------------------------------------------
-- one to duplicate against, and a Pinnacle "3-Pin" that must subsume a bare
-- "Listed" row arriving for the same source-year
INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
  ('ve_aaaaaaaaa1', 'worlds-50-best-restaurants', 2024, 12, 'No. 12', NULL,
   'https://www.the50.com/restaurants/best-in-the-world/previous-list/2024'),
  ('ve_eeeeeeeee5', 'pinnacle-guide', 2026, NULL, '3-Pin', NULL,
   'https://www.pinnacleguide.com/'),
  -- rank 1 of the 2026 steakhouse list already sits on a venue in London.
  -- The acceptance batch claims the same rank for a different venue, which is
  -- exactly the La Cupula / Bodega El Capricho shape the report must flag.
  ('ve_aaaaaaaaa1', '101-best-steakhouses', 2026, 1, 'No. 1', NULL,
   'https://www.worldbeststeaks.com/the-list');

-- the controlled vocabulary these tests use --------------------------------
INSERT INTO award_categories (source_id, category) VALUES
  ('101-best-steakhouses', 'No. 1'),
  ('101-best-steakhouses', 'No. 101'),
  ('asia-50-best-restaurants', 'No. 49'),
  ('latin-america-50-best-restaurants', 'No. 48'),
  ('top-500-bars', 'No. 124'),
  ('top-500-bars', 'No. 417'),
  ('top-500-bars', 'No. 458'),
  ('worlds-50-best-restaurants', 'No. 6'),
  ('worlds-50-best-restaurants', 'No. 12'),
  ('worlds-50-best-restaurants', 'No. 16'),
  ('worlds-50-best-restaurants', 'No. 30'),
  ('pinnacle-guide', '1-Pin'),
  ('pinnacle-guide', '2-Pin'),
  ('pinnacle-guide', '3-Pin'),
  ('pinnacle-guide', 'Listed'),
  ('michelin', 'One Star'),
  ('worlds-50-best-bars', 'No. 7');

-- a suspended source, for the source_suspended reject path
INSERT INTO award_sources (slug, display, status) VALUES
  ('suspended-guide', 'A Suspended Guide', 'suspended');
