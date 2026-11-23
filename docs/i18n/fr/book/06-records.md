# Records, classes et enums

## type : un record

```kite
type Point:
    x: int
    y: int

make main():
    p = Point()          // tous les champs démarrent à zéro / vides
    p.x = 3
    p.y = 4
    print(p.x + p.y)
```

Les records sont copiés à l'assignation (`q = p` copie). Les champs peuvent être des ints, floats, bools, chaînes, listes, pointeurs et autres
records. Les noms de champs peuvent être des mots réservés (`job.thread`).

## class : un record avec des méthodes

```kite
class Counter:
    n: int
    make init(self):             // s'exécute sur `Counter()`
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

Une classe peut en étendre une autre (`class Dog(Animal):`) et redéfinir ses méthodes (le dispatch se fait selon la vraie classe de l'objet).
Les classes sont passées par référence aux fonctions ; les records et les ints sont passés par valeur.

## enum

```kite
enum Color:
    Red
    Green
    Blue

make main():
    c = Color.Green
    if c == Color.Green:
        print("green")
```

Les enums avec données listent leurs champs par variante. Construisez une valeur avec `Shape.Circle(2)` et décomposez-la avec `match`
(ajoutez `else:` pour les variantes restantes, et quand chaque branche retourne) :

```kite
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

Les données récursives contiennent des pointeurs vers elles-mêmes : `Add(l: ptr<Expr>, r: ptr<Expr>)`.
