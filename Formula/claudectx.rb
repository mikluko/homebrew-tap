class Claudectx < Formula
  desc "Launch Claude Code with provider contexts, kubeconfig-style"
  homepage "https://github.com/mikluko/claudectx"
  url "https://github.com/mikluko/claudectx/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "09e6434fc7a07c77e03a9b774a238f3e804df67e70b8415c7bc3131086959b60"
  license "MIT"
  head "https://github.com/mikluko/claudectx.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=v#{version}"), "."
  end

  test do
    assert_match "claudectx", shell_output("#{bin}/claudectx --help")
  end
end
