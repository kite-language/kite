# Structures de contrôle

```kite
if score >= 90:
    print("A")
orif score >= 80:          // `orif` signifie « sinon si »
    print("B")
else:
    print("C")
```

```kite
while i < 10:
    i.incr()

until done:                // boucle jusqu'à ce que la condition soit vraie
    step()

for i = 0 to 5:            // 0, 1, 2, 3, 4  (la fin est exclue)
    print(i)

for item in items:         // chaque élément d'une liste
    print(item)

infinit:                   // boucle sans fin, on en sort avec `break`
    if finished():
        break
```

`break` quitte la boucle la plus proche, `continue` passe au tour suivant. Les variables de boucle appartiennent à la fonction.

## try / finally

```kite
make load(path: string) -> string:
    text = ""
    try:
        text = read_file(path)
        return text
    finally:
        print("done reading")        // s'exécute avant que le `return` ne quitte le bloc
```

`finally` s'exécute toujours après le bloc, y compris avant un `return`, un `break` ou un `continue` qui le quitte. Kite n'a pas encore
d'exceptions : un bloc `failed:` est accepté par le parseur mais ne s'exécute jamais (il est réservé au travail de propagation
d'erreurs de la [feuille de route](/project/roadmap/)). Signalez les problèmes avec des valeurs de retour (`std.error`) ou `panic`.

## Arrêter le programme

`exit(code)` termine le processus ; `panic("message")` affiche `panic: message` et sort avec le code 101 ;
`assert(condition, "pourquoi")` déclenche un panic quand la condition est fausse.
