# e06s01: Define modern GObject and public-API boundaries

**type:** architecture
**risk:** P1
**context:** GTK migration foundation
**depends on:** e05
**scenario:** SC-e06s01-P1-01

## 1. Goal

Give future GTK migration modules one narrow, observable GNOME C pattern while
leaving all historic XMMS compatibility facades unchanged.

## 2. User value

Maintainers can add a GTK-facing type without exposing mutable implementation
details, inventing a false extension point, or expanding the production GTK2
process.

## 3. Scope

The isolated GTK3 migration-proof adapter (`xmms/ui_gtk3_control.[ch]`) is the
only implementation target. It is compiled only into the GTK3 proof test.

## 4. Zoom-out check

- **Purpose:** translate GTK3 draw and pointer events for the toolkit-neutral
  Play-button control boundary.
- **Caller:** `tests/test-gtk3-play-button-proof.c`; `tests/meson.build`
  compiles it only into the separately linked proof executable.
- **Contracts:** preserve rendering and single-activation behavior, retain the
  GTK2/GTK3 separate-process boundary, and do not change the generic
  `ui_control`, plugin, socket, configuration, or skin interfaces.

## 5. Requirements

#### ADDED: GObject-facing migration-module policy

New GObject types are final unless an approved subclassing contract says
otherwise. Their instance data is private to the implementation file, and
public headers expose only the type declaration and caller-observable methods.
Properties and signals require caller-observable state or behavior. Interfaces
require a genuine third-party implementation boundary.

#### ADDED: Compatibility-boundary policy

The historic plugin vtable ABI, `libxmms` API, control-socket protocol, skins,
and configuration remain compatibility facades. This story does not convert
them to GObject interfaces.

#### ADDED: Mutable-state policy

New migration modules use owned or injected state rather than process-global
mutable state.

## 6. Design decision

Introduce a final `XmmsUiGtk3Control` GObject that owns the proof adapter's
button state privately. Its minimal API accepts GTK events and draws the
existing toolkit-neutral commands; activation remains the existing observable
result value.

**Reason for Depth:** the object centralizes the proof adapter's mutable button
state behind one ownership boundary, so later GTK migration callers cannot
mutate its internals or rely on a speculative extension API.

## 7. Dependencies

- GLib/GObject **[OK]** — already required by the project; the installed
  `G_DECLARE_FINAL_TYPE` contract declares types not intended for subclassing.
- GTK3 **[OK]** — already optional for the separately linked proof target; no
  new dependency is proposed.

## 8. Implementation steps

1. Add the documented policy and a focused shell contract that rejects missing
   final-type, private-data, minimal-header, property/signal, interface,
   mutable-state, and legacy-facade rules → verify:
   `tests/test-gnome-c-foundations.sh "$PWD" --policy`
2. Convert only the GTK3 proof adapter to a final, private-state
   `XmmsUiGtk3Control`, update its proof consumer, and register both focused
   contracts in the `gobject-boundaries` Meson suite → verify:
   `meson setup build-meson --wrap-mode=nodownload && xvfb-run --auto-servernum meson test -C build-meson --suite gobject-boundaries`
3. Run the unchanged project gate after the focused suite is green → verify:
   `tools/preflight.sh --strict`

## 9. Test strategy

The policy contract tests the documented boundary rules. The
`gobject-boundaries` suite then tests the adapter's public source shape and
observable GTK3 rendering and activation through its new public methods.
The existing negative release-state fixture and all strict-preflight checks
remain unchanged.

## 10. Manual verification

1. Configure the Meson build with `meson setup build-meson --wrap-mode=nodownload`.
2. Run `xvfb-run --auto-servernum meson test -C build-meson --suite gobject-boundaries`.
3. Confirm the suite reports the policy contract and GTK3 proof as passing.
4. Confirm no production player, plugin, socket, or configuration process was
   started by the proof.

## 11. Out of scope

- Production GTK3/GTK4 port.
- Bulk conversion of GTK2-era structs.
- Plugin, `libxmms`, socket, skin, or configuration API changes.
- New interfaces, properties, signals, global mutable state, or dependencies.

## 12. Risks and controls

- **Compatibility:** retain the original proof scenarios and GTK-major process
  separation.
- **API overreach:** expose only constructor, event, and draw methods.
- **Threading:** keep all GTK use in the Xvfb test's main thread.

## 13. Acceptance criteria

- A final GObject declaration has no public instance fields.
- The adapter owns its button state privately and exposes no unnecessary
  property, signal, or interface.
- Existing GTK3 rendering and single-activation behavior pass through the new
  public API.
- Strict preflight passes without changing historic compatibility surfaces.
