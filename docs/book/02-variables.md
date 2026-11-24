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
| `num` | `3`, `2.5` | an `int` or a `float`, see [num](#num-an-int-or-a-float) |
| `string` | `"hi"`, `"line\n"` | bytes; `\n \t \r \0 \e \\ \" \x41` escapes |
| `[T]` | `[1, 2, 3]` | list, see [Collections](/guide/collections/) |
| `(A, B)` | `(1, "a")` | tuple of scalars |
| `{"k": T}` | `{"a": 1}` | dictionary with literal keys |
| `ptr<T>` | `alloc(int)` | pointer, see [Memory](/guide/memory/) |

## Operators

`+ - * / %` on numbers (`+` also joins strings), `== != < > <= >=`, `and or not`, bit operators `& | ^ ~ << >>`.
Compound assignment: `x += 1`, `x -= 1`, ... and the readable `x.incr()` / `x.decr()` for `+1` / `-1`
(also on fields and list items: `self.count.incr()`, `items[2].decr()`).

## num: an int or a float

`num` is a number that is either an `int` or a `float`. Use it when a value may be one or the other (a price, a measurement,
the result of a calculation on mixed input). An `int` or a `float` is accepted wherever a `num` is expected.

```kite
make half(x: num) -> num:
    return x / 2

make main():
    a: num = 3                 // holds an int
    b: num = 2.5               // holds a float
    print(a + b)               // 5.5   (anything with a float is a float)
    print(a * 2)               // 6     (int with int stays an int)
    print(half(7))             // 3     (integer division)
    print(half(7.0))           // 3.5
    print(a < b)               // false
    print(b.as_int())          // 2     (a float is truncated)
    print(a.as_float())        // 3.0
    print(a.is_float())        // false
```

- Arithmetic (`+ - * / %`), comparisons and `-x` work on `num`, mixing freely with `int` and `float`.
- `print`, `str` and f-strings show a `num` naturally (`3`, `2.5`; a float with a whole value keeps its point: `3.0`).
- `x.as_int()` and `x.as_float()` convert out; `x.is_float()` tells which one it holds. Lists, record fields and parameters can be `num` (`[num]`).
- A variable is a `num` when you declare it as one (`x: num = 0`); `x = 0` alone makes an `int`.

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
