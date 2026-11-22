# Records, classes and enums

## type: a record

```
type Point:
    x: int
    y: int

make main():
    p = Point()          // all fields start at zero / empty
    p.x = 3
    p.y = 4
    print(p.x + p.y)
```

Records are copied when assigned (`q = p` copies). Fields may be ints, floats, bools, strings, lists, pointers and other
records. Field names may be reserved words (`job.thread`).

## class: a record with methods

```
class Counter:
    n: int
    make init(self):             // runs on `Counter()`
        self.n = 0
    make bump(self):
        self.n.incr()
    make value(self) -> int:
        return self.n

make main():
    c = Counter()
    c.bump()
    c.bump()
    print(c.value())             // 2
```

A class may extend another (`class Dog(Animal):`) and override its methods (dispatch is by the object's real class).
Classes are passed by reference to functions; records and ints are passed by value.

## enum

```
enum Color:
    Red
    Green
    Blue

make main():
    c = Color.Green
    if c == Color.Green:
        print("green")
```

Enums with data list their fields per variant. Construct a value as `Shape.Circle(2)` and take it apart with `match`
(add `else:` for the remaining variants, and when every arm returns):

```
enum Shape:
    Circle(r: int)
    Rect(w: int, h: int)

make area(s: Shape) -> int:
    match s:
        case Circle(r):
            return 3 * r * r
        case Rect(w, h):
            return w * h
        else:
            return 0

make main():
    print(area(Shape.Rect(2, 5)))
```

Recursive data holds pointers to itself: `Add(l: ptr<Expr>, r: ptr<Expr>)`.
