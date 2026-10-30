extends SceneTree

const Prototype = preload("res://main.gd")
var failures := 0

func expect(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error(message)

func press(node, key: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = key
    event.pressed = true
    node._unhandled_input(event)

func cross_impact(node) -> void:
    node._process((node.IMPACT_AT - node.elapsed + 0.01) / node.playback_speed)
    expect(is_equal_approx(node.elapsed, node.IMPACT_AT), "Impact crossing clamps time")
    expect(node.impact_triggered, "Impact crossing latches event")

func check_toggle(timing: String, speed: float) -> void:
    var node = Prototype.new()
    node.playback_speed = speed
    node.restart()
    if timing == "before":
        press(node, KEY_R)
        cross_impact(node)
    else:
        cross_impact(node)
        expect(node.hitstop_remaining > 0.0, "Normal playback starts hitstop")
        if timing == "during":
            node._process(node.HITSTOP_SECONDS / 2.0)
            expect(node.hitstop_remaining > 0.0, "Toggle occurs inside active hitstop")
        else:
            node._process(node.HITSTOP_SECONDS + 0.01)
            node._process(0.01)
            expect(node.hitstop_remaining == 0.0, "Toggle occurs after hitstop")
        press(node, KEY_R)
    expect(node.reduced_motion, timing + ": R enables reduced motion")
    expect(node.hitstop_remaining == 0.0, timing + ": no remaining hitstop")
    var previous: float = node.elapsed
    node._process(0.01)
    expect(node.elapsed > previous, timing + ": next tick advances immediately")
    press(node, KEY_R)
    expect(not node.reduced_motion, "R disables reduced motion")
    for _tick in range(600):
        previous = node.elapsed
        node._process(0.01)
        expect(node.hitstop_remaining == 0.0, "Impact must not trigger twice")
        expect(node.impact_triggered, "Impact latch survives toggles")
        if node.playing:
            expect(node.elapsed > previous, "Recovery continues advancing")
    expect(is_equal_approx(node.elapsed, node.DURATION), "Recovery reaches timeline end")
    expect(not node.playing, "Playback stops at timeline end")
    press(node, KEY_SPACE)
    expect(node.playing and not node.inspection_paused, "Space replays completed timeline")
    cross_impact(node)
    press(node, KEY_R)
    node._process(0.3 / speed)
    expect(node.phase_at(node.elapsed) == "RECOVERY", "Reached recovery")
    press(node, KEY_P)
    previous = node.elapsed
    node._process(0.1)
    expect(node.elapsed == previous, "Recovery can pause")
    press(node, KEY_R)
    press(node, KEY_R)
    expect(node.inspection_paused, "Reduced motion preserves explicit pause")
    press(node, KEY_1)
    press(node, KEY_P)
    node._process(0.1)
    expect(is_equal_approx(node.elapsed, previous + 0.05), "Recovery resumes at selected speed")
    node.set_reduced_motion(false)
    node.restart()
    expect(not node.impact_triggered, "Replay resets impact latch")
    cross_impact(node)
    expect(node.hitstop_remaining > 0.0, "Replay permits a new impact")
    node.free()

func check_seeking() -> void:
    var node = Prototype.new()
    node.restart()
    cross_impact(node)
    for target in [-node.STEP, 0.0, node.IMPACT_AT - node.STEP, node.IMPACT_AT, node.IMPACT_AT + node.STEP, node.DURATION, node.DURATION + node.STEP]:
        node.seek_to(target)
        var expected_time: float = clampf(target, 0.0, node.DURATION)
        expect(is_equal_approx(node.elapsed, expected_time), "Seek clamps to timeline boundaries")
        expect(not node.playing and node.inspection_paused, "Seek explicitly pauses playback")
        var expected_latch: bool = expected_time >= node.IMPACT_AT
        expect(node.impact_triggered == expected_latch, "Seek sets deterministic impact latch")
        for enabled in [true, false]:
            node.set_reduced_motion(enabled)
            node._process(0.1)
            expect(node.elapsed == expected_time, "Seek stays paused across reduced-motion toggles")
            expect(node.hitstop_remaining == 0.0, "Seek never starts hitstop")
            expect(node.impact_triggered == expected_latch, "Toggle preserves seek latch")
    node.free()

func _initialize() -> void:
    for timing in ["before", "during", "after"]:
        for speed in [0.5, 1.0, 1.5]:
            check_toggle(timing, speed)
    check_seeking()
    if failures == 0:
        print("PASS reduced-motion toggles before/during/after hitstop; recovery, replay and seek")
    else:
        push_error("FAIL: %d regression assertions" % failures)
    quit(0 if failures == 0 else 1)
