#!/bin/bash
# runexamples.sh KITEC: builds every example that has a recorded .out with the given kitec
# (`kitec ll` + clang) and compares the program output.
KC="${1:?usage: runexamples.sh path/to/kitec}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
for f in "$ROOT"/examples/stable/*.ki "$ROOT"/examples/lang5/*.ki; do
  out="${f%.ki}.out"; [ -f "$out" ] || continue
  tmp=$(mktemp -d)
  if "$KC" ll "$f" > "$tmp/p.ll" 2> "$tmp/err" && clang "$tmp/p.ll" -O0 -o "$tmp/p" -Wno-override-module 2>> "$tmp/err"; then
    (cd "$(dirname "$f")" && "$tmp/p" > "$tmp/actual" 2>&1)
    if cmp -s "$tmp/actual" "$out"; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (output) $f"; fi
  else
    fail=$((fail+1)); echo "FAIL (build) $f: $(head -c 200 "$tmp/err")"
  fi
  rm -rf "$tmp"
done
echo "examples: $pass passed, $fail failed"
