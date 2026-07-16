# 🧹 Cleanup Guide

This guide covers the systematic tear-down of the Serverless REST API infrastructure.

> [!CAUTION]
> **This action is irreversible.** All resources listed below will be permanently deleted. Ensure you no longer need the API endpoints or the data stored in the DynamoDB table before proceeding.

## 📋 Resources to Delete

| # | Resource | Service | Deletion Order Reason |
|:---:|:---|:---|:---|
| 1 | API Gateway | API Gateway | Removes the public endpoint pointing to Lambda |
| 2 | Lambda Function | Lambda | Removes the compute logic |
| 3 | DynamoDB Table | DynamoDB | Deletes the database and all stored records |
| 4 | IAM Role & Policy | IAM | Deletes the execution permissions (must detach policies first) |
| 5 | CloudWatch Log Group | CloudWatch Logs | Deletes the execution logs for the function |

## 🖥️ Method 1: AWS Management Console

1. Go to **API Gateway** → Select `users-api` → Click **Delete** → Confirm.
2. Go to **Lambda** → **Functions** → Select `users-api` → Click **Actions** → **Delete**.
3. Go to **DynamoDB** → **Tables** → Select `users` table → Click **Delete** → Type `delete` to confirm.
4. Go to **IAM** → **Roles** → Search for `lambda-users-api-role`:
   - Click the role
   - Remove the `dynamodb-users-access` inline policy
   - Remove the `AWSLambdaBasicExecutionRole` managed policy
   - Click **Delete role**
5. Go to **CloudWatch** → **Log Groups** → Select `/aws/lambda/users-api` → Click **Actions** → **Delete log group**.

## 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash
# =============================================================================
# Project 08 — Cleanup: Tears down the entire Serverless REST API
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 08 — Full Cleanup ===\e[0m"

# Get API ID
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text 2>/dev/null)

# Step 1 - Delete API Gateway
if [ "$API_ID" != "None" ] && [ -n "$API_ID" ]; then
  echo -e "\e[33m[1/5] Deleting API Gateway...\e[0m"
  aws apigateway delete-rest-api --rest-api-id "$API_ID"
  echo -e "\e[32m  API Gateway deleted\e[0m"
else
  echo -e "\e[90m  API Gateway not found.\e[0m"
fi

# Step 2 - Delete Lambda function
echo -e "\e[33m[2/5] Deleting Lambda function...\e[0m"
if aws lambda delete-function --function-name users-api 2>/dev/null; then
  echo -e "\e[32m  Lambda deleted\e[0m"
else
  echo -e "\e[90m  Lambda not found.\e[0m"
fi

# Step 3 - Delete DynamoDB table
echo -e "\e[33m[3/5] Deleting DynamoDB table...\e[0m"
if aws dynamodb delete-table --table-name users 2>/dev/null; then
  echo -e "\e[32m  DynamoDB table deleted\e[0m"
else
  echo -e "\e[90m  DynamoDB table not found.\e[0m"
fi

# Step 4 - Delete IAM role
echo -e "\e[33m[4/5] Deleting IAM role...\e[0m"
ROLE_NAME="lambda-users-api-role"
aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name dynamodb-users-access 2>/dev/null
aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null
if aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null; then
  echo -e "\e[32m  IAM role deleted\e[0m"
else
  echo -e "\e[90m  IAM role not found.\e[0m"
fi

# Step 5 - Delete CloudWatch log group
echo -e "\e[33m[5/5] Deleting CloudWatch log group...\e[0m"
if aws logs delete-log-group --log-group-name "/aws/lambda/users-api" 2>/dev/null; then
  echo -e "\e[32m  Log group deleted\e[0m"
else
  echo -e "\e[90m  Log group not found.\e[0m"
fi

echo -e "\e[32m================================================\e[0m"
echo -e "\e[32m  Project 08 Cleanup Complete!\e[0m"
echo -e "\e[32m================================================\e[0m"
```

## 🪟 Method 3: AWS CLI (PowerShell)

```powershell
<#
.SYNOPSIS
Project 08 — Cleanup: Tears down the entire Serverless REST API.
#>

Write-Host "=== Project 08 — Full Cleanup ===" -ForegroundColor Cyan

# Get API ID
$API_ID = aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text 2>$null

# Step 1 - Delete API Gateway
Write-Host "[1/5] Deleting API Gateway..." -ForegroundColor Yellow
if ($API_ID -ne "None" -and $API_ID -ne "") {
  aws apigateway delete-rest-api --rest-api-id $API_ID
  Write-Host "  API Gateway deleted" -ForegroundColor Green
} else {
  Write-Host "  API Gateway not found." -ForegroundColor DarkGray
}

# Step 2 - Delete Lambda function
Write-Host "[2/5] Deleting Lambda function..." -ForegroundColor Yellow
aws lambda delete-function --function-name users-api 2>$null
Write-Host "  Lambda deletion attempted" -ForegroundColor Green

# Step 3 - Delete DynamoDB table
Write-Host "[3/5] Deleting DynamoDB table..." -ForegroundColor Yellow
aws dynamodb delete-table --table-name users 2>$null
Write-Host "  DynamoDB deletion attempted" -ForegroundColor Green

# Step 4 - Delete IAM role
Write-Host "[4/5] Deleting IAM role..." -ForegroundColor Yellow
$RoleName = "lambda-users-api-role"
aws iam delete-role-policy --role-name $RoleName --policy-name dynamodb-users-access 2>$null
aws iam detach-role-policy --role-name $RoleName --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>$null
aws iam delete-role --role-name $RoleName 2>$null
Write-Host "  IAM role deletion attempted" -ForegroundColor Green

# Step 5 - Delete CloudWatch log group
Write-Host "[5/5] Deleting CloudWatch log group..." -ForegroundColor Yellow
aws logs delete-log-group --log-group-name "/aws/lambda/users-api" 2>$null
Write-Host "  Log group deletion attempted" -ForegroundColor Green

Write-Host "================================================" -ForegroundColor Green
Write-Host "  Project 08 Cleanup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
```

## ✅ Cleanup Verification

Run these commands to confirm all resources have been deleted:

```bash
# Verify API Gateway is gone
aws apigateway get-rest-apis --query "items[?name=='users-api']"

# Verify Lambda is gone
aws lambda get-function --function-name users-api 2>&1 | grep "ResourceNotFoundException"

# Verify DynamoDB table is gone
aws dynamodb describe-table --table-name users 2>&1 | grep "ResourceNotFoundException"
```

## 💰 Cost Implications

Because this project is entirely serverless, leaving it running costs **$0.00** if it receives no traffic.
However, it's a best practice to clean up unused resources to keep your account tidy and prevent accidental future charges if the endpoint was discovered or left in a script.
