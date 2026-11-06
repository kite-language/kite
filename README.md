<p align="center"><img src="assets/logo/kite-256.png" alt="Kite" width="128"></p>

# Kite

Readable like Python, fast like C, with a pinch of Rust-style safety. Current version: **0.3.1**.

```
make main():
    name = "Kite"
    print(f"Hello, {name}!")
```

## Install
```
curl -fsSL https://kite-lang.pages.dev/install.sh | sh                 # Linux
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --deb     # Debian / Ubuntu
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --rpm     # Fedora / RHEL / openSUSE
curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh           # macOS
irm https://kite-lang.pages.dev/install.ps1 | iex                      # Windows (PowerShell)
```
Kite needs `clang` to produce executables.

## Work on Kite
```
./build.sh              # Rust seed compiler → kitec (the compiler written in Kite)
./build.sh test         # + Kite-vs-Rust differential tests
./clean.sh --deep       # remove every build output
scripts/dev-install.sh  # local dev setup of everything (compiler + editors); see --help
```

## Repositories ([github.com/kite-language](https://github.com/kite-language))
| repository | content |
|---|---|
| **kite** (this one) | compiler, docs, prelude, examples, install scripts, Linguist material |
| [tree-sitter-kite](https://github.com/kite-language/tree-sitter-kite) | tree-sitter grammar |
| [vscode-kite](https://github.com/kite-language/vscode-kite) | VS Code extension |
| [zed-kite](https://github.com/kite-language/zed-kite) | Zed extension |
| [kate-kite](https://github.com/kite-language/kate-kite) | Kate / KWrite / KDevelop syntax definition |
| [notepadpp-kite](https://github.com/kite-language/notepadpp-kite) | Notepad++ language definition |

Each one has its own version: [docs/versions.md](docs/versions.md).

## Layout of this repository
| path | content |
|---|---|
| `compiler/` | the Kite compiler written in Kite (`kitec`) |
| `archive/rust-stage0/` | the original Rust compiler (seed of the bootstrap) |
| `stdlib/prelude/` | library code written in Kite |
| `docs/` | documentation ([index](docs/README.md)) |
| `examples/` | programs (`stable/` and `lang5/` have recorded outputs) |
| `scripts/` | `package-release.sh`, `dev-install.sh`, `cross-build.sh`, `difftest.sh` |
| `linguist/` | GitHub Linguist pull-request material |
| `website/` | kite-lang.pages.dev |

## Releases
`scripts/package-release.sh` builds the Linux and Windows archives (x64, arm64), `.deb`, `.rpm` and
`checksums.txt` into `dist/release/`. It packages the Rust compiler until the bootstrap is complete.
