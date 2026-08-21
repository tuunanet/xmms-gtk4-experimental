# Impact assessment: e06s03 GNOME C formatting gate

**Scope:** Add a non-mutating formatter check only for the isolated GTK3
adapter, using a repository-owned style config and the system clang-format.

## Affected paths

- `tools/clang-format-gnome.yml`: config used only by the new checker.
- `tools/check-gnome-c-format.sh`: fixed-path dry-run wrapper.
- `tests/test-gnome-c-foundations.sh` and `tests/meson.build`: focused policy
  and Meson registration tests.
- `xmms/ui_gtk3_control.[ch]`: only formatted production files.

## Protected boundaries

The full legacy GTK2 tree, plugin ABI, socket, configuration, skins, packaging,
and runtime behavior are excluded. The checker never writes files, fetches a
tool, or evaluates source content.

## Risk

Low. A missing system tool fails with package guidance; a style mismatch fails
before packaging. Strict preflight covers the registered test.
