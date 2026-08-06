class GitBetter < Formula
  desc "Token-lean git companion for humans and LLM agents"
  homepage "https://github.com/Falconiere/git-better"
  version "1.0.0"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/git-better/releases/download/v1.0.0/git-better-aarch64-apple-darwin.tar.xz"
    sha256 "8dae72cc9e30aae1bb860245b0e08a79140ef51a79532662b3ad210da61b8149"
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
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
    bin.install "gb" if OS.mac? && Hardware::CPU.arm?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
