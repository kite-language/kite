# La commande `kite`

```sh
kite <commande> [options]
```

| commande | ce qu'elle fait |
|----------|-----------------|
| `kite init [NOM]` | crée un paquet (`--lib` pour une pièce) ; sans nom, dans le dossier courant |
| `kite build` | compile le paquet |
| `kite run` | compile, puis exécute le programme |
| `kite check` | vérifie les types sans produire de binaire |
| `kite test [FILTRE]` | compile et exécute `tests/*.ki` (un code de sortie non nul est un échec) |
| `kite fmt [--check]` | normalise les espaces dans `src/` et `tests/` |
| `kite doc` | écrit `target/doc/<nom>.md` à partir des commentaires `//` au-dessus des éléments |
| `kite clean` | supprime `target/` |
| `kite bench [--runs N]` | compile en mode release et chronomètre des exécutions répétées |
| `kite add NOM[@REQ]` / `remove NOM` | modifie `[dependencies]` |
| `kite update` | re-résout les dépendances et réécrit `kite.lock` |
| `kite tree` | affiche l'arbre des dépendances |
| `kite search [REQUÊTE]` / `kite info PIÈCE` | parcourt le registre des pièces |
| `kite verify` / `kite publish` | vérifie une pièce / prépare sa pull request |
| `kite target list\|add\|remove\|show [NOM]` | gère les cibles de compilation |
| `kite inspect FICHIER` | affiche la signature Kite stockée dans un binaire |

## kite build

| option | signification |
|--------|---------------|
| `--release` | optimise (`-O3`), résultat dans `target/release/` |
| `--target T` | compile pour une autre cible (`target/<T>/<profil>/`) |
| `-q`, `--quiet` | pas de lignes de progression |
| `-o FICHIER`, `--out-dir DOSSIER` | où placer le résultat |
| `--link FICHIER` | lie un objet/une bibliothèque supplémentaire (répétable) |
| `--static` | lie statiquement |
| `--lib` | un fichier objet plus un en-tête C, pour appeler Kite depuis C |
| `--freestanding` | un fichier objet sans dépendance à libc, sans `main` |
| `--runtime core` | ajoute le runtime intégré sans libc (allocateur « bump », fonctions mémoire et chaînes) |
| `--heap-size N` | tas de ce runtime en octets (par défaut 1048576) |
| `--backend native` | générateur x86-64 expérimental, sans clang (sous-ensemble entier) |

`kite.toml` règle les mêmes options : `[build] opt_level`, `target`, `runtime`, `heap_size`.

## Sortie de compilation

```
   Compiling sha256 v0.4.9 (/home/me/kite/pieces/std/sha256/0.4.9)
   Compiling hello v0.1.0 (/home/me/hello)
    Finished dev [unoptimized] target(s) in 0.42s
```

`Fresh` remplace `Compiling` quand rien n'a changé. Organisation : `target/debug/<nom>`, `target/release/<nom>`, avec
l'IR LLVM (`<nom>.ll`) à côté du binaire et l'empreinte du cache dans `.fingerprint/`.

## Environnement

| variable | signification |
|----------|---------------|
| `KITE_PIECES` | le dossier du registre (le `pieces/` du dépôt) |
| `KITE_HOME` | où `kite target add` installe les cibles (par défaut `~/.kite`) |
