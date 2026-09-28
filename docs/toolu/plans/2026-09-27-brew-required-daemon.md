# Required daemon across Homebrew install, upgrade and regeneration — Plan

**Date:** 2026-09-27   **Status:** Draft   **Spec:** docs/toolu/specs/2026-09-27-brew-required-daemon-design.md   **Topic:** Falconiere/homebrew-tap#1: formula lifecycle contract, regeneration guard, real-brew CI

## Evidence and approach

- **Evidence inspected:**
  - Homebrew 7.0.6 source: `formula_installer.rb#post_install` (sandboxed),
    `formula.rb#run_post_install` (temporary HOME, `odeprecated`) and
    `rubocops/install_steps.rb` (legacy hook rejected).
  - comemory `origin/main` engine behavior, read through the explorer and a
    container probe with the v0.51.0 linux binary:
    - `sync daemon status` starts nothing;
    - `save` starts the coordinator through preflight and queues `pending`
      `replica_operation` rows without auth;
    - `sync daemon uninstall` keeps the data;
    - `comemory upgrade` resolves the latest tag through the `releases/latest`
      redirect and, on the Homebrew channel, runs `ensure_child` on the
      canonical Cellar file.
  - The publisher step in comemory `.github/workflows/release.yml` (inline
    completion Ruby with a `    install_binary_aliases!\n` anchor, then
    `brew style --fix` with FormulaAudit/Homepage, FormulaAudit/Desc and
    FormulaAuditStrict excepted).
  - The raw generated `comemory.rb` is attached to each comemory release.
- **Memory:** recall was unavailable. The local comemory 0.50.0 cannot open a
  schema-0029 database.
- **Approach:** as in the spec: a caveats contract, a tap-owned `apply`/`check`
  script tested on the real release asset, and a real-brew lifecycle script run
  on disposable runners. Native preconditions mirror the engine's
  `scripts/test-daemon-install.sh` (D10).
- **Tooling:**
  - Local checks are `shellcheck`, `ruby -c`, the contract test, `brew style`
    (read-only) and `actionlint` through docker.
  - Lifecycle behavior is proven only by the CI run for the pushed HEAD. The
    developer machine runs a live brew-installed comemory and must not be
    touched.

## Workstream summary

Repository hygiene → red contract test on the real release asset → contract
script → formula patched by the script → lifecycle script and workflow (red on
the unpatched formula, then green) → README → full gate.

## Steps (machine-readable)

```json
[
  {
    "id": "S1-gitignore",
    "title": "Ignore local Claude settings and tmp state",
    "check": "git check-ignore -q .claude/settings.local.json && git check-ignore -q .claude/tmp/x",
    "paths": [".gitignore"]
  },
  {
    "id": "S2-contract-test",
    "title": "Contract test over the real latest-release comemory.rb (red before the script exists)",
    "check": "bash scripts/test-formula-contract.sh",
    "ac_refs": ["AC-5"],
    "depends_on": ["S1-gitignore"],
    "input": "gh release download (latest Falconiere/comemory) -p comemory.rb; committed Formula/comemory.rb",
    "paths": ["scripts/test-formula-contract.sh", "scripts/comemory_formula.rb", "Formula/comemory.rb"]
  },
  {
    "id": "S3-contract-script",
    "title": "scripts/comemory_formula.rb apply/check; Formula/comemory.rb regenerated through apply",
    "check": "ruby -c scripts/comemory_formula.rb && ruby scripts/comemory_formula.rb check Formula/comemory.rb && bash scripts/test-formula-contract.sh && brew style --except-cops FormulaAudit/Homepage,FormulaAudit/Desc,FormulaAuditStrict Formula/comemory.rb",
    "ac_refs": ["AC-1", "AC-5"],
    "depends_on": ["S2-contract-test"],
    "input": "real latest-release comemory.rb; committed Formula/comemory.rb",
    "paths": ["scripts/comemory_formula.rb", "scripts/test-formula-contract.sh", "Formula/comemory.rb"]
  },
  {
    "id": "S4-lifecycle-script",
    "title": "scripts/test-brew-lifecycle.sh scenarios hook_probe, install, reinstall, upgrade, uninstall, uninstall_brew_only",
    "check": "shellcheck scripts/*.sh scripts/lib/*.sh && bash scripts/test-brew-lifecycle.sh --self-test",
    "ac_refs": ["AC-1", "AC-2", "AC-3", "AC-4", "AC-6"],
    "depends_on": ["S3-contract-script"],
    "input": "real brew, real v0.51.0 release artifacts, real launchd/systemd on disposable runners",
    "paths": ["scripts/test-brew-lifecycle.sh", "scripts/lib"]
  },
  {
    "id": "S5-workflow",
    "title": ".github/workflows/lifecycle.yml: contract job + brew-lifecycle matrix (macos-14 native, ubuntu-22.04 native, ubuntu-22.04 headless); on PR, push to main, dispatch",
    "check": "docker run --rm -v \"$PWD:/repo\" -w /repo rhysd/actionlint:latest -color=never && test \"$(gh run list -w lifecycle.yml -c \"$(git rev-parse HEAD)\" --json conclusion -q '[.[] | .conclusion] | unique | join(\",\")')\" = success",
    "ac_refs": ["AC-1", "AC-2", "AC-3", "AC-4", "AC-5", "AC-6"],
    "depends_on": ["S4-lifecycle-script"],
    "input": "GitHub Actions run for the pushed HEAD",
    "paths": [".github/workflows/lifecycle.yml", "scripts", "Formula/comemory.rb"]
  },
  {
    "id": "S6-readme",
    "title": "README: supported readiness commands, channel limitation (H-6), uninstall order, engine contract links",
    "check": "grep -q 'sync daemon ensure' README.md && grep -q 'comemory upgrade' README.md && grep -q 'sync daemon uninstall' README.md && grep -q 'docs/guides/upgrading.md' README.md && grep -qi 'does not fully support' README.md",
    "ac_refs": ["AC-7"],
    "depends_on": ["S3-contract-script"],
    "paths": ["README.md"]
  }
]
```

## Critical files

- `.gitignore` (new)
- `scripts/comemory_formula.rb` (new)
- `scripts/test-formula-contract.sh` (new)
- `scripts/test-brew-lifecycle.sh` (new), `scripts/lib/brew_lifecycle.sh` (new)
- `.github/workflows/lifecycle.yml` (new)
- `Formula/comemory.rb` (caveats added through `apply`)
- `README.md`

## Verification

- **End to end:** the `lifecycle.yml` run for the pushed HEAD is green on all
  four jobs. The contract step inside it runs against the real latest-release
  `comemory.rb`.
- **Red evidence:** before S3, `test-formula-contract.sh` fails because the
  script is missing and the committed formula lacks caveats. The first CI run of
  the lifecycle script, on the unpatched formula, fails `install` at the caveats
  assertion.
- **Boundaries covered:**
  - headless `process` supervisor;
  - the legacy hook probe;
  - a brew-only uninstall leftover;
  - an upgrade that changes the keg;
  - `apply` on a formula that already has completions.
- **Docs:** README, plus the formula caveats as user-facing text. Follow-ups
  F-1 to F-3 go in the PR body.
