#!/usr/bin/env bash
# Contract test for scripts/comemory_formula.rb, over real formulae:
#   - the raw cargo-dist `comemory.rb` attached to the latest comemory release
#     (what the next release will publish), fetched with `gh` unless
#     --release-formula names a local copy;
#   - the v0.51.0 publisher output (commit 51f149b), which already carries the
#     completions block that comemory's release.yml injects today;
#   - boundary copies of those that break the contract one way each.
# Repository cases (skipped by --fixtures-only) check the committed formula and
# the README statements that describe the Homebrew channel.
#
# Usage: bash scripts/test-formula-contract.sh [--release-formula PATH] [--fixtures-only]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$ROOT/scripts/comemory_formula.rb"
PUBLISHED_COMMIT="51f149b"
release_formula=""
fixtures_only=0

while [ $# -gt 0 ]; do
  case "$1" in
    --release-formula) release_formula="${2:?--release-formula needs a path}"; shift 2 ;;
    --fixtures-only) fixtures_only=1; shift ;;
    *) echo "usage: $0 [--release-formula PATH] [--fixtures-only]" >&2; exit 2 ;;
  esac
done

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

pass() { echo "PASS $1"; }
fail() { echo "FAIL $1: $2"; failures=$((failures + 1)); }

# expect_check NAME FILE ok|fail [STDERR-SUBSTRING...]
expect_check() {
  local name="$1" file="$2" want="$3" rc=0 needle
  shift 3
  ruby "$TOOL" check "$file" >"$work/out" 2>"$work/err" || rc=$?
  if [ "$want" = ok ] && [ "$rc" -ne 0 ]; then
    fail "$name" "check exited $rc: $(tr '\n' ' ' <"$work/err")"; return
  fi
  if [ "$want" = fail ] && [ "$rc" -ne 1 ]; then
    fail "$name" "check exited $rc, want 1"; return
  fi
  for needle in "$@"; do
    if ! grep -qF -- "$needle" "$work/err"; then
      fail "$name" "stderr lacks '$needle': $(tr '\n' ' ' <"$work/err")"; return
    fi
  done
  pass "$name"
}

# expect_apply_fails NAME FILE STDERR-SUBSTRING
expect_apply_fails() {
  local name="$1" file="$2" needle="$3" rc=0
  cp "$file" "$work/before"
  ruby "$TOOL" apply "$file" >"$work/out" 2>"$work/err" || rc=$?
  if [ "$rc" -ne 1 ]; then fail "$name" "apply exited $rc, want 1"; return; fi
  if ! grep -qF -- "$needle" "$work/err"; then fail "$name" "stderr lacks '$needle'"; return; fi
  if ! cmp -s "$file" "$work/before"; then fail "$name" "apply modified the file despite failing"; return; fi
  pass "$name"
}

# insert_before_class_end FILE TEXT: splice TEXT in front of the last line (the class `end`).
insert_before_class_end() {
  ruby -e 'path, text = ARGV; lines = File.readlines(path); last = lines.rindex { |l| l.strip == "end" }; lines.insert(last, text); File.write(path, lines.join)' "$1" "$2"
}

# --- inputs -------------------------------------------------------------------
if [ -z "$release_formula" ]; then
  gh release download --repo Falconiere/comemory --pattern comemory.rb --dir "$work/release" >/dev/null
  release_formula="$work/release/comemory.rb"
fi
[ -s "$release_formula" ] || { echo "release formula missing or empty: $release_formula" >&2; exit 2; }
cp "$release_formula" "$work/raw.rb"
git -C "$ROOT" show "$PUBLISHED_COMMIT:Formula/comemory.rb" >"$work/published.rb"

# --- fixture cases ------------------------------------------------------------
expect_check "raw release formula is rejected" "$work/raw.rb" fail \
  "contract: missing def caveats" "contract: missing generate_completions_from_executable"

cp "$work/raw.rb" "$work/applied.rb"
if ruby "$TOOL" apply "$work/applied.rb" && ruby -c "$work/applied.rb" >/dev/null; then
  pass "apply on raw release formula yields valid Ruby"
else
  fail "apply on raw release formula yields valid Ruby" "apply or ruby -c failed"
fi
expect_check "applied raw release formula satisfies the contract" "$work/applied.rb" ok

cp "$work/applied.rb" "$work/applied-twice.rb"
ruby "$TOOL" apply "$work/applied-twice.rb"
if cmp -s "$work/applied.rb" "$work/applied-twice.rb"; then
  pass "apply is idempotent"
else
  fail "apply is idempotent" "second apply changed the file"
fi

expect_check "published v0.51.0 formula (completions, no caveats) is rejected" "$work/published.rb" fail \
  "contract: missing def caveats"
cp "$work/published.rb" "$work/published-applied.rb"
ruby "$TOOL" apply "$work/published-applied.rb"
completions="$(grep -c 'generate_completions_from_executable(' "$work/published-applied.rb" || true)"
if [ "$completions" = 1 ]; then
  pass "apply keeps an existing completions block single"
else
  fail "apply keeps an existing completions block single" "found $completions completions calls"
fi
expect_check "applied published formula satisfies the contract" "$work/published-applied.rb" ok

cp "$work/applied.rb" "$work/optout.rb"
ruby -e 'p = ARGV[0]; s = File.read(p); s.sub!("Homebrew cannot start it", "the daemon is optional; skip it with --no-daemon"); File.write(p, s)' "$work/optout.rb"
expect_check "opt-out wording in caveats is rejected" "$work/optout.rb" fail "contract: caveats offer an opt-out"

cp "$work/applied.rb" "$work/install-daemon.rb"
ruby -e 'p = ARGV[0]; s = File.read(p); s.sub!("    install_binary_aliases!\n", "    install_binary_aliases!\n    system bin/\"comemory\", \"sync\", \"daemon\", \"ensure\"\n"); File.write(p, s)' "$work/install-daemon.rb"
expect_check "sync daemon call outside caveats is rejected" "$work/install-daemon.rb" fail \
  "contract: sync daemon invoked outside caveats"

cp "$work/applied.rb" "$work/post-install.rb"
insert_before_class_end "$work/post-install.rb" $'\n  def post_install\n    system bin/"comemory", "--version"\n  end\n'
expect_check "post_install is rejected" "$work/post-install.rb" fail "contract: post_install is forbidden"

cp "$work/applied.rb" "$work/service.rb"
insert_before_class_end "$work/service.rb" $'\n  service do\n    run [opt_bin/"comemory", "--version"]\n  end\n'
expect_check "service block is rejected" "$work/service.rb" fail "contract: service block is forbidden"

grep -vF 'install_binary_aliases!' "$work/raw.rb" >"$work/no-anchor.rb"
expect_apply_fails "apply refuses a formula without the completions anchor" "$work/no-anchor.rb" \
  "anchor"

# --- repository cases ---------------------------------------------------------
if [ "$fixtures_only" -eq 0 ]; then
  expect_check "committed Formula/comemory.rb satisfies the contract" "$ROOT/Formula/comemory.rb" ok
  readme="$ROOT/README.md"
  missing=""
  for needle in "sync daemon ensure" "comemory upgrade" "sync daemon uninstall" \
      "does not fully support" "docs/guides/upgrading.md" "docs/scenarios/install.md"; do
    grep -qF -- "$needle" "$readme" || missing="$missing '$needle'"
  done
  if [ -z "$missing" ]; then
    pass "README documents the Homebrew daemon lifecycle and its limitation"
  else
    fail "README documents the Homebrew daemon lifecycle and its limitation" "missing:$missing"
  fi
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures contract case(s) failed" >&2
  exit 1
fi
echo "all contract cases passed"
