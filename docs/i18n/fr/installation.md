# Installation

Kite est livré sous la forme d'une seule commande, `kite`. Il faut une chaîne d'outils C (`clang`) pour transformer l'IR LLVM généré en programme.

## Linux

```sh
curl -fsSL https://kite-lang.pages.dev/install.sh | sh
```

Installe dans `~/.local/bin`. Nécessite `curl` (ou `wget`) et `tar`. Sur Debian/Ubuntu, ajoutez `-s -- --deb` ; sur Fedora/RHEL, `-s -- --rpm`.
Installez clang avec votre gestionnaire de paquets (`sudo apt install clang`).

## macOS (Apple silicon)

```sh
curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh
```

Installez d'abord les outils en ligne de commande avec `xcode-select --install`.

## Windows

```powershell
irm https://kite-lang.pages.dev/install.ps1 | iex
```

Installe dans `%LOCALAPPDATA%\Kite\bin` et l'ajoute au `PATH` de l'utilisateur. Installez clang avec `winget install LLVM.LLVM`.

> **Remarque :** la prise en charge de Windows et de macOS est récente. Si quelque chose échoue, ouvrez une issue avec toute la sortie de `kite build`.

## Vérifier l'installation

```sh
kite --version
kite init hello
cd hello
kite run
```

## Fixer une version ou désinstaller

```sh
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --version 0.7.0
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --uninstall
```

## Étape suivante

Suivez [votre premier projet](/guide/first-project/).
