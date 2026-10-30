extends Node2D
## Isolated, non-destructive APW finisher choreography prototype.
## Uses procedural stand-in silhouettes. Not final character sprites.

const W := 1280.0
const H := 720.0
const DURATION := 2.6
var elapsed := 0.0
var playing := false
var shake := 0.0
var reduced_motion := false
var frame_count := 0
# Timeline inspection controls. All choreography uses virtual time so seeking is deterministic.
const STEP := 1.0 / 30.0
const IMPACT_AT := 1.63
const HITSTOP_SECONDS := 0.085
var inspection_paused := false
var playback_speed := 1.0
var hitstop_remaining := 0.0
var impact_triggered := false
var show_debug := true

func _ready() -> void:
    set_process(true)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        restart()
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_R:
                reduced_motion = not reduced_motion
            KEY_P:
                inspection_paused = not inspection_paused
            KEY_LEFT:
                seek_to(elapsed - STEP)
            KEY_RIGHT:
                seek_to(elapsed + STEP)
            KEY_HOME:
                seek_to(0.0)
            KEY_END:
                seek_to(DURATION)
            KEY_1:
                playback_speed = 0.5
            KEY_2:
                playback_speed = 1.0
            KEY_3:
                playback_speed = 1.5
            KEY_D:
                show_debug = not show_debug
        queue_redraw()

func seek_to(t: float) -> void:
    elapsed = clampf(t, 0.0, DURATION)
    playing = false
    inspection_paused = true
    hitstop_remaining = 0.0
    impact_triggered = elapsed >= IMPACT_AT
    queue_redraw()

func restart() -> void:
    elapsed = 0.0
    shake = 0.0
    playing = true
    inspection_paused = false
    hitstop_remaining = 0.0
    impact_triggered = false
    queue_redraw()

func _process(delta: float) -> void:
    if playing and not inspection_paused:
        if hitstop_remaining > 0.0:
            hitstop_remaining = maxf(0.0, hitstop_remaining - delta)
        else:
            var previous := elapsed
            elapsed = minf(elapsed + delta * playback_speed, DURATION)
            if not impact_triggered and previous < IMPACT_AT and elapsed >= IMPACT_AT:
                elapsed = IMPACT_AT
                impact_triggered = true
                if not reduced_motion:
                    hitstop_remaining = HITSTOP_SECONDS
            if elapsed >= DURATION:
                playing = false
        frame_count += 1
        queue_redraw()

func phase_at(t: float) -> String:
    if t < 0.42: return "APPROACH"
    if t < 0.92: return "DOUBLE UNDERHOOK"
    if t < 1.24: return "HOLD / ANTICIPATION"
    if t < 1.63: return "DDT DROP"
    if t < 1.88: return "IMPACT"
    return "RECOVERY"

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(W, H)), Color("11142c"))
    for i in range(13):
        var x := float(i) * 108.0
        draw_line(Vector2(x, 120), Vector2(x + 44, 530), Color("22264e"), 3.0)
    draw_rect(Rect2(85, 390, 1110, 238), Color("303d78"))
    draw_rect(Rect2(115, 417, 1050, 183), Color("6977c1"))
    for y in [410.0, 450.0, 490.0]:
        draw_line(Vector2(65, y), Vector2(1215, y), Color("f442a8"), 6.0)
    var t := elapsed
    var phase := phase_at(t)
    var attacker := Vector2(500, 475)
    var defender := Vector2(760, 475)
    var opponent_angle := 0.0
    var attacker_angle := 0.0
    if t >= 0.42:
        defender.x = lerpf(760, 600, clampf((t - 0.42) / 0.5, 0, 1))
        attacker.x = 520
    if t >= 0.92:
        defender.y = lerpf(475, 425, clampf((t - 0.92) / 0.32, 0, 1))
    if t >= 1.24:
        var drop := clampf((t - 1.24) / 0.39, 0, 1)
        opponent_angle = drop * 1.45
        attacker_angle = drop * 0.62
        defender.y = lerpf(425, 525, drop * drop)
        attacker.y = lerpf(475, 530, drop)
    if t >= 1.63:
        defender.y = 525
        attacker.y = 530
        opponent_angle = 1.45
        attacker_angle = 0.62
    var offset := Vector2.ZERO
    if t >= 1.63 and t < 1.88 and not reduced_motion:
        var intensity := 1.0 - (t - 1.63) / 0.25
        offset = Vector2(sin(t * 180) * 13, cos(t * 160) * 8) * intensity
    _wrestler(attacker + offset, Color("d89065"), Color("15151b"), attacker_angle, true)
    _wrestler(defender + offset, Color("e3ae85"), Color("34d8f5"), opponent_angle, false)
    if t >= 1.63 and t < 1.88 and not reduced_motion:
        var alpha := 0.65 * (1.0 - (t - 1.63) / 0.25)
        draw_circle(Vector2(610, 530) + offset, 95 * (1.0 - alpha), Color(1, 0.85, 0.2, alpha))
    # A timeline ruler makes each animation beat inspectable at 30 fps.
    var bar := Rect2(125, 632, 1030, 10)
    draw_rect(bar, Color("171a35"))
    for boundary in [0.42, 0.92, 1.24, IMPACT_AT, 1.88]:
        var marker_x: float = bar.position.x + bar.size.x * boundary / DURATION
        draw_line(Vector2(marker_x, 625), Vector2(marker_x, 648), Color("ffe26b"), 2.0)
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * elapsed / DURATION, bar.size.y)), Color("35d7ed"))
    draw_circle(Vector2(bar.position.x + bar.size.x * elapsed / DURATION, 637), 8, Color.WHITE)
    draw_rect(Rect2(0, 0, W, 95), Color("090b1d"))
    draw_string(ThemeDB.fallback_font, Vector2(40, 43), "APW: NO TEA PARTY! | BIRDMAN DDT PROTOTYPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("f542aa"))
    draw_string(ThemeDB.fallback_font, Vector2(40, 77), "PHASE: " + phase + "  |  SPACE: REPLAY  |  P: PAUSE  |  ARROWS: FRAME STEP", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
    if show_debug:
        var status := "PAUSED" if inspection_paused else ("PLAYING" if playing else "STOPPED")
        var metrics := "TIME %.3fs / %.2fs | FRAME %d | %s | SPEED %.1fx | HITSTOP %.0fms" % [elapsed, DURATION, int(round(elapsed * 30.0)), status, playback_speed, hitstop_remaining * 1000.0]
        draw_string(ThemeDB.fallback_font, Vector2(105, 610), metrics, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f3f4ff"))
        draw_string(ThemeDB.fallback_font, Vector2(105, 699), "LEFT/RIGHT: 1/30s  |  HOME/END: SEEK  |  1/2/3: SPEED  |  D: DEBUG  |  R: REDUCED MOTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c5d5fa"))
    draw_string(ThemeDB.fallback_font, Vector2(40, 676), "PROCEDURAL PLACEHOLDERS - NOT FINAL BIRDMAN ART", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("ffe26b"))

func _wrestler(pos: Vector2, skin: Color, gear: Color, angle: float, birdman: bool) -> void:
    # All positions are relative to the feet, rotated around the torso pivot.
    var pivot := pos + Vector2(0, -85)
    var c := cos(angle)
    var s := sin(angle)
    var p := func(v: Vector2) -> Vector2:
        var d := v - Vector2(0, -85)
        return pivot + Vector2(d.x * c - d.y * s, d.x * s + d.y * c)
    draw_line(p.call(Vector2(-18, -65)), p.call(Vector2(-25, 0)), gear, 22, true)
    draw_line(p.call(Vector2(18, -65)), p.call(Vector2(26, 0)), gear, 22, true)
    draw_line(p.call(Vector2(-38, -145)), p.call(Vector2(-57, -86)), skin, 20, true)
    draw_line(p.call(Vector2(38, -145)), p.call(Vector2(55, -86)), skin, 20, true)
    draw_colored_polygon(PackedVector2Array([p.call(Vector2(-38,-158)), p.call(Vector2(38,-158)), p.call(Vector2(33,-66)), p.call(Vector2(-33,-66))]), gear)
    draw_circle(p.call(Vector2(0, -188)), 27, skin)
    if birdman:
        draw_line(p.call(Vector2(-21, -145)), p.call(Vector2(20, -120)), Color("ef4f91"), 5, true)
