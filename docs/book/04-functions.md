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
