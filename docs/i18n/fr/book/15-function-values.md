# Valeurs de fonction et lambdas

Une fonction peut être rangée dans une variable, passée à une autre fonction et retournée comme n'importe quelle valeur. Son type s'écrit
`fn(types des paramètres) -> type du résultat`.

```kite
make double(x: int) -> int:
    return x * 2

make apply(f: fn(int) -> int, v: int) -> int:
    return f(v)                      // appeler une variable qui contient une fonction

make main():
    f = double                       // un nom de fonction est une valeur
    print(f(21))                     // 42
    print(apply(double, 4))          // 8
```

Rien n'est retourné ? Omettez la flèche : `fn(string)` est une fonction qui prend une chaîne et ne retourne rien.

## Lambdas

Une **lambda** est une petite fonction écrite là où on s'en sert : `|paramètres| expression`.

```kite
print(apply(|x| x + 100, 5))                          // 105
g: fn(int, int) -> int = |a, b| a * b
k = |x: float| x / 2.0                                // écrivez le type quand rien ne l'indique
say: fn(string) = |s| print(s)
z = || 42                                             // sans paramètre
```

Les types des paramètres viennent du type de fonction **attendu** (`apply` ci-dessus attend `fn(int) -> int`) ; une lambda affectée à une nouvelle
variable n'a pas de type attendu, annotez donc ses paramètres (`|x: float|`). Le type du résultat est celui de l'expression.

## Capturer des variables (fermetures)

Une lambda peut utiliser les variables de la fonction qui l'entoure. Elle garde une **copie** de leurs valeurs au moment où elle est créée :

```kite
make main():
    base = 1000
    add_base = |x: int| x + base          // capture base
    base = 5                              // la fermeture voit toujours 1000
    print(add_base(7))                    // 1007
    scale = 2.5
    half = |x: float| x * scale
    ys = iter.map([1, 2, 3], |n| n * 10 + base)    // les captures marchent aussi avec iter.map
```

Les variables capturées peuvent être `int`, `float`, `bool`, `string`, des pointeurs, des enums et d'autres fonctions (une fermeture peut en capturer une autre).

## map, filter, reduce

La pièce `std.iter` travaille sur les listes avec des valeurs de fonction (elle est générique, les types des éléments sont déduits) :

```kite
use std.iter

make main():
    nums = [1, 2, 3, 4]
    squares = iter.map(nums, |x| x * x)               // [1, 4, 9, 16]
    evens = iter.filter(nums, |x| x % 2 == 0)         // [2, 4]
    print(iter.reduce(nums, 0, |acc, x| acc + x))     // 10
    print(iter.any(nums, |x| x > 3))                  // true
    iter.each(iter.range(3), |i| print(i * 10))
```

## Limites

- Une lambda capture **une copie** des variables qu'elle utilise, prise à la création de la lambda (voir plus haut) ; les listes, records et `num` ne peuvent pas encore être capturés (`E0139`).
  Le bloc qui contient les valeurs capturées n'est pas libéré : ne créez pas de fermetures dans une très longue boucle.
- Les valeurs de fonction prennent et retournent `int`, `float`, `bool`, `string`, des pointeurs et des enums (pas encore de listes, records ni `num`) : erreur `E0131`.
- Une fonction doit avoir un `-> Type` explicite pour servir de valeur (`E0135`) ; un mauvais nombre ou type d'arguments à l'appel est `E0136` / `E0137`.
