class Claudectx < Formula
  desc "Launch Claude Code with provider contexts, kubeconfig-style"
  homepage "https://github.com/mikluko/claudectx"
  url "https://github.com/mikluko/claudectx/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "128972ce5f10e72c7d9cb4519a7350356cf491aa00deb3bedbc7805d458480a8"
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
