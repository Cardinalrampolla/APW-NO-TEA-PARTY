# Codex Worktree Workflow

Use the Codex CLI as the coding agent. The three task prompts live in `.codex/tasks/`; launch each in a separate terminal from this project directory:

## Launch Tasks
```powershell
codex --worktree (Get-Content -Raw .codex/tasks/animation.md)
codex --worktree (Get-Content -Raw .codex/tasks/code-quality-review.md)
codex --worktree (Get-Content -Raw .codex/tasks/automated-verification.md)
```

Each invocation creates a separate Codex-managed Git worktree. Review each task prompt before starting it. Do not use Codex apply, merge, cherry-pick, or any automatic integration action; a human reviews each worktree diff and decides what to integrate.

## Git Prerequisite

Codex worktrees need a committed base revision. This checkout currently has no commits (unborn `master`). The original project files are staged, while the updated guardrails and task prompts are not all in the index. Do not commit or change staging automatically. Have the repository owner review and commit the intended baseline, including this workflow setup, then launch the tasks above. This keeps all three worktrees based on the same reviewed snapshot.

## Completion Evidence

A task is not complete unless its report includes the worktree/branch, changed files, exact automated test commands, and observed pass/fail output. If a required test cannot run, report the task as blocked or incomplete rather than passing it. Report Godot runtime checks separately from source-level checks, and never claim visual acceptance without reviewing the sequence in Godot. The production HTML game is out of scope and must remain unchanged.

## Initial Prototype Review

The current scene is a small single-script Godot 4 prototype: choreography and drawing are in `main.gd`, and `verify_prototype.py` checks source invariants using string matches. The verifier is useful as a smoke check but is brittle and does not execute animation behavior. Godot runtime and frame-by-frame visual review remain separate acceptance gates. The review and verification tasks should validate these observations and report any additional findings with file and line evidence.
