#!/usr/bin/env python3
"""50 read-only source-contract checks for the APW Godot DDT prototype.

STATIC ONLY: passing does not prove the game runs, animations look right, or
state transitions behave correctly. Ordewell owns independent runtime QA.
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
CHECKS = [["project","project.godot exists","file:project.godot"],["project","main.tscn exists","file:main.tscn"],["project","main.gd exists","file:main.gd"],["project","verifier exists","file:verify_prototype.py"],["project","README exists","file:README.md"],["project","ignore rules exist","file:.gitignore"],["project","Godot scene declares Node2D","gd:extends Node2D"],["project","ready hook exists","gd:func _ready()"],["project","frame processing exists","gd:func _process(delta:"],["project","redraw request exists","gd:queue_redraw()"],["timeline","duration defined","gd:const DURATION :="],["timeline","frame step defined","gd:const STEP :="],["timeline","impact time defined","gd:const IMPACT_AT :="],["timeline","hitstop length defined","gd:const HITSTOP_SECONDS :="],["timeline","elapsed initialized","gd:var elapsed := 0.0"],["timeline","playing initialized","gd:var playing := false"],["timeline","impact state initialized","gd:var impact_triggered := false"],["timeline","seek method exists","gd:func seek_to(t:"],["timeline","seek clamps time","gd:clampf(t, 0.0, DURATION)"],["timeline","end stops playback","gd:if elapsed >= DURATION:"],["controls","input handler exists","gd:func _unhandled_input(event:"],["controls","replay input exists","gd:is_action_pressed(\"ui_accept\")"],["controls","replay method exists","gd:func restart()"],["controls","pause key exists","gd:KEY_P:"],["controls","left step exists","gd:KEY_LEFT:"],["controls","right step exists","gd:KEY_RIGHT:"],["controls","home seek exists","gd:KEY_HOME:"],["controls","end seek exists","gd:KEY_END:"],["controls","half speed exists","gd:KEY_1:"],["controls","normal speed exists","gd:KEY_2:"],["safety","fast speed exists","gd:KEY_3:"],["safety","speed setter exists","gd:func set_playback_speed(speed:"],["safety","speed clamp exists","gd:clampf(speed, 0.25, 2.0)"],["safety","motion toggle exists","gd:KEY_R:"],["safety","motion setter exists","gd:func set_reduced_motion(enabled:"],["safety","hitstop cleared on motion enable","gd:if reduced_motion:\n        hitstop_remaining = 0.0"],["safety","process clears stale hitstop","gd:if reduced_motion and hitstop_remaining > 0.0:"],["safety","impact one-shot guard","gd:not impact_triggered and previous < IMPACT_AT"],["safety","hitstop disabled for reduced motion","gd:if not reduced_motion:\n                    hitstop_remaining = HITSTOP_SECONDS"],["safety","seek clears hitstop","gd:hitstop_remaining = 0.0"],["render","draw hook exists","gd:func _draw()"],["render","phase selector exists","gd:func phase_at(t:"],["render","approach phase exists","gd:APPROACH"],["render","underhook phase exists","gd:DOUBLE UNDERHOOK"],["render","impact phase exists","gd:IMPACT"],["render","recovery phase exists","gd:RECOVERY"],["render","wrestler renderer exists","gd:func _wrestler("],["render","timeline markers exist","gd:for boundary in [0.42, 0.92, 1.24, IMPACT_AT, 1.88]"],["render","debug toggle exists","gd:KEY_D:"],["render","placeholder disclaimer exists","gd:PROCEDURAL PLACEHOLDERS"]]
def main():
    source = (ROOT / "main.gd").read_text(encoding="utf-8") if (ROOT / "main.gd").is_file() else ""
    passed = 0
    for index, (group, name, rule) in enumerate(CHECKS, 1):
        kind, value = rule.split(":", 1)
        ok = (ROOT / value).is_file() if kind == "file" else value in source
        passed += ok
        print(f"{index:02d}/50 {'PASS' if ok else 'FAIL'} [{group}] {name}")
    print(f"STATIC GATE: {passed}/{len(CHECKS)} checks passed")
    print("LIMITATION: string/file checks only; no Godot runtime, behavioral or visual validation")
    return 0 if passed == len(CHECKS) else 1

if __name__ == "__main__":
    sys.exit(main())
