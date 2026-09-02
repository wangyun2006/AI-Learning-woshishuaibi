$ErrorActionPreference = 'Continue'
$root = 'E:\AI-Learning-woshishuaibi-main\AI-Learning-woshishuaibi-main'
$serverDir = Join-Path $root 'server'
$frontendDir = Join-Path $root 'frontend'
$adminDir = Join-Path $root 'admin-web'
$nodeExe = 'C:\Program Files\nodejs\node.exe'

function Test-Port($port) {
  return [bool](Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)
}

$pg = Get-Service -Name 'postgresql-x64-17' -ErrorAction SilentlyContinue
if ($pg -and $pg.Status -ne 'Running') { Start-Service -Name 'postgresql-x64-17' }
Write-Host '[1/4] PostgreSQL ready'

if (Test-Port 3000) {
  Write-Host '[2/4] Backend API already running (3000)'
} else {
  Start-Process -FilePath $nodeExe -ArgumentList '--env-file=.env','dist/main.js' -WorkingDirectory $serverDir -WindowStyle Hidden
  Write-Host '[2/4] Backend API starting (3000)...'
}

if (Test-Port 5173) {
  Write-Host '[3/4] Student web already running (5173)'
} else {
  $env:VITE_API_BASE_URL = 'http://127.0.0.1:3000/api/v1'
  $env:VITE_DATA_MODE = 'api'
  Start-Process -FilePath $nodeExe -ArgumentList 'node_modules/vite/bin/vite.js' -WorkingDirectory $frontendDir -WindowStyle Hidden
  Write-Host '[3/4] Student web starting (5173)...'
}

if (Test-Port 5174) {
  Write-Host '[4/4] Admin web already running (5174)'
} else {
  Start-Process -FilePath $nodeExe -ArgumentList 'node_modules/vite/bin/vite.js' -WorkingDirectory $adminDir -WindowStyle Hidden
  Write-Host '[4/4] Admin web starting (5174)...'
}

$ready = $false
for ($i = 0; $i -lt 40; $i++) {
  if ((Test-Port 3000) -and (Test-Port 5173) -and (Test-Port 5174)) { $ready = $true; break }
  Start-Sleep -Milliseconds 1000
}
if (-not $ready) { Write-Host 'Warning: some services not ready yet, refresh browser later' }

Start-Sleep -Seconds 2
Start-Process 'http://127.0.0.1:5173'
Write-Host ''
Write-Host '========================================='
Write-Host '  AI Learning Platform ready'
Write-Host '  Student: http://127.0.0.1:5173'
Write-Host '  Admin:   http://127.0.0.1:5174'
Write-Host '  API:     http://127.0.0.1:3000/api/docs'
Write-Host '  Admin acct: admin@example.com / admin123456'
Write-Host '  Student acct: student@example.com / student123'
Write-Host '========================================='