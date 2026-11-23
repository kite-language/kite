# Votre premier projet

```sh
kite init hello
cd hello
kite run
```

`kite init` crée :

| fichier | rôle |
|---------|------|
| `kite.toml` | le manifeste : nom, version, description, auteurs, licence, dépendances |
| `src/main.ki` | le programme : une fonction `make main():` |
| `.gitignore` | ignore `target/` |

`src/main.ki` :

```kite
make main():
    print("Hello, Kite!")
```

## Les commandes de tous les jours

| commande | ce qu'elle fait |
|----------|-----------------|
| `kite run` | compile (si besoin) et exécute |
| `kite build [--release]` | compile vers `target/debug/<nom>` ou `target/release/<nom>` (`--release` optimise) |
| `kite check` | vérifie seulement les types (rapide) |
| `kite test` | compile et exécute chaque `tests/*.ki` |
| `kite fmt [--check]` | normalise les espaces |
| `kite doc` | écrit `target/doc/<nom>.md` à partir de vos commentaires `//` |
| `kite clean` | supprime `target/` |

Quand rien n'a changé, kite affiche `Fresh` et saute le compilateur : la compilation est mise en cache grâce à une empreinte de vos sources,
de vos pièces et de la version du compilateur.

## Les métadonnées du paquet dans votre programme

`kite.toml` peut décrire le paquet, et le programme peut le lire :

```toml
[package]
name = "hello"
version = "0.1.0"
description = "My first Kite program"
authors = ["Ada <ada@example.com>"]
license = "MIT"
```

```kite
make main():
    print(f"{pkg_name()} {pkg_version()} by {pkg_authors()}")
```

Chaque binaire porte aussi une signature (`kite inspect target/debug/hello` affiche le paquet, le compilateur et la compilation).
