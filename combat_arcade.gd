extends Control
## Playable combat UI prototype. All controls are generated in code.
const Combat = preload("res://combat_rules.gd")
const OpponentAI = preload("res://combat_ai.gd")
var opponent_ai = OpponentAI.new()
var ai_enabled := true
var ai_toggle: Button
var game = Combat.new()
var title_label: Label
var status_label: Label
var history_label: Label
var actions: GridContainer
var restart_button: Button

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var backdrop := ColorRect.new()
    backdrop.color = Color("#101127")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var layout := VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 14)
    layout.offset_left = 55
    layout.offset_top = 30
    layout.offset_right = -55
    layout.offset_bottom = -30
    add_child(layout)
    title_label = Label.new()
    title_label.text = "APW: NO TEA PARTY!  //  ARCADE COMBAT"
    title_label.add_theme_font_size_override("font_size", 32)
    title_label.add_theme_color_override("font_color", Color("#ff4ac8"))
    layout.add_child(title_label)
    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 23)
    layout.add_child(status_label)
    var ring := ColorRect.new()
    ring.color = Color("#262a55")
    ring.custom_minimum_size = Vector2(0, 210)
    layout.add_child(ring)
    var ring_label := Label.new()
    ring_label.text = "  GIDEON HARK             VS             BIRDMAN PHIL PICASSO\n\n  [ WRESTLING RING — CHARACTER SPRITES PENDING ]"
    ring_label.add_theme_font_size_override("font_size", 23)
    ring.add_child(ring_label)
    actions = GridContainer.new()
    actions.columns = 3
    layout.add_child(actions)
    history_label = Label.new()
    history_label.add_theme_font_size_override("font_size", 18)
    layout.add_child(history_label)
    ai_toggle = Button.new()
    ai_toggle.text = "BIRDMAN AI: ON (TOGGLE FOR TWO PLAYERS)"
    ai_toggle.custom_minimum_size = Vector2(180, 50)
    ai_toggle.pressed.connect(_toggle_ai)
    layout.add_child(ai_toggle)
    restart_button = Button.new()
    restart_button.text = "RESTART MATCH"
    restart_button.custom_minimum_size = Vector2(180, 55)
    restart_button.pressed.connect(_restart)
    layout.add_child(restart_button)
    _refresh()

func _toggle_ai() -> void:
    ai_enabled = not ai_enabled
    ai_toggle.text = "BIRDMAN AI: ON" if ai_enabled else "TWO-PLAYER MODE"
    _run_ai_turns()
    _refresh()

func _run_ai_turns() -> void:
    var steps := 0
    while ai_enabled and not game.match_over and game.current_turn == 1 and steps < 8:
        var action: String = opponent_ai.choose_action(game)
        if action.is_empty() or not game.take_action(action):
            break
        steps += 1

func _restart() -> void:
    game = Combat.new()
    _refresh()

func _take_action(action: String) -> void:
    if game.take_action(action):
        _run_ai_turns()
        _refresh()

func _refresh() -> void:
    var a: Dictionary = game.wrestlers[0]
    var b: Dictionary = game.wrestlers[1]
    var turn_name: String = game.wrestlers[game.current_turn]["name"]
    var phase_text := "REFEREE COUNT: %d  |  %s" % [game.pin_count, turn_name]
    if game.match_over:
        phase_text = "WINNER: " + str(game.wrestlers[game.winner]["name"])
    status_label.text = "%s  HP %d  ST %d       |       %s  HP %d  ST %d\n%s" % [
        a["name"], a["health"], a["stamina"],
        b["name"], b["health"], b["stamina"],
        phase_text
    ]
    for child in actions.get_children():
        actions.remove_child(child)
        child.queue_free()
    for action in game.legal_actions():
        var button := Button.new()
        button.text = action.to_upper()
        button.custom_minimum_size = Vector2(250, 65)
        button.add_theme_font_size_override("font_size", 22)
        button.add_theme_color_override("font_color", Color("#65f4ff"))
        button.pressed.connect(_take_action.bind(action))
        actions.add_child(button)
    var last: Array[String] = game.log.slice(maxi(0, game.log.size() - 5))
    history_label.text = "\n".join(last)
