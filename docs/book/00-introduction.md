# Kite

Kite is a compiled language that reads like Python and runs like C. It has indentation-based blocks, static types
that are inferred, and no garbage collector pauses: your program is turned into native code by `kite build`.

```
make main():
    name = "Kite"
    print(f"Hello from {name}!")
```

**What you get**

- A compiler written in Kite itself (it compiles itself: stage 1 = stage 2 = stage 3).
- **Pieces**: Kite's packages. The language ships with 40 default pieces (`std.fs`, `std.json`, `std.random`, ...) and a
  community registry that lives in the repository.
- Threads, pointers and manual memory when you need them; strings, lists, tuples and dictionaries when you do not.
- `kite` does everything: `init`, `build`, `run`, `check`, `test`, `fmt`, `doc`, `add`, `publish`, `target`, ...
- A freestanding mode with its own tiny runtime, for kernels and microcontrollers.

**Where to start**

1. [Install Kite](/installation/) -- one command on Linux and macOS, one on Windows.
2. [Your first project](/guide/first-project/) -- `kite init`, `kite run`.
3. [Variables and types](/guide/variables/), [control flow](/guide/control-flow/), [functions](/guide/functions/).
4. [Pieces](/guide/pieces/) when you want a library, [the standard pieces](/reference/std-pieces/) for what is included.
