class Claudectx < Formula
  desc "Launch Claude Code with provider contexts, kubeconfig-style"
  homepage "https://github.com/mikluko/claudectx"
  url "https://github.com/mikluko/claudectx/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "651a4805b2f660a7e0fe736154aa66f6eed93b466c5eea78b5c188a2269caa53"
  license "MIT"
  head "https://github.com/mikluko/claudectx.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  test do
    assert_match "claudectx", shell_output("#{bin}/claudectx --help")
  end
end
