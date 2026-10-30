# APW — 50 More Checkpoints (G61–G110)

> This is an executable work backlog, NOT a claim that these checkpoints have passed.

## Mandatory prerequisites
- Close source-publication blocker #9 before runtime-dependent implementation.
- Fix confirmed hitstop/reduced-motion bug #7 and establish behavioral verification #8.
- Preserve the original HTML; prototype changes belong in isolated branches.
- Every checkpoint must include an owner, PR/commit, exact tests run, visual evidence where applicable, and PASS/FAIL/BLOCKED.
- Mandatory A1 quality gate: `docs/A1_QUALITY_GATE.md` on this branch.

## G61–G70 — Wrestler animation systems

- [ ] **G61** reusable two-actor animation driver
- [ ] **G62** grapple anchor authoring tools
- [ ] **G63** character scale/height alignment
- [ ] **G64** blendable anticipation poses
- [ ] **G65** deterministic contact frames
- [ ] **G66** move interruption and rollback
- [ ] **G67** left/right facing symmetry
- [ ] **G68** animation event debug overlay
- [ ] **G69** reduced-motion alternatives for every effect
- [ ] **G70** 20-run animation regression capture

**Exit gate:** evidence reviewed; incomplete tasks remain open; no auto-merge.

## G71–G80 — Core wrestling gameplay

- [ ] **G71** stamina and momentum tuning
- [ ] **G72** reversible grapple initiation
- [ ] **G73** reversal timing and counter feedback
- [ ] **G74** strike-to-grapple transitions
- [ ] **G75** three-count pin state machine
- [ ] **G76** kick-out window and accessibility
- [ ] **G77** rope-break and boundary rules
- [ ] **G78** referee line-of-sight logic
- [ ] **G79** dirty-trick risk and disqualification
- [ ] **G80** 20-match gameplay test protocol

**Exit gate:** evidence reviewed; incomplete tasks remain open; no auto-merge.

## G81–G90 — Roster and signature moves

- [ ] **G81** roster data schema and validation
- [ ] **G82** Birdman Double Underhook DDT finishing pass
- [ ] **G83** Bruza Russian Leg Sweep
- [ ] **G84** Simon Temple Chokeslam
- [ ] **G85** Gideon Hark Ripcord Clothesline
- [ ] **G86** Johnny Putrid The Stroke
- [ ] **G87** TNT The Unprettier
- [ ] **G88** Nikki Poteet Running Cannonball
- [ ] **G89** wrestler-specific selling/recovery variants
- [ ] **G90** finisher test gallery and consistency review

**Exit gate:** evidence reviewed; incomplete tasks remain open; no auto-merge.

## G91–G100 — Arcade game feel and presentation

- [ ] **G91** arcade HUD layout polish
- [ ] **G92** high-contrast player/opponent indicators
- [ ] **G93** responsive large-button controls
- [ ] **G94** hit impact timing and freeze-frame tuning
- [ ] **G95** camera composition and arena framing
- [ ] **G96** non-graphic impact VFX polish
- [ ] **G97** sound cue timing and volume options
- [ ] **G98** performance budgets and frame-time measurement
- [ ] **G99** keyboard/controller input latency test
- [ ] **G100** recorded A1 visual review with defects log

**Exit gate:** evidence reviewed; incomplete tasks remain open; no auto-merge.

## G101–G110 — Production readiness and QA

- [ ] **G101** project source manifest and hashes
- [ ] **G102** branch and dependency consistency audit
- [ ] **G103** reproducible clean-install test
- [ ] **G104** save/load and corrupted-state resilience
- [ ] **G105** career mode progression smoke tests
- [ ] **G106** singles/tag/hardcore rules regression
- [ ] **G107** accessibility settings smoke test
- [ ] **G108** 100-match stress test and memory review
- [ ] **G109** independent second-agent PR review
- [ ] **G110** owner-reviewed release gate; no auto-merge

**Exit gate:** evidence reviewed; incomplete tasks remain open; no auto-merge.

## Crew discipline
- Agents claim ownership in #3 with START before implementing.
- Cross-review changes before proposing merge.
- Flag source/runtime blockers immediately; do not report invented success.
- Focus on finishing current critical-path tasks before starting new waves.