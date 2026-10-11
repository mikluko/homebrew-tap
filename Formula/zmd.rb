class Zmd < Formula
  desc "Session picker for zmx: start one in a checkout, or attach a running one"
  homepage "https://github.com/mikluko/zmd"
  url "https://github.com/mikluko/zmd/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "68966156b19d912e692f1e03109dca46189b1c44b8c649f3816cfb86bcb0c638"
  license "MIT"
  head "https://github.com/mikluko/zmd.git", branch: "main"

  depends_on "go" => :build

  # zmx is what this picks among, but it is not declared: it is installed by
  # hand and not needed to build.

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zmd version")
  end
end
