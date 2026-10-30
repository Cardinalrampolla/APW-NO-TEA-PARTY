extends RefCounted
## Deterministic opponent controller; no random inputs or hidden state.
## Designed for Birdman as the player-one opponent in the arcade prototype.

func choose_action(game: RefCounted) -> String:
    var actions: Array[String] = game.legal_actions()
    if actions.is_empty():
        return ""
    if actions.has("kickout"):
        return "kickout"
    if actions.has("count"):
        return "count"
    if actions.has("pin"):
        var target: Dictionary = game.wrestlers[game.opponent(game.current_turn)]
        var escape_score: int = int(target["health"]) + int(target["stamina"]) / 4
        if escape_score < 30:
            return "pin"
    if actions.size() == 1:
        return actions[0]
    var own: Dictionary = game.wrestlers[game.current_turn]
    var enemy: Dictionary = game.wrestlers[game.opponent(game.current_turn)]
    if int(own["stamina"]) < 18:
        return "recover"
    if int(enemy["health"]) <= 32 and actions.has("finisher"):
        return "finisher"
    if int(own["stamina"]) >= 50 and actions.has("grapple"):
        return "grapple"
    if actions.has("strike"):
        return "strike"
    return "recover"
