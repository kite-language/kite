# Errores: Result, Option y `?`

Kite no tiene excepciones. Una función que puede fallar devuelve un **`Result`**, y una función que puede no tener nada que devolver da un
**`Option`**. Ambos son simples registros genéricos de las piezas por defecto `std.result` y `std.option`.

```kite
use std.result

make digit(c: string) -> Result<int, string>:
    r = Result<int, string>()                  // un Result vacío que se rellena
    if c >= "0" and c <= "9":
        return result.ok(r, to_int(c))
    return result.err(r, f"not a digit: {c}")

make main():
    r = digit("x")
    if result.is_err(r):
        print(result.error(r))                 // not a digit: x
    print(result.unwrap_or(digit("7"), 0))     // 7
```

## El operador `?`

Llamar a varias funciones que pueden fallar exigiría un `if` tras cada llamada. Pon **`?`** después de la llamada: cuando la llamada falla, la
función actual devuelve ese fallo de inmediato; cuando tiene éxito, obtienes el valor.

```kite
make two_digits(a: string, b: string) -> Result<int, string>:
    x = digit(a)?                              // ante un error: devolverlo desde two_digits
    y = digit(b)?
    r = Result<int, string>()
    return result.ok(r, x * 10 + y)

make sum3(a: string, b: string, c: string) -> Result<int, string>:
    r = Result<int, string>()
    return result.ok(r, digit(a)? + digit(b)? + digit(c)?)   // varios `?` en una expresión, de izquierda a derecha
```

Funciona igual con `Option`: `i = find(xs, 6)?` devuelve un `Option` vacío desde la función actual cuando no se encontró nada.

Reglas:

- La función que usa `?` debe devolver a su vez un `Result<T, E>` (con el mismo tipo de error `E`) o un `Option<T>`: si no, error `E0144`.
- `?` puede aparecer en una asignación, una instrucción de llamada, un `return` o la condición de un `if`. No puede usarse en la condición de un bucle, a la derecha de `and` / `or`
  (podría no ejecutarse), ni dentro de una lambda (`E0141`, `E0142`); en cualquier otro sitio es el error `E0143`.
- Es solo un atajo para un `if`: sigues pudiendo mirar `r.is_ok`, `r.value` y `r.error` tú mismo.
