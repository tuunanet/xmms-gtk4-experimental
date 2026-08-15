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

## First application

The isolated GTK3 migration-proof adapter is the first application of this
policy. It remains separately linked from the production GTK2 player and must
continue to translate the existing toolkit-neutral Play-button behavior.
