# Targets

```
kite target list                      # known targets and which are installed
kite target add x86_64-unknown-none   # install a target (checks clang and LLD, writes its linker script)
kite target show x86_64-unknown-none
kite target remove x86_64-unknown-none
kite build --target x86_64-unknown-none [--release]
```
`[build] target = "..."` in `kite.toml` sets a default.

**Hosted targets** (`x86_64-unknown-linux-gnu`, `aarch64-unknown-linux-gnu`, `x86_64-pc-windows-msvc`,
`aarch64-apple-darwin`, `x86_64-apple-darwin`) are passed to clang as they are (cross-linking needs a toolchain for
them). Any other triple is also forwarded to clang.

**Bare-metal targets** (`x86_64-unknown-none`, `aarch64-unknown-none`, `riscv64-unknown-none`) are for writing an
operating system. `kite target add` installs `~/.kite/targets/<name>/{target.toml,link.ld}` (`$KITE_HOME` overrides
`~/.kite`); it needs a clang with that backend and `ld.lld`. The build is freestanding (no libc, no `main` special
case), links with the target's linker script (entry `_start`, base address 0x100000 / 0x40080000 / 0x80000000)
and writes `target/<name>/<profile>/<package>.elf`:

```
make _start():
    ...        # your kernel entry point
```
Memory primitives (`alloc`, strings, lists) need a libc: in a kernel provide `malloc`, `free`, `memcpy`, `memmove`,
`strlen`, `strcmp`, `snprintf`, `realloc` yourself (extern C or Kite), or stay with integers and pointer arithmetic.

## Freestanding builds and the built-in runtime (0.4.4)

`kite build --freestanding` (an object file) and every bare-metal target produce a module that declares and defines
**only what the program uses**: no `argc`/`argv`, no format strings, no libc declarations.

Generated code still needs `malloc`, `memcpy`, `strlen`... for lists, strings and structs. For code with no libc at all,
add the **core runtime**: `--runtime core` (the default for bare-metal targets) or `[build] runtime = "core"`:

| function | behaviour |
|----------|-----------|
| `malloc`, `realloc` | bump allocator over a static heap (`--heap-size`, default 1 MiB); returns `null` when full |
| `free` | does nothing (the heap is never reused) |
| `memcpy`, `memmove`, `memset`, `memcmp`, `strlen`, `strcmp` | plain loops |
| `printf` | does nothing (a kernel prints through its own device code) |
| `exit` | halts in a loop (also what a failed list bounds check ends in) |

```
// kernel: no libc, entry point _start, writes "kite-boot" to the VGA text buffer
make _start():
    vga = int_to_ptr(753664)                 // 0xB8000
    names = ["kite", "os"]
    append(names, "boot")
    msg = names[0] + "-" + names[2]
    i = 0
    while i < len(msg):
        cell = vga + i
        *cell = char_at(msg, i) + 3840
        i.incr()
```

```
kite target add x86_64-unknown-none
kite build --target x86_64-unknown-none      # target/x86_64-unknown-none/debug/<name>.elf, no undefined symbols
```

To provide your own allocator instead, build with `--runtime none` and define `malloc`, `free`, ... as C functions.

## Smaller executables (0.5.1)
`kite build --storage` (or `[build] storage = true`) removes every function the program cannot reach from `main` / `_start`, including the unused
functions of imported pieces, then compiles for size and lets the linker drop unused sections and symbols. Freestanding objects and libraries without
an entry point are kept whole. See the [kite command](/reference/cli/).
