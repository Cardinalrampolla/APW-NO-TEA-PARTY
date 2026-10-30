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
    # Regression: Birdman must damage a defender who can escape count one.
    var loop = Combat.new()
    loop.wrestlers[0]["health"] = 30
    loop.wrestlers[0]["stamina"] = 0
    loop.current_turn = 1
    var loop_steps := 0
    while not loop.match_over and loop_steps < 500:
        var act: String = brain.choose_action(loop) if loop.current_turn == 1 else ("kickout" if loop.legal_actions().has("kickout") else "recover")
        check(loop.legal_actions().has(act), "loop regression legal action step %d" % loop_steps)
        if not loop.take_action(act):
            break
        loop_steps += 1
    check(loop.match_over, "AI finishes match against escapable passive defender")
    check(loop_steps < 500, "AI avoids repeat-pin action cap")
    print("APW AI: %d scenarios, %d checks passed, %d failed" % [scenarios, passed, failed])
    quit(0 if failed == 0 else 1)
