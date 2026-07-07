class HledgerFmt < Formula
  desc "Hledger add-on: format-preserving journal formatter"
  homepage "https://github.com/mikluko/hledger-fmt"
  url "https://github.com/mikluko/hledger-fmt/archive/refs/tags/v0.2.0.0.tar.gz"
  sha256 "195e9e5c4c2833e592f36ded3b50dad955bfd2663b91833440ca9c3905bf74b2"
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
