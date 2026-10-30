extends SceneTree
## 60 AI decision scenarios: six opponent-health levels x ten stamina levels.
const Combat = preload("res://combat_rules.gd")
const Brain = preload("res://combat_ai.gd")
var passed := 0
var failed := 0

func _initialize() -> void:
    call_deferred("run_tests")

func check(condition: bool, label: String) -> void:
    if condition:
        passed += 1
    else:
        failed += 1
        printerr("FAIL: " + label)

func run_tests() -> void:
    var brain = Brain.new()
    var scenarios := 0
    for target_health in [0, 1, 25, 30, 31, 100]:
        for stamina in [0, 7, 8, 17, 18, 34, 35, 49, 50, 100]:
            scenarios += 1
            var game = Combat.new()
            game.current_turn = 1
            game.wrestlers[0]["health"] = target_health
            game.wrestlers[1]["stamina"] = stamina
            var choice: String = brain.choose_action(game)
            var label := "health=%d stamina=%d" % [target_health, stamina]
            check(game.legal_actions().has(choice), "AI selects legal action: " + label)
            check(brain.choose_action(game) == choice, "AI deterministic: " + label)
            check(game.take_action(choice), "AI action executes: " + label)
            check(int(game.wrestlers[0]["health"]) >= 0, "health nonnegative: " + label)
            check(int(game.wrestlers[1]["stamina"]) >= 0, "stamina nonnegative: " + label)
    var pin = Combat.new()
    pin.current_turn = 1
    pin.pin_target = 0
    check(brain.choose_action(pin) == "count", "AI referee count when attacker")
    pin.current_turn = 0
    check(brain.choose_action(pin) == "kickout", "AI kickout when defender")
    var stunned = Combat.new()
    stunned.current_turn = 1
    stunned.wrestlers[1]["stunned"] = 1
    check(brain.choose_action(stunned) == "recover", "AI recovers from stun")
    var ended = Combat.new()
    ended.match_over = true
    check(brain.choose_action(ended) == "", "AI stops on match over")
    print("APW AI: %d scenarios, %d checks passed, %d failed" % [scenarios, passed, failed])
    quit(0 if failed == 0 else 1)
