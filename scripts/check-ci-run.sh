#!/usr/bin/env bash
# Delivery evidence: wait for the newest `push` run of a workflow at a commit,
# then require exactly N jobs, each concluding `success`.
#
#   bash scripts/check-ci-run.sh <workflow-file> <sha> <expected-jobs>
#
# Polls every 30 s, for at most CI_RUN_TIMEOUT_SECS (default 5400). Exit codes:
#   0  all expected jobs succeeded
#   1  the run failed, the job count differs, a job did not succeed, the run
#      never completed in time, or no run appeared within 5 min
#   2  bad arguments, or a `gh` error on 3 consecutive polls
set -euo pipefail

[ $# -eq 3 ] && [[ "$3" =~ ^[0-9]+$ ]] || { echo "usage: $0 <workflow-file> <sha> <expected-jobs>" >&2; exit 2; }
workflow="$1" sha="$2" want="$3"
timeout="${CI_RUN_TIMEOUT_SECS:-5400}"
start="$(date +%s)"
errors=0

# gh_try ARGS...: run gh into GH_OUT; three consecutive failures end the check with 2.
GH_OUT=""
gh_try() {
  if GH_OUT="$(gh "$@" 2>&1)"; then
    errors=0
    return 0
  fi
  errors=$((errors + 1))
  echo "gh $*: $GH_OUT" >&2
  [ "$errors" -lt 3 ] || { echo "gh failed 3 times in a row" >&2; exit 2; }
  return 1
}

run_id=""
while :; do
  elapsed=$(( $(date +%s) - start ))
  if [ -z "$run_id" ]; then
    if gh_try run list --workflow "$workflow" --commit "$sha" --event push --limit 1 --json databaseId; then
      run_id="$(jq -r '.[0].databaseId // empty' <<<"$GH_OUT")"
    fi
    if [ -z "$run_id" ] && [ "$elapsed" -ge 300 ]; then
      echo "no push run of $workflow for $sha" >&2
      exit 1
    fi
  fi
  if [ -n "$run_id" ] && gh_try run view "$run_id" --json status,conclusion,url,jobs; then
    view="$GH_OUT"
    if [ "$(jq -r .status <<<"$view")" = completed ]; then
      jq -r '"run \(.url): \(.conclusion)", (.jobs[] | "  \(.name): \(.conclusion)")' <<<"$view"
      have="$(jq '.jobs | length' <<<"$view")"
      ok="$(jq '[.jobs[] | select(.conclusion == "success")] | length' <<<"$view")"
      if [ "$have" -eq "$want" ] && [ "$ok" -eq "$want" ]; then
        exit 0
      fi
      echo "want $want successful jobs, have $ok of $have" >&2
      exit 1
    fi
  fi
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "run ${run_id:-<none>} did not complete within ${timeout}s" >&2
    exit 1
  fi
  sleep 30
done
