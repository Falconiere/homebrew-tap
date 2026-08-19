class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.9.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "50bff2d9ea136e50385ee23bd49eb0a322f9d334eaa21f96ff82984787157bff"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "3cd4c119869265669a8c7d37f0cf3f264b876021aec6055260e35bce1df3ff2e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "5e6ead46226c9a842a83c6d585cb145224af498eae1820e51441e4d49bda8a2f"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "b4dd3eb2f10dccb65f9a8187207477dddedbc222bc97ff8071b71b63b4238df5"
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
