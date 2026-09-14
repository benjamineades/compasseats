# Ingest stage - no-op

Batch key **michelin-2026-france** already exists.

| field | value |
|---|---|
| batch id | 3 |
| status | staged |
| source | michelin |
| list year | 2026 |
| staged rows | 1071 |
| created | 2026-09-14 14:37:59.296062+00 |

Nothing was staged and nothing was changed. This is what idempotency looks like: if a run timed out, the work is already here.

To apply review decisions to this batch, re-run stage with the same CSV plus `--decisions <filled review csv>`.
