# Cleanup Guide

This guide covers the systematic tear-down of the infrastructure.

## 🧹 CLEAN UP ALL AWS RESOURCES

### 🖥️ Method 1: AWS Management Console
*(Refer to script comments for UI cleanup steps)*

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
# Get API ID
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text)

# Step 1 - Delete API Gateway
if [ "$API_ID" != "None" ] && [ -n "$API_ID" ]; then
  aws apigateway delete-rest-api --rest-api-id $API_ID
  echo "API Gateway deleted"
fi

# Step 2 - Delete Lambda function
aws lambda delete-function --function-name users-api
echo "Lambda deleted"

# Step 3 - Delete DynamoDB table
aws dynamodb delete-table --table-name users
echo "DynamoDB table deleted"

# Step 4 - Delete IAM role
aws iam delete-role-policy --role-name lambda-users-api-role --policy-name dynamodb-users-access
aws iam detach-role-policy --role-name lambda-users-api-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda-users-api-role
echo "IAM role deleted"

# Step 5 - Delete CloudWatch log group
aws logs delete-log-group --log-group-name "/aws/lambda/users-api"
echo "Log group deleted"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Get API ID
$API_ID = aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text

# Step 1 - Delete API Gateway
if ($API_ID -ne "None" -and $API_ID -ne "") {
  aws apigateway delete-rest-api --rest-api-id $API_ID
  Write-Host "API Gateway deleted"
}

# Step 2 - Delete Lambda function
aws lambda delete-function --function-name users-api
Write-Host "Lambda deleted"

# Step 3 - Delete DynamoDB table
aws dynamodb delete-table --table-name users
Write-Host "DynamoDB table deleted"

# Step 4 - Delete IAM role
aws iam delete-role-policy --role-name lambda-users-api-role --policy-name dynamodb-users-access
aws iam detach-role-policy --role-name lambda-users-api-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda-users-api-role
Write-Host "IAM role deleted"

# Step 5 - Delete CloudWatch log group
aws logs delete-log-group --log-group-name "/aws/lambda/users-api"
Write-Host "Log group deleted"
```
