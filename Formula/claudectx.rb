class Claudectx < Formula
  desc "Launch Claude Code with provider contexts, kubeconfig-style"
  homepage "https://github.com/mikluko/claudectx"
  url "https://github.com/mikluko/claudectx/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "6016864a2027c5dd2e23da3f33f0644ec7a768f2497f787f669e74450c841d89"
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
