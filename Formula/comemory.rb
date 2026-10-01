class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.55.0"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.55.0/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "27b4ecdf12dd93013963ae3598f92550e052019a64205870a93049588c943ac3"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.55.0/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "d26b5ad9bcee94c3cf1bef89ffe4983c4de261d4e98757fbca0f25970ef65881"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.55.0/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "bccfec6a50be5be34392da381b9e793153b7b592dc6995d05bf3425629bc8886"
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
