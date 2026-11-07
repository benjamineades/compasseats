#!/usr/bin/env bash
# Run one publish workflow the way GitHub Actions would: a fresh shallow clone of
# main from the stand-in origin, then the workflow's own steps in order.
#   wf.sh <run id> build [allow_decrease]
#   wf.sh <run id> promote <version> <confirmation> [dry]
#   wf.sh <run id> rollback <confirmation> [dry]
set -uo pipefail
R=/tmp/claude-0/-home-claude/2685fd0c-4f2d-5b47-b9b9-8fef096cef96/scratchpad/rehearsal
export PATH=/root/.bun/bin:$PATH
export SUPABASE_DB_URL=postgres://postgres@127.0.0.1:5433/compass_live_copy
run="$1"; kind="$2"; shift 2
W=$R/runs/$run; rm -rf "$W"; mkdir -p "$W"
export RUNNER_TEMP=$W/tmp GITHUB_RUN_ID=$run; mkdir -p "$RUNNER_TEMP"
git clone -q --depth 1 --branch main "file://$R/origin.git" "$W/repo" || exit 9
cd "$W/repo"
export GITHUB_SHA=$(git rev-parse HEAD)
mode=$([ "$kind" = build ] && echo create || echo require)
bash scripts/publish/checkout-preview.sh "$RUNNER_TEMP/preview" $mode > "$W/checkout.log" 2>&1 || { cat "$W/checkout.log"; exit 1; }
case "$kind" in
  build)
    ARGS=(--tree "$RUNNER_TEMP/preview" --live-file data/venues.json --out "$RUNNER_TEMP/publish-out" --git-sha "$(git rev-parse HEAD)")
    [ -n "${1:-}" ] && ARGS+=(--allow-decrease "$1")
    bun run scripts/publish/build.ts "${ARGS[@]}" > "$W/step.out" 2> "$W/step.err"; code=$?
    ;;
  promote)
    ARGS=(--tree "$RUNNER_TEMP/preview" --version "$1" --confirm "$2" --run "$run")
    [ "${3:-}" = dry ] && ARGS+=(--dry-run)
    bun run scripts/publish/promote.ts "${ARGS[@]}" > "$W/step.out" 2> "$W/step.err"; code=$?
    ;;
  rollback)
    ARGS=(--tree "$RUNNER_TEMP/preview" --confirm "$1" --run "$run")
    [ "${2:-}" = dry ] && ARGS+=(--dry-run)
    bun run scripts/publish/rollback.ts "${ARGS[@]}" > "$W/step.out" 2> "$W/step.err"; code=$?
    ;;
esac
echo "[$run $kind] exit $code"
if [ $code -ne 0 ]; then sed 's/^/  stderr: /' "$W/step.err" | head -8; exit $code; fi
cd "$RUNNER_TEMP/preview"
if [ -z "$(git status --porcelain)" ]; then echo "[$run] no change to push"; exit 0; fi
git config user.name compasseats-publish; git config user.email publish@users.noreply.github.com
git add -A
if [ "$kind" = build ]; then msg="publish: build $(cat $RUNNER_TEMP/publish-out/version.txt) (from main ${GITHUB_SHA::7})"; else msg="publish: $kind"; fi
git commit -q -m "$msg" && git push -q origin HEAD:refs/heads/publish-preview && echo "[$run] pushed: $msg"
