<#
.SYNOPSIS
Invalidates the CloudFront cache.
#>

# Load environment variables
$envFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\..\.env"
if (-not (Test-Path $envFile)) {
    $envFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\.env"
}
if (-not (Test-Path $envFile)) {
    $envFile = ".env"
}

if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^export\s+([^=]+)=(.*)$' } | ForEach-Object {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim(' "''')
        Set-Item -Path "env:\$name" -Value $value
    }
} else {
    Write-Host "Error: .env file not found." -ForegroundColor Red
    exit 1
}

$DistId = $env:DISTRIBUTION_ID

if ([string]::IsNullOrEmpty($DistId)) {
    Write-Host "Error: DISTRIBUTION_ID must be set in .env" -ForegroundColor Red
    exit 1
}

Write-Host "Creating CloudFront cache invalidation for distribution: $DistId..." -ForegroundColor Cyan
aws cloudfront create-invalidation `
  --distribution-id $DistId `
  --paths "/*"

Write-Host "Invalidation request submitted." -ForegroundColor Green
