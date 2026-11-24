# Genéricos

Los genéricos permiten que una sola definición funcione con muchos tipos. Kite tiene **funciones genéricas** y **registros genéricos**;
ambos se especializan en tiempo de compilación (una copia por combinación de tipos), así que no cuestan nada en ejecución.

## Funciones genéricas

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

make main():
    print(first([4, 5, 6]))        // T = int
    print(first(["a", "b"]))       // T = string
```

El compilador deduce los parámetros de tipo a partir de los argumentos. Un parámetro de tipo puede aparecer como `T`, `[T]`, `ptr<T>` o dentro
de un registro genérico como `Box<T>`. Si no puede deducirse, la llamada es el error `E0123`.

## Registros genéricos

```kite
type Box<T>:
    value: T
    count: int

type Pair<A, B>:
    first: A
    second: B

make main():
    b = Box<int>()                 // argumentos de tipo entre ángulos
    b.value = 41
    p = Pair<string, int>()
    p.first = "k"
    p.second = 7

    boxes: [Box<int>] = []         // también en los tipos
    append(boxes, b)
    nested = Box<Box<int>>()       // y anidados
```

`Box<int>` y `Box<string>` son dos tipos distintos hechos a partir de la misma definición. Las funciones genéricas pueden recibirlos y
devolverlos: `make wrap<T>(x: T) -> Box<T>:` y `make unwrap<T>(b: Box<T>) -> T:`.
Los registros genéricos son simples registros `type` (todavía no hay clases ni enums genéricos).

## Option y Result

Hay dos registros genéricos listos para usar:

```kite
use std.option
use std.result

make find(xs: [int], x: int) -> Option<int>:
    i = 0
    for v in xs:
        if v == x:
            return option.some(i)
        i.incr()
    return Option<int>()                    // un Option vacío significa «nada»

make digit(c: string) -> Result<int, string>:
    r = Result<int, string>()               // un Result vacío que se rellena
    if c >= "0" and c <= "9":
        return result.ok(r, to_int(c))
    return result.err(r, f"not a digit: {c}")

make main():
    print(option.unwrap_or(find([4, 5, 6], 9), -1))     // -1
    r = digit("x")
    if result.is_err(r):
        print(result.error(r))                           // not a digit: x
```

> **Nota:** `Option` y `Result` son simples registros genéricos, así que puedes leer sus campos (`o.has`, `o.value`, `r.is_ok`).

## Argumentos de tipo explícitos (templates)

Normalmente los parámetros de tipo se infieren. También puedes darlos tú, entre ángulos antes de los argumentos, como en las plantillas
de C++. Es la forma de llamar a una función genérica cuyo tipo no se deduce de sus argumentos:

```kite
make zero<T>() -> T:
    z: T = 0
    return z

make convert<A, B>(a: A, b: B) -> B:
    return b

make main():
    print(zero<int>())                    // nada de lo que deducir T: se indica
    print(first<string>(["x", "y"]))      // igual que first(["x", "y"])
    print(convert<int, string>(1, "two"))
```

Los argumentos de tipo se escriben con nombres de tipo que empiezan en mayúscula (`Point`, `Box<int>`) o los tipos integrados
(`int`, `float`, `bool`, `string`, `num`, `[int]`, `ptr<int>`), así que `a < b > (c)` sigue siendo una comparación.
Dar más argumentos de tipo de los que tiene la función es el error `E0127`.
