class GitBetter < Formula
  desc "Token-lean git companion for humans and LLM agents"
  homepage "https://github.com/Falconiere/git-better"
  version "1.0.2"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/git-better/releases/download/v1.0.2/git-better-aarch64-apple-darwin.tar.xz"
    sha256 "1de4468543ef52fd6936522262a84b6e77905846da69bde7c3fdb473fceccf20"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/git-better/releases/download/v1.0.2/git-better-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "d12f0250ecb825ba835a71bac1a8493325b1684179d72dd5872666e507cc1da5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/git-better/releases/download/v1.0.2/git-better-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "1280a101781fc778d5f9873af46e0de7238f757fe8e47ed01f141cccf56364b2"
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
    bin.install "gb" if OS.mac? && Hardware::CPU.arm?
    bin.install "gb" if OS.linux? && Hardware::CPU.arm?
    bin.install "gb" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
