class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "dcfa4f5fc0fee1295c915b9ac15a240567f1aa79fd8c37b6c736e32f2730bb60"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "0cf6ef2f92428e40d4485d8cf1339e9800612cb8eabb9d7507df8c46e6e0e56c"
    sha256 cellar: :any_skip_relocation, ventura:      "6c247aee74483bcd8686acf27d4e4d4f95a3053a5f6e1c39b45aca0d0253bd39"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a2e6d2d0743aa5127cf2bdcde66e3742ae27a57c3bbf7b7840cfc82193f575e5"
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
