# Traceability Gate: e01 C lint regression gate

- Generated: 2026-07-28T14:18:59Z
- Verdict: **WAIVED**
- Reason: The repository does not provide `scripts/trace-stories.sh`, `scripts/check-blind-spots.sh`, or `scripts/lib/completeness-critic.sh`; therefore the deterministic matrix and oracle-confidence calculation cannot run.

## Manual fallback

| Story | Implementation | Tests | Verification | Result |
|---|---|---|---|---|
| `e01s01` | `tools/run-c-lint.sh`, `tools/cppcheck-suppressions.txt`, `Makefile.am`, `Makefile.in`, `tests/Makefile` | `tests/test-c-lint.sh` | `specs/verifications/e01s01-verify.yaml`, `specs/verifications/NFR-e01s01.json` | Covered |
| `e01s02` | `CONTRIBUTING.md`, `docs/architecture/build-and-test.md` | `tests/test-package-recipes.sh` | `specs/verifications/e01s02-verify.yaml` | Covered locally; no push CI workflow tracked |

## Adversarial refutation

Attempted refutation: the Ubuntu 24.04 analyzer could reject a baseline generated with the newer local analyzer, leaving the lint story unimplemented in practice.

Result: the refutation initially succeeded. Cppcheck 2.13.0 exposed 13 additional legacy diagnostics. Commit `fa64939` added narrow line-specific entries, after which the full lint contract passed under both Cppcheck 2.13.0 and 2.19.0.

No missing story, implementation path, test, or persisted verification evidence was found in the manual fallback. Local canonical preflight is the required integration check; no push CI workflow tracked.
