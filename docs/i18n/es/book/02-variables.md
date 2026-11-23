# Variables, tipos y conversiones

Una variable se crea asignándole un valor. Su tipo se infiere y **no puede cambiar**; los nombres viven en la función que
los crea.

```kite
count = 0            // int
price = 9.5          // float
ready = true         // bool
name = "Kite"        // string
```

Anota el tipo cuando quieras ser explícito (o para `null`):

```kite
total: int = 0
p: ptr<int> = null
```

## Los tipos

| tipo | ejemplos | notas |
|------|----------|-------|
| `int` | `42`, `-7`, `0` | entero con signo de 64 bits |
| `float` | `3.14`, `0.5` | 64 bits |
| `bool` | `true`, `false` | |
| `string` | `"hi"`, `"line\n"` | bytes; escapes `\n \t \r \0 \e \\ \" \x41` |
| `[T]` | `[1, 2, 3]` | lista, ver [Colecciones](/guide/collections/) |
| `(A, B)` | `(1, "a")` | tupla de escalares |
| `{"k": T}` | `{"a": 1}` | diccionario con claves literales |
| `ptr<T>` | `alloc(int)` | puntero, ver [Memoria](/guide/memory/) |

## Operadores

`+ - * / %` con números (`+` también une cadenas), `== != < > <= >=`, `and or not`, operadores de bits `& | ^ ~ << >>`.
Asignación compuesta: `x += 1`, `x -= 1`, ... y los legibles `x.incr()` / `x.decr()` para `+1` / `-1`
(también en campos y elementos de lista: `self.count.incr()`, `items[2].decr()`).

## Convertir

| de | a | cómo |
|----|---|------|
| cualquier cosa imprimible | `string` | `str(x)` o una f-string |
| `string` | `int` | `to_int("42")` |
| `int` | `float` | `float_of(3)` |
| `float` | `int` | `int_of(2.9)` (trunca) |

## Construir cadenas

Usa **f-strings** en lugar de largas cadenas de `+`:

```kite
name = "Kite"
n = len(name)
print(f"{name} has {n} letters")      // Kite has 4 letters
```

Cualquier expresión sin comillas cabe en `{ }`; para lo demás, calcúlalo antes.
