# APW: No Tea Party! — 50 Checkpoint Execution Roadmap

> Planning document, not a claim of implementation or test completion.

## Preconditions
- Existing local Godot Birdman prototype must be committed to a separate feature branch before distributed execution.
- Preserve original APW HTML; never auto-merge or force push.
- Each checkpoint requires a commit/PR or evidence artifact, explicit PASS/FAIL/BLOCKED status, and actual test logs where available.
- Runtime and visual checks must not be reported as passed unless executed.
- Run work in parallel only when dependencies permit; a wave gate requires reviewed evidence before promotion.

## G11–G20: Prototype foundation

- [ ] **G11** inventory Godot source and dependency manifest — Evidence: changed files/commit + relevant test or capture.
- [ ] **G12** publish prototype on non-main branch — Evidence: changed files/commit + relevant test or capture.
- [ ] **G13** reproducible Godot import and headless boot — Evidence: changed files/commit + relevant test or capture.
- [ ] **G14** input-to-animation state mapping — Evidence: changed files/commit + relevant test or capture.
- [ ] **G15** fixed-step timeline for DDT — Evidence: changed files/commit + relevant test or capture.
- [ ] **G16** paired wrestler alignment and anchors — Evidence: changed files/commit + relevant test or capture.
- [ ] **G17** grapple lock validation and cancellation — Evidence: changed files/commit + relevant test or capture.
- [ ] **G18** one-shot impact event contract — Evidence: changed files/commit + relevant test or capture.
- [ ] **G19** reduced-motion hitstop fix — Evidence: changed files/commit + relevant test or capture.
- [ ] **G20** regression suite for G11–G19 — Evidence: changed files/commit + relevant test or capture.

**Wave exit gate:** Each item PASS or explicitly BLOCKED with owner, reason, next action. No automatic merge.

## G21–G30: Birdman animation quality

- [ ] **G21** neutral/approach anticipation poses — Evidence: changed files/commit + relevant test or capture.
- [ ] **G22** opponent grapple reaction poses — Evidence: changed files/commit + relevant test or capture.
- [ ] **G23** visible double-underhook setup — Evidence: changed files/commit + relevant test or capture.
- [ ] **G24** synchronized lift frames — Evidence: changed files/commit + relevant test or capture.
- [ ] **G25** DDT rotation arc — Evidence: changed files/commit + relevant test or capture.
- [ ] **G26** grounded contact and safe landing — Evidence: changed files/commit + relevant test or capture.
- [ ] **G27** impact flash and camera shake tuning — Evidence: changed files/commit + relevant test or capture.
- [ ] **G28** opponent selling and stagger — Evidence: changed files/commit + relevant test or capture.
- [ ] **G29** recovery transitions and control restore — Evidence: changed files/commit + relevant test or capture.
- [ ] **G30** runtime capture and side-by-side visual review — Evidence: changed files/commit + relevant test or capture.

**Wave exit gate:** Each item PASS or explicitly BLOCKED with owner, reason, next action. No automatic merge.

## G31–G40: Combat reliability

- [ ] **G31** damage application exactly once — Evidence: changed files/commit + relevant test or capture.
- [ ] **G32** stamina and special move cost — Evidence: changed files/commit + relevant test or capture.
- [ ] **G33** hitstun duration and escape handling — Evidence: changed files/commit + relevant test or capture.
- [ ] **G34** grapple range and facing edge cases — Evidence: changed files/commit + relevant test or capture.
- [ ] **G35** input buffering and invalid-action feedback — Evidence: changed files/commit + relevant test or capture.
- [ ] **G36** interruption/counter state rollback — Evidence: changed files/commit + relevant test or capture.
- [ ] **G37** collision and arena boundary behavior — Evidence: changed files/commit + relevant test or capture.
- [ ] **G38** repeated move 100-cycle stability — Evidence: changed files/commit + relevant test or capture.
- [ ] **G39** pin eligibility after finisher — Evidence: changed files/commit + relevant test or capture.
- [ ] **G40** automated combat-state regression suite — Evidence: changed files/commit + relevant test or capture.

**Wave exit gate:** Each item PASS or explicitly BLOCKED with owner, reason, next action. No automatic merge.

## G41–G50: Arcade presentation and usability

- [ ] **G41** screen-space composition and silhouettes — Evidence: changed files/commit + relevant test or capture.
- [ ] **G42** animation timing presets — Evidence: changed files/commit + relevant test or capture.
- [ ] **G43** impact particles and readability — Evidence: changed files/commit + relevant test or capture.
- [ ] **G44** camera follow/zoom bounds — Evidence: changed files/commit + relevant test or capture.
- [ ] **G45** motion accessibility and flash reduction — Evidence: changed files/commit + relevant test or capture.
- [ ] **G46** controller/keyboard action parity — Evidence: changed files/commit + relevant test or capture.
- [ ] **G47** large arcade UI action prompts — Evidence: changed files/commit + relevant test or capture.
- [ ] **G48** sound cue integration hooks and mute handling — Evidence: changed files/commit + relevant test or capture.
- [ ] **G49** frame pacing and performance profiling — Evidence: changed files/commit + relevant test or capture.
- [ ] **G50** recorded gameplay review and tuning — Evidence: changed files/commit + relevant test or capture.

**Wave exit gate:** Each item PASS or explicitly BLOCKED with owner, reason, next action. No automatic merge.

## G51–G60: Integration and release gate

- [ ] **G51** source integrity and master HTML checksum — Evidence: changed files/commit + relevant test or capture.
- [ ] **G52** feature branch diff audit — Evidence: changed files/commit + relevant test or capture.
- [ ] **G53** Godot build reproducibility — Evidence: changed files/commit + relevant test or capture.
- [ ] **G54** cross-platform path/case validation — Evidence: changed files/commit + relevant test or capture.
- [ ] **G55** missing asset fallback checks — Evidence: changed files/commit + relevant test or capture.
- [ ] **G56** crash and error-log sweep — Evidence: changed files/commit + relevant test or capture.
- [ ] **G57** manual 10-match playtest protocol — Evidence: changed files/commit + relevant test or capture.
- [ ] **G58** documented known defects and prioritization — Evidence: changed files/commit + relevant test or capture.
- [ ] **G59** reviewed PR with test evidence — Evidence: changed files/commit + relevant test or capture.
- [ ] **G60** release candidate decision; no auto-merge — Evidence: changed files/commit + relevant test or capture.

**Wave exit gate:** Each item PASS or explicitly BLOCKED with owner, reason, next action. No automatic merge.

## Reporting format
`[AGENT] [START|DONE|BLOCKED] Checkpoint: G## | Issue: #... | Branch: ... | Commit/PR: ... | Tests executed: ... | Result: ... | Next: ...`