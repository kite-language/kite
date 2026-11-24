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
| `num` | `3`, `2.5` | un `int` ou un `float`, voir [num](#num-un-int-ou-un-float) |
| `string` | `"hi"`, `"line\n"` | octets ; échappements `\n \t \r \0 \e \\ \" \x41` |
| `[T]` | `[1, 2, 3]` | liste, voir [Collections](/guide/collections/) |
| `(A, B)` | `(1, "a")` | tuple de scalaires |
| `{"k": T}` | `{"a": 1}` | dictionnaire à clés littérales |
| `ptr<T>` | `alloc(int)` | pointeur, voir [Mémoire](/guide/memory/) |

## Opérateurs

`+ - * / %` sur les nombres (`+` concatène aussi les chaînes), `== != < > <= >=`, `and or not`, opérateurs binaires `& | ^ ~ << >>`.
Affectation composée : `x += 1`, `x -= 1`, ... et le lisible `x.incr()` / `x.decr()` pour `+1` / `-1`
(aussi sur les champs et les éléments de liste : `self.count.incr()`, `items[2].decr()`).

## num : un int ou un float

`num` est un nombre qui est soit un `int`, soit un `float`. Utilisez-le quand une valeur peut être l'un ou l'autre (un prix, une mesure,
le résultat d'un calcul sur des entrées mixtes). Un `int` ou un `float` est accepté partout où un `num` est attendu.

```kite
make half(x: num) -> num:
    return x / 2

make main():
    a: num = 3                 // contient un int
    b: num = 2.5               // contient un float
    print(a + b)               // 5.5   (tout ce qui contient un float est un float)
    print(a * 2)               // 6     (int avec int reste un int)
    print(half(7))             // 3     (division entière)
    print(half(7.0))           // 3.5
    print(a < b)               // false
    print(b.as_int())          // 2     (un float est tronqué)
    print(a.as_float())        // 3.0
    print(a.is_float())        // false
```

- L'arithmétique (`+ - * / %`), les comparaisons et `-x` fonctionnent sur `num`, en se mélangeant librement avec `int` et `float`.
- `print`, `str` et les f-strings affichent naturellement un `num` (`3`, `2.5` ; un float de valeur entière garde son point : `3.0`).
- `x.as_int()` et `x.as_float()` convertissent vers l'extérieur ; `x.is_float()` indique lequel il contient. Les listes, champs de records et paramètres peuvent être `num` (`[num]`).
- Une variable est un `num` quand vous la déclarez comme telle (`x: num = 0`) ; `x = 0` seul fait un `int`.

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
