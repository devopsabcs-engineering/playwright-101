#!/usr/bin/env pwsh
# Runs all Playwright tests in this project.

$ErrorActionPreference = 'Stop'
Set-Location -Path (Join-Path $PSScriptRoot '..\playwright-tests')

if (-not (Test-Path 'node_modules')) {
    Write-Host 'Installing dependencies...' -ForegroundColor Cyan
    npm install
    npx playwright install
}

Write-Host 'Running Playwright tests...' -ForegroundColor Cyan
$env:PLAYWRIGHT_SCREENSHOT = 'on'
npx playwright test
