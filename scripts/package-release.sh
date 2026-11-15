#!/bin/bash
# Build the release files: Linux + Windows (+ macOS when buildable) archives,
# .deb packages and checksums, with the names the installers expect:
#
#   dist/release/kite-<ver>-linux-x64.tar.gz      kite_<ver>_amd64.deb
#   dist/release/kite-<ver>-linux-arm64.tar.gz    kite_<ver>_arm64.deb
#                                                 kite-<ver>-1.x86_64.rpm  kite-<ver>-1.aarch64.rpm
#   dist/release/kite-<ver>-windows-x64.zip       dist/release/kite-<ver>-windows-arm64.zip
#   dist/release/checksums.txt
#
# Usage:
#   scripts/package-release.sh                  all targets that can be built here
#   scripts/package-release.sh --targets linux-x64,windows-x64
#   scripts/package-release.sh --compiler rust|kite|auto
#   scripts/package-release.sh --no-deb --no-rpm
#
# --compiler selects which `kite` goes into the packages:
#   rust   the Rust seed compiler (archive/rust-stage0)
#   kite   the self-hosted compiler (`kitec`, built by ./build.sh)
#   auto   `kite` if compiler/BOOTSTRAPPED exists, otherwise `rust`
#
# Cross-compilation needs the usual toolchains (or `cross` + Docker); targets
# that cannot be linked here are reported and skipped. Use the GitHub workflow
# (.github/workflows/release.yml) to build every target on native runners.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/archive/rust-stage0"
OUT="$ROOT/dist/release"
COMPILER=auto
TARGETS=linux-x64,linux-arm64,windows-x64,windows-arm64
DEB=1
RPM=1
while [ $# -gt 0 ]; do
  case "$1" in
    --compiler) COMPILER=$2; shift 2 ;;
    --targets)  TARGETS=$2;  shift 2 ;;
    --no-deb)   DEB=0; shift ;;
    --no-rpm)   RPM=0; shift ;;
    -h|--help)  sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
if [ "$COMPILER" = auto ]; then
  if [ -f "$ROOT/compiler/BOOTSTRAPPED" ]; then COMPILER=kite; else COMPILER=rust; fi
fi
VERSION=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$SRC/Cargo.toml" | head -1)
echo "==> release $VERSION, compiler: $COMPILER, targets: $TARGETS"
if [ "$COMPILER" = kite ] && [ ! -f "$ROOT/compiler/BOOTSTRAPPED" ]; then
  echo "error: the self-hosted compiler is not built yet (compiler/BOOTSTRAPPED missing): run ./build.sh" >&2
  exit 1
fi
rm -rf "$OUT"; mkdir -p "$OUT"

# 1. archives (tar.gz / zip)
if [ "$COMPILER" = kite ]; then
  # Self-hosted: `kite` is compiled by `kite` itself (no Rust). The host target uses the binary
  # produced by ./build.sh; other targets are built with `kite build --target` (needs clang
  # plus a linker/sysroot for that target) -- or natively on a runner of that OS (release.yml).
  KITE_BIN="$ROOT/compiler/target/kite"
  [ -x "$KITE_BIN" ] || { echo "error: $KITE_BIN missing: run ./build.sh" >&2; exit 1; }
  HOST=""; case "$(uname -s)-$(uname -m)" in
    Linux-x86_64) HOST=linux-x64 ;; Linux-aarch64|Linux-arm64) HOST=linux-arm64 ;;
    Darwin-arm64) HOST=macos-arm64 ;; Darwin-x86_64) HOST=macos-x64 ;; esac
  triple_of() { case "$1" in
    linux-x64) echo x86_64-unknown-linux-gnu ;; linux-arm64) echo aarch64-unknown-linux-gnu ;;
    windows-x64) echo x86_64-pc-windows-msvc ;; windows-arm64) echo aarch64-pc-windows-msvc ;;
    macos-x64) echo x86_64-apple-darwin ;; macos-arm64) echo arm64-apple-darwin ;; esac; }
  IFS=, read -ra TLIST <<< "$TARGETS"
  for short in "${TLIST[@]}"; do
    name="kite-${VERSION}-${short}"; stage="$OUT/.stage/$name"; mkdir -p "$stage"
    exe=kite; case "$short" in windows-*) exe=kite.exe ;; esac
    if [ "$short" = "$HOST" ]; then
      cp "$KITE_BIN" "$stage/$exe"
    else
      if ! ( cd "$ROOT/compiler" && "$KITE_BIN" build --release -q --target "$(triple_of "$short")" -o "$stage/$exe" ) >/tmp/kite-pkg-"$short".log 2>&1; then
        echo "   $short: skipped (cannot link for that target here, see /tmp/kite-pkg-$short.log)"; rm -rf "$stage"; continue
      fi
    fi
    rm -f "$stage"/kite.ll "$stage"/kite.exe.ll
    cp -r "$ROOT/pieces" "$stage/pieces"
    cp "$ROOT/README.md" "$ROOT/LICENSE" "$stage/" 2>/dev/null || true
    case "$short" in
      windows-*) (cd "$OUT/.stage" && zip -r -q "$OUT/$name.zip" "$name") ;;
      *)         tar -C "$OUT/.stage" -czf "$OUT/$name.tar.gz" "$name" ;;
    esac
    echo "   -> $name"
  done
  rm -rf "$OUT/.stage"
else
  "$ROOT/scripts/cross-build.sh" --targets "$TARGETS" --output-dir "$OUT" || \
    echo "   (some targets were skipped, see above)"
fi

if [ -z "$(find "$OUT" -maxdepth 1 \( -name 'kite-*.tar.gz' -o -name 'kite-*.zip' \) 2>/dev/null)" ]; then
  echo "error: no target could be built (see the logs above)." >&2
  echo "       a target is built with 'cross' (Docker/Podman) or a native cross-linker; or use the" >&2
  echo "       GitHub workflow .github/workflows/release.yml. Try:  scripts/package-release.sh --targets linux-x64" >&2
  rm -f "$OUT/checksums.txt"
  exit 1
fi

# 2. .deb packages (Linux targets that were built)
make_deb() {
  local short=$1 arch=$2
  local tarball; tarball="$OUT/kite-${VERSION}-${short}.tar.gz"; [ -f "$tarball" ] || tarball=""
  [ -n "$tarball" ] || { echo "   no $short archive, skipping its .deb"; return 0; }
  command -v dpkg-deb >/dev/null || { echo "   dpkg-deb missing, skipping .deb"; return 0; }
  local tmp; tmp=$(mktemp -d); local pkg="$tmp/pkg"
  mkdir -p "$pkg/DEBIAN" "$pkg/usr/bin" "$pkg/usr/share/kite" "$pkg/usr/share/doc/kite" "$tmp/x"
  tar -xzf "$tarball" -C "$tmp/x"
  install -m 0755 "$(find "$tmp/x" -type f -name kite | head -1)" "$pkg/usr/bin/kite"
  cp -r "$ROOT/stdlib" "$pkg/usr/share/kite/stdlib"
  cp -r "$ROOT/pieces" "$pkg/usr/share/kite/pieces"
  cp -r "$ROOT/examples" "$pkg/usr/share/kite/examples"
  cp -r "$ROOT/docs/." "$pkg/usr/share/doc/kite/"
  cp "$ROOT/LICENSE" "$pkg/usr/share/doc/kite/copyright"
  cat > "$pkg/DEBIAN/control" <<CTRL
Package: kite
Version: $VERSION
Section: devel
Priority: optional
Architecture: $arch
Depends: clang
Installed-Size: $(du -sk "$pkg" | cut -f1)
Maintainer: Kite Language <noreply@example.com>
Homepage: https://github.com/kite-language/kite
Description: The Kite programming language
 Readable like Python, fast like C, with a pinch of Rust-style safety.
 Compiles through LLVM; needs clang to produce native executables.
CTRL
  dpkg-deb --build --root-owner-group "$pkg" "$OUT/kite_${VERSION}_${arch}.deb" >/dev/null
  rm -rf "$tmp"
  echo "   -> kite_${VERSION}_${arch}.deb"
}
# .rpm packages (Fedora / RHEL / openSUSE) built with rpmbuild from the same binary
make_rpm() {
  local short=$1 rarch=$2
  local tarball="$OUT/kite-${VERSION}-${short}.tar.gz"
  [ -f "$tarball" ] || { echo "   no $short archive, skipping its .rpm"; return 0; }
  command -v rpmbuild >/dev/null || { echo "   rpmbuild missing (apt install rpm / dnf install rpm-build), skipping .rpm"; return 0; }
  local tmp; tmp=$(mktemp -d)
  mkdir -p "$tmp/x" "$tmp/top/"{BUILD,RPMS,SOURCES,SPECS,SRPMS}
  tar -xzf "$tarball" -C "$tmp/x"
  local bin; bin=$(find "$tmp/x" -type f -name kite | head -1)
  cat > "$tmp/top/SPECS/kite.spec" <<SPEC
Name:           kite
Version:        $VERSION
Release:        1
Summary:        The Kite programming language
License:        MIT
URL:            https://github.com/kite-language/kite
Requires:       clang
AutoReqProv:    no
%global debug_package %{nil}
%global _build_id_links none
%global __os_install_post %{nil}
%description
Readable like Python, fast like C, with a pinch of Rust-style safety.
Compiles through LLVM; needs clang to produce native executables.

%install
mkdir -p %{buildroot}/usr/bin %{buildroot}/usr/share/kite %{buildroot}/usr/share/doc/kite
install -m 0755 $bin %{buildroot}/usr/bin/kite
cp -r $ROOT/stdlib %{buildroot}/usr/share/kite/stdlib
cp -r $ROOT/pieces %{buildroot}/usr/share/kite/pieces
cp -r $ROOT/examples %{buildroot}/usr/share/kite/examples
cp -r $ROOT/docs/. %{buildroot}/usr/share/doc/kite/

%files
/usr/bin/kite
/usr/share/kite
/usr/share/doc/kite
SPEC
  rpmbuild -bb --quiet --target "$rarch" --define "_topdir $tmp/top" "$tmp/top/SPECS/kite.spec" >/dev/null 2>"$tmp/rpm.err" \
    || { echo "   rpmbuild failed:"; sed 's/^/     /' "$tmp/rpm.err"; rm -rf "$tmp"; return 0; }
  cp "$tmp"/top/RPMS/*/kite-*.rpm "$OUT/"
  rm -rf "$tmp"
  echo "   -> kite-${VERSION}-1.${rarch}.rpm"
}
if [ "$RPM" = 1 ]; then
  case ",$TARGETS," in *,linux-x64,*)   make_rpm linux-x64 x86_64 ;; esac
  case ",$TARGETS," in *,linux-arm64,*) make_rpm linux-arm64 aarch64 ;; esac
fi

if [ "$DEB" = 1 ]; then
  case ",$TARGETS," in *,linux-x64,*)   make_deb linux-x64 amd64 ;; esac
  case ",$TARGETS," in *,linux-arm64,*) make_deb linux-arm64 arm64 ;; esac
fi

# 3. checksums
( cd "$OUT" && ls | grep -v checksums.txt | xargs -r sha256sum > checksums.txt ) || true
echo "==> done:"; ls -la "$OUT"
