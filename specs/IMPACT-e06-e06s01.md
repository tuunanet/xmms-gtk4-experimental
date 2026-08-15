# Impact: e06s01 GObject and public-API boundaries

## Target

The isolated GTK3 migration-proof adapter in `xmms/ui_gtk3_control.[ch]` and
its Meson-linked GTK3 proof test. The work adds a final, private-state GObject
boundary only to this non-production migration module.

## Dependents (3)

- `tests/test-gtk3-play-button-proof.c`: the sole API consumer; proves drawing
  and activation behavior under GTK3.
- `tests/meson.build`: compiles the adapter only into the separately linked
  GTK3 proof executable.
- e03s03: owns the historical GTK3 proof behavior and must retain its GTK2
  separation contract.

No production executable, plugin, socket, configuration, skin, or installed
public header depends on this adapter.

## Affected Stories

- **e06s01:** defines and proves the final-type/private-state policy.
- **e03s03:** regression coverage must retain the existing GTK3 proof's
  rendering, activation, and GTK2-linkage guarantees.

## Test Coverage

- `tests/test-gtk3-play-button-proof.c` covers render and single-activation
  behavior through the adapter's observable API.
- `tests/test-gnome-c-foundations.sh` will cover the documented final-type,
  private-data, minimal-header, no-property/signal, no-interface, and
  legacy-ABI-exemption policy.
- `tests/meson.build` will assign the GTK3 proof to the
  `gobject-boundaries` suite for the story's focused command.

## Risk: Low (score 4/10)

The target has one runtime consumer and is compiled only into an isolated test
executable. Its two dependencies are GTK3 and the existing toolkit-neutral
control boundary. The historical GTK3 proof has churn, so retain all current
behavior tests and the separate-process constraint.

## Recommended action

Proceed without a grill-me session. Use TDD to add the policy contract first,
then encapsulate the proof adapter's button state in a final GObject type
without changing the toolkit-neutral control API or any historic compatibility
surface.
