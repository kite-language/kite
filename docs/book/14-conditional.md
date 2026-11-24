# Conditional compilation

Some code only makes sense on one operating system. A **`when`** block keeps its code for the targets you name and
**removes it from the program** for every other target: it is not compiled, not type-checked and not in the binary.

```kite
when windows:
    make open_url(url: string):
        run(f"start {url}")
else:
    make open_url(url: string):
        run(f"xdg-open {url}")

make main():
    open_url("https://kite-lang.pages.dev")
    when linux:
        print("running on Linux")
```

`when` works on top-level items (functions, types, constants, `use` lines) and on statements inside functions. An optional
`else:` block right after it holds the code for the other targets. Blocks can be nested.

## Conditions

| condition | true when the target is |
|-----------|-------------------------|
| `windows`, `linux`, `macos` | that operating system |
| `unix` | Linux or macOS |
| `bare` | freestanding (no OS), e.g. `x86_64-unknown-none` |
| `x86_64`, `aarch64`, `riscv64` | that CPU architecture |
| `os == "linux"`, `arch == "aarch64"` | the same, written as a comparison (`!=` also works) |

Combine them with `not`, `and`, `or` and parentheses: `when unix and not macos:`, `when (linux or macos) and arch == "aarch64":`.

The target is the one given to `kite build --target ...` (or `[build] target` in `kite.toml`); without one it is the machine you are on.

> **Note:** `when` is only a keyword at the start of a line followed by a condition and `:`, so a variable named `when` still works.
