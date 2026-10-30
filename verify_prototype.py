from pathlib import Path
root = Path(__file__).resolve().parent
script = (root / 'main.gd').read_text()
checks = {
 'project scene exists': (root / 'main.tscn').exists(),
 'godot project exists': (root / 'project.godot').exists(),
 'deterministic frame step': 'const STEP := 1.0 / 30.0' in script and 'seek_to(elapsed + STEP)' in script,
 'seek clamps': 'clampf(t, 0.0, DURATION)' in script,
 'impact crossing only once': 'not impact_triggered and previous < IMPACT_AT' in script,
 'reduced-motion hitstop bypass': 'if not reduced_motion:\n                    hitstop_remaining' in script,
 'reduced-motion toggle clears active hitstop': 'func set_reduced_motion(enabled: bool) -> void:\n    reduced_motion = enabled\n    # Turning accessibility mode on during an active hitstop must resume\n    # timeline progression immediately instead of finishing the freeze.\n    if reduced_motion:\n        hitstop_remaining = 0.0' in script,
 'reduced-motion regression test exists': (root / 'tests' / 'test_reduced_motion.gd').exists(),
 'phase ruler': 'for boundary in [0.42, 0.92, 1.24, IMPACT_AT, 1.88]' in script,
 'speed controls': all(x in script for x in ['KEY_1:', 'KEY_2:', 'KEY_3:']),
 'debug toggle': 'KEY_D:' in script,
 'original silhouettes retained': 'func _wrestler(' in script,
}
for name, passed in checks.items():
 print(('PASS' if passed else 'FAIL') + ' ' + name)
if not all(checks.values()): raise SystemExit(1)
