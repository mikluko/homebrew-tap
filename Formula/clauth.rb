class Clauth < Formula
  desc "Multi-account manager and usage monitor for Claude Code, with CLI, TUI and MCP"
  homepage "https://github.com/uwuclxdy/clauth"
  url "https://github.com/uwuclxdy/clauth/archive/refs/tags/v0.15.2.tar.gz"
  sha256 "5bcf117631d38b7b496c9d8af4bcfc31b3ff824500f9cb62bfa5a954bb810603"
  license "MIT"
  head "https://github.com/uwuclxdy/clauth.git", branch: "mommy"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(root: libexec)

    # The TUI checks GitHub for a newer release and, finding one, overwrites its
    # own executable through self-replace; upstream exempts only ~/.cargo/bin.
    # A keg is writable, so it would swap the binary brew believes it installed.
    # First launch also offers to append a completions source line to a shell
    # rc, which the scripts installed below make redundant.
    (bin/"clauth").write_env_script libexec/"bin/clauth",
                                    CLAUTH_NO_UPDATE:      "1",
                                    CLAUTH_NO_COMPLETIONS: "1"

    generate_completions_from_executable(libexec/"bin/clauth", "completions",
                                         shell_parameter_format: "")
  end

  def caveats
    <<~EOS
      Self-update is off: `brew upgrade clauth` is the upgrade path. The TUI
      still reports a newer release when it sees one.

      Accounts, tokens and settings are user-scoped and survive uninstall:
        ~/.clauth/

      Launching an account needs `claude` on PATH; clauth does not install it.
    EOS
  end

  test do
    # Everything here runs the wrapper, so an env script that fails to exec
    # fails the test rather than the user's first launch.
    assert_match "clauth #{version}", shell_output("#{bin}/clauth --version")

    # An empty register is a clean exit with an empty profile list, and reaching
    # that answer means the config layer ran rather than clap alone. Nothing is
    # configured to poll, so this stays offline.
    status = JSON.parse(shell_output("#{bin}/clauth status --json"))
    assert_empty status["profiles"]

    assert_match "_clauth", shell_output("#{bin}/clauth completions bash")
  end
end
