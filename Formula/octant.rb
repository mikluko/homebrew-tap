class Octant < Formula
  desc "Wayfinder-compatible issue tracker serving MCP over loopback HTTP"
  homepage "https://github.com/mikluko/octant"
  # the repo is private, so both specs are git+SSH: the clone happens before
  # brew's build sandbox and goes through the 1Password agent, which is what
  # keeps a brew-specific credential from existing anywhere. It has to be the
  # ssh:// URI and not git@host:path — Homebrew picks the download strategy by
  # parsing the URL, and scp-style syntax is not a URI, so it lands on curl.
  url "ssh://git@github.com/mikluko/octant.git", tag: "0.1"
  head "ssh://git@github.com/mikluko/octant.git", branch: "main"

  depends_on "go" => :build

  def install
    # the pure-Go SQLite driver is the whole reason cgo can be off, and off is
    # what makes the binary answer to nothing outside the prefix
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"octant", "serve"]
    # not `crashed: true`: an exit(1) from a failed migration or an occupied
    # port is not a crash, and under `crashed:` it would leave the daemon
    # silently down with every agent getting connection refused and nothing
    # saying why. This turns the same failure into a throttled respawn loop
    # that writes the reason each time.
    keep_alive successful_exit: false
    log_path var/"log/octant.log"
    error_log_path var/"log/octant.err"
  end

  def caveats
    <<~EOS
      The daemon serves MCP at http://127.0.0.1:9876/mcp, loopback only, no auth:
        brew services start octant

      Its database and the snapshots it writes daily are the only user-scoped
      state, and nothing in the prefix is precious:
        ~/.local/share/octant/octant.db
        ~/.local/share/octant/backups/
        #{var}/log/octant.log, #{var}/log/octant.err

      Restore is gunzip and nothing else:
        gunzip -c ~/.local/share/octant/backups/octant-YYYY-MM-DD.db.gz \\
          > ~/.local/share/octant/octant.db

      There is no config file. Persistent overrides of OCTANT_ADDR, OCTANT_DB and
      OCTANT_LOG_LEVEL go in ~/.homebrew/services/octant.env, one KEY=value per
      line, applied on the next `brew services restart octant`.

      `brew upgrade` does not restart services and a running process keeps its
      inode, so an upgrade needs:
        brew services restart octant
    EOS
  end

  test do
    assert_match "usage: octant serve", shell_output("#{bin}/octant 2>&1", 1)

    port = free_port
    snapshots = testpath/"backups"
    pid = spawn bin/"octant", "serve", "--addr", "127.0.0.1:#{port}",
                "--db", testpath/"octant.db"
    begin
      # a snapshot lands at startup rather than a day in, so its arrival is also
      # the signal that the daemon finished opening the database
      50.times do
        break if Dir[snapshots/"octant-*.db.gz"].any?

        sleep 0.2
      end
      assert_equal 1, Dir[snapshots/"octant-*.db.gz"].length

      # stateless streamable HTTP answers POST only, so a GET proving the route
      # is served comes back 405 rather than 404
      assert_match "405 Method Not Allowed",
                   shell_output("curl -s -i http://127.0.0.1:#{port}/mcp")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
