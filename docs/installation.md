# Installation

Kite ships as one `kite` command. It needs a C toolchain (`clang`) to turn the generated LLVM IR into a program.

## Linux

```sh
curl -fsSL https://kite-lang.pages.dev/install.sh | sh
```

Installs into `~/.local/bin`. Needs `curl` (or `wget`) and `tar`. On Debian/Ubuntu add `-s -- --deb`, on Fedora/RHEL `-s -- --rpm`.
Install clang with your package manager (`sudo apt install clang`).

## macOS (Apple silicon)

```sh
curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh
```

Install the command line tools first with `xcode-select --install`.

## Windows

```powershell
irm https://kite-lang.pages.dev/install.ps1 | iex
```

Installs into `%LOCALAPPDATA%\Kite\bin` and adds it to your user `PATH`. Install clang with `winget install LLVM.LLVM`.

> **Note:** Windows and macOS support is young. If something fails, open an issue with the full output of `kite build`.

## Check the installation

```sh
kite --version
kite init hello
cd hello
kite run
```

## Pin a version or uninstall

```sh
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --version 0.4.9
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --uninstall
```

## Next step

Follow [your first project](/guide/first-project/).
