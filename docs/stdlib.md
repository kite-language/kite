# Standard library (`std.*`)

Modules are plain Kite files in `stdlib/std/`, imported with `use std.<name>`. The resolver looks first in the
project's `src/`, then in the standard library directory: `$KITE_STDLIB`, a `stdlib/` folder next to the project
(repository checkout), `~/.local/share/kite/stdlib`, `/usr/local/share/kite/stdlib`, `/usr/share/kite/stdlib`
(the `.deb`/`.rpm` install the last one).

Kite has no namespaces yet, so every function is prefixed with its module name (`path_join`, `fs_read`, ...).
Only what a program references is compiled in.

| module | what it offers |
|--------|----------------|
| `std.sys` | libc hooks (`system`, `access`, `isatty`, `getpid`), `sys_sh`, `sys_capture`, `sys_quote` -- the base of the others |
| `std.path` | `path_join norm parent file_name extension stem with_extension relative is_absolute` |
| `std.fs` | `fs_exists is_file is_dir read write append mkdir_all remove remove_all copy rename list cwd temp_dir` |
| `std.process` | `process_run` (exit code), `process_output`, `process_env`, `process_which`, `process_pid` |
| `std.term` | colours (only on a terminal): `term_bold red green yellow blue cyan dim`, `term_width`, `term_is_tty` |
| `std.args` | `args_new`, `args_has_flag`, `args_value` (`--k v` / `--k=v`), `args_positional` |
| `std.fmt` | `fmt_pad_left pad_right zero_pad radix hex bin thousands milli bool` |
| `std.time` | `time_now_ns ms secs`, `time_sleep_ms`, `time_format`, `time_elapsed_ms` |
| `std.toml` | flat TOML reader: `toml_get`, `toml_get_int`, `toml_has`, `toml_keys`, `toml_quote` |
| `std.json` | `json_get(text, "a.b.0.c")`, `json_get_raw`, `json_array`, `json_member_raw`, `json_quote` |
| `std.semver` | `semver_parse compare satisfies` (`^1.2`, `~1.2.3`, `>=`, `<`, exact, `*`) |
| `std.sha256` | `sha256_hex(text)` |
| `std.git` | `git_clone` (shallow, by tag), `git_fetch`, `git_rev_parse`, `git_tags`, `git_remote_tags`, ... (nothing that pushes) |
| `std.test` | `test_new`, `test_eq_int/str/bool`, `test_true/false`, `test_finish` |

Tests: `stdlib/tests/std_test` (run by `./build.sh test`, `KITE_STDLIB=stdlib kite run`).

Known limits: strings are byte strings; `std.json`/`std.toml` read values without building a tree (no nested
collections in Kite yet); `bool == bool` is not supported by the code generator (compare with `and`/`not`).
