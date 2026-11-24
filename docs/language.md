# Kite language reference (0.3)

Kite reads like Python, compiles through LLVM to C-class machine code and
keeps a minimum of Rust-style safety (bounds-checked lists, typed pointers).

## Basics
- Blocks are indented. Comments start with `//`.
- Everything is 0-based: lists, `char_at`, `substr(s, start, end)` (end exclusive),
  `arg(0)` is the first command-line argument.
- Loops: `while cond:` / `until cond:` (stop when true) / `for x in xs:` /
  `for i = a to b:` (end exclusive) / `infinit:`.
- Operators: `+ - * / %`, comparisons (also on strings), `and or not`,
  bit ops `& | ^ << >> ~`, and **every compound form**: `+= -= *= /= %= &= |= ^= <<= >>=`.

## Strings
- f-strings: `f"hello {name}, {n + 1} {{literal braces}}"`.
- `str(x)` converts `int`/`float`/`bool`; `+` concatenates.
- Prelude helpers (compiled in only when used): `split join find trim
  starts_with ends_with contains_str replace_all repeat chr to_int is_space
  is_alpha is_digit is_alnum min max abs`.

## Functions
- Defaults, named arguments, variadics:
  `make f(a: int, b: int = 2, *rest: int)`, `f(1, b=5)`.
- Any value can be passed and returned: lists, tuples, structs, classes.
  Aggregates are passed by reference (callee mutations are visible), unless
  the callee reassigns the parameter name (then it works on a copy).
- Types in signatures: `int float bool string [T] (A, B) ptr<T> StructName`.
- Tuple unpacking: `a, b = pair()`.

## Collections
- Lists of scalars, strings, structs: `append pop remove(xs, i) insert(xs, i, v) clear len`.
- Typed empty list: `xs: [Tok] = []`.
- Structs can hold lists and other structs; `obj.items` aliases the real field,
  `append(obj.items, x)` mutates it.
- Hash maps: `m = StrMap_int()` (string keys; `StrMap_string`, `StrMap_float`,
  `StrMap_bool`, or `StrMap_<YourStruct>`): `m.set(k, v)`, `m.get(k)`, `m.has(k)`,
  `m.size()`, `m.keys` (insertion order).

## Classes
```
class Animal:
    name: string
    make init(self, name: string):
        self.name = name
    make speak(self) -> string:
        return "..."

class Dog(Animal):
    make speak(self) -> string:
        return "woof"
```
- `Dog("Rex")` calls `init`; `Animal.init(self, name)` calls the base version.
- Single inheritance; methods overridden in subclasses are dispatched
  dynamically (hidden class tag), so `a.speak()` on an `Animal` parameter that
  holds a `Dog` calls `Dog.speak`. A `Dog` can be passed where an `Animal` is expected.
- The receiver's class is inferred from assignments, annotated parameters and
  function return types.

## Data enums and `match`
```
enum Expr:
    Num(v: int)
    Add(l: ptr<Expr>, r: ptr<Expr>)
    Nil

match x:
    case Num(v):
        ...
    case Add(l, r):
        ...
    else:
        ...
```
Construct with `Expr.Num(3)`. Plain enums (`enum Color: Red, Green`) stay integer tags.

## Pointers and `null`
- `p = alloc(T)`, `*p = value`, `v = *p`, `p.field` / `p.field = x` (auto-deref).
- `null` takes its type from context (assignment target, argument, return type).
- Recursive data = data enums / structs holding `ptr<Self>`.

## Not in 0.2
`**kwargs`, generic user types, struct value-copy-vs-alias parity with Python for `b = a`,
dict literals with keys added at run time (use `StrMap_T`), map key deletion.

## Visibility (`pub`)

`pub` before `make`, `type`, `class`, `enum` or `const` exports the item. A file that uses `pub` at least once is in explicit mode:
its other top-level items are private to the piece (the `src/` tree they live in). Files without `pub` keep everything public.
Class methods follow their class. `pub` is only a keyword in front of an item: it can still be used as a variable name.
Using a private item of another piece is error `E0080`.

## Generic functions (0.4.6)

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

## Constants (0.4.8)

`const NAME = expr` (or `const NAME: type = expr`) works at the top level and inside functions, with any type (numbers, strings,
f-strings, lists, records) and may use other constants. Constants are read-only: assigning to one, or changing a field of a constant record, is error `E0124`.

## Words usable as names (0.4.8)

`from use type class match case enum thread try failed finally` are keywords only where their keyword meaning applies; elsewhere they are
ordinary names: `from = 3`, `print(type)`, `make span(from: int, case: int)`, `for finally in xs`, f-strings `f"{try}"`.
Still reserved: `to`, `in`, the type names (`int float string bool ptr`) and `null`.

## The `num` type (0.5.0)

`num` holds an `int` or a `float`. `x: num = 3` and `x: num = 2.5` are both valid; an `int` or `float` is converted where a `num` is expected
(assignments, arguments, returns, `append`). `+ - * / %`, comparisons and unary `-` accept a `num` on either side; int with int gives an int,
anything with a float gives a float. `x.as_int()`, `x.as_float()`, `x.is_float()`; `print`, `str` and f-strings show it. It is a record
(`is_float`, `i`, `f`) with helper functions that the compiler adds only to programs that use the type.

## Explicit type arguments (0.5.0)

`first<int>(xs)`, `zero<int>()`, `convert<int, string>(a, b)` give the type parameters of a generic function explicitly. See [Generics](/guide/generics/).

## Conditional compilation: `when` (0.5.0)

`when windows:` ... `else:` ... keeps the block for that target and removes it for the others (items and statements); conditions are
`windows linux macos unix bare x86_64 aarch64 riscv64`, `os == "..."`, `arch == "..."`, combined with `not and or`. See [Conditional compilation](/guide/conditional/).
