# BUG-2026-07-30T143100: Meson gettext header collision

## Problem

A Meson build can fail after the retained Autotools configure path has generated
a translation-enabled source header. The Meson-generated header instead leaves
gettext disabled and defines stub macros. When a translation-aware module later
includes the system gettext declarations, those macros corrupt the declarations.

Expected behavior: Meson configures the same enabled gettext interface used by
the retained build, regardless of whether a legacy configure output exists.

Security impact: NONE. No security exploit path identified.

## Root Cause Analysis

**Reproduce:** Configure the retained build, then reconfigure and fully compile
Meson. The ALSA plugin compilation fails in the system gettext declarations.

**Isolate:** A clean Meson build without the legacy source header succeeds. The
failure appears only when source code includes both the Meson-generated i18n
header and the translation-enabled retained-build header.

**Hypotheses:**

1. Meson copies an Autoconf template without defining gettext support.
2. A compiler include-path ordering problem chooses the wrong header.

**Verify:** The Meson header contains the unresolved disabled gettext marker and
therefore declares gettext as a stub macro. The retained-build header enables
gettext and includes the system declarations. Enabling gettext in Meson's
configured header eliminates the incompatible macro declaration; include-path
order is only the condition that exposes the mismatch.

Risk level: Medium. It blocks a supported clean build and disables intended
runtime translations when it does not block compilation.

## TDD Fix Plan

1. **RED:** Add a Meson configuration contract that requires its generated i18n
   header to enable gettext and compile a translation-aware module after a
   retained-build configure output exists.
   **GREEN:** Configure Meson's i18n header with gettext enabled rather than
   copying the unresolved Autoconf template.
   **verify:** `meson setup --reconfigure build-meson --wrap-mode=nodownload && meson compile -C build-meson`

2. **RED:** Run the full Meson test and staged-install gates with the retained
   configured source state present.
   **GREEN:** Keep all existing build, test, install, and source-distribution
   contracts passing.
   **verify:** `xvfb-run --auto-servernum meson test -C build-meson --print-errorlogs && tests/verify-meson-install-layout.sh build-meson`

**REFACTOR:** Keep the i18n configuration local to Meson setup and preserve the
existing public gettext, locale, and plugin contracts.

## Acceptance Criteria

- [ ] Meson's generated i18n header enables gettext.
- [ ] A fully configured retained build does not prevent Meson compilation.
- [ ] Meson tests and staged install pass.
- [ ] The clean source-distribution verifier passes.

## Resolution

<!-- filled in by validate-fix -->
