class HledgerFmt < Formula
  desc "Hledger add-on: format-preserving journal formatter"
  homepage "https://github.com/mikluko/hledger-fmt"
  url "https://github.com/mikluko/hledger-fmt/archive/refs/tags/v0.1.0.2.tar.gz"
  sha256 "32baca70cd2ced736828f19dd2529ab17818288e3e46d3c112431af408ce2c82"
  license "MIT"
  head "https://github.com/mikluko/hledger-fmt.git", branch: "main"

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    input = "2020-01-01 x\n  a  1 USD\n  b\n"
    assert_equal <<~LEDGER, pipe_output("#{bin}/hledger-fmt -", input)
      2020-01-01 x
          a  1 USD
          b
    LEDGER
  end
end
