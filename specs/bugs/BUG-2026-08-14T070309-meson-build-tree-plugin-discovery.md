# BUG-2026-08-14T070309: Meson build-tree plugins are not discovered

## Problem

An uninstalled player built with Meson does not load the plugins built beside
it. The documented build-tree executable starts with no input, output, effect,
general, or visualization modules, even though Meson produced the shared
objects.

Expected behavior: an uninstalled Meson executable discovers its adjacent
Meson plugin targets and selects the configured output plugin.

Reproduction: configure and compile a no-download Meson build, then initialize
the plugin loader against that build tree. The built shared modules exist, but
the loader reports zero plugins.

Security impact: **LOW**. No security exploit path is identified. The defect
prevents local development/runtime behavior rather than accepting untrusted
input.

## Root Cause Analysis

### Reproduce

An isolated loader harness against a current Meson build found real plugin
shared objects in the build tree and loaded zero plugin vtables.

### Isolate

The uninstalled discovery path searches a legacy nested output layout only.
The separate output-plugin preference helper uses the same legacy-only layout.
Meson emits modules directly in each plugin target directory and the player
build records a relative build root, so the documented invocation is not
anchored to its build tree.

### Hypotheses

1. **Confirmed:** legacy-only discovery misses direct Meson module outputs.
   Falsification: make the loader scan direct module directories and assert it
   loads actual Meson targets.
2. **Confirmed:** legacy-only ALSA lookup misses the direct Meson output.
   Falsification: query the helper against actual Meson output and assert its
   returned path exists.
3. **Confirmed:** a relative build root makes discovery depend on the process
   working directory. Falsification: compile the player with its absolute
   Meson build root and exercise discovery from the configured build tree.

### Verify

The module inventory contained Meson-built input, output, effect, general, and
visualization shared objects while the loader returned zero entries. This
confirms a build-layout/discovery mismatch rather than a missing module or
linker dependency.

Risk level: **High** for the Meson cutover because the documented uninstalled
player cannot load audio plugins.

## TDD Fix Plan

1. **RED:** Add an integration test that initializes plugin discovery against
   actual Meson input and output targets and expects the module lists and
   selected output to be populated.
   **GREEN:** Scan direct build-target plugin directories before retaining the
   legacy fixture layout fallback.
   **Verify:** Run the focused plugin discovery test.

2. **RED:** Add an integration test that resolves the ALSA output module from
   actual Meson output.
   **GREEN:** Resolve the direct Meson path before the retained fixture
   fallback.
   **Verify:** Run the focused output helper test.

3. **RED:** Assert the production Meson build records an absolute build-plugin
   root and that the build-tree executable uses it.
   **GREEN:** Supply Meson's build root through the compile definition.
   **Verify:** Reconfigure, compile, and run the plugin integration tests.

4. **RED:** Extend final-cutover fixtures to reject residual ignored or
   symlinked legacy support paths.
   **GREEN:** Remove broad legacy ignores and scan both regular files and
   symlinked registration/support paths.
   **Verify:** Run the forbidden-artifact regression in Git and extracted
   archives.

**REFACTOR:** Keep direct Meson lookup and legacy fixture fallback in small,
named helpers; update the architecture document to describe direct build-tree
module discovery.

## Acceptance Criteria

- [ ] Actual Meson build-tree input and output modules are loaded.
- [ ] ALSA discovery resolves the actual Meson output module.
- [ ] The documented build-tree executable has an absolute Meson plugin root.
- [ ] Final-cutover artifact checks reject legacy support symlinks and do not
      mask `.libs` paths.
- [ ] All focused and full regression tests pass.

## Resolution

**Status:** fixed

- Meson now records its absolute build root for uninstalled plugin discovery.
- Plugin enumeration scans direct Meson target directories before the retained
  `.libs` fixture fallback; ALSA lookup follows the same order.
- Integration tests load actual Meson `mpg123` and ALSA modules, while fixture
  tests retain legacy-layout coverage.
- `tools/preflight.sh --strict`, clean distribution, release artifacts, and
  clean Git/extracted-source verification passed with 33/33 tests.

The actual player startup from the documented build-tree path also produced no
plugin `dlopen` diagnostics.
