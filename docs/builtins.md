# Built-in functions

Always available, no import. Indexes are **0-based**.

| function | does |
|---|---|
| `print(x)` | prints one value and a newline (`int`, `float`, `bool`, `string`) |
| `str(x)` | `int`/`float`/`bool` → `string` (f-strings use it: `f"n={n}"`) |
| `len(x)` | length of a `string` or a list |
| `append(xs, v)` | adds `v` at the end of list `xs` |
| `pop(xs)` | removes and returns the last element |
| `remove(xs, i)` | removes and returns element `i` |
| `insert(xs, i, v)` | inserts `v` at index `i` |
| `clear(xs)` | empties the list |
| `char_at(s, i)` | byte value of the character at `i` |
| `substr(s, start, end)` | characters `start` … `end-1` |
| `read_file(path)` / `write_file(path, text)` | whole-file I/O |
| `arg(i)` / `arg_count()` | command-line arguments (`arg(0)` is the first one after the program) |
| `alloc(T)` / `alloc_n(T, n)` / `free(p)` | heap memory, see `pointers.md` |
| `exit(code)` | ends the program |

Out-of-range indexes stop the program with a message (no undefined behaviour).

## Prelude (written in Kite, compiled in only when used)
`split`, `join`, `find`, `trim`, `starts_with`, `ends_with`, `contains_str`, `replace_all`, `repeat`, `chr`,
`to_int`, `is_space`, `is_alpha`, `is_digit`, `is_alnum`, `min`, `max`, `abs` and the hash maps
`StrMap_int`, `StrMap_string`, `StrMap_float`, `StrMap_bool`, `StrMap_<YourStruct>`
(`m.set(k, v)`, `m.get(k)`, `m.has(k)`, `m.size()`, `m.keys`). Sources: `stdlib/prelude/`.
