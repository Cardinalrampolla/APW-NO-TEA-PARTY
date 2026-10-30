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
    check(pin_game.legal_actions() == ["count"], "attacker starts referee count")
    check(pin_game.take_action("count"), "referee counts one before kickout")
    check(pin_game.take_action("kickout"), "downed defender attempts kickout")
    check(pin_game.pin_target == 1, "downed defender cannot escape")
    check(pin_game.pin_count == 1, "one count")
    check(pin_game.take_action("count"), "referee count two")
    check(pin_game.pin_count == 2, "two count")
    check(pin_game.take_action("kickout"), "third kickout attempt")
    check(pin_game.take_action("count"), "referee count three")
    check(pin_game.match_over and pin_game.winner == 0, "pinfall winner")
    check(pin_game.legal_actions().is_empty(), "finished match blocks actions")
    var escape_game = Combat.new()
    escape_game.wrestlers[1]["health"] = 25
    check(escape_game.take_action("pin"), "low-health pin allowed")
    check(escape_game.take_action("count"), "referee starts live-health pin")
    check(escape_game.take_action("kickout"), "live wrestler kicks out")
    check(escape_game.pin_target == -1, "kickout ends pin")
    check(escape_game.current_turn == 1, "kickout gives defender next turn")
    var boundary = Combat.new()
    boundary.wrestlers[0]["stamina"] = 34
    var before = boundary.state()
    check(not boundary.legal_actions().has("finisher"), "34 stamina hides finisher")
    check(not boundary.take_action("finisher"), "34 stamina rejects finisher")
    check(boundary.state() == before, "rejected finisher does not mutate state")
    boundary.wrestlers[0]["stamina"] = 35
    check(boundary.legal_actions().has("finisher"), "35 stamina exposes finisher")
    check(boundary.take_action("finisher"), "35 stamina accepts finisher")
    check(boundary.wrestlers[0]["stamina"] == 0, "finisher spends exactly 35")
    check(boundary.wrestlers[1]["health"] == 68, "finisher deals exactly 32")
    for stamina in [0, 7, 8, 17, 18, 34, 35, 100]:
        var probe = Combat.new()
        probe.wrestlers[0]["stamina"] = stamina
        check(probe.legal_actions().has("strike") == (stamina >= 8), "strike cost at %d" % stamina)
        check(probe.legal_actions().has("grapple") == (stamina >= 18), "grapple cost at %d" % stamina)
        check(probe.legal_actions().has("finisher") == (stamina >= 35), "finisher cost at %d" % stamina)
        check(probe.legal_actions().has("recover"), "recovery always available at %d" % stamina)
    for count in [0, 1, 2]:
        var escape_at_count = Combat.new()
        escape_at_count.wrestlers[1]["health"] = 25
        escape_at_count.take_action("pin")
        escape_at_count.pin_count = count
        escape_at_count.current_turn = 1 if count > 0 else 0
        if count > 0:
            check(escape_at_count.take_action("kickout"), "kickout action at count %d" % count)
            check(escape_at_count.pin_target == -1, "kickout succeeds at count %d" % count)
        else:
            check(not escape_at_count.take_action("kickout"), "no premature kickout at count zero")
    var nearfall = Combat.new()
    nearfall.wrestlers[1]["health"] = 25
    nearfall.wrestlers[1]["stamina"] = 0
    check(nearfall.take_action("pin"), "pin live low-health target")
    check(nearfall.current_turn == 0, "pinning wrestler counts first")
    for count in [1, 2]:
        check(nearfall.take_action("count"), "nearfall referee count %d" % count)
        check(nearfall.pin_count == count, "nearfall count exactly %d" % count)
        check(nearfall.take_action("kickout"), "nearfall kickout attempted %d" % count)
        check(nearfall.pin_target == 1, "nearfall failed escape holds pin %d" % count)
        check(nearfall.current_turn == 0, "nearfall returns to pinning wrestler %d" % count)
    check(nearfall.take_action("count"), "nearfall reaches three")
    check(nearfall.match_over and nearfall.winner == 0, "live-health three-count awards correct winner")
    check(nearfall.pin_count == 3, "count exactly three")
    check(nearfall.legal_actions().is_empty(), "no actions after live-health pin")
    var late_escape = Combat.new()
    late_escape.wrestlers[1]["health"] = 25
    late_escape.wrestlers[1]["stamina"] = 100
    check(late_escape.take_action("pin"), "high-stamina defender pinned")
    check(late_escape.take_action("count"), "count one before escape")
    check(late_escape.take_action("kickout"), "healthy defender kicks out at one")
    check(late_escape.pin_target == -1 and late_escape.pin_count == 0, "successful kickout clears pin")
    check(late_escape.current_turn == 1, "successful kickout awards defender turn")
    var illegal = Combat.new()
    var untouched = illegal.state()
    check(not illegal.take_action("teleport"), "illegal action rejected")
    check(illegal.state() == untouched, "illegal action preserves state")
    print("APW combat rules: %d passed, %d failed" % [passed, failed])
    quit(0 if failed == 0 else 1)
