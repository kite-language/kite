# Aide-mémoire

Une page avec la syntaxe de tous les jours.

## Les bases

```kite
// un commentaire
name = "Kite"            // une variable se crée par assignation
count: int = 0           // type facultatif
const LIMIT = 10         // une constante
print(f"{name} has {count} items, limit {LIMIT}")
```

## Structures de contrôle

```kite
if x > 0:
    print("positive")
orif x == 0:
    print("zero")
else:
    print("negative")

for i = 0 to 5:          // 0, 1, 2, 3, 4 (la fin est exclue)
    print(i)
for item in items:
    print(item)
while n > 0:
    n -= 1
```

## Fonctions

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
person = {"name": "Ada", "age": 36}     // les clés sont des chaînes littérales
ages = StrMap_int()                    // table de hachage à clés chaînes
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

## Visibilité dans les pièces

```kite
pub make area(w: int, h: int) -> int:    // utilisable depuis d'autres pièces
    return w * h

make helper() -> int:                    // privé à la pièce (quand le fichier utilise `pub`)
    return 1
```

## Fonctions génériques

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

print(first([4, 5, 6]))
print(first(["a", "b"]))
```

## Commandes

| commande | ce qu'elle fait |
|----------|-----------------|
| `kite init NOM` | crée un projet (`--lib` pour une pièce) |
| `kite run` | compile et exécute |
| `kite build --release` | compilation optimisée |
| `kite check` | vérifie seulement les types |
| `kite test` | exécute `tests/*.ki` |
| `kite add NOM` | ajoute une pièce à `[dependencies]` |
| `kite fmt` | corrige les espaces |
