# board.ps1 - show CONTROL state, your inbox, and recent activity (cross-platform PowerShell).
# Usage: pwsh tools/board.ps1 [your-agent-name]
# "Inbox" is computed: open messages across all agents/*/outbox addressed to you (or all).
param([string]$Me = "")
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Field($file, $name) {
  $line = Select-String -Path $file -Pattern "^$name`:" | Select-Object -First 1
  if ($line) { ($line.Line -replace "^$name`:\s*", "").Trim() } else { "" }
}

Write-Output "=== CONTROL ==="
if (Test-Path CONTROL.md) {
  Select-String -Path CONTROL.md -Pattern '^(state|reason):' | ForEach-Object { "  " + $_.Line }
} else { Write-Output "  (no CONTROL.md)" }

Write-Output ""
Write-Output "=== BOARD (in progress) ==="
if (Test-Path BOARD.md) {
  $b = Get-Content BOARD.md
  $start = ($b | Select-String -Pattern '## In progress').LineNumber
  $end   = ($b | Select-String -Pattern '## Assigned').LineNumber
  if ($start -and $end) { $b[($start-1)..($end-2)] | ForEach-Object { "  " + $_ } }
}

$msgs = Get-ChildItem -Path "agents/*/outbox/*.md" -ErrorAction SilentlyContinue
if ($Me) {
  Write-Output ""
  Write-Output "=== INBOX for: $Me (open messages addressed to you or 'all') ==="
  $found = $false
  foreach ($f in $msgs) {
    $to = Field $f.FullName "to"; $st = Field $f.FullName "status"
    if (($to -eq $Me -or $to -eq "all") -and $st -eq "open") {
      $from = Field $f.FullName "from"; $typ = Field $f.FullName "type"
      Write-Output "  [$typ] from $from  ->  $($f.FullName)"
      $found = $true
    }
  }
  if (-not $found) { Write-Output "  (empty)" }
}

Write-Output ""
Write-Output "=== Recent messages (last 8) ==="
if ($msgs) { $msgs | Sort-Object LastWriteTime -Descending | Select-Object -First 8 | ForEach-Object { "  " + $_.FullName } }
else { Write-Output "  (none)" }
