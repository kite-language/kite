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
- Names to avoid for variables and functions (reserved): `to in from use type class match case enum thread try failed finally
  int float string bool ptr null`. Member names after a dot and record fields may use them.
