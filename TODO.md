# Kite: what is left (v0.3.1)

## 1. Bootstrap: port the Rust compiler to Kite
Done: lexer, parser, diagnostics, desugar (≈ 31 % of ≈ 12 000 Rust lines). **Goal of 0.4.0: finish everything below.** Each phase is verified against the Rust one with
canonical dumps (`scripts/difftest.sh`).

| # | phase | Rust size | Kite file | check |
|---|-------|-----------|-----------|-------|
| 1 | ~~desugar~~ ✅ done in 0.3.1 | 1 147 | `compiler/src/desugar.ki` | dump of the desugared AST: 37 files identical |
| 2 | prelude injection | 122 | `prelude.ki` | dump after injection |
| 3 | sema | 2 001 | `sema.ki` | typed dump + same diagnostics |
| 4 | IR lowering | 2 861 | `ir.ki` | IR dump |
| 5 | LLVM codegen | 1 557 | `codegen.ki` | identical `.ll` |
| 6 | project / `kite.toml`, imports, C headers | ≈ 530 | `project.ki`, `resolve.ki`, `cheader.ki` | same results |
| 7 | driver + CLI (`init build run check clean bench package`) | ≈ 1 400 | `driver.ki`, `cli.ki` | same outputs |
| 8 | stage2: `kitec` compiles itself, same IR as stage1 | – | `./build.sh` | writes `compiler/BOOTSTRAPPED` |
| 9 | ship `kitec` as `kite` | – | `package-release.sh --compiler auto` | Rust tests re-run |

Probably needed on the way: float formatting/parsing, directory/process helpers, `sort`, better prelude error spans.

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
