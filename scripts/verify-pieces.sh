#!/bin/bash
# verify-pieces.sh: the registry checks run by CI on every pull request that touches pieces/.
#   KITE=path/to/kite   the compiler to use (default: kite on PATH)
#   --base REF          also fail when a published version directory that exists at REF was modified
# For every pieces/<name>/<version>/: kite.toml metadata and directory names agree, the piece
# compiles (`kite verify`), and published versions stay immutable. Read-only: never writes to git.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KITE="${KITE:-kite}"
BASE=""
[ "${1:-}" = "--base" ] && BASE="${2:?--base needs a ref}"
export KITE_PIECES="$ROOT/pieces"
bad=0; n=0
for dir in "$ROOT"/pieces/*/*/; do
  [ -f "$dir/kite.toml" ] || continue
  n=$((n+1))
  if ! (cd "$dir" && "$KITE" verify > /tmp/verify-piece.log 2>&1); then
    echo "FAIL ${dir#$ROOT/}: $(grep -m1 'error' /tmp/verify-piece.log)"; bad=$((bad+1))
  fi
done
if [ -n "$BASE" ]; then
  # files changed under an existing version directory (modified or deleted, not added) are rejected
  changed=$(git -C "$ROOT" diff --name-status --diff-filter=MDR "$BASE"...HEAD -- pieces 2>/dev/null | awk '{print $2}')
  if [ -n "$changed" ]; then
    echo "FAIL published piece versions are immutable; these files changed:"; echo "$changed" | sed 's/^/    /'; bad=$((bad+1))
  fi
fi
echo "pieces: $n checked, $bad problem(s)"
[ "$bad" -eq 0 ]
