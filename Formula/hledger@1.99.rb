class HledgerAT199 < Formula
  desc "Easy plain text accounting with command-line, terminal and web UIs"
  homepage "https://hledger.org/"
  url "https://github.com/hledgerorg/hledger/archive/refs/tags/1.99.5.tar.gz"
  sha256 "f30ce299f709039ec68c3b0b43b4db70b4e6f872207dae42fcd8ffccf96884d3"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://github.com/hledgerorg/hledger.git"
    regex(/^v?(1\.99(?:\.\d+)+)$/i)
    strategy :git
  end

  keg_only :versioned_formula

  depends_on "ghc" => :build
  depends_on "haskell-stack" => :build
  depends_on "pkgconf" => :build
  depends_on "gmp"
  depends_on "libyaml"

  uses_from_macos "libffi"
  uses_from_macos "ncurses"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      --flag=libyaml:system-libyaml
      --jobs=#{ENV.make_jobs}
      --local-bin-path=#{bin}
      --no-install-ghc
      --skip-ghc-check
      --system-ghc
    ]
    if OS.linux?
      args << "--ghc-options=-pie"

      # Using global configuration to apply options to all dependencies.
      # -split-sections helps reduce installation size by over 50%.
      Pathname("#{Dir.home}/.stack/config.yaml").write <<~YAML
        ghc-options:
          "$everything": -split-sections -fPIC -fexternal-dynamic-refs
      YAML
    end

    # Let `stack` handle its own parallelization
    ENV.deparallelize { system "stack", "install", *args }

    # Strip binaries to reduce size by ~100MB (~25%) on macOS. This has no impact on Linux. Also done upstream:
    # https://github.com/hledgerorg/hledger/blob/hledger-1.52.1/.github/workflows/binaries-mac-arm64.yml#L156-L158
    system "strip", *bin.children if OS.mac?

    man1.install Utils::Gzip.compress(*Dir["hledger*/*.1"])
    info.install Utils::Gzip.compress(*Dir["hledger*/*.info"])
    bash_completion.install "hledger/shell-completion/hledger-completion.bash" => "hledger"
  end

  test do
    system bin/"hledger", "test"
    system bin/"hledger-ui", "--version"
    system bin/"hledger-web", "--test"
  end
end
