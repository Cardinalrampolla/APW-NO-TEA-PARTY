# Run in PowerShell from the extracted APW_ORDEWELL_PILOT directory.
$ErrorActionPreference = 'Stop'
Write-Host 'APW Ordewell guarded pilot preflight' -ForegroundColor Cyan
foreach ($cmd in @('node','git','code')) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Host "MISSING: $cmd. Install it, restart PowerShell, then rerun." -ForegroundColor Red
    exit 1
  }
}
$runner = @('claude','codex','opencode') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1
if (-not $runner) {
  Write-Host 'MISSING: coding agent CLI (Claude Code, Codex or OpenCode).' -ForegroundColor Yellow
  Write-Host 'Install and authenticate one supported coding agent before continuing.'
  exit 2
}
Write-Host "Runner found: $runner" -ForegroundColor Green
Write-Host 'Installing Ordewell VS Code extension...'
& code --install-extension ordewell.ordewell
if ($LASTEXITCODE -ne 0) { throw 'VS Code extension installation failed.' }
Write-Host 'Opening pilot workspace in VS Code...'
& code (Resolve-Path '.').Path
Write-Host 'Next: open Ordewell panel, paste PILOT_PLAN.md goal, review plan, approve manually.' -ForegroundColor Green
Write-Host 'Keep autorun and automatic merging OFF. This script does not execute agent tasks.'
