# Required daemon across Homebrew install, upgrade and regeneration — Plan

**Date:** 2026-09-27   **Status:** Approved   **Spec:** docs/toolu/specs/2026-09-27-brew-required-daemon-design.md   **Topic:** Falconiere/homebrew-tap#1: formula lifecycle contract, regeneration guard, real-brew CI

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
  - Local checks are `shellcheck`, `ruby -c`, the contract test and
    `actionlint` through docker.
  - `brew style` runs only in CI, on the tapped formula. Run locally on the
    worktree path, it has no formula context and applies generic Ruby cops, as
    observed.
  - Lifecycle behavior is proven only by the CI run for the pushed HEAD. The
    developer machine runs a live brew-installed comemory and must not be
    touched.

## Workstream summary

Repository hygiene → contract test written first (red while the script is
absent), then the contract script → formula patched through `apply` (red:
`check` fails on the committed formula first) → README asserted by the
contract test → lifecycle script → workflow proven by the HEAD push run
(`scripts/check-ci-run.sh` waits for it, then requires all 4 jobs green).

## Steps (machine-readable)

```json
[
  {
    "id": "S1-gitignore",
    "title": "Ignore local Claude settings and tmp state",
    "check": "git check-ignore -q .claude/settings.local.json && git check-ignore -q .claude/tmp/x",
    "paths": [
      ".gitignore"
    ]
  },
  {
    "id": "S2-contract-script",
    "title": "scripts/comemory_formula.rb apply/check with its fixture test (test written first; red while the script is absent)",
    "check": "ruby -c scripts/comemory_formula.rb && bash scripts/test-formula-contract.sh --fixtures-only",
    "ac_refs": [
      "AC-5"
    ],
    "depends_on": [
      "S1-gitignore"
    ],
    "input": "real latest-release comemory.rb (gh release download); real v0.51.0 publisher output (git show 51f149b:Formula/comemory.rb); boundary copies with opt-out wording in caveats, a sync daemon call in install, post_install, service do, and a missing anchor",
    "paths": [
      "scripts/comemory_formula.rb",
      "scripts/test-formula-contract.sh"
    ]
  },
  {
    "id": "S3-formula",
    "title": "Formula/comemory.rb regenerated through apply (red: check fails on the committed formula before apply)",
    "check": "ruby scripts/comemory_formula.rb check Formula/comemory.rb && ruby -c Formula/comemory.rb",
    "ac_refs": [
      "AC-1",
      "AC-5"
    ],
    "depends_on": [
      "S2-contract-script"
    ],
    "input": "committed Formula/comemory.rb (release 0.51.0 publisher output)",
    "paths": [
      "scripts/comemory_formula.rb",
      "Formula/comemory.rb"
    ]
  },
  {
    "id": "S4-readme",
    "title": "README: supported readiness commands, channel limitation (H-6), uninstall order, engine contract links; asserted by the contract test's repository cases",
    "check": "bash scripts/test-formula-contract.sh",
    "ac_refs": [
      "AC-7",
      "AC-5"
    ],
    "depends_on": [
      "S3-formula"
    ],
    "input": "README.md, committed Formula/comemory.rb, real latest-release comemory.rb",
    "paths": [
      "README.md",
      "Formula/comemory.rb",
      "scripts/comemory_formula.rb",
      "scripts/test-formula-contract.sh"
    ]
  },
  {
    "id": "S5-lifecycle-script",
    "title": "scripts/test-brew-lifecycle.sh (+ scripts/lib/brew_lifecycle.sh): scenarios hook_probe, install, reinstall, upgrade, uninstall, uninstall_brew_only; --self-test is syntax/refusal only",
    "check": "shellcheck scripts/*.sh scripts/lib/*.sh && bash scripts/test-brew-lifecycle.sh --self-test",
    "depends_on": [
      "S3-formula"
    ],
    "paths": [
      "scripts"
    ]
  },
  {
    "id": "S6-workflow",
    "title": ".github/workflows/lifecycle.yml: contract job (check + contract test + brew style on the tapped formula with the publisher's exceptions) and brew-lifecycle matrix (macos-14 native, ubuntu-22.04 native, ubuntu-22.04 headless); push on any branch + workflow_dispatch. Proven by the push run for HEAD: waits for it to finish, then requires exactly 4 jobs all success",
    "check": "docker run -i --rm rhysd/actionlint:latest -no-color -stdin-filename .github/workflows/lifecycle.yml - < .github/workflows/lifecycle.yml && bash scripts/check-ci-run.sh lifecycle.yml \"$(git rev-parse HEAD)\" 4",
    "ac_refs": [
      "AC-1",
      "AC-2",
      "AC-3",
      "AC-4",
      "AC-5",
      "AC-6",
      "AC-7"
    ],
    "depends_on": [
      "S4-readme",
      "S5-lifecycle-script"
    ],
    "input": "GitHub Actions push run for HEAD on real brew/launchd/systemd runners with real v0.51.0 release artifacts",
    "paths": [
      ".github/workflows/lifecycle.yml",
      "scripts",
      "Formula/comemory.rb",
      "README.md"
    ]
  }
]
```

## Critical files

- `.gitignore` (new)
- `scripts/comemory_formula.rb` (new)
- `scripts/test-formula-contract.sh` (new)
- `scripts/test-brew-lifecycle.sh` (new), `scripts/lib/brew_lifecycle.sh` (new)
- `scripts/check-ci-run.sh` (new): waits for the push run of `<workflow>` at
  `<sha>`, then requires exactly N jobs, all `success`
- `.github/workflows/lifecycle.yml` (new)
- `Formula/comemory.rb` (caveats added through `apply`)
- `README.md`

## Verification

- **End to end:** the `lifecycle.yml` run for the pushed HEAD is green on all
  four jobs. The contract step inside it runs against the real latest-release
  `comemory.rb`.
- **Red evidence:**
  - S2: the fixture test fails before `comemory_formula.rb` exists.
  - S3: `check` fails on the committed formula before `apply`, naming the
    missing caveats. This is red for the right reason.
  - S4: the repository cases fail before the README update.
- **Boundaries covered:**
  - headless `process` supervisor;
  - the legacy hook probe;
  - a brew-only uninstall leftover;
  - an upgrade that changes the keg;
  - `apply` on a formula that already has completions.
- **Docs:** README, plus the formula caveats as user-facing text. Follow-ups
  F-1 to F-3 go in the PR body, stating that H-1 is a manual step and that H-4
  is detection-only until F-1.
- **Delivery:**
  1. Scoped commits, each pushed after its affected checks pass.
  2. `plan-ledger.sh run <plan> --verify` fresh-green.
  3. `toolu-review:review` with version 2 state.
  4. `verdict.sh status` shows `overall: ready`.
  5. Push, then open the PR with body `Closes Falconiere/homebrew-tap#1` /
     `Part of Falconiere/comemory#248` and CI links.
  6. Hand off to `pr-babysit:babysit`.

## Deviations

- Plan review round 1 (Needs changes):
  - S2 now pairs the script with its fixture test.
  - The committed-formula red moved to S3.
  - The README is asserted in the contract test, so CI enforces it.
  - `--self-test` is defined, and S5 carries no AC refs.
  - The CI check waits for completion and asserts per-job success.
  - The trigger moved to push on any branch.

  All findings were addressed.

- Plan review round 2: Approved. The should-fix, the `check-ci-run.sh` contract, went into the spec's Interfaces. The consider item is taken up: CI downloads the release asset once and passes it through `--release-formula`.
- Execution: the actionlint flag is `-no-color`; `-color=never` is invalid in actionlint 1.7.12.
- Execution: actionlint reads the workflow on stdin, because Colima does not share `/Volumes` with containers.
