class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "a91a1f5afae35d3043295128f237603e3a2fad8b1897f06fa9515b1fd23ec28a"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "e95ae9fbf8d67c8c7af43b9d113298d0b2c109e3e9958c4b58851b99ad7837f0"
    sha256 cellar: :any_skip_relocation, ventura:      "3edc37051eec9a515a9c0870726af16d5e40fe60b093f9f75bafbf5be41d6836"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d95826437e07d0d7696d5f877b1366128b3528cc51a030b4873442492f89fa75"
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
