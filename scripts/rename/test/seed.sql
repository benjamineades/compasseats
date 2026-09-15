-- Extra seed for the rename tests, on top of scripts/ingest/test/seed.sql.
--
-- The ingest seed already gives us Paris and London and a handful of venues.
-- These are the shapes the rename job needs and that one does not have:
--
--   ve_rn11111111 Le Gabriel      : the happy path - a Michelin card name with
--                                   a hotel after a spaced dash, and a blurb
--                                   and awards hanging off it
--   ve_rn22222222 Table du Marche : the name_moved case, once a test edits it
--   ve_rn33333333 Comptoir        : holds an award from a second publisher
--   ve_rn44444444 Hollow          : the collision target, in the same city - a
--                                   rename onto its norm_key comes back as review
--   ve_rn55555555 Sel et Poivre   : renamed by the venue's own website, so its
--                                   source is `venue` and it writes no ledger row

INSERT INTO venues (id, name, category, city_id, status) VALUES
  ('ve_rn11111111', 'Restaurant Le Gabriel', 'restaurant', 'ci_ccbee73cd8', 'active'),
  ('ve_rn22222222', 'Table du Marche',       'restaurant', 'ci_ccbee73cd8', 'active'),
  ('ve_rn33333333', 'Comptoir',              'restaurant', 'ci_ccbee73cd8', 'active'),
  ('ve_rn44444444', 'Hollow',                'bar',        'ci_ccbee73cd8', 'active'),
  ('ve_rn55555555', 'Sel et Poivre',         'restaurant', 'ci_ccbee73cd8', 'active');

INSERT INTO listings (venue_id, property_id, published) VALUES
  ('ve_rn11111111', 'eats', true),
  ('ve_rn22222222', 'eats', true),
  ('ve_rn33333333', 'eats', true),
  ('ve_rn44444444', 'eats', true),
  ('ve_rn55555555', 'eats', true);

INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES
  ('eats', 'paris',  'restaurant-le-gabriel', 've_rn11111111', true),
  ('eats', 'paris',  'table-du-marche',       've_rn22222222', true),
  ('eats', 'paris',  'comptoir',              've_rn33333333', true),
  ('eats', 'paris',  'hollow',                've_rn44444444', true),
  ('eats', 'paris',  'sel-et-poivre',         've_rn55555555', true);

INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
  ('ve_rn11111111', 'michelin', 2026, NULL, 'One Star', NULL,
   'https://guide.michelin.com/en/ile-de-france/paris/restaurant/le-gabriel'),
  ('ve_rn33333333', 'michelin', 2026, NULL, 'One Star', NULL,
   'https://guide.michelin.com/en/ile-de-france/paris/restaurant/comptoir'),
  ('ve_rn33333333', 'la-liste', 2026, NULL, NULL, NULL,
   'https://www.laliste.com/en/the-list/2026');

INSERT INTO blurbs (venue_id, short, long) VALUES
  ('ve_rn11111111', 'A dining room above the courtyard.', NULL);
