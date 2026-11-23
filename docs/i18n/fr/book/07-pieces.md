# Pièces (paquets)

Une **pièce** est une bibliothèque : un dossier avec `kite.toml` et `src/lib.ki`.

```sh
kite init --lib shapes     # en créer une
kite add sha256            # en utiliser une (voir plus bas)
```

## Deux sortes

- Les **pièces par défaut** (`std.*`) sont livrées avec Kite et ne demandent aucune déclaration : `use std.fs`.
- Les **pièces communautaires** vivent dans le registre du dépôt. Déclarez-les dans `[dependencies]` (`kite add table`) et
  importez-les par leur nom : `use table`.

```kite
use std.strings         // une pièce par défaut
use table               // une pièce communautaire (listée dans kite.toml)

make main():
    t = table_new(2)
    table_add_row(t, ["name", "qty"])
    print(table_render(t))
    print(strings.upper("kite"))     // appels piece.function(...)
```

## Appeler des pièces

`piece.function(args)` est la manière lisible d'appeler une pièce. Cela désigne la fonction nommée `<pièce>_<fonction>` :
`fs.read(path)` vaut `fs_read(path)`, `strings.upper(s)` vaut `strings_upper(s)`. Si une variable locale porte le même nom que la
pièce, la variable l'emporte (utilisez le nom long).

Les fonctions de toutes les pièces partagent un seul espace de noms en interne : nommez les vôtres `<pièce>_<fonction>`.

## Gérer les dépendances

```sh
kite search json       # trouver des pièces
kite info semver       # métadonnées et versions
kite add sha256@^1.2   # ajouter avec une contrainte (^ ~ >= < =)
kite tree              # arbre des dépendances (sous-dépendances comprises)
kite update            # re-résoudre kite.lock
kite remove sha256
```

`kite.lock` enregistre les versions exactes et les sommes de contrôle ; si une copie du registre change, la compilation s'arrête.

## Publier

```sh
kite verify            # mêmes vérifications que la CI du registre
kite publish           # prépare pieces/community/<nom>/<version>/ et affiche les commandes git
```

`kite publish` n'exécute jamais git : vous lancez les commandes affichées et ouvrez une pull request ; la CI compile chaque pièce modifiée.

## Éléments publics et privés

Par défaut, tout est public. Dès qu'un fichier marque un élément de premier niveau `pub`, ce fichier passe en *mode explicite* :
les éléments sans `pub` sont **privés à leur pièce** (tous les fichiers sous le `src/` de la pièce).

```kite
pub type Point:
    x: int
    y: int

pub make dist(a: Point, b: Point) -> int:     // fait partie de l'interface
    return abs(a.x - b.x) + abs(a.y - b.y)

make helper(n: int) -> int:                   // privé : les autres pièces ne peuvent pas l'appeler
    return n * 2
```

`pub` s'applique à `make`, `type`, `class`, `enum` et `const`. Les méthodes d'une classe suivent la classe. Utiliser un élément privé
d'une autre pièce est l'erreur `E0080`. La référence des [pièces standard](/reference/std-pieces/) ne liste que les éléments `pub` d'une pièce qui utilise `pub`.

> **Astuce :** commencez en privé, et marquez `pub` seulement ce dont les utilisateurs de votre pièce ont besoin : l'interface reste petite et vous pouvez changer le reste librement.
