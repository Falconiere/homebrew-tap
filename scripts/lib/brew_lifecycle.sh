#!/usr/bin/env bash
# Helpers for scripts/test-brew-lifecycle.sh. Everything here inspects the real
# system: brew's prefix, the engine's own `sync daemon` JSON, launchd/systemd
# unit files, the process table and the SQLite corpus. Nothing is simulated.
# Sourced after the caller sets MODE, EXPECT_SUPERVISOR, EXPECT_UNITS, UNIT_DIR,
# UNIT_GLOB and WORK.

DATA_DIR="$HOME/.comemory"
BREW_PREFIX="$(brew --prefix)"
CAVEAT_LINE="$BREW_PREFIX/opt/comemory/bin/comemory sync daemon ensure"

log() { printf '==> %s\n' "$*"; }
pass() { printf 'PASS %s\n' "$1"; }
# fail SCENARIO REASON: the whole run stops at the first broken assertion.
fail() { printf 'FAIL %s: %s\n' "$1" "$2"; exit 1; }

real_path() { python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"; }

# The engine's `binary_file` identity: "<st_dev>:<st_ino>" of the executable.
file_id() { python3 -c 'import os, sys; s = os.stat(sys.argv[1]); print(f"{s.st_dev}:{s.st_ino}")' "$1"; }

unit_files() {
  local f
  for f in "$UNIT_DIR"/$UNIT_GLOB; do
    [ -e "$f" ] && printf '%s\n' "$f"
  done
  return 0
}
unit_count() { unit_files | awk 'END { print NR }'; }

# One "<pid> <args>" line per live coordinator (`comemory ... sync daemon run`).
coordinators() { ps -Ao pid=,args= | awk '/ sync daemon run/ && !/awk/ { print }'; }
coordinator_count() { coordinators | awk 'END { print NR }'; }

pid_alive() { kill -0 "$1" 2>/dev/null; }

# wait_until SECONDS COMMAND...: poll every 0.5 s until COMMAND succeeds.
wait_until() {
  local deadline=$(( $(date +%s) + $1 ))
  shift
  until "$@"; do
    [ "$(date +%s)" -ge "$deadline" ] && return 1
    sleep 0.5
  done
}
coordinators_are() { [ "$(coordinator_count)" -eq "$1" ]; }
pid_gone() { ! pid_alive "$1"; }

# caveats_printed SCENARIO LOG: brew printed the lifecycle caveats naming the opt path.
caveats_printed() {
  grep -qF -- "$CAVEAT_LINE" "$2" || fail "$1" "brew output lacks the caveats line '$CAVEAT_LINE'"
}

# brew_logged SCENARIO LOG ARGS...: run brew, tee its output, fail on non-zero exit.
brew_logged() {
  local scenario="$1" out="$2" rc=0
  shift 2
  brew "$@" >"$out" 2>&1 || rc=$?
  cat "$out"
  [ "$rc" -eq 0 ] || fail "$scenario" "brew $* exited $rc"
}

daemon_status() { "$1" sync daemon status --json; }

# ensure_ready SCENARIO EXE OUT: the supported step; ready JSON or failure with its output.
ensure_ready() {
  local scenario="$1" exe="$2" out="$3" rc=0
  "$exe" sync daemon ensure --json >"$out" 2>"$out.err" || rc=$?
  cat "$out"
  [ "$rc" -eq 0 ] || fail "$scenario" "sync daemon ensure exited $rc: $(cat "$out" "$out.err")"
}

# assert_ready SCENARIO JSON VERSION BINARY: the engine's readiness proves version, path, data dir, supervisor.
assert_ready() {
  local scenario="$1" json="$2" version="$3" binary="$4" data
  data="$(real_path "$DATA_DIR")"
  jq -e --arg v "$version" --arg b "$binary" --arg d "$data" --arg s "$EXPECT_SUPERVISOR" '
      .ready == true and .daemon.version == $v and .daemon.binary == $b
      and .daemon.data_dir == $d and .supervisor == $s' "$json" >/dev/null \
    || fail "$scenario" "readiness mismatch (want version=$version binary=$binary data_dir=$data supervisor=$EXPECT_SUPERVISOR): $(cat "$json")"
}

formula_version() { brew info --json=v2 falconiere/tap/comemory | jq -r '.formulae[0].versions.stable'; }
binary_version() { "$1" --version | awk '{ print $2 }'; }

# snapshot OUT: memories + replica_operation rows and memory files, byte-comparable.
snapshot() {
  python3 - "$DATA_DIR" >"$1" <<'PY'
import hashlib, os, sqlite3, sys
root = sys.argv[1]
db = sqlite3.connect(os.path.join(root, "comemory.db"))
for table in ("memories", "replica_operation"):
    cols = [r[1] for r in db.execute(f"PRAGMA table_info({table})")]
    for row in db.execute(f"SELECT * FROM {table} ORDER BY 1"):
        print(table, dict(zip(cols, row)))
mem = os.path.join(root, "memories")
for name in sorted(os.listdir(mem)):
    path = os.path.join(mem, name)
    if os.path.isfile(path):
        print("file", name, hashlib.sha256(open(path, "rb").read()).hexdigest())
PY
}

pending_ops() {
  python3 - "$DATA_DIR" <<'PY'
import os, sqlite3, sys
db = sqlite3.connect(os.path.join(sys.argv[1], "comemory.db"))
print(db.execute("SELECT count(*) FROM replica_operation WHERE state = 'pending'").fetchone()[0])
PY
}

# same_snapshot SCENARIO BEFORE: current data equals BEFORE.
same_snapshot() {
  snapshot "$WORK/now.snap"
  cmp -s "$2" "$WORK/now.snap" || fail "$1" "data changed: $(diff "$2" "$WORK/now.snap" | head -20)"
}

# remove_units_by_hand: what a user must do after a brew-only uninstall.
remove_units_by_hand() {
  local unit
  while IFS= read -r unit; do
    [ -n "$unit" ] || continue
    if [ "$(uname -s)" = Darwin ]; then
      launchctl bootout "gui/$(id -u)" "$unit" 2>/dev/null || true
    else
      systemctl --user disable --now "$(basename "$unit")" 2>/dev/null || true
    fi
    rm -f "$unit"
  done < <(unit_files)
  [ "$(uname -s)" = Darwin ] || systemctl --user daemon-reload 2>/dev/null || true
}

# stop_coordinators PATTERN: end leftovers whose command line contains PATTERN.
stop_coordinators() {
  local pid
  for pid in $(coordinators | awk -v p="$1" 'index($0, p) { print $1 }'); do
    kill "$pid" 2>/dev/null || true
  done
}
