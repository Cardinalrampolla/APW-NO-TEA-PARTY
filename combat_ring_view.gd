extends Control
## Procedural wrestling silhouettes: temporary art, but actual in-ring motion.
var motion := ""
var attacker := 0
var elapsed := 2.0
var pin_target := -1
var count := 0
var victor := -1

func play_move(action: String, actor: int, target: int, referee_count: int, winner: int) -> void:
    motion = action
    attacker = actor
    pin_target = target
    count = referee_count
    victor = winner
    elapsed = 0.0
    queue_redraw()

func _process(delta: float) -> void:
    if elapsed < 1.0:
        elapsed = minf(elapsed + delta, 1.0)
        queue_redraw()

func _draw() -> void:
    var w := size.x
    var h := size.y
    if w < 100.0 or h < 100.0:
        return
    draw_rect(Rect2(0, 0, w, h), Color("#202449"))
    draw_rect(Rect2(12, 35, w - 24, h - 48), Color("#414b83"))
    draw_rect(Rect2(20, 48, w - 40, h - 70), Color("#6879aa"))
    for yy in [58.0, 92.0, 126.0]:
        draw_line(Vector2(8, yy), Vector2(w - 8, yy), Color("#fa4bb8"), 4.0)
    var ground := h - 26.0
    var left := Vector2(w * 0.32, ground)
    var right := Vector2(w * 0.68, ground)
    var impact := motion in ["strike", "grapple", "finisher"]
    var progress := clampf(elapsed / 0.55, 0.0, 1.0)
    var l_tilt := 0.0
    var r_tilt := 0.0
    if impact:
        var dash := sin(progress * PI) * minf(w * 0.13, 90.0)
        if attacker == 0:
            left.x += dash
            r_tilt = progress * (1.45 if motion == "finisher" else 0.55)
        else:
            right.x -= dash
            l_tilt = -progress * (1.45 if motion == "finisher" else 0.55)
    if pin_target != -1:
        if pin_target == 0:
            l_tilt = -1.45
            left.y += 9.0
            right.x = left.x + 42.0
        else:
            r_tilt = 1.45
            right.y += 9.0
            left.x = right.x - 42.0
    _fighter(left, Color("#ff4ac8"), Color("#3c354b"), l_tilt, false)
    _fighter(right, Color("#181a28"), Color("#d3a17d"), r_tilt, true)
    if impact and elapsed < 0.65:
        var burst := 1.0 - absf(elapsed - 0.3) / 0.35
        burst = clampf(burst, 0.0, 1.0)
        draw_arc((left + right) * 0.5 + Vector2(0, -55), 24 + 35 * burst, 0, TAU, 18, Color(1.0, 0.9, 0.3, burst), 5.0)
    if pin_target != -1:
        var message := "PIN!"
        if count > 0:
            message = ["", "ONE!", "TWO!", "THREE!"][mini(count, 3)]
        draw_string(ThemeDB.fallback_font, Vector2(w * 0.45, 43), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#ffe86b"))
    if victor != -1:
        var winner_name := "GIDEON WINS!" if victor == 0 else "BIRDMAN WINS!"
        draw_string(ThemeDB.fallback_font, Vector2(w * 0.35, 83), winner_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("#6efaff"))

func _fighter(feet: Vector2, gear: Color, skin: Color, tilt: float, bald: bool) -> void:
    var torso := feet + Vector2(0, -52)
    var pivot := torso
    var lean := Vector2(sin(tilt) * 48.0, (1.0 - cos(tilt)) * 40.0)
    torso += lean
    var head := torso + Vector2(0, -41)
    draw_line(feet + Vector2(-12, 0), torso + Vector2(-13, 13), gear, 15.0, true)
    draw_line(feet + Vector2(13, 0), torso + Vector2(13, 13), gear, 15.0, true)
    draw_line(torso + Vector2(-15, -18), torso + Vector2(-34, 9), skin, 11.0, true)
    draw_line(torso + Vector2(15, -18), torso + Vector2(34, 9), skin, 11.0, true)
    draw_rect(Rect2(torso - Vector2(20, 35), Vector2(40, 48)), gear)
    if not bald:
        for i in range(3):
            draw_line(head + Vector2(-15 + i * 15, -6), head + Vector2(-17 + i * 15, 19), Color("#50302d"), 7.0)
        for i in range(3):
            draw_line(torso + Vector2(-15 + i * 15, -30), torso + Vector2(-15 + i * 15, 8), Color("#ff89d7"), 4.0)
    else:
        draw_line(torso + Vector2(-13, -26), torso + Vector2(14, -9), Color("#b64555"), 4.0)
    draw_circle(head, 16.0, skin)
