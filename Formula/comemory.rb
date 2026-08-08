class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.16.0"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.16.0/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "a39c2809807f3ea6e03cda127af2065d9211c44240a9066f3f1167156eabbe95"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.16.0/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "3ab68a420a55d662de3772a2a708048d8d2b6bfbb7aa2dd0298deadf4057ef0b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.16.0/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "e8be7745b2d6eec217fdc1d4df1ff6d84bc3cb5c66369c290bc1743cbdcdca29"
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
