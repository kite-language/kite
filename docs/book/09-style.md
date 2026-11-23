# Writing readable Kite

- **4 spaces**, no tabs (`kite fmt` fixes whitespace).
- **f-strings** over `+` chains: `f"{name}: {count}"`.
- **Chains** over temporaries when each step reads naturally:
  ```
  names = text
      .trim()
      .split(",")
  ```
- `x.incr()` / `x.decr()` instead of `x += 1` when the intent is "one more".
- Name functions of a piece `<piece>_<function>` and call them as `piece.function()`.
- Put a `//` comment above every function you want in `kite doc`.
- Prefer `const` over magic numbers.
- Keep functions short; return early.
- Mark only a piece's interface `pub`; everything else stays private.
- Names to avoid for variables and functions (reserved): `to in int float string bool ptr null`, and the built-ins (`len`, `print`, ...).
  Other keywords (`from`, `type`, `match`, ...) work as names, but a clearer name reads better.
