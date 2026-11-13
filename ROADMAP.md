# Kite roadmap

Versions are `0.x`: the compiler is written in Kite and compiles itself since 0.4.0.
"Planned" means decided but not started; dates are deliberately left open.

## Done
| version | what |
|---------|------|
| 0.4.0 | self-hosted compiler (stage1 = stage2 = stage3), `std.*` libraries |
| 0.4.1 | pieces (packages) with a `std/` and a `community/` registry, `piece.function()` calls, threads (`spawn`), memory builtins, `kite.toml` metadata (`pkg_*()`), cargo-like `target/`, `kite target` for bare-metal OS builds, `kite test` / `fmt` / `doc`, `const`, `bool == bool`, `p[i]` on pointers, `float_of` / `int_of` + `std.math`, `\x41` `\e` `\r` `\0` escapes, `panic` / `assert` |

## Planned
Each stage is ordered by how much it unlocks; the version numbers are indicative.

### Language readability and power (0.5.x)
- [ ] **Real namespaces**: functions of a piece live in `piece::function`, no global prefixes, `use piece.{a, b}`
- [ ] **Generics**: `Vec<T>`, `Option<T>`, `Result<T, E>`, `StrMap<V>` as ordinary library code (replaces the internal `StrMap_<T>` template)
- [ ] **Nested collections**: lists of lists, dictionaries of lists, structs holding collections
- [ ] **Function values and closures**: callbacks, `spawn(|| ...)` capturing variables
- [ ] **Free the reserved words** that clash with everyday names (`thread`, `failed`, `ptr`, `type`, ...) in field and variable positions
- [ ] **Module-level `const` for any expression**, not only literals-and-calls, evaluated once

### Safer code (0.6.x)
- [ ] **Error propagation** with `?` on `Result` values, `panic` with source location
- [ ] **Nullable types** checked by the compiler (`T?`)
- [ ] **Traits / interfaces** for shared behaviour without inheritance
- [ ] **Overflow checks** in debug builds

### Concurrency (0.6.x)
- [ ] Real `thread:` blocks that capture locals
- [ ] Channels, condition variables, thread pools as pieces
- [ ] Thread-safe collections

### Operating systems and tooling (0.7.x)
- [ ] `unsafe` blocks, `volatile` access, packed structs, `@section` / `@no_mangle` attributes
- [ ] A libc-free `core` piece (own allocator, string and list runtime) so kernels need no C
- [ ] Debug information (lines and variables visible in gdb / lldb)
- [ ] Language server (diagnostics, go to definition), `kite doc` HTML output
- [ ] Remote registry mirror and signed pieces

### Not scheduled (no date, no stage)
- [ ] **Remove LLVM IR for a custom optimisation and compilation multi arch like rust**: replace the LLVM IR text
  back end with Kite's own mid-level IR, its own optimisation passes and its own code generators for several
  architectures (x86-64, AArch64, RISC-V, ...), so a Kite toolchain needs neither clang nor LLVM to produce a binary.
