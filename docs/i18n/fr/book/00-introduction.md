# Kite

Kite est un langage compilé, lisible comme Python et rapide comme C. Il a des blocs définis par l'indentation, des types
statiques inférés et aucune pause de ramasse-miettes : `kite build` transforme votre programme en code natif.

```kite
make main():
    name = "Kite"
    print(f"Hello from {name}!")
```

**Ce que vous obtenez**

- Un compilateur écrit en Kite lui-même (il se compile : stage 1 = stage 2 = stage 3).
- Les **pièces** : les paquets de Kite. Le langage fournit 40 pièces par défaut (`std.fs`, `std.json`, `std.random`, ...) et un
  registre communautaire hébergé dans le dépôt.
- Des threads, des pointeurs et de la mémoire manuelle quand vous en avez besoin ; des chaînes, listes, tuples et dictionnaires quand vous n'en avez pas besoin.
- `kite` fait tout : `init`, `build`, `run`, `check`, `test`, `fmt`, `doc`, `add`, `publish`, `target`, ...
- Un mode freestanding avec son propre petit runtime, pour les noyaux et les microcontrôleurs.

**Par où commencer**

1. [Installer Kite](/installation/) -- une commande sur Linux et macOS, une sur Windows.
2. [Votre premier projet](/guide/first-project/) -- `kite init`, `kite run`.
3. [Variables et types](/guide/variables/), [structures de contrôle](/guide/control-flow/), [fonctions](/guide/functions/).
4. [Pièces](/guide/pieces/) quand vous voulez une bibliothèque, [les pièces standard](/reference/std-pieces/) pour ce qui est inclus.
