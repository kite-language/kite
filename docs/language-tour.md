# A short tour of Kite

Kite reads like Python and compiles to native code. Indentation (4 spaces) is the block structure; there are no
braces or semicolons.

```
// A function: `make`, typed parameters, optional return type (inferred when omitted)
make area(w: int, h: int) -> int:
    return w * h

const LIMIT = 3                       // a constant (literal or any expression)

type Point:                           // a record
    x: int
    y: int

class Counter:                        // a record with methods
    total: int
    make add(self, n: int):
        self.total += n

enum Color:
    Red
    Green

make main():
    p = Point()                       // variables are created by assigning; the type is inferred
    p.x = 4
    names = ["ada", "linus"]          // lists, tuples (1, "a"), dictionaries {"k": 1}
    append(names, "grace")
    for i = 0 to len(names):          // `to` excludes the end; `for n in names:` iterates
        print(names[i])
    if area(2, 3) > 5 and not false:
        print("big")
    orif LIMIT == 3:                  // `orif` is elif
        print("limit")
    else:
        print("small")
    while LIMIT > 5:
        break
    try:
        print(read_file("missing.txt"))
    finally:
        print("done")
```

## Pieces (libraries)
```
use std.fs                            // a default piece, no declaration needed
use sha256                            // a community piece listed in kite.toml [dependencies]

make main():
    print(fs.exists("kite.toml"))     // piece.function(...) is fs_exists(...)
    print(sha256.hex("abc"))
    print(pkg_name() + " " + pkg_version())   // values from kite.toml
```

## Memory, pointers, threads
```
buf = alloc_n(int, 8)                 // ptr<int>
buf[0] = 42                           // p[i] or *(p + i)
buf = realloc_n(buf, 16)
free(buf)

make worker(arg: int):
    print(arg)
make main():
    h = spawn(worker, 7)              // runs worker(7) on a new thread
    thread_join(h)
```

## Conversions, escapes, errors
`float_of(3)`, `int_of(2.9)`, `str(12)`, `to_int("12")`; strings accept `\n \t \r \0 \e \\ \" \x41`.
`panic("message")` stops with exit code 101; `assert(cond, "why")` panics when `cond` is false.
Errors as values: `use std.error` (`Error`, `ResultInt`, ...).

## Commands
`kite init [--lib]`, `build [--release] [--target T]`, `run`, `check`, `test`, `fmt`, `doc`, `clean`, `add` / `remove`
/ `update` / `tree` / `search` / `info` / `publish` / `verify` (pieces), `target list|add|remove|show`, `bench`.

Rules that surprise newcomers: variables keep one type, names are function-scoped, a few words are reserved
(`to in from use type class match case enum thread try failed finally int float string bool ptr null`), and there
are no globals except `const`. The roadmap lists what is planned next: see `ROADMAP.md`.
