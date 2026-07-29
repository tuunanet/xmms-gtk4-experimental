# e02s01: Prove GTK4 X11 feasibility and freeze compatibility contracts

<!-- story: e02s01 -->

**type:** feat

**risk:** P0

**context:** infrastructure

**bcps:** 5

## 1. Summary

Prove the non-negotiable GTK4/X11 behaviors on Ubuntu 26.04 and establish executable baselines for every plugin interface and GTK2 migration surface.

## 2. User

XMMS maintainers deciding whether the direct GTK4 migration can proceed safely.

## 3. Problem

GTK4 removes native shaping and movement APIs required by XMMS, while current tests do not detect plugin ABI drift or most classic-window regressions.

## 4. Value

The epic fails early if exact X11 behavior is infeasible and gains objective compatibility gates before broad source changes begin.

## 5. Context

The impact assessment found 121 GTK/GDK source files and a 10/10 risk score. ADR-0001 approves a contained X11 adapter around a deprecated GTK 4.22 XID accessor and Xlib/XShape. GTK4 development headers are not yet installed locally.

## 6. In Scope

- GTK 4.22/X11 compile and runtime feasibility fixture.
- XID, XShape, movement, Cairo drawing, input controller, and backend-failure proof.
- Plugin struct, callback, field-offset, entry-point, and lifecycle baselines.
- Machine-readable GTK2 usage and delivery-path inventories.

## 7. Out of Scope

- Production window migration.
- GTK3 or Wayland support.
- Changing any plugin contract.

## 8. Dependencies

- **[OK] GTK 4.22:** authoritative Ubuntu 26.04 toolkit.
- **[OK] GDK X11 backend:** required GTK backend for the approved product behavior.
- **[OK] Xlib/Xext/XShape:** mature native X11 interfaces already aligned with project constraints.

## 9. Module Purpose

The feasibility fixtures prove native capabilities; compatibility tests own stable snapshots that all later migration stories consume.

## 10. Callers

Developers, CI, every later e02 story, release verification, and external plugin fixture builds.

## 11. Contracts

- No production migration proceeds unless every feasibility check passes.
- ABI snapshots cover all five plugin families.
- Non-X11 execution fails clearly.
- Tests do not load GTK2 and GTK4 in one process.

## 12. Requirements

### ADDED: GTK4 X11 feasibility gate

The project SHALL prove shaping, movement, drawing, and input behavior against GTK 4.22 before production cutover.

### ADDED: Frozen plugin compatibility manifest

The project SHALL detect any plugin layout, callback, entry-point, or injected-field drift.

### ADDED: Migration inventory

The project SHALL track GTK2 source, binary, build, package, workflow, and documentation dependencies through final removal.

## 13. Design

Use retained test fixtures rather than production code for the proof. **Reason for Depth:** native X11 behavior and plugin ABI are release-blocking contracts that cannot be established through source inspection alone.

## 14. Files and Data

- New ABI probe sources and manifests under `tests/`.
- GTK4/X11 feasibility fixture and shell harness.
- GTK migration inventory policy test.
- ADR-0001 and impact/test-plan references.

## 15. Error Handling

Missing GTK4/X11/XShape dependencies, non-X11 backends, unavailable native surfaces, shape failures, and ABI mismatches fail closed with the failed capability named.

## 16. Security

Native handles and X11 calls are process-local but must validate surface state and avoid stale XIDs. The feasibility code uses no untrusted network input.

## 17. Acceptance Criteria

### SC-e02s01-P0-01: Plugin contracts are frozen

```gherkin
Given the current public plugin headers
When the ABI contract suite compiles and inspects every plugin family
Then every expected size, field offset, callback type, and entry point matches
And any representative mutation makes the suite fail
```

### SC-e02s01-P0-02: Required X11 behavior is feasible

```gherkin
Given GTK 4.22 running with the X11 backend under Xvfb
When the feasibility fixture creates a GTK4 window
Then it obtains the native XID
And applies and queries an XShape mask
And moves the window and receives draw, click, motion, and key callbacks
```

### SC-e02s01-P0-03: Unsupported backend fails clearly

```gherkin
Given the active GDK backend is not X11
When the native-window fixture starts
Then it exits non-zero with an actionable X11 requirement
And performs no native window operation
```

## 18. Implementation Steps

1. Add compile-time snapshots for all plugin contracts → verify: `tests/test-plugin-abi.sh "$PWD"`
2. Add the GTK4/X11 feasibility fixture (ref: ADR-0001) → verify: `xvfb-run --auto-servernum tests/test-gtk4-x11-feasibility.sh "$PWD"`
3. Add migration inventory contracts → verify: `tests/test-gtk-migration-contracts.sh "$PWD" --phase baseline`
4. Persist feasibility results and architecture policy → verify: `tests/test-package-recipes.sh "$PWD" && grep -q 'Status: Accepted' specs/adr/ADR-0001-gtk4-x11-native-window-adapter.md`

## 19. Verification Script

1. Install GTK 4.22 and X11/XShape development packages on Ubuntu 26.04.
2. Run the ABI suite and observe all five plugin families pass.
3. Run the feasibility fixture under Xvfb and inspect its capability summary.
4. Run with a non-X11 backend and confirm the expected failure.
5. Confirm no production executable or plugin was changed.

## 20. Risks

- GTK4's XID accessor is deprecated; failure blocks or revises ADR-0001.
- Xvfb cannot prove all window-manager behavior; later recorded UAT remains mandatory.
- ABI snapshots can be architecture-sensitive; supported architectures need explicit manifests.
