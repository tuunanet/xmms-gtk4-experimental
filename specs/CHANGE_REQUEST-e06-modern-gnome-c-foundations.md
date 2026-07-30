# Change request: post-Meson modern GNOME C foundations

**Status:** Accepted
**Placement:** After e05 completes; `e06.depends_on = e05`

## Request

Adopt modern GNOME C practices for future GTK3/GTK4-facing development:

- final GObject types by default;
- interfaces only at genuine extension boundaries;
- private instance fields and minimal public headers;
- properties/signals only for needed observation;
- no new global mutable state;
- directional UI, domain, storage, rendering, and source/plugin dependencies;
- GNOME two-space formatting near 80 columns; and
- repository-owned clang-format checks that fail Preflight for incorrectly
  formatted changed modern C/H files.

## Placement rationale

e05 must finish first because it establishes the canonical Meson preflight that
e06 extends. Mixing a new formatter or dependency gate into the temporary
dual-build phase would obscure Meson parity failures.

## WSJF

`(business value 5 + time criticality 3 + risk reduction 8) / job size 8 = 2.0`.

The work enables maintainable future GTK migration code and reduces architectural
drift, but has no external deadline and must not interrupt the P0 build-system
cutover.

## Compatibility guardrail

The epic governs new and materially changed modern-code paths. It does not
silently reformat or retrofit historical GTK2 modules, replace plugin vtables,
or change public socket, configuration, skin, executable, or Debian contracts.
