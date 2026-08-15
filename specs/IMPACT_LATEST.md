# Impact: v0.0.3 release-workflow repair and autonomous epic policy

## Target

- `.github/workflows/package-release.yml`: target-container checkout and
  dependency ordering.
- `CLAUDE.md` and `specs/workflows/autonomous-epic.yaml`: project-local agent
  execution policy.

## Dependents

1. The manual tagged package-release workflow uses the container checkout to
   create the Meson source archive consumed by `tools/package-deb.sh`.
2. `tests/test-package-recipes.sh` statically protects the release workflow's
   package and draft-release contract.
3. `tests/meson.build` and its test-inventory contract register policy checks.
4. `specs/state.yaml` records accepted project workflow decisions and release
   target state.
5. `meson.build`, `CHANGELOG.md`, and `tools/check-release-version.sh` form the
   release-version authority.

## Affected Stories

- **e05s04:** owns package and release workflow behavior.
- **e05s06:** cannot complete until tagged draft-release acceptance succeeds.
- **Future active epics:** consume the autonomous execution policy.

## Test Coverage

- Existing `tests/test-package-recipes.sh` verifies release workflow presence,
  targets, permissions, checksums, draft creation, Meson usage, and no
  Autotools fallback.
- Gap: it does not require Git to be installed before the container checkout.
- Gap: no project-local contract currently prevents agents from pausing after
  routine successful story steps.

## Risk: High

The change affects the sole tagged release pipeline and every future epic's
agent progression. A failed package job blocks release delivery; unsafe
automation must retain explicit blocked and exhausted terminal states.

## Recommended action

Add focused contract tests before changing workflow/policy behavior; retain all
release authorization, credential, destructive-operation, and external-blocker
human gates. Run full strict preflight before creating `v0.0.3`.
