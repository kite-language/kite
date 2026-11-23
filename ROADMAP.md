# Kite roadmap

Versions are `0.x` until 1.0.0. The compiler is written in Kite and compiles itself since 0.4.0.
"Planned" means decided but not started; dates are deliberately left open.

## Done
| version | what |
|---------|------|
| 0.4.0 | self-hosted compiler (stage1 = stage2 = stage3), `std.*` libraries |
| 0.4.1 | pieces (packages) with a `std/` and a `community/` registry, `piece.function()` calls, threads (`spawn`), memory builtins, `kite.toml` metadata (`pkg_*()`), cargo-like `target/`, `kite target` for bare-metal OS builds, `kite test` / `fmt` / `doc`, `const`, `bool == bool`, `p[i]` on pointers, `float_of` / `int_of` + `std.math`, string escapes, `panic` / `assert` |
| 0.4.2 | the compiler's own source uses the default pieces instead of private copies; the Rust seed resolves `use std.<piece>`; default pieces are versioned with the language |
| 0.4.3 | the compiler calls pieces as `piece.function()` itself; 17 new default pieces (`random strings collections bits stats hex base64 crc32 url csv datetime log io glob http uuid utf8`) and 4 community pieces (`table ini progress diff`); reserved words allowed as member names (`random.string`, `glob.match`); portable low-level layer (no shell for environment, cwd, mkdir, clock, file tests; Windows-aware quoting); `build.sh` always rebuilds from clean caches; CI repaired (rustfmt, clippy, Windows link, macOS on the current runner) |
| 0.4.4 | `.incr()`/`.decr()`, multi-line method chains, uniform call syntax, keyword member names, string escapes; freestanding `--runtime core` (libc-free); binary signature and `kite inspect`; experimental native x86-64 back end (`--backend native`, integer subset); Windows link and portability fixes; the guide and the new site |
| 0.4.5 | `pub` / private items for pieces (E0080); site in English, French and Spanish with a clearer layout; cheat sheet and troubleshooting pages; Windows `timespec_get` and CLI test fixes |
| 0.4.6 | generic functions (`make first<T>(xs: [T]) -> T`), inferred and specialised per type |
| 0.4.7 | nested collections: lists of lists, nested literals, struct fields of nested lists, `len` of list elements |
| 0.4.8 | general `const` (local, read-only, E0124); reserved words usable as variable, parameter and field names |
| 0.4.9 | generic records (`Box<T>`), `std.option` / `std.result` (`Option<T>`, `Result<T, E>`) |

## Road to 1.0.0
Each stage is ordered by how much it unlocks; version numbers are indicative. **1.0.0 is declared when every
box up to 0.9 is ticked, the whole test suite passes on Linux, macOS (Apple silicon) and Windows from the stage-3
compiler, and the syntax and the default pieces' API are frozen.**

### 0.5 -- language foundations
- [ ] **Real namespaces**: functions of a piece live in `piece::function`, no global prefixes, `use piece.{a, b}`
- [ ] **Generics**: `Vec<T>`, `Option<T>`, `Result<T, E>`, `Map<K, V>` as ordinary library code (replaces the internal `StrMap_<T>` template)
  - done in 0.4.6 / 0.4.9: generic functions, generic records (`Box<T>`), `std.option`, `std.result`; still to do: `Map<K, V>` as library code, generic classes and enums
- [x] **Nested collections**: lists of lists, structs holding collections (0.4.7); tuples still hold scalars only
- [x] **Free the reserved words** for variable and function names too (0.4.8; `to`, `in`, the type names and `null` stay reserved)
- [ ] `const` for any expression, evaluated once; compile-time constants in types (`[int; 8]`)
  - done in 0.4.8: local constants and read-only checks; still to do: evaluate once, `[int; 8]`

### 0.6 -- functions and concurrency
- [ ] **Function values and closures**: callbacks, `spawn(|| ...)` capturing variables, iterators with `map` / `filter`
- [ ] Real `thread:` blocks capturing locals; channels, condition variables, thread pools, thread-safe collections as pieces
- [ ] `async` / `await` on top of the thread pool

### 0.7 -- safety
- [ ] **Error propagation**: `?` on `Result`, `try`/`catch` mapped onto it, `panic` with source location and backtrace
- [ ] **Nullable types** checked by the compiler (`T?`), no implicit null
- [ ] **Traits / interfaces** for shared behaviour without inheritance, operator overloading
- [ ] Overflow checks in debug builds, bounds-check elimination in release

### 0.8 -- systems and portability
- [ ] `unsafe` blocks, `volatile`, packed structs, `@section` / `@no_mangle` attributes, inline assembly
- [ ] A libc-free `core` piece (own allocator, string and list runtime) so kernels need no C
- [ ] Debug information (lines and variables visible in gdb / lldb)
- [ ] A shell-free runtime on every OS (the remaining shell uses in `std.fs`, `std.process`, `std.git` replaced by system calls)
- [ ] First-class Windows and macOS: all releases built and tested from the stage-3 compiler

### 0.9 -- ecosystem and tooling
- [ ] Language server (diagnostics, go to definition, completion), AST-based `kite fmt`, `kite doc` as HTML, `kite bench` with comparison
- [ ] Remote registry mirror, signed pieces, `kite audit`, reproducible builds
- [ ] More pieces: `regex`, `json` with a value tree, `net` (sockets), `crypto` (hashes, HMAC, AES), `compress`, `sqlite`, `tui`
- [ ] The language book and the migration guide

### 1.0.0 -- stability
- [ ] Syntax frozen; a documented edition mechanism for later changes
- [ ] The API of the default pieces frozen (additions only), with a deprecation policy
- [ ] `kite migrate` for edition changes; a conformance test-suite that other implementations can run

### Small finishing touches before 1.0.0 (1.0 polish)
- [ ] `print(float)` uses `%f` while `str(float)` uses `%g`: make them agree
- [ ] String `+` is O(n) (use `join`): a string builder or rope
- [ ] `StrMap` has no `remove`
- [ ] `read_file` returns "" on error: give it a failure channel
- [ ] `try` / `failed` blocks are parsed but `failed` never runs
- [ ] Variables are function-scoped and keep one type; empty list literals need a type
- [ ] Diagnostics are plain text: add colour and underlined spans
- [ ] `kite fmt` only fixes whitespace; `kite doc` is markdown only; `kite bench` uses integer microseconds

## Not scheduled (no date, no stage)
- [ ] **Remove LLVM IR for a custom optimisation and compilation multi arch like rust**: replace the LLVM IR text
  back end with Kite's own mid-level IR, its own optimisation passes and its own code generators for several
  architectures (x86-64, AArch64, RISC-V, ...), so a Kite toolchain needs neither clang nor LLVM to produce a binary.
  **Status (0.4.4)**: started. `kite build --backend native` has an x86-64 Linux generator and ELF writer for the integer subset.
  Next: lists, strings and structs (reuse the core runtime), floats (SSE), AArch64 and RISC-V encoders, Mach-O and PE writers,
  register allocation, more passes (CSE, dead code, inlining); then make it the default and drop clang.
