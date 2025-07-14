class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "189bb35929a306664fa4ac8cafcec5d7fc24a8e9ffaff220b41b9d2beca7ba07"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "2717805a6da919a6935dddd4e743349c52eeed6b8ea280ede4b0f959cbda5f53"
    sha256 cellar: :any_skip_relocation, ventura:      "b53f57d353c0998dc90378420340e1f8d97d539c84a23c0f83813836928dae4b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "567d50815117937fc9980879d245728e1bbd67e421a78eff06994914e3e0cda7"
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
