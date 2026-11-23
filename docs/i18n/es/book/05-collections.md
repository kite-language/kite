# Colecciones

## Listas

```kite
nums = [3, 1, 2]
append(nums, 9)             // o nums.append(9)
print(nums[0])              // los índices empiezan en 0
nums[1] = 10
x = pop(nums)               // quita y devuelve el último elemento
insert(nums, 0, 7)          // insert(lista, índice, valor)
remove(nums, 1)             // remove(lista, índice) devuelve el valor quitado
clear(nums)
print(len(nums))

empty: [string] = []        // una lista vacía necesita un tipo
```

Leer fuera de la lista detiene el programa con un mensaje claro. Todos los elementos comparten un único tipo.

## Cadenas

Las cadenas son cadenas de bytes.

| función | ejemplo |
|---------|---------|
| `len(s)` | `len("abc")` es 3 |
| `substr(s, from, to)` | `substr("hello", 1, 3)` es `"el"` |
| `char_at(s, i)` | el byte en `i`, como int |
| `find(s, sub)` | índice de `sub` o -1 |
| `contains_str`, `starts_with`, `ends_with` | comprobaciones |
| `trim`, `split(s, sep)`, `join(list, sep)`, `replace_all(s, a, b)`, `repeat(s, n)` | transformaciones |
| `str(x)`, `chr(n)`, `to_int(s)` | conversiones |

Más ayudas (mayúsculas, ajuste de línea, conteo, UTF-8) están en `std.strings` y `std.utf8`.

## Tuplas y diccionarios

```kite
pair = (1, "one")
print(pair[0])                    // el índice de una tupla debe ser un literal

person = {"name": "Ada", "age": 36}
print(person["name"])             // las claves son cadenas literales
```

## Tablas hash

```kite
ages = StrMap_int()            // claves de cadena; también StrMap_string, StrMap_float, StrMap_bool
ages.set("ada", 36)
print(ages.get("ada"))         // 36
print(ages.has("bob"))         // false
print(ages.size())
for key in ages.keys:          // orden de inserción
    print(key)
```

## Colecciones anidadas

Las listas pueden contener listas, a cualquier profundidad, y los campos de los registros también:

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

Una lista anidada vacía necesita un tipo: `rows: [[int]] = []`. Las listas de registros (`[Cell]`) y de tablas (`[StrMap_int]`) funcionan igual.
Las tuplas todavía solo contienen escalares.
