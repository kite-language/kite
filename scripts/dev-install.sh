#!/bin/bash
# Sets up a local development environment from the sibling repositories of the kite-language organization:
#
#   <workspace>/kite   tree-sitter-kite   vscode-kite   zed-kite   kate-kite   notepadpp-kite
#   (zed-extensions is not needed; missing editor repositories are simply skipped)
#
# It builds and installs from your LOCAL checkouts, and never runs a git command that writes
# (no commit, push, pull, checkout...). It only reads versions and commit ids.
#
#   scripts/dev-install.sh                     show the workspace, versions and what is installed
#   scripts/dev-install.sh --all               kite + kate + vscode + zed + tree-sitter tests
#   scripts/dev-install.sh --kite --vscode     pick components
#   scripts/dev-install.sh --uninstall         remove what this script installed
#
# Components: --kite (compiler -> ~/.local/bin/kite, kitec)   --vscode (.vsix installed with `code`)
#             --zed (dev copy for "zed: install dev extension")   --kate (syntax definition from ../kate-kite)
#             --tree-sitter (npm install + grammar tests)   --npp (Notepad++ files, Windows)
# Options:    --workspace DIR   --prefix DIR (default ~/.local)   --snapshot (zed: use uncommitted grammar)
#             --dry-run         --help
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE="$(dirname "$HERE")"
PREFIX="${HOME}/.local"
DRY=0; SNAPSHOT=0; UNINSTALL=0; DO=()

while [ $# -gt 0 ]; do
  case "$1" in
    --all) DO+=(kite kate vscode zed tree-sitter); shift ;;
    --kite|--vscode|--zed|--kate|--tree-sitter|--npp) DO+=("${1#--}"); shift ;;
    --workspace) WORKSPACE="$(cd "${2:?--workspace needs a directory}" && pwd)"; shift 2 ;;
    --prefix) PREFIX="${2:?--prefix needs a directory}"; shift 2 ;;
    --snapshot) SNAPSHOT=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
done

KITE="$HERE"
TS="$WORKSPACE/tree-sitter-kite"; VS="$WORKSPACE/vscode-kite"; ZED="$WORKSPACE/zed-kite"
KATE="$WORKSPACE/kate-kite"; NPP="$WORKSPACE/notepadpp-kite"
BIN="$PREFIX/bin"
KATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/org.kde.syntax-highlighting/syntax"

if [ -t 1 ]; then B='\033[1m'; G='\033[32m'; R='\033[31m'; Y='\033[33m'; Z='\033[0m'; else B=''; G=''; R=''; Y=''; Z=''; fi
say()  { printf '%b%s%b\n' "$B" "$*" "$Z"; }
ok()   { printf '%b✔ %s%b\n' "$G" "$*" "$Z"; }
warn() { printf '%b! %s%b\n' "$Y" "$*" "$Z" >&2; }
die()  { printf '%b✘ %s%b\n' "$R" "$*" "$Z" >&2; exit 1; }
run()  { if [ "$DRY" = 1 ]; then echo "  [dry-run] $*"; else "$@"; fi; }

# ---- versions (read-only) ------------------------------------------------------------
ver_json() { python3 - "$1" "$2" <<'PY' 2>/dev/null || echo "?"
import json, sys
d = json.load(open(sys.argv[1]))
for k in sys.argv[2].split("."):
    d = d[k]
print(d)
PY
}
ver_toml() { sed -n 's/^version *= *"\(.*\)"/\1/p' "$1" 2>/dev/null | head -1; }
commit_of() { [ -d "$1/.git" ] && git -C "$1" rev-parse --short HEAD 2>/dev/null || echo "-"; }
dirty_of()  { [ -d "$1/.git" ] && [ -n "$(git -C "$1" status --porcelain 2>/dev/null)" ] && echo " (uncommitted changes)" || true; }

show_status() {
  say "workspace: $WORKSPACE"
  printf '  %-18s %-10s %-9s %s\n' repository version commit state
  row() { # name dir version
    if [ -d "$2" ]; then printf '  %-18s %-10s %-9s %s\n' "$1" "$3" "$(commit_of "$2")" "ok$(dirty_of "$2")"
    else printf '  %-18s %-10s %-9s %s\n' "$1" "-" "-" "MISSING at $2"; fi; }
  row kite "$KITE" "$(ver_toml "$KITE/compiler/kite.toml")"
  row tree-sitter-kite "$TS" "$(ver_json "$TS/package.json" version)"
  row vscode-kite "$VS" "$(ver_json "$VS/package.json" version)"
  row zed-kite "$ZED" "$(ver_toml "$ZED/extension.toml")"
  row kate-kite "$KATE" "$(sed -n 's/^## \([0-9][0-9.]*\).*/\1/p' "$KATE/CHANGELOG.md" 2>/dev/null | head -1)"
  row notepadpp-kite "$NPP" "$(sed -n 's/^## \([0-9][0-9.]*\).*/\1/p' "$NPP/CHANGELOG.md" 2>/dev/null | head -1)"
  echo
  say "installed:"
  [ -x "$BIN/kite" ]  && echo "  kite  -> $BIN/kite ($("$BIN/kite" --version 2>/dev/null))" || echo "  kite  -> not installed in $BIN"
  [ -x "$BIN/kitec" ] && echo "  kitec -> $BIN/kitec"
  [ -f "$KATE_DIR/kite.xml" ] && echo "  kate  -> $KATE_DIR/kite.xml" || echo "  kate  -> not installed"
  if command -v code >/dev/null 2>&1; then
    code --list-extensions --show-versions 2>/dev/null | grep -i "kite-language" | sed 's/^/  vscode -> /' || echo "  vscode -> not installed"
  else echo "  vscode -> 'code' not found"; fi
}

need_dir() { [ -d "$1" ] || die "missing repository: $1  (clone it next to kite: git clone https://github.com/kite-language/$(basename "$1").git)"; }

# ---- components -------------------------------------------------------------------------
do_kite() {
  say "==> kite: build (stage0 Rust -> kitec) and install into $BIN"
  run "$KITE/build.sh"
  run mkdir -p "$BIN"
  if [ -x "$KITE/compiler/target/kite" ]; then run install -m 0755 "$KITE/compiler/target/kite" "$BIN/kite"; else run install -m 0755 "$KITE/archive/rust-stage0/target/release/kite" "$BIN/kite"; fi
  [ -x "$KITE/compiler/target/kitec" ] && run install -m 0755 "$KITE/compiler/target/kitec" "$BIN/kitec"
  ok "installed $BIN/kite (add $BIN to your PATH if needed)"
  command -v clang >/dev/null 2>&1 || warn "clang not found: kite needs it to build programs (sudo apt install clang)"
}
do_kate() {
  say "==> kate: install the syntax definition"
  need_dir "$KATE"
  run mkdir -p "$KATE_DIR"
  run cp "$KATE/kite.xml" "$KATE_DIR/kite.xml"
  ok "installed $KATE_DIR/kite.xml (restart Kate)"
}
do_vscode() {
  say "==> vscode: build and install the extension from $VS"
  need_dir "$VS"
  command -v npm >/dev/null 2>&1 || die "npm is required to package the extension"
  run bash -c "cd '$VS' && npm install --no-audit --no-fund && npm test && npm run package"
  VSIX="$(ls -t "$VS"/*.vsix 2>/dev/null | head -1 || true)"
  if command -v code >/dev/null 2>&1 && { [ "$DRY" = 1 ] || [ -n "$VSIX" ]; }; then
    run code --install-extension "${VSIX:-<built .vsix>}" --force
    ok "extension installed (reload VS Code)"
  else
    warn "'code' not found: install ${VSIX:-the .vsix} with 'Extensions: Install from VSIX...'"
  fi
}
do_zed() {
  say "==> zed: prepare the dev extension from $ZED"
  need_dir "$ZED"; need_dir "$TS"
  if [ "$SNAPSHOT" = 1 ]; then run "$ZED/scripts/dev-install.sh" --snapshot; else run "$ZED/scripts/dev-install.sh"; fi
}
do_tree_sitter() {
  say "==> tree-sitter: install tools and run the grammar tests in $TS"
  need_dir "$TS"
  command -v npm >/dev/null 2>&1 || die "npm is required"
  run bash -c "cd '$TS' && npm install --no-audit --no-fund && npm run generate && npm test"
  ok "grammar tests passed"
}
do_npp() {
  need_dir "$NPP"
  say "==> notepad++: files are in $NPP"
  warn "Notepad++ is Windows-only: run  powershell -ExecutionPolicy Bypass -File install.ps1  (in notepadpp-kite)"
}

undo() {
  say "==> uninstall"
  run rm -f "$BIN/kite" "$BIN/kitec" "$KATE_DIR/kite.xml"
  command -v code >/dev/null 2>&1 && run code --uninstall-extension kite-language.kite-language-vscode || true
  ok "removed (Zed dev extensions are removed from Zed's Extensions page)"
}

# ---- main ---------------------------------------------------------------------------------
if [ "$UNINSTALL" = 1 ]; then undo; exit 0; fi
show_status
[ ${#DO[@]} -eq 0 ] && { echo; echo "nothing to do: pick components (--all, --kite, --vscode, ...)"; exit 0; }
echo
for c in "${DO[@]}"; do
  case "$c" in
    kite) do_kite ;; kate) do_kate ;; vscode) do_vscode ;; zed) do_zed ;;
    tree-sitter) do_tree_sitter ;; npp) do_npp ;;
  esac
done
echo; ok "done"
