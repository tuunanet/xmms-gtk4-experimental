# e06s03: Add changed-file GNOME C formatting preflight

**type:** tooling
**risk:** P1
**depends on:** e05

## Context

The repository currently has no `.clang-format`; `.editorconfig` declares the
historical tab-indented C style. A whole-tree reformat would obscure behavior
changes and violate preservation constraints, but new GTK3/GTK4-facing code
needs a mechanically enforced GNOME-oriented style.

## Requirements

#### ADDED: Path-scoped GNOME C formatting

Add repository-owned clang-format configuration for the approved modern-code
paths: two-space indentation, GNOME brace style, and approximately 80-column
wrapping where practical. Legacy paths remain unchanged unless a separately
approved migration explicitly adopts the new format.

#### ADDED: Changed-file formatting gate

Preflight and CI reject incorrectly formatted changed C/H files within the
modern-code paths. The gate must not rewrite files, download tools, or impose a
whole-tree formatting diff; it must provide actionable system-package guidance
when clang-format is absent.

## Acceptance criteria

- Given an incorrectly formatted changed modern C/H file, when preflight runs,
  then it fails and identifies the file and remediation command.
- Given an unchanged historical C/H file, when formatting preflight runs, then
  it is not reformatted or failed solely for its historical tab style.
- Given no system clang-format binary, when formatting preflight runs, then it
  fails fast without pip, network, or automatic installation.

## Out of scope

Formatting unrelated historical modules, making clang-format rewrite developer
files automatically, or using formatting to mask functional changes.
