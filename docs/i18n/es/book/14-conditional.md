# Compilación condicional

Algunos códigos solo tienen sentido en un sistema operativo. Un bloque **`when`** conserva su código para los destinos que nombras y
**lo elimina del programa** para todos los demás: no se compila, no se comprueba y no está en el binario.

```kite
when windows:
    make open_url(url: string):
        run(f"start {url}")
else:
    make open_url(url: string):
        run(f"xdg-open {url}")

make main():
    open_url("https://kite-lang.pages.dev")
    when linux:
        print("running on Linux")
```

`when` funciona con los elementos de nivel superior (funciones, tipos, constantes, líneas `use`) y con las instrucciones dentro de
las funciones. Un bloque `else:` opcional justo después contiene el código de los demás destinos. Los bloques se pueden anidar.

## Condiciones

| condición | verdadera cuando el destino es |
|-----------|--------------------------------|
| `windows`, `linux`, `macos` | ese sistema operativo |
| `unix` | Linux o macOS |
| `bare` | freestanding (sin SO), p. ej. `x86_64-unknown-none` |
| `x86_64`, `aarch64`, `riscv64` | esa arquitectura de CPU |
| `os == "linux"`, `arch == "aarch64"` | lo mismo, escrito como comparación (`!=` también funciona) |

Combínalas con `not`, `and`, `or` y paréntesis: `when unix and not macos:`, `when (linux or macos) and arch == "aarch64":`.

El destino es el que se da a `kite build --target ...` (o `[build] target` en `kite.toml`); sin destino, es la máquina en la que estás.

> **Nota:** `when` solo es una palabra clave al principio de una línea, seguida de una condición y `:`, así que una variable llamada `when` sigue funcionando.
