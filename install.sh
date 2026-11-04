#!/bin/sh
# Installs `ff`, the terminal client for FireFlow and Flame Chorus.
#   curl -fsSL https://raw.githubusercontent.com/Persistent-AI/ff-releases/main/install.sh | sh
# What it does, all of it: picks the binary for this OS and CPU from the latest release of
# github.com/Persistent-AI/ff-releases, checks its SHA-256 against that release's SHA256SUMS (and its Sigstore
# signature when `cosign` is installed), and puts it at ~/.ff/bin/ff. No sudo, nothing else is downloaded or run.
# Everything ff keeps lives in ~/.ff (or $FF_HOME); uninstalling is `rm -rf ~/.ff`.
# FF_VERSION=v0.1.0 picks a version; FF_HOME changes the folder (the binary goes to $FF_HOME/bin).
set -eu

repo="Persistent-AI/ff-releases"
dir="${FF_INSTALL_DIR:-${FF_HOME:-$HOME/.ff}/bin}"
version="${FF_VERSION:-latest}"

case "$(uname -s)" in Darwin) os=darwin ;; Linux) os=linux ;; *) echo "ff: no build for $(uname -s)" >&2; exit 1 ;; esac
case "$(uname -m)" in x86_64|amd64) arch=x64 ;; arm64|aarch64) arch=arm64 ;; *) echo "ff: no build for $(uname -m)" >&2; exit 1 ;; esac
asset="ff-${os}-${arch}"
if [ "$version" = latest ]; then base="https://github.com/${repo}/releases/latest/download"; else base="https://github.com/${repo}/releases/download/${version}"; fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
echo "ff: downloading ${asset} (${version})"
curl -fsSL --proto '=https' --tlsv1.2 -o "$tmp/$asset" "$base/$asset"
curl -fsSL --proto '=https' --tlsv1.2 -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"

expected="$(grep " ${asset}\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)"
if command -v sha256sum >/dev/null 2>&1; then actual="$(sha256sum "$tmp/$asset" | cut -d' ' -f1)"; else actual="$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)"; fi
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then echo "ff: checksum mismatch for ${asset}; nothing installed" >&2; exit 1; fi
echo "ff: checksum ok"

if command -v cosign >/dev/null 2>&1; then
  curl -fsSL --proto '=https' --tlsv1.2 -o "$tmp/SHA256SUMS.bundle" "$base/SHA256SUMS.bundle"
  cosign verify-blob --bundle "$tmp/SHA256SUMS.bundle" \
    --certificate-identity-regexp '^https://github.com/Persistent-AI/ff-tui/\.github/workflows/release\.yml@refs/tags/v' \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com "$tmp/SHA256SUMS" >/dev/null
  echo "ff: signature ok (built by Persistent-AI/ff-tui's release workflow)"
fi

mkdir -p "$dir"
chmod +x "$tmp/$asset"
mv "$tmp/$asset" "$dir/ff"
[ "$os" = darwin ] && xattr -d com.apple.quarantine "$dir/ff" 2>/dev/null || true
echo "ff: installed $("$dir/ff" --version) at $dir/ff"
case ":$PATH:" in *":$dir:"*) ;; *) echo "ff: add it to PATH:  echo 'export PATH=\"$dir:\$PATH\"' >> ~/.$(basename "${SHELL:-sh}")rc" ;; esac
echo "ff: run  ff"
