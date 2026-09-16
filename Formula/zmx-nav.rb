class ZmxNav < Formula
  desc "Session navigation for zmx: pick a running session, or start one in a repo"
  homepage "https://github.com/mikluko/zmx-nav"
  url "https://github.com/mikluko/zmx-nav/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b4c369a6aa910a03427d537dc441b343ee76fc46007941c727c58a0a784acbf0"
  license "MIT"
  head "https://github.com/mikluko/zmx-nav.git", branch: "main"

  depends_on "go" => :build

  # Runtime, not declared as dependencies: zmx is what this navigates and fzf
  # is the picker, but both are useful to install by hand and neither is
  # needed to build.

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zmx-nav version")

    # `pick --render` is the picker's own reload target: it prints the lines
    # rather than presenting them, so it needs neither a TTY nor fzf.
    shell_output("#{bin}/zmx-nav pick --render repo")

    assert_match "unknown grouping", shell_output("#{bin}/zmx-nav pick --render nope 2>&1", 1)

    # `new` resolves its targets before it reaches fzf, so an empty root is
    # refused without a TTY.
    (testpath/"forge").mkpath
    assert_match "no repositories below",
                 shell_output("#{bin}/zmx-nav new --root #{testpath}/forge 2>&1", 1)
  end
end
