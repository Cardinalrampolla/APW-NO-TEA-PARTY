extends Control
## Procedural wrestling silhouettes: temporary art, but actual in-ring motion.
var motion := ""
var attacker := 0
var elapsed := 2.0
const MOVE_TIME := 1.25
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
    if elapsed < MOVE_TIME:
        elapsed = minf(elapsed + delta, MOVE_TIME)
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
    var approach := smoothstep(0.05, 0.34, elapsed)
    var contact := smoothstep(0.36, 0.62, elapsed)
    var recovery := smoothstep(0.92, MOVE_TIME, elapsed)
    var contact_x := w * 0.50
    var l_tilt := 0.0
    var r_tilt := 0.0
    var l_arm := 0.0
    var r_arm := 0.0
    var l_lift := 0.0
    var r_lift := 0.0
    if impact:
        var active := 1.0 - recovery
        if attacker == 0:
            left.x = lerpf(left.x, contact_x - 31.0, approach * active)
            right.x = lerpf(right.x, contact_x + 34.0, contact * active)
            l_arm = approach * active
            if motion == "strike":
                r_tilt = contact * 0.65 * active
            elif motion == "grapple":
                r_tilt = contact * 1.20 * active
                r_lift = contact * 12.0 * active
            else:
                r_tilt = contact * 1.53 * active
                r_lift = contact * 22.0 * active
        else:
            right.x = lerpf(right.x, contact_x + 31.0, approach * active)
            left.x = lerpf(left.x, contact_x - 34.0, contact * active)
            r_arm = approach * active
            if motion == "strike":
                l_tilt = -contact * 0.65 * active
            elif motion == "grapple":
                l_tilt = -contact * 1.20 * active
                l_lift = contact * 12.0 * active
            else:
                l_tilt = -contact * 1.53 * active
                l_lift = contact * 22.0 * active
    if pin_target != -1:
        if pin_target == 0:
            l_tilt = -1.53
            left.y += 10.0
            right.x = left.x + 43.0
        else:
            r_tilt = 1.53
            right.y += 10.0
            left.x = right.x - 43.0
    _fighter(left + Vector2(0, -l_lift), Color("#ff4ac8"), Color("#c99475"), l_tilt, false, l_arm)
    _fighter(right + Vector2(0, -r_lift), Color("#181a28"), Color("#d3a17d"), r_tilt, true, r_arm)
    if impact and elapsed >= 0.44 and elapsed < 0.76:
        var burst := 1.0 - absf(elapsed - 0.56) / 0.16
        burst = clampf(burst, 0.0, 1.0)
        draw_arc(Vector2(contact_x, ground - 55), 22.0 + 45.0 * burst, 0, TAU, 20, Color(1.0, 0.91, 0.26, burst), 5.0)
    if pin_target != -1:
        var message := "PIN!"
        if count > 0:
            message = ["", "ONE!", "TWO!", "THREE!"][mini(count, 3)]
        draw_string(ThemeDB.fallback_font, Vector2(w * 0.45, 43), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#ffe86b"))
    if victor != -1:
        var winner_name := "GIDEON WINS!" if victor == 0 else "BIRDMAN WINS!"
        draw_string(ThemeDB.fallback_font, Vector2(w * 0.35, 83), winner_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("#6efaff"))

func _fighter(feet: Vector2, gear: Color, skin: Color, tilt: float, bald: bool, arm_reach: float) -> void:
    var torso := feet + Vector2(0, -52)
    var lean := Vector2(sin(tilt) * 48.0, (1.0 - cos(tilt)) * 40.0)
    torso += lean
    var head := torso + Vector2(0, -41)
    draw_line(feet + Vector2(-12, 0), torso + Vector2(-13, 13), gear, 15.0, true)
    draw_line(feet + Vector2(13, 0), torso + Vector2(13, 13), gear, 15.0, true)
    var arm_offset := 42.0 * arm_reach
    draw_line(torso + Vector2(-15, -18), torso + Vector2(-34 - arm_offset, 9 - arm_offset * 0.65), skin, 11.0, true)
    draw_line(torso + Vector2(15, -18), torso + Vector2(34 + arm_offset, 9 - arm_offset * 0.65), skin, 11.0, true)
    draw_rect(Rect2(torso - Vector2(20, 35), Vector2(40, 48)), gear)
    if not bald:
        for i in range(3):
            draw_line(head + Vector2(-15 + i * 15, -6), head + Vector2(-17 + i * 15, 19), Color("#50302d"), 7.0)
        for i in range(3):
            draw_line(torso + Vector2(-15 + i * 15, -30), torso + Vector2(-15 + i * 15, 8), Color("#ff89d7"), 4.0)
    else:
        draw_line(torso + Vector2(-13, -26), torso + Vector2(14, -9), Color("#b64555"), 4.0)
    draw_circle(head, 16.0, skin)
