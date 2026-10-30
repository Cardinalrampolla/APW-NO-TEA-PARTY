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

## Isolated Godot DDT prototype
This `prototype/birdman-ddt` feature branch contains an experimental Godot 4 project. It is separate from the production HTML game and does not replace it.

### Run
1. Install Godot 4.4 or newer.
2. Open `project.godot` in Godot and run the project (F6/F5).
3. Press **Space** to play Birdman's DDT storyboard.

### Static check
With Python 3 installed, run `python verify_prototype.py` from this directory. This is a source smoke check, not a Godot runtime or visual test.

### Reduced-motion regression
With Godot 4.4 or newer, run `godot --headless --path . --script res://tests/test_reduced_motion.gd` to exercise reduced-motion toggles before, during, and after hitstop at each playback speed, along with impact-once, replay, recovery controls, and seek boundaries. The test checks the actual controller but does not replace frame-by-frame visual review.

The wrestlers are procedural stand-ins, not final character art. Review the animation in Godot before accepting visual behavior.
