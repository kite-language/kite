# Pieces (packages)

A **piece** is a Kite library: a project with `src/lib.ki` and a `kite.toml`. Pieces are Kite's crates:
the language itself is "made of pieces" -- the default ones (`std.*`) live in the same registry as everyone else's.

## The registry
The registry is the `pieces/` directory of the Kite repository, in two clearly separated tiers:

- `pieces/std/<name>/<version>/` -- the **default pieces**, maintained with the language. They need no declaration:
  `use std.<name>`. They are installed with the compiler.
- `pieces/community/<name>/<version>/` -- **third-party pieces**, added by pull request. They are declared in
  `[dependencies]` and imported by name. A community piece cannot take the name of a default piece.

Published versions are **immutable**. kite finds it through `$KITE_PIECES`, a `pieces/` folder (with a `REGISTRY`
file) above the project, `~/.kite/pieces`, or `/usr/share/kite/pieces` (installed with the `.deb`/`.rpm`/archive).

## Using pieces
```
kite search json          # search names, descriptions, keywords
kite info semver          # metadata and versions
kite add sha256           # writes `sha256 = "0.4.1"` to [dependencies] and updates kite.lock
kite add semver@^0.4      # a requirement: "1.2" / "^1.2" / "~1.2.3" / ">=1.0" / "=1.2.3" / "*"
kite tree                 # dependency tree (transitive dependencies are detected and resolved)
kite update               # re-resolve and rewrite kite.lock
kite remove sha256
```
`kite.toml` also accepts local pieces: `mylib = { path = "../mylib" }` (not publishable).
`kite.lock` records name, version, source and a sha256 checksum of every registry piece; a mismatch with the
registry copy aborts the build.

In code: `use sha256` (a declared community dependency), `use mylib.sub` (a module of a piece, `src/sub.ki`),
and `use std.fs` for the **default pieces** (the equivalent of Rust's `std::`). A project's own `src/<name>.ki`
wins over a piece of the same name. `kite add fs` answers that `fs` is a default piece.

**Qualified calls**: call a piece's function as `piece.function(...)` -- `fs.read(path)`, `sha256.hex(text)`,
`types.clamp(v, 0, 10)`. It stands for the function named `<piece>_<function>` (the naming convention of pieces:
`fs_read`), or else a function called `<function>` defined by that piece. The prefixed names keep working. The name
is only a piece inside functions that do not use it as a variable (a local called `fs` shadows the piece), and
only in files that import the piece; an unknown function is an error that lists the names it looked for.
Functions still share one global namespace under the hood, so name your piece's functions `<piece>_<function>`.

## Default pieces (`std.*`)
| piece | what it offers |
|-------|----------------|
| `sys` | libc hooks (`system`, `access`, `isatty`, `getpid`), `sys_sh`, `sys_capture`, `sys_quote` |
| `types` | `types_min max abs clamp sign gcd pow`, `types_is_int`, `types_parse_int/bool`, case helpers |
| `error` | `Error` (code, message, context chain), `error_wrap`, `error_describe`, `ResultInt/Str/Bool` |
| `mem` | `mem_new get set grow copy zero fill equal free`, growable `IntVec` (`intvec_*`) |
| `threads` | mutexes (`mutex_*`), atomic ints (`atomic_*`), `thread_sleep_ms`; threads themselves are the builtins `spawn`/`thread_join` |
| `time` | `time_now_ns/ms/secs`, `time_sleep_ms`, `time_format`, `time_elapsed_ms` |
| `fs`, `path`, `process`, `term`, `args`, `fmt` | files, paths, programs/env, colours, CLI parsing, formatting |
| `toml`, `json`, `semver`, `sha256`, `git`, `test` | flat TOML, JSON reader, versions, hashing, git wrapper, assertions |

## Language support added in 0.4.1
Memory: `alloc(T)`, `alloc_n(T, n)`, `free(p)` (existing) plus `realloc_n(p, n)`, `copy_n(dst, src, n)`,
`zero_n(p, n)`, `ptr_to_int(p)`, `int_to_ptr(n)` (a `ptr<int>`); pointer arithmetic `p + i`, `*p`.
Threads: `h = spawn(worker, arg)` runs `make worker(arg: int)` (returns nothing or an `int`) on a new thread
(pthreads) and `thread_join(h)` waits. Share data by passing `ptr_to_int(block)` and rebuilding it with
`int_to_ptr`; protect it with the `threads` piece.

## Package metadata in code
`kite.toml` `[package]` accepts `description`, `authors`, `license`, `repository`, `homepage`, `readme`,
`keywords`. They are available to programs: `pkg_name()`, `pkg_version()`, `pkg_edition()`, `pkg_description()`,
`pkg_authors()`, `pkg_license()`, `pkg_repository()`, `pkg_homepage()`, `pkg_keywords()` (compiled in only when used).

## Writing and publishing a piece
```
kite init --lib my-piece   # src/lib.ki, kite.toml with metadata (authors from git config)
kite verify                # same checks as the registry CI
export KITE_PIECES=~/src/kite/pieces      # your clone of the Kite repository
kite publish               # validates, compiles, copies into pieces/community/my-piece/<version>/ and prints the commands
```
`kite publish` never runs git or touches GitHub: it prints `git checkout -b`, `git add`, `git commit`,
`git push` and `gh pr create` for you to run. The pull request is checked by `.github/workflows/pieces.yml`
(`scripts/verify-pieces.sh`): metadata complete (`description`, `license`, `authors`, valid name and semver),
directory names match `kite.toml` (`pieces/<tier>/<name>/<version>`), the piece compiles with its dependencies, and no existing version changed.
A published piece may only depend on registry pieces (no `path` dependencies).

## Build output (like cargo)
`target/debug/<name>` or `target/release/<name>` (`--release` = optimised, `-O3`), with the LLVM IR next to it and
a fingerprint (compiler version, flags, every source file of the package and its pieces). When nothing changed
kite prints `Fresh` and skips compilation. `--target <t>` builds into `target/<t>/<profile>/`.
