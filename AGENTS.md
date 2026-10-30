# APW: No Tea Party! — agent working agreement

## Mission
Deliver a convincing, testable Birdman Phil Picasso Double Underhook DDT in this isolated Godot 4 prototype. Do not migrate or edit the production HTML game.

## Quality gates
1. Preserve Godot 4.4+ syntax and runnable scene/project structure.
2. Keep animation seeking deterministic; impact freeze must trigger once per playback and never on timeline seek.
3. Reduced motion must disable shake and hitstop.
4. Every behavioral change needs an automated check; report tests actually run, separately from checks requiring Godot.
5. Do not call procedural silhouettes final sprites or claim visual acceptance without viewing Godot output.
6. Make changes on isolated git branches/worktrees; no automatic merge into main. Human reviews the diff.

## Division of work
- Animation task: improve pose interpolation and choreography in the prototype; include automated checks for behavioral changes.
- Code quality review task: review the prototype read-only and report prioritized findings with evidence.
- Automated verification task: improve verify_prototype.py and reproducible test cases; do not edit main.gd.
- Every task uses its own Codex-managed Git worktree. A human reviews and integrates all changes; never merge or apply task diffs automatically.

## Acceptance
Pass static tests; Godot scene launches without parse errors; DDT sequence is reviewed frame-by-frame in Godot; original APW HTML remains unchanged. Runtime/visual gates remain pending until actually executed.
