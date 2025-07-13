class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "bbb728da44540b87d8b4bc721489e9a83459dc7c1465f1b0b056929b91656225"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "cec1d39518e9bca64241d5b310325cba3eb5d769eccf4a2174a9b6b5ffd8c75a"
    sha256 cellar: :any_skip_relocation, ventura:      "a37c51a9d184949c33a0b91ed77b39650f78a3ac4f21419ff3d041256f40980e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "059e90e843ffac0022249000d5b9c34c90a6ed5d122716c93edc207d4c70cf1f"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    input, = Open3.popen2 "script -q output.txt"
    input.puts "stty rows 80 cols 130"
    input.puts "export TERM=vt100"
    input.puts bin/"taproom"
    sleep 15
    input.puts "q"
    sleep 1
    input.close
    sleep 2

    assert_match "Formulae analytics loaded", (testpath/"output.txt").read
  end
end
