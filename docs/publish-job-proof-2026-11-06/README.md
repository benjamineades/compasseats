# Publish job proof, Nov 6, 2026 (Atlanta) / Nov 7 (UTC)

Proof for the Phase 2 publish job pull request (branch `phase2/publish-job`).
No database write. No change to the live site. The real `publish-preview`
branch on GitHub was not created; the rehearsal used a local stand-in.

| File | What it is |
|---|---|
| `fingerprints.csv` | md5 of every row of 12 tables: live (Read connector, Nov 7 02:17:20 UTC) and the local copy, before and after the 2 builds. All equal. |
| `build-report-20261107T021949Z.md` | Report of build run 1 (101). |
| `build-report-20261107T022009Z.md` | Report of build run 2 (102): same content hash, 0 changes. |
| `manifest-*.json` | The 2 manifests: sha256 and size of all 3,287 files of each version. |
| `gates.csv`, `exposure.csv`, `checks.csv`, `city-counts.csv`, `blurbs.csv`, `compare-live.csv` | CSVs of build run 1. |
| `channel-after-rehearsal.json` | `channels/preview.json` after the promote and rollback runs. |
| `rehearsal-log.md` | Runs 101 to 112: build, promote, refusals, hash-check refusal, rollback. |
| `verify.txt` | An independent check (`tools/verify.py`, no publish-job code): file hashes, and file counts against SQL counts. |
| `tools/` | The export decoder, the load file maker, the fingerprint query, the workflow runner, the verifier. |
