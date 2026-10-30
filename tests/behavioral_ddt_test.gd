extends SceneTree

const Prototype = preload("res://main.gd")

var checks_run := 0
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var demo = Prototype.new()
    root.add_child(demo)
    demo.set_process(false)

    _check_seek_boundaries(demo)
    _check_reduced_motion_impact(demo)
    _check_impact_and_hitstop(demo)
    _check_interruption_release(demo)
    _check_replay_reset_and_recovery(demo)

    if failures == 0:
        print("PASS behavioral DDT regression (%d checks)" % checks_run)
        quit(0)
    else:
        push_error("FAIL behavioral DDT regression: %d of %d checks failed" % [failures, checks_run])
        quit(1)

func _check_seek_boundaries(demo) -> void:
    demo.seek_to(-1.0)
    _check(is_equal_approx(demo.elapsed, 0.0), "negative seek clamps to timeline start")
    _check(not demo.impact_triggered, "pre-impact seek does not arm impact")
    _check(not demo.playing and demo.inspection_paused, "seek pauses playback")
    demo.seek_to(demo.IMPACT_AT)
    _check(is_equal_approx(demo.elapsed, demo.IMPACT_AT), "seek lands on requested impact frame")
    _check(demo.impact_triggered, "impact seek disarms playback event")
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "timeline seek does not trigger hitstop")
    demo.seek_to(demo.DURATION + 1.0)
    _check(is_equal_approx(demo.elapsed, demo.DURATION), "end seek clamps to timeline duration")
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "end seek leaves no hitstop")

func _check_reduced_motion_impact(demo) -> void:
    demo.restart()
    demo.reduced_motion = true
    demo.elapsed = demo.IMPACT_AT - 0.01
    demo._process(0.02)
    _check(demo.impact_triggered, "reduced-motion playback still registers impact")
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "reduced motion skips impact hitstop")
    demo._process(0.01)
    _check(demo.elapsed > demo.IMPACT_AT, "reduced-motion playback advances past impact")

func _check_impact_and_hitstop(demo) -> void:
    demo.restart()
    demo.reduced_motion = false
    demo.elapsed = demo.IMPACT_AT - 0.01
    demo._process(0.02)
    _check(demo.impact_triggered, "crossing impact registers the event")
    _check(is_equal_approx(demo.elapsed, demo.IMPACT_AT), "impact crossing holds the contact frame")
    _check(is_equal_approx(demo.hitstop_remaining, demo.HITSTOP_SECONDS), "impact starts one configured hitstop")
    demo._process(demo.HITSTOP_SECONDS + 0.001)
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "hitstop expires")
    demo._process(0.01)
    _check(demo.elapsed > demo.IMPACT_AT, "animation progresses after hitstop")
    _check(demo.impact_triggered, "impact remains registered for the playback")
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "same playback does not refreeze")

func _check_interruption_release(demo) -> void:
    demo.restart()
    demo.reduced_motion = false
    demo.elapsed = demo.IMPACT_AT - 0.01
    demo._process(0.02)
    _check(demo.hitstop_remaining > 0.0, "interruption starts during active hitstop")
    demo.seek_to(0.0)
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "seek interruption releases hitstop")
    _check(not demo.playing and demo.inspection_paused, "seek interruption remains paused")
    demo.restart()
    _check(is_equal_approx(demo.hitstop_remaining, 0.0), "restart interruption releases hitstop")
    _check(demo.playing and not demo.inspection_paused, "restart resumes from a clean playback state")

func _check_replay_reset_and_recovery(demo) -> void:
    for run_index in range(2):
        demo.elapsed = demo.IMPACT_AT + 0.1
        demo.hitstop_remaining = 0.01
        demo.impact_triggered = true
        demo.restart()
        _check(is_equal_approx(demo.elapsed, 0.0), "replay %d resets pose-driving time" % run_index)
        _check(is_equal_approx(demo.hitstop_remaining, 0.0), "replay %d clears leftover hitstop" % run_index)
        _check(not demo.impact_triggered, "replay %d rearms the impact event" % run_index)
        demo.reduced_motion = true
        demo.elapsed = demo.IMPACT_AT + 0.1
        demo.impact_triggered = true
        demo._process(demo.DURATION)
        _check(is_equal_approx(demo.elapsed, demo.DURATION), "replay %d reaches recovery end" % run_index)
        _check(not demo.playing, "replay %d stops after recovery" % run_index)

func _check(condition: bool, label: String) -> void:
    checks_run += 1
    if condition:
        print("PASS ", label)
    else:
        failures += 1
        push_error("FAIL " + label)
