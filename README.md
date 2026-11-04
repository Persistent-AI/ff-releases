# ff — terminal client for FireFlow and Flame Chorus

Open your FireFlow flows, files and Flame Chorus chats in the terminal.

```sh
curl -fsSL https://raw.githubusercontent.com/Persistent-AI/ff-releases/main/install.sh | sh
ff
```

The install script ([read it first](install.sh)) downloads the binary for your system from this repository's
latest release, checks its SHA-256 against the release's `SHA256SUMS` (and the Sigstore signature of that list when
`cosign` is installed), and puts it at `~/.local/bin/ff`. It needs no sudo and runs nothing else.

- `ff` opens the client; the first start signs you in to FireFlow and Flame Chorus in your browser.
- `ff update` replaces the binary with the latest release, checked the same way.
- `ff --version` prints the installed version.

Builds: macOS on Apple silicon, Linux x64 and arm64. macOS on Intel is planned.

This repository holds releases only. Licensed under the Business Source License 1.1 ([LICENSE.txt](LICENSE.txt)).
