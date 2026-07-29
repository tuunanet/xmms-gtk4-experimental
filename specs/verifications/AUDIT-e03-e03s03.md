# Audit: e03s03 GTK3 Play-button proof

**Reviewed range:** `ca6680b...955c5ef` plus verification-record updates
**Result:** PASS

## Review order

`scripts/bp-churn-rank.sh` is not present in this repository, so the audit reviewed the full branch diff and prioritized the control boundary, GTK3 adapter, proof test, build configuration, and packaging manifest.

## Checklist

- [x] **Supply chain and security:** GTK3 is a system `libgtk-3-dev` build dependency; no vendored or runtime-downloaded package was added. Secret-pattern scan found no credentials. `specs/security/REVIEW.md` records no reportable finding.
- [x] **Provenance and metadata:** e03 story metadata, tasks, ADR-0001, scope, impact, and test plan describe the boundary and delivery decisions.
- [x] **Law of Demeter:** the small C modules operate only on their immediate state, command, Cairo, and GDK event arguments.
- [x] **Conventions:** the production player stays GTK2; the GTK3 proof is a distinct executable; generated Autotools outputs accompany source changes; no plugin, socket, config, skin, or `libxmms` contract changed.
- [x] **Scope and Boy Scout:** the diff is limited to the planned GTK2 characterization, toolkit-neutral boundary, isolated GTK3 proof, required build/package wiring, and documentation. The distcheck manifest defect was fixed in its own `fix(dist)` commit. No dead or commented-out implementation code remains.
- [x] **Safety and clarity:** C code uses explicit GLib types, static helpers, narrow state/result structs, named control-result flags, and no new ownership transfer or worker-thread path.
- [x] **Tests:** focused GTK2 baseline, pure-control, and GTK3 proof tests cover normal/pressed drawing, inclusive/exclusive boundaries, invalid activation, leave/re-entry, and one-shot activation. Tests are isolated and self-validating; GTK tests run under Xvfb.
- [x] **SOLID and heuristics:** state handling, GTK3 event adaptation, and Cairo drawing are separate responsibilities. No message chains, data clumps beyond purposeful command/state records, duplicate logic, magic control semantics, or hidden toolkit dependency was identified.
- [x] **Code style:** new implementation files are focused (20–91 lines). Existing `pbutton.c` remains a legacy integration facade; no broad formatting was performed. Names are subsystem-prefixed and comments explain toolkit isolation.
- [x] **Delivery verification:** GTK3 proof links `libgtk-3.so` and excludes `libgtk-x11-2.0.so`; package contract checks and Preflight pass.

## Terminal evidence

```text
make lint                                              PASS
xvfb-run --auto-servernum tests/test-pbutton-baseline PASS
./tests/test-ui-control                                PASS
xvfb-run --auto-servernum tests/test-gtk3-play-button-proof PASS
tests/test-package-recipes.sh "$PWD"                  PASS
make -j"$(nproc)" && xvfb-run --auto-servernum make check PASS
```

## Manual UAT

The user confirmed the GTK2 Play control showed pressed artwork, returned to normal on pointer leave, restored pressed artwork on re-entry, and activated exactly once when released inside.

## Red-flag check

No checklist item was skipped. The absent churn-ranking helper was documented and replaced with full-diff review; the initially missing focused-test binary was rebuilt before the terminal checks, so it was not treated as a test failure.

**Next:** independent `request-review`.
