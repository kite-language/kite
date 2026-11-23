# Functions and constants

```
make area(w: int, h: int) -> int:
    return w * h

make greet(name: string):          // no `->`: returns nothing
    print(f"Hello, {name}!")
```

- Parameters are typed; the return type may be omitted and is then inferred from the first `return`.
- Recursive and mutually recursive functions need an explicit `-> Type`.
- Defaults and named arguments: `make connect(host: string, port: int = 80)` is called as `connect("a")` or
  `connect("a", port = 8080)`.
- `*items: int` collects extra arguments into a list `items` of that element type (`total(1, 2, 3)`).
- Return several values with a tuple: `return (1, "one")`, receive them with `n, word = pair()`.

## Constants

```
const LIMIT = 100
const GREETING: string = "hello"
```

A constant is read like a variable and cannot be assigned. (Internally it is a zero-argument function, so it can be any
expression.)

A constant can also be declared **inside a function**, and any constant is read-only: assigning to it (`LIMIT = 9`, `LIMIT += 1`,
`LIMIT.incr()`, or changing a field of a constant record) is error `E0124`.

```kite
const LIMIT = 100                  // global: visible everywhere

make main():
    const STEP = LIMIT / 4         // local to this function
    total = 0
    total += STEP                  // fine: `total` is an ordinary variable
```

## Calling functions

Three equivalent spellings; use whichever reads best:

```
len(text)           // plain call
text.len()          // uniform call syntax: value.f(args) is f(value, args)
```

Uniform call syntax makes chains read left to right, and chains may continue on the next line:

```
words = "  one, two ,three  "
    .trim()
    .split(",")
```

It applies to any value that is not a class instance (class methods keep their own meaning).

## Documentation comments

`//` comments directly above a function, type or class are collected by `kite doc`.

## Generic functions

A function can take **type parameters** in angle brackets. The compiler infers them from the arguments and makes one specialised copy
per combination of types, so a generic function is as fast as one you wrote by hand.

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

make pick<A, B>(a: A, b: B) -> A:
    return a

make main():
    print(first([4, 5, 6]))        // 4      (T = int)
    print(first(["a", "b"]))       // a      (T = string)
    print(pick(7, "x"))            // 7      (A = int, B = string)
```

- A type parameter can appear in a parameter type as `T`, `[T]` or `ptr<T>`, and in the return type and the body.
- Every type parameter must be deducible from the arguments (`E0123` otherwise); two parameters of the same `T` must agree (`E0122`).
- Generic functions are top-level only (no generic methods) and need `-> Type` when they return a value.
- Generic records (`Box<T>`) and the ready-made `Option<T>` / `Result<T, E>` are in the chapter [Generics](/guide/generics/).
