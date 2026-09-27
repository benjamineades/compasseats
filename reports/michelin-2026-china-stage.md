# Ingest stage - michelin-2026-china (INCOMPLETE)

This run **did not finish**: fixtures/ingest/michelin-2026-china-decisions.csv has no column for: source_id, year, source_url. Headers found: line, venue_name, city_label, decision, reason.

Stage writes to `ingest_batches` and `ingest_rows` inside one transaction, and that transaction had not committed. No live table was touched, and no batch row was written. Re-running the same batch key is safe.

## Phases that completed

None. The run died before its first phase - most likely reading the CSV or
opening the database connection.
