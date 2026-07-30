# e06s01: Define modern GObject and public-API boundaries

**type:** architecture
**risk:** P1
**depends on:** e05

## Context

Future GTK3/GTK4-facing modules need a consistent, maintainable GNOME C shape
without changing XMMS's historic plugin ABI, socket API, skins, configuration,
or legacy modules merely for style.

## Requirements

#### ADDED: New GObject-facing module policy

New GObject types are final by default. A type may be derivable only when an
approved subclassing contract exists. Instance data remains private in the
implementation file, public headers expose only the minimal type and caller
methods, and properties/signals exist only for caller-observable state or
behavior.

#### ADDED: Extension-boundary policy

A GObject interface is introduced only at a genuine extension boundary. The
existing plugin vtable ABI remains a compatibility facade and is not converted
to a GObject interface without separately approved ABI work.

#### ADDED: Mutable-state policy

New modules do not introduce process-global mutable state. Dependencies are
injected, owned explicitly, or obtained through an existing documented
compatibility boundary.

## Acceptance criteria

- Given a new non-subclassable GObject type, when its API is declared, then it
  is final and its instance fields are private.
- Given a proposed property, signal, or interface, when callers cannot observe
  or implement the stated boundary, then it is not exposed.
- Given a legacy plugin or socket compatibility surface, when e06 is completed,
  then its ABI and protocol remain unchanged.

## Out of scope

Bulk conversion of GTK2-era structs to GObject types, plugin ABI replacement,
and unrelated historical-header cleanup.
