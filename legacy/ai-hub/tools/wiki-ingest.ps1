# wiki-ingest.ps1 -- Collect queued lesson messages for SimonKWiki ingestion (PROTOCOL 18 / 34.1).
# The hub rule says every AI writes `type: wiki_lesson` (or activation/lesson notes) to its outbox
# and Claude (librarian) batch-ingests into the wiki. That intake had NO tool, so lessons piled up
# unprocessed. This collects new lessons into one digest for Claude to review + commit into the
# private SimonKWiki repo. It does NOT write the wiki itself (raw immutability + librarian-only
# writes stay Claude's hands-on step).
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File "tools/wiki-ingest.ps1"          # list + write digest
#   powershell -ExecutionPolicy Bypass -File "tools/wiki-ingest.ps1" -ListOnly
param([switch]$ListOnly)
$ErrorActionPreference = 'Continue'
$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8; $OutputEncoding = $utf8
$root = Split-Path $PSScriptRoot -Parent
function Now { Get-Date -Format 'yyyy-MM-dd / HH:mm:ss' }

# Ledger of already-ingested message ids (claude-owned, gitignored-friendly plain text).
$ledger = Join-Path $root "agents\claude\wiki-ingest-ledger.txt"
$done = @{}
if(Test-Path $ledger){ Get-Content $ledger -Encoding UTF8 | ForEach-Object { if($_.Trim()){ $done[$_.Trim()] = $true } } }

# Lesson-bearing messages: explicit type: wiki_lesson, OR notes whose filename/type marks a
# reusable signal (activation-signals / lessons-learned / retro). 2-of-3 intake stays Claude's call.
$lessons = @()
Get-ChildItem (Join-Path $root "agents") -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $obx = Join-Path $_.FullName "outbox"
  if(-not (Test-Path $obx)){ return }
  Get-ChildItem $obx -Filter *.md -File -ErrorAction SilentlyContinue | ForEach-Object {
    $file = $_
    $h = Get-Content $file.FullName -Encoding UTF8 -TotalCount 15
    $fm = @{}
    foreach($l in $h){ if($l -match '^(from|to|type|id|created):\s*"?(.*?)"?\s*$'){ $fm[$matches[1]] = $matches[2] } }
    $isLesson = ($fm.type -match 'wiki_lesson|lesson|retro') -or ($file.Name -match 'lesson|retro|activation-signals|firstrun-feedback')
    if($isLesson){
      $id = if($fm.id){ $fm.id } else { $file.BaseName }
      if(-not $done.ContainsKey($id)){
        $lessons += [pscustomobject]@{ Id=$id; From=$fm.from; Created=$fm.created; File=$file.FullName; Name=$file.Name }
      }
    }
  }
}

if($lessons.Count -eq 0){ Write-Host "[wiki-ingest $(Now) KST] no new lessons to ingest (ledger up to date)." -ForegroundColor Green; return }

Write-Host ("[wiki-ingest $(Now) KST] " + $lessons.Count + " new lesson(s) queued for SimonKWiki:") -ForegroundColor Cyan
$lessons | ForEach-Object { Write-Host ("  - [" + $_.From + "] " + $_.Name) -ForegroundColor Gray }

if($ListOnly){ return }

# Write a consolidated digest for Claude to review then commit into the wiki (T-/M- codes per 18.1).
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$digest = Join-Path $root ("agents\claude\outbox\" + $stamp + "-wiki-lesson-digest.md")
$body = @()
$body += "# Wiki lesson digest -- $(Now) KST"
$body += ""
$body += "Claude (librarian) review + ingest into SimonKWiki (LESSONS_LEARNED.md T-codes / recurring-mistakes.md M-codes per PROTOCOL 18.1). Then append each id to agents/claude/wiki-ingest-ledger.txt."
$body += ""
foreach($x in $lessons){
  $body += "## [" + $x.From + "] " + $x.Name
  $body += "- id: " + $x.Id
  $body += "- created: " + $x.Created
  $content = Get-Content $x.File -Encoding UTF8 | Select-Object -Skip 0
  # include the message body (skip frontmatter block)
  $inFm = $false; $seenFm = 0
  foreach($line in $content){
    if($line -match '^---\s*$'){ $seenFm++; continue }
    if($seenFm -ge 2){ $body += "  " + $line }
  }
  $body += ""
}
[System.IO.File]::WriteAllLines($digest, $body, $utf8)
Write-Host ("digest: " + $digest) -ForegroundColor DarkCyan
Write-Host "next: Claude reviews digest -> ingests to SimonKWiki -> appends ids to wiki-ingest-ledger.txt" -ForegroundColor DarkCyan
