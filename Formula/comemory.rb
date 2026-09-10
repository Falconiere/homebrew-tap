class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.26.0"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.26.0/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "edb18cc50f8a7b5ed797bf46bc2f0ca7aae85f568389489f16087a2d8e9af9f8"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.26.0/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "f6bae2bb1fe2f1d4cbae154fa83178c85531e9542a7d2fbb7e6b942de3f9751f"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.26.0/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "b1c08312b4702ac0bce573d48b110e003c6ad69ee24bf40026e49cdcb9cf2425"
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

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
