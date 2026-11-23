# Escribir Kite legible

- **4 espacios**, sin tabuladores (`kite fmt` corrige los espacios).
- **f-strings** en lugar de cadenas de `+`: `f"{name}: {count}"`.
- **Cadenas de llamadas** en lugar de temporales cuando cada paso se lee con naturalidad:
  ```kite
  names = text
      .trim()
      .split(",")
  ```
- `x.incr()` / `x.decr()` en lugar de `x += 1` cuando la intención es «uno más».
- Nombra las funciones de una pieza `<pieza>_<función>` y llámalas como `piece.function()`.
- Pon un comentario `//` encima de cada función que quieras en `kite doc`.
- Prefiere `const` a los números mágicos.
- Mantén las funciones cortas; devuelve pronto.
- Marca `pub` solo la interfaz de una pieza; el resto queda privado.
- Nombres que evitar en variables y funciones (reservados): `to in int float string bool ptr null`, y las funciones integradas (`len`, `print`, ...).
  Las demás palabras clave (`from`, `type`, `match`, ...) valen como nombres, pero un nombre más claro se lee mejor.
