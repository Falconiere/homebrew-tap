# Falconiere/tap

Homebrew formulae for Falconiere's developer tools: memory and code-quality
rules for coding agents, a token-lean git companion, and a self-hosted GitHub
Actions runner.

## Quick start

```bash
brew tap Falconiere/tap
brew trust --formula Falconiere/tap/toolu
brew install Falconiere/tap/toolu
```

Homebrew 7 will not load formulae from a third-party tap until you trust them.
`brew trust --formula` trusts one formula, so repeat it for each one you
install. `brew trust --tap Falconiere/tap` trusts every formula in this tap,
including any added later; use it only if you accept that.

## Formulae

| Formula | Command | What it does | Platforms |
| --- | --- | --- | --- |
| [`comemory`](https://github.com/Falconiere/comemory) | `comemory` | Agentic dev memory and code-aware semantic search over a two-layer property graph. Needs its sync daemon started; see [comemory](#comemory). | macOS arm64, Linux x86_64/arm64 |
| [`git-better`](https://github.com/Falconiere/git-better) | `gb` | Token-lean git companion for humans and LLM agents. | macOS arm64, Linux x86_64/arm64 |
| [`toolu`](https://github.com/Falconiere/toolu) | `toolu` | Code-quality rules for coding agents, as one native binary. Plugins install separately; see [toolu](#toolu). | macOS arm64/x86_64, Linux x86_64/arm64 |
| [`toolu-runner`](https://github.com/Falconiere/toolu-ghrunner) | `toolu-runner` | Standalone self-hosted GitHub Actions JIT runner. Needs a one-time setup; see [toolu-runner](#toolu-runner). | macOS arm64/x86_64, Linux x86_64/arm64 |

Each formula follows its project's latest release. `brew upgrade <formula>` and
`brew uninstall <formula>` work as usual; comemory adds a daemon step, below.

## comemory

comemory requires a resident sync daemon. Its managed installers start it and
verify it before they report success. Homebrew cannot do that: it runs formula
hooks sandboxed with a temporary `HOME`, and it has no uninstall hook. So on
this channel you run the daemon step yourself. The formula's caveats repeat
these commands after every install, upgrade and reinstall.

```bash
# Install, then start and verify the daemon
# (Homebrew 7 loads formulae from third-party taps only after `brew trust`)
brew tap Falconiere/tap
brew trust --formula Falconiere/tap/comemory
brew install Falconiere/tap/comemory
"$(brew --prefix)/opt/comemory/bin/comemory" sync daemon ensure

# Upgrade: runs `brew upgrade comemory`, then restarts and verifies the daemon on the new binary
comemory upgrade

# After a plain `brew upgrade` or `brew reinstall`, verify the daemon yourself
comemory sync daemon ensure

# Uninstall: remove the service first, then the formula (your data directory is kept)
comemory sync daemon uninstall
brew uninstall comemory
```

`sync daemon ensure` succeeds only once a running coordinator reports the
installed version, binary and data directory. It needs no login. Any other
comemory command also restarts a missing daemon. Your data (`~/.comemory` by
default) is never removed by these steps.

### Channel support

Homebrew does not fully support comemory's required-daemon installation:

- `brew install` and `brew upgrade` finish without starting the daemon.
- `brew uninstall` alone leaves the service definition behind.

Until that changes, only `comemory sync daemon ensure` or `comemory upgrade`
gives verified post-install readiness on this channel. The standalone installer
covers the rest of the engine's install and upgrade contract, which is described
in comemory's
[docs/scenarios/install.md](https://github.com/Falconiere/comemory/blob/main/docs/scenarios/install.md)
and
[docs/guides/upgrading.md](https://github.com/Falconiere/comemory/blob/main/docs/guides/upgrading.md).

## toolu

The formula installs the `toolu` binary. Then install its plugins into your
coding-agent hosts:

```bash
brew tap Falconiere/tap
brew trust --formula Falconiere/tap/toolu
brew install Falconiere/tap/toolu
toolu plugins install
```

Supported hosts are listed in toolu's
[docs/install.md](https://github.com/Falconiere/toolu/blob/main/docs/install.md).
Its version pinning and rollback use the curl installer, which refuses to
replace a Homebrew-installed `toolu`; on this channel, use `brew upgrade toolu`
and `brew uninstall toolu`.

## toolu-runner

The formula installs the binary only. The guided setup registers the runner,
installs its background service, and confirms the runner is online:

```bash
brew tap Falconiere/tap
brew trust --formula Falconiere/tap/toolu-runner
brew install Falconiere/tap/toolu-runner
toolu-runner setup
```

Unattended flags and service management are covered in the
[toolu-runner quick start](https://github.com/Falconiere/toolu-ghrunner#quick-start).

## Maintaining this tap

Each project's release automation normally regenerates and pushes its own
formula. When a release does not show up here, bump the formula by hand from
the same source:

- `comemory` and `git-better` come from cargo-dist.
- `toolu` and `toolu-runner` come from each stable release's `SHA256SUMS`.

cargo-dist regenerates `Formula/comemory.rb` on every comemory release. The
hand-maintained parts, shell completions and the lifecycle caveats, are owned by
`scripts/comemory_formula.rb`:

```bash
ruby scripts/comemory_formula.rb apply Formula/comemory.rb   # add them (idempotent)
ruby scripts/comemory_formula.rb check Formula/comemory.rb   # fail if either is missing
```

CI (`.github/workflows/lifecycle.yml`) runs `check` on every push, including
release pushes. It also runs real `brew install`, `reinstall`, `upgrade` and
`uninstall` on macOS (launchd) and Linux (systemd and headless) against this
tap. Those runs use `scripts/test-brew-lifecycle.sh`.

A separate `contract` job runs `scripts/test-formula-contract.sh`. Among its
checks, it greps this README for the comemory daemon commands and the
channel-support note. CI does not check the formulae table, the links or the
toolu and toolu-runner sections.
