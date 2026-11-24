# Generics

Generics let one definition work for many types. Kite has **generic functions** and **generic records**; both are
specialised at compile time (one copy per combination of types), so they cost nothing at run time.

## Generic functions

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

make main():
    print(first([4, 5, 6]))        // T = int
    print(first(["a", "b"]))       // T = string
```

The compiler infers the type parameters from the arguments. A type parameter can appear as `T`, `[T]`, `ptr<T>` or inside a
generic record such as `Box<T>`. If it cannot be deduced, the call is error `E0123`.

## Generic records

```kite
type Box<T>:
    value: T
    count: int

type Pair<A, B>:
    first: A
    second: B

make main():
    b = Box<int>()                 // type arguments in angle brackets
    b.value = 41
    p = Pair<string, int>()
    p.first = "k"
    p.second = 7

    boxes: [Box<int>] = []         // also in types
    append(boxes, b)
    nested = Box<Box<int>>()       // and nested
```

`Box<int>` and `Box<string>` are two different types made from the same definition. Generic functions can take and return
them: `make wrap<T>(x: T) -> Box<T>:` and `make unwrap<T>(b: Box<T>) -> T:`.
Generic records are plain `type` records (no generic classes or enums yet).

## Option and Result

Two generic records are ready to use:

```kite
use std.option
use std.result

make find(xs: [int], x: int) -> Option<int>:
    i = 0
    for v in xs:
        if v == x:
            return option.some(i)
        i.incr()
    return Option<int>()                    // an empty Option is "none"

make digit(c: string) -> Result<int, string>:
    r = Result<int, string>()               // an empty Result to fill in
    if c >= "0" and c <= "9":
        return result.ok(r, to_int(c))
    return result.err(r, f"not a digit: {c}")

make main():
    print(option.unwrap_or(find([4, 5, 6], 9), -1))     // -1
    r = digit("x")
    if result.is_err(r):
        print(result.error(r))                           // not a digit: x
```

> **Note:** `Option` and `Result` are ordinary generic records, so you can read their fields (`o.has`, `o.value`, `r.is_ok`).

## Explicit type arguments (templates)

Normally the type parameters are inferred. You can also give them yourself, in angle brackets before the arguments, as in C++
templates. This is the way to call a generic function whose type cannot be deduced from its arguments:

```kite
make zero<T>() -> T:
    z: T = 0
    return z

make convert<A, B>(a: A, b: B) -> B:
    return b

make main():
    print(zero<int>())                    // nothing to infer T from: say it
    print(first<string>(["x", "y"]))      // same as first(["x", "y"])
    print(convert<int, string>(1, "two"))
```

Type arguments are written with type names that start with an uppercase letter (`Point`, `Box<int>`), the built-in types
(`int`, `float`, `bool`, `string`, `num`, `[int]`, `ptr<int>`), so `a < b > (c)` is still a comparison.
Giving more type arguments than the function has is error `E0127`.
