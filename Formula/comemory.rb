class Comemory < Formula
  desc "Agentic dev memory + code-aware semantic search via a two-layer property graph."
  homepage "https://github.com/Falconiere/comemory"
  version "0.49.1"
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/Falconiere/comemory/releases/download/v0.49.1/comemory-aarch64-apple-darwin.tar.xz"
    sha256 "b0bd56be618190368e8fa4d86cc94b1879fa4ef94d19ad8b5d2731f3a619da41"
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/Falconiere/comemory/releases/download/v0.49.1/comemory-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "e30b681dc0bdc5854b393f595bd9830c1a3fd66701dc463c16cb3cf68d983fbd"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Falconiere/comemory/releases/download/v0.49.1/comemory-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "0409870bb7edf064e4f0a598cd4745f0f09e5527c282e68f443718b1cf9f06bd"
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
end
