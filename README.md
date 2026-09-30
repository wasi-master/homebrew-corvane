# homebrew-corvane

[Homebrew](https://brew.sh/) tap for [Corvane](https://github.com/wasi-master/corvane), a native
[GitHub Desktop](https://github.com/apps/desktop) clone for macOS.

## Install

```bash
brew install --cask wasi-master/corvane/corvane
```

This also puts a `corvane` command on your PATH. `corvane <path>` opens a
repository and `corvane clone <url>` clones one.

## Upgrade

```bash
brew upgrade corvane
```

The app's own updater knows when it was installed with Homebrew and points you
here instead of updating itself.

## About the quarantine step

Corvane is signed with a self-signed certificate, not an Apple Developer ID,
so macOS would block the first launch. Homebrew no longer supports
`--no-quarantine`, so the cask removes the quarantine attribute from
`Corvane.app` after installing it.

## Uninstall

```bash
brew uninstall --cask corvane
brew uninstall --cask --zap corvane   # also removes settings and caches
```
