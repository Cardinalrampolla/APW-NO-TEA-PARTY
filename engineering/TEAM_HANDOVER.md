# APW engineering collaboration

## Responsibilities
- Team A: combat animation, artwork, gameplay feel, career story and final creative integration.
- Team B: code safety, save/load, timer lifecycle, regression testing, performance and release QA.
- Owner: release approval and creative decisions.

## Branches
- `main`: integration only; no direct unreviewed edits.
- `team-a`: Team A work.
- `team-b`: Team B work.

## Transfer protocol
1. Compare source SHA-256 against `engineering/BASELINE_MANIFEST.md`.
2. Commit verified baseline as a separate untouched file; tag the baseline.
3. Work in branch-specific paths or independent branches; no force pushes.
4. Open draft PR with changed files, test evidence, known risks and rollback path.
5. Resolve conflicts by reviewing both branches, not blindly overwriting either.
6. Merge only after technical and creative approval.

## Current limitation
GitHub is accessible via connector but the 23 MB source HTML has not been transferred. This repo currently contains coordination documentation, not a playable game. Team A and Team B must each invoke their own connected tools to read updated repository state.
