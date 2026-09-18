class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.35.1"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.35.1/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "f3a6c24de9f2a2f0440716d32ac6187e0d88449d44cb7134ac7e5720c7a45937"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.35.1/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "784e2ed332ed91eb6712c3b5c66d8668c5ffed46e2191b5452cb36d5633ab405"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.35.1/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "7d4edf3b25326cb634e0cc3e2e887429f06788abe595577113a0480f6336149f"
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
