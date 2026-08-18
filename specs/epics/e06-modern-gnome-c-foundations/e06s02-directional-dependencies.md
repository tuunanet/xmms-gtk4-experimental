# e06s02: Enforce directional subsystem dependencies

**type:** architecture
**risk:** P1
**depends on:** e05, e06s01

## Context

The staged UI migration needs boundaries that prevent rendering, storage, and
source code from acquiring reverse dependencies through convenience globals or
public-header leakage.

## Requirements

#### ADDED: Dependency-direction contract

Document and validate the allowed directions among UI, domain, storage,
rendering, and source/plugin dependencies. New modules must depend only toward
stable lower-level contracts; dependencies that cross a layer require an
explicit facade or ADR.

#### ADDED: Boundary verification

Add a focused, source-level verification that rejects new prohibited dependency
edges while allowing documented historical compatibility paths unchanged.

## Approved first-enforcement scope

The checker applies only to new GTK migration modules. It does not classify or
re-layer the historic `xmms/` tree.

| Layer | Managed paths | May depend on |
| --- | --- | --- |
| UI/rendering adapter | `xmms/ui_gtk3_control.c`, `xmms/ui_gtk3_control.h` | GTK3 and `ui_control.h` |
| Toolkit-neutral UI control | `xmms/ui_control.c`, `xmms/ui_control.h` | GLib only |
| Test consumer | `tests/test-gtk3-play-button-proof.c` | Either managed module; excluded from production-edge checks |

The adapter may depend only toward the toolkit-neutral UI-control contract.
The control contract may not depend on a renderer, storage, source/plugin, or
production UI module. A future cross-layer dependency requires a narrow facade
or an ADR before it is added.

The source-level checker rejects `plugin.h`, `controlsocket.h`,
`configfile.h`, `skin.h`, and `main.h` in the two managed production modules.
It permits the GTK3 and GLib external headers and the adapter's documented
`ui_control.h` dependency.

### Historical compatibility allowlist

| Edge | Reason | Checker treatment |
| --- | --- | --- |
| `xmms/pbutton.c` → `ui_control.h` | The GTK2 Play button reuses the existing toolkit-neutral state helper. | Outside the managed set; retained unchanged. |
| `tests/test-gtk3-play-button-proof.c` → `ui_gtk3_control.h` | The separately linked proof is its sole test consumer. | Test-only consumer; excluded from production-edge checks. |
| Existing plugin, socket, configuration, and skin paths | Preserved compatibility facades and historic APIs. | Outside the managed set; no broad legacy scan. |

The contract is registered in Meson's `gobject-boundaries` suite. Since the
preflight wrapper accepts only `--strict`, `tools/preflight.sh --strict` is the
full-preflight verification; the focused shell-contract mode remains the
fast developer check.

## Acceptance criteria

- Given a new UI module, when it needs player state, then it depends on a
  domain-facing contract rather than storage or renderer internals.
- Given a rendering or storage module, when it is compiled, then it does not
  acquire a reverse dependency on a UI module.
- Given a documented historical compatibility edge, when boundary verification
  runs, then it is retained only as an explicit allowlist entry.

## Out of scope

Re-layering every existing source file, changing plugin loading behavior, or
removing established global state without a behavior-preserving migration plan.
