extends SceneTree
const Combat = preload("res://combat_rules.gd")
var passed := 0
var failed := 0

func _initialize() -> void:
    call_deferred("run_tests")

func check(ok: bool, name: String) -> void:
    if ok:
        passed += 1
    else:
        failed += 1
        printerr("FAIL: " + name)

func run_tests() -> void:
    var game = Combat.new()
    check(game.legal_actions().has("strike"), "strike available")
    check(game.take_action("strike"), "strike succeeds")
    check(game.wrestlers[1]["health"] == 91, "strike damages once")
    check(game.current_turn == 1, "turn switches")
    check(not game.take_action("pin"), "early pin blocked")
    check(game.take_action("grapple"), "grapple succeeds")
    check(game.wrestlers[0]["health"] == 84, "grapple damages once")
    check(game.take_action("finisher"), "finisher succeeds")
    check(game.wrestlers[1]["health"] == 59, "finisher damages once")
    check(game.wrestlers[1]["stunned"] == 1, "finisher stuns")
    check(game.legal_actions() == ["recover"], "stunned wrestler must recover")
    check(game.take_action("recover"), "stun recovery succeeds")
    check(game.wrestlers[1]["stunned"] == 0, "stun cleared")
    var pin_game = Combat.new()
    pin_game.wrestlers[1]["health"] = 0
    check(pin_game.take_action("pin"), "pin allowed on downed opponent")
    check(pin_game.legal_actions() == ["kickout"], "defender kickout phase")
    check(pin_game.take_action("kickout"), "downed defender attempts kickout")
    check(pin_game.pin_target == 1, "downed defender cannot escape")
    check(pin_game.take_action("count"), "referee count one")
    check(pin_game.pin_count == 1, "one count")
    check(pin_game.take_action("kickout"), "second kickout attempt")
    check(pin_game.take_action("count"), "referee count two")
    check(pin_game.pin_count == 2, "two count")
    check(pin_game.take_action("kickout"), "third kickout attempt")
    check(pin_game.take_action("count"), "referee count three")
    check(pin_game.match_over and pin_game.winner == 0, "pinfall winner")
    check(pin_game.legal_actions().is_empty(), "finished match blocks actions")
    var escape_game = Combat.new()
    escape_game.wrestlers[1]["health"] = 25
    check(escape_game.take_action("pin"), "low-health pin allowed")
    check(escape_game.take_action("kickout"), "live wrestler kicks out")
    check(escape_game.pin_target == -1, "kickout ends pin")
    check(escape_game.current_turn == 1, "kickout gives defender next turn")
    check(not escape_game.take_action("finisher") or escape_game.wrestlers[1]["health"] <= 100, "finisher is gated by stamina")
    print("APW combat rules: %d passed, %d failed" % [passed, failed])
    quit(0 if failed == 0 else 1)
