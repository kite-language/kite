# Valores de función y lambdas

Una función puede guardarse en una variable, pasarse a otra función y devolverse como cualquier otro valor. Su tipo se escribe
`fn(tipos de los parámetros) -> tipo del resultado`.

```kite
make double(x: int) -> int:
    return x * 2

make apply(f: fn(int) -> int, v: int) -> int:
    return f(v)                      // llamar a una variable que contiene una función

make main():
    f = double                       // un nombre de función es un valor
    print(f(21))                     // 42
    print(apply(double, 4))          // 8
```

¿No devuelve nada? Omite la flecha: `fn(string)` es una función que recibe una cadena y no devuelve nada.

## Lambdas

Una **lambda** es una función pequeña escrita donde se usa: `|parámetros| expresión`.

```kite
print(apply(|x| x + 100, 5))                          // 105
g: fn(int, int) -> int = |a, b| a * b
k = |x: float| x / 2.0                                // escribe el tipo cuando nada lo indica
say: fn(string) = |s| print(s)
z = || 42                                             // sin parámetros
```

Los tipos de los parámetros vienen del tipo de función **esperado** (`apply` arriba espera `fn(int) -> int`); una lambda asignada a una variable nueva
no tiene tipo esperado, así que anota sus parámetros (`|x: float|`). El tipo del resultado es el de la expresión.

## Capturar variables (cierres)

Una lambda puede usar las variables de la función que la rodea. Guarda una **copia** de sus valores en el momento en que se crea:

```kite
make main():
    base = 1000
    add_base = |x: int| x + base          // captura base
    base = 5                              // el cierre sigue viendo 1000
    print(add_base(7))                    // 1007
    scale = 2.5
    half = |x: float| x * scale
    ys = iter.map([1, 2, 3], |n| n * 10 + base)    // las capturas funcionan también con iter.map
```

Las variables capturadas pueden ser `int`, `float`, `bool`, `string`, punteros, enums y otras funciones (un cierre puede capturar otro cierre).

## map, filter, reduce

La pieza `std.iter` trabaja con listas y valores de función (es genérica, los tipos de los elementos se infieren):

```kite
use std.iter

make main():
    nums = [1, 2, 3, 4]
    squares = iter.map(nums, |x| x * x)               // [1, 4, 9, 16]
    evens = iter.filter(nums, |x| x % 2 == 0)         // [2, 4]
    print(iter.reduce(nums, 0, |acc, x| acc + x))     // 10
    print(iter.any(nums, |x| x > 3))                  // true
    iter.each(iter.range(3), |i| print(i * 10))
```

## Límites

- Una lambda captura **una copia** de las variables que usa, tomada cuando se crea la lambda (ver arriba); las listas, registros y `num` todavía no se pueden capturar (`E0139`).
  El bloque que guarda los valores capturados no se libera: no crees cierres en un bucle larguísimo.
- Los valores de función reciben y devuelven `int`, `float`, `bool`, `string`, punteros y enums (todavía no listas, registros ni `num`): error `E0131`.
- Una función necesita un `-> Tipo` explícito para usarse como valor (`E0135`); un número o tipo de argumentos incorrecto al llamarla es `E0136` / `E0137`.
