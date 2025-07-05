class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "176dc961af636cde024f52d10856423ca9f2e62d080300c7f393bec1824023c1"
  license "MIT"

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
