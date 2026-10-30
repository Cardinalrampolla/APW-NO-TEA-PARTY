extends RefCounted
## Deterministic APW combat rules: prototype, not production-balanced.
## This class has no Godot scene dependencies; it can be headless tested.
const MAX_HEALTH := 100
const MAX_STAMINA := 100
const PIN_THRESHOLD := 30
const STRIKE_DAMAGE := 9
const GRAPPLE_DAMAGE := 16
const FINISHER_DAMAGE := 32
const RECOVERY_STAMINA := 16

var wrestlers: Array[Dictionary] = []
var current_turn := 0
var match_over := false
var winner := -1
var pin_target := -1
var pin_count := 0
var log: Array[String] = []

func _init(name_a: String = "Gideon Hark", name_b: String = "Birdman Phil Picasso") -> void:
    wrestlers = [
        {"name": name_a, "health": MAX_HEALTH, "stamina": MAX_STAMINA, "stunned": 0, "finishers": 0},
        {"name": name_b, "health": MAX_HEALTH, "stamina": MAX_STAMINA, "stunned": 0, "finishers": 0},
    ]

func opponent(index: int) -> int:
    return 1 - index

func legal_actions() -> Array[String]:
    if match_over:
        return []
    if pin_target != -1:
        if current_turn == pin_target:
            return ["kickout"]
        return ["count"]
    if wrestlers[current_turn]["stunned"] > 0:
        return ["recover"]
    var choices: Array[String] = ["recover"]
    if wrestlers[current_turn]["stamina"] >= 8:
        choices.append("strike")
    if wrestlers[current_turn]["stamina"] >= 18:
        choices.append("grapple")
    if wrestlers[current_turn]["stamina"] >= 35:
        choices.append("finisher")
    if wrestlers[opponent(current_turn)]["health"] <= PIN_THRESHOLD:
        choices.append("pin")
    return choices

func take_action(action: String) -> bool:
    if not legal_actions().has(action):
        return false
    var actor := current_turn
    var target := opponent(actor)
    if action == "strike" or action == "grapple" or action == "finisher":
        var cost := 8 if action == "strike" else (18 if action == "grapple" else 35)
        if wrestlers[actor]["stamina"] < cost:
            return false
        wrestlers[actor]["stamina"] -= cost
        var damage := STRIKE_DAMAGE if action == "strike" else (GRAPPLE_DAMAGE if action == "grapple" else FINISHER_DAMAGE)
        wrestlers[target]["health"] = maxi(0, wrestlers[target]["health"] - damage)
        if action == "finisher":
            wrestlers[actor]["finishers"] += 1
            wrestlers[target]["stunned"] = 1
        log.append("%s hits %s: %s (%d damage)" % [wrestlers[actor]["name"], wrestlers[target]["name"], action, damage])
        current_turn = target
    elif action == "recover":
        wrestlers[actor]["stamina"] = mini(MAX_STAMINA, wrestlers[actor]["stamina"] + RECOVERY_STAMINA)
        wrestlers[actor]["stunned"] = 0
        log.append("%s recovers" % wrestlers[actor]["name"])
        current_turn = target
    elif action == "pin":
        pin_target = target
        pin_count = 0
        current_turn = target
        log.append("%s attempts a pin!" % wrestlers[actor]["name"])
    elif action == "kickout":
        # Deterministic kick-out: 1 or 2 is possible at > 0 health;
        # at 0 health the wrestler cannot escape the third count.
        var health: int = wrestlers[actor]["health"]
        if health > 0 and pin_count <= 2:
            pin_target = -1
            pin_count = 0
            current_turn = actor
            log.append("%s kicks out!" % wrestlers[actor]["name"])
        else:
            current_turn = target
            log.append("%s cannot kick out!" % wrestlers[actor]["name"])
    elif action == "count":
        pin_count += 1
        log.append("REFEREE: %d!" % pin_count)
        if pin_count >= 3:
            match_over = true
            winner = actor
            pin_target = -1
            log.append("%s wins by pinfall!" % wrestlers[actor]["name"])
        else:
            current_turn = target
    return true

func state() -> Dictionary:
    return {
        "wrestlers": wrestlers.duplicate(true),
        "current_turn": current_turn,
        "match_over": match_over,
        "winner": winner,
        "pin_target": pin_target,
        "pin_count": pin_count,
        "legal_actions": legal_actions(),
        "log": log.duplicate(),
    }
