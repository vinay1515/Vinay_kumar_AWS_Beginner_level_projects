#!/bin/bash

#Requires -Version 5.1
<#
.SYNOPSIS
Tears down all resources created for Project 8 to ensure a clean AWS environment.
#>

# Parameterized for safety, but defaults to the project values
API_NAME="users-api"
LAMBDA_NAME="users-api"
TABLE_NAME="users"
ROLE_NAME="lambda-users-api-role"

echo -e "\e[36mStarting environment cleanup...\e[0m"

# 1. Delete API Gateway
echo -e "\e[33mFinding and deleting API Gateway...\e[0m"
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text)
if ($API_ID) {
  aws apigateway delete-rest-api --rest-api-id $API_ID
echo "API Gateway deleted."
}

# 2. Delete Lambda
echo -e "\e[33mDeleting Lambda function...\e[0m"
aws lambda delete-function --function-name $LAMBDA_NAME
echo "Lambda deleted."

# 3. Delete DynamoDB
echo -e "\e[33mDeleting DynamoDB table...\e[0m"
aws dynamodb delete-table --table-name $TABLE_NAME | Out-Null
echo "DynamoDB table deleted."

# 4. Delete IAM Role and Policies
echo -e "\e[33mCleaning up IAM roles and policies...\e[0m"
aws iam delete-role-policy \
  --role-name $ROLE_NAME \
  --policy-name dynamodb-users-access

aws iam detach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam delete-role --role-name $ROLE_NAME
echo "IAM role deleted."

# 5. Delete Log Group
echo -e "\e[33mDeleting CloudWatch log group...\e[0m"
aws logs delete-log-group --log-group-name "/aws/lambda/$LAMBDA_NAME"
echo "Log group deleted."

echo -e "\e[32mCleanup complete.\e[0m"