class Herdr < Formula
  desc "Agent multiplexer that lives in your terminal, with ui.pane_focus_anchor"
  homepage "https://github.com/mikluko/herdr"
  url "https://github.com/mikluko/herdr/archive/refs/tags/v0.9.0-mikluko.1.tar.gz"
  # Homebrew reads "1" out of that tag on its own, so the version is spelled out.
  version "0.9.0-mikluko.1"
  sha256 "5128eec6a1cb0cbfd54e74807c7bc85ff35cb8a5df3eb5b9c7a04b8c6655b1e9"
  license "Apache-2.0"
  head "https://github.com/mikluko/herdr.git", branch: "pane-focus-anchor"

  depends_on "rust" => :build
  # the vendored libghostty-vt pins minimum_zig_version 0.16.0 and build.rs
  # rejects anything else; homebrew-core still builds upstream with zig@0.15.
  # When homebrew-core's zig moves past 0.16 this needs a zig@0.16 formula.
  depends_on "zig" => :build

  def install
    # build_info derives the reported version from these two; without them the
    # binary calls itself 0.9.0 and is indistinguishable from upstream stable.
    ENV["HERDR_BUILD_CHANNEL"] = "mikluko"
    ENV["HERDR_BUILD_ID"] = version.to_s.split(".").last

    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"herdr", "completion")
  end

  service do
    run [opt_bin/"herdr", "server"]
    keep_alive true
    log_path var/"log/herdr.log"
    error_log_path var/"log/herdr.log"
  end

  def caveats
    <<~EOS
      This replaces homebrew-core's herdr; the two cannot be installed together.
      The built-in update check still compares against upstream stable, so
      `herdr update` will point at homebrew-core once upstream passes 0.9.0.
      Upgrades of this build come through `brew upgrade herdr` only.
    EOS
  end

  test do
    assert_match "herdr #{version}", shell_output("#{bin}/herdr --version")
    assert_match "pane_focus_anchor", shell_output("#{bin}/herdr --default-config")
  end
end
