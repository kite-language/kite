# Bootstrapping: Kite compiled by Kite

```
stage0  archive/rust-stage0   Rust seed compiler (kept forever)
stage1  compiler/             the compiler written in Kite, built BY stage0
stage2  stage2/               stage1 compiling itself — must give the same LLVM IR as stage1
```

```
./build.sh          # stage0 → stage1 (→ stage2 when the port is complete)
./build.sh test     # + differential tests Kite vs Rust
./build.sh status   # which phases are ported
```

## Progress
| phase | status |
|---|---|
| lexer, parser, diagnostics | ✅ identical to Rust on every sample (tokens, AST, spans) |
| desugar (classes, `match`, data enums, defaults, named args, `*args`, unpacking) | ✅ identical to Rust on every sample, errors included |
| prelude injection | next |
| sema, IR, codegen, driver | todo (target: **0.4.0**) |

When stage1 = stage2, `compiler/BOOTSTRAPPED` is written and `scripts/package-release.sh --compiler auto`
starts shipping `kitec` instead of the Rust binary.

## How a port is verified
Each phase is compared with the Rust one on all `.ki` files of the repository through *canonical dumps*
(`scripts/difftest.sh`). `kitec tokens FILE`, `kitec ast FILE`, `kitec desugar FILE`, `kitec --capabilities` expose them.
