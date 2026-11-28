# Troubleshooting

## `clang failed to compile the generated LLVM IR`

Kite writes LLVM IR and asks `clang` to compile it. The error message names the `.ll` file in `target/`: open it at the reported line.
If the program is plain Kite, this is a compiler bug: please report it with the `.ll` file.

## `clang: command not found`

Install clang (`sudo apt install clang`, `xcode-select --install`, or `winget install LLVM.LLVM`).

## `E0080: ... is private to the piece that defines it`

The piece marks some items `pub`, so the others are private. Ask the piece author to mark the item `pub`, or use a public function instead.
Inside your own project there is no such restriction unless your file uses `pub`.

## `E0072: piece ... has no function ...`

Functions of a piece are called as `piece.function(...)`. The piece must be imported (`use std.fs`, or `use name` after `kite add name`).
See the function list in the [standard pieces](/reference/std-pieces/).

## A variable cannot be used as a name

A few words are reserved (`to in int float string bool ptr null`),
and the built-in names `str len print append pop remove insert clear free arg` are taken. Pick another name.
Words such as `from`, `type`, `use`, `match`, `case`, `class`, `thread` or `try` are fine as names (`from = 3`, `make f(case: int)`);
after a `.` any word is accepted: `job.thread`.

## Segmentation fault with lists inside classes

Assigning a class copies its header, so two names can share one buffer. Use `self.items.append(x)`, not a copy such as `items = self.items`.

## A string field crashes `len()`

A `string` field of a freshly created record is a null pointer until you set it. Set the field before reading it.

## Windows: link errors about `printf` or `timespec_get`

Update to the latest version (these symbols are provided by Kite's own shims). Run `kite build` again and report the full output if it still fails.

## Colours in error messages

Errors are coloured on a terminal. Set `NO_COLOR=1` to turn the colours off, or `KITE_COLOR=always` / `KITE_COLOR=never` to force them on or off (for example in a CI log).
