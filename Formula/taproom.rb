class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.2.3.tar.gz"
  sha256 "a1dba31ea80be49666bcf271cbc5e94581f537f0ca33586cf92378acbdd27e31"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "609df58583500d7aec761e16cdad75dbe32a9ac6fb440396665ed52643f43f37"
    sha256 cellar: :any_skip_relocation, ventura:      "0f750c40708e6d2306d4a61be85ef2b9d73c86dc3cf9c9199938515a6b627f1b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "045fda8c9e46e9d641d3b85a54d6b4b2503670225b9fc31b26ae27da45888ba2"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    input, = Open3.popen2 "script -q output.txt"
    input.puts "stty rows 80 cols 130"
    input.puts "export TERM=vt100"
    input.puts "#{bin}/taproom --hide-columns Size"
    sleep 15
    input.puts "q"
    sleep 1
    input.close
    sleep 2

    assert_match "Loading Formulae analytics", (testpath/"output.txt").read
  end
end
