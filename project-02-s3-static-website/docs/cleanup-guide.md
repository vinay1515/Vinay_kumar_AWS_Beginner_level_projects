# 🧹 Cleanup Guide

This guide covers the systematic tear-down of the infrastructure deployed for the static website on S3 and CloudFront.

> [!CAUTION]
> **This action is irreversible.** All resources listed below will be permanently deleted, including your website files stored in S3.

## 📋 Resources to Delete

| # | Resource | Service | Deletion Order Reason |
|:---:|:---|:---|:---|
| 1 | CloudFront Distribution | CloudFront | Must be disabled before it can be deleted |
| 2 | S3 Bucket Objects | S3 | Bucket must be completely empty before deletion |
| 3 | S3 Bucket | S3 | Cannot be deleted while containing objects |

## 🖥️ Method 1: AWS Management Console

1. **Delete CloudFront Distribution:**
   - Go to **CloudFront** → **Distributions**
   - Select your distribution
   - Click **Disable** (Wait 3–5 minutes for the status to change from Deploying to Disabled)
   - Once disabled, select the distribution again and click **Delete**
2. **Empty and Delete S3 Bucket:**
   - Go to **S3** → **Buckets**
   - Select your bucket
   - Click **Empty** → Type `permanently delete` to confirm
   - Click **Delete** → Type the bucket name to confirm

## 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
# =============================================================================
# Project 02 — Cleanup: Tears down S3 and CloudFront
# =============================================================================

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

echo -e "\e[36m=== Project 02 — Full Cleanup ===\e[0m"

echo -e "\e[33mNOTE: For CloudFront distribution ($DISTRIBUTION_ID), please disable and delete it via the AWS Console.\e[0m"
echo -e "\e[33mCloudFront -> Distributions -> Select yours -> Disable -> wait 5 min -> Delete\e[0m"
echo -e "\e[90m(Automating CloudFront deletion via CLI requires managing ETag constraints which is beyond the scope of this beginner script.)\e[0m"

if [ -n "$BUCKET_NAME" ]; then
    echo -e "\e[33m[1/2] Emptying S3 bucket: $BUCKET_NAME...\e[0m"
    aws s3 rm s3://"$BUCKET_NAME" --recursive

    echo -e "\e[33m[2/2] Deleting S3 bucket: $BUCKET_NAME...\e[0m"
    aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
fi

echo -e "\e[32m================================================\e[0m"
echo -e "\e[32m  S3 Cleanup complete!\e[0m"
echo -e "\e[32m================================================\e[0m"
```

## 🪟 Method 3: AWS CLI (PowerShell)
```powershell
<#
.SYNOPSIS
Project 02 — Cleanup: Tears down S3 and CloudFront.
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

Write-Host "=== Project 02 — Full Cleanup ===" -ForegroundColor Cyan

Write-Host "NOTE: For CloudFront distribution ($DistId), please disable and delete it via the AWS Console." -ForegroundColor Yellow
Write-Host "CloudFront -> Distributions -> Select yours -> Disable -> wait 5 min -> Delete" -ForegroundColor Yellow

if (-not [string]::IsNullOrEmpty($BucketName)) {
    Write-Host "[1/2] Emptying S3 bucket: $BucketName..." -ForegroundColor Yellow
    aws s3 rm s3://$BucketName --recursive

    Write-Host "[2/2] Deleting S3 bucket: $BucketName..." -ForegroundColor Yellow
    aws s3api delete-bucket --bucket $BucketName --region $Region
}

Write-Host "================================================" -ForegroundColor Green
Write-Host "  S3 Cleanup complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
```

## ✅ Cleanup Verification

Run these commands to confirm all resources have been deleted:

```bash
# Verify S3 Bucket is gone
aws s3api head-bucket --bucket "$BUCKET_NAME" 2>&1 | grep "Not Found"

# Verify CloudFront Distribution is gone
aws cloudfront get-distribution --id "$DISTRIBUTION_ID" 2>&1 | grep "NoSuchDistribution"
```

## 💰 Cost Implications

Since this project resides within the Free Tier limits (5GB storage, 1TB CloudFront transfer out), leaving it running indefinitely typically costs **$0.00**.

However, if you exceed Free Tier limits, you would be charged:
- S3 Storage: $0.023 per GB/month
- CloudFront Data Transfer Out: $0.085 per GB
