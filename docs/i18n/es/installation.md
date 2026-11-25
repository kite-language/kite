# Instalación

Kite se distribuye como un único comando, `kite`. Necesita una cadena de herramientas de C (`clang`) para convertir el IR de LLVM generado en un programa.

## Linux

```sh
curl -fsSL https://kite-lang.pages.dev/install.sh | sh
```

Instala en `~/.local/bin`. Necesita `curl` (o `wget`) y `tar`. En Debian/Ubuntu añade `-s -- --deb`; en Fedora/RHEL, `-s -- --rpm`.
Instala clang con tu gestor de paquetes (`sudo apt install clang`).

## macOS (Apple silicon)

```sh
curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh
```

Instala antes las herramientas de línea de comandos con `xcode-select --install`.

## Windows

```powershell
irm https://kite-lang.pages.dev/install.ps1 | iex
```

Instala en `%LOCALAPPDATA%\Kite\bin` y lo añade al `PATH` del usuario. Instala clang con `winget install LLVM.LLVM`.

> **Nota:** el soporte de Windows y macOS es joven. Si algo falla, abre un issue con toda la salida de `kite build`.

## Comprobar la instalación

```sh
kite --version
kite init hello
cd hello
kite run
```

## Fijar una versión o desinstalar

```sh
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --version 0.5.2
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --uninstall
```

## Siguiente paso

Sigue [tu primer proyecto](/guide/first-project/).
