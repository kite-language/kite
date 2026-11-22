#!/usr/bin/env python3
# Sorts the run of `@.str.N = ...` constants (Rust emits them in HashMap order).
import sys, re
# the build signature (@.kite.meta, @llvm.used) exists only in binaries built by the Kite compiler, not by the Rust seed
lines = [l for l in sys.stdin.read().split("\n") if not (l.startswith("@.kite.meta") or l.startswith("@llvm.used"))]
out, run = [], []
for l in lines:
    if re.match(r"^@\.str\.\d+ = ", l):
        run.append(l)
    else:
        if run:
            out += sorted(run); run = []
        out.append(l)
if run: out += sorted(run)
sys.stdout.write("\n".join(out).rstrip("\n") + "\n")
