# APW isolated Godot graphics prototype

This is a separate, experimental Godot 4 project. It does not modify or replace the original APW HTML game.

## Run
1. Install Godot 4.4 or newer.
2. Import `project.godot` in Godot.
3. Run project (F6/F5). Press **Space** to play Birdman's DDT storyboard.

## Animation review controls
- **Space** replay; **P** pause/resume
- **Left/Right** seek backward/forward exactly 1/30 second (pauses playback)
- **Home/End** jump to start/end
- **1/2/3** playback speed 0.5x / 1x / 1.5x
- **D** toggle debug metrics and **R** reduced-motion mode
- The timeline displays phase boundaries and current animation time.
- Impact crossing at 1.63s now has an 85ms freeze-frame (disabled for reduced motion).

## Godot Forge (optional, install only after reviewing upstream code)
From this project directory, with Node.js 20+ and Godot installed:
`npx -y godot-forge-mcp@latest install`
Then connect a supported MCP client as documented at https://github.com/Tann2019/godot-mcp-server .

## Current limits
- Wrestlers are procedural stand-ins, NOT likeness-accurate final sprites.
- Timeline phases and impact FX are implemented in `main.gd`; no Godot runtime test was possible in this environment because Godot is not installed.
- This is a prototype of animation timing, not a playable wrestling game or engine migration.
- No third-party repository was executed or installed.

## Checkpoint notes
- CP-G01: Deterministic timeline seeking and 30fps frame stepping
- CP-G02: Single-trigger impact hitstop; prevents multiple freeze triggers after pause
- CP-G03: Timeline phase markers and playback speed controls
- CP-G04: Debug HUD and reduced-motion-compatible impact
- CP-G05: Original HTML game remains unchanged

## Verification boundary
Static source checks are included in `verify_prototype.py`. They **do not** replace a Godot Editor runtime or visual playtest.
