cask "zenterm" do
  version "1.3.0"
  sha256 "790f48f2bb577c4e7e140a47eb4aa5a8156a203fd18af934c0e22baa3eef7c07"

  url "https://github.com/praxis-labs-io/zen-term/releases/download/v#{version}/ZenTerm-#{version}-arm64.dmg"
  name "ZenTerm"
  desc "Terminal with panes, drawers and tool floats, on a libghostty core"
  homepage "https://zenterm.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "ZenTerm.app"

  zap trash: [
    "~/.config/zen-term",
    "~/Library/Caches/com.drucial.ZenTerm",
    "~/Library/HTTPStorages/com.drucial.ZenTerm",
    "~/Library/Preferences/com.drucial.ZenTerm.plist",
    "~/Library/Saved Application State/com.drucial.ZenTerm.savedState",
  ]
end
