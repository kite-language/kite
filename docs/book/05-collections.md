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
print(ages.size())
for key in ages.keys:          // insertion order
    print(key)
```

## Lists of lists?

Nested collections are on the [roadmap](/project/roadmap/); today use a flat list with an index formula, or a record.
