# Homebrew cask for Corvane (macOS and Linux). Lives in the
# `wasi-master/homebrew-corvene` tap as `Casks/corvane.rb`.
# `packaging/homebrew/stamp.py` rewrites `version` and the `sha256` values
# (`packaging/release.sh` for macOS, release.yml's `cask` job for Linux).
#
#   brew install --cask wasi-master/corvane/corvane
#
# macOS: the bundle is self-signed (no Apple Developer ID), so Gatekeeper
# blocks a quarantined copy on first launch. Homebrew 7 removed
# `--no-quarantine` and always quarantines cask downloads, so
# `postflight_steps` clears the attribute.
# Linux: the release's AppImage goes to `~/Applications/Corvane.AppImage`.
cask "corvane" do
  # only the Linux assets are per architecture (the macOS zip is universal)
  arch arm: "aarch64", intel: "x86_64"

  version "0.1.0"
  # the macOS zip is one universal build: `arm` and `intel` are the same file
  sha256 arm:          "35860ca05e5d373a4490347cb8e6cc779dfbc7a61f2b290bf295420f455b047a",
         intel:        "35860ca05e5d373a4490347cb8e6cc779dfbc7a61f2b290bf295420f455b047a",
         arm64_linux:  "1f6d6a1be479bca24390291bb14793513bf4d499c7dd7d7e096c487280301ec8",
         x86_64_linux: "a0fabdee3b65e321a61d9c45730691117a9c37beda33f983e48ce1ef419b0ae6"

  on_macos do
    url "https://github.com/wasi-master/corvene/releases/download/v#{version}/Corvane-#{version}-macos-universal.zip"

    depends_on macos: :sequoia

    app "Corvane.app"
    # `corvane [open] [path]` / `corvane clone <url>` (Install Command Line Tool… does the same by hand)
    binary "#{appdir}/Corvane.app/Contents/Resources/corvane"

    postflight_steps do
      run "/usr/bin/xattr",
          args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Corvane.app"],
          writable_paths: ["Corvane.app"],
          writable_base:  :appdir
    end

    zap trash: [
      "~/Library/Application Support/Corvane",
      "~/Library/Caches/Corvane",
      "~/Library/Logs/Corvane",
      "~/Library/Preferences/com.wasimaster.corvane.plist",
      "~/Library/Saved Application State/com.wasimaster.corvane.savedState",
    ]
  end
  on_linux do
    url "https://github.com/wasi-master/corvene/releases/download/v#{version}/Corvane-#{version}-#{arch}.AppImage"

    # a fixed name: the updater knows the cask's image by its folder, and the
    # command line tool's link keeps pointing at it across upgrades
    app_image "Corvane-#{version}-#{arch}.AppImage", target: "Corvane.AppImage"

    # the launcher entry and icons Corvane writes for itself at first run
    # are left to `zap`: an `uninstall` would also remove them on every
    # upgrade, and the entry's `TryExec` hides it once the image is gone
    zap trash: [
      "~/.cache/corvane",
      "~/.local/share/applications/com.wasimaster.corvane.desktop",
      "~/.local/share/corvane",
      "~/.local/share/icons/hicolor/256x256/apps/com.wasimaster.corvane.png",
      "~/.local/share/icons/hicolor/scalable/apps/com.wasimaster.corvane.svg",
      "~/.local/state/corvane",
    ]
  end

  name "Corvane"
  desc "Native GitHub Desktop clone in Rust (GPUI + gitoxide)"
  homepage "https://github.com/wasi-master/corvene"

  livecheck do
    url :url
    strategy :github_latest
  end

  caveats <<~EOS
    Updates for this install come from `brew upgrade corvane`; the in-app
    updater only points there.

    macOS: Corvane is self-signed; this cask clears its quarantine attribute
    so Gatekeeper lets it launch.

    Linux: the app is ~/Applications/Corvane.AppImage. Run it once and it
    adds itself to the application menu (~/.local/share/applications). It
    needs a Vulkan driver, a Secret Service keyring and git 2.40 or newer.
    File > Install Command Line Tool links `corvane` into ~/.local/bin.
  EOS
end
