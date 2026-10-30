# APW local agent bootstrap. Run inside the intended Godot prototype repository.
# No credentials are stored by this script. Never force-push or merge.
$ErrorActionPreference = "Stop"
$remote = "https://github.com/Cardinalrampolla/APW-NO-TEA-PARTY.git"
Write-Host "APW agent preflight" -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Git missing. Install Git for Windows." }
git rev-parse --is-inside-work-tree | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Run from the intended local prototype Git repository." }
$origin = (git remote get-url origin 2>$null)
if ($origin -and ($origin.Trim() -ne $remote)) { throw "Existing origin differs: $origin. Refusing to overwrite." }
if (-not $origin) { git remote add origin $remote; Write-Host "Configured origin: $remote" }
git remote -v
if (Get-Command codex -ErrorAction SilentlyContinue) {
  codex login status
  if ($LASTEXITCODE -ne 0) { Write-Warning "Codex needs interactive authentication: run 'codex login' yourself. No script can bypass account approval." }
} else { Write-Warning "Codex CLI missing." }
if (Get-Command gh -ErrorAction SilentlyContinue) {
  gh auth status
  if ($LASTEXITCODE -ne 0) { Write-Warning "GitHub CLI needs interactive authentication: run 'gh auth login'." }
} else { Write-Warning "GitHub CLI missing; git credential manager may still authenticate on push." }
Write-Host "Local branches:"; git branch --list
Write-Host "Git status:"; git status --short
Write-Host "Preflight complete. No source was pushed, merged or altered."
