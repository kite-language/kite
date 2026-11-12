#!/usr/bin/env python3
# Sorts the run of `@.str.N = ...` constants (Rust emits them in HashMap order).
import sys, re
lines = sys.stdin.read().split("\n")
out, run = [], []
for l in lines:
    if re.match(r"^@\.str\.\d+ = ", l):
        run.append(l)
    else:
        if run:
            out += sorted(run); run = []
        out.append(l)
if run: out += sorted(run)
sys.stdout.write("\n".join(out))
