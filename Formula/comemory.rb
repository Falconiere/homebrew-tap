class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.8.3"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.8.3/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "791cd8d75eb3d49a9ea04c446365a40437633b7f381b4149e08c6756eaed711e"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.8.3/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "edc112d2af22cc81e18ef0a24d7f3cde1dd9d1e7e26897a4f0f3f2e2f56756b7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.8.3/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "c5b446f408ae24f7348607aeda3fd41e4ccd89282e10a63622bd4b5de9b235ea"
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
