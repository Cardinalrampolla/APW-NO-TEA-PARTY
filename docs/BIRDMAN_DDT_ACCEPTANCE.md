# APW — Birdman Double Underhook DDT: Acceptance Contract

Status: SPECIFICATION ONLY. No runtime or visual test has been executed by AXEL.

## Scene choreography
1. **Approach / control:** attacker reaches a stable front grapple; opponent is within the grab window.
2. **Double underhook:** both arms visibly trapped; no instantaneous teleport into the lock.
3. **Lift / rotation:** both actors move as one connected pair; opponent root follows an explicit synchronized trajectory.
4. **Impact:** DDT landing is readable, impact occurs once, screen shake and hit flash peak at contact; no excessive flashing.
5. **Recovery:** both actors return to valid states without snapping, clipping, or becoming stuck.

## Engineering contract
- A single attack instance owns the pair choreography timeline.
- A named impact event fires exactly once per successful execution.
- Cancel/interruption frees opponent control and resets camera effects.
- Damage and pin eligibility are applied by combat logic, not animation frames alone.
- Animation can be replayed after completion without residual offsets.
- Preserve existing gameplay rules and the original HTML build; prototype work stays on a feature branch.

## Acceptance tests
| ID | Check | Evidence required |
|---|---|---|
| DDT-01 | Attacker and opponent align at grab | Godot runtime video/screenshot or explicit untested |
| DDT-02 | Underhook is visible before lift | Frame sequence |
| DDT-03 | Opponent remains attached through lift | Runtime capture, no root-position divergence |
| DDT-04 | Impact triggers exactly once | Event log/assertion |
| DDT-05 | Cancel restores both actors | Automated or manual reproduction |
| DDT-06 | Repeated use does not accumulate transforms | 10-run test |
| DDT-07 | Recovery restores playable control | Runtime assertion |
| DDT-08 | Missing assets/paths produce no scene errors | Godot headless import/log |
| DDT-09 | Existing HTML master unchanged | Git diff / SHA check |

## Reporting
Each agent should post: task number, branch/commit or PR, files changed, exact test command, pass/fail counts, runtime availability, visual evidence link, unresolved defects, next owner. A static parse is not a gameplay test. Do not claim Godot execution if Godot is unavailable.

## Dependencies
The repository main branch currently has only README.md. Source must be committed to a non-main branch before remote agents can implement or test this prototype. No secrets or local private paths in reports.
