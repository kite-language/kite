# Funciones y constantes

```kite
make area(w: int, h: int) -> int:
    return w * h

make greet(name: string):          // sin `->`: no devuelve nada
    print(f"Hello, {name}!")
```

- Los parámetros llevan tipo; el tipo de retorno puede omitirse y se infiere entonces del primer `return`.
- Las funciones recursivas y mutuamente recursivas necesitan un `-> Tipo` explícito.
- Valores por defecto y argumentos con nombre: `make connect(host: string, port: int = 80)` se llama como `connect("a")` o
  `connect("a", port = 8080)`.
- `*items: int` recoge los argumentos extra en una lista `items` de ese tipo de elemento (`total(1, 2, 3)`).
- Devuelve varios valores con una tupla: `return (1, "one")`, recíbelos con `n, word = pair()`.

## Constantes

```kite
const LIMIT = 100
const GREETING: string = "hello"
```

Una constante se lee como una variable y no se puede reasignar. (Internamente es una función sin argumentos, así que puede ser
cualquier expresión.)

Una constante también puede declararse **dentro de una función**, y toda constante es de solo lectura: asignarle un valor (`LIMIT = 9`,
`LIMIT += 1`, `LIMIT.incr()`, o cambiar un campo de un registro constante) es el error `E0124`.

```kite
const LIMIT = 100                  // global: visible en todas partes

make main():
    const STEP = LIMIT / 4         // local a esta función
    total = 0
    total += STEP                  // correcto: `total` es una variable normal
```

## Llamar a funciones

Dos formas equivalentes; usa la que se lea mejor:

```kite
len(text)           // llamada normal
text.len()          // sintaxis de llamada uniforme: value.f(args) es f(value, args)
```

La sintaxis de llamada uniforme hace que las cadenas de llamadas se lean de izquierda a derecha, y pueden continuar en la línea siguiente:

```kite
words = "  one, two ,three  "
    .trim()
    .split(",")
```

Se aplica a cualquier valor que no sea una instancia de clase (los métodos de clase conservan su propio significado).

## Comentarios de documentación

Los comentarios `//` justo encima de una función, tipo o clase los recoge `kite doc`.

## Funciones genéricas

Una función puede tener **parámetros de tipo** entre ángulos. El compilador los deduce a partir de los argumentos y genera una copia
especializada por cada combinación de tipos, así que una función genérica es tan rápida como una escrita a mano.

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

make pick<A, B>(a: A, b: B) -> A:
    return a

make main():
    print(first([4, 5, 6]))        // 4      (T = int)
    print(first(["a", "b"]))       // a      (T = string)
    print(pick(7, "x"))            // 7      (A = int, B = string)
```

- Un parámetro de tipo puede aparecer en el tipo de un parámetro como `T`, `[T]` o `ptr<T>`, y también en el tipo de retorno y en el cuerpo.
- Cada parámetro de tipo debe poder deducirse de los argumentos (`E0123` en caso contrario); dos parámetros con la misma `T` deben coincidir (`E0122`).
- Las funciones genéricas son solo de nivel superior (sin métodos genéricos) y necesitan `-> Tipo` cuando devuelven un valor.
- Los registros genéricos (`Box<T>`) y los `Option<T>` / `Result<T, E>` ya hechos están en el capítulo [Genéricos](/guide/generics/).
