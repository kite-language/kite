# Community pieces

Third-party pieces live here: `pieces/community/<name>/<version>/{kite.toml, src/lib.ki, ...}`.
Add yours with `kite init --lib`, `kite verify`, `kite publish` and a pull request (see docs/pieces.md).
Community pieces are declared in `[dependencies]` and imported by name (`use <name>`); the default pieces
(`pieces/std/`) need no declaration and are imported as `use std.<name>`. A community piece cannot reuse the
name of a default piece.
