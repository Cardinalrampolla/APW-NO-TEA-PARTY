extends SceneTree
## Headless QA: 50 authored spatial poses, plus animation transition behavior.
## Run: godot --headless --path . --script res://tests/test_finisher_poses.gd

const PreviewScene = preload("res://finisher_preview.tscn")
const Timing = preload("res://finisher_timing.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func assert_case(condition: bool, label: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        printerr("FAIL %02d: %s" % [checks, label])

func _run() -> void:
    var preview = PreviewScene.instantiate()
    root.add_child(preview)
    preview.running = false
    assert_case(Timing.validate_library(), "timing library structurally valid")
    assert_case(preview.MOVE_IDS.size() == 10, "ten finishers available")
    assert_case(preview.POSES.size() == 10, "ten spatial pose sets available")
    # Fifty individually counted spatial-pose validation checkpoints.
    for move_index in range(10):
        var move_id: String = preview.MOVE_IDS[move_index]
        var beats: Array = Timing.get_move(move_id)["beats"]
        for pose_index in range(5):
            var pose: Array = preview.POSES[move_index][pose_index]
            var valid := pose.size() == 6
            if valid:
                var attacker_x: float = pose[0]
                var attacker_y: float = pose[1]
                var defender_x: float = pose[2]
                var defender_y: float = pose[3]
                var attacker_angle: float = pose[4]
                var defender_angle: float = pose[5]
                valid = is_finite(attacker_x) and is_finite(attacker_y)
                valid = valid and is_finite(defender_x) and is_finite(defender_y)
                valid = valid and is_finite(attacker_angle) and is_finite(defender_angle)
                valid = valid and attacker_x >= 0.0 and attacker_x <= 1280.0
                valid = valid and defender_x >= 0.0 and defender_x <= 1280.0
                valid = valid and attacker_y >= 0.0 and attacker_y <= 720.0
                valid = valid and defender_y >= 0.0 and defender_y <= 720.0
                valid = valid and absf(attacker_angle) <= TAU
                valid = valid and absf(defender_angle) <= TAU
            assert_case(valid, "%s spatial pose %d" % [move_id, pose_index + 1])
        preview.selected = move_index
        for beat_index in range(5):
            var at: float = beats[beat_index]["at"]
            var sample: Array = preview.interpolated_pose(at)
            var expected: Array = preview.POSES[move_index][beat_index]
            var match_pose := sample.size() == 6
            if match_pose:
                for j in range(6):
                    if absf(float(sample[j]) - float(expected[j])) > 0.0001:
                        match_pose = false
            assert_case(match_pose, "%s interpolates exact anchor %d" % [move_id, beat_index + 1])
        preview.reset_preview()
        preview.running = false
        preview.elapsed = preview.SECONDS * 0.73
        preview.last_beat = 2
        preview.running = true
        preview._process(0.01)
        assert_case(preview.impact_count == 1, "%s impact triggers once" % move_id)
        preview._process(0.01)
        assert_case(preview.impact_count == 1, "%s impact not repeated" % move_id)
        preview.reset_preview()
        assert_case(preview.impact_count == 0 and preview.last_beat == -1, "%s replay resets impact" % move_id)
    preview.queue_free()
    print("APW finisher QA: %d checks, %d failures; 50 spatial poses, 50 anchor matches, 30 impact/replay checks + 3 library checks" % [checks, failures])
    quit(0 if failures == 0 else 1)
