# Fonctions et constantes

```kite
make area(w: int, h: int) -> int:
    return w * h

make greet(name: string):          // pas de `->` : ne retourne rien
    print(f"Hello, {name}!")
```

- Les paramètres sont typés ; le type de retour peut être omis, il est alors inféré depuis le premier `return`.
- Les fonctions récursives et mutuellement récursives demandent un `-> Type` explicite.
- Valeurs par défaut et arguments nommés : `make connect(host: string, port: int = 80)` s'appelle `connect("a")` ou
  `connect("a", port = 8080)`.
- `*items: int` rassemble les arguments supplémentaires dans une liste `items` de ce type d'élément (`total(1, 2, 3)`).
- Retournez plusieurs valeurs avec un tuple : `return (1, "one")`, recevez-les avec `n, word = pair()`.

## Constantes

```kite
const LIMIT = 100
const GREETING: string = "hello"
```

Une constante se lit comme une variable et ne peut pas être réassignée. (En interne c'est une fonction sans argument : ce peut donc être
n'importe quelle expression.)

Une constante peut aussi être déclarée **dans une fonction**, et toute constante est en lecture seule : lui assigner une valeur (`LIMIT = 9`,
`LIMIT += 1`, `LIMIT.incr()`, ou modifier un champ d'un record constant) est l'erreur `E0124`.

```kite
const LIMIT = 100                  // globale : visible partout

make main():
    const STEP = LIMIT / 4         // locale à cette fonction
    total = 0
    total += STEP                  // correct : `total` est une variable ordinaire
```

## Appeler des fonctions

Deux écritures équivalentes ; utilisez celle qui se lit le mieux :

```kite
len(text)           // appel simple
text.len()          // syntaxe d'appel uniforme : value.f(args) vaut f(value, args)
```

La syntaxe d'appel uniforme fait lire les chaînes d'appels de gauche à droite, et une chaîne peut continuer à la ligne suivante :

```kite
words = "  one, two ,three  "
    .trim()
    .split(",")
```

Elle s'applique à toute valeur qui n'est pas une instance de classe (les méthodes de classe gardent leur propre sens).

## Commentaires de documentation

Les commentaires `//` placés juste au-dessus d'une fonction, d'un type ou d'une classe sont collectés par `kite doc`.

## Fonctions génériques

Une fonction peut prendre des **paramètres de type** entre chevrons. Le compilateur les déduit des arguments et produit une copie
spécialisée pour chaque combinaison de types : une fonction générique est aussi rapide qu'une fonction écrite à la main.

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

make pick<A, B>(a: A, b: B) -> A:
    return a

make main():
    print(first([4, 5, 6]))        // 4      (T = int)
    print(first(["a", "b"]))       // a      (T = string)
    print(pick(7, "x"))            // 7      (A = int, B = string)
```

- Un paramètre de type peut apparaître dans un type de paramètre sous la forme `T`, `[T]` ou `ptr<T>`, ainsi que dans le type de retour et le corps.
- Chaque paramètre de type doit pouvoir être déduit des arguments (`E0123` sinon) ; deux paramètres du même `T` doivent s'accorder (`E0122`).
- Les fonctions génériques sont de premier niveau uniquement (pas de méthodes génériques) et demandent `-> Type` quand elles retournent une valeur.
- Les records génériques (`Box<T>`) et les `Option<T>` / `Result<T, E>` prêts à l'emploi sont dans le chapitre [Génériques](/guide/generics/).
