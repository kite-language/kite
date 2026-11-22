# Memory, pointers and threads

## Pointers

```
p = alloc(int)            // one int on the heap, zeroed
*p = 42                   // write through the pointer
print(*p)
free(p)

buf = alloc_n(int, 8)     // eight ints
buf[0] = 7                // p[i] ...
*(buf + 1) = 8            // ... or pointer arithmetic
buf = realloc_n(buf, 16)  // resize (keeps the contents)
zero_n(buf, 16)           // clear
copy_n(dst, src, 8)       // copy 8 elements
free(buf)
```

`&x` takes the address of a local scalar. `null` is the empty pointer (`p == null`). `ptr_to_int(p)` and `int_to_ptr(n)`
convert between a pointer and its address.

## Threads

```
make worker(id: int):
    print(f"worker {id}")

make main():
    h = spawn(worker, 1)      // runs worker(1) on a new thread
    thread_join(h)
```

Share data by passing `ptr_to_int(block)` and rebuilding the pointer in the thread; protect it with the `threads` piece
(`mutex_new`, `mutex_lock`, `atomic_add`, ...).

## Talking to C

Declare a C function and call it:

```
extern make abs(n: int) -> int
```

Parameters and results may be `int`, `float`, `bool`, `string` and `ptr<T>`. Build with `--link lib.a` to add objects.
