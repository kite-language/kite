# Changelog (kite repository)

Editor repositories have their own changelogs: see docs/versions.md.

## 0.3.1
- **Bootstrap**: the desugar pass (classes, virtual dispatch, `match`, data enums, defaults, named args, `*args`,
  unpacking) is ported to Kite: `kitec desugar FILE` is identical to the Rust desugar on all 37 sample files,
  diagnostics included. `./build.sh test` now runs this comparison too.
- **Rust stage0 fixes** needed by the port: the LLVM entry label is `kite.entry` so a variable named `entry`
  cannot collide with it.
- **Editors**: all integrations are 1.0.0 and live in their own repositories: `tree-sitter-kite`, `vscode-kite`,
  `zed-kite`, `kate-kite`, `notepadpp-kite` (see docs/versions.md). Target of 0.4.0: complete bootstrap.

## 0.3.0
- **Language**: f-strings, `str()`, compound operators, 0-based indexes, default / named / variadic parameters,
  tuple unpacking, aggregates passed to and returned from functions, classes with inheritance and virtual dispatch,
  data enums with `match`, pointers with auto-dereference and typed `null`, lists of structs, structs containing
  lists, `pop/remove/insert/clear`, string ordering, `exit`, prelude (string helpers, `StrMap_T` hash maps).
- **Bootstrap**: the Rust compiler is archived in `archive/rust-stage0/`; `compiler/` holds the lexer and parser
  written in Kite (identical to Rust on every sample). `build.sh` runs stage0 → stage1 and the differential tests.
- **Packaging**: `scripts/package-release.sh` (Linux/Windows archives, `.deb`, `.rpm`, checksums);
  installers with SHA-256 verification, `--deb`, `--rpm`, `--version`, `--prefix`; release workflow for
  Linux, Windows and macOS (one job builds both macOS architectures).
- **Repositories**: editor support moved to `tree-sitter-kite`, `vscode-kite`, `zed-kite`;
  Kate and Notepad++ definitions added under `editors/`; `scripts/dev-install.sh`.
- **Removed**: the GUI installer.
- **Fixes**: Rust crate self-contained for `cross` builds; temporaries renamed `%.tN`; Windows zip packaging.
