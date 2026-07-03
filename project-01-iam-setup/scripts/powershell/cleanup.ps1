<#
.SYNOPSIS
Cleans up the deployed IAM and billing alarm resources.
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
}
else {
    Write-Host "Error: .env file not found." -ForegroundColor Red
    exit 1
}

$Region = $env:AWS_REGION
$AccountId = (aws sts get-caller-identity --query Account --output text).Trim()

Write-Host "Deleting CloudWatch Alarm..." -ForegroundColor Cyan
aws cloudwatch delete-alarms --alarm-names "AccountBillingAlarm"

Write-Host "Deleting SNS Topic..." -ForegroundColor Cyan
aws sns delete-topic --topic-arn "arn:aws:sns:${Region}:${AccountId}:billing-alerts"
Write-Host "NOTE: For IAM User Cleanup, please manually detach policies, delete access keys, and then delete the user." -ForegroundColor Yellow
Write-Host "Example:" -ForegroundColor Yellow
Write-Host "aws iam detach-user-policy --user-name <YourUserName> --policy-arn arn:aws:iam::aws:policy/AdministratorAccess"
Write-Host "aws iam delete-login-profile --user-name <YourUserName>"
Write-Host "aws iam delete-access-key --user-name <YourUserName> --access-key-id <YourAccessKeyId>"
Write-Host "aws iam delete-user --user-name <YourUserName>"

Write-Host "Initial Cleanup complete." -ForegroundColor Green
