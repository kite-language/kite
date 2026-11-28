# Kite

Kite es un lenguaje compilado que se lee como Python y corre como C. Tiene bloques por indentación, tipos estáticos
inferidos y ninguna pausa de recolector de basura: `kite build` convierte tu programa en código nativo.

```kite
make main():
    name = "Kite"
    print(f"Hello from {name}!")
```

**Qué obtienes**

- Un compilador escrito en el propio Kite (se compila a sí mismo: stage 1 = stage 2 = stage 3).
- Las **piezas**: los paquetes de Kite. El lenguaje incluye 41 piezas por defecto (`std.fs`, `std.json`, `std.random`, ...) y un
  registro comunitario que vive en el repositorio.
- Hilos, punteros y memoria manual cuando los necesitas; cadenas, listas, tuplas y diccionarios cuando no.
- `kite` lo hace todo: `init`, `build`, `run`, `check`, `test`, `fmt`, `doc`, `add`, `publish`, `target`, ...
- Un modo freestanding con su propio runtime diminuto, para núcleos y microcontroladores.

**Por dónde empezar**

1. [Instalar Kite](/installation/) -- un comando en Linux y macOS, uno en Windows.
2. [Tu primer proyecto](/guide/first-project/) -- `kite init`, `kite run`.
3. [Variables y tipos](/guide/variables/), [control de flujo](/guide/control-flow/), [funciones](/guide/functions/).
4. [Piezas](/guide/pieces/) cuando quieras una biblioteca, [las piezas estándar](/reference/std-pieces/) para lo que viene incluido.
