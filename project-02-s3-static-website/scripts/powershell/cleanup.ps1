<#
.SYNOPSIS
Cleans up the deployed S3 resources.
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

$BucketName = $env:BUCKET_NAME
$Region = $env:AWS_REGION
$DistId = $env:DISTRIBUTION_ID

Write-Host "NOTE: For CloudFront distribution ($DistId), please disable and delete it via the AWS Console." -ForegroundColor Yellow
Write-Host "CloudFront -> Distributions -> Select yours -> Disable -> wait 5 min -> Delete" -ForegroundColor Yellow

if (-not [string]::IsNullOrEmpty($BucketName)) {
    Write-Host "Emptying S3 bucket: $BucketName..." -ForegroundColor Cyan
    aws s3 rm s3://$BucketName --recursive

    Write-Host "Deleting S3 bucket: $BucketName..." -ForegroundColor Cyan
    aws s3api delete-bucket --bucket $BucketName --region $Region
}

Write-Host "S3 Cleanup complete." -ForegroundColor Green
