param(
  [string]$RepoPath = ".",
  [string]$Remote = "origin",
  [string]$Branch = "",
  [int]$IntervalSeconds = 60
)
Set-Location $RepoPath
if ($Branch -eq "") { $Branch = (git rev-parse --abbrev-ref HEAD).Trim() }
while ($true) {
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$timestamp] sync start ($Remote/$Branch)"
  git fetch $Remote | Out-Host
  $status = git status --porcelain
  if ($status -eq "") {
    git pull --rebase --autostash $Remote $Branch | Out-Host
  } else {
    git stash push -u -m "auto-sync-$timestamp" | Out-Host
    git pull --rebase $Remote $Branch | Out-Host
    git stash pop | Out-Host
  }
  Write-Host "[$timestamp] sync done"
  Start-Sleep -Seconds $IntervalSeconds
}

