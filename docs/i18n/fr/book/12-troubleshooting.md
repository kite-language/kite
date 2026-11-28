# Dépannage

## `clang failed to compile the generated LLVM IR`

Kite écrit de l'IR LLVM et demande à `clang` de le compiler. Le message d'erreur nomme le fichier `.ll` dans `target/` : ouvrez-le à la ligne indiquée.
Si le programme est du Kite ordinaire, c'est un bug du compilateur : signalez-le en joignant le fichier `.ll`.

## `clang: command not found`

Installez clang (`sudo apt install clang`, `xcode-select --install` ou `winget install LLVM.LLVM`).

## `E0080: ... is private to the piece that defines it`

La pièce marque certains éléments `pub`, donc les autres sont privés. Demandez à l'auteur de la pièce de marquer l'élément `pub`, ou utilisez une fonction publique.
Dans votre propre projet, il n'y a pas cette restriction tant que votre fichier n'utilise pas `pub`.

## `E0072: piece ... has no function ...`

Les fonctions d'une pièce s'appellent `piece.function(...)`. La pièce doit être importée (`use std.fs`, ou `use nom` après `kite add nom`).
Voir la liste des fonctions dans les [pièces standard](/reference/std-pieces/).

## Une variable ne peut pas porter ce nom

Quelques mots sont réservés (`to in int float string bool ptr null`),
et les noms intégrés `str len print append pop remove insert clear free arg` sont pris. Choisissez un autre nom.
Des mots comme `from`, `type`, `use`, `match`, `case`, `class`, `thread` ou `try` sont acceptés comme noms (`from = 3`, `make f(case: int)`) ;
après un `.`, tout mot est accepté : `job.thread` est valide.

## Erreur de segmentation avec des listes dans des classes

Assigner une classe copie son en-tête : deux noms peuvent alors partager un même tampon. Utilisez `self.items.append(x)` et non une copie comme `items = self.items`.

## Un champ `string` fait planter `len()`

Un champ `string` d'un record fraîchement créé est un pointeur nul tant que vous ne l'avez pas renseigné. Renseignez le champ avant de le lire.

## Windows : erreurs d'édition de liens sur `printf` ou `timespec_get`

Passez à la dernière version (ces symboles sont fournis par les shims de Kite). Relancez `kite build` et signalez toute la sortie si cela échoue encore.

## Couleurs dans les messages d'erreur

Les erreurs sont colorées dans un terminal. Définissez `NO_COLOR=1` pour désactiver les couleurs, ou `KITE_COLOR=always` / `KITE_COLOR=never` pour les forcer ou les couper (par exemple dans un journal de CI).
