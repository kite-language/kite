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
