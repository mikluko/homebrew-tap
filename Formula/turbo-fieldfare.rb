class TurboFieldfare < Formula
  desc "Gemma 4 26B-A4B inference in ~2 GB of RAM on Apple Silicon"
  homepage "https://github.com/drumih/turbo-fieldfare"
  url "https://github.com/drumih/turbo-fieldfare/archive/refs/tags/0.3.tar.gz"
  sha256 "7a2539a263e448714186e417924a5dc55cf6847a1ebb42a4a82c8d6e2dc12669"
  license "Apache-2.0"
  head "https://github.com/drumih/turbo-fieldfare.git", branch: "main"

  depends_on xcode: ["26.0", :build]
  depends_on arch: :arm64
  depends_on macos: :tahoe

  COMMANDS = {
    "TurboFieldfareCLI"    => "turbo-fieldfare",
    "TurboFieldfareServer" => "turbo-fieldfare-server",
    "TurboFieldfareRepack" => "turbo-fieldfare-repack",
  }.freeze

  APP_PRODUCTS = %w[TurboFieldfareMac TurboFieldfareDecodeService].freeze

  ICON_SIZES = [16, 32, 128, 256, 512].freeze

  # AppModelLocation falls back to Application Support once the app runs outside a
  # package checkout, so the service reads whatever the app installed
  MODEL_DIR = "Library/Application Support/TurboFieldfare/gemma4.gturbo".freeze

  def install
    (COMMANDS.keys + APP_PRODUCTS).each do |product|
      system "swift", "build", "--disable-sandbox", "-c", "release", "--product", product
    end

    build = buildpath/".build/release"
    bundles = Dir[build/"*.bundle"]

    app = buildpath/"TurboFieldfare.app"
    contents = app/"Contents"
    (contents/"MacOS").mkpath
    (contents/"Resources").mkpath

    # SwiftPM resolves `Bundle.module` against `Bundle.main.bundleURL`. That is
    # the .app itself for the bundled app, and the enclosing directory for the
    # decode service, which runs as a bare executable next to it.
    cp_r bundles, app
    cp_r bundles, contents/"MacOS"
    APP_PRODUCTS.each { |product| cp build/product, contents/"MacOS" }

    (contents/"Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key><string>TurboFieldfareMac</string>
        <key>CFBundleIdentifier</key><string>com.github.drumih.turbo-fieldfare</string>
        <key>CFBundleName</key><string>TurboFieldfare</string>
        <key>CFBundleIconFile</key><string>TurboFieldfare</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
        <key>CFBundleVersion</key><string>#{version}</string>
        <key>LSApplicationCategoryType</key><string>public.app-category.developer-tools</string>
        <key>LSMinimumSystemVersion</key><string>26.0</string>
        <key>NSHighResolutionCapable</key><true/>
      </dict>
      </plist>
    PLIST

    iconset = buildpath/"TurboFieldfare.iconset"
    iconset.mkpath
    icon = buildpath/"Sources/TurboFieldfareApp/Mac/Resources/turbofieldfare-app-icon.png"
    ICON_SIZES.each do |size|
      system "sips", "-z", size.to_s, size.to_s, icon,
             "--out", iconset/"icon_#{size}x#{size}.png"
      system "sips", "-z", (size * 2).to_s, (size * 2).to_s, icon,
             "--out", iconset/"icon_#{size}x#{size}@2x.png"
    end
    system "iconutil", "-c", "icns", iconset,
           "-o", contents/"Resources/TurboFieldfare.icns"

    prefix.install app

    # exec scripts, not symlinks: `Bundle.module` has to resolve against libexec
    libexec.install bundles
    COMMANDS.each do |product, command|
      libexec.install build/product => command
      bin.write_exec_script libexec/command
    end

    # launchd expands nothing in ProgramArguments and the server reads no
    # environment, so the service goes through a shim that builds the argv
    (libexec/"turbo-fieldfare-service").write <<~SH
      #!/bin/bash
      set -euo pipefail

      config="#{etc}/turbo-fieldfare/server.env"
      if [ -r "$config" ]; then
        . "$config"
      fi

      exec "#{opt_libexec}/turbo-fieldfare-server" \\
        --model "${TURBO_FIELDFARE_MODEL:-$HOME/#{MODEL_DIR}}" \\
        --port "${TURBO_FIELDFARE_PORT:-8080}"
    SH
    chmod 0755, libexec/"turbo-fieldfare-service"

    (etc/"turbo-fieldfare").mkpath
    server_env = etc/"turbo-fieldfare/server.env"
    server_env.write(<<~ENV) unless server_env.exist?
      # Read by `brew services start turbo-fieldfare`; restart to apply changes.
      # TURBO_FIELDFARE_PORT=8080
      # TURBO_FIELDFARE_MODEL=$HOME/#{MODEL_DIR}
    ENV

    (var/"log").mkpath
  end

  service do
    run opt_libexec/"turbo-fieldfare-service"
    keep_alive crashed: true
    log_path var/"log/turbo-fieldfare-server.log"
    error_log_path var/"log/turbo-fieldfare-server.log"
  end

  def caveats
    <<~EOS
      The Mac app is installed outside /Applications. Link it there with:
        ln -sfn #{opt_prefix}/TurboFieldfare.app /Applications/TurboFieldfare.app

      Model weights are not included (~14.3 GB). The app installs them on first run,
      and the service reads the same directory, so one copy serves both. To install
      them without the app:
        turbo-fieldfare-repack --output ~/"#{MODEL_DIR}"

      The command-line tools take no default; pass that path to --model yourself.

      `brew services start turbo-fieldfare` then serves that model on
      http://127.0.0.1:8080/v1, with no authentication or TLS. Port and model path
      are read from this file at every start:
        #{etc}/turbo-fieldfare/server.env

      If another process already holds the port, the server cannot bind and exits,
      and launchd keeps retrying quietly, so a service that never comes up means
      reading:
        #{var}/log/turbo-fieldfare-server.log

      Run only one of the app, the CLI, and the service at a time. Each one loads
      the model and takes the Metal device for itself.

      The app bundle is unsigned. SwiftPM requires its resource bundles in the
      .app root, which codesign rejects as unsealed content.
    EOS
  end

  test do
    assert_match "--messages-file", shell_output("#{bin}/turbo-fieldfare --help")
    assert_match "--prompt-cache-mode", shell_output("#{bin}/turbo-fieldfare-server --help")
    assert_match "--verify-install", shell_output("#{bin}/turbo-fieldfare-repack --help")

    assert_match "--port \"${TURBO_FIELDFARE_PORT:-8080}\"",
                 (libexec/"turbo-fieldfare-service").read

    app = prefix/"TurboFieldfare.app"
    assert_path_exists app/"Contents/MacOS/TurboFieldfareDecodeService"
    assert_path_exists app/"Contents/MacOS/TurboFieldfare_TurboFieldfare.bundle"
    assert_path_exists app/"TurboFieldfare_TurboFieldfareMac.bundle"
  end
end
