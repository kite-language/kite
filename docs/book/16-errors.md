# Errors: Result, Option and `?`

Kite has no exceptions. A function that can fail returns a **`Result`**, and a function that may have nothing to return gives an
**`Option`**. Both are ordinary generic records from the default pieces `std.result` and `std.option`.

```kite
use std.result

make digit(c: string) -> Result<int, string>:
    r = Result<int, string>()                  // an empty Result to fill in
    if c >= "0" and c <= "9":
        return result.ok(r, to_int(c))
    return result.err(r, f"not a digit: {c}")

make main():
    r = digit("x")
    if result.is_err(r):
        print(result.error(r))                 // not a digit: x
    print(result.unwrap_or(digit("7"), 0))     // 7
```

## The `?` operator

Calling several functions that can fail would mean an `if` after every call. Put **`?`** after the call instead: when the call fails, the
current function returns that failure straight away; when it succeeds you get the value.

```kite
make two_digits(a: string, b: string) -> Result<int, string>:
    x = digit(a)?                              // on an error: return it from two_digits
    y = digit(b)?
    r = Result<int, string>()
    return result.ok(r, x * 10 + y)

make sum3(a: string, b: string, c: string) -> Result<int, string>:
    r = Result<int, string>()
    return result.ok(r, digit(a)? + digit(b)? + digit(c)?)   // several `?` in one expression, left to right
```

It works the same with `Option`: `i = find(xs, 6)?` returns an empty `Option` from the current function when nothing was found.

Rules:

- The function that uses `?` must itself return a `Result<T, E>` (with the same error type `E`) or an `Option<T>`: otherwise error `E0144`.
- `?` can appear in an assignment, a call statement, a `return` or an `if` condition. It cannot be used in a loop condition, on the right of `and` / `or`
  (it might not run), or inside a lambda (`E0141`, `E0142`); anywhere else it is error `E0143`.
- It is only a shortcut for an `if`: you can still look at `r.is_ok`, `r.value` and `r.error` yourself.
