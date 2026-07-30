# ADR-0002: Replace the build toolchain with Meson through verified parity

- **Status:** Accepted
- **Date:** 2026-07-30
- **Decision owners:** Maintainers
- **Scope:** Build, test, package, release, and agent tooling

## Context

XMMS currently relies on Autotools, libtool, tracked generated `configure` and
`Makefile.in` files, Make targets, and Debian/release helpers that call them.
The legacy stack is difficult to regenerate and distributes build knowledge
across 33 source manifests and 34 generated artifacts.

The project needs a maintained build system without changing runtime
compatibility contracts. The replacement must also provide a reproducible,
agent-friendly preflight and preserve source distribution, Debian packages, and
manual draft-release safeguards.

## Decision

1. Make Meson the sole final build authority.
2. Keep Autotools only during a temporary parity phase; it remains the sole
   official package/release producer until Meson passes approved parity gates.
3. Require Meson to use system/pkg-config dependencies only. WrapDB,
   subprojects, pip bootstrap, and implicit downloads are prohibited.
4. Retain Debian metadata, `dpkg-buildpackage`, package names, package targets,
   checksum validation, and draft-only release policy while replacing their
   internal build commands.
5. Replace `make distcheck` with a project-owned Meson distribution verifier
   that performs clean extraction, setup, compile, test, and staged install.
6. Provide one versioned `tools/preflight.sh` entry point for agents,
   contributors, and CI. It fails fast with actionable system-package guidance
   when Meson or Ninja is unavailable.
7. Remove all Autotools, libtool, `configure`, and Makefile source/generated
   artifacts only after Meson build, test, install, package, release, and
   distribution parity is evidenced.

## Consequences

- Meson migration is a sequence of independently verified slices, not a bulk
  file conversion.
- Current GTK2 production and separate GTK3 proof behavior remain build
  contracts; no GTK4 production-port work is implied.
- The oldest package target establishes the tool floor: Ubuntu Noble provides
  Meson 1.3.2, so the project requires Meson >= 1.3.2. Meson declares Ninja >=
  1.6 for that package; the project adopts the same minimum until a later
  Meson feature requires more.
- Build/release documentation and static contracts must migrate with commands,
  rather than retaining unsupported legacy examples.

## Rejected alternatives

### Preserve Autotools permanently

Rejected because the project explicitly requires full Meson replacement and a
single authoritative build contract.

### Replace all build files in one cutover

Rejected because it would hide changes to optional features, install layout,
plugins, gettext, source archives, packages, and release artifacts until too
late to compare against a working baseline.

### Bootstrap Meson with pip or download wraps automatically

Rejected because target package/release environments must be reproducible,
offline-capable, and explicit about dependency provenance.

## References

- [Meson: Porting from Autotools](https://mesonbuild.com/Porting-from-autotools.html)
- [Ubuntu Noble Meson package](https://packages.ubuntu.com/noble/all/meson)
- [ADR-0001 staged GTK migration](ADR-0001-staged-gtk-migration.md)
- [e05 legacy build baseline](../tech-architecture/e05-legacy-build-baseline.json)
