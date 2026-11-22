# Variables, types and conversions

A variable is created by assigning to it. Its type is inferred and **cannot change**; names live in the function that
creates them.

```
count = 0            // int
price = 9.5          // float
ready = true         // bool
name = "Kite"        // string
```

Annotate when you want to be explicit (or for `null`):

```
total: int = 0
p: ptr<int> = null
```

## The types

| type | examples | notes |
|------|----------|-------|
| `int` | `42`, `-7`, `0` | 64-bit signed |
| `float` | `3.14`, `0.5` | 64-bit |
| `bool` | `true`, `false` | |
| `string` | `"hi"`, `"line\n"` | bytes; `\n \t \r \0 \e \\ \" \x41` escapes |
| `[T]` | `[1, 2, 3]` | list, see [Collections](/guide/collections/) |
| `(A, B)` | `(1, "a")` | tuple of scalars |
| `{"k": T}` | `{"a": 1}` | dictionary with literal keys |
| `ptr<T>` | `alloc(int)` | pointer, see [Memory](/guide/memory/) |

## Operators

`+ - * / %` on numbers (`+` also joins strings), `== != < > <= >=`, `and or not`, bit operators `& | ^ ~ << >>`.
Compound assignment: `x += 1`, `x -= 1`, ... and the readable `x.incr()` / `x.decr()` for `+1` / `-1`
(also on fields and list items: `self.count.incr()`, `items[2].decr()`).

## Converting

| from | to | how |
|------|----|-----|
| anything printable | `string` | `str(x)` or an f-string |
| `string` | `int` | `to_int("42")` |
| `int` | `float` | `float_of(3)` |
| `float` | `int` | `int_of(2.9)` (truncates) |

## Building strings

Use **f-strings** instead of long `+` chains:

```
name = "Kite"
n = len(name)
print(f"{name} has {n} letters")      // Kite has 4 letters
```

Any expression without quotes fits in `{ }`; for anything else compute it first.
