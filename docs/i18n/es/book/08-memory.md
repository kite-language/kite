# Memoria, punteros e hilos

## Punteros

```kite
p = alloc(int)            // un int en el heap, puesto a cero
*p = 42                   // escribir a través del puntero
print(*p)
free(p)

buf = alloc_n(int, 8)     // ocho ints
buf[0] = 7                // p[i] ...
*(buf + 1) = 8            // ... o aritmética de punteros
buf = realloc_n(buf, 16)  // redimensionar (conserva el contenido)
zero_n(buf, 16)           // limpiar
copy_n(dst, src, 8)       // copiar 8 elementos
free(buf)
```

`&x` toma la dirección de un escalar local. `null` es el puntero vacío (`p == null`). `ptr_to_int(p)` e `int_to_ptr(n)`
convierten entre un puntero y su dirección.

## Hilos

```kite
make worker(id: int):
    print(f"worker {id}")

make main():
    h = spawn(worker, 1)      // ejecuta worker(1) en un hilo nuevo
    thread_join(h)
```

Comparte datos pasando `ptr_to_int(block)` y reconstruyendo el puntero en el hilo; protégelos con la pieza `threads`
(`mutex_new`, `mutex_lock`, `atomic_add`, ...).

## Hablar con C

Declara una función de C y llámala:

```kite
extern make abs(n: int) -> int
```

Los parámetros y resultados pueden ser `int`, `float`, `bool`, `string` y `ptr<T>`. Compila con `--link lib.a` para añadir objetos.
