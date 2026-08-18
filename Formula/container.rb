class Container < Formula
  desc "Create and run Linux containers using lightweight virtual machines"
  homepage "https://apple.github.io/container/documentation/"
  url "https://github.com/mikluko/container/archive/99b1fd27b9b55c7e58027071edc8868dde72ca85.tar.gz"
  version "1.2.2.99b1fd2"
  sha256 "794d50eb0f65f7c299b07d5b12095f4c28646975f6638df8846143fd09fdf724"
  license "Apache-2.0"
  head "https://github.com/mikluko/container.git", branch: "k8s-create-publish"

  depends_on xcode: ["26.0", :build]
  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    ENV["RELEASE_VERSION"] = version

    system "swift", "build", *std_swift_args

    release_dir = buildpath/".build/release"

    bin.install release_dir/"container"
    bin.install release_dir/"container-apiserver"
    libexec.install "scripts/ensure-container-stopped.sh"

    # Container requires binaries and plugins to be signed with specific entitlements
    codesign "--identifier=com.apple.container.cli", bin/"container"
    codesign "--identifier=com.apple.container.apiserver", bin/"container-apiserver"

    plugins = {
      "container-core-images"   => { source: "CoreImages",       entitlements: false },
      "container-network-vmnet" => { source: "NetworkVmnet",     entitlements: true  },
      "container-runtime-linux" => { source: "RuntimeLinux",     entitlements: true  },
      "machine-apiserver"       => { source: "MachineAPIServer", entitlements: false,
                                     resources: ["init", "create-user.sh"] },
      "k8s"                     => { source: "K8s",              entitlements: false,
                                     resources: ["kindnet.yaml"] },
    }
    plugins.each do |bin_name, opts|
      plugin_dir = libexec/"container-plugins/#{bin_name}"
      (plugin_dir/"bin").install release_dir/bin_name
      plugin_dir.install "Sources/Plugins/#{opts[:source]}/config.toml"
      opts[:resources]&.each do |resource|
        (plugin_dir/"resources").install "Sources/Plugins/#{opts[:source]}/Resources/#{resource}"
      end

      entitlement_args = []
      entitlement_args << "--entitlements=signing/#{bin_name}.entitlements" if opts[:entitlements]

      codesign "--prefix=com.apple.container.", *entitlement_args,
               plugin_dir/"bin/#{bin_name}"
    end

    generate_completions_from_executable bin/"container", "--generate-completion-script"

    # Relocate the binaries under libexec and replace them in bin with shim
    # wrappers. The CLI resolves its install root as the lexical grandparent
    # of the running executable (see Sources/ContainerPlugin/InstallRoot.swift),
    # so the binaries must live one directory below the keg root for the
    # bundled plugins under libexec/container-plugins/ to be discovered.
    # CONTAINER_INSTALL_ROOT is also exported by the wrappers for the code
    # paths that honour the environment variable.
    bin.env_script_all_files libexec, CONTAINER_INSTALL_ROOT: opt_prefix
  end

  # Signs ad-hoc by default. Set HOMEBREW_CONTAINER_SIGNING_IDENTITY to a
  # keychain identity (e.g. "Developer ID Application: ...") to sign with it
  # instead; only HOMEBREW_*-prefixed variables survive the build sandbox.
  def codesign(*args)
    identity = ENV.fetch("HOMEBREW_CONTAINER_SIGNING_IDENTITY", "-")
    system "/usr/bin/codesign", "-f", "-s", identity, *args
  end

  # container APIs aren't guaranteed to be backward compatible,
  # so we stop the system service to ensure no components are out of sync.
  # Ref: https://github.com/apple/container/issues/551#issuecomment-3246928923
  post_install_steps do
    run "ensure-container-stopped.sh", args: ["-a"], base: :libexec
  end

  service do
    run [opt_bin/"container", "system", "start"]
    keep_alive true
    working_dir var
    log_path var/"log/container.log"
    error_log_path var/"log/container.log"
  end

  test do
    # Cannot fully test, as it needs to write outside testpath
    assert_match version.to_s, shell_output("#{bin}/container --version")

    assert_match(/Error: (?:interrupted: ")?internalError: "failed to list containers"/,
                 shell_output("#{bin}/container list 2>&1", 1))
  end
end
