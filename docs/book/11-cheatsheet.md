# Cheat sheet

One page with the syntax you use every day.

## Basics

```kite
// a comment
name = "Kite"            // variables are created by assignment
count: int = 0           // optional type
const LIMIT = 10         // a constant
print(f"{name} has {count} items, limit {LIMIT}")
```

## Control flow

```kite
if x > 0:
    print("positive")
orif x == 0:
    print("zero")
else:
    print("negative")

for i = 0 to 5:          // 0, 1, 2, 3, 4 (the end is excluded)
    print(i)
for item in items:
    print(item)
while n > 0:
    n -= 1
```

## Functions

```kite
make area(w: int, h: int = 1) -> int:
    return w * h

print(area(3))
print(area(3, h = 4))
```

## Collections

```kite
xs = [1, 2, 3]
append(xs, 4)
person = {"name": "Ada", "age": 36}     // keys are string literals
ages = StrMap_int()                    // hash map with string keys
ages.set("ada", 36)
```

## Records, classes, enums

```kite
type Point:
    x: int
    y: int

class Counter:
    n: int
    make bump(self):
        self.n += 1

enum Shape:
    Circle(r: int)
    Square(side: int)
```

## Visibility in pieces

```kite
pub make area(w: int, h: int) -> int:    // usable from other pieces
    return w * h

make helper() -> int:                    // private to the piece (when the file uses `pub`)
```

## Generic functions

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

print(first([4, 5, 6]))
print(first(["a", "b"]))
```

## Commands

| command | what it does |
|---------|--------------|
| `kite init NAME` | create a project (`--lib` for a piece) |
| `kite run` | build and run |
| `kite build --release` | optimised build |
| `kite check` | type-check only |
| `kite test` | run `tests/*.ki` |
| `kite add NAME` | add a piece to `[dependencies]` |
| `kite fmt` | fix whitespace |
