# board.ps1 — 통신 허브 상태 요약 헬퍼 (읽기 전용)
# 사용: pwsh tools/board.ps1  [-Me claude|codex|antigravity]
# 기능: BOARD 요약 + 각 outbox 메시지의 to/status 스캔 → 지정 AI의 inbox(미응답 request) 표시.

param([string]$Me = "")

$root = Split-Path $PSScriptRoot -Parent
$agents = @("claude","codex","antigravity")

Write-Host "=== AI Infra Communication Hub ===`n" -ForegroundColor Cyan

# 모든 메시지 수집
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

Write-Host "전체 메시지: $($msgs.Count)건" -ForegroundColor Yellow
$msgs | Format-Table From,To,Type,Status,File -AutoSize

# 응답된 요청 id 집합
$answered = $msgs | Where-Object { $_.Type -eq "response" -and $_.Ref } | Select-Object -ExpandProperty Ref

if ($Me) {
  Write-Host "`n=== $Me 의 inbox (미응답 request) ===" -ForegroundColor Green
  $inbox = $msgs | Where-Object { ($_.To -eq $Me -or $_.To -eq "all") -and $_.Type -eq "request" -and $_.Status -eq "open" -and ($answered -notcontains $_.Id) }
  if ($inbox) { $inbox | Format-Table From,Type,File -AutoSize } else { Write-Host "(비어 있음)" }
}
