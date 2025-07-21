class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.2.4.tar.gz"
  sha256 "0ed380067007c88869911f85753b1bae529436d3f74493671e4e8030d3cf5076"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "3489a167435b704121843658dc1d388c9b2cb928fd9438fb1389bf5a44b30572"
    sha256 cellar: :any_skip_relocation, ventura:      "376518834caa4552fdc0fddea7dc8d68999984d162d889221370ac912320295f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d3dccdeecaa12c58f0ebae68ca2c707f8ee205ecd0d5de806bd040a0f3e2fa52"
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
