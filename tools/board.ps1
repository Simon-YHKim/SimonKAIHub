# board.ps1 -- Communication Hub status helper (read-only)
# Usage: powershell tools/board.ps1 [-Me claude|codex|antigravity|grok]
# Scans every agents/*/outbox message's frontmatter (to/status/type/ref)
# and shows -Me's inbox = open requests addressed to -Me with no response yet.
# Also shows run-state (CONTROL.md), auth blockers, open consensus, recent HTML reports.

param([string]$Me = "")

$root = Split-Path $PSScriptRoot -Parent
$agents = @("claude","codex","antigravity","grok")

Write-Host "=== AI Infra Communication Hub ===`n" -ForegroundColor Cyan

# --- run-state (CONTROL.md) ---
$control = Join-Path $root "CONTROL.md"
if (Test-Path $control) {
  $cstate = (Get-Content $control -TotalCount 12 | Select-String '^state:\s*(.*)$').Matches.Groups[1].Value
  $creason = (Get-Content $control -TotalCount 12 | Select-String '^pause_reason:\s*"?(.*?)"?$').Matches.Groups[1].Value
  $color = if ($cstate -eq "running") { "Green" } elseif ($cstate -eq "paused") { "Red" } else { "Yellow" }
  Write-Host ("RUN STATE: {0}" -f $cstate.ToUpper()) -ForegroundColor $color
  if ($creason) { Write-Host ("  reason: {0}" -f $creason) -ForegroundColor DarkGray }
  Write-Host ""
}

# --- scan all outbox messages ---
$msgs = @()
foreach ($a in $agents) {
  $obx = Join-Path $root "agents\$a\outbox"
  if (Test-Path $obx) {
    Get-ChildItem $obx -Filter *.md -File | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
      $head = Get-Content $_.FullName -TotalCount 15
      $fm = @{}
      foreach ($line in $head) {
        if ($line -match '^(id|from|to|type|ref|status|priority|project):\s*"?(.*?)"?\s*$') { $fm[$matches[1]] = $matches[2] }
      }
      $msgs += [pscustomobject]@{ File=$_.Name; From=$fm.from; To=$fm.to; Type=$fm.type; Status=$fm.status; Ref=$fm.ref; Id=$fm.id; Priority=$fm.priority }
    }
  }
}

Write-Host ("Total messages: {0}" -f $msgs.Count) -ForegroundColor Yellow

$answered = $msgs | Where-Object { $_.Type -eq "response" -and $_.Ref } | Select-Object -ExpandProperty Ref

# --- auth / external blockers ---
$blockers = $msgs | Where-Object { $_.Type -eq "blocker" }
if ($blockers) {
  Write-Host "`n[AUTH / EXTERNAL BLOCKERS] (Simon 개입 필요)" -ForegroundColor Magenta
  $blockers | Format-Table From,Status,File -AutoSize
}

# --- open consensus votes ---
$consReq = $msgs | Where-Object { $_.Type -eq "consensus_request" -and ($answered -notcontains $_.Id) }
$consVote = $msgs | Where-Object { $_.Type -eq "consensus_vote" }
if ($consReq) {
  Write-Host "`n[CONSENSUS OPEN] (투표 진행)" -ForegroundColor Cyan
  foreach ($r in $consReq) {
    $votes = ($consVote | Where-Object { $_.Ref -eq $r.Id }).From -join ", "
    Write-Host ("  {0}  votes: {1}" -f $r.File, ($(if ($votes) { $votes } else { "(none)" })))
  }
}

# --- inbox for -Me ---
if ($Me) {
  Write-Host ("`n=== inbox for {0} (open, unanswered requests) ===" -f $Me) -ForegroundColor Green
  $inbox = $msgs | Where-Object { ($_.To -eq $Me -or $_.To -eq "all") -and $_.Type -eq "request" -and $_.Status -eq "open" -and ($answered -notcontains $_.Id) }
  if ($inbox) { $inbox | Format-Table From,Priority,Type,File -AutoSize } else { Write-Host "(empty)" }
}

# --- recent HTML reports (browser previews) ---
$previews = Get-ChildItem (Join-Path $root "agents") -Recurse -Filter *.html -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -match 'outbox\\preview' } |
  Sort-Object LastWriteTime -Descending | Select-Object -First 5
if ($previews) {
  Write-Host "`n[RECENT HTML REPORTS]" -ForegroundColor DarkCyan
  $previews | ForEach-Object { Write-Host ("  {0}  {1}" -f $_.LastWriteTime.ToString('MM-dd HH:mm'), $_.Name) }
}
