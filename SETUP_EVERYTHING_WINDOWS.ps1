# APW guarded pilot setup. Run from the extracted APW_ORDEWELL_PILOT folder.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
function Need($name, $wingetId) {
  if (Get-Command $name -ErrorAction SilentlyContinue) { Write-Host "OK: $name" -ForegroundColor Green; return }
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw "Missing $name. Install $wingetId, then rerun." }
  Write-Host "Installing $name using winget ($wingetId)..." -ForegroundColor Cyan
  & winget install --id $wingetId --exact --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) { throw "Installation of $name failed." }
  # Refresh common PATH additions for this session. A new terminal may still be required.
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "$name installed but not on PATH. Restart PowerShell and rerun." }
}
Write-Host 'APW — guarded Ordewell setup' -ForegroundColor Cyan
Need 'git' 'Git.Git'
Need 'node' 'OpenJS.NodeJS.LTS'
Need 'code' 'Microsoft.VisualStudioCode'
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw 'npm not found. Restart PowerShell and rerun.' }
$runner = @('codex','claude','opencode') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1
if (-not $runner) {
  Write-Host 'Installing Codex CLI runner...' -ForegroundColor Cyan
  & npm install -g '@openai/codex'
  if ($LASTEXITCODE -ne 0) { throw 'Codex installation failed.' }
  $env:Path += ';' + (Join-Path $env:APPDATA 'npm')
  $runner = 'codex'
}
Write-Host "Runner: $runner" -ForegroundColor Green
& code --install-extension ordewell.ordewell
if ($LASTEXITCODE -ne 0) { throw 'Ordewell extension installation failed.' }
if (-not (Test-Path '.git')) {
  & git init
  if ($LASTEXITCODE -ne 0) { throw 'Git initialization failed.' }
  & git add -- .
  Write-Host 'Git initialized. Commit after reviewing files; no automatic commit made.'
}
Write-Host 'Running APW prototype static checks...' -ForegroundColor Cyan
if (Get-Command py -ErrorAction SilentlyContinue) { & py -3 verify_prototype.py; if ($LASTEXITCODE -ne 0) { throw 'APW verification failed.' } }
elseif (Get-Command python -ErrorAction SilentlyContinue) { & python verify_prototype.py; if ($LASTEXITCODE -ne 0) { throw 'APW verification failed.' } }
else { Write-Warning 'Python not found: static checks skipped.' }
& code $PSScriptRoot
Write-Host ''
Write-Host 'Installation finished. Complete runner sign-in yourself in VS Code terminal.' -ForegroundColor Yellow
Write-Host "Try: $runner login  (follow the runner's current sign-in instructions)"
Write-Host 'Then open Ordewell in VS Code, review PILOT_PLAN.md, approve a guarded pilot.'
Write-Host 'Keep automatic merging and autorun OFF. No agent task has been launched.'
