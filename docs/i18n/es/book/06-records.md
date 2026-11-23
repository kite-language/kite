# Registros, clases y enums

## type: un registro

```kite
type Point:
    x: int
    y: int

make main():
    p = Point()          // todos los campos empiezan en cero / vacíos
    p.x = 3
    p.y = 4
    print(p.x + p.y)
```

Los registros se copian al asignarlos (`q = p` copia). Los campos pueden ser ints, floats, bools, cadenas, listas, punteros y otros
registros. Los nombres de campo pueden ser palabras reservadas (`job.thread`).

## class: un registro con métodos

```kite
class Counter:
    n: int
    make init(self):             // se ejecuta en `Counter()`
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

Una clase puede extender otra (`class Dog(Animal):`) y sobrescribir sus métodos (el despacho depende de la clase real del objeto).
Las clases se pasan por referencia a las funciones; los registros y los ints se pasan por valor.

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

Los enums con datos listan sus campos por variante. Construye un valor como `Shape.Circle(2)` y descompónlo con `match`
(añade `else:` para las variantes restantes, y cuando todas las ramas devuelven):

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

Los datos recursivos guardan punteros a sí mismos: `Add(l: ptr<Expr>, r: ptr<Expr>)`.
