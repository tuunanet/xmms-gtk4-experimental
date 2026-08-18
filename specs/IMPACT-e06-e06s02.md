# Impact assessment: e06s02 directional dependencies

**Date:** 2026-08-15
**Scope:** Enforce a source-level dependency contract only for the two isolated
GTK3 migration-proof modules.

## Affected paths

| Path | Change | Compatibility impact |
| --- | --- | --- |
| `docs/architecture/gnome-c-foundations.md` | Add the directional-dependency policy and legacy exemptions. | Documentation only. |
| `tests/test-gnome-c-foundations.sh` | Add deterministic policy and include-edge checks. | Test-only. |
| `tests/meson.build` | Register the focused contract in `gobject-boundaries`. | Test registration only. |
| `xmms/ui_gtk3_control.[ch]` | Checked as the UI/rendering adapter. | No source behavior change planned. |
| `xmms/ui_control.[ch]` | Checked as the toolkit-neutral control boundary. | No source behavior change planned. |

## Protected, unchanged boundaries

The checker deliberately excludes the legacy `xmms/` tree outside the two
managed modules. In particular, it preserves the GTK2 `pbutton.c` bridge,
plugin ABI, `libxmms`, control socket, configuration, skin, source-distribution,
packaging, and separate GTK-major process boundary.

## Risks and mitigation

- **False positives:** fixed managed-file and forbidden-header lists prevent
  historical source from entering scope.
- **False negatives:** the policy names the managed modules and forbidden
  cross-layer includes; the contract asserts both the policy and source edges.
- **Build integration:** Meson runs the focused suite during strict preflight;
  no unsupported preflight option is added.

## Verification

1. `tests/test-gnome-c-foundations.sh "$PWD" --dependency-contract`
2. `xvfb-run --auto-servernum meson test -C build-meson --suite gobject-boundaries`
3. `tools/preflight.sh --strict`
