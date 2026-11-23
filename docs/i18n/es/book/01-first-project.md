# Tu primer proyecto

```sh
kite init hello
cd hello
kite run
```

`kite init` crea:

| archivo | para qué sirve |
|---------|----------------|
| `kite.toml` | el manifiesto: nombre, versión, descripción, autores, licencia, dependencias |
| `src/main.ki` | el programa: una función `make main():` |
| `.gitignore` | ignora `target/` |

`src/main.ki`:

```kite
make main():
    print("Hello, Kite!")
```

## Los comandos de cada día

| comando | qué hace |
|---------|----------|
| `kite run` | compila (si hace falta) y ejecuta |
| `kite build [--release]` | compila a `target/debug/<nombre>` o `target/release/<nombre>` (`--release` optimiza) |
| `kite check` | solo comprueba los tipos (rápido) |
| `kite test` | compila y ejecuta cada `tests/*.ki` |
| `kite fmt [--check]` | normaliza los espacios en blanco |
| `kite doc` | escribe `target/doc/<nombre>.md` a partir de tus comentarios `//` |
| `kite clean` | borra `target/` |

Cuando nada ha cambiado, kite muestra `Fresh` y se salta el compilador: la compilación se guarda en caché con una huella de tus fuentes,
tus piezas y la versión del compilador.

## Metadatos del paquete en tu programa

`kite.toml` puede describir el paquete, y el programa puede leerlo:

```toml
[package]
name = "hello"
version = "0.1.0"
description = "My first Kite program"
authors = ["Ada <ada@example.com>"]
license = "MIT"
```

```kite
make main():
    print(f"{pkg_name()} {pkg_version()} by {pkg_authors()}")
```

Cada binario lleva además una firma (`kite inspect target/debug/hello` muestra el paquete, el compilador y la compilación).
