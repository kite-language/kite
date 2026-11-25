# El comando `kite`

```sh
kite <comando> [opciones]
```

| comando | qué hace |
|---------|----------|
| `kite init [NOMBRE]` | crea un paquete (`--lib` para una pieza); sin nombre, en el directorio actual |
| `kite build` | compila el paquete |
| `kite run` | compila y luego ejecuta el programa |
| `kite check` | comprueba los tipos sin producir un binario |
| `kite test [FILTRO]` | compila y ejecuta `tests/*.ki` (un código de salida distinto de cero es un fallo) |
| `kite fmt [--check]` | normaliza los espacios en `src/` y `tests/` |
| `kite doc` | escribe `target/doc/<nombre>.md` a partir de los comentarios `//` sobre los elementos |
| `kite clean` | borra `target/` |
| `kite bench [--runs N]` | compila en modo release y mide ejecuciones repetidas |
| `kite add NOMBRE[@REQ]` / `remove NOMBRE` | edita `[dependencies]` |
| `kite update` | vuelve a resolver las dependencias y reescribe `kite.lock` |
| `kite tree` | imprime el árbol de dependencias |
| `kite search [CONSULTA]` / `kite info PIEZA` | explora el registro de piezas |
| `kite verify` / `kite publish` | comprueba una pieza / prepara su pull request |
| `kite target list\|add\|remove\|show [NOMBRE]` | gestiona los destinos de compilación |
| `kite inspect ARCHIVO` | muestra la firma de Kite guardada en un binario |

## kite build

| opción | significado |
|--------|-------------|
| `--release` | optimiza (`-O3`), resultado en `target/release/` |
| `--target T` | compila para otro destino (`target/<T>/<perfil>/`) |
| `-q`, `--quiet` | sin líneas de progreso |
| `-o ARCHIVO`, `--out-dir DIR` | dónde poner el resultado |
| `--link ARCHIVO` | enlaza un objeto/biblioteca adicional (repetible) |
| `--static` | enlaza estáticamente |
| `--lib` | un archivo objeto más una cabecera C, para llamar a Kite desde C |
| `--freestanding` | un archivo objeto sin requisito de libc, sin `main` |
| `--runtime core` | añade el runtime integrado sin libc (asignador «bump», funciones de memoria y cadenas) |
| `--heap-size N` | heap de ese runtime en bytes (por defecto 1048576) |
| `--backend native` | generador x86-64 experimental, sin clang (subconjunto entero) |
| `--storage` | el ejecutable más pequeño: elimina toda función que el programa nunca llama (también dentro de las piezas que usa), `-Os`, una sección por función y el enlazador quita el resto, símbolos eliminados |

`kite.toml` fija las mismas opciones: `[build] opt_level`, `target`, `runtime`, `heap_size`.

## Ejecutables más pequeños: `--storage`

```sh
kite build --release --storage
```

`--storage` hace el ejecutable lo más pequeño posible. Kite parte de `main` y conserva solo las funciones que el programa puede alcanzar:
se elimina toda función que nadie llama, **incluidas las funciones sin usar de las piezas que importas** (un programa que usa una sola
función de `std.strings` no arrastra las demás). Después el código se compila para tamaño, cada función tiene su propia sección,
y el enlazador quita lo que queda sin usar y elimina los símbolos. El comportamiento no cambia; solo cambia el tamaño.

```
$ kite build --release --storage
      Shrunk removed 103 of 143 functions the program never calls
$ ls -l target/release/app     # unos 14 KB en lugar de 50 KB para un programa pequeño
```

Hazlo permanente con `[build] storage = true` en `kite.toml`. Las bibliotecas (`--lib`) y los objetos freestanding sin `main`
ni `_start` se dejan enteros, porque cualquier función puede llamarse desde fuera.

## Salida de la compilación

```
   Compiling sha256 v0.5.2 (/home/me/kite/pieces/std/sha256/0.5.2)
   Compiling hello v0.1.0 (/home/me/hello)
    Finished dev [unoptimized] target(s) in 0.42s
```

`Fresh` sustituye a `Compiling` cuando nada ha cambiado. Estructura: `target/debug/<nombre>`, `target/release/<nombre>`, con el
IR de LLVM (`<nombre>.ll`) junto al binario y la huella de caché en `.fingerprint/`.

## Entorno

| variable | significado |
|----------|-------------|
| `KITE_PIECES` | el directorio del registro (el `pieces/` del repositorio) |
| `KITE_HOME` | dónde instala los destinos `kite target add` (por defecto `~/.kite`) |
