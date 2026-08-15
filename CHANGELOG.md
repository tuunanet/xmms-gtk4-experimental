# Changelog

All notable changes to XMMS GTK4 Experimental are documented here.

The project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- Gave the release build-parity contract a bounded 120-second test budget for slower package environments.

## [0.0.5] - 2026-08-15

### Fixed

- Ran release-container Meson distribution tests under Xvfb.
- Removed the optional PyYAML dependency from autonomous-policy verification.
- Corrected the reviewed Linux Mint Cppcheck 2.13 plugin-enumeration baseline.

## [0.0.4] - 2026-08-15

### Fixed

- Trust only the checked-out workspace before Meson creates release source archives in package containers.

## [0.0.3] - 2026-08-14

### Changed

- Made approved active-epic execution autonomous between green verification gates.

### Fixed

- Installed Git before release-container checkout so Meson can create the verified source archive.

## [0.0.2] - 2026-08-14

### Changed

- Made Meson the only supported build, test, source-distribution, and Debian package workflow.
- Removed retired Autotools, configure, libtool, and generated-delivery sources.

### Fixed

- Restored uninstalled discovery of direct Meson-built input and output plugin modules.

## [0.0.1]

### Changed

- Established the XMMS GTK4 Experimental project identity and repository links.
- Started an independent pre-1.0 release line for the experimental GTK4 direction.
- Preserved inherited runtime compatibility names while separating project branding.

### Fixed

- Restored clean GCC 15 builds for three legacy Vorbis GTK signal registrations.
- Removed stale test and GitHub metadata references that blocked checks and source archives.

Earlier fork-specific release history is archived in
[`docs/history/prior-fork-changelog.md`](docs/history/prior-fork-changelog.md).
