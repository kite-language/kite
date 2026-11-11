# How the compiler is built

```
source (.ki) ─ lexer ─ parser ─ desugar (+ prelude) ─ sema ─ IR ─ LLVM IR (.ll) ─ clang ─ executable
```

| stage | does | Rust (stage0) | Kite (`compiler/`) |
|---|---|---|---|
| lexer | tokens, indentation → `Indent`/`Dedent` | `src/lexer/` | `lexer.ki` ✅ |
| parser | AST, f-strings, classes | `src/parser.rs` | `parser.ki` ✅ |
| desugar | defaults, named args, `*args`, unpacking, classes → structs + functions, `match`, data enums | `src/desugar.rs` | `desugar.ki` ✅ |
| prelude | adds the prelude functions a program uses | `src/prelude.rs` | next |
| sema | types, errors | `src/sema.rs` | todo |
| IR | lowering to a small IR (aggregates by pointer, `sret`) | `src/ir.rs` | todo |
| codegen | LLVM IR text | `src/codegen.rs` | todo |
| driver | CLI, projects, imports, `clang` | `src/driver.rs`, `commands/`, `project.rs`, `resolve.rs` | todo |

The Rust sources live in `archive/rust-stage0/` (the *seed* compiler). `docs/bootstrap.md` explains how the Kite
version replaces it. In the Kite compiler the AST is an **arena** of uniform nodes `(kind, text, span, kids)`
(see `compiler/src/ast.ki`).

## Design rules
- Each stage only knows its input and output; the driver is the only place that knows the order.
- Errors are collected (`Diags`) so one run reports as many as possible.
- Generated code is plain LLVM IR: aggregates are passed by pointer and returned through a hidden out-pointer,
  every `alloca` is hoisted to the function entry, lists are `{len, cap, data*}`.
