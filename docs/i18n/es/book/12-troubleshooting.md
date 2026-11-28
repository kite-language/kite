# Solución de problemas

## `clang failed to compile the generated LLVM IR`

Kite escribe IR de LLVM y le pide a `clang` que lo compile. El mensaje de error nombra el archivo `.ll` en `target/`: ábrelo en la línea indicada.
Si el programa es Kite normal, es un error del compilador: infórmalo adjuntando el archivo `.ll`.

## `clang: command not found`

Instala clang (`sudo apt install clang`, `xcode-select --install` o `winget install LLVM.LLVM`).

## `E0080: ... is private to the piece that defines it`

La pieza marca algunos elementos como `pub`, así que los demás son privados. Pide al autor de la pieza que marque el elemento como `pub`, o usa una función pública.
En tu propio proyecto no existe esa restricción mientras tu archivo no use `pub`.

## `E0072: piece ... has no function ...`

Las funciones de una pieza se llaman `piece.function(...)`. La pieza debe estar importada (`use std.fs`, o `use nombre` tras `kite add nombre`).
Consulta la lista de funciones en las [piezas estándar](/reference/std-pieces/).

## Una variable no puede usar ese nombre

Unas pocas palabras están reservadas (`to in int float string bool ptr null`),
y los nombres integrados `str len print append pop remove insert clear free arg` están ocupados. Elige otro nombre.
Palabras como `from`, `type`, `use`, `match`, `case`, `class`, `thread` o `try` valen como nombres (`from = 3`, `make f(case: int)`);
después de un `.` se acepta cualquier palabra: `job.thread` es válido.

## Fallo de segmentación con listas dentro de clases

Asignar una clase copia su cabecera, así que dos nombres pueden compartir un mismo búfer. Usa `self.items.append(x)`, no una copia como `items = self.items`.

## Un campo `string` hace fallar `len()`

Un campo `string` de un registro recién creado es un puntero nulo hasta que lo asignas. Asigna el campo antes de leerlo.

## Windows: errores de enlazado con `printf` o `timespec_get`

Actualiza a la última versión (esos símbolos los proporcionan los shims de Kite). Vuelve a ejecutar `kite build` e informa de toda la salida si sigue fallando.

## Colores en los mensajes de error

Los errores se colorean en un terminal. Define `NO_COLOR=1` para desactivar los colores, o `KITE_COLOR=always` / `KITE_COLOR=never` para forzarlos o quitarlos (por ejemplo en un registro de CI).
