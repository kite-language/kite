# Collections

## Listes

```kite
nums = [3, 1, 2]
append(nums, 9)             // ou nums.append(9)
print(nums[0])              // les indices commencent à 0
nums[1] = 10
x = pop(nums)               // retire et renvoie le dernier élément
insert(nums, 0, 7)          // insert(liste, indice, valeur)
remove(nums, 1)             // remove(liste, indice) renvoie la valeur retirée
clear(nums)
print(len(nums))

empty: [string] = []        // une liste vide a besoin d'un type
```

Lire en dehors de la liste arrête le programme avec un message clair. Tous les éléments partagent un seul type.

## Chaînes

Les chaînes sont des chaînes d'octets.

| fonction | exemple |
|----------|---------|
| `len(s)` | `len("abc")` vaut 3 |
| `substr(s, from, to)` | `substr("hello", 1, 3)` vaut `"el"` |
| `char_at(s, i)` | l'octet à la position `i`, en int |
| `find(s, sub)` | indice de `sub` ou -1 |
| `contains_str`, `starts_with`, `ends_with` | tests |
| `trim`, `split(s, sep)`, `join(list, sep)`, `replace_all(s, a, b)`, `repeat(s, n)` | transformations |
| `str(x)`, `chr(n)`, `to_int(s)` | conversions |

D'autres aides (casse, retour à la ligne, comptage, UTF-8) sont dans `std.strings` et `std.utf8`.

## Tuples et dictionnaires

```kite
pair = (1, "one")
print(pair[0])                    // l'indice d'un tuple doit être un littéral

person = {"name": "Ada", "age": 36}
print(person["name"])             // les clés sont des chaînes littérales
```

## Tables de hachage

```kite
ages = StrMap_int()            // clés chaînes ; aussi StrMap_string, StrMap_float, StrMap_bool
ages.set("ada", 36)
print(ages.get("ada"))         // 36
print(ages.has("bob"))         // false
ages.remove("ada")             // true s'il y était ; les autres clés gardent leur ordre
print(ages.size())
for key in ages.keys:          // ordre d'insertion
    print(key)
```

## Collections imbriquées

Les listes peuvent contenir des listes, à n'importe quelle profondeur, et les champs de structs aussi :

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

Une liste imbriquée vide a besoin d'un type : `rows: [[int]] = []`. Les listes de structs (`[Cell]`) et de tables (`[StrMap_int]`) fonctionnent de la même façon.
Les tuples ne contiennent encore que des scalaires.
