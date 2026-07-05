# Comprehensive Deployment Guide

This guide details the complete process for deploying a serverless static website to Amazon S3, mimicking how frontend applications are hosted in production.

---

## 🚀 PRE-FLIGHT CHECKS

Before deploying cloud infrastructure, always validate your terminal session identity to ensure you are not accidentally deploying resources to the wrong AWS account.

Run these commands in PowerShell or Bash:
```powershell
# Confirm you are authenticated as the IAM Administrator (from Project 01)
aws sts get-caller-identity

# Confirm your default region
aws configure get region
```

---

## 🏗️ PART 1 — PROVISION THE S3 BUCKET

We must first create the logical container for our website code.

### 🖥️ Method 1: AWS Management Console
1. Navigate to **S3** → **Create bucket**.
2. **Bucket name**: `portfolio-website-yourname` (Must be globally unique. Do not use spaces or uppercase letters).
3. **Region**: `US East (N. Virginia) us-east-1` (or your preferred region).
4. **Object Ownership**: ACLs disabled (default).
5. **Block Public Access settings for this bucket**: 
   - **CRITICAL:** Uncheck the box that says "Block *all* public access".
   - Check the warning box acknowledging that the current settings might result in this bucket and the objects within becoming public.
6. Click **Create bucket**.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
source ../../.env
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"

```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$BUCKET_NAME = (Get-Content ..\..\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
$AWS_REGION = (Get-Content ..\..\.env | Where-Object { $_ -match '^AWS_REGION=' } | ForEach-Object { $_ -replace '^AWS_REGION=','' })
aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION

```
---

## ⚙️ PART 2 — ENABLE STATIC WEBSITE HOSTING

By default, S3 acts as a storage drive. We must tell it to act as a web server.

### 🖥️ Method 1: AWS Management Console
1. Click your newly created bucket to open it.
2. Navigate to the **Properties** tab.
3. Scroll all the way to the bottom to **Static website hosting**.
4. Click **Edit**.
5. Select **Enable**.
6. **Hosting type:** Host a static website.
7. **Index document:** Type `index.html` (This tells S3 which file to load when a user hits the root URL).
8. **Error document:** Type `error.html` (Optional, but best practice for custom 404 pages).
9. Click **Save changes**.
10. Scroll back down to **Static website hosting** and **copy the Bucket website endpoint URL**. You will need this later.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
source ../../.env
aws s3api put-bucket-website --bucket "$BUCKET_NAME" --website-configuration '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}}'

```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$BUCKET_NAME = (Get-Content ..\..\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}}'

```
---

## 🔐 PART 3 — APPLY THE PUBLIC BUCKET POLICY

Even though we turned off the "Block Public Access" kill-switch, the files inside the bucket are still private by default. We must apply a JSON policy to grant the world read-access.

### 🖥️ Method 1: AWS Management Console
1. Navigate to the **Permissions** tab of your bucket.
2. Scroll to **Bucket policy** and click **Edit**.
3. Paste the following JSON policy. **You MUST replace `YOUR-BUCKET-NAME` with your actual bucket name.**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```
4. Click **Save changes**. You will now see a red "Public" tag attached to your bucket. This is expected and desired for a public website.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
source ../../.env
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy '{"Version":"2012-10-17","Statement":[{"Sid":"PublicReadGetObject","Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::'"$BUCKET_NAME"'/*"}]}'

```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$BUCKET_NAME = (Get-Content ..\..\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "{\`"Version\`":\`"2012-10-17\`",\`"Statement\`":[{\`"Sid\`":\`"PublicReadGetObject\`",\`"Effect\`":\`"Allow\`",\`"Principal\`":\`"*\`",\`"Action\`":\`"s3:GetObject\`",\`"Resource\`":\`"arn:aws:s3:::$BUCKET_NAME/*\`"}]}"

```
---

## 🚀 PART 4 — DEPLOY THE WEBSITE CODE

We will use the AWS CLI to rapidly sync a local directory of code to the S3 bucket.

### 🖥️ Method 1: AWS Management Console
1. Navigate to your bucket.
2. Click **Upload**.
3. Click **Add files** and select your `index.html` and `style.css`.
4. Click **Upload**.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
source ../../.env
aws s3 sync ../../website/ s3://"$BUCKET_NAME"/ --region "$AWS_REGION"

```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$BUCKET_NAME = (Get-Content ..\..\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
$AWS_REGION = (Get-Content ..\..\.env | Where-Object { $_ -match '^AWS_REGION=' } | ForEach-Object { $_ -replace '^AWS_REGION=','' })
aws s3 sync ..\..\website\ s3://$BUCKET_NAME/ --region $AWS_REGION

```

---

## 🌐 PART 5 — VALIDATE THE LIVE WEBSITE

### 🖥️ Method 1: AWS Management Console
1. Open your web browser.
2. Paste the **Bucket website endpoint URL** you copied in Part 2.
3. You should see the custom HTML portfolio page rendered perfectly in your browser!

### 🐧 Method 2: AWS CLI (Bash)
*(Validation is a visual check in the browser. See Method 1)*

### 🪟 Method 3: AWS CLI (PowerShell)
*(Validation is a visual check in the browser. See Method 1)*

---

## ⚡ PART 7 — INVALIDATE CLOUDFRONT CACHE (Optional)
If you attach CloudFront to this bucket in the future, use these scripts to force a cache refresh when you upload new code.

### 🖥️ Method 1: AWS Management Console
*(CloudFront invalidation can be done via CloudFront -> Invalidations -> Create Invalidation in the UI)*

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

if [ -z "$DISTRIBUTION_ID" ]; then
    echo -e "\e[31mError: DISTRIBUTION_ID must be set in .env\e[0m"
    exit 1
fi

echo -e "\e[36mCreating CloudFront cache invalidation for distribution: $DISTRIBUTION_ID...\e[0m"
aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*"

echo -e "\e[32mInvalidation request submitted.\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
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
```

---

## 🧹 PART 8 — CLEANUP
Use these scripts to empty and delete the bucket to stop incurring storage costs.

### 🖥️ Method 1: AWS Management Console
1. Go to S3.
2. Select your bucket and click **Empty**. Confirm by typing the bucket name.
3. Select your bucket again and click **Delete**. Confirm by typing the bucket name.


### 🐧 Method 1: AWS CLI (Bash)
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
