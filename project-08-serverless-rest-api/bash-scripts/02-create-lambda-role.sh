#!/bin/bash

# =============================================================================
# Project 8 — Script 02: Create Lambda IAM Role
# Creates execution role with CloudWatch Logs + scoped DynamoDB access
# =============================================================================

echo -e "\e[36m=== Project 8 — Create Lambda IAM Role ===\e[0m"
echo ""

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $ACCOUNT_ID"
echo ""

# ── CREATE ROLE ───────────────────────────────────────────────────────────────
echo -e "\e[33m[1/4] Creating role: lambda-users-api-role...\e[0m"

aws iam create-role \
  --role-name lambda-users-api-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' | Out-Null

echo -e "\e[32mRole created.\e[0m"

# ── ATTACH BASIC EXECUTION POLICY ────────────────────────────────────────────
echo -e "\e[33m[2/4] Attaching AWSLambdaBasicExecutionRole (CloudWatch Logs)...\e[0m"

aws iam attach-role-policy \
  --role-name lambda-users-api-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

echo -e "\e[32mManaged policy attached.\e[0m"

# ── ADD DYNAMODB INLINE POLICY ────────────────────────────────────────────────
echo -e "\e[33m[3/4] Adding DynamoDB inline policy (least privilege)...\e[0m"

DYNAMODB_POLICY="{
  \"Version\": \"2012-10-17\",
  \"Statement\": [{
    \"Effect\": \"Allow\",
    \"Action\": [
      \"dynamodb:GetItem\",
      \"dynamodb:PutItem\",
      \"dynamodb:UpdateItem\",
      \"dynamodb:DeleteItem\",
      \"dynamodb:Scan\",
      \"dynamodb:Query\"
    ],
    \"Resource\": \"arn:aws:dynamodb:us-east-1:${ACCOUNT_ID}:table/users\"
  }]
}"

aws iam put-role-policy \
  --role-name lambda-users-api-role \
  --policy-name dynamodb-users-access \
  --policy-document $DYNAMODB_POLICY

echo -e "\e[32mDynamoDB policy attached (scoped to table/users ARN).\e[0m"

# ── GET ROLE ARN ──────────────────────────────────────────────────────────────
echo -e "\e[33m[4/4] Fetching role ARN...\e[0m"

LAMBDA_ROLE_ARN=$(aws iam get-role \
  --role-name lambda-users-api-role \
  --query "Role.Arn" --output text)

echo -e "\e[32mRole ARN: $LAMBDA_ROLE_ARN\e[0m"

# IAM propagation delay
echo ""
echo -e "\e[33mWaiting 10 seconds for IAM changes to propagate globally...\e[0m"
sleep 10
echo -e "\e[32mReady.\e[0m"

echo ""
echo -e "\e[36m=== IAM Role Complete ===\e[0m"
echo "  LAMBDA_ROLE_ARN = $LAMBDA_ROLE_ARN"
echo ""
echo -e "\e[36mNext step: Run 03-package-lambda.ps1\e[0m"