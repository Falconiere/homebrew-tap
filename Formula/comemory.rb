class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.8.0"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.8.0/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "40ac86a56b96eb52ac002adea24d2ba9e616e26f5befd9a9b2fd82987b0fd020"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.8.0/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "1b7337a7e4072d1145d91955ee38902cbde36b7917d3bf691ed08a1ce5c8090e"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.8.0/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "83c8444f19738837a17e83e1f23325f5aafac8564f0d9ec1f4cf7998dbf00bb1"
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
    bin.install "comemory" if OS.mac? && Hardware::CPU.arm?
    bin.install "comemory" if OS.linux? && Hardware::CPU.arm?
    bin.install "comemory" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
