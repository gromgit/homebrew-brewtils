class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "176dc961af636cde024f52d10856423ca9f2e62d080300c7f393bec1824023c1"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "1cec921e495133579524f8eade2df34b16d1741a48ba732e1b20833ec8987102"
    sha256 cellar: :any_skip_relocation, ventura:      "9cf9dce908d5368c3c65bd581b343fe2f3578840e0212e6c21156c98007f3918"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "978d45ee223bf4b6394b71dc1763410c22262bed8ac55fba3a3a2d0573d0e611"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    input, = Open3.popen2 "script -q output.txt"
    input.puts "stty rows 80 cols 130"
    input.puts bin/"taproom"
    sleep 5
    input.puts "q"
    sleep 1
    input.close
    sleep 2

    assert_match "Search packages", (testpath/"output.txt").read
  end
end
