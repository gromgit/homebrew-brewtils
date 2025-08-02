class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.2.7.tar.gz"
  sha256 "15605f308ce9a5777053f3c1161fe077e9097553bb1d0d2e1b80264c03d3a6c2"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "868d57e013f09e48b34fe6a68f858fa681174828083c432b006bd260bcb161bf"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "491e40a7db18af7544daff623e233462331475be1fa269b07bdf69f76f553f29"
    sha256 cellar: :any_skip_relocation, ventura:       "0eb48920225cb22da63e66a597b0bc41d722bed5425fc1c3a7cd4c03bf60a373"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b08bf7808ed7472d145ea2eebf023f3b369e8b45318096998ec60481b42dd5f9"
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
