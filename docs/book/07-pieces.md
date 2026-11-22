# Pieces (packages)

A **piece** is a library: a folder with `kite.toml` and `src/lib.ki`.

```
kite init --lib shapes     // create one
kite add sha256            // use one (see below)
```

## Two kinds

- **Default pieces** (`std.*`) ship with Kite and need no declaration: `use std.fs`.
- **Community pieces** live in the repository's registry. Declare them in `[dependencies]` (`kite add table`) and
  import them by name: `use table`.

```
use std.strings         // a default piece
use table               // a community piece (listed in kite.toml)

make main():
    t = table_new(2)
    table_add_row(t, ["name", "qty"])
    print(table_render(t))
    print(strings.upper("kite"))     // piece.function(...) calls
```

## Calling pieces

`piece.function(args)` is the readable way to call a piece. It means the function called `<piece>_<function>`:
`fs.read(path)` is `fs_read(path)`, `strings.upper(s)` is `strings_upper(s)`. If a local variable has the same name as the
piece, the variable wins (use the long name).

Functions of all pieces share one namespace under the hood, so name yours `<piece>_<function>`.

## Managing dependencies

```
kite search json       # find pieces
kite info semver       # metadata and versions
kite add sha256@^1.2   # add with a requirement (^ ~ >= < =)
kite tree              # dependency tree (sub-dependencies included)
kite update            # re-resolve kite.lock
kite remove sha256
```

`kite.lock` records exact versions and checksums; if a registry copy changes, the build stops.

## Publishing

```
kite verify            # same checks as the registry CI
kite publish           # prepares pieces/community/<name>/<version>/ and prints the git commands
```

`kite publish` never runs git: you run the printed commands and open a pull request; CI compiles every changed piece.
