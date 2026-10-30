extends RefCounted
## Data-only finisher timing library. These are choreography planning beats,
## NOT approved sprites or complete rendered animations.
## Each move has five normalized timeline anchors for future animation work.

const MOVES := {
    "birdman_double_underhook_ddt": {
        "wrestler": "Birdman Phil Picasso",
        "move": "Double Underhook DDT",
        "beats": [
            {"at": 0, "pose": "approach", "contact": false},
            {"at": 0.22, "pose": "secure double underhook", "contact": false},
            {"at": 0.48, "pose": "plant feet and load", "contact": false},
            {"at": 0.72, "pose": "drop to mat", "contact": true},
            {"at": 1, "pose": "impact and sell", "contact": false},
        ],
    },
    "bruza_russian_leg_sweep": {
        "wrestler": "Bruza The Serb",
        "move": "Russian Leg Sweep",
        "beats": [
            {"at": 0, "pose": "square up", "contact": false},
            {"at": 0.22, "pose": "hook opponent leg", "contact": false},
            {"at": 0.48, "pose": "pull backward", "contact": false},
            {"at": 0.72, "pose": "sweep and fall", "contact": true},
            {"at": 1, "pose": "back bump and sell", "contact": false},
        ],
    },
    "nikki_running_cannonball": {
        "wrestler": "Nikki Poteet",
        "move": "Running Cannonball",
        "beats": [
            {"at": 0, "pose": "measure distance", "contact": false},
            {"at": 0.22, "pose": "sprint forward", "contact": false},
            {"at": 0.48, "pose": "jump and tuck", "contact": false},
            {"at": 0.72, "pose": "body contact", "contact": true},
            {"at": 1, "pose": "land and sell", "contact": false},
        ],
    },
    "simon_chokeslam": {
        "wrestler": "Simon Temple",
        "move": "Chokeslam",
        "beats": [
            {"at": 0, "pose": "face opponent", "contact": false},
            {"at": 0.22, "pose": "secure throat grip", "contact": false},
            {"at": 0.48, "pose": "lift and hold", "contact": false},
            {"at": 0.72, "pose": "slam downward", "contact": true},
            {"at": 1, "pose": "mat impact and sell", "contact": false},
        ],
    },
    "gideon_ripcord_clothesline": {
        "wrestler": "Gideon Hark",
        "move": "Ripcord Clothesline",
        "beats": [
            {"at": 0, "pose": "capture wrist", "contact": false},
            {"at": 0.22, "pose": "pull opponent through", "contact": false},
            {"at": 0.48, "pose": "rotate shoulders", "contact": false},
            {"at": 0.72, "pose": "clothesline contact", "contact": true},
            {"at": 1, "pose": "fall and sell", "contact": false},
        ],
    },
    "johnny_the_stroke": {
        "wrestler": "Johnny Putrid",
        "move": "The Stroke",
        "beats": [
            {"at": 0, "pose": "hook head", "contact": false},
            {"at": 0.22, "pose": "turn and control", "contact": false},
            {"at": 0.48, "pose": "load forward fall", "contact": false},
            {"at": 0.72, "pose": "face-first takedown", "contact": true},
            {"at": 1, "pose": "impact and sell", "contact": false},
        ],
    },
    "tnt_unprettier": {
        "wrestler": "TNT",
        "move": "The Unprettier",
        "beats": [
            {"at": 0, "pose": "capture arms", "contact": false},
            {"at": 0.22, "pose": "turn back-to-back", "contact": false},
            {"at": 0.48, "pose": "lock double arm", "contact": false},
            {"at": 0.72, "pose": "drop to mat", "contact": true},
            {"at": 1, "pose": "face bump and sell", "contact": false},
        ],
    },
    "whiskey_450_splash": {
        "wrestler": "Whiskey Sixx",
        "move": "450 Splash",
        "beats": [
            {"at": 0, "pose": "climb turnbuckle", "contact": false},
            {"at": 0.22, "pose": "set stance", "contact": false},
            {"at": 0.48, "pose": "launch and rotate", "contact": false},
            {"at": 0.72, "pose": "body splash contact", "contact": true},
            {"at": 1, "pose": "bounce and sell", "contact": false},
        ],
    },
    "eli_five_star_frog_splash": {
        "wrestler": "Eli Driftwood",
        "move": "Five Star Frog Splash",
        "beats": [
            {"at": 0, "pose": "climb ropes", "contact": false},
            {"at": 0.22, "pose": "balance at top", "contact": false},
            {"at": 0.48, "pose": "leap and extend", "contact": false},
            {"at": 0.72, "pose": "splash contact", "contact": true},
            {"at": 1, "pose": "recoil and sell", "contact": false},
        ],
    },
    "al_drum_finisher": {
        "wrestler": "Al Straya",
        "move": "44 Gallon Drum to the Head",
        "beats": [
            {"at": 0, "pose": "reveal prop", "contact": false},
            {"at": 0.22, "pose": "position opponent", "contact": false},
            {"at": 0.48, "pose": "wind up", "contact": false},
            {"at": 0.72, "pose": "cartoon prop contact", "contact": true},
            {"at": 1, "pose": "stagger and sell", "contact": false},
        ],
    },
}

static func get_move(move_id: String) -> Dictionary:
    return MOVES.get(move_id, {}).duplicate(true)

static func beat_at(move_id: String, progress: float) -> Dictionary:
    var move: Dictionary = MOVES.get(move_id, {})
    if move.is_empty():
        return {}
    var beats: Array = move["beats"]
    var t := clampf(progress, 0.0, 1.0)
    var selected: Dictionary = beats[0]
    for beat in beats:
        if t >= float(beat["at"]):
            selected = beat
        else:
            break
    return selected.duplicate(true)

static func validate_library() -> bool:
    if MOVES.size() != 10:
        return false
    for move in MOVES.values():
        var beats: Array = move["beats"]
        if beats.size() != 5:
            return false
        var last_at := -1.0
        var contacts := 0
        for beat in beats:
            var at: float = beat["at"]
            if at <= last_at or at < 0.0 or at > 1.0:
                return false
            if beat["contact"]:
                contacts += 1
            last_at = at
        if contacts != 1 or last_at != 1.0:
            return false
    return true
