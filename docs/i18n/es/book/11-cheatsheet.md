# Hoja de referencia rápida

Una página con la sintaxis de cada día.

## Lo básico

```kite
// un comentario
name = "Kite"            // una variable se crea al asignarla
count: int = 0           // tipo opcional
const LIMIT = 10         // una constante
print(f"{name} has {count} items, limit {LIMIT}")
```

## Control de flujo

```kite
if x > 0:
    print("positive")
orif x == 0:
    print("zero")
else:
    print("negative")

for i = 0 to 5:          // 0, 1, 2, 3, 4 (el final se excluye)
    print(i)
for item in items:
    print(item)
while n > 0:
    n -= 1
```

## Funciones

```kite
make area(w: int, h: int = 1) -> int:
    return w * h

print(area(3))
print(area(3, h = 4))
```

## Colecciones

```kite
xs = [1, 2, 3]
append(xs, 4)
person = {"name": "Ada", "age": 36}     // las claves son cadenas literales
ages = StrMap_int()                    // tabla hash con claves de cadena
ages.set("ada", 36)
```

## Registros, clases, enums

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

## Visibilidad en piezas

```kite
pub make area(w: int, h: int) -> int:    // se puede usar desde otras piezas
    return w * h

make helper() -> int:                    // privado de la pieza (cuando el archivo usa `pub`)
    return 1
```

## Funciones genéricas

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

print(first([4, 5, 6]))
print(first(["a", "b"]))
```

## Comandos

| comando | qué hace |
|---------|----------|
| `kite init NOMBRE` | crea un proyecto (`--lib` para una pieza) |
| `kite run` | compila y ejecuta |
| `kite build --release` | compilación optimizada |
| `kite check` | solo comprueba los tipos |
| `kite test` | ejecuta `tests/*.ki` |
| `kite add NOMBRE` | añade una pieza a `[dependencies]` |
| `kite fmt` | corrige los espacios |
