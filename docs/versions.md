# Versions

Every repository (and every editor integration) has **its own version**, bumped only when *it* changes.
The editor integrations all start at **1.0.0**; the compiler is still 0.x.

| repository | version | where the version is set | changelog |
|---|---|---|---|
| [kite](https://github.com/kite-language/kite) (compiler, docs, scripts) | **0.3.1** | `archive/rust-stage0/Cargo.toml`, `compiler/kite.toml` | `CHANGELOG.md` |
| [tree-sitter-kite](https://github.com/kite-language/tree-sitter-kite) | **1.0.0** | `package.json`, `tree-sitter.json`, `Cargo.toml` (`scripts/bump-version.sh`) | `CHANGELOG.md` |
| [vscode-kite](https://github.com/kite-language/vscode-kite) | **1.0.0** | `package.json` | `CHANGELOG.md` |
| [zed-kite](https://github.com/kite-language/zed-kite) | **1.0.0** | `extension.toml` | `CHANGELOG.md` |
| [kate-kite](https://github.com/kite-language/kate-kite) | **1.0.0** | `CHANGELOG.md` (and `version=` inside `kite.xml`, KDE's own counter) | `CHANGELOG.md` |
| [notepadpp-kite](https://github.com/kite-language/notepadpp-kite) | **1.0.0** | `CHANGELOG.md` | `CHANGELOG.md` |

## Which editor version matches which language version
| Kite language | tree-sitter-kite | vscode-kite | zed-kite | kate-kite | notepadpp-kite |
|---|---|---|---|---|---|
| 0.3.x | 1.0.x | 1.0.x | 1.0.x | 1.0.x | 1.0.x |
| 0.1.x | 0.1.x (old) | – | 0.1.x (old) | – | – |

## Releasing (all by hand)
1. Change the code, update that repository's `CHANGELOG.md` and its version.
2. Run its tests (`./build.sh test`, `npm test`, …).
3. Commit, tag (`vX.Y.Z`) and push yourself. Nothing in these repositories runs git commands that write.
4. If the grammar changed: bump `tree-sitter-kite`, run `zed-kite/scripts/set-grammar-rev.sh`, bump `zed-kite`.
5. Add a row to the table above when a new language version needs different editor versions.
