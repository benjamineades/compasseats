# Michelin Chengdu 2026 — archive evidence (archive method test 1)

Read Sep 29, 2026. Source rule: Sep 28 ruling on archived Michelin pages (conditions 1 to 8).

## Ceremony URLs (condition 3)
- 2026 edition: https://guide.michelin.com/mo/en/article/news-and-views/michelin-guide-chengdu-2026 — page date 02 September 2025; JSON-LD datePublished 2025-09-02T12:00. Article: 13 starred (Two Stars 2, One Star 11), 27 Bib Gourmand, 36 Selected.
- 2027 edition: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-stars-chengdu-2027 — page date 02 September 2026; JSON-LD datePublished 2026-09-03T12:00 (the earlier date is used).
- Window used (UTC archive timestamps): 20250903000000 <= timestamp < 20260902000000. The two ceremony days are excluded.

## Relay
- File: `reports/chengdu-2026-archive-relay.jsonl`, 40 lines, no final newline, sorted, non-ASCII as \uXXXX.
- SHA-256 (browser = disk): `216ffff2ad2578356ec3bdf4518c6d38ef488fb51822e28ec333f73e095f5ffc`
- Method: Wayback CDX, prefix `guide.michelin.com/<us/en|en>/chengdu-municipality/chengdu/restaurant/`, status 200, 2025-09-01 to 2026-09-10: 203 captures, 71 pages. For each page, in-window captures read in date order; the first capture whose meta description names "2026 MICHELIN Guide Chengdu" is kept. Raw page `/web/<14-digit ts>id_/<url>`; the final URL equals the requested URL (0 redirects).
- 69 of 71 pages have a 2026-edition capture. Hidden Place and Li Xuan: no edition text, no award (not distinctions).

## Conditions (population: the 40 distinctions)
| # | Condition | Result |
|---|---|---|
| 1 | Host web.archive.org | 40 of 40 |
| 2 | Captured URL on guide.michelin.com | 40 of 40 |
| 3 | Timestamp in the window | 40 of 40 (first 20250903040600, last 20260115030537) |
| 4 | Page names the edition | 40 of 40 meta "2026 MICHELIN Guide Chengdu"; 40 of 40 JSON-LD dateAwarded 2026 |
| 5 | Count per distinction = article | Two Stars 2 = 2, One Star 11 = 11, Bib 27 = 27. The other 29 edition pages carry no star or Bib |
| 6 | Relay and hash in reports/ | this file and the relay file |
| 7 | Exact archive URL stored | 15 of 15 batch rows: venue page, 14-digit timestamp, id_ flag; all distinct |
| 8 | Same job, gates, scope | stars and Bib only; batch key michelin-2026-chengdu; batch note contains "archive" |

## Batch files
- `fixtures/ingest/michelin-2026-chengdu.csv`: 15 rows, 16 columns (China shape), LF. SHA-256 `6b40b0c5851c8eed40b82d441ebd45d08ca0b67b5e976b868721e495326b517a`
- `fixtures/ingest/michelin-2026-chengdu-decisions.csv`: 2 rows (line 14 new, line 15 use:ve_81ee6aa1e8), quoted, CRLF. SHA-256 `26b21b4c62ce1a272174048cfc983e15120bbfd11ad47b6f688e9564a30d7130`
