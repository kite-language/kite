# Écrire du Kite lisible

- **4 espaces**, pas de tabulations (`kite fmt` corrige les espaces).
- Des **f-strings** plutôt que des chaînes de `+` : `f"{name}: {count}"`.
- Des **chaînes d'appels** plutôt que des variables temporaires quand chaque étape se lit naturellement :
  ```kite
  names = text
      .trim()
      .split(",")
  ```
- `x.incr()` / `x.decr()` plutôt que `x += 1` quand l'intention est « un de plus ».
- Nommez les fonctions d'une pièce `<pièce>_<fonction>` et appelez-les `piece.function()`.
- Mettez un commentaire `//` au-dessus de chaque fonction que vous voulez dans `kite doc`.
- Préférez `const` aux nombres magiques.
- Gardez les fonctions courtes ; retournez tôt.
- Marquez `pub` seulement l'interface d'une pièce ; le reste reste privé.
- Noms à éviter pour les variables et les fonctions (réservés) : `to in int float string bool ptr null`, et les fonctions intégrées (`len`, `print`, ...).
  Les autres mots-clés (`from`, `type`, `match`, ...) passent comme noms, mais un nom plus clair se lit mieux.
