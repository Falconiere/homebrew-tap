# README catalog for the whole tap — Plan

**Date:** 2026-10-26   **Status:** Approved   **Spec:** docs/toolu/specs/2026-10-26-readme-catalog-design.md   **Topic:** Rewrite README.md so it presents every formula in the tap

## Evidence and approach

- **Inspected:** `Formula/*.rb` (`desc`, `homepage`, `url` targets,
  `bin.install`), current `README.md`, the README needles in
  `scripts/test-formula-contract.sh` (repository cases),
  `.github/workflows/lifecycle.yml`, and upstream READMEs for toolu
  (`toolu plugins install`) and toolu-ghrunner (`toolu-runner setup`).
- **Probed:** `brew trust --help` on Homebrew 7.0.11. A throwaway
  `XDG_CONFIG_HOME` refuses an untrusted load. `brew trust --formula` loads
  only that formula, and `brew trust --tap Falconiere/tap` loads all four. The
  user's trust store is untouched.
- **Memory:** comemory MCP was unavailable and the wrapper had no hits for this repo.
- **Approach:** the spec's catalog layout. The comemory text moves under its
  own heading with its wording kept; its maintainer notes move into
  `## Maintaining this tap`.
- **Baseline:** the contract test is green on `main`. S1, S3 and S4 are red on the
  current README. S5 is already green and guards against regressions.

## Workstream summary

README rewrite → contract, quick start, follow-up commands and link checks →
repo gate and diff scope.

## Steps (machine-readable)

```json
[
  {
    "id": "S1-catalog",
    "title": "Rewrite README.md: intro, quick start, formulae table, per-formula sections, maintainer section",
    "check": "bt=$(printf '\\140'); n=0; for f in Formula/*.rb; do b=$(basename \"$f\" .rb); h=$(sed -n 's/^  homepage \"\\(.*\\)\"$/\\1/p' \"$f\"); c=$(grep -cF -- \"| [${bt}${b}${bt}](${h}) |\" README.md); [ \"$c\" = 1 ] || { echo \"AC-1: $b has $c rows\"; exit 1; }; n=$((n+1)); done; r=$(grep -cE '^[|] [[]`[a-z-]+`[]][(]https://github[.]com/' README.md); [ \"$r\" = \"$n\" ] || { echo \"AC-1: $r formula rows for $n formulae\"; exit 1; }; echo \"AC-1 ok: $n rows\" && bt=$(printf '\\140'); for f in Formula/*.rb; do b=$(basename \"$f\" .rb); grep -qE 'aarch64-unknown-linux|linux-arm64' \"$f\" && grep -qE 'x86_64-unknown-linux|linux-amd64' \"$f\" || { echo \"AC-2: $b lacks a Linux target\"; exit 1; }; if grep -qE 'x86_64-apple-darwin|darwin-amd64' \"$f\"; then want='macOS arm64/x86_64, Linux x86_64/arm64'; else want='macOS arm64, Linux x86_64/arm64'; fi; grep -F -- \"| [${bt}${b}${bt}](\" README.md | grep -qF -- \"| ${want} |\" || { echo \"AC-2: $b row lacks '$want'\"; exit 1; }; echo \"AC-2 ok: $b = $want\"; done",
    "ac_refs": [
      "AC-1",
      "AC-2"
    ],
    "paths": [
      "README.md",
      "Formula"
    ],
    "input": "Formula/*.rb homepage and url lines",
    "model": "inherit"
  },
  {
    "id": "S2-contract",
    "title": "comemory contract strings survive the rewrite",
    "check": "out=$(bash scripts/test-formula-contract.sh 2>&1) || { printf '%s\\n' \"$out\" | grep -E '^FAIL'; exit 1; }; printf '%s\\n' \"$out\" | grep -qx 'PASS README documents the Homebrew daemon lifecycle and its limitation' && printf '%s\\n' \"$out\" | tail -1 | grep -qx 'all contract cases passed' && echo 'AC-3 ok'",
    "ac_refs": [
      "AC-3"
    ],
    "depends_on": [
      "S1-catalog"
    ],
    "paths": [
      "README.md",
      "Formula/comemory.rb",
      "scripts/test-formula-contract.sh",
      "scripts/comemory_formula.rb"
    ],
    "input": "committed README + latest comemory release formula via gh"
  },
  {
    "id": "S3-quickstart",
    "title": "Quick start trusts one formula; the named --tap option trusts all; every block trusts before it installs",
    "check": "t=$(mktemp -d); trap 'rm -rf \"$t\"' EXIT; export XDG_CONFIG_HOME=\"$t\" HOMEBREW_NO_AUTO_UPDATE=1; if brew info --formula Falconiere/tap/git-better >/dev/null 2>\"$t/err\"; then echo 'AC-4: untrusted load succeeded'; exit 1; fi; grep -q 'Refusing to load formula' \"$t/err\" || { cat \"$t/err\"; exit 1; }; for l in 'brew tap Falconiere/tap' 'brew trust --formula Falconiere/tap/toolu' 'brew install Falconiere/tap/toolu'; do grep -qxF -- \"$l\" README.md || { echo \"AC-4: quick start lacks: $l\"; exit 1; }; done; grep -qF 'brew trust --tap Falconiere/tap' README.md || { echo 'AC-4: --tap option not named'; exit 1; }; brew trust --formula Falconiere/tap/toolu >/dev/null || { echo 'AC-4: brew trust --formula failed'; exit 1; }; brew info --formula Falconiere/tap/toolu >/dev/null || { echo 'AC-4: toolu not loadable after --formula trust'; exit 1; }; if brew info --formula Falconiere/tap/git-better >/dev/null 2>&1; then echo 'AC-4: --formula trust widened to git-better'; exit 1; fi; brew trust --tap Falconiere/tap >/dev/null || { echo 'AC-4: brew trust --tap failed'; exit 1; }; for f in Formula/*.rb; do b=$(basename \"$f\" .rb); brew info --formula \"Falconiere/tap/$b\" >/dev/null || { echo \"AC-4: $b not loadable\"; exit 1; }; done; awk '/^```/{inb=!inb; delete tr; tap=0; next} inb && /^brew trust --tap Falconiere\\/tap/{tap=1} inb && /^brew trust --formula Falconiere\\/tap\\//{split($4,p,\"/\"); tr[p[3]]=1} inb && /^brew install Falconiere\\/tap\\//{split($3,p,\"/\"); if(!tap && !(p[3] in tr)){print \"AC-4: install before trust: \" $0; bad=1}} END{exit bad}' README.md && echo 'AC-4 ok'",
    "ac_refs": [
      "AC-4"
    ],
    "depends_on": [
      "S1-catalog"
    ],
    "paths": [
      "README.md",
      "Formula"
    ],
    "input": "installed Homebrew 7.0.11, tapped falconiere/tap, throwaway XDG_CONFIG_HOME"
  },
  {
    "id": "S4-followups",
    "title": "toolu and toolu-runner sections name their post-install command",
    "check": "awk '/^## toolu$/{s=1;next} /^## /{s=0} s' README.md | grep -qF 'toolu plugins install' || { echo 'AC-5: toolu section lacks toolu plugins install'; exit 1; }; awk '/^## toolu-runner$/{s=1;next} /^## /{s=0} s' README.md | grep -qF 'toolu-runner setup' || { echo 'AC-5: toolu-runner section lacks toolu-runner setup'; exit 1; }; echo 'AC-5 ok'",
    "ac_refs": [
      "AC-5"
    ],
    "depends_on": [
      "S1-catalog"
    ],
    "paths": [
      "README.md"
    ],
    "input": "README sections; upstream READMEs as source"
  },
  {
    "id": "S5-links",
    "title": "Every URL answers 200; every in-page anchor and GitHub URL fragment resolves",
    "check": "for u in $(grep -oE 'https://[^]) >`\"]+' README.md | sort -u); do c=$(curl -sL -o /dev/null -w '%{http_code}' \"$u\"); [ \"$c\" = 200 ] || { echo \"AC-6: $u -> $c\"; exit 1; }; done; slugs=$(grep -E '^#+ ' README.md | sed -E 's/^#+ //' | tr 'A-Z' 'a-z' | sed -E 's/[^a-z0-9 _-]//g; s/ /-/g'); for a in $(grep -oE '[]][(]#[a-z0-9_-]+[)]' README.md | sed -E 's/^[]][(]#//; s/[)]$//' | sort -u); do printf '%s\\n' \"$slugs\" | grep -qx -- \"$a\" || { echo \"AC-6: missing anchor $a\"; exit 1; }; done; for u in $(grep -oE 'https://[^]) >`\"]+#[A-Za-z0-9_-]+' README.md | sort -u); do frag=${u##*#}; base=${u%%#*}; case \"$base\" in https://github.com/*/*/blob/*) raw=$(printf '%s' \"$base\" | sed -E 's#^https://github[.]com/([^/]+)/([^/]+)/blob/#https://raw.githubusercontent.com/\\1/\\2/#') ;; https://github.com/*/*) raw=$(printf '%s' \"${base%/}/HEAD/README.md\" | sed 's#^https://github[.]com/#https://raw.githubusercontent.com/#') ;; *) echo \"AC-6: cannot verify fragment on $u\"; exit 1 ;; esac; curl -fsSL \"$raw\" | grep -E '^#+ ' | sed -E 's/^#+ //' | tr 'A-Z' 'a-z' | sed -E 's/[^a-z0-9 _-]//g; s/ /-/g' | grep -qx -- \"$frag\" || { echo \"AC-6: no heading for #$frag in $raw\"; exit 1; }; done; echo 'AC-6 ok'",
    "ac_refs": [
      "AC-6"
    ],
    "depends_on": [
      "S1-catalog"
    ],
    "paths": [
      "README.md"
    ],
    "input": "live GitHub URLs in README"
  },
  {
    "id": "S6-gate",
    "title": "Repo quality gate and diff scope",
    "check": "ruby scripts/comemory_formula.rb check Formula/comemory.rb && shellcheck scripts/*.sh scripts/lib/*.sh && extra=$({ git diff --name-only main --; git ls-files --others --exclude-standard; } | grep -vxE 'README[.]md|docs/toolu/(specs/2026-10-26-readme-catalog-design|plans/2026-10-26-readme-catalog)[.]md'); [ -z \"$extra\" ] || { echo \"out of scope: $extra\"; exit 1; }; echo 'gate ok'",
    "depends_on": [
      "S2-contract",
      "S3-quickstart",
      "S4-followups",
      "S5-links"
    ],
    "paths": [
      "README.md",
      "Formula",
      "scripts",
      "docs/toolu"
    ]
  }
]
```

## Critical files

- `README.md` (rewrite)
- `docs/toolu/specs/2026-10-26-readme-catalog-design.md`
- `docs/toolu/plans/2026-10-26-readme-catalog.md`

## Verification

- End to end: every step check above passes on the committed branch, then
  `toolu ledger run docs/toolu/plans/2026-10-26-readme-catalog.md --verify`.
- Real inputs: the formula files, live Homebrew with a throwaway trust store,
  the latest comemory release formula, and live GitHub URLs.
- Failure and boundary cases: an untrusted load must be refused (S3); a missing
  needle fails the contract (S2); a formula row with no file or the wrong
  platforms fails (S1); an out-of-scope file fails the gate (S6).
- Docs: README is the deliverable; no other surface changes.
- Delivery: scoped `docs:` commit on `docs/readme-catalog`, `toolu-review:review`,
  `toolu ledger verdict status` reporting ready, push, PR against `main`, then
  `pr-babysit:babysit`. Prerequisite: an authenticated `gh` (S2 downloads the
  latest comemory release formula).

## Plan review

- S3-quickstart: 🟡 should-fix: the `brew trust` exit code was ignored. Fixed: the step now exits on failure.
- AC coverage: dangling and uncovered refs are both empty (`pl_check_ac_refs` is not installed, so an equivalent inline Ruby check ran). Dependency order is valid.
- S5-links: 🔵 consider: already green before the rewrite. Kept as a regression guard for the new links.

**Status:** Approved

## Deviations

After `/code-review high` on PR #3 (see the spec's revision section):

- S2-contract: the check no longer hard-codes `env -u GH_TOKEN`; it needs an authenticated `gh`.
- S3-quickstart: now proves the narrow `--formula` default (git-better stays refused after trusting toolu), the opt-in `--tap` path, and that every README code block trusts its formula before `brew install`. Its failure message no longer prints literal quotes. Red on the pre-fix README: `AC-4: quick start lacks: brew trust --formula Falconiere/tap/toolu`, and the block scan flags the comemory, toolu and toolu-runner install lines.
- S5-links: now also checks fragments on GitHub URLs against the target Markdown's headings. Red on a README with `#no-such-heading`.
