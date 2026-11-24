# Compilation conditionnelle

Certains codes n'ont de sens que sur un système d'exploitation. Un bloc **`when`** garde son code pour les cibles que vous nommez et
**le retire du programme** pour toutes les autres : il n'est ni compilé, ni vérifié, ni présent dans le binaire.

```kite
when windows:
    make open_url(url: string):
        run(f"start {url}")
else:
    make open_url(url: string):
        run(f"xdg-open {url}")

make main():
    open_url("https://kite-lang.pages.dev")
    when linux:
        print("running on Linux")
```

`when` fonctionne sur les éléments de premier niveau (fonctions, types, constantes, lignes `use`) et sur les instructions à l'intérieur des
fonctions. Un bloc `else:` facultatif juste après contient le code des autres cibles. Les blocs peuvent être imbriqués.

## Conditions

| condition | vraie quand la cible est |
|-----------|--------------------------|
| `windows`, `linux`, `macos` | ce système d'exploitation |
| `unix` | Linux ou macOS |
| `bare` | freestanding (sans OS), par ex. `x86_64-unknown-none` |
| `x86_64`, `aarch64`, `riscv64` | cette architecture de processeur |
| `os == "linux"`, `arch == "aarch64"` | la même chose, écrite comme une comparaison (`!=` marche aussi) |

Combinez-les avec `not`, `and`, `or` et des parenthèses : `when unix and not macos:`, `when (linux or macos) and arch == "aarch64":`.

La cible est celle donnée à `kite build --target ...` (ou `[build] target` dans `kite.toml`) ; sans cible, c'est la machine sur laquelle vous êtes.

> **Remarque :** `when` n'est un mot-clé qu'en début de ligne, suivi d'une condition et de `:`, donc une variable nommée `when` fonctionne toujours.
