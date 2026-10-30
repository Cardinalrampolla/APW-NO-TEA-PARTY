# APW — Cross-Agent Peer Review Protocol

## Purpose
Catch overlooked defects before integration. Review must be adversarial but constructive: seek reproducible failures, not merely approve appearances.

## Cadence
- Every substantial PR: independent reviewer required before DONE.
- Every ten-checkpoint wave: rotate reviewers across animation, combat and QA.
- Every confirmed bug fix: original author supplies regression test; separate reviewer reproduces before closing.
- Every release candidate: independent integration audit.

## Reviewer procedure
1. Identify exact source branch, baseline, commit and scope; ensure production HTML is untouched.
2. Read changed code and nearby call sites; inspect scene references, animation timelines, data invariants, input handling and error paths.
3. Try failure scenarios: interruption, cancel, seek, repeated use, low FPS, missing assets, reduced motion, off-screen actors and invalid state.
4. Execute tests, record exact commands and outcomes; distinguish static checks from actual Godot runtime.
5. Inspect visual output where relevant: silhouettes, clipping, timing, effects, camera, legibility and frame pacing.
6. Post findings as BLOCKER / MAJOR / MINOR, each with steps to reproduce and expected vs actual behavior.
7. Original author addresses findings; independent reviewer retests and records PASS / FAIL / UNTESTED.
8. Only then propose integration. No automatic merges.

## Suggested rotation
| Wave | Author lane | Reviewer lane |
|---|---|---|
| Animation | Animation agent | QA agent |
| Gameplay | Combat agent | Animation agent |
| Verification | QA agent | Code-quality agent |
| Integration | Integration agent | A different agent not responsible for changes |

## Required evidence
```
[AGENT] [REVIEW START] Issue #__ | PR/commit: __ | Reviewer: __
[AGENT] [REVIEW DONE] Issue #__ | Finding: BLOCKER/MAJOR/MINOR | Repro: __ | Tests: __ | Visual check: __ | Verdict: PASS/FAIL/UNTESTED
```

**No rubber-stamp approvals.** No reviewer can claim runtime testing without the runtime. A missing reviewer means UNREVIEWED, not DONE.
