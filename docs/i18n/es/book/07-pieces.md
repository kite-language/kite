# Piezas (paquetes)

Una **pieza** es una biblioteca: una carpeta con `kite.toml` y `src/lib.ki`.

```sh
kite init --lib shapes     # crear una
kite add sha256            # usar una (ver más abajo)
```

## Dos tipos

- Las **piezas por defecto** (`std.*`) vienen con Kite y no necesitan declaración: `use std.fs`.
- Las **piezas comunitarias** viven en el registro del repositorio. Decláralas en `[dependencies]` (`kite add table`) e
  impórtalas por su nombre: `use table`.

```kite
use std.strings         // una pieza por defecto
use table               // una pieza comunitaria (listada en kite.toml)

make main():
    t = table_new(2)
    table_add_row(t, ["name", "qty"])
    print(table_render(t))
    print(strings.upper("kite"))     // llamadas piece.function(...)
```

## Llamar a piezas

`piece.function(args)` es la forma legible de llamar a una pieza. Significa la función llamada `<pieza>_<función>`:
`fs.read(path)` es `fs_read(path)`, `strings.upper(s)` es `strings_upper(s)`. Si una variable local tiene el mismo nombre que la
pieza, gana la variable (usa el nombre largo).

Las funciones de todas las piezas comparten un único espacio de nombres internamente, así que nombra las tuyas `<pieza>_<función>`.

## Gestionar dependencias

```sh
kite search json       # buscar piezas
kite info semver       # metadatos y versiones
kite add sha256@^1.2   # añadir con un requisito (^ ~ >= < =)
kite tree              # árbol de dependencias (con subdependencias)
kite update            # volver a resolver kite.lock
kite remove sha256
```

`kite.lock` guarda las versiones exactas y las sumas de verificación; si una copia del registro cambia, la compilación se detiene.

## Publicar

```sh
kite verify            # las mismas comprobaciones que la CI del registro
kite publish           # prepara pieces/community/<nombre>/<versión>/ e imprime los comandos de git
```

`kite publish` nunca ejecuta git: tú ejecutas los comandos impresos y abres un pull request; la CI compila cada pieza modificada.

## Elementos públicos y privados

Por defecto todo es público. En cuanto un archivo marca un elemento de nivel superior como `pub`, ese archivo pasa a *modo explícito*:
los elementos sin `pub` son **privados de su pieza** (todos los archivos bajo el `src/` de la pieza).

```kite
pub type Point:
    x: int
    y: int

pub make dist(a: Point, b: Point) -> int:     // parte de la interfaz
    return abs(a.x - b.x) + abs(a.y - b.y)

make helper(n: int) -> int:                   // privado: otras piezas no pueden llamarlo
    return n * 2
```

`pub` funciona con `make`, `type`, `class`, `enum` y `const`. Los métodos de una clase siguen a la clase. Usar un elemento privado
de otra pieza es el error `E0080`. La referencia de [piezas estándar](/reference/std-pieces/) solo lista los elementos `pub` de una pieza que usa `pub`.

> **Consejo:** empieza en privado y marca `pub` solo lo que necesitan los usuarios de tu pieza: la interfaz se mantiene pequeña y puedes cambiar el resto con libertad.

## Importar nombres

En lugar de escribir `piece.function()` cada vez, importa por nombre las funciones que usas:

```kite
use std.strings.{upper, lower}       // o: from std.strings import upper, lower
use std.option.{some, unwrap_or}

make main():
    print(upper("kite") + lower("ABC"))   // KITEabc
    print(unwrap_or(some(41), 0))
```

`upper` pasa a significar `strings.upper` en ese archivo (una función tuya con el mismo nombre gana). Nombrar una función que la pieza
no tiene es el error `E0128`. La forma calificada `strings.upper(...)` sigue funcionando siempre.
