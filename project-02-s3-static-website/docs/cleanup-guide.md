# Cleanup Guide

This guide covers the systematic tear-down of the infrastructure.

## 🧹 CLEANS UP RESOURCES

### 🖥️ Method 1: AWS Management Console
*(Refer to script comments for UI cleanup steps)*

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
# Load environment variables
if [ -f "../../.env" ]; then
    source ../../.env
elif [ -f "../.env" ]; then
    source ../.env
elif [ -f ".env" ]; then
    source .env
else
    echo -e "\e[31mError: .env file not found.\e[0m"
    exit 1
fi

echo -e "\e[33mNOTE: For CloudFront distribution ($DISTRIBUTION_ID), please disable and delete it via the AWS Console.\e[0m"
echo -e "\e[33mCloudFront -> Distributions -> Select yours -> Disable -> wait 5 min -> Delete\e[0m"

if [ -n "$BUCKET_NAME" ]; then
    echo -e "\e[36mEmptying S3 bucket: $BUCKET_NAME...\e[0m"
    aws s3 rm s3://"$BUCKET_NAME" --recursive

    echo -e "\e[36mDeleting S3 bucket: $BUCKET_NAME...\e[0m"
    aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
fi

echo -e "\e[32mS3 Cleanup complete.\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
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
```
