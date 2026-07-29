# Impact assessment: project rebrand and version reset

## Target

Current project branding, repository URLs, release version metadata, packaging descriptions, release documentation, and the stale keyboard-shortcut test wiring.

## Dependents (8 groups)

- `configure.in` and shipped `configure`: configure-time package version and generated `VERSION` macros.
- `CHANGELOG.md` and release tools: release-note extraction and version consistency checks.
- `Makefile.am`, shipped `Makefile.in`, and `tests/Makefile`: source distribution and regression orchestration.
- `packaging/` and `tools/build-deb.sh`: Debian metadata, desktop display name, and generated package changelog.
- `README.md`, contributor/manual/release docs, and architecture docs: public project identity and repository links.
- `CLAUDE.md`, `CONVENTIONS.md`, and `specs/`: agent guidance, project state, vision, and planning identity.
- `tests/test-package-recipes.sh`: packaging display-name contract.
- GitHub workflow and release path classification: absent from the flattened root; no checked-in workflow file can require an update in this change.

## Affected Stories

- BUG-2026-07-29T111455: restore a green baseline after intentional test-source removal.
- Story e02s01: expose one consistent new project identity and initial version across all current surfaces.

## Test Coverage

- `tests/test-release-tools.sh`: release metadata and extraction behavior.
- `tests/test-package-recipes.sh`: packaging and desktop metadata.
- `make check`: build/test manifest consistency.
- `make distcheck`: shipped generated metadata and source archive completeness.
- Gap: prose branding has no dedicated test; repository-wide searches provide deterministic verification.

## Risk: Medium

The runtime ABI remains untouched, but version and branding fan out across generated Autotools files, packaging, release tooling, and many public documents.

## Recommended action

Proceed with two atomic commits: first remove the stale test wiring and prove the baseline; then rebrand current surfaces, archive prior fork-specific changelog prose under `docs/history/`, set version `0.0.1`, and run release/package/full distribution gates.
