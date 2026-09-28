#!/usr/bin/env bash
# Real-brew lifecycle test for comemory's required sync daemon (homebrew-tap#1).
#
# It taps this checkout and drives real `brew install`, `reinstall`, `upgrade`
# and `uninstall` of Formula/comemory.rb (real release artifacts). Readiness is
# read only from the engine's own `sync daemon ensure/status --json`, and
# preservation from the real SQLite corpus. It runs only on a disposable
# machine: it installs and removes comemory, and it starts and removes user
# services.
#
#   bash scripts/test-brew-lifecycle.sh --native     # launchd (macOS) or systemd --user (Linux)
#   bash scripts/test-brew-lifecycle.sh --headless   # Linux without a user bus: `process` supervisor
#   bash scripts/test-brew-lifecycle.sh --self-test  # syntax + refusal check only; proves no AC
#
# Refuses (exit 2) unless CI=true or COMEMORY_DISPOSABLE_ENV=1.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAP="falconiere/tap"

usage() { echo "usage: $0 --native|--headless|--self-test" >&2; exit 2; }
[ $# -eq 1 ] || usage
MODE="${1#--}"

if [ "$MODE" = self-test ]; then
  bash -n "$0" && bash -n "$ROOT/scripts/lib/brew_lifecycle.sh"
  rc=0
  out="$(env -u CI -u COMEMORY_DISPOSABLE_ENV bash "$0" --native 2>&1)" || rc=$?
  if [ "$rc" -eq 2 ] && [[ "$out" == *"disposable"* ]]; then
    echo "PASS self-test: refuses to run outside a disposable environment"
    exit 0
  fi
  echo "FAIL self-test: want exit 2 with a refusal, got $rc: $out"
  exit 1
fi

if [ "${CI:-}" != true ] && [ "${COMEMORY_DISPOSABLE_ENV:-}" != 1 ]; then
  echo "refusing: this installs/removes comemory and user services; run only on a disposable machine (CI=true or COMEMORY_DISPOSABLE_ENV=1)" >&2
  exit 2
fi

case "$MODE:$(uname -s)" in
  native:Darwin)
    launchctl print "gui/$(id -u)" >/dev/null || { echo "native mode needs the launchd gui domain" >&2; exit 2; }
    EXPECT_SUPERVISOR=launchd EXPECT_UNITS=1
    UNIT_DIR="$HOME/Library/LaunchAgents" UNIT_GLOB='io.comemory.sync.*.plist' ;;
  native:Linux)
    systemctl --user show-environment >/dev/null || { echo "native mode needs systemd --user" >&2; exit 2; }
    EXPECT_SUPERVISOR=systemd EXPECT_UNITS=1
    UNIT_DIR="$HOME/.config/systemd/user" UNIT_GLOB='comemory-sync-*.service' ;;
  headless:Linux)
    unset XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS
    EXPECT_SUPERVISOR=process EXPECT_UNITS=0
    UNIT_DIR="$HOME/.config/systemd/user" UNIT_GLOB='comemory-sync-*.service' ;;
  *) usage ;;
esac

if brew list --formula comemory >/dev/null 2>&1; then
  echo "refusing: comemory is already installed through brew on this machine" >&2
  exit 2
fi
[ ! -e "$HOME/.comemory" ] || { echo "refusing: $HOME/.comemory already exists" >&2; exit 2; }

export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_ENV_HINTS=1
WORK="$(mktemp -d)"
# shellcheck source=lib/brew_lifecycle.sh
. "$ROOT/scripts/lib/brew_lifecycle.sh"
OPT_CM="$BREW_PREFIX/opt/comemory/bin/comemory"   # Homebrew's stable path (H-1)
LINK_CM="$BREW_PREFIX/bin/comemory"               # what a user's PATH runs

log "brew $(brew --version | head -1); mode=$MODE supervisor=$EXPECT_SUPERVISOR"
brew tap "$TAP" "$ROOT"
TAP_DIR="$(brew --repository "$TAP")"
brew trust --formula "$TAP/comemory"

# commit_tap MESSAGE: brew reads the tap's working tree; keep it a clean git state.
commit_tap() { git -C "$TAP_DIR" -c user.name=lifecycle -c user.email=lifecycle@localhost commit -qam "$1"; }

scenario_hook_probe() {
  local s=hook_probe probe="$TAP_DIR/Formula/comemory-hook-probe.rb" var_dir rc=0 home ok
  # The same formula plus the legacy hook H-1 asks for: `ensure` from post_install.
  sed 's/^class Comemory < Formula/class ComemoryHookProbe < Formula/' "$TAP_DIR/Formula/comemory.rb" >"$probe"
  ruby -e 'path = ARGV[0]; lines = File.readlines(path); last = lines.rindex { |l| l.strip == "end" }
    lines.insert(last, <<~HOOK.lines.map { |l| "  #{l}" }.join)

      def post_install
        probe = var/"comemory-hook-probe"
        probe.mkpath
        (probe/"home").write(Dir.home)
        # Kernel.system: Formula#system would pass the redirection hash as an argument.
        ok = Kernel.system((bin/"comemory").to_s, "sync", "daemon", "ensure", "--json",
                           out: (probe/"ensure.json").to_s, err: (probe/"ensure.err").to_s)
        (probe/"exit").write(ok.inspect)
      end
    HOOK
    File.write(path, lines.join)' "$probe"
  git -C "$TAP_DIR" add "$probe"
  commit_tap "test: comemory hook probe"
  brew trust --formula "$TAP/comemory-hook-probe"

  brew install "$TAP/comemory-hook-probe" >"$WORK/probe.log" 2>&1 || rc=$?
  cat "$WORK/probe.log"
  var_dir="$BREW_PREFIX/var/comemory-hook-probe"
  home="$(cat "$var_dir/home" 2>/dev/null || echo '<hook did not run>')"
  ok="$(cat "$var_dir/exit" 2>/dev/null || echo '<none>')"
  log "probe: brew exit=$rc hook HOME=$home ensure-ok=$ok"
  cat "$var_dir/ensure.json" "$var_dir/ensure.err" 2>/dev/null || true

  daemon_status "$BREW_PREFIX/opt/comemory-hook-probe/bin/comemory" >"$WORK/probe-status.json"
  cat "$WORK/probe-status.json"
  jq -e '.state != "running"' "$WORK/probe-status.json" >/dev/null \
    || fail "$s" "a hook-started daemon serves the real data dir"
  [ "$(unit_count)" -eq 0 ] || fail "$s" "the hook installed a unit in $UNIT_DIR: $(unit_files)"
  if [ -e "$var_dir/home" ] && [ ! -e "$var_dir/exit" ]; then
    fail "$s" "the hook ran but never finished running ensure; the probe proves nothing"
  fi
  if [ "$home" = "$HOME" ] && [ "$ok" = true ]; then
    fail "$s" "post_install ran ensure with the real HOME; revisit the channel limitation"
  fi

  stop_coordinators comemory-hook-probe
  brew uninstall "$TAP/comemory-hook-probe"
  rm -rf "$var_dir"
  git -C "$TAP_DIR" rm -q "$probe"
  commit_tap "test: drop comemory hook probe"
  wait_until 20 coordinators_are 0 || fail "$s" "probe coordinators linger: $(coordinators)"
  pass "$s (Homebrew's hook ran with HOME=$home, not the user's; no daemon for $DATA_DIR)"
}

scenario_install() {
  local s=install version
  if [ "$(coordinator_count)" -ne 0 ] || [ "$(unit_count)" -ne 0 ]; then
    fail "$s" "machine not clean: $(coordinators) $(unit_files)"
  fi
  brew_logged "$s" "$WORK/install.log" install "$TAP/comemory"
  caveats_printed "$s" "$WORK/install.log"

  daemon_status "$OPT_CM" >"$WORK/after-install.json"
  jq -e '.state == "not_running"' "$WORK/after-install.json" >/dev/null \
    || fail "$s" "brew itself started a daemon: $(cat "$WORK/after-install.json")"
  [ "$(unit_count)" -eq 0 ] || fail "$s" "brew itself wrote a unit"

  version="$(formula_version)"
  [ "$(binary_version "$OPT_CM")" = "$version" ] || fail "$s" "binary is not formula version $version"
  ensure_ready "$s" "$OPT_CM" "$WORK/ensure-install.json"
  assert_ready "$s" "$WORK/ensure-install.json" "$version" "$(real_path "$OPT_CM")"
  [ "$(unit_count)" -eq "$EXPECT_UNITS" ] || fail "$s" "want $EXPECT_UNITS unit(s), have: $(unit_files)"
  [ "$(coordinator_count)" -eq 1 ] || fail "$s" "want one coordinator: $(coordinators)"
  unit_files | while IFS= read -r unit; do log "unit $unit:"; cat "$unit"; done
  pass "$s (v$version ready on $(real_path "$OPT_CM") via $EXPECT_SUPERVISOR, never logged in)"
}

scenario_queue() {
  local s=queue pending
  "$LINK_CM" save --json --repo brew-lifecycle "Queued before a Homebrew reinstall and upgrade: first."
  "$LINK_CM" save --json --repo brew-lifecycle "Queued before a Homebrew reinstall and upgrade: second."
  pending="$(pending_ops)"
  [ "$pending" -ge 2 ] || fail "$s" "want >= 2 pending replica operations, have $pending"
  [ "$(coordinator_count)" -eq 1 ] || fail "$s" "saves left $(coordinator_count) coordinators"
  snapshot "$WORK/base.snap"
  pass "$s ($pending pending operations queued while logged out)"
}

scenario_reinstall() {
  local s=reinstall version pid0 file0 file1 pid1
  version="$(formula_version)"
  daemon_status "$OPT_CM" >"$WORK/before-reinstall.json"
  pid0="$(jq -r .daemon.pid "$WORK/before-reinstall.json")"
  file0="$(jq -r .daemon.binary_file "$WORK/before-reinstall.json")"
  brew_logged "$s" "$WORK/reinstall.log" reinstall "$TAP/comemory"
  caveats_printed "$s" "$WORK/reinstall.log"
  file1="$(file_id "$(real_path "$OPT_CM")")"
  [ "$file1" != "$file0" ] || fail "$s" "reinstall kept the same file $file0"

  ensure_ready "$s" "$OPT_CM" "$WORK/ensure-reinstall.json"
  assert_ready "$s" "$WORK/ensure-reinstall.json" "$version" "$(real_path "$OPT_CM")"
  pid1="$(jq -r .daemon.pid "$WORK/ensure-reinstall.json")"
  [ "$pid1" != "$pid0" ] || fail "$s" "coordinator pid $pid0 did not restart"
  jq -e --arg f "$file1" '.daemon.binary_file == $f' "$WORK/ensure-reinstall.json" >/dev/null \
    || fail "$s" "coordinator does not run the reinstalled file $file1"
  wait_until 20 pid_gone "$pid0" || fail "$s" "old coordinator $pid0 still runs"
  [ "$(coordinator_count)" -eq 1 ] || fail "$s" "want one coordinator: $(coordinators)"
  same_snapshot "$s" "$WORK/base.snap"
  pass "$s (pid $pid0 -> $pid1, file $file0 -> $file1, queued data intact)"
}

scenario_upgrade() {
  local s=upgrade version old_bin new_bin pid0 unit
  pid0="$(daemon_status "$OPT_CM" | jq -r .daemon.pid)"
  old_bin="$(real_path "$OPT_CM")"
  # A revision bump is a real upgrade to a new keg (<version>_1) of the same release.
  python3 - "$TAP_DIR/Formula/comemory.rb" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path).read()
text, count = re.subn(r'^(  version ".*"\n)', r'\1  revision 1\n', text, count=1, flags=re.M)
if count != 1:
    sys.exit("no version line to bump")
open(path, "w").write(text)
PY
  commit_tap "test: comemory revision 1"
  brew_logged "$s" "$WORK/upgrade.log" upgrade "$TAP/comemory"
  caveats_printed "$s" "$WORK/upgrade.log"
  new_bin="$(real_path "$OPT_CM")"
  [ "$new_bin" != "$old_bin" ] || fail "$s" "upgrade kept keg $old_bin"
  log "old keg binary $old_bin exists after upgrade: $([ -e "$old_bin" ] && echo yes || echo no)"

  # An ordinary command first (engine preflight), recorded as evidence only.
  "$LINK_CM" stats --json >/dev/null
  log "after an ordinary command the daemon runs: $(daemon_status "$OPT_CM" | jq -c '{state, binary: .daemon.binary}')"

  version="$(formula_version)"
  "$LINK_CM" upgrade --json >"$WORK/upgrade.json" || fail "$s" "comemory upgrade failed: $(cat "$WORK/upgrade.json")"
  cat "$WORK/upgrade.json"
  jq -e --arg b "$new_bin" --arg v "$version" \
      '.daemon.ready == true and .daemon.binary == $b and .daemon.version == $v' "$WORK/upgrade.json" >/dev/null \
    || fail "$s" "comemory upgrade did not verify the daemon on $new_bin"
  wait_until 20 pid_gone "$pid0" || fail "$s" "old coordinator $pid0 still runs"
  [ "$(coordinator_count)" -eq 1 ] || fail "$s" "want one coordinator: $(coordinators)"
  ! coordinators | grep -qF -- "$old_bin" || fail "$s" "a coordinator still runs $old_bin"
  [ "$(unit_count)" -eq "$EXPECT_UNITS" ] || fail "$s" "want $EXPECT_UNITS unit(s), have: $(unit_files)"
  while IFS= read -r unit; do
    grep -qF -- "$new_bin" "$unit" || fail "$s" "unit $unit does not start $new_bin"
  done < <(unit_files)
  same_snapshot "$s" "$WORK/base.snap"
  pass "$s ($old_bin -> $new_bin, one coordinator, queued data intact)"
}

scenario_uninstall() {
  local s=uninstall
  "$OPT_CM" sync daemon uninstall --json
  brew uninstall "$TAP/comemory"
  wait_until 20 coordinators_are 0 || fail "$s" "coordinators remain: $(coordinators)"
  [ "$(unit_count)" -eq 0 ] || fail "$s" "units remain: $(unit_files)"
  same_snapshot "$s" "$WORK/base.snap"
  pass "$s (service removed, $DATA_DIR intact)"
}

scenario_uninstall_brew_only() {
  local s=uninstall_brew_only version leftover
  brew_logged "$s" "$WORK/reinstall2.log" install "$TAP/comemory"
  version="$(formula_version)"
  ensure_ready "$s" "$OPT_CM" "$WORK/ensure-again.json"
  assert_ready "$s" "$WORK/ensure-again.json" "$version" "$(real_path "$OPT_CM")"
  brew uninstall "$TAP/comemory"
  leftover="$(unit_count)"
  # The documented limitation: brew has no uninstall hook, so a native unit survives.
  [ "$leftover" -eq "$EXPECT_UNITS" ] || fail "$s" "want $EXPECT_UNITS leftover unit(s) after brew-only uninstall, have $leftover"
  log "after brew-only uninstall: units=$leftover coordinators=$(coordinator_count)"
  remove_units_by_hand
  stop_coordinators "sync daemon run"
  wait_until 20 coordinators_are 0 || fail "$s" "coordinators remain after manual cleanup: $(coordinators)"
  [ "$(unit_count)" -eq 0 ] || fail "$s" "units remain after manual cleanup"
  same_snapshot "$s" "$WORK/base.snap"
  pass "$s (brew uninstall alone left $leftover unit(s); data intact)"
}

scenario_hook_probe
scenario_install
scenario_queue
scenario_reinstall
scenario_upgrade
scenario_uninstall
scenario_uninstall_brew_only
log "all brew lifecycle scenarios passed ($MODE)"
