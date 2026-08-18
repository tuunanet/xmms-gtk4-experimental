# GNOME C foundations

This policy applies to new GTK migration modules. It does not rewrite historic
XMMS compatibility facades for style.

## GObject types and public headers

New GObject types are **final by default**. A derivable type needs a documented
and approved subclassing contract.

Instance data remains private in the implementation file. A public header
contains the type declaration, a constructor where callers need one, and the
smallest caller methods that express observable behavior. It does not expose
an instance struct or mutable fields.

Properties and signals exist only for **caller-observable state or behavior**.
A type does not add them merely to mirror internal state. An interface exists
only at a **genuine extension boundary** where an independently owned caller or
module must implement it.

## State and ownership

A new module does not introduce **process-global mutable state**. It owns its
state explicitly, receives dependencies through construction or methods, or
uses an existing documented compatibility boundary. GTK operations remain on
the GTK main thread.

## Historic compatibility exemptions

The existing **plugin vtable ABI**, `libxmms` API, **control-socket protocol**,
skin contracts, and configuration keys are compatibility facades. Do not
convert them to GObject interfaces or alter their public layouts without a
separately approved compatibility change.

## Directional dependencies

This contract applies only to the new GTK migration modules. It does not
classify or re-layer the historic `xmms/` tree.

| Layer | Managed paths | May depend on |
| --- | --- | --- |
| UI/rendering adapter | `xmms/ui_gtk3_control.c`, `xmms/ui_gtk3_control.h` | GTK3 and `ui_control.h` |
| Toolkit-neutral UI control | `xmms/ui_control.c`, `xmms/ui_control.h` | GLib only |
| Test consumer | `tests/test-gtk3-play-button-proof.c` | Either managed module; not a production edge |

The UI/rendering adapter may depend only toward the toolkit-neutral UI-control
contract. The control contract does not depend on rendering, storage,
source/plugin, or production UI modules. A future cross-layer dependency needs
a narrow facade or an ADR before it is added.

The managed production modules must not include `plugin.h`, `controlsocket.h`,
`configfile.h`, `skin.h`, or `main.h`. GTK3 and GLib headers are permitted;
`ui_gtk3_control.h` may include the documented `ui_control.h` contract.

### Historical compatibility allowlist

- `xmms/pbutton.c` may include `ui_control.h`: the GTK2 Play button keeps its
  established bridge to the toolkit-neutral state helper.
- `tests/test-gtk3-play-button-proof.c` may include `ui_gtk3_control.h`: it is
  the separately linked proof's test-only consumer.
- Existing plugin, socket, configuration, and skin paths stay unchanged as
  historic compatibility facades and are outside this first source-level scan.

## First application

The isolated GTK3 migration-proof adapter is the first application of this
policy. It remains separately linked from the production GTK2 player and must
continue to translate the existing toolkit-neutral Play-button behavior.
