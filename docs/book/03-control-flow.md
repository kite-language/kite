# Control flow

```
if score >= 90:
    print("A")
orif score >= 80:          // `orif` is `else if`
    print("B")
else:
    print("C")
```

```
while i < 10:
    i.incr()

until done:                // loops until the condition is true
    step()

for i = 0 to 5:            // 0, 1, 2, 3, 4  (the end is excluded)
    print(i)

for item in items:         // every element of a list
    print(item)

infinit:                   // loop forever, leave with `break`
    if finished():
        break
```

`break` leaves the nearest loop, `continue` jumps to its next turn. Loop variables belong to the function.

## try / finally

```
make load(path: string) -> string:
    text = ""
    try:
        text = read_file(path)
        return text
    finally:
        print("done reading")        // runs before the `return` leaves the block
```

`finally` always runs after the block, including before a `return`, `break` or `continue` that leaves it. Kite has no
exceptions yet: a `failed:` block is accepted by the parser but never runs (it is reserved for the error-propagation
work on the [roadmap](/project/roadmap/)). Report problems with return values (`std.error`) or `panic`.

## Stopping the program

`exit(code)` ends the process; `panic("message")` prints `panic: message` and exits with code 101;
`assert(condition, "why")` panics when the condition is false.
