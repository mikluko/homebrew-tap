class HledgerCloseCta < Formula
  desc "Hledger add-on: period-end closing with currency translation adjustment"
  homepage "https://github.com/mikluko/hledger-close-cta"
  url "https://github.com/mikluko/hledger-close-cta/archive/refs/tags/v0.1.0.0.tar.gz"
  sha256 "5596022754ab6aa583d48e0075a3d29af6def3f184b9d4c1527d8b2b12441354"
  license "MIT"
  head "https://github.com/mikluko/hledger-close-cta.git", branch: "main"

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  def install
    # the freeze file pins the GHC 9.10 package set; let cabal resolve
    # against whatever GHC brew provides
    rm "cabal.project.freeze"
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    assert_match "close-cta", shell_output("#{bin}/hledger-close-cta --help")
  end
end
