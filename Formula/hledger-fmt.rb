class HledgerFmt < Formula
  desc "Hledger add-on: format-preserving journal formatter"
  homepage "https://github.com/mikluko/hledger-fmt"
  url "https://github.com/mikluko/hledger-fmt/archive/refs/tags/v0.2.1.0.tar.gz"
  sha256 "2724bf4b3edae648f7bb05a7408c5060ee8556df9189c0b0d6574f53a5dbd12f"
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
