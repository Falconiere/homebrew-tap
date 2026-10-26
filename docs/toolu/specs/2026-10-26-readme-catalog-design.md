# README catalog for the whole tap — Design

**Date:** 2026-10-26   **Status:** Approved   **Author:** Falconiere Barbosa (delivery-flow agent)   **Topic:** Rewrite README.md so it presents every formula in the tap, not only comemory

## Problem

The tap ships four formulae (`comemory`, `git-better`, `toolu`, `toolu-runner`),
but `README.md` documents only comemory. A visitor cannot see what the tap
offers, which command each formula installs, which platforms it covers, or the
one-time step Homebrew 7 needs before it loads third-party formulae
(`brew trust`). toolu and toolu-runner also each need one command after
`brew install` (`toolu plugins install`, `toolu-runner setup`) that this tap
never mentions.

## Non-Goals

1. No change to any formula, script or CI workflow.
2. No new CI assertion for the catalog; the ledger checks below prove it once.
3. No version numbers in the README (release bots bump them on every release).
4. No badges, emoji or logo (plain style matches the current README).
5. No new docs files; comemory's lifecycle text stays in the README because
   `scripts/test-formula-contract.sh` asserts it there.
6. No duplication of upstream install guides beyond the one follow-up command
   per formula; link to them instead.

## Architecture

One rewritten `README.md` with this order:

1. Title and one-sentence intro.
2. **Quick start:** `brew tap Falconiere/tap`,
   `brew trust --formula Falconiere/tap/toolu`, `brew install Falconiere/tap/toolu`,
   plus a note that `brew trust --tap Falconiere/tap` trusts every formula,
   including later ones.
3. **Formulae** table: formula (linked to its upstream repo), command it
   installs, what it does, platforms. Followed by one line on upgrade and
   uninstall (`brew upgrade` / `brew uninstall`, except comemory).
4. Per-formula sections only where a post-install step exists:
   - `## comemory`: the current daemon lifecycle text and `### Channel support`,
     content kept.
   - `## toolu`: `toolu plugins install`, link to upstream install docs, and a
     note that the curl installer's pinning and rollback do not apply to a
     Homebrew install.
   - `## toolu-runner`: `toolu-runner setup`, link to upstream quick start.
   - Each section's code block can be run on its own: it taps and trusts its
     formula before `brew install`, because the table links straight to it.
5. `## Maintaining this tap`: which release automation regenerates each
   formula, the current comemory `scripts/comemory_formula.rb apply|check`
   text, and what `.github/workflows/lifecycle.yml` runs.

Decisive trade-off: a catalog layout over appending a list above the existing
comemory text (leaves the README lopsided) or splitting comemory into its own
doc (breaks the README contract test). Jev ranked catalog 0.91, split 0.08,
append 0.01.

Trust command: the quick start defaults to `--formula`, which trusts only
what the user installs. Three separate release automations push formulae
here, so `--tap` would let any of them ship a formula Homebrew loads without
asking. `--tap` is named as the opt-in shortcut. The first draft defaulted to
`--tap` (Jev 0.51 / 0.49); code review raised the supply-chain point, and Jev
then ranked `--formula` 0.98.

Facts are taken from the repository and upstream, not invented:

| Formula | Command | Platforms (from `url` blocks) | Post-install (upstream README) |
| --- | --- | --- | --- |
| comemory | `comemory` | macOS arm64, Linux x86_64/arm64 | `sync daemon ensure` (current README) |
| git-better | `gb` (`bin.install "gb"`) | macOS arm64, Linux x86_64/arm64 | none |
| toolu | `toolu` | macOS arm64/x86_64, Linux x86_64/arm64 | `toolu plugins install` |
| toolu-runner | `toolu-runner` | macOS arm64/x86_64, Linux x86_64/arm64 | `toolu-runner setup` |

## Interfaces / Schema

- File: `README.md` (rewrite). Spec and plan under `docs/toolu/`.
- Table row shape, one per `Formula/<name>.rb`:
  ``| [`<name>`](<homepage>) | `<command>` | <desc> | <platforms> |``
- Platform strings, exactly: `macOS arm64/x86_64, Linux x86_64/arm64` when the
  formula has a macOS Intel `url` (`x86_64-apple-darwin` or `darwin-amd64`),
  otherwise `macOS arm64, Linux x86_64/arm64`.
- Headings used as link anchors: `## comemory`, `## toolu`, `## toolu-runner`.

## Failure modes and edge cases

- **Contract needle dropped:** if the rewrite loses any string that
  `scripts/test-formula-contract.sh` greps (`sync daemon ensure`,
  `comemory upgrade`, `sync daemon uninstall`, `does not fully support`,
  `docs/guides/upgrading.md`, `docs/scenarios/install.md`), the test prints
  `FAIL README documents ...` and exits 1. Not converted; the step stays red.
- **Formula added later without a row:** not prevented by CI (Non-Goal 2); the
  AC-1 check catches it when re-run.
- **Platform drift:** a release adding or dropping a target makes the AC-2
  check fail until the row is updated.
- **Dead link:** an upstream repo renamed or private returns a non-200 status
  in the AC-6 check, which fails.
- **Concurrent release push:** release bots commit only `Formula/*.rb`, so they
  cannot conflict with this README change; a version bump needs no README edit.
- **`gh` cannot authenticate:** the contract test's `gh release download`
  fails and the AC-3 step stays red until `gh` has a working login.
- **Moved upstream heading:** a URL fragment such as `#quick-start` keeps
  returning 200 after the heading is renamed; the AC-6 check reads the target
  Markdown and fails.

## Acceptance criteria

- **AC-1:** Given the four files in `Formula/`, `README.md` has exactly one
  table row per formula, its name linked to that formula's `homepage`, and no
  formula row for anything outside `Formula/`.
- **AC-2:** Given each formula's `url` blocks, its README row states the
  platform string defined above; comemory and git-better do not claim macOS
  x86_64.
- **AC-3:** Given the rewritten README, `scripts/test-formula-contract.sh`
  (repository cases included) prints
  `PASS README documents the Homebrew daemon lifecycle and its limitation` and
  `all contract cases passed`.
- **AC-4:** Given Homebrew 7.0.11 and an empty trust store,
  `brew info --formula Falconiere/tap/<f>` exits 1 with
  `Refusing to load formula`. After the quick start's
  `brew trust --formula Falconiere/tap/toolu`, toolu loads and git-better is
  still refused. After the named `brew trust --tap Falconiere/tap`, all four
  load. Every README code block that runs `brew install Falconiere/tap/<f>`
  trusts `<f>` (or the tap) earlier in the same block.
- **AC-5:** Given upstream READMEs, the README contains `toolu plugins install`
  under `## toolu` and `toolu-runner setup` under `## toolu-runner`.
- **AC-6:** Every `https://` URL in `README.md` answers HTTP 200 after
  redirects, every `](#anchor)` link matches a heading, and every fragment
  on a GitHub URL matches a heading in the Markdown it points to.

## Acceptance evidence

| AC | Real input | Expected result | Boundary / failure | Check |
| --- | --- | --- | --- | --- |
| AC-1 | `Formula/*.rb` names and `homepage` lines | one row per name with that homepage; formula-row count equals file count | current README lacks `git-better`, `toolu`, `toolu-runner` rows, so the check is red before the rewrite | loop over `Formula/*.rb`, `grep -c` the row, require 1; compare total row count |
| AC-2 | `url` lines of each formula | row contains the derived platform string | comemory and git-better have no Intel macOS URL; their rows must not say `arm64/x86_64` for macOS | loop deriving the string from the formula, `grep` it in the row |
| AC-3 | committed README plus latest comemory release formula via `gh` | both PASS lines, exit 0 | the test itself rejects a missing needle | `bash scripts/test-formula-contract.sh` |
| AC-4 | installed `brew`, the tapped `falconiere/tap`, a throwaway `XDG_CONFIG_HOME` (so the user's `~/.homebrew/trust.json` is untouched), README code blocks | untrusted load refused; `--formula` trust loads only that formula; `--tap` trust loads all four; every install line is preceded by its trust line | git-better still refused after trusting toolu proves the narrow scope; a block with an untrusted install fails | README line grep, `brew trust` + `brew info --formula` in the throwaway config, `awk` pass over code blocks |
| AC-5 | README sections | each command inside its section | a command placed in the wrong section fails | `awk` section extract plus `grep` |
| AC-6 | every URL, in-page anchor and GitHub URL fragment in README | all 200; all anchors and fragments resolve | a 404, a missing heading, or a fragment on a non-GitHub URL fails | `curl -sL -o /dev/null -w '%{http_code}'` per URL; heading slugs from README and from the raw target Markdown |

## Documentation impact

`README.md` is the change. No other user-facing surface changes; formulae,
caveats and scripts are untouched.

## Open Questions

None blocking. Whether to add a permanent CI assertion for the catalog
(Non-Goal 2) is left to the owner, Falconiere Barbosa, as a later choice.

## Spec review

- Acceptance evidence: 🔵 consider: checks are summarized here. The plan ledger must give exact commands.
- AC-4: fixed in review. The first draft only grepped `brew trust --help`. Now it runs the trust command in a throwaway config and loads every formula.
- AC-1: fixed in review. It now also rejects formula rows that have no file in `Formula/`.

**Status:** Approved

## Revision after code review (2026-10-26)

`/code-review high` on PR #3 found eight issues. All are fixed here:

1. Trust scope: the quick start now defaults to `--formula` (Architecture, AC-4).
2. Section blocks now tap and trust before `brew install` (Architecture, AC-4).
3. The toolu section no longer points Homebrew users to the installer's pinning and rollback.
4. The maintainer section no longer claims bumps never need manual edits.
5. The CI paragraph attributes the README check to the `contract` job and says what CI does not check.
6. AC-6 now covers fragments on GitHub URLs.
7. The plan's S3 error message no longer prints literal quotes.
8. The spec and plan no longer record one machine's credential setup.

**Status:** Approved
