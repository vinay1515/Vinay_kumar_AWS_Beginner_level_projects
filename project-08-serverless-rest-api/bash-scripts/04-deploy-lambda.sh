#!/bin/bash

# =============================================================================
# Project 8 — Script 04: Deploy Lambda Function
# Creates the users-api Lambda function and tests it directly
# =============================================================================

echo -e "\e[36m=== Project 8 — Deploy Lambda Function ===\e[0m"
echo ""

if (-not $LAMBDA_ROLE_ARN) {
    LAMBDA_ROLE_ARN=$(aws iam get-role \
      --role-name lambda-users-api-role \
      --query "Role.Arn" --output text)
echo "Fetched role ARN: $LAMBDA_ROLE_ARN"
}

if (-not (Test-Path "lambda\function.zip")) {
echo -e "\e[31mERROR: lambda\function.zip not found. Run 03-package-lambda.ps1 first.\e[0m"
    exit 1
}

# ── DEPLOY ────────────────────────────────────────────────────────────────────
echo -e "\e[33mDeploying Lambda function: users-api...\e[0m"
echo "  Runtime:  python3.12"
echo "  Memory:   128 MB"
echo "  Timeout:  30 seconds"
echo "  Handler:  lambda_function.lambda_handler"
echo ""

LAMBDA_ARN=$(aws lambda create-function \
  --function-name users-api \
  --runtime python3.12 \
  --role $LAMBDA_ROLE_ARN \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda/function.zip \
  --timeout 30 \
  --memory-size 128 \
  --description "Serverless Users CRUD API — Project 8" \
  --environment Variables="{TABLE_NAME=users,REGION=us-east-1}" \
  --tags Project=project-08-serverless \
  --query "FunctionArn" --output text)

echo -e "\e[32mLambda ARN: $LAMBDA_ARN\e[0m"
echo -e "\e[33mWaiting for function to become active...\e[0m"

aws lambda wait function-active --function-name users-api
echo -e "\e[32mFunction is active.\e[0m"

# ── VERIFY CONFIGURATION ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33mFunction configuration:\e[0m"
aws lambda get-function-configuration \
  --function-name users-api \
  --query "Configuration.{Name:FunctionName,Runtime:Runtime,State:State,Memory:MemorySize,Timeout:Timeout,Handler:Handler}" \
  --output table

# ── DIRECT TEST ───────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mRunning direct Lambda test (GET /users)...\e[0m"

aws lambda invoke \
  --function-name users-api \
  --payload '{"httpMethod":"GET","path":"/users","pathParameters":null}' \
  --cli-binary-format raw-in-base64-out \
  response.json | Out-Null

result=Get-Content response.json | jq .
echo "Status code: $($result.statusCode)"
if ($result.statusCode -eq 200) {
echo -e "\e[32mLambda test PASSED.\e[0m"
} else {
echo -e "\e[33mLambda test returned unexpected status. Check CloudWatch Logs.\e[0m"
echo "Logs: aws logs tail /aws/lambda/users-api --follow"
}

echo ""
echo -e "\e[36m=== Lambda Deployment Complete ===\e[0m"
echo "  LAMBDA_ARN = $LAMBDA_ARN"
echo ""
echo -e "\e[36mNext step: Run 05-create-api-gateway.ps1\e[0m"