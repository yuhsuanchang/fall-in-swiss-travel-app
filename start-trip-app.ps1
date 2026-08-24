$ErrorActionPreference = 'Stop'
$Port = 8080
$Root = $PSScriptRoot
$AppFile = 'switzerland_italy_trip_app.html'

function Find-Python {
  foreach ($cmd in @('py', 'python', 'python3')) {
    $resolved = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($resolved) {
      return $resolved.Source
    }
  }
  return $null
}

function Get-LanIp {
  $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.PrefixOrigin -ne 'WellKnown' -and
      $_.IPAddress -notmatch '^127\.' -and
      $_.IPAddress -notmatch '^169\.254\.'
    } |
    Select-Object -First 1 -ExpandProperty IPAddress

  if ($ip) { return $ip }
  return '127.0.0.1'
}

$python = Find-Python
if (-not $python) {
  Write-Host ''
  Write-Host 'Python not found. Please install Python first.' -ForegroundColor Red
  Write-Host 'Download: https://www.python.org/downloads/' -ForegroundColor Yellow
  Write-Host 'Remember to check Add Python to PATH during install.' -ForegroundColor Yellow
  Write-Host ''
  Read-Host 'Press Enter to exit'
  exit 1
}

$ip = Get-LanIp
$localUrl = "http://localhost:${Port}/${AppFile}"
$phoneUrl = "http://${ip}:${Port}/${AppFile}"

Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
Write-Host '  Fall in Swiss Travel App started' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'PC browser:' -NoNewline
Write-Host " $localUrl" -ForegroundColor White
Write-Host ''
Write-Host 'Phone browser (same Wi-Fi):' -ForegroundColor Green
Write-Host " $phoneUrl" -ForegroundColor Green
Write-Host ''
Write-Host 'Install on phone:' -ForegroundColor Yellow
Write-Host '  iPhone Safari: Share -> Add to Home Screen'
Write-Host '  Android Chrome: Menu -> Install app / Add to Home Screen'
Write-Host ''
Write-Host 'After first open, itinerary and checklist work offline.'
Write-Host 'Press Ctrl + C to stop the server.' -ForegroundColor DarkGray
Write-Host ''

Start-Process $localUrl | Out-Null
Set-Location $Root
& $python -m http.server $Port