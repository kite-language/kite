# Control de flujo

```kite
if score >= 90:
    print("A")
orif score >= 80:          // `orif` es «si no, si»
    print("B")
else:
    print("C")
```

```kite
while i < 10:
    i.incr()

until done:                // repite hasta que la condición sea verdadera
    step()

for i = 0 to 5:            // 0, 1, 2, 3, 4  (el final se excluye)
    print(i)

for item in items:         // cada elemento de una lista
    print(item)

infinit:                   // bucle infinito, se sale con `break`
    if finished():
        break
```

`break` sale del bucle más cercano, `continue` salta a su siguiente vuelta. Las variables de bucle pertenecen a la función.

## try / finally

```kite
make load(path: string) -> string:
    text = ""
    try:
        text = read_file(path)
        return text
    finally:
        print("done reading")        // se ejecuta antes de que el `return` salga del bloque
```

`finally` siempre se ejecuta después del bloque, incluso antes de un `return`, `break` o `continue` que lo abandone. Kite todavía no tiene
excepciones: un bloque `failed:` lo acepta el parser pero nunca se ejecuta (está reservado para el trabajo de propagación de
errores de la [hoja de ruta](/project/roadmap/)). Comunica los problemas con valores de retorno (`std.error`) o `panic`.

## Detener el programa

`exit(code)` termina el proceso; `panic("mensaje")` imprime `panic: mensaje` y sale con el código 101;
`assert(condition, "por qué")` hace panic cuando la condición es falsa.
