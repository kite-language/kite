# Your first project

```
kite init hello
cd hello
kite run
```

`kite init` creates:

| file | purpose |
|------|---------|
| `kite.toml` | the manifest: name, version, description, authors, license, dependencies |
| `src/main.ki` | the program: a `make main():` function |
| `.gitignore` | ignores `target/` |

`src/main.ki`:

```
make main():
    print("Hello, Kite!")
```

## The commands you will use every day

| command | what it does |
|---------|--------------|
| `kite run` | build (if needed) and run |
| `kite build [--release]` | compile to `target/debug/<name>` or `target/release/<name>` (`--release` optimises) |
| `kite check` | type-check only (fast) |
| `kite test` | build and run every `tests/*.ki` |
| `kite fmt [--check]` | normalise whitespace |
| `kite doc` | write `target/doc/<name>.md` from your `//` comments |
| `kite clean` | remove `target/` |

When nothing changed kite prints `Fresh` and skips the compiler: the build is cached by a fingerprint of your sources,
your pieces and the compiler version.

## Package metadata in your program

`kite.toml` can describe the package, and the program can read it:

```
[package]
name = "hello"
version = "0.1.0"
description = "My first Kite program"
authors = ["Ada <ada@example.com>"]
license = "MIT"
```

```
make main():
    print(f"{pkg_name()} {pkg_version()} by {pkg_authors()}")
```

Every binary also carries a signature (`kite inspect target/debug/hello` shows the package, the compiler and the build).
