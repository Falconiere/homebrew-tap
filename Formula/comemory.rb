class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.53.1"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.53.1/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "6c853c78a1c6406912a476e2dff558466df45f8977eda29e5d8f1925b9cb1ee7"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.53.1/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "1832bbce8d4cf8632f53be71faad71aeb42c83e5e3037d680a65a10fe3039336"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.53.1/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "d2387134fc47956ac6a73e1398a6d08accff4216e28d27000badea88dfcfef78"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":      {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-unknown-linux-gnu":  {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "comemory"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "comemory"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "comemory"
    end

    install_binary_aliases!

    generate_completions_from_executable(
      bin/"comemory",
      "completions",
      shells: [:bash, :zsh, :fish, :pwsh],
    )

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end

  def caveats
    <<~EOS
      comemory needs its sync daemon running, and Homebrew cannot start it:
      formula hooks run sandboxed, without access to your home directory.
      After every install, upgrade or reinstall, start and verify it with:
        #{opt_bin}/comemory sync daemon ensure
      `comemory upgrade` upgrades through Homebrew and verifies the daemon.
      Any other comemory command also restarts a missing daemon.
      Before `brew uninstall comemory`, remove the service with:
        comemory sync daemon uninstall
      This never deletes your data directory (~/.comemory by default).
    EOS
  end
end
