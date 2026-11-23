# Mémoire, pointeurs et threads

## Pointeurs

```kite
p = alloc(int)            // un int sur le tas, mis à zéro
*p = 42                   // écrire à travers le pointeur
print(*p)
free(p)

buf = alloc_n(int, 8)     // huit ints
buf[0] = 7                // p[i] ...
*(buf + 1) = 8            // ... ou arithmétique de pointeurs
buf = realloc_n(buf, 16)  // redimensionner (garde le contenu)
zero_n(buf, 16)           // vider
copy_n(dst, src, 8)       // copier 8 éléments
free(buf)
```

`&x` prend l'adresse d'un scalaire local. `null` est le pointeur vide (`p == null`). `ptr_to_int(p)` et `int_to_ptr(n)`
convertissent entre un pointeur et son adresse.

## Threads

```kite
make worker(id: int):
    print(f"worker {id}")

make main():
    h = spawn(worker, 1)      // exécute worker(1) sur un nouveau thread
    thread_join(h)
```

Partagez des données en passant `ptr_to_int(block)` et en reconstruisant le pointeur dans le thread ; protégez-les avec la pièce `threads`
(`mutex_new`, `mutex_lock`, `atomic_add`, ...).

## Parler à C

Déclarez une fonction C et appelez-la :

```kite
extern make abs(n: int) -> int
```

Les paramètres et résultats peuvent être `int`, `float`, `bool`, `string` et `ptr<T>`. Compilez avec `--link lib.a` pour ajouter des objets.
