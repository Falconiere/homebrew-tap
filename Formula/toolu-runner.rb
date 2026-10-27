class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.14.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.14.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "903a18887fb9c5821034be40a2401338bdb257dd1fe29840b143c290df18006f"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.14.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "370d0d7ff5cd96f6ac705c1d785306c2635a11441709639c0c5fd233a3057b8c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.14.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "00e129db25a46e9150c1ff046e19ad6fd8802f341a49fa62c4050b61f162e816"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.14.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "210c2d66c23fef47a5638dfdec20f4e8a9b33d13c68b7190e3134e604429d744"
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
