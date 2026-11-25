# Changelog (kite repository)

Editor repositories have their own changelogs: see docs/versions.md.

## 0.5.2 -- Windows and macOS CI fixes
- **Windows stage 2**: `fs.is_dir` used `path + "/."`, which Windows folds into `path`, so every file looked like a directory and `kite build` said
  ``stage2/src/main.ki not found``. A directory is now `exists(path + "/")` (a trailing slash only names a directory on every OS).
- **Windows tests**: the Rust end-to-end tests compared output with `\n` while Windows programs print `\r\n`: the output is normalised.
- **Line endings**: `.gitattributes` forces LF checkouts (`* text=auto eol=lf`) and `archive/rust-stage0/rustfmt.toml` sets `newline_style = "Unix"`, so `cargo fmt --check`
  and the shell scripts behave the same on Windows.
- **macOS x86-64**: CI and the release workflow now also run on `macos-15-intel` (GitHub's last native Intel image, available until August 2027), next to the
  Apple-silicon `macos-latest`; each architecture is built natively (`release-macos-arm64`, `release-macos-x64`).

## 0.5.1 -- `--storage`: the smallest executable
- `kite build --storage` / `[build] storage = true`: removes every function the program can never reach from `main` / `_start` (including the unused functions
  of the pieces it imports and of the prelude), compiles with `-Os -ffunction-sections -fdata-sections` and links with garbage collection and stripped
  symbols (`--gc-sections -s` on Linux, `-dead_strip -x` on macOS, `/OPT:REF,ICF` on Windows). `Shrunk removed N of M functions` is printed. A small program
  went from 50 912 to 14 480 bytes. `compiler/src/shake.ki`; libraries and objects without an entry point are left whole; the native back end gets the same pruned program.
- `KITE_STORAGE=1` turns the removal on for any command (used by `build.sh test` to run the language and piece tests on a pruned program).

## 0.5.0 -- the 0.5 line: generics, `num`, conditional compilation
Everything below is new compared with 0.4.4 (the 0.4.5 to 0.4.9 steps are folded into this release).
- **`num`**: a number that is an `int` or a `float`. `x: num = 3`, `x: num = 2.5`; an `int`/`float` converts to `num` where a `num` is expected (assignment,
  arguments, returns, `append`); `+ - * / %`, comparisons and unary `-` accept `num` (int with int stays int, anything with a float is a float);
  `x.as_int()`, `x.as_float()`, `x.is_float()`; `print`, `str`, f-strings. Implemented as a prelude record `num` plus `num__*` functions
  (`stdlib/prelude/num.ki`) injected only into programs that mention the type; sema rewrites the operators into calls (E0126 for an unsupported operand).
  The uniform call syntax now also applies to values of record types when no method of that name exists (`value.f()` is `f(value)`).
- **Templates**: generic functions `make first<T>(xs: [T]) -> T` (inferred, specialised per type), generic records `type Box<T>:` with `Box<int>` in any
  type position and as constructor `Box<int>()`, and **explicit type arguments** `first<int>(xs)`, `zero<int>()`, `convert<int, string>(a, b)` (E0127 for too many).
  `std.option` (`Option<T>`) and `std.result` (`Result<T, E>`): 40 default pieces.
- **Conditional compilation**: `when windows:` / `else:` blocks (items and statements; `windows linux macos unix bare x86_64 aarch64 riscv64`,
  `os == "..."`, `arch == "..."`, `not and or`). The code for other targets is removed before parsing (not compiled, not type-checked, not in the binary).
  The target is `--target` / `[build] target`, the host otherwise.
- **Pieces**: `pub` before make/type/class/enum/const exports an item; a file with any `pub` makes its other items private to the piece (E0080).
- **Language**: nested collections (`[[int]]`, struct fields of lists of lists, `len(g[0])` fixed); local and read-only `const` (E0124); `from use type class match case enum thread try
  failed finally` usable as names (`to`, `in`, type names and `null` stay reserved); fields and parameters of those names work too.
- **Windows CI fixes**: `timespec_get` declared and defined twice (declaration skipped, `i64` shim), CLI test checks `hello.exe`; a regression check compiles the Windows IR.
- **Site**: English, French (`/fr/`) and Spanish (`/es/`); grouped menu, page outline, copy buttons, callouts; guide chapters Generics, Conditional compilation, cheat sheet, troubleshooting.
- Fixed while testing: a stale arena header after generic instantiation could crash the compiler.

## 0.4.9 -- generic records, `Option<T>` and `Result<T, E>`
- **Generic records**: `type Box<T>:` / `type Pair<A, B>:`; applied as `Box<int>` in any type position (`[Box<int>]`, `ptr<Box<int>>`, `Box<Box<int>>`)
  and as a constructor `Box<int>()`. The compiler makes one instance per type arguments (`Box__int`), also from inside generic functions
  (`make wrap<T>(x: T) -> Box<T>`, inferred through `Box<T>` parameters). Errors `E0125` (wrong number of type arguments), `E0067` for an unsupported field type.
  Lexer note: `Box<int>(` is merged into one identifier token before parsing (uppercase name + `<...>` + `(`), `>>` closes two levels.
- **New default pieces** `std.option` (`Option<T>`: `some`, `is_some`, `is_none`, `unwrap`, `unwrap_or`) and `std.result`
  (`Result<T, E>`: `ok`, `err`, `is_ok`, `is_err`, `unwrap`, `unwrap_or`, `error`): 40 default pieces.
- Docs: new guide chapter "Generics" (EN/FR/ES); test `lang_test/tests/generic_types.ki`. Kite compiler only (the seed cannot parse `<T>`).

## 0.4.8 -- general constants, words usable as names
- **Constants**: `const NAME = expr` also inside functions (`const STEP = LIMIT / 4`), with an optional type; any constant is read-only:
  assigning to it, `+=`, `.incr()`, or changing a field of a constant record is error `E0124`. Global constants already accepted any type and other constants.
- **Words usable as names**: `from use type class match case enum thread try failed finally` are keywords only where their meaning applies
  (a token pass turns them into names after `=`, `(`, `,`, operators, `return`, `if`..., or at the start of an assignment), so
  `from = 3`, `print(type)`, `make span(from: int, case: int)`, `for finally in xs`, `f"{try}"` work. Still reserved: `to`, `in`, type names, `null`.
- Tests: `lang_test/tests/consts.ki`, `names.ki`; `build.sh test` checks `E0124`. Kite compiler only (the seed keeps the old rules).

## 0.4.7 -- nested collections
- Lists of lists to any depth (`[[int]]`, `[[string]]`, `[[Cell]]`), nested list literals (`[[1, 2], [3]]`), struct fields of nested
  list types (`cells: [[int]]`), `len(grid[0])` on an element that is a list (it was lowered as a string length), lists of maps (`[StrMap_int]`).
  Checked with AddressSanitizer. Kite compiler only. Tuples still hold scalars only.
- Test: `stdlib/tests/lang_test/tests/nested.ki`. Docs: guide chapter 5 (EN/FR/ES).

## 0.4.6 -- generic functions
- **Generic functions**: `make first<T>(xs: [T]) -> T:`. Type parameters are inferred from the argument types (`T`, `[T]`, `ptr<T>`);
  the compiler instantiates one specialised function per combination (`first__int`, `first__Lstring`) while checking calls, so there is
  no run-time cost. Errors `E0120` (generic methods), `E0121` (argument count), `E0122` (type mismatch), `E0123` (cannot infer).
  Kite compiler only (the Rust seed cannot parse type parameters, so the compiler sources do not use them).
- Tests: `stdlib/tests/lang_test/tests/generics.ki`. Docs: guide chapter 4, language reference, cheat sheet (EN/FR/ES).

## 0.4.5 -- visibility (`pub`), a site in three languages, Windows fixes
- **Visibility**: `pub` before `make`, `type`, `class`, `enum` or `const` exports an item. A file that uses `pub` is in explicit mode: its
  other top-level items are private to their piece (the `src/` tree). Files without `pub` stay open, so existing pieces keep working.
  Using a private function, type, class, enum or constant of another piece is error `E0080`. `pub` is not a reserved word.
  The standard-pieces reference lists only the `pub` items of a piece that uses `pub`.
- **Windows (CI)**: the `timespec_get` shim was declared and defined (`invalid redefinition of function`): the extern declaration is now
  skipped when the shim is emitted, in both back ends, with matching `i64` types; the end-to-end CLI test looks for `hello.exe`.
  `build.sh test` compiles the Windows IR of a `std.time` program to an object as a regression check.
- **Site**: English at `/`, French at `/fr/`, Spanish at `/es/` (language switcher, `hreflang`, sitemap); the install page is now a docs page;
  outline of the page on the right, grouped collapsible menu, copy buttons, callouts, previous/next links, new cheat sheet and
  troubleshooting pages. A page without translation shows the English text with a notice.
- Tests: `stdlib/tests/visibility/` (fixture piece with public and private items), run by `build.sh test`.

## 0.4.4 -- language touches, freestanding runtime, first native back end
- **Language** (Kite compiler only; the Rust seed cannot parse these): `.incr()` / `.decr()`; method chains continued on lines
  starting with `.name`; **uniform call syntax** `value.f(args)` = `f(value, args)` when the receiver is not a class instance;
  reserved words allowed as member and field names; string escapes `\x41 \e \r \0`; `const NAME = expr`; `p[i]` on pointers;
  `bool == bool` (invalid LLVM before 0.4.3); builtins `float_of`, `int_of`, `spawn`, `thread_join`, `realloc_n`, `copy_n`,
  `zero_n`, `ptr_to_int`, `int_to_ptr`, `panic`, `assert`; f-strings in both lexers (about 200 compiler messages rewritten).
- **Freestanding**: only used declarations and globals are emitted; `--runtime core` (default for bare targets) links a libc-free
  runtime written in LLVM IR (bump allocator, `mem*`/`str*`, no-op `printf`, halting `exit`), `--heap-size N`,
  `[build] runtime` / `heap_size`. A kernel for `x86_64-unknown-none` links with no undefined symbol (not run in QEMU).
- **Signature**: every binary carries `KITE-META|language=Kite|compiler=...|package=...|KITE-END`; `kite inspect FILE` prints it.
- **Native back end (experimental)**: `kite build --backend native`, own x86-64 code generator and ELF writer (no clang, no linker),
  constant folding; integer, bool and string-literal programs (arithmetic, if/while/for, functions, recursion, print, exit).
  Unsupported programs are rejected with the reason.
- **Windows**: `timespec_get` shim, `-llegacy_stdio_definitions`, portable `std.sys/fs/path/process/time` (not run here: CI is the check).
- **Docs and site**: the guide (`docs/book`), `docs/targets.md`, docs at `/`, install page at `/installation/`.
- Tests: `stdlib/tests/lang_test/tests/features2.ki`; `build.sh test` no longer compares the non-injected `desugar` dump (the uniform-call
  rewrite differs from the seed there, `inject` agrees) and checks `kite inspect`, `--runtime core` and `--backend native`.

## 0.4.3 -- more pieces, repaired workflows
- **The compiler calls pieces as `piece.function()`** (`fs.is_dir(p)`, `path.join(a, b)`, `sys.quote(s)`, 254 call sites);
  the Rust seed resolves those calls too (desugarer), shadowed names stay prefixed.
- **Reserved words are valid member names**: `random.string(r, 8)`, `glob.match(p, t)`, `job.thread`, and record fields
  named after reserved words.
- **17 new default pieces**: `random strings collections bits stats hex base64 crc32 url csv datetime log io glob http
  uuid utf8`; **4 community pieces**: `table ini progress diff` (65 assertions in `stdlib/tests/pieces2_test`).
- **Portable runtime layer** (`std.sys/fs/path/process/time`): environment, working directory, `mkdir`, clock and file
  tests through the C library instead of the shell; Windows-aware quoting, temp dir and null device; drive-letter
  paths; `std.sha256` computes the build fingerprint (no `sha256sum`). The compiler links `legacy_stdio_definitions`
  on Windows and no longer passes `-pthread -lm` there.
- **Workflows repaired**: the Rust seed is rustfmt-formatted and clippy-clean (`-D warnings`); the Windows ARM64 link error
  (`undefined symbol: printf`) and the Windows x64 stage-2 failure (POSIX shell commands run by `cmd.exe`) are fixed; macOS
  uses the current Apple-silicon runner (the Intel archive is cross-compiled; the job is non-blocking), Windows and macOS
  never block the Linux release; `clang --target=<triple>` spelling.
- **`build.sh` clears its caches**: `compiler/target`, `stage2/`, `stage3/` and their `.fingerprint` caches are removed on every
  run (`./build.sh --fresh` also rebuilds the Rust seed); `.exe` suffixes are handled for Windows.
- `ROADMAP.md`: the road to 1.0.0 (stages 0.5 to 0.9, the 1.0 stability criteria) and, last and unscheduled, the LLVM-free
  multi-architecture back end.

## 0.4.2 -- the compiler uses its own pieces
- `compiler/src/` now imports the default pieces instead of private copies: shell and process helpers (`std.sys`,
  `std.process`), files and directories (`std.fs`), paths (`std.path`), colours (`std.term`), clock and durations
  (`std.time`), formatting (`std.fmt`), integer helpers (`std.types`), TOML values (`std.toml`) and version
  requirements (`std.semver`). `sysx.ki` shrank to the cargo-style status lines; `project.ki` and `pieces.ki` lost their
  TOML and semver code.
- The Rust seed resolves `use std.<piece>` (registry: `$KITE_PIECES` or the nearest `pieces/`), so stage 1 still builds.
- Pieces gained what the compiler needed: `path_has_extension`, `path_display`, `toml_array_join`, `toml_inline_get`,
  `toml_strip_comment`, `toml_quote_list`, `semver_best`, `types_isqrt`, `time_fmt_secs`, `term_paint_if`,
  `term_is_tty_fd`, `term_esc`. `term` no longer uses a `\x1b` literal (the seed's lexer has none).
- Default pieces are versioned with the language (`pieces/std/<name>/0.4.2`); only community versions are immutable.
- Everything is 0.4.2: compiler, seed, default pieces, site, install scripts.

## 0.4.1 -- pieces
- **Pieces**: Kite's packages ("crates"). The registry is `pieces/<name>/<version>/` in the repository, verified by
  CI (`scripts/verify-pieces.sh`, `.github/workflows/pieces.yml`): metadata, names, compilation, immutability.
  CLI: `kite init --lib`, `add`, `remove`, `update`, `tree`, `search`, `info`, `verify`, `publish` (prepares the pull
  request and prints the git/gh commands, never runs them). Transitive dependencies, semver requirements
  (`^ ~ >= < =`), path dependencies, `kite.lock` with sha256 checksums. See `docs/pieces.md`.
- **Language**: `const NAME = expr`, `bool == bool`, `p[i]` on `ptr<T>`, `float_of` / `int_of` (+ `std.math`),
  string escapes `\x41 \e \r \0`, `panic` / `assert`.
- **Tools**: `kite test` (runs `tests/*.ki`), `kite fmt [--check]`, `kite doc` (markdown from `//` comments).
- `ROADMAP.md` and `docs/language-tour.md` (the planned work, ending with the LLVM-free multi-arch back end, has no date).
- **Qualified calls**: `piece.function(...)` (`fs.read(p)`, `sha256.hex(t)`) for imported pieces; shadowed by locals.
- **Two registry tiers**: `pieces/std/` (default pieces, `use std.<name>`, installed with the compiler) and
  `pieces/community/` (declared dependencies, added by pull request); names cannot clash.
- **Releases ship stage3** on Linux, macOS and Windows (`release.yml`); the install scripts (`install.sh`,
  `install-macos.sh`, `install.ps1`) also install `~/.kite/pieces`; the site shows v0.4.1.
- Fix: diagnostics of multi-file projects were tagged with the wrong file (off-by-one in `Sema.tag_from`) and
  could crash the renderer.
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
