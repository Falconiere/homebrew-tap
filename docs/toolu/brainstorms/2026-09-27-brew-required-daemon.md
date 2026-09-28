# Brainstorm — Required daemon across Homebrew install, upgrade and regeneration

**Date:** 2026-09-27   **Issue:** Falconiere/homebrew-tap#1 (epic Falconiere/comemory#248)   **Path:** Full

## Capsule

- **Outcome:** Homebrew users get the same verified, resident sync daemon the
  engine's managed installers give, through commands the formula names and
  real-brew CI proves. The formula never claims a readiness Homebrew cannot
  deliver, and a future cargo-dist regeneration cannot quietly drop the
  integration.
- **Material defaults/non-goal:** There is no formula `post_install` and no
  `service do` block. The formula carries a `caveats` lifecycle contract. Real
  `brew` install, reinstall, upgrade and uninstall run on disposable GitHub
  runners. A tap-owned contract script (`apply`/`check`) guards
  regeneration. Engine and comemory `release.yml` edits are out of scope for this
  worker and are recorded as follow-ups.
- **Repository evidence:** Homebrew 7.0.6 source (see the axes below). The
  engine design `docs/designs/2026-09-26-managed-daemon-install.md` (D8 and
  non-goal 1) assigns the hook, the guard and the real-brew evidence to this
  issue. The live user unit on this machine points at
  `/opt/homebrew/Cellar/comemory/0.50.0/bin/comemory`.
- **Risk:** Until comemory's `release.yml` calls the tap script, each release
  push drops the caveats, and tap CI turns red on that commit. That failure is
  loud, but it is only fixed by the follow-up. The unit still pins the versioned
  Cellar path, which is engine-owned: after `brew upgrade` plus cleanup, the old
  daemon survives only until the next CLI command or `comemory upgrade` repairs
  it.
- **Handoff:** spec.

## Axes

**Failure behavior / constraints: can a formula hook start the user service?** No.
In Homebrew 7.0.6:

- `FormulaInstaller#post_install` runs `postinstall.rb` under
  `Sandbox.run_or_fork`. Writes are limited to the Cellar, `etc`, `var` and the
  prefix link directories, with `deny_read_home` and network denied unless
  allowed.
- `Formula#run_post_install` creates a fresh temporary `HOME`
  (`Dir.mktmpdir("#{name}-postinstall-", HOMEBREW_TEMP)`) and clears sensitive
  env. The engine's default data directory is `$HOME/.comemory`, so `ensure`
  there would target a throwaway directory.
- Legacy `post_install` is `odeprecated`, and the `InstallSteps` rubocop rejects
  it. `post_install_steps` allows only literal file steps.
- A formula has no uninstall hook.

The issue anticipates this outcome (H-2 and H-6): report the limitation
explicitly, keep the CLI-managed path, and do not claim full support.

**Integration: the supported path.** The engine already provides it:

- `sync daemon ensure` verifies version, canonical binary and `binary_file`.
- Any ordinary command repairs a missing daemon through preflight (observed in a
  container: `save` started the coordinator).
- `comemory upgrade` on the Homebrew channel runs `brew upgrade` and then
  `ensure_child` on the canonical Cellar file (D8).
- `sync daemon uninstall` removes the unit and keeps the data.

`sync daemon status` is preflight-exempt, so a test can observe that brew
started nothing.

**Data.** Unauthenticated `save` queues real `pending` rows in
`replica_operation` (observed with v0.51.0). Upgrade and reinstall preservation
is asserted on those rows plus the `memories` table and files.

**Regeneration.** The release step (comemory `.github/workflows/release.yml`,
publish-homebrew-formula) runs with this tap checked out as its working
directory. It currently injects completions with inline Ruby, then runs
`brew style --fix`. The raw generated formula is a release asset (`comemory.rb`
on v0.51.0). That asset is the real input for the guard test.

## Alternatives

| Option | Verdict |
|---|---|
| Legacy `post_install` running `ensure` | Rejected. It targets a temporary HOME inside the sandbox, is audit-rejected and deprecated, and would claim readiness that is not real. It is kept only as a CI probe that proves the limitation. |
| `service do` plus `brew services` | Rejected. H-3 forbids a second unit-naming scheme (`homebrew.mxcl.*`), and it still does not start on install. |
| Caveats contract, real-brew CI and a tap guard | Chosen. Jev choice `limitation_explicit`, p=1.00. |
| Guard only in comemory `release.yml` | Not authorized for this worker. Recorded as a follow-up. The tap script is the one the release step should call. Jev choice `tap_ci_plus_followup`, p=1.00. |

## Follow-ups (outside this worktree's authorization)

1. comemory `release.yml`: replace the inline completion Ruby with
   `ruby scripts/comemory_formula.rb apply` and `check` against this tap's
   checkout, before `git commit`.
2. Engine: write the stable `opt/comemory/bin/comemory` path into the unit for
   Homebrew installs. This is design non-goal 1's "stable `opt/` path inside the
   unit" item.
3. comemory `scripts/replication/coverage.json`: add rows H-1 to H-6 pointing at
   this tap's CI jobs.
