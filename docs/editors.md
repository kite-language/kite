# Editors

Editor support lives in separate repositories of the [kite-language](https://github.com/kite-language) organization,
each with its **own version** (see `versions.md`).

| editor | repository / path | how to use |
|---|---|---|
| VS Code | [`vscode-kite`](https://github.com/kite-language/vscode-kite) | install the `.vsix` (`kite-language.kite-language-vscode`) |
| Zed | [`zed-kite`](https://github.com/kite-language/zed-kite) (grammar from [`tree-sitter-kite`](https://github.com/kite-language/tree-sitter-kite)) | `zed: install dev extension`, or the registry once published |
| Neovim, Helix | [`tree-sitter-kite`](https://github.com/kite-language/tree-sitter-kite) | tree-sitter grammar + `queries/` |
| Kate, KWrite, KDevelop | [`kate-kite`](https://github.com/kite-language/kate-kite) | `scripts/install.sh` (copies `kite.xml` to `~/.local/share/org.kde.syntax-highlighting/syntax/`) |
| Notepad++ | [`notepadpp-kite`](https://github.com/kite-language/notepadpp-kite) | run `install.ps1` or import `Kite.xml` |
| GitHub | `linguist/` (this repo) | material for a pull request to `github-linguist/linguist` |

Local development of everything at once: `scripts/dev-install.sh --help`.
