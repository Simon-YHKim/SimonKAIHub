# commit.ps1 -- 허브 커밋 헬퍼 (AI별 기여자 표기)
# 목적: 공유 .git의 author가 전부 "AI Hub"로 뭉개지는 문제 해결.
#       각 AI가 자기 정체성으로 커밋해 git log/blame에 기여가 드러나게 한다.
#
# 사용:
#   powershell tools/commit.ps1 -As codex -m "docs(comm): gate ..." -Files "agents/codex/STATUS.md","agents/codex/outbox/x.md"
#   powershell tools/commit.ps1 -As claude -m "feat(comm): ..."   # -Files 생략 시 이미 stage된 것만 커밋
#
# 규칙(PROTOCOL §10.5): 자기 파일만 명시 stage. `git add -A`/`git add .` 금지.
#   -Files 를 주면 그 경로들만 stage 후 커밋. 안 주면 현재 staged 인덱스 그대로 커밋.

param(
  [Parameter(Mandatory=$true)][ValidateSet("claude","codex","antigravity","grok")][string]$As,
  [Parameter(Mandatory=$true)][string]$Message,
  [string[]]$Files = @()
)

$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

$identities = @{
  claude      = @{ name = "Claude";      email = "claude@2nd-b.ai" }
  codex       = @{ name = "Codex";       email = "codex@2nd-b.ai" }
  antigravity = @{ name = "Antigravity"; email = "antigravity@2nd-b.ai" }
  grok        = @{ name = "Grok";        email = "grok@2nd-b.ai" }
}
$id = $identities[$As]

$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

if ($Files.Count -gt 0) {
  foreach ($f in $Files) { git add -- $f }
}

# author + committer 둘 다 해당 AI로 박는다 (git log/blame/contributors에 드러남)
git -c user.name="$($id.name)" -c user.email="$($id.email)" commit -m $Message
if ($LASTEXITCODE -eq 0) {
  Write-Host "[commit] committed as ${As}: $Message" -ForegroundColor Green
} else {
  Write-Host "[commit] failed. Check staged files, conflicts, and git status." -ForegroundColor Yellow
}
