# APW A1 Quality Gate — Mandatory Review Checklist

**Status:** Enforced review standard, not evidence of completed testing.

## Gate 1: Source integrity
- [ ] Baseline branch and source SHA recorded; original APW HTML untouched.
- [ ] Scope matches assigned issue; diff inspected line-by-line for accidental edits.
- [ ] No dead code, secrets, generated caches, broken references, or unnecessary dependencies.

## Gate 2: Functional correctness
- [ ] Happy-path behavior verified with exact reproduction steps.
- [ ] Cancel/interruption/retry/recovery and boundary conditions tested.
- [ ] Repeated move executions do not accumulate offsets or duplicate events.
- [ ] Reduced-motion toggle during hitstop does not leave a frozen state.
- [ ] Regression tests added for each defect fixed.

## Gate 3: Visual and feel
- [ ] Two-character grapple silhouettes clearly communicate hold, lift, impact, recovery.
- [ ] Characters remain synchronized and grounded; no obvious snapping or clipping.
- [ ] Impact feedback reads instantly without uncomfortable flashing.
- [ ] Camera framing, screen shake, timing and readability checked in runtime.
- [ ] Capture screenshots or short clips for any animation/UI change; name what remains subjective.

## Gate 4: Verification
- [ ] Run static checks and report commands, exit codes and outputs.
- [ ] Run Godot import/headless checks when runtime exists; otherwise BLOCKED.
- [ ] Run visual/manual checks when runtime exists; otherwise UNTESTED.
- [ ] Independent reviewer checks meaningful changes before merge.
- [ ] No invented pass/fail counts or claims of runtime success.

## Gate 5: Delivery
- [ ] Isolated feature branch and reviewable PR.
- [ ] Linked issue/checkpoint, commit, test logs, visual evidence and known limitations.
- [ ] Owner approves release/integration; **no auto-merge**.

### Reporting template
```
[AGENT] [DONE|BLOCKED] Issue #__ / Checkpoint G__
Branch/commit/PR:
Files changed:
Tests executed (exact commands + outcomes):
Visual evidence:
Second-reviewer verdict:
Known gaps:
Next action:
```

A1 quality is a review target, not an assertion that the current prototype already meets it.
