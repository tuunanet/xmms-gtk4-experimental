# Threat model: e06 modern GNOME C foundations

**Scope:** e06s01 establishes policy and one new GTK-migration module without
changing the historic plugin ABI, control socket, configuration, skins, or
legacy module behavior.

## Assets and boundaries

- The plugin vtable ABI, `libxmms` API, and control-socket protocol are
  compatibility assets. They remain outside the proposed GObject boundary.
- GTK main-thread affinity and explicit GLib ownership are runtime safety
  boundaries for any newly introduced module.
- Module state is internal. New process-global mutable state is prohibited;
  dependencies must be injected, owned explicitly, or obtained through a
  documented compatibility boundary.

## Risk assessment

| Category | Assessment | Mitigation |
| --- | --- | --- |
| Public API / ABI exposure | Medium compatibility risk; not a security boundary | Keep the new type final, private-instance-data, and header-minimal. Do not alter plugin, socket, skin, or configuration contracts. |
| GObject interface expansion | Low | Add an interface only where third parties genuinely implement a boundary; do not convert the existing plugin vtable. |
| Mutable global state | Low | Require explicit ownership or injection; test for absence of new global mutable state. |
| GTK thread use | Low | Keep GTK operations on the main thread and use focused Xvfb tests. |
| Injection, auth, secrets, network, deserialization | None in approved scope | Do not add these paths. Any such addition requires a new threat review. |

## Security verdict

No attacker-reachable data flow, credential path, authorization boundary, or
external request is planned. No HIGH finding is present. The primary risk is
compatibility regression, controlled by the explicit legacy-ABI exemptions and
regression tests.
