# Changelog (kite repository)

Editor repositories have their own changelogs: see docs/versions.md.

## 0.4.1 -- pieces
- **Pieces**: Kite's packages ("crates"). The registry is `pieces/<name>/<version>/` in the repository, verified by
  CI (`scripts/verify-pieces.sh`, `.github/workflows/pieces.yml`): metadata, names, compilation, immutability.
  CLI: `kite init --lib`, `add`, `remove`, `update`, `tree`, `search`, `info`, `verify`, `publish` (prepares the pull
  request and prints the git/gh commands, never runs them). Transitive dependencies, semver requirements
  (`^ ~ >= < =`), path dependencies, `kite.lock` with sha256 checksums. See `docs/pieces.md`.
- **Default pieces** replace `stdlib/std`: `sys path fs process term args fmt time toml json semver sha256 git test`
  and the new `types`, `error`, `mem`, `threads` (`use std.<piece>`).
- **Language**: `spawn(fn, arg)` / `thread_join(h)` (pthreads), `realloc_n`, `copy_n`, `zero_n`, `ptr_to_int`,
  `int_to_ptr`. Code for programs that do not use them is unchanged (bootstrap IR still identical).
- **kite.toml**: `description authors license repository homepage readme keywords`, `{ path = ... }` / `{ version = ... }`
  dependencies; the values are readable from programs (`pkg_name()`, `pkg_version()`, `pkg_authors()`, ...).
- **Build output like cargo**: `target/debug|release/<name>`, `Compiling`/`Fresh` per piece and package, a fingerprint
  cache (compiler version, flags, all sources), `--target` builds into `target/<triple>/<profile>/`.
- **Targets**: `kite target list|add|remove|show`; bare-metal targets (`x86_64-unknown-none`, `aarch64-unknown-none`,
  `riscv64-unknown-none`) install a linker script and `kite build --target` produces a linked ELF for OS work
  (`docs/targets.md`).
- **Fix**: coloured status lines printed `?[1;32m` (the prelude's `chr` only knows printable characters); the ESC byte
  now comes from the shell. `clang --target=` spelling.
- `build.sh` is quieter (the Rust seed's warnings and the `-> path` lines are gone).

## 0.4.0 -- self-hosted
- **The compiler is written in Kite and compiles itself.** Ported to Kite: sema, IR lowering, LLVM codegen, project
  and `kite.toml` handling, import resolution, C header generation, the driver and the whole CLI
  (`init build run check clean bench add remove update`). `./build.sh` runs stage1 (compiled by the Rust seed),
  stage2 (compiled by kitec) and stage3 and requires identical LLVM IR before writing `compiler/BOOTSTRAPPED`.
- Verified against the Rust compiler: tokens, AST, desugar, inject, sema (typed program and diagnostics) and the
  generated `.ll` on every example and on the compiler's own sources; recorded example outputs pass with the
  self-hosted compiler (`scripts/runexamples.sh`).
- `package-release.sh --compiler auto` now ships the self-hosted `kite` (it needs only libc and clang).
- Standard library `stdlib/std/` (`use std.<name>`): sys path fs process term args fmt time toml json semver sha256 git
  test (`docs/stdlib.md`); the resolver finds it via `$KITE_STDLIB`, a neighbouring `stdlib/`, or the installed copy.
- Prelude: `join` merges pairwise (O(n log n)); the quadratic version exhausted memory on large outputs.
- Prelude injection (`compiler/src/prelude.ki`, embedded by `scripts/gen-prelude.sh`).
- **Fix**: the desugar crash on large inputs: `for x in ast.nodes[i].kids` read the list through the arena slot, which
  moves when the arena is reallocated inside the loop body; headers are now copied to a local first. Also
  `kids[1] = self.mk_type(...)` evaluated the target before the call that can reallocate the arena.
- New: `docs/packages.md` (design of the Git-based package system, planned for 0.5.0).

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
