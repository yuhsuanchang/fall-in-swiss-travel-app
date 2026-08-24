$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$RepoName = 'fall-in-swiss-travel-app'

Set-Location $Root

function Require-Gh {
  $gh = Get-Command gh -ErrorAction SilentlyContinue
  if (-not $gh) {
    Write-Host 'GitHub CLI (gh) is not installed.' -ForegroundColor Red
    Write-Host 'Install: winget install --id GitHub.cli -e'
    exit 1
  }
}

function Test-GitRemote([string]$Name) {
  $remotes = @(git remote)
  return $remotes -contains $Name
}

Require-Gh

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host ''
  Write-Host 'Please sign in to GitHub first:' -ForegroundColor Yellow
  Write-Host '  gh auth login'
  Write-Host ''
  Write-Host 'Recommended choices:'
  Write-Host '  GitHub.com -> HTTPS -> Login with a web browser'
  Write-Host ''
  exit 1
}

if (-not (Test-Path '.git')) {
  git init | Out-Null
  git add .
  git commit -m 'Add shareable GitHub Pages travel app.' | Out-Null
  git branch -M main | Out-Null
}

if (-not (Test-GitRemote 'origin')) {
  Write-Host "Creating GitHub repo: $RepoName" -ForegroundColor Cyan
  gh repo create $RepoName --public --source=. --remote=origin --push
  if ($LASTEXITCODE -ne 0) {
    Write-Host 'Failed to create or push the GitHub repo.' -ForegroundColor Red
    exit 1
  }
} else {
  Write-Host 'Pushing latest changes to GitHub...' -ForegroundColor Cyan
  git push -u origin main
  if ($LASTEXITCODE -ne 0) {
    Write-Host 'Failed to push to GitHub.' -ForegroundColor Red
    exit 1
  }
}

Write-Host ''
Write-Host 'Next step (one time only):' -ForegroundColor Yellow
Write-Host '  1. Open your repo on GitHub'
Write-Host '  2. Settings -> Pages'
Write-Host '  3. Build and deployment -> Source: GitHub Actions'
Write-Host ''
Write-Host 'After the workflow finishes, your shareable URL will be:'
$owner = gh api user -q .login
Write-Host "  https://$owner.github.io/$RepoName/" -ForegroundColor Green
Write-Host ''
Write-Host 'Share that URL with your friends.'
