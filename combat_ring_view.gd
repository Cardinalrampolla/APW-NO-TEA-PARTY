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
    var approach := smoothstep(0.08, 0.30, elapsed)
    var contact := smoothstep(0.34, 0.64, elapsed)
    var reset := smoothstep(0.98, MOVE_TIME, elapsed)
    var hold := 1.0 - reset
    var centre := w * 0.5
    var l_tilt := 0.0
    var r_tilt := 0.0
    var l_arm := 0.0
    var r_arm := 0.0
    var l_lift := 0.0
    var r_lift := 0.0
    var left_fallen := false
    var right_fallen := false
    var impact := motion in ["strike", "grapple", "finisher"]
    if impact:
        if attacker == 0:
            left.x = lerpf(left.x, centre - 26.0, approach * hold)
            right.x = lerpf(right.x, centre + 29.0, approach * hold)
            l_arm = approach * hold
            if motion == "strike":
                r_tilt = 0.35 * contact * hold
            elif motion == "grapple":
                r_tilt = 1.40 * contact * hold
                right_fallen = contact > 0.7 and reset < 0.5
            else:
                r_tilt = 1.53 * contact * hold
                right_fallen = contact > 0.7 and reset < 0.5
                l_lift = 16.0 * sin(PI * clampf(elapsed / 0.75, 0.0, 1.0))
        else:
            right.x = lerpf(right.x, centre + 26.0, approach * hold)
            left.x = lerpf(left.x, centre - 29.0, approach * hold)
            r_arm = approach * hold
            if motion == "strike":
                l_tilt = -0.35 * contact * hold
            elif motion == "grapple":
                l_tilt = -1.40 * contact * hold
                left_fallen = contact > 0.7 and reset < 0.5
            else:
                # Birdman's double-underhook DDT: lock up, pull forward, head-first takedown.
                l_tilt = -1.53 * contact * hold
                left_fallen = contact > 0.7 and reset < 0.5
                r_lift = 13.0 * sin(PI * clampf(elapsed / 0.75, 0.0, 1.0))
    if pin_target != -1:
        if pin_target == 0:
            left_fallen = true
            left.x = centre - 20.0
            right.x = centre + 20.0
        else:
            right_fallen = true
            right.x = centre + 20.0
            left.x = centre - 20.0
    _fighter(left + Vector2(0, -l_lift), Color("#ff4ac8"), Color("#c99475"), l_tilt, false, l_arm, left_fallen)
    _fighter(right + Vector2(0, -r_lift), Color("#181a28"), Color("#d3a17d"), r_tilt, true, r_arm, right_fallen)
    if impact and elapsed >= 0.54 and elapsed < 0.83:
        var burst := clampf(1.0 - absf(elapsed - 0.66) / 0.15, 0.0, 1.0)
        draw_arc(Vector2(centre, ground - 35.0), 18.0 + 45.0 * burst, 0.0, TAU, 20, Color(1.0, 0.91, 0.26, burst), 5.0)
        for i in range(8):
            var direction := Vector2.RIGHT.rotated(float(i) * TAU / 8.0)
            draw_line(Vector2(centre, ground - 35.0) + direction * 24.0, Vector2(centre, ground - 35.0) + direction * (35.0 + 35.0 * burst), Color("#fff0a0", burst), 4.0)
    if pin_target != -1:
        var message := "PIN!"
        if count > 0:
            message = ["", "ONE!", "TWO!", "THREE!"][mini(count, 3)]
        draw_string(ThemeDB.fallback_font, Vector2(w * 0.45, 43), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#ffe86b"))
    if victor != -1:
        var winner_name := "GIDEON WINS!" if victor == 0 else "BIRDMAN WINS!"
        draw_string(ThemeDB.fallback_font, Vector2(w * 0.35, 83), winner_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("#6efaff"))

func _fighter(feet: Vector2, gear: Color, skin: Color, tilt: float, bald: bool, arm_reach: float, fallen: bool) -> void:
    # Articulated local-space rig. The entire body rotates together on takedown.
    # When down, shoulders/head lie on the canvas instead of hovering above it.
    var angle := tilt
    if fallen:
        angle = -PI * 0.5 if tilt <= 0.0 else PI * 0.5
    var origin := feet + Vector2(0.0, -12.0)
    if fallen:
        origin.y -= 10.0
    var facing := 1.0 if bald else -1.0
    var hip := Vector2(0, -26)
    var shoulder := Vector2(0, -79)
    var head := Vector2(0, -106)
    var foot_l := Vector2(-15, 12)
    var foot_r := Vector2(15, 12)
    var elbow_l := Vector2(-30, -60)
    var elbow_r := Vector2(30, -60)
    var hand_l := Vector2(-37, -42)
    var hand_r := Vector2(37, -42)
    if arm_reach > 0.0:
        hand_l += Vector2(-facing * 28.0 * arm_reach, -18.0 * arm_reach)
        hand_r += Vector2(-facing * 28.0 * arm_reach, -18.0 * arm_reach)
    var transform := Transform2D(angle, origin)
    var h := transform * hip
    var sh := transform * shoulder
    var hd := transform * head
    draw_line(h, transform * foot_l, gear.darkened(0.22), 15.0, true)
    draw_line(h, transform * foot_r, gear.darkened(0.22), 15.0, true)
    draw_line(transform * Vector2(-16, -75), transform * elbow_l, skin, 12.0, true)
    draw_line(transform * elbow_l, transform * hand_l, skin, 10.0, true)
    draw_line(transform * Vector2(16, -75), transform * elbow_r, skin, 12.0, true)
    draw_line(transform * elbow_r, transform * hand_r, skin, 10.0, true)
    draw_line(h, sh, gear, 39.0, true)
    if not bald:
        for stripe in [-11.0, 0.0, 11.0]:
            draw_line(transform * Vector2(stripe, -40), transform * Vector2(stripe, -70), Color("#ff93d4"), 4.0)
        draw_circle(hd + Vector2(-5, -4), 20.0, Color("#49302b"))
    draw_circle(hd, 16.0, skin)
    if bald:
        draw_line(hd + Vector2(-7, 11), hd + Vector2(7, 11), Color("#432726"), 4.0)
