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

## Public and private items

By default everything is public. As soon as a file marks one top-level item `pub`, that file is in *explicit mode*:
the items without `pub` are **private to their piece** (every file under the piece's `src/`).

```kite
pub type Point:
    x: int
    y: int

pub make dist(a: Point, b: Point) -> int:     // part of the interface
    return abs(a.x - b.x) + abs(a.y - b.y)

make helper(n: int) -> int:                   // private: other pieces cannot call it
    return n * 2
```

`pub` works on `make`, `type`, `class`, `enum` and `const`. A class's methods follow the class. Using a private item
from another piece is error `E0080`. The [standard pieces](/reference/std-pieces/) reference lists only the `pub` items of a piece that uses `pub`.

> **Tip:** start private, and mark `pub` only what users of your piece need: it keeps the interface small and lets you change the rest freely.

## Importing names

Instead of writing `piece.function()` every time, import the functions you use by name:

```kite
use std.strings.{upper, lower}       // or: from std.strings import upper, lower
use std.option.{some, unwrap_or}

make main():
    print(upper("kite") + lower("ABC"))   // KITEabc
    print(unwrap_or(some(41), 0))
```

`upper` then stands for `strings.upper` in that file (a function of your own with the same name wins). Naming a function the piece
does not have is error `E0128`. The qualified form `strings.upper(...)` always keeps working.
