class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "10.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.3.0/toolu-darwin-arm64.tar.gz"
      sha256 "244d2d317091a8f575923eefe50aad506989ac768c6a0b6acc195080f46e9bd6"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.3.0/toolu-darwin-amd64.tar.gz"
      sha256 "d9212063758679270162a09bf5ec017b8605dc1a357f7acfa8ca07410019d188"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.3.0/toolu-linux-arm64.tar.gz"
      sha256 "fdcc99df5f8f28c6b54b168f44b280907132b8d4126253de4380e2bf68bb1a4e"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.3.0/toolu-linux-amd64.tar.gz"
      sha256 "dd70c938c98a5524da5ff6fe2afcc5ef9105dd448fd9ffbebe08eaf61fe722fa"
    end
  end

  def install
    bin.install "toolu"
    generate_completions_from_executable(bin/"toolu", "completions")
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
