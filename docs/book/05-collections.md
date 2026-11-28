# Collections

## Lists

```
nums = [3, 1, 2]
append(nums, 9)             // or nums.append(9)
print(nums[0])              // indexes start at 0
nums[1] = 10
x = pop(nums)               // removes and returns the last element
insert(nums, 0, 7)          // insert(list, index, value)
remove(nums, 1)             // remove(list, index) returns the removed value
clear(nums)
print(len(nums))

empty: [string] = []        // an empty list needs a type
```

Reading outside the list stops the program with a clear message. All elements share one type.

## Strings

Strings are byte strings.

| function | example |
|----------|---------|
| `len(s)` | `len("abc")` is 3 |
| `substr(s, from, to)` | `substr("hello", 1, 3)` is `"el"` |
| `char_at(s, i)` | the byte at `i` as an int |
| `find(s, sub)` | index of `sub` or -1 |
| `contains_str`, `starts_with`, `ends_with` | tests |
| `trim`, `split(s, sep)`, `join(list, sep)`, `replace_all(s, a, b)`, `repeat(s, n)` | transformations |
| `str(x)`, `chr(n)`, `to_int(s)` | conversions |

More helpers (case, wrapping, counting, UTF-8) live in `std.strings` and `std.utf8`.

## Tuples and dictionaries

```
pair = (1, "one")
print(pair[0])                    // tuple index must be a literal

person = {"name": "Ada", "age": 36}
print(person["name"])             // keys are string literals
```

## Hash maps

```
ages = StrMap_int()            // string keys; also StrMap_string, StrMap_float, StrMap_bool
ages.set("ada", 36)
print(ages.get("ada"))         // 36
print(ages.has("bob"))         // false
ages.remove("ada")             // true if it was there; the other keys keep their order
print(ages.size())
for key in ages.keys:          // insertion order
    print(key)
```

## Nested collections

Lists can hold lists, to any depth, and so can struct fields:

```kite
type Board:
    cells: [[int]]
    names: [[string]]

make main():
    grid = [[1, 2], [3, 4]]
    append(grid, [5])
    grid[0][1] = 7
    print(len(grid[0]))              // 2
    for row in grid:
        for v in row:
            print(v)

    b = Board()
    append(b.cells, [1, 2, 3])
    print(b.cells[0][2])             // 3
```

An empty nested list needs a type: `rows: [[int]] = []`. Lists of structs (`[Cell]`) and of maps (`[StrMap_int]`) work the same way.
Tuples still hold scalars only.
