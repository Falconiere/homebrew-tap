class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.15.0"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.15.0/toolu-runner-darwin-arm64.tar.gz"
    sha256 "fb16f13fe9575ba4c6133fdc4e7d01f3548968c38522755b10c15c1117583feb"
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.15.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "474d98d4dc9bb5bfe374fe24ce9b937eb419298f4d66120f67c84019b455f63f"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.15.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "47f484f80b4284d6569108e51ed353d468dd0a3970425aec66d94feaa66b2af5"
    end
  end

  def install
    bin.install "toolu-runner"
    # launchd plist + systemd unit — optional, only used by --service installs.
    pkgshare.install "scripts" if File.directory?("scripts")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toolu-runner --version")
  end
end
