class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "ea355cbc1553a5e7f02fdf1e8976c44d24575d0d1b31914fb8374a5495d7e0f3"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "569493e7efab4582b76071c1dbcfdbaaf82eefbb5537712df776419102c9c53e"
    sha256 cellar: :any_skip_relocation, ventura:      "b5f7a77c179856971b97c9929e5f3abd0256a5de23c922ac78f1f1f16c769e6a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c4411ca93aff31a017f20aa0b69c37ac830805ca9c57bc06d32fd331bbb66adf"
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
    sleep 5
    input.puts "q"
    sleep 1
    input.close
    sleep 2

    assert_match "Search packages", (testpath/"output.txt").read
  end
end
