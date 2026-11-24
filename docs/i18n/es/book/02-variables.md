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
| `num` | `3`, `2.5` | un `int` o un `float`, ver [num](#num-un-int-o-un-float) |
| `string` | `"hi"`, `"line\n"` | bytes; escapes `\n \t \r \0 \e \\ \" \x41` |
| `[T]` | `[1, 2, 3]` | lista, ver [Colecciones](/guide/collections/) |
| `(A, B)` | `(1, "a")` | tupla de escalares |
| `{"k": T}` | `{"a": 1}` | diccionario con claves literales |
| `ptr<T>` | `alloc(int)` | puntero, ver [Memoria](/guide/memory/) |

## Operadores

`+ - * / %` con números (`+` también une cadenas), `== != < > <= >=`, `and or not`, operadores de bits `& | ^ ~ << >>`.
Asignación compuesta: `x += 1`, `x -= 1`, ... y los legibles `x.incr()` / `x.decr()` para `+1` / `-1`
(también en campos y elementos de lista: `self.count.incr()`, `items[2].decr()`).

## num: un int o un float

`num` es un número que es o bien un `int` o bien un `float`. Úsalo cuando un valor puede ser uno u otro (un precio, una medida,
el resultado de un cálculo con entradas mixtas). Un `int` o un `float` se acepta donde se espera un `num`.

```kite
make half(x: num) -> num:
    return x / 2

make main():
    a: num = 3                 // contiene un int
    b: num = 2.5               // contiene un float
    print(a + b)               // 5.5   (todo lo que lleva un float es un float)
    print(a * 2)               // 6     (int con int sigue siendo int)
    print(half(7))             // 3     (división entera)
    print(half(7.0))           // 3.5
    print(a < b)               // false
    print(b.as_int())          // 2     (un float se trunca)
    print(a.as_float())        // 3.0
    print(a.is_float())        // false
```

- La aritmética (`+ - * / %`), las comparaciones y `-x` funcionan con `num`, mezclándose libremente con `int` y `float`.
- `print`, `str` y las f-strings muestran un `num` con naturalidad (`3`, `2.5`; un float de valor entero conserva su punto: `3.0`).
- `x.as_int()` y `x.as_float()` convierten hacia fuera; `x.is_float()` dice cuál contiene. Las listas, campos de registro y parámetros pueden ser `num` (`[num]`).
- Una variable es un `num` cuando la declaras como tal (`x: num = 0`); `x = 0` a secas hace un `int`.

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
