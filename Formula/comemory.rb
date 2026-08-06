class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.14.2"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.14.2/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "05f0573bf304c10f5ced87bacdc5a9753124ec8e13f08d60349f30d23426ec45"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.14.2/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "74c859ffe7349e78244195e3a963e397881ed9e8efefa142edcb6bc9bd17e238"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.14.2/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "4565a149a5c27b1ec1bc73d0138f1b8472e7522d927eff5182b314fc7385e69f"
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
