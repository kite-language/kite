# Erreurs : Result, Option et `?`

Kite n'a pas d'exceptions. Une fonction qui peut échouer retourne un **`Result`**, et une fonction qui peut n'avoir rien à retourner donne un
**`Option`**. Ce sont deux simples records génériques des pièces par défaut `std.result` et `std.option`.

```kite
use std.result

make digit(c: string) -> Result<int, string>:
    r = Result<int, string>()                  // un Result vide à remplir
    if c >= "0" and c <= "9":
        return result.ok(r, to_int(c))
    return result.err(r, f"not a digit: {c}")

make main():
    r = digit("x")
    if result.is_err(r):
        print(result.error(r))                 // not a digit: x
    print(result.unwrap_or(digit("7"), 0))     // 7
```

## L'opérateur `?`

Appeler plusieurs fonctions qui peuvent échouer demanderait un `if` après chaque appel. Mettez plutôt **`?`** après l'appel : quand l'appel échoue, la
fonction courante retourne tout de suite cet échec ; quand il réussit, vous obtenez la valeur.

```kite
make two_digits(a: string, b: string) -> Result<int, string>:
    x = digit(a)?                              // sur une erreur : la retourner depuis two_digits
    y = digit(b)?
    r = Result<int, string>()
    return result.ok(r, x * 10 + y)

make sum3(a: string, b: string, c: string) -> Result<int, string>:
    r = Result<int, string>()
    return result.ok(r, digit(a)? + digit(b)? + digit(c)?)   // plusieurs `?` dans une expression, de gauche à droite
```

Cela marche de la même façon avec `Option` : `i = find(xs, 6)?` retourne un `Option` vide depuis la fonction courante quand rien n'a été trouvé.

Règles :

- La fonction qui utilise `?` doit elle-même retourner un `Result<T, E>` (avec le même type d'erreur `E`) ou un `Option<T>` : sinon erreur `E0144`.
- `?` peut apparaître dans une affectation, une instruction d'appel, un `return` ou une condition de `if`. Il ne peut pas être utilisé dans une condition de boucle, à droite de `and` / `or`
  (il pourrait ne pas s'exécuter), ni dans une lambda (`E0141`, `E0142`) ; ailleurs c'est l'erreur `E0143`.
- Ce n'est qu'un raccourci pour un `if` : vous pouvez toujours consulter `r.is_ok`, `r.value` et `r.error` vous-même.
