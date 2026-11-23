# Variables, types et conversions

Une variable se crée en lui assignant une valeur. Son type est inféré et **ne peut pas changer** ; les noms vivent dans la fonction qui
les crée.

```kite
count = 0            // int
price = 9.5          // float
ready = true         // bool
name = "Kite"        // string
```

Annotez quand vous voulez être explicite (ou pour `null`) :

```kite
total: int = 0
p: ptr<int> = null
```

## Les types

| type | exemples | remarques |
|------|----------|-----------|
| `int` | `42`, `-7`, `0` | entier signé sur 64 bits |
| `float` | `3.14`, `0.5` | 64 bits |
| `bool` | `true`, `false` | |
| `string` | `"hi"`, `"line\n"` | octets ; échappements `\n \t \r \0 \e \\ \" \x41` |
| `[T]` | `[1, 2, 3]` | liste, voir [Collections](/guide/collections/) |
| `(A, B)` | `(1, "a")` | tuple de scalaires |
| `{"k": T}` | `{"a": 1}` | dictionnaire à clés littérales |
| `ptr<T>` | `alloc(int)` | pointeur, voir [Mémoire](/guide/memory/) |

## Opérateurs

`+ - * / %` sur les nombres (`+` concatène aussi les chaînes), `== != < > <= >=`, `and or not`, opérateurs binaires `& | ^ ~ << >>`.
Affectation composée : `x += 1`, `x -= 1`, ... et le lisible `x.incr()` / `x.decr()` pour `+1` / `-1`
(aussi sur les champs et les éléments de liste : `self.count.incr()`, `items[2].decr()`).

## Convertir

| depuis | vers | comment |
|--------|------|---------|
| tout ce qui s'affiche | `string` | `str(x)` ou une f-string |
| `string` | `int` | `to_int("42")` |
| `int` | `float` | `float_of(3)` |
| `float` | `int` | `int_of(2.9)` (tronque) |

## Construire des chaînes

Utilisez les **f-strings** plutôt que de longues chaînes de `+` :

```kite
name = "Kite"
n = len(name)
print(f"{name} has {n} letters")      // Kite has 4 letters
```

Toute expression sans guillemets tient dans `{ }` ; pour le reste, calculez-la d'abord.
