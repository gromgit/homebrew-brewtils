class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.2.6.tar.gz"
  sha256 "afe0f2ad6daad9454149ac250d4efdc9de31da177e06222d411c4c4e29ee1dd0"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "3bea08e7b3a3edb09cd43f0e6912deba5d603a5445628573c9695c52198c549a"
    sha256 cellar: :any_skip_relocation, ventura:      "eaf22aeca3003cee177b9b66d9f6948fc69a0a3f2bac3bc764378dfc865060dd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c308f6cba7331941a8fac024b6e902f3cef289cb2de68fcc55d5ccf91515b98d"
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
