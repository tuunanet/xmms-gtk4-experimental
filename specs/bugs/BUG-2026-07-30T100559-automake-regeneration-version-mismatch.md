# BUG-2026-07-30T100559: Legacy manifest regeneration requires unavailable Automake

## Problem

Changing the temporary dual-build source-distribution manifest cannot regenerate
its shipped makefile template on the supported development host. The installed
Automake rejects the repository's older generated macro definitions.

Reproduce with:

```sh
automake --force --copy
```

Expected: the manifest source can regenerate its shipped template.

Actual: Automake reports a version mismatch between its 1.18.1 binary and the
1.9.6 macro definitions recorded by the legacy build system.

Security impact: NONE — no security exploit path identified.

## Root Cause Analysis

### Reproduce

The current host provides only Automake 1.18.1. Running the generator exits
nonzero before it writes the makefile template.

### Isolate

The legacy macro bundle explicitly identifies Automake 1.9.6, while the
installed generator requires matching macro definitions. The source manifest
change itself is valid; the failure occurs before manifest content is emitted.

### Hypothesize

1. **The host generator is incompatible with the retained macro bundle.**
   Falsification: compare the generator version and macro-declared version,
   then run the generator.
2. **The manifest edit is syntactically invalid.**
   Falsification: repeat generation before and after reverting the manifest
   addition.

### Verify

The versions differ (1.18.1 versus 1.9.6), and the same version-mismatch error
occurs independently of the manifest addition. The verified root cause is the
unavailable historical Automake toolchain, not the Meson parity verifier.

Risk level: Medium. Hand-editing generated output would hide an unreproducible
legacy build artifact. The approved e05s03 Meson distribution migration is the
appropriate resolution point.

## TDD Fix Plan

1. **RED**: Run Meson source-distribution parity from a clean extracted tree
   after e05s03 makes Meson the distribution producer.
   **GREEN**: Include the parity verifier and its inputs in the Meson
   distribution manifest rather than altering the obsolete Automake template.
   **verify**: e05s03's project-owned Meson distribution verifier.

## Acceptance Criteria

- [ ] e05s03 source archives include the Meson parity verifier and inputs.
- [ ] No hand-edited legacy generated makefile template is introduced.
- [ ] Meson clean extraction, build, test, and staged install pass.

## Resolution

Deferred to e05s03, where Meson owns source distribution and the obsolete
Automake generator is no longer required for this manifest change.
