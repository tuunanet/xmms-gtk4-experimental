# Impact Assessment: e07 GTK3 main-window slice

## Target

The proposed e07 tracer extends `xmms/ui_gtk3_control.[ch]`, the GTK3-only
Meson test target, and the associated linkage/source-distribution contracts.

## Dependents (2 direct code callers; broader build fan-out)

- `tests/test-gtk3-play-button-proof.c`: existing GTK3 rendering and activation proof calls the adapter constructor, draw function, and event handler.
- `tests/meson.build`: builds and registers the GTK3 proof target.
- `tests/verify-meson-output-contract.sh`: verifies the GTK3 proof binary and GTK-major linkage.
- `tests/test-meson-test-suite-contract.sh`: verifies Meson test registration.
- `tools/check-gnome-c-format.sh` and `tests/test-gnome-c-foundations.sh`: enforce formatting and GObject policy for the adapter.
- `tools/verify-build-parity.sh`: records the isolated GTK3 proof in the output baseline.

## Affected Stories

- `e03s03`: existing Play-button proof must remain green and GTK2-free.
- `e06s01`: final-type/private-state policy continues to apply to new GTK3 code.
- `e06s02`: directional dependency checks continue to apply to the tracer.
- `e06s03`: changed-file GNOME C formatting covers any modified adapter files.
- `e07s01`, `e07s02`, `e07s03`: proposed main-window shell, transport, and delivery slices.

## Test Coverage

- `tests/test-gtk3-play-button-proof.c`: covers existing draw and exactly-once Play activation behavior.
- Meson output and test-suite contract scripts: cover binary presence, GTK-major linkage, and registration.
- GNOME C foundation scripts: cover policy, dependency direction, and formatter scope.
- Gap: e07 geometry, transport isolation, and source-distribution behavior require new focused tests before implementation is marked passing.

## Risk: High

The adapter has few direct callers but is a shared migration boundary with binary
linkage and source-distribution checks. A careless extension could regress the
e03 proof or accidentally couple the GTK3 process to production GTK2 code.

## Recommended action

Proceed only with focused additive fixtures and target-specific tests. Preserve
the existing e03 proof as a regression gate, inspect built dependencies, and
run strict preflight before any integration decision.
