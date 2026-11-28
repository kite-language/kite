# Function values and lambdas

A function can be stored in a variable, passed to another function and returned like any other value. Its type is written
`fn(parameter types) -> result type`.

```kite
make double(x: int) -> int:
    return x * 2

make apply(f: fn(int) -> int, v: int) -> int:
    return f(v)                      // call a variable that holds a function

make main():
    f = double                       // a function name is a value
    print(f(21))                     // 42
    print(apply(double, 4))          // 8
```

Nothing is returned? Leave out the arrow: `fn(string)` is a function that takes a string and returns nothing.

## Lambdas

A **lambda** is a small function written where it is used: `|parameters| expression`.

```kite
print(apply(|x| x + 100, 5))                          // 105
g: fn(int, int) -> int = |a, b| a * b
k = |x: float| x / 2.0                                // write the type when nothing tells it
say: fn(string) = |s| print(s)
z = || 42                                             // no parameters
```

The parameter types come from the **expected** function type (`apply` above expects `fn(int) -> int`); a lambda assigned to a new variable
has no expected type, so annotate its parameters there (`|x: float|`). The result type is the type of the expression.

## Capturing variables (closures)

A lambda can use the variables of the function around it. It keeps a **copy** of their values from the moment the lambda is created:

```kite
make main():
    base = 1000
    add_base = |x: int| x + base          // captures base
    base = 5                              // the closure still sees 1000
    print(add_base(7))                    // 1007
    scale = 2.5
    half = |x: float| x * scale
    ys = iter.map([1, 2, 3], |n| n * 10 + base)    // captures work through iter.map too
```

Captured variables can be `int`, `float`, `bool`, `string`, pointers, enums and other functions (a closure can capture a closure).

## map, filter, reduce

The piece `std.iter` works on lists with function values (it is generic, so the element types are inferred):

```kite
use std.iter

make main():
    nums = [1, 2, 3, 4]
    squares = iter.map(nums, |x| x * x)               // [1, 4, 9, 16]
    evens = iter.filter(nums, |x| x % 2 == 0)         // [2, 4]
    print(iter.reduce(nums, 0, |acc, x| acc + x))     // 10
    print(iter.any(nums, |x| x > 3))                  // true
    iter.each(iter.range(3), |i| print(i * 10))
```

## Limits

- A lambda captures **a copy** of the variables it uses, taken when the lambda is created (see above); lists, records and `num` cannot be captured yet (`E0139`).
  The block that holds the captured values is not freed: do not create closures in a very long loop.
- Function values take and return `int`, `float`, `bool`, `string`, pointers and enums (not lists, records or `num` yet): error `E0131`.
- A function must have an explicit `-> Type` to be used as a value (`E0135`); a wrong argument count or type when calling one is `E0136` / `E0137`.
