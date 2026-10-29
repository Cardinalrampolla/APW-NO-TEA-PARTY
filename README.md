# APW: NO TEA PARTY!

Private development repository for APW.

## Development lanes
- `main`: integration baseline; no unreviewed changes.
- `team-a`: gameplay, graphics, animations, narrative.
- `team-b`: engineering, debugging, optimisation, QA.

## Collaboration protocol
1. Preserve the untouched source baseline and record SHA-256 before repairs.
2. Each team commits only on its own branch.
3. Open pull requests to propose integration into `main`.
4. Compare overlapping functions before merge; never force-push over the other team's work.
5. Record test evidence and unverified behaviours on every engineering PR.
6. Project owner approves promotion of any official master release.

## Current state
Repository initialized for collaboration. The v12.5 HTML baseline has **not** yet been uploaded here. Large single-file HTML builds may exceed connector upload limits. Do not represent repository files as current until verified.
