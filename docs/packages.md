# Package system (design, planned for 0.5.0)

Status: **design only**. Nothing here is implemented yet; the compiler first has to finish its bootstrap (0.4.0).

## Principles
- No server. A package is a Git repository containing `kite.toml` and `src/lib.ki`.
- A release is a tag `vX.Y.Z`.
- A **registry index** is a Git repository (`kite-language/registry`) with one JSON-lines file per package.
  Publishing is a pull request validated by CI.

## Index entry (one line per version)
| field | meaning |
|-------|---------|
| `vers` | version |
| `repo` | Git URL of the package |
| `tag` | release tag |
| `rev` | 40-hex commit the tag must point to |
| `cksum` | sha256 of the source tree |
| `deps` | dependencies |
| `kite` | compatible compiler versions |
| `yanked` | withdrawn release (still resolvable from a lock file, never chosen for new ones) |

## Client side
- The CLI clones the index to `~/.kite/registry` and package sources to `~/.kite/cache`
  (shallow `git clone --branch <tag>`), then verifies `rev` and `cksum`.
- `kite.lock` pins `name / version / repo / rev / cksum` for every dependency.
- Dependencies in `kite.toml`: `"1.2"`, ranges, `{ git = "...", tag = "..." }`, `{ path = "..." }`, and
  `[dev-dependencies]`.
- Module loading receives one search root per dependency.

## Commands
`add remove update fetch search info tree audit publish yank`.
`publish` and `yank` only prepare the files and print the `git` / `gh` commands to run; they never write to Git or
GitHub themselves.

## Security
Pinned commits, checksums, yanking, and `kite audit` (reports yanked or known-bad versions in the lock file).
