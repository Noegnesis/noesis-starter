# Fresh-user test + handoff checklist (Phase 1)

## A. Self-test on the build machine (Windows)
- [ ] `powershell -File setup.ps1 -Check` reports prereqs without installing.
- [ ] `bash tests/run.sh` is all green; `Invoke-Pester tests` is all green (needs Pester 5).
- [ ] `bash -n setup.sh` parses.

## B. macOS hardware test (cannot be done on the Windows build machine — needs a real Mac)
- [ ] On a tester's Mac (Rina first): `bash setup.sh --check` runs clean.
- [ ] `bash setup.sh` from a clean directory installs without a broken command.
- [ ] `/vault-setup` Basic branch builds a vault; Obsidian opens OR the manual
      "Open folder as vault" step is printed (never silent failure).
- [ ] Capture the **token cost** of the Basic onboarding run; confirm it is
      comfortable inside a Claude Pro budget. Note the number here.

## C. Acceptance — Rina
- [ ] Confirm her macOS version and that she has git + Claude Code or can install them.
- [ ] Walk her through the macOS Quick Start; she reaches a working vault + `/daily`.
- [ ] Log what broke and fold fixes back before the next handoff (Cole's sandbox).

## D. Known gap
Until step B passes on real hardware, keep the README macOS one-liner labeled
"beta — verifying on hardware."
