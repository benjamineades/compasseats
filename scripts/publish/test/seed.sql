-- Seed data for the publish tests. A small, hand-built stand-in for the live
-- database. Nothing here is copied from production rows; the shapes matter.
--
-- Published (6): ve_pub0000001..04, 06, 07. Closed and unpublished (1): ve_pub0000005.
--   01 Le Gabriel     Paris   3 awards, price, blurb `rewritten`        -> blurb published
--   02 Bar Nouveau    Paris   1 award, blurb `needs_rewrite`            -> blurb withheld (Q4)
--   03 Kikunoi        Kyoto   native name, 1 award + 1 from a suspended source (left out)
--   04 Fujiya         Osaka   an old slug                               -> redirect
--   05 Closed Spot    London  closed, unpublished, old slug, blurb      -> all left out
--   06 Tallow Bar     London  1 award
--   07 No Award Room  London  no award row                              -> reported, not a gate
-- London's stored venues_count is 3, the job counts 2: reported (Q5).

INSERT INTO regions (id, slug, display) VALUES
  ('rg_kansai', 'kansai', 'Kansai');

INSERT INTO cities (id, slug, display, country, country_iso, region_id, venues_count) VALUES
  ('ci_paris01', 'paris',      'Paris',      'France',         'FR', NULL,        2),
  ('ci_kyoto01', 'kyoto',      'Kyoto',      'Japan',          'JP', 'rg_kansai', 1),
  ('ci_osaka01', 'osaka',      'Osaka',      'Japan',          'JP', 'rg_kansai', 1),
  ('ci_londn01', 'london',     'London',     'United Kingdom', 'GB', NULL,        3),
  ('ci_ghost01', 'ghost-town', 'Ghost Town', 'Nowhere',        NULL, NULL,        0);

UPDATE award_sources SET status = 'suspended' WHERE slug = 'wine-spectator';

INSERT INTO venues (id, name, name_native, category, city_id, status) VALUES
  ('ve_pub0000001', 'Le Gabriel',    NULL,     'restaurant', 'ci_paris01', 'active'),
  ('ve_pub0000002', 'Bar Nouveau',   NULL,     'bar',        'ci_paris01', 'active'),
  ('ve_pub0000003', 'Kikunoi',       '菊乃井', 'restaurant', 'ci_kyoto01', 'active'),
  ('ve_pub0000004', 'Fujiya',        NULL,     'restaurant', 'ci_osaka01', 'active'),
  ('ve_pub0000005', 'Closed Spot',   NULL,     'restaurant', 'ci_londn01', 'closed'),
  ('ve_pub0000006', 'Tallow Bar',    NULL,     'bar',        'ci_londn01', 'active'),
  ('ve_pub0000007', 'No Award Room', NULL,     'restaurant', 'ci_londn01', 'active');

INSERT INTO listings (venue_id, property_id, published) VALUES
  ('ve_pub0000001', 'eats', true),
  ('ve_pub0000002', 'eats', true),
  ('ve_pub0000003', 'eats', true),
  ('ve_pub0000004', 'eats', true),
  ('ve_pub0000005', 'eats', false),
  ('ve_pub0000006', 'eats', true),
  ('ve_pub0000007', 'eats', true);

INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES
  ('eats', 'paris',  'le-gabriel',    've_pub0000001', true),
  ('eats', 'paris',  'bar-nouveau',   've_pub0000002', true),
  ('eats', 'kyoto',  'kikunoi',       've_pub0000003', true),
  ('eats', 'osaka',  'fujiya',        've_pub0000004', true),
  ('eats', 'osaka',  'fujiya-1935',   've_pub0000004', false),
  ('eats', 'london', 'closed-spot',   've_pub0000005', true),
  ('eats', 'london', 'closed-spot-2', 've_pub0000005', false),
  ('eats', 'london', 'tallow-bar',    've_pub0000006', true),
  ('eats', 'london', 'no-award-room', 've_pub0000007', true);

INSERT INTO redirects (from_path, to_path) VALUES
  ('/paris/gabriel', '/paris/le-gabriel');

INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
  ('ve_pub0000001', 'michelin',            2026, NULL, 'Three Stars', NULL, 'https://guide.michelin.com/en/paris/le-gabriel'),
  ('ve_pub0000001', 'michelin',            2025, NULL, 'Two Stars',   NULL, NULL),
  ('ve_pub0000001', 'oad',                 2026, 5,    'No. 5',       NULL, 'https://www.oadguides.com/lists/europe/2026'),
  ('ve_pub0000002', 'worlds-50-best-bars', 2025, 30,   'No. 30',      NULL, 'https://www.worlds50bestbars.com/list/1-50'),
  ('ve_pub0000003', 'michelin',            2026, NULL, 'Three Stars', NULL, 'https://guide.michelin.com/en/kyoto/kikunoi'),
  ('ve_pub0000003', 'wine-spectator',      2025, NULL, 'Best of Award of Excellence', NULL, 'https://www.winespectator.com/x'),
  ('ve_pub0000004', 'michelin',            2026, NULL, 'Two Stars',   NULL, 'https://guide.michelin.com/en/osaka/fujiya'),
  ('ve_pub0000005', 'michelin',            2024, NULL, 'One Star',    NULL, NULL),
  ('ve_pub0000006', 'top-500-bars',        2026, 12,   'No. 12',      NULL, 'https://top500bars.com/2026');

INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher) VALUES
  ('ve_pub0000001', 4, '€€€€', 'EUR', 'guide_ingest', 'published_symbol', 'michelin'),
  ('ve_pub0000003', 4, '¥¥¥¥', 'JPY', 'legacy_guide', 'published_symbol', NULL),
  ('ve_pub0000005', 2, '££',   'GBP', 'legacy_guide', 'published_symbol', NULL);

INSERT INTO blurbs (venue_id, short, long, status) VALUES
  ('ve_pub0000001', 'A short line.', 'A longer paragraph.', 'rewritten'),
  ('ve_pub0000002', 'Old short.',    'Old long.',           'needs_rewrite'),
  ('ve_pub0000005', 'Gone short.',   'Gone long.',          'rewritten');

INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
  ('michelin', 'award', 4, 'seed');
