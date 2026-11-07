# Rehearsal log, Nov 7, 2026 (UTC)

Each run: a fresh shallow clone of main (= branch phase2/publish-job at 0d39444) from a local stand-in for GitHub, then the workflow's own steps (tools/wf.sh). Database: the local copy (fingerprints.csv).

| Run | Button | Input | Exit | Result |
|---|---|---|---|---|
| 101 | build | - | 0 | versions/20261107T021949Z, content 3aca439f…9783, pushed |
| 102 | build | - | 0 | versions/20261107T022009Z, content 3aca439f…9783 (same), diff 0/0/0, pushed |
| 103 | promote | 20261107T021949Z, PUBLISH 20261107T022009Z | 1 | refused: confirmation must read PUBLISH 20261107T021949Z |
| 104 | promote | 20261107T021949Z, PUBLISH 20261107T021949Z | 0 | preview = 20261107T021949Z, hash check 3,287 files |
| 105 | promote | 20261107T022009Z, PUBLISH 20261107T022009Z | 0 | preview = 20261107T022009Z |
| 106 | rollback | ROLLBACK 20261107T021949Z | 1 | refused: must read ROLLBACK 20261107T022009Z |
| 107 | rollback | ROLLBACK 20261107T022009Z, dry run | 0 | no change |
| 108 | rollback | ROLLBACK 20261107T022009Z | 0 | preview = 20261107T021949Z |
| 109 | promote | 20261107T022009Z, PUBLISH 20261107T022009Z | 0 | preview = 20261107T022009Z |
| - | hand edit | venues/paris.json of 20261107T021949Z changed and pushed | - | simulates a changed version folder |
| 110 | rollback | ROLLBACK 20261107T022009Z | 1 | refused: venues/paris.json 199003 bytes, manifest says 199002; sha256 differs |
| - | hand edit undone | git revert, pushed | - |  |
| 112 | rollback | ROLLBACK 20261107T022009Z | 0 | preview = 20261107T021949Z |

Run 111 repeated run 110 before the revert was pushed (the revert command had a wrong flag); it gave the same refusal. Run 112 is the clean rollback.

## Branch log of publish-preview at the end
```
dccc3b8 publish: rollback
3970072 Revert "hand edit to version A"
f8939ab hand edit to version A
496e1d7 publish: promote
f30b68f publish: rollback
f61b6d1 publish: promote
6ad1bbf publish: promote
c422be8 publish: build 20261107T022009Z (from main 0d39444)
ffcd614 publish: build 20261107T021949Z (from main 0d39444)
```

## Run 104 output (promote)
```
## Publish — promote

| Item | Value |
|---|---|
| Preview now | none (first promote) |
| Preview after | `20261107T021949Z` |
| Hash check | 3287 files match manifest.json; content `3aca439f5764bf656e5c56d6dfe90b6495fc0e771a75e7c69cab2ac202689783` |
| Venues in the version | 11,510 |
| Built at / database read at | 2026-11-07T02:19:49Z / 2026-11-07T02:19:49Z |
| Rollback after this would go to | nothing (no earlier version) |

Done. `channels/preview.json` now points at `20261107T021949Z`.
```
## Run 110 stderr (rollback refused)
```
The version to go back to, 20261107T021949Z, did not pass its hash check. Nothing was changed.
  - venues/paris.json: 199003 bytes, manifest says 199002
  - venues/paris.json: sha256 b26721a9298b..., manifest says c0f6576daf09...
```
## Run 112 output (rollback)
```
## Publish — rollback

| Item | Value |
|---|---|
| Preview now | `20261107T022009Z` |
| Preview after | `20261107T021949Z` |
| Hash check of `20261107T021949Z` | 3287 files match manifest.json; content `3aca439f5764bf656e5c56d6dfe90b6495fc0e771a75e7c69cab2ac202689783` |
| Venues in `20261107T021949Z` | 11,510 |
| A second rollback after this would go to | nothing (no earlier version) |

Done. `channels/preview.json` now points at `20261107T021949Z`. Version `20261107T022009Z` stays in the tree; to put it back, run **Publish — promote** with `PUBLISH 20261107T022009Z`.
```
