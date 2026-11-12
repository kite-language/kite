#!/bin/bash
# llcmp.sh FILES...: compares the LLVM IR of kitec (Kite) and the Rust stage0, with the string
# constants sorted (Rust emits them in HashMap order).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RS="$ROOT/archive/rust-stage0/target/release/examples/dump_ast"
KC="$ROOT/compiler/target/kitec"
norm() { python3 "$ROOT/scripts/llnorm.py"; }
bad=0; total=0
for f in "$@"; do
  total=$((total+1))
  $RS ll "$f" 2>/dev/null | norm > /tmp/ll_rs.txt; rs=${PIPESTATUS[0]}
  $KC ll "$f" 2>/dev/null | norm > /tmp/ll_ki.txt; ki=${PIPESTATUS[0]}
  if [ "$rs" != "$ki" ]; then echo "EXIT DIFF $f (rs=$rs ki=$ki)"; bad=$((bad+1)); continue; fi
  if ! cmp -s /tmp/ll_rs.txt /tmp/ll_ki.txt; then echo "DIFF $f"; bad=$((bad+1)); fi
done
echo "ll: $total files, $bad differ"
