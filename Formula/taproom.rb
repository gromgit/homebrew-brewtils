class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "b64693641a4b3ad49f21a0177cfbdb04a636811bd72f85c59e380e7385dd62ea"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "1ed3368bd55fae0029e50c8703eca603ef47c289ec2ef334d02d2b0a5efb2779"
    sha256 cellar: :any_skip_relocation, ventura:      "3daaf224144591a08c424a85e69ff353c7f9f4b7764eb5190ccc0cce7446c2d5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ce37288c4b8219627ab9e0e010ae84467c5a3401b35cbc00e484d03c84be321e"
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
