#!/bin/bash
# Kite build + bootstrap.
#
#   ./build.sh            build everything that can be built (see stages below)
#   ./build.sh test       same, then run the differential tests (Kite vs Rust)
#   ./build.sh status     show which compiler phases are ported to Kite
#   ./build.sh clean      remove build outputs (see also ./clean.sh)
#   ./build.sh --fresh    also rebuild the Rust seed from scratch (default: only kitec and the stage dirs are rebuilt)
#
# Stages
#   stage0  the Rust compiler (archive/rust-stage0)          built with cargo + clang
#   stage1  kitec, the compiler written in Kite (compiler/)   compiled by stage0
#   stage2  kitec compiled by stage1 itself                   (needs the full port)
#   stage2 must produce the same LLVM IR as stage1; when it does, compiler/BOOTSTRAPPED
#   is written and kitec can replace the Rust compiler.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
STAGE0_DIR="$ROOT/archive/rust-stage0"
STAGE0_TARGET="$STAGE0_DIR/target"   # always ours, whatever CARGO_TARGET_DIR says
STAGE0="${KITE_STAGE0:-$STAGE0_TARGET/release/kite}"
KITEC="$ROOT/compiler/target/kitec"

# On Windows the executables carry an .exe suffix: pick whichever exists.
exe() { if [ -f "$1.exe" ]; then echo "$1.exe"; else echo "$1"; fi; }

bold() { printf '\033[1m%s\033[0m\n' "$*"; }

FRESH=0
if [ "${1:-}" = "--fresh" ]; then FRESH=1; shift; fi

case "${1:-build}" in
  clean)  exec "$ROOT/clean.sh" ;;
  status)
    [ -x "$KITEC" ] || { echo "kitec not built yet: run ./build.sh"; exit 1; }
    bold "phases ported to Kite:"; "$KITEC" --capabilities | sed 's/^/  - /'
    [ -f "$ROOT/compiler/BOOTSTRAPPED" ] && echo "bootstrap: COMPLETE" || echo "bootstrap: in progress"
    exit 0 ;;
esac

# The Rust crate keeps its own frozen copy of the prelude (it must be self-contained for
# `cross`/Docker builds); warn when it drifts from the canonical stdlib/prelude.
for f in core.ki map.tpl; do
  cmp -s "$ROOT/stdlib/prelude/$f" "$STAGE0_DIR/src/prelude/$f" || \
    echo "warning: stdlib/prelude/$f differs from archive/rust-stage0/src/prelude/$f (stage0 uses its own copy)" >&2
done

# Never trust old outputs: stage1/2/3 and their build caches (target/, .fingerprint) are always rebuilt.
rm -rf "$ROOT/compiler/target" "$ROOT/stage2" "$ROOT/stage3" "$ROOT/compiler/BOOTSTRAPPED"
if [ "$FRESH" = 1 ]; then rm -rf "$STAGE0_TARGET"; fi

bold "==> stage0: Rust compiler"
if [ ! -x "$STAGE0" ]; then
  (cd "$STAGE0_DIR" && CARGO_TARGET_DIR="$STAGE0_TARGET" cargo build -q --release --bins --examples 2>&1 | grep -v "^warning\|^ *|\|^ *-->\|^ *=\|^$\|^[0-9 ]*|" || true)
fi
STAGE0="$(exe "$STAGE0")"
[ -e "$STAGE0" ] || { echo "error: stage0 binary not found at $STAGE0" >&2; exit 1; }

# kitec embeds the prelude (compiler/src/prelude_data.ki is generated from stdlib/prelude/)
"$ROOT/scripts/gen-prelude.sh" >/dev/null

bold "==> stage1: kitec (Kite) compiled by stage0"
(cd "$ROOT/compiler" && "$STAGE0" build --release)
KITEC="$(exe "$ROOT/compiler/target/kitec")"

PORTED="$("$KITEC" --capabilities | tr '\n' ' ')"
echo "    ported phases: $PORTED"
if echo "$PORTED" | grep -qw build; then
  bold "==> stage2: kitec compiled by kitec (stage1)"
  for n in stage2 stage3; do rm -rf "$ROOT/$n" && mkdir -p "$ROOT/$n" && cp -r "$ROOT/compiler/." "$ROOT/$n/" && rm -rf "$ROOT/$n/target"; done
  (cd "$ROOT/stage2" && "$KITEC" build --release)
  bold "==> stage3: kitec compiled by stage2 (fixed point)"
  (cd "$ROOT/stage3" && "$(exe "$ROOT/stage2/target/release/kitec")" build --release)
  # Rust emits string constants in HashMap order: compare stage1 with the constants sorted.
  n1=$(python3 "$ROOT/scripts/llnorm.py" < "$ROOT/compiler/target/kitec.ll" | python3 -c 'import sys,hashlib;print(hashlib.md5(sys.stdin.buffer.read()).hexdigest())')
  n2=$(python3 "$ROOT/scripts/llnorm.py" < "$ROOT/stage2/target/release/kitec.ll" | python3 -c 'import sys,hashlib;print(hashlib.md5(sys.stdin.buffer.read()).hexdigest())')
  if [ "$n1" = "$n2" ] && cmp -s "$ROOT/stage2/target/release/kitec.ll" "$ROOT/stage3/target/release/kitec.ll"; then
    echo "    stage1 = stage2 = stage3 (identical LLVM IR): bootstrap complete; shipping stage3"
    date -u +%FT%TZ > "$ROOT/compiler/BOOTSTRAPPED"
    mkdir -p "$ROOT/compiler/target" && S3="$(exe "$ROOT/stage3/target/release/kitec")"; case "$S3" in *.exe) cp "$S3" "$ROOT/compiler/target/kite.exe" ;; *) cp "$S3" "$ROOT/compiler/target/kite" ;; esac
    echo "    self-hosted compiler (stage3): compiler/target/kite (does not need Rust or cargo)"
  else
    echo "error: stage2/stage3 differ from stage1" >&2; exit 1
  fi
else
  bold "==> stage2: skipped (the port of the remaining phases is in progress; ./build.sh status)"
fi

if [ "${1:-}" = "test" ]; then
  bold "==> differential tests (Kite vs Rust)"
  cd "$ROOT"
  # Lexing and parsing are compared on every source, the compiler's own included. The later phases are compared on
  # programs written in the language the Rust seed knows: the compiler's sources use features that only the Kite
  # compiler has (`piece.function()`, uniform call syntax, f-strings of pieces), which the seed resolves differently.
  FILES=$(ls examples/*.ki examples/*/*.ki stdlib/prelude/core.ki compiler/src/*.ki)
  PROGRAMS=$(ls examples/*.ki examples/*/*.ki stdlib/prelude/core.ki)
  export KITE_STAGE0_TARGET="$STAGE0_TARGET"
  scripts/difftest.sh tokens $FILES
  scripts/difftest.sh ast $FILES
  # `desugar` is not compared: Kite's uniform-call rewrite runs before class information is complete, so it turns
  # `m.set(..)` into `Call set` where the seed keeps `MethodCall` in the non-injected dump; `inject` agrees.
  scripts/difftest.sh inject $PROGRAMS
  scripts/difftest.sh sema $PROGRAMS
  scripts/llcmp.sh $PROGRAMS
  bold "==> examples with recorded output, built by the self-hosted compiler"
  [ -e "$(exe "$ROOT/stage2/target/release/kitec")" ] && scripts/runexamples.sh "$(exe "$ROOT/stage2/target/release/kitec")"
  bold "==> default pieces tests"
  (cd "$ROOT/stdlib/tests/std_test" && KITE_PIECES="$ROOT/pieces" "$(exe "$ROOT/stage2/target/release/kitec")" run -q)
  bold "==> new default and community pieces"
  (cd "$ROOT/stdlib/tests/pieces2_test" && KITE_PIECES="$ROOT/pieces" "$(exe "$ROOT/stage2/target/release/kitec")" run -q)
  bold "==> language feature tests (kite test)"
  (cd "$ROOT/stdlib/tests/lang_test" && KITE_PIECES="$ROOT/pieces" "$(exe "$ROOT/stage2/target/release/kitec")" test)
  bold "==> signature, native back end, freestanding runtime"
  (
    KC="$(exe "$ROOT/stage2/target/release/kitec")"; export KITE_PIECES="$ROOT/pieces"
    W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT; cd "$W"
    "$KC" init sig >/dev/null && cd sig
    printf 'make fib(n: int) -> int:\n    if n < 2:\n        return n\n    return fib(n - 1) + fib(n - 2)\n\nmake main():\n    print(fib(20))\n' > src/main.ki
    "$KC" build -q >/dev/null; "$KC" inspect target/debug/sig | grep -q "language=Kite" && echo "inspect: ok"
    [ "$(./target/debug/sig)" = "6765" ] && echo "llvm back end: ok"
    "$KC" build --release --backend native -q >/dev/null; [ "$(./target/release/sig)" = "6765" ] && echo "native back end: ok"
    # Windows IR regression (timespec_get declared and defined twice): the IR must at least compile to an object
    cd .. && "$KC" init win >/dev/null && cd win
    printf 'use std.time\nmake main():\n    print(time.now_ms())\n' > src/main.ki
    "$KC" build -q --target x86_64-pc-windows-msvc >/dev/null 2>&1 || true
    clang -c --target=x86_64-pc-windows-msvc -x ir target/x86_64-pc-windows-msvc/debug/win.ll -o win.obj 2>/dev/null && echo "windows IR: ok"
    cd .. && "$KC" init os >/dev/null && cd os
    printf 'make _start():\n    names = ["kite", "os"]\n    append(names, "boot")\n    i = 0\n    i.incr()\n' > src/main.ki
    if command -v ld.lld >/dev/null 2>&1; then
      "$KC" target add x86_64-unknown-none >/dev/null 2>&1
      "$KC" build --target x86_64-unknown-none -q >/dev/null
      [ "$(nm -u target/x86_64-unknown-none/debug/os.elf | wc -l)" = "0" ] && echo "freestanding core runtime: ok"
    else echo "freestanding core runtime: skipped (no ld.lld)"; fi
  )
  bold "==> visibility (pub / private)"
  (
    KC="$(exe "$ROOT/stage2/target/release/kitec")"
    W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
    cp -r "$ROOT/pieces" "$W/reg"; mkdir -p "$W/reg/community"; cp -r "$ROOT/stdlib/tests/visibility/vis" "$W/reg/community/vis"
    export KITE_PIECES="$W/reg"; cd "$W"; "$KC" init app >/dev/null; cd app; "$KC" add vis >/dev/null
    cp "$ROOT/stdlib/tests/visibility/ok.ki" src/main.ki
    [ "$("$KC" run -q 2>/dev/null)" = "18" ] && echo "pub items usable from another piece: ok"
    cp "$ROOT/stdlib/tests/visibility/private.ki" src/main.ki
    N=$("$KC" check 2>&1 | grep -c "E0080" || true); [ "$N" = "3" ] && echo "private items rejected (function, type, const): ok"
  )
  bold "==> constants cannot be assigned"
  (
    KC="$(exe "$ROOT/stage2/target/release/kitec")"; export KITE_PIECES="$ROOT/pieces"
    W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT; cd "$W"; "$KC" init cst >/dev/null; cd cst
    printf 'const LIMIT = 3\n\nmake main():\n    const LOCAL = 4\n    LOCAL = 5\n    LOCAL += 1\n    LIMIT = 9\n    ok = 1\n    ok = 2\n' > src/main.ki
    N=$("$KC" check 2>&1 | grep -c "E0124" || true); [ "$N" = "3" ] && echo "assignments to constants rejected (E0124): ok"
  )
  bold "==> piece registry verification"
  KITE="$(exe "$ROOT/stage2/target/release/kitec")" scripts/verify-pieces.sh
fi
