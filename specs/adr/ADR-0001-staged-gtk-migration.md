# ADR-0001: Stage the UI migration through GTK3

- **Status:** Accepted
- **Date:** 2026-07-29
- **Decision owners:** Maintainers
- **Scope:** GTK migration foundation

## Context

The player, custom skin renderer, dialogs, `libxmms` helpers, `wmxmms`, and many bundled plugins are linked to GTK2. The skinned widget base embeds `GdkPixmap`, `GdkGC`, `GtkWidget`, and legacy GDK event types. GTK4 removes or replaces those drawing and input APIs.

Plugin vtables keep `about` and `configure` callbacks toolkit-neutral at the C signature level, but implementations may open GTK2 dialogs inside the player process. Preserving the vtable layout therefore does not make a GTK2-linked shared object safe to load into a GTK3 or GTK4 process.

The GTK project explicitly recommends converting GTK2 applications to GTK3 before following the GTK3-to-GTK4 guide. Its GTK2-to-GTK3 guide also warns that mixed GTK-major linkage in one process can abort or crash, especially through loadable modules.

## Decision

1. Migrate the production UI in stages: **GTK2 → GTK3 → GTK4**.
2. Keep the current GTK2 application green while migration foundations and behavior baselines are introduced.
3. Use GTK3 as the compatibility bridge for removing deprecated APIs, replacing `GdkPixmap`/`GdkGC` drawing with Cairo-backed rendering, and adopting event controllers where GTK3 provides them.
4. Preserve plugin vtable layouts and exported `get_*plugin_info` entry points unless a later explicitly approved scope authorizes an ABI change.
5. Do **not** require the future GTK3/GTK4 player to load third-party plugins linked to GTK2. Plugins containing UI code must be rebuilt or ported for the player's active GTK major version.
6. Keep plugin loading, playback, playlist, control socket, `libxmms`, configuration paths, executable/package names, and skin-format behavior stable during the foundation increment.
7. Deliver the migration as vertical slices with automated behavior evidence, not as a repository-wide toolkit substitution.

## Consequences

### Positive

- Follows the upstream-supported migration sequence.
- Makes Cairo a usable rendering bridge between GTK generations.
- Allows GTK3 event-controller preparation before the GTK4 switch.
- Separates stable plugin ABI contracts from unsafe mixed-toolkit linkage assumptions.
- Preserves a working player while migration seams are proven incrementally.

### Costs and limitations

- GTK3 is an interim target and adds a migration phase.
- UI-bearing third-party plugins require rebuilds or ports for the active GTK major.
- Plugin discovery will eventually need a reliable compatibility policy and actionable diagnostics before incompatible modules are opened.
- GTK2-only tests for fonts, popup menus, and file selection will need behavior-level replacements rather than mechanical API edits.
- Classic skin parity requires new rendering, geometry, interaction, mask, windowshade, and doublesize coverage.

## Rejected alternatives

### Port directly from GTK2 to GTK4

Rejected because upstream directs GTK2 applications through GTK3, while this codebase relies extensively on drawing and event APIs removed before GTK4.

### Load GTK2 and GTK3/GTK4 plugin UI in the same process

Rejected because GTK documents mixed-major linkage as problematic and potentially crash-prone, including when introduced by loadable modules.

### Break the plugin ABI as part of the toolkit switch

Rejected for the foundation. Toolkit linkage and public vtable shape are separate concerns; no ABI break is presently required.

### Redesign the UI instead of preserving skin behavior

Rejected because toolkit migration must not silently become a product redesign or skin-format break.

## References

- [GTK: Migrating from GTK 2.x to GTK 4](https://docs.gtk.org/gtk4/migrating-2to4.html)
- [GTK: Migrating from GTK 2.x to GTK 3](https://docs.gtk.org/gtk3/migrating-2to3.html)
- [GTK: Migrating from GTK 3.x to GTK 4](https://docs.gtk.org/gtk4/migrating-3to4.html)
- [`xmms/plugin.h`](../../xmms/plugin.h)
- [`docs/architecture/ui-interaction.md`](../../docs/architecture/ui-interaction.md)
- [`docs/architecture/plugin-system.md`](../../docs/architecture/plugin-system.md)
- [`docs/architecture/skins.md`](../../docs/architecture/skins.md)
