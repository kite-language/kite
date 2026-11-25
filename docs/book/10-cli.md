# The `kite` command

```
kite <command> [options]
```

| command | what it does |
|---------|--------------|
| `kite init [NAME]` | create a package (`--lib` for a piece); without a name, in the current directory |
| `kite build` | compile the package |
| `kite run` | build, then run the program |
| `kite check` | type-check without producing a binary |
| `kite test [FILTER]` | build and run `tests/*.ki` (a non-zero exit code is a failure) |
| `kite fmt [--check]` | normalise whitespace in `src/` and `tests/` |
| `kite doc` | write `target/doc/<name>.md` from the `//` comments above items |
| `kite clean` | remove `target/` |
| `kite bench [--runs N]` | build in release mode and time repeated runs |
| `kite add NAME[@REQ]` / `remove NAME` | edit `[dependencies]` |
| `kite update` | re-resolve dependencies and rewrite `kite.lock` |
| `kite tree` | print the dependency tree |
| `kite search [QUERY]` / `kite info PIECE` | browse the piece registry |
| `kite verify` / `kite publish` | check a piece / prepare its pull request |
| `kite target list\|add\|remove\|show [NAME]` | manage build targets |
| `kite inspect FILE` | show the Kite signature stored in a binary |

## kite build

| option | meaning |
|--------|---------|
| `--release` | optimise (`-O3`), output in `target/release/` |
| `--target T` | build for another target (`target/<T>/<profile>/`) |
| `-q`, `--quiet` | no progress lines |
| `-o FILE`, `--out-dir DIR` | where to put the result |
| `--link FILE` | link an extra object/library (repeatable) |
| `--static` | link statically |
| `--lib` | an object file plus a C header, for calling Kite from C |
| `--freestanding` | an object file with no libc requirement, no `main` |
| `--runtime core` | add the built-in libc-free runtime (bump allocator, memory and string functions) |
| `--heap-size N` | heap of that runtime in bytes (default 1048576) |
| `--backend native` | experimental x86-64 generator with no clang (integer subset) |
| `--storage` | smallest executable: drops every function the program never calls (also inside the pieces it uses), `-Os`, one section per function and the linker removes the rest, symbols stripped |

`kite.toml` sets the same options: `[build] opt_level`, `target`, `runtime`, `heap_size`.

## Smaller executables: `--storage`

```sh
kite build --release --storage
```

`--storage` makes the executable as small as it can be. Kite starts from `main` and keeps only the functions the program can reach:
every function nobody calls is removed, **including the unused functions of the pieces you import** (a program that uses one
function of `std.strings` does not carry the other ones). Then the code is compiled for size, each function gets its own section,
and the linker removes whatever is left unused and strips the symbols. Behaviour does not change; only the size does.

```
$ kite build --release --storage
      Shrunk removed 103 of 143 functions the program never calls
$ ls -l target/release/app     # about 14 KB instead of 50 KB for a small program
```

Make it permanent with `[build] storage = true` in `kite.toml`. Libraries (`--lib`) and freestanding objects without a `main`
or `_start` are left whole, because every function may be called from outside.

## Build output

```
   Compiling sha256 v0.5.2 (/home/me/kite/pieces/std/sha256/0.5.2)
   Compiling hello v0.1.0 (/home/me/hello)
    Finished dev [unoptimized] target(s) in 0.42s
```

`Fresh` replaces `Compiling` when nothing changed. Layout: `target/debug/<name>`, `target/release/<name>`, with the
LLVM IR (`<name>.ll`) next to the binary and the cache fingerprint in `.fingerprint/`.

## Environment

| variable | meaning |
|----------|---------|
| `KITE_PIECES` | the registry directory (the repository's `pieces/`) |
| `KITE_HOME` | where `kite target add` installs targets (default `~/.kite`) |
