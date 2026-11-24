# Génériques

Les génériques permettent à une seule définition de fonctionner pour plusieurs types. Kite a des **fonctions génériques** et des
**records génériques** ; les deux sont spécialisés à la compilation (une copie par combinaison de types), donc ils ne coûtent rien à l'exécution.

## Fonctions génériques

```kite
make first<T>(xs: [T]) -> T:
    return xs[0]

make main():
    print(first([4, 5, 6]))        // T = int
    print(first(["a", "b"]))       // T = string
```

Le compilateur déduit les paramètres de type à partir des arguments. Un paramètre de type peut apparaître sous la forme `T`, `[T]`, `ptr<T>`
ou à l'intérieur d'un record générique comme `Box<T>`. S'il ne peut pas être déduit, l'appel est l'erreur `E0123`.

## Records génériques

```kite
type Box<T>:
    value: T
    count: int

type Pair<A, B>:
    first: A
    second: B

make main():
    b = Box<int>()                 // arguments de type entre chevrons
    b.value = 41
    p = Pair<string, int>()
    p.first = "k"
    p.second = 7

    boxes: [Box<int>] = []         // aussi dans les types
    append(boxes, b)
    nested = Box<Box<int>>()       // et imbriqués
```

`Box<int>` et `Box<string>` sont deux types différents issus de la même définition. Les fonctions génériques peuvent les prendre et les
retourner : `make wrap<T>(x: T) -> Box<T>:` et `make unwrap<T>(b: Box<T>) -> T:`.
Les records génériques sont de simples records `type` (pas encore de classes ni d'enums génériques).

## Option et Result

Deux records génériques sont prêts à l'emploi :

```kite
use std.option
use std.result

make find(xs: [int], x: int) -> Option<int>:
    i = 0
    for v in xs:
        if v == x:
            return option.some(i)
        i.incr()
    return Option<int>()                    // un Option vide signifie « rien »

make digit(c: string) -> Result<int, string>:
    r = Result<int, string>()               // un Result vide à remplir
    if c >= "0" and c <= "9":
        return result.ok(r, to_int(c))
    return result.err(r, f"not a digit: {c}")

make main():
    print(option.unwrap_or(find([4, 5, 6], 9), -1))     // -1
    r = digit("x")
    if result.is_err(r):
        print(result.error(r))                           // not a digit: x
```

> **Remarque :** `Option` et `Result` sont de simples records génériques : vous pouvez lire leurs champs (`o.has`, `o.value`, `r.is_ok`).

## Arguments de type explicites (templates)

Normalement les paramètres de type sont déduits. Vous pouvez aussi les donner vous-même, entre chevrons avant les arguments, comme avec les templates
C++. C'est la façon d'appeler une fonction générique dont le type ne se déduit pas de ses arguments :

```kite
make zero<T>() -> T:
    z: T = 0
    return z

make convert<A, B>(a: A, b: B) -> B:
    return b

make main():
    print(zero<int>())                    // rien pour déduire T : on le dit
    print(first<string>(["x", "y"]))      // comme first(["x", "y"])
    print(convert<int, string>(1, "two"))
```

Les arguments de type s'écrivent avec des noms de types commençant par une majuscule (`Point`, `Box<int>`) ou les types intégrés
(`int`, `float`, `bool`, `string`, `num`, `[int]`, `ptr<int>`), donc `a < b > (c)` reste une comparaison.
Donner plus d'arguments de type que la fonction n'en a est l'erreur `E0127`.
