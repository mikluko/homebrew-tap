class Valiss < Formula
  desc "NATS-style tenant authentication for gRPC and HTTP: nkey credential issuer CLI"
  homepage "https://github.com/mikluko/valiss"
  url "https://github.com/mikluko/valiss/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "8066260eadfa801d52955137d553ca2fce1fe027270d0c3765cf469b6cbbdf85"
  license "MIT"
  head "https://github.com/mikluko/valiss.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  test do
    output = shell_output("#{bin}/valiss 2>&1", 2)
    assert_match "usage: valiss", output

    keys = shell_output("#{bin}/valiss keygen operator 2>/dev/null")
    assert_match(/^public: O/, keys)
    assert_match(/^seed: SO/, keys)
  end
end
