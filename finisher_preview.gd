extends Node2D
## Playable timing preview for 10 APW finishers.
## Procedural stand-ins only; photo-based SNES sprites remain outstanding.
const FinisherTiming = preload("res://finisher_timing.gd")
const W := 1280.0
const H := 720.0
const SECONDS := 2.5
const MOVE_IDS := [
    "birdman_double_underhook_ddt",
    "bruza_russian_leg_sweep",
    "nikki_running_cannonball",
    "simon_chokeslam",
    "gideon_ripcord_clothesline",
    "johnny_the_stroke",
    "tnt_unprettier",
    "whiskey_450_splash",
    "eli_five_star_frog_splash",
    "al_drum_finisher",
]
# Five spatial poses per move: attacker (x,y), defender (x,y), body angles in radians.
# The poses are authored independently, not repeated timing-only placeholders.
const POSES := [
    [[450,475,780,475,0,0],[520,475,635,475,0,0],[530,475,605,435,0,0],[545,530,610,525,0.6,1.4],[540,500,645,535,0,1.4]],
    [[470,475,760,475,0,0],[525,475,620,475,0,0],[540,485,610,485,0,0],[540,530,625,530,1.1,1.2],[525,505,660,540,0,1.4]],
    [[300,475,800,475,0,0],[470,475,800,475,0,0],[650,425,790,475,-0.6,0],[790,495,805,530,1.2,1.4],[825,510,810,540,0,1.4]],
    [[465,475,750,475,0,0],[520,475,620,475,0,0],[540,475,605,330,0,0],[550,515,615,535,0.2,1.5],[530,480,665,540,0,1.5]],
    [[450,475,770,475,0,0],[525,475,680,475,0,0],[570,475,625,475,0,0],[615,490,645,530,0.3,1.4],[590,475,695,540,0,1.5]],
    [[465,475,760,475,0,0],[530,475,635,475,0,0],[545,475,615,455,0,0],[550,525,625,530,0.9,1.4],[535,505,675,540,0,1.4]],
    [[455,475,755,475,0,0],[535,475,635,475,0,0],[560,475,610,475,0,0],[565,520,620,530,0.9,1.4],[550,500,670,540,0,1.4]],
    [[360,330,785,530,0,1.5],[450,300,785,530,0,1.5],[615,250,785,530,3.0,1.5],[785,505,785,530,6.0,1.5],[830,500,790,540,0,1.5]],
    [[360,330,785,530,0,1.5],[470,295,785,530,0,1.5],[635,325,785,530,-0.4,1.5],[785,505,785,530,0.9,1.5],[835,500,785,540,0,1.5]],
    [[470,475,765,475,0,0],[525,475,660,475,0,0],[550,475,620,475,0,0],[570,475,625,530,0.1,1.4],[555,475,675,540,0,1.5]],
]
var selected := 0
var elapsed := 0.0
var running := true
var reduced_motion := false
var impact_count := 0
var last_beat := -1

func _ready() -> void:
    set_process(true)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_RIGHT:
            selected = (selected + 1) % MOVE_IDS.size()
            reset_preview()
        elif event.keycode == KEY_LEFT:
            selected = (selected + MOVE_IDS.size() - 1) % MOVE_IDS.size()
            reset_preview()
        elif event.keycode == KEY_SPACE:
            reset_preview()
        elif event.keycode == KEY_P:
            running = not running
        elif event.keycode == KEY_R:
            reduced_motion = not reduced_motion
        queue_redraw()

func reset_preview() -> void:
    elapsed = 0.0
    impact_count = 0
    last_beat = -1
    running = true

func _process(delta: float) -> void:
    if running:
        elapsed = minf(SECONDS, elapsed + maxf(0.0, delta))
        var current := beat_index(elapsed / SECONDS)
        if current >= 3 and last_beat < 3:
            impact_count += 1
        last_beat = current
        if elapsed >= SECONDS:
            running = false
        queue_redraw()

func beat_index(progress: float) -> int:
    var beats: Array = FinisherTiming.get_move(MOVE_IDS[selected])["beats"]
    var index := 0
    for i in range(beats.size()):
        if progress >= float(beats[i]["at"]):
            index = i
    return index

func interpolated_pose(progress: float) -> Array:
    var beats: Array = FinisherTiming.get_move(MOVE_IDS[selected])["beats"]
    var index := beat_index(progress)
    var current: Array = POSES[selected][index]
    if index == 4:
        return current
    var next: Array = POSES[selected][index + 1]
    var begin: float = beats[index]["at"]
    var end: float = beats[index + 1]["at"]
    var alpha := clampf((progress - begin) / (end - begin), 0.0, 1.0)
    # Smooth acceleration/deceleration between authored spatial poses.
    alpha = alpha * alpha * (3.0 - 2.0 * alpha)
    var result: Array = []
    for i in range(6):
        result.append(lerpf(float(current[i]), float(next[i]), alpha))
    return result

func _draw() -> void:
    draw_rect(Rect2(0, 0, W, H), Color("10132a"))
    draw_rect(Rect2(90, 365, 1100, 255), Color("374476"))
    draw_rect(Rect2(115, 390, 1050, 195), Color("7380c6"))
    for y in [390.0, 440.0, 490.0]:
        draw_line(Vector2(65, y), Vector2(1215, y), Color("f642a4"), 5.0)
    var progress := clampf(elapsed / SECONDS, 0.0, 1.0)
    var pose := interpolated_pose(progress)
    var shake := Vector2.ZERO
    if beat_index(progress) == 3 and not reduced_motion:
        shake = Vector2(sin(elapsed * 150.0) * 5.0, cos(elapsed * 120.0) * 4.0)
    draw_wrestler(Vector2(pose[0], pose[1]) + shake, float(pose[4]), Color("ed9c6a"), Color("1b1a28"))
    draw_wrestler(Vector2(pose[2], pose[3]) + shake, float(pose[5]), Color("e7b18a"), Color("2be2f4"))
    if beat_index(progress) == 3 and not reduced_motion:
        draw_arc(Vector2(pose[2], pose[3]) + shake, 72, 0.0, TAU, 24, Color("ffda54"), 7.0)
    var move: Dictionary = FinisherTiming.get_move(MOVE_IDS[selected])
    draw_rect(Rect2(0, 0, W, 115), Color("080c20"))
    draw_string(ThemeDB.fallback_font, Vector2(32, 43), "APW: NO TEA PARTY! | FINISHER PREVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("ff48aa"))
    draw_string(ThemeDB.fallback_font, Vector2(32, 86), str(move["wrestler"]) + " — " + str(move["move"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)
    draw_rect(Rect2(120, 638, 1040, 12), Color("232847"))
    draw_rect(Rect2(120, 638, 1040 * progress, 12), Color("34e3f3"))
    for beat in move["beats"]:
        var x: float = 120.0 + 1040.0 * float(beat["at"])
        draw_line(Vector2(x, 630), Vector2(x, 656), Color("ffdb57"), 3.0)
    var status := "PLAYING" if running else "PAUSED / FINISHED"
    draw_string(ThemeDB.fallback_font, Vector2(80, 685), "LEFT/RIGHT: MOVE  SPACE: REPLAY  P: PAUSE  R: REDUCED MOTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(80, 710), "BEAT %d/5 | IMPACT EVENTS %d | %s | PLACEHOLDER ART" % [beat_index(progress) + 1, impact_count, status], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffdb57"))

func draw_wrestler(feet: Vector2, angle: float, skin: Color, gear: Color) -> void:
    var pivot := feet + Vector2(0, -85)
    var c := cos(angle)
    var s := sin(angle)
    var p := func(v: Vector2) -> Vector2:
        var d := v - Vector2(0, -85)
        return pivot + Vector2(d.x * c - d.y * s, d.x * s + d.y * c)
    draw_line(p.call(Vector2(-19, -67)), p.call(Vector2(-25, 0)), gear, 22.0, true)
    draw_line(p.call(Vector2(19, -67)), p.call(Vector2(25, 0)), gear, 22.0, true)
    draw_line(p.call(Vector2(-35, -140)), p.call(Vector2(-55, -86)), skin, 20.0, true)
    draw_line(p.call(Vector2(35, -140)), p.call(Vector2(55, -86)), skin, 20.0, true)
    draw_colored_polygon(PackedVector2Array([p.call(Vector2(-35, -150)), p.call(Vector2(35, -150)), p.call(Vector2(32, -66)), p.call(Vector2(-32, -66))]), gear)
    draw_circle(p.call(Vector2(0, -183)), 25.0, skin)
