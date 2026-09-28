# homebrew-tap

Homebrew tap for Falconiere projects.

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

### Maintaining the formula

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
