# board.ps1 -- Communication Hub status helper (read-only)
# Usage: powershell tools/board.ps1 [-Me claude|codex|antigravity]
# Scans every agents/*/outbox message's frontmatter (to/status/type/ref)
# and shows -Me's inbox = open requests addressed to -Me with no response yet.

param([string]$Me = "")

$root = Split-Path $PSScriptRoot -Parent
$agents = @("claude","codex","antigravity")

Write-Host "=== AI Infra Communication Hub ===`n" -ForegroundColor Cyan

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
      $msgs += [pscustomobject]@{ File=$_.Name; From=$fm.from; To=$fm.to; Type=$fm.type; Status=$fm.status; Ref=$fm.ref; Id=$fm.id }
    }
  }
}

Write-Host ("Total messages: {0}" -f $msgs.Count) -ForegroundColor Yellow
$msgs | Format-Table From,To,Type,Status,File -AutoSize

$answered = $msgs | Where-Object { $_.Type -eq "response" -and $_.Ref } | Select-Object -ExpandProperty Ref

if ($Me) {
  Write-Host ("`n=== inbox for {0} (open, unanswered requests) ===" -f $Me) -ForegroundColor Green
  $inbox = $msgs | Where-Object { ($_.To -eq $Me -or $_.To -eq "all") -and $_.Type -eq "request" -and $_.Status -eq "open" -and ($answered -notcontains $_.Id) }
  if ($inbox) { $inbox | Format-Table From,Type,File -AutoSize } else { Write-Host "(empty)" }
}
