# Cleanup Guide

This guide covers the systematic tear-down of the infrastructure provisioned in this project. 

> [!WARNING]  
> Since this project sets up the foundational IAM access for subsequent projects in this portfolio, you typically **do not** want to clean this up immediately. However, if you need to tear down the environment, follow these steps.

## 🧹 INFRASTRUCTURE TEARDOWN

### 🖥️ Method 1: AWS Management Console
1. Go to **CloudWatch** -> Alarms and delete `AccountBillingAlarm`.
2. Go to **SNS** -> Topics and delete the `billing-alerts` topic.
3. Go to **IAM** -> Users. Select your created admin user, delete their access keys under Security Credentials, and then delete the user.
4. Go to **IAM** -> User groups and delete the `Administrators` group.

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

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "\e[36mDeleting CloudWatch Alarm...\e[0m"
aws cloudwatch delete-alarms --alarm-names "AccountBillingAlarm"

echo -e "\e[36mDeleting SNS Topic...\e[0m"
aws sns delete-topic --topic-arn "arn:aws:sns:$AWS_REGION:$ACCOUNT_ID:billing-alerts"

echo -e "\e[33mNOTE: For IAM User Cleanup, please manually detach policies, delete access keys, and then delete the user.\e[0m"
echo -e "\e[33mExample:\e[0m"
echo -e "aws iam detach-user-policy --user-name <YourUserName> --policy-arn arn:aws:iam::aws:policy/AdministratorAccess"
echo -e "aws iam delete-login-profile --user-name <YourUserName>"
echo -e "aws iam delete-access-key --user-name <YourUserName> --access-key-id <YourAccessKeyId>"
echo -e "aws iam delete-user --user-name <YourUserName>"

echo -e "\e[32mInitial Cleanup complete.\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
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
```
