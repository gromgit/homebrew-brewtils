class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "b64693641a4b3ad49f21a0177cfbdb04a636811bd72f85c59e380e7385dd62ea"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "752c319ac1d13839733d3d699f6cdfe84a84d31a50bd1dffc4a028b84a1f401f"
    sha256 cellar: :any_skip_relocation, ventura:      "6f352ded56a3167c98ffd4fe2353b59c1876aa6f3697531a3e3b04a0812006f3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0cf5f03ceadd14114c42ab8d8b09ae93ac7d463ec30afbf1f78c76715ef95fe5"
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
