# Kite: what is left (v0.4.0)

## 1. Bootstrap: done in 0.4.0 ✅
The whole Rust compiler is ported to Kite (`compiler/`). `./build.sh` builds stage1 (kitec compiled by the Rust seed),
stage2 (kitec compiled by kitec) and stage3 (compiled by stage2); the three produce the same LLVM IR and
`compiler/BOOTSTRAPPED` is written. From now on the Rust seed (`archive/rust-stage0`) is only needed to
bootstrap from scratch and as a test oracle (`scripts/difftest.sh`, `scripts/llcmp.sh`).

| phase | Kite file | verified against Rust |
|-------|-----------|-----------------------|
| lexer, parser, diagnostics | `lexer.ki`, `parser.ki`, `diag.ki` | tokens / AST dumps, 49 files |
| desugar, prelude injection | `desugar.ki`, `prelude.ki` | desugared / injected dumps |
| sema | `sema.ki`, `types.ki` | typed dump and diagnostics (49 files + 36 error cases) |
| IR, LLVM codegen | `irdef.ki`, `ir.ki`, `codegen.ki` | identical `.ll` (string constants compared sorted) |
| project, imports, C headers | `project.ki`, `resolve.ki`, `cheader.ki` | stage2 = stage3 = stage1 |
| driver, CLI | `driver.ki`, `cli.ki`, `sysx.ki` | `init build run check clean bench add remove update` |

Still open from this chapter: `kite package`, `--target` cross builds from `kite` itself on every OS
(Windows/macOS releases still use the Rust seed), colours for diagnostics, making the CLI itself use `std.*`
(`sysx.ki`/`project.ki` are private copies), `bool == bool` in the code generator (also a Rust-seed limitation).
The `std.*` libraries are done: see `docs/stdlib.md`.

## 1b. Package system (0.5.0)
Design in `docs/packages.md`; implemented after the bootstrap, on top of the `git`, `toml`, `json`, `semver`, `sha256` libraries.

## 2. Language and runtime
`**kwargs`, user generics, dynamic dict literals and key deletion, struct `b = a` aliasing, nested collections,
`Option`/`Result` sugar, `match` on ints/strings, f-string format specs, memory reclamation, threads/async,
a larger stdlib (files, paths, time, json, regex, sorting), wider integers, FFI callbacks.

## 3. Tooling
`kite fmt`, `kite doc`, `kite test`, dependencies, language server, REPL/playground.

## 4. Editors (own repositories, own versions, all 1.0.0)
- publish `tree-sitter-kite`, then `zed-kite` (registry PR: see `zed-kite/PUBLISHING.md`), `vscode-kite` (Marketplace + Open VSX)
- submit `notepadpp-kite` (`notepad-plus-plus/userDefinedLanguages`) and `kate-kite` (KDE `syntax-highlighting`, needs `autotests` files)
- GitHub Linguist PR once there are ≈ 2000 indexed `.ki` files in many repositories (`linguist/README.md`)

## 5. Release and CI
- run the GitHub workflows once for real (`ci.yml`, `release.yml`); `windows-arm64` needs MSVC (CI runner)
- sign artifacts, apt/Homebrew/winget/AUR/Nix channels, man page and shell completions
- website: real domain, docs pages, download table from the latest release

## 6. Docs and tests
language tutorial and cookbook; unit tests for the 0.2+ features in the Rust crate; one error-message test per E-code
shared by both compilers; fuzzing lexer/parser (Rust vs Kite).

## 7. Housekeeping
`stdlib/prelude/` and `archive/rust-stage0/src/prelude/` are two copies (the crate must be self-contained for `cross`);
`build.sh` warns if they differ.
