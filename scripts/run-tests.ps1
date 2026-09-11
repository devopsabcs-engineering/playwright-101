#!/usr/bin/env pwsh
# Runs all Playwright tests in this project (functional and accessibility suites).

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
Set-Location -Path (Join-Path $PSScriptRoot '..\playwright-tests')

if (-not (Test-Path 'node_modules')) {
    Write-Host 'Installing dependencies...' -ForegroundColor Cyan
    npm install
    npx playwright install --with-deps chromium
}

$env:PLAYWRIGHT_SCREENSHOT = 'on'
$env:PLAYWRIGHT_HTML_OPEN = 'never'

$suites = @('functional', 'accessibility')
$failed = @()

foreach ($suite in $suites) {
    Write-Host "Running $suite tests..." -ForegroundColor Cyan
    npm run "test:$suite"
    if ($LASTEXITCODE -ne 0) {
        $failed += $suite
    }
}

if (-not $env:CI) {
    $reports = @(
        @{ Path = 'playwright-report'; Port = 9323 }
        @{ Path = 'playwright-report/accessibility'; Port = 9324 }
    )
    $npxCommand = if ($IsWindows) { 'npx.cmd' } else { 'npx' }

    foreach ($report in $reports) {
        if (Test-Path (Join-Path $report.Path 'index.html')) {
            try {
                Write-Host "Opening $($report.Path) at http://localhost:$($report.Port)..." -ForegroundColor Cyan
                Start-Process -FilePath $npxCommand -ArgumentList @(
                    'playwright', 'show-report', $report.Path, '--port', $report.Port
                ) -WorkingDirectory (Get-Location).Path
            }
            catch {
                Write-Warning "Could not open $($report.Path): $_"
            }
        }
        else {
            Write-Warning "Report not found: $($report.Path)/index.html"
        }
    }
}

if ($failed.Count -gt 0) {
    Write-Host "Failed suites: $($failed -join ', ')" -ForegroundColor Red
    exit 1
}

Write-Host 'All suites passed.' -ForegroundColor Green
