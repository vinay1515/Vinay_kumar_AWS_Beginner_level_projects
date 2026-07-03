<#
.SYNOPSIS
Deploys the static website to S3.
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

if ([string]::IsNullOrEmpty($BucketName) -or [string]::IsNullOrEmpty($Region)) {
    Write-Host "Error: BUCKET_NAME and AWS_REGION must be set in .env" -ForegroundColor Red
    exit 1
}

Write-Host "Creating S3 bucket: $BucketName in region $Region..." -ForegroundColor Cyan
if ($Region -eq "us-east-1") {
    aws s3api create-bucket --bucket $BucketName --region $Region
} else {
    aws s3api create-bucket --bucket $BucketName --region $Region --create-bucket-configuration LocationConstraint=$Region
}

Write-Host "Disabling block public access..." -ForegroundColor Cyan
aws s3api put-public-access-block `
  --bucket $BucketName `
  --public-access-block-configuration `
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

Write-Host "Enabling static website hosting..." -ForegroundColor Cyan
aws s3api put-bucket-website `
  --bucket $BucketName `
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
  }'

Write-Host "Applying bucket policy..." -ForegroundColor Cyan
aws s3api put-bucket-policy `
  --bucket $BucketName `
  --policy "{
    `"Version`":`"2012-10-17`",
    `"Statement`":[{
      `"Sid`":`"PublicReadGetObject`",
      `"Effect`":`"Allow`",
      `"Principal`":`"*`",
      `"Action`":`"s3:GetObject`",
      `"Resource`":`"arn:aws:s3:::$BucketName/*`"
    }]
  }"

$SourcePath = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\..\website"
if (-not (Test-Path $SourcePath)) {
    $SourcePath = ".\website"
}

Write-Host "Syncing files from $SourcePath to S3 bucket: $BucketName..." -ForegroundColor Cyan
aws s3 sync $SourcePath s3://$BucketName/ --region $Region

Write-Host "Deployment complete. Bucket Website URL: http://$BucketName.s3-website-$Region.amazonaws.com" -ForegroundColor Green
