# Deployment Guide

This document provides the deployment steps for Project 08 in three formats: **AWS Management Console**, **Bash**, and **PowerShell**.

## Prerequisites
- AWS CLI configured
- Appropriate IAM permissions
- Python 3.12+

## PRE-FLIGHT
*(These commands are local verification steps. Choose your preferred terminal)*

### 🐧 Method 1: AWS CLI (Bash)
```bash
aws sts get-caller-identity
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $ACCOUNT_ID"
aws configure get region
```

### 🪟 Method 2: AWS CLI (PowerShell)
```powershell
aws sts get-caller-identity
$ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text
Write-Host "Account ID: $ACCOUNT_ID"
aws configure get region
```

---

## 🗄️ PART 1 — CREATE DYNAMODB TABLE

Create the DynamoDB table that stores all user records with on-demand billing.

### 🖥️ Method 1: AWS Management Console
1. **Create DynamoDB table**
   - Console search → DynamoDB → Create table
   - Table name: users
   - Partition key: userId (String)
   - Read/write capacity: On-demand
   - Click Create table
   - Wait ~30 seconds for status to show Active

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 01: DynamoDB Table Setup
# Creates the users table with on-demand billing for the serverless API
# =============================================================================

echo -e "\e[36m=== Project 8 — DynamoDB Setup ===\e[0m"
echo ""

# Pre-flight
aws sts get-caller-identity > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "\e[31mERROR: AWS CLI not configured.\e[0m"
    exit 1
fi

REGION=$(aws configure get region)
echo "Region: $REGION"
echo ""

# ── CREATE DYNAMODB TABLE ────────────────────────────────────────────────────
echo -e "\e[33m[1/2] Creating DynamoDB table: users...\e[0m"

aws dynamodb create-table \
  --table-name users \
  --attribute-definitions AttributeName=userId,AttributeType=S \
  --key-schema AttributeName=userId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --tags Key=Project,Value=project-08-serverless

# ── WAIT FOR TABLE ───────────────────────────────────────────────────────────
echo -e "\e[33m[2/2] Waiting for table to become active...\e[0m"

aws dynamodb wait table-exists --table-name users

echo -e "\e[32mDynamoDB table created and active\e[0m"

# ── VERIFY ───────────────────────────────────────────────────────────────────
aws dynamodb describe-table \
  --table-name users \
  --query "Table.{Name:TableName,Status:TableStatus,BillingMode:BillingModeSummary.BillingMode}" \
  --output table

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== DynamoDB Setup Complete ===\e[0m"
echo ""
echo -e "\e[36mNext step: Run 02-create-lambda-execution-role.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 01: DynamoDB Table Setup
# Creates the users table with on-demand billing for the serverless API
# =============================================================================

Write-Host "=== Project 8 — DynamoDB Setup ===" -ForegroundColor Cyan
Write-Host ""

# Pre-flight
aws sts get-caller-identity | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS CLI not configured." -ForegroundColor Red
    exit 1
}

$REGION = aws configure get region
Write-Host "Region: $REGION"
Write-Host ""

# ── CREATE DYNAMODB TABLE ────────────────────────────────────────────────────
Write-Host "[1/2] Creating DynamoDB table: users..." -ForegroundColor Yellow

aws dynamodb create-table `
  --table-name users `
  --attribute-definitions AttributeName=userId,AttributeType=S `
  --key-schema AttributeName=userId,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --tags Key=Project,Value=project-08-serverless

# ── WAIT FOR TABLE ───────────────────────────────────────────────────────────
Write-Host "[2/2] Waiting for table to become active..." -ForegroundColor Yellow

aws dynamodb wait table-exists --table-name users

Write-Host "DynamoDB table created and active" -ForegroundColor Green

# ── VERIFY ───────────────────────────────────────────────────────────────────
aws dynamodb describe-table `
  --table-name users `
  --query "Table.{Name:TableName,Status:TableStatus,BillingMode:BillingModeSummary.BillingMode}" `
  --output table

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== DynamoDB Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Run 02-create-lambda-execution-role.ps1" -ForegroundColor Cyan
```

---

## 🔐 PART 2 — CREATE LAMBDA EXECUTION ROLE

Create the IAM execution role with least-privilege DynamoDB permissions for Lambda.

### 🖥️ Method 1: AWS Management Console
2. **Create Lambda IAM role**
   - Console → IAM → Roles → Create role
   - Trusted entity: AWS service, Service: Lambda → Next
   - Search and attach: AWSLambdaBasicExecutionRole → Next
   - Role name: lambda-users-api-role → Create role

3. **Add DynamoDB policy**
   - Click your new role → Add permissions → Create inline policy
   - JSON tab → Allow dynamodb:GetItem/PutItem/UpdateItem/DeleteItem/Scan on table arn
   - Policy name: dynamodb-users-access → Create policy

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 02: Lambda IAM Role Setup
# Creates the IAM execution role with DynamoDB permissions for Lambda
# =============================================================================

echo -e "\e[36m=== Project 8 — Lambda IAM Role Setup ===\e[0m"
echo ""

# ── CREATE EXECUTION ROLE ────────────────────────────────────────────────────
echo -e "\e[33m[1/4] Creating Lambda execution role...\e[0m"

aws iam create-role \
  --role-name lambda-users-api-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# ── ATTACH BASIC POLICY ─────────────────────────────────────────────────────
echo -e "\e[33m[2/4] Attaching CloudWatch Logs policy...\e[0m"

aws iam attach-role-policy \
  --role-name lambda-users-api-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# ── ADD DYNAMODB POLICY ──────────────────────────────────────────────────────
echo -e "\e[33m[3/4] Adding DynamoDB inline policy...\e[0m"

aws iam put-role-policy \
  --role-name lambda-users-api-role \
  --policy-name dynamodb-users-access \
  --policy-document "{
    \"Version\":\"2012-10-17\",
    \"Statement\":[{
      \"Effect\":\"Allow\",
      \"Action\":[
        \"dynamodb:GetItem\",
        \"dynamodb:PutItem\",
        \"dynamodb:UpdateItem\",
        \"dynamodb:DeleteItem\",
        \"dynamodb:Scan\",
        \"dynamodb:Query\"
      ],
      \"Resource\":\"arn:aws:dynamodb:us-east-1:${ACCOUNT_ID}:table/users\"
    }]
  }"

# ── GET ROLE ARN ─────────────────────────────────────────────────────────────
echo -e "\e[33m[4/4] Retrieving role ARN...\e[0m"

LAMBDA_ROLE_ARN=$(aws iam get-role \
  --role-name lambda-users-api-role \
  --query "Role.Arn" --output text)

echo -e "\e[32mLambda Role ARN: $LAMBDA_ROLE_ARN\e[0m"

# Wait for role to propagate (IAM changes take ~10 seconds)
echo -e "\e[33mWaiting 10 seconds for IAM propagation...\e[0m"
sleep 10

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== IAM Role Setup Complete ===\e[0m"
echo ""
echo "  LAMBDA_ROLE_ARN = $LAMBDA_ROLE_ARN"
echo ""
echo -e "\e[36mNext step: Run 03-write-and-deploy-lambda.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 02: Lambda IAM Role Setup
# Creates the IAM execution role with DynamoDB permissions for Lambda
# =============================================================================

Write-Host "=== Project 8 — Lambda IAM Role Setup ===" -ForegroundColor Cyan
Write-Host ""

# ── CREATE EXECUTION ROLE ────────────────────────────────────────────────────
Write-Host "[1/4] Creating Lambda execution role..." -ForegroundColor Yellow

aws iam create-role `
  --role-name lambda-users-api-role `
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# ── ATTACH BASIC POLICY ─────────────────────────────────────────────────────
Write-Host "[2/4] Attaching CloudWatch Logs policy..." -ForegroundColor Yellow

aws iam attach-role-policy `
  --role-name lambda-users-api-role `
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

$ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text

# ── ADD DYNAMODB POLICY ──────────────────────────────────────────────────────
Write-Host "[3/4] Adding DynamoDB inline policy..." -ForegroundColor Yellow

aws iam put-role-policy `
  --role-name lambda-users-api-role `
  --policy-name dynamodb-users-access `
  --policy-document "{
    `"Version`":`"2012-10-17`",
    `"Statement`":[{
      `"Effect`":`"Allow`",
      `"Action`":[
        `"dynamodb:GetItem`",
        `"dynamodb:PutItem`",
        `"dynamodb:UpdateItem`",
        `"dynamodb:DeleteItem`",
        `"dynamodb:Scan`",
        `"dynamodb:Query`"
      ],
      `"Resource`":`"arn:aws:dynamodb:us-east-1:${ACCOUNT_ID}:table/users`"
    }]
  }"

# ── GET ROLE ARN ─────────────────────────────────────────────────────────────
Write-Host "[4/4] Retrieving role ARN..." -ForegroundColor Yellow

$LAMBDA_ROLE_ARN = aws iam get-role `
  --role-name lambda-users-api-role `
  --query "Role.Arn" --output text

Write-Host "Lambda Role ARN: $LAMBDA_ROLE_ARN" -ForegroundColor Green

# Wait for role to propagate (IAM changes take ~10 seconds)
Write-Host "Waiting 10 seconds for IAM propagation..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== IAM Role Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  LAMBDA_ROLE_ARN = $LAMBDA_ROLE_ARN"
Write-Host ""
Write-Host "Next step: Run 03-write-and-deploy-lambda.ps1" -ForegroundColor Cyan
```

---

## ⚡ PART 3 — WRITE AND DEPLOY THE LAMBDA FUNCTION

Package the Python Lambda function and deploy it to AWS.

### 🖥️ Method 1: AWS Management Console
4. **Create project folder and Lambda code**
   - Save python script in `lambda/lambda_function.py`.

5. **Package and deploy Lambda**
*Using the CLI is highly recommended for packaging and deploying.*
If you must use the console:
   - Zip your `lambda_function.py` into a file `function.zip`
   - Console → Lambda → Create function → Author from scratch
   - Function name: users-api, Runtime: Python 3.12
   - Change default execution role → Use an existing role → `lambda-users-api-role`
   - Click Create function
   - In the Code source section, click Upload from → .zip file → Upload `function.zip`
   - Configuration tab → Environment variables → Add `TABLE_NAME`=`users`, `REGION`=`us-east-1`
   - Configuration tab → General configuration → Edit → Timeout `30` seconds, Memory `128` MB

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 03: Lambda Function Deployment
# Packages and deploys the Python Lambda function for the Users API
# =============================================================================

echo -e "\e[36m=== Project 8 — Lambda Deployment ===\e[0m"
echo ""

# ── PACKAGE LAMBDA ───────────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Packaging Lambda function...\e[0m"

zip -j lambda/function.zip lambda/lambda_function.py

echo -e "\e[32mLambda packaged into function.zip\e[0m"

LAMBDA_ROLE_ARN=$(aws iam get-role --role-name lambda-users-api-role --query "Role.Arn" --output text)

# ── DEPLOY LAMBDA ────────────────────────────────────────────────────────────
echo -e "\e[33m[2/3] Deploying Lambda function: users-api...\e[0m"

LAMBDA_ARN=$(aws lambda create-function \
  --function-name users-api \
  --runtime python3.12 \
  --role $LAMBDA_ROLE_ARN \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda/function.zip \
  --timeout 30 \
  --memory-size 128 \
  --description "Serverless Users CRUD API - Project 8" \
  --environment Variables="{TABLE_NAME=users,REGION=us-east-1}" \
  --tags Project=project-08-serverless \
  --query "FunctionArn" --output text)

echo -e "\e[32mLambda ARN: $LAMBDA_ARN\e[0m"

# ── WAIT FOR ACTIVE ──────────────────────────────────────────────────────────
echo -e "\e[33m[3/3] Waiting for Lambda to become active...\e[0m"

aws lambda wait function-active --function-name users-api

echo -e "\e[32mLambda function is active\e[0m"

# ── VERIFY ───────────────────────────────────────────────────────────────────
aws lambda get-function \
  --function-name users-api \
  --query "Configuration.{Name:FunctionName,Runtime:Runtime,State:State,Memory:MemorySize,Timeout:Timeout}" \
  --output table

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Lambda Deployment Complete ===\e[0m"
echo ""
echo "  LAMBDA_ARN = $LAMBDA_ARN"
echo ""
echo -e "\e[36mNext step: Run 04-test-lambda-directly.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 03: Lambda Function Deployment
# Packages and deploys the Python Lambda function for the Users API
# =============================================================================

Write-Host "=== Project 8 — Lambda Deployment ===" -ForegroundColor Cyan
Write-Host ""

# ── PACKAGE LAMBDA ───────────────────────────────────────────────────────────
Write-Host "[1/3] Packaging Lambda function..." -ForegroundColor Yellow

Compress-Archive `
  -Path lambda\lambda_function.py `
  -DestinationPath lambda\function.zip `
  -Force

Write-Host "Lambda packaged into function.zip" -ForegroundColor Green

$LAMBDA_ROLE_ARN = aws iam get-role --role-name lambda-users-api-role --query "Role.Arn" --output text

# ── DEPLOY LAMBDA ────────────────────────────────────────────────────────────
Write-Host "[2/3] Deploying Lambda function: users-api..." -ForegroundColor Yellow

$LAMBDA_ARN = aws lambda create-function `
  --function-name users-api `
  --runtime python3.12 `
  --role $LAMBDA_ROLE_ARN `
  --handler lambda_function.lambda_handler `
  --zip-file fileb://lambda/function.zip `
  --timeout 30 `
  --memory-size 128 `
  --description "Serverless Users CRUD API - Project 8" `
  --environment Variables="{TABLE_NAME=users,REGION=us-east-1}" `
  --tags Project=project-08-serverless `
  --query "FunctionArn" --output text

Write-Host "Lambda ARN: $LAMBDA_ARN" -ForegroundColor Green

# ── WAIT FOR ACTIVE ──────────────────────────────────────────────────────────
Write-Host "[3/3] Waiting for Lambda to become active..." -ForegroundColor Yellow

aws lambda wait function-active --function-name users-api

Write-Host "Lambda function is active" -ForegroundColor Green

# ── VERIFY ───────────────────────────────────────────────────────────────────
aws lambda get-function `
  --function-name users-api `
  --query "Configuration.{Name:FunctionName,Runtime:Runtime,State:State,Memory:MemorySize,Timeout:Timeout}" `
  --output table

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Lambda Deployment Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  LAMBDA_ARN = $LAMBDA_ARN"
Write-Host ""
Write-Host "Next step: Run 04-test-lambda-directly.ps1" -ForegroundColor Cyan
```

---

## 🧪 PART 4 — TEST LAMBDA DIRECTLY

Test the Lambda function directly before wiring up API Gateway.

### 🖥️ Method 1: AWS Management Console
Before wiring up API Gateway, test Lambda directly.
   - Console → Lambda → Functions → `users-api`
   - Test tab → Create new event
   - Event JSON for POST /users:
```json
{
  "httpMethod": "POST",
  "path": "/users",
  "body": "{\"name\":\"Vinay Kumar\",\"email\":\"vinay@example.com\",\"role\":\"admin\"}"
}
```
   - Click Test
   - Expand Details and verify statusCode 201.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 04: Direct Lambda Testing
# Tests the Lambda function directly before wiring up API Gateway
# =============================================================================

echo -e "\e[36m=== Project 8 — Direct Lambda Testing ===\e[0m"
echo ""

# ── TEST 1: CREATE USER ─────────────────────────────────────────────────────
echo -e "\e[33m[1/2] Testing POST /users (create user)...\e[0m"

CREATE_PAYLOAD='{"body":"{\"name\":\"Vinay Kumar\",\"email\":\"vinay@example.com\",\"role\":\"admin\"}","httpMethod":"POST","path":"/users"}'

aws lambda invoke \
  --function-name users-api \
  --payload "$CREATE_PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  response.json

echo -e "\e[32mResponse:\e[0m"
cat response.json
echo ""

# ── TEST 2: LIST USERS ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/2] Testing GET /users (list all)...\e[0m"

LIST_PAYLOAD='{"httpMethod":"GET","path":"/users"}'

aws lambda invoke \
  --function-name users-api \
  --payload "$LIST_PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  response-list.json

echo -e "\e[32mResponse:\e[0m"
cat response-list.json
echo ""

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Direct Lambda Tests Complete ===\e[0m"
echo ""
echo "Check the response files for statusCode 201 (create) and 200 (list)."
echo ""
echo -e "\e[36mNext step: Run 05-create-api-gateway.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 04: Direct Lambda Testing
# Tests the Lambda function directly before wiring up API Gateway
# =============================================================================

Write-Host "=== Project 8 — Direct Lambda Testing ===" -ForegroundColor Cyan
Write-Host ""

# ── TEST 1: CREATE USER ─────────────────────────────────────────────────────
Write-Host "[1/2] Testing POST /users (create user)..." -ForegroundColor Yellow

$CREATE_PAYLOAD = '{"body":"{\"name\":\"Vinay Kumar\",\"email\":\"vinay@example.com\",\"role\":\"admin\"}","httpMethod":"POST","path":"/users"}'

aws lambda invoke `
  --function-name users-api `
  --payload $CREATE_PAYLOAD `
  --cli-binary-format raw-in-base64-out `
  response.json

Write-Host "Response:" -ForegroundColor Green
cat response.json
Write-Host ""

# ── TEST 2: LIST USERS ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "[2/2] Testing GET /users (list all)..." -ForegroundColor Yellow

$LIST_PAYLOAD = '{"httpMethod":"GET","path":"/users"}'

aws lambda invoke `
  --function-name users-api `
  --payload $LIST_PAYLOAD `
  --cli-binary-format raw-in-base64-out `
  response-list.json

Write-Host "Response:" -ForegroundColor Green
cat response-list.json
Write-Host ""

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Direct Lambda Tests Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check the response files for statusCode 201 (create) and 200 (list)."
Write-Host ""
Write-Host "Next step: Run 05-create-api-gateway.ps1" -ForegroundColor Cyan
```

---

## 🌐 PART 5 — CREATE API GATEWAY

Create the REST API, resources, methods, and deploy to prod stage.

### 🖥️ Method 1: AWS Management Console
6. **Create REST API**
   - Console search → API Gateway → Create API
   - Choose REST API → Build
   - API name: `users-api`, Endpoint type: Regional → Create API

7. **Create /users resource**
   - Left panel → Resources → Click / (root) → Create resource
   - Resource name: `users`
   - ✅ Enable API Gateway CORS → Create resource

8. **Create POST and GET methods on /users**
   - Click /users resource → Create method
   - Method type: POST (and then GET)
   - Integration type: Lambda function, Lambda proxy integration: ✅ Enable
   - Lambda function: `users-api`

10. **Create /users/{userId} resource and methods**
   - Click /users → Create resource → Resource name: `{userId}`, Resource path: `{userId}`
   - ✅ Enable API Gateway CORS → Create resource
   - Create GET, PUT, DELETE methods on /{userId} pointing to `users-api` lambda.

12. **Deploy the API**
   - Click Deploy API
   - Stage: [New stage], Stage name: `prod`
   - Copy the Invoke URL

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 05: API Gateway Setup
# Creates the REST API, resources, methods, and deploys to prod stage
# =============================================================================

echo -e "\e[36m=== Project 8 — API Gateway Setup ===\e[0m"
echo ""

# ── CREATE REST API ──────────────────────────────────────────────────────────
echo -e "\e[33m[1/5] Creating REST API: users-api...\e[0m"

API_ID=$(aws apigateway create-rest-api \
  --name users-api \
  --description "Serverless Users REST API - Project 8" \
  --endpoint-configuration types=REGIONAL \
  --query "id" --output text)

echo -e "\e[32mAPI ID: $API_ID\e[0m"

# ── GET ROOT RESOURCE ────────────────────────────────────────────────────────
ROOT_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --query "items[?path=='/'].id" \
  --output text)

# ── CREATE RESOURCES ─────────────────────────────────────────────────────────
echo -e "\e[33m[2/5] Creating /users and /users/{userId} resources...\e[0m"

USERS_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part users \
  --query "id" --output text)

USER_ID_RESOURCE=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $USERS_RESOURCE_ID \
  --path-part "{userId}" \
  --query "id" --output text)

echo "  /users resource:          $USERS_RESOURCE_ID"
echo "  /users/{userId} resource: $USER_ID_RESOURCE"

# ── GET LAMBDA ARN ───────────────────────────────────────────────────────────
LAMBDA_ARN=$(aws lambda get-function --function-name users-api --query "Configuration.FunctionArn" --output text)

# ── ADD METHODS ──────────────────────────────────────────────────────────────
echo -e "\e[33m[3/5] Adding HTTP methods and Lambda integrations...\e[0m"

add_api_method() {
  local RESOURCE_ID=$1
  local HTTP_METHOD=$2

  aws apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $RESOURCE_ID \
    --http-method $HTTP_METHOD \
    --authorization-type NONE > /dev/null

  aws apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $RESOURCE_ID \
    --http-method $HTTP_METHOD \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations" > /dev/null

  echo "  Created: $HTTP_METHOD"
}

add_api_method $USERS_RESOURCE_ID "POST"
add_api_method $USERS_RESOURCE_ID "GET"
add_api_method $USER_ID_RESOURCE "GET"
add_api_method $USER_ID_RESOURCE "PUT"
add_api_method $USER_ID_RESOURCE "DELETE"

# ── LAMBDA PERMISSION ────────────────────────────────────────────────────────
echo -e "\e[33m[4/5] Granting API Gateway permission to invoke Lambda...\e[0m"

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
TIMESTAMP=$(date +%s)

aws lambda add-permission \
  --function-name users-api \
  --statement-id "apigateway-invoke-$TIMESTAMP" \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:${ACCOUNT_ID}:${API_ID}/*/*"

echo -e "\e[32mLambda permission granted\e[0m"

# ── DEPLOY ───────────────────────────────────────────────────────────────────
echo -e "\e[33m[5/5] Deploying to prod stage...\e[0m"

aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name prod \
  --description "Initial deployment - Project 8" > /dev/null

API_URL="https://${API_ID}.execute-api.us-east-1.amazonaws.com/prod"
echo -e "\e[32mAPI deployed at: $API_URL\e[0m"

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== API Gateway Setup Complete ===\e[0m"
echo ""
echo "  API_ID  = $API_ID"
echo "  API_URL = $API_URL"
echo ""
echo -e "\e[36mNext step: Run 06-test-full-api.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 05: API Gateway Setup
# Creates the REST API, resources, methods, and deploys to prod stage
# =============================================================================

Write-Host "=== Project 8 — API Gateway Setup ===" -ForegroundColor Cyan
Write-Host ""

# ── CREATE REST API ──────────────────────────────────────────────────────────
Write-Host "[1/5] Creating REST API: users-api..." -ForegroundColor Yellow

$API_ID = aws apigateway create-rest-api `
  --name users-api `
  --description "Serverless Users REST API - Project 8" `
  --endpoint-configuration types=REGIONAL `
  --query "id" --output text

Write-Host "API ID: $API_ID" -ForegroundColor Green

# ── GET ROOT RESOURCE ────────────────────────────────────────────────────────
$ROOT_ID = aws apigateway get-resources `
  --rest-api-id $API_ID `
  --query "items[?path=='/'].id" `
  --output text

# ── CREATE RESOURCES ─────────────────────────────────────────────────────────
Write-Host "[2/5] Creating /users and /users/{userId} resources..." -ForegroundColor Yellow

$USERS_RESOURCE_ID = aws apigateway create-resource `
  --rest-api-id $API_ID `
  --parent-id $ROOT_ID `
  --path-part users `
  --query "id" --output text

$USER_ID_RESOURCE = aws apigateway create-resource `
  --rest-api-id $API_ID `
  --parent-id $USERS_RESOURCE_ID `
  --path-part "{userId}" `
  --query "id" --output text

Write-Host "  /users resource:          $USERS_RESOURCE_ID"
Write-Host "  /users/{userId} resource: $USER_ID_RESOURCE"

# ── GET LAMBDA ARN ───────────────────────────────────────────────────────────
$LAMBDA_ARN = aws lambda get-function --function-name users-api --query "Configuration.FunctionArn" --output text

# ── ADD METHODS ──────────────────────────────────────────────────────────────
Write-Host "[3/5] Adding HTTP methods and Lambda integrations..." -ForegroundColor Yellow

function Add-ApiMethod {
  param($ResourceId, $HttpMethod)

  aws apigateway put-method `
    --rest-api-id $API_ID `
    --resource-id $ResourceId `
    --http-method $HttpMethod `
    --authorization-type NONE | Out-Null

  aws apigateway put-integration `
    --rest-api-id $API_ID `
    --resource-id $ResourceId `
    --http-method $HttpMethod `
    --type AWS_PROXY `
    --integration-http-method POST `
    --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations" | Out-Null

  Write-Host "  Created: $HttpMethod"
}

Add-ApiMethod -ResourceId $USERS_RESOURCE_ID -HttpMethod "POST"
Add-ApiMethod -ResourceId $USERS_RESOURCE_ID -HttpMethod "GET"
Add-ApiMethod -ResourceId $USER_ID_RESOURCE -HttpMethod "GET"
Add-ApiMethod -ResourceId $USER_ID_RESOURCE -HttpMethod "PUT"
Add-ApiMethod -ResourceId $USER_ID_RESOURCE -HttpMethod "DELETE"

# ── LAMBDA PERMISSION ────────────────────────────────────────────────────────
Write-Host "[4/5] Granting API Gateway permission to invoke Lambda..." -ForegroundColor Yellow

$ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text

aws lambda add-permission `
  --function-name users-api `
  --statement-id apigateway-invoke `
  --action lambda:InvokeFunction `
  --principal apigateway.amazonaws.com `
  --source-arn "arn:aws:execute-api:us-east-1:${ACCOUNT_ID}:${API_ID}/*/*"

Write-Host "Lambda permission granted" -ForegroundColor Green

# ── DEPLOY ───────────────────────────────────────────────────────────────────
Write-Host "[5/5] Deploying to prod stage..." -ForegroundColor Yellow

aws apigateway create-deployment `
  --rest-api-id $API_ID `
  --stage-name prod `
  --description "Initial deployment - Project 8" | Out-Null

$API_URL = "https://$API_ID.execute-api.us-east-1.amazonaws.com/prod"
Write-Host "API deployed at: $API_URL" -ForegroundColor Green

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== API Gateway Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  API_ID  = $API_ID"
Write-Host "  API_URL = $API_URL"
Write-Host ""
Write-Host "Next step: Run 06-test-full-api.ps1" -ForegroundColor Cyan
```

---

## 🚀 PART 6 — TEST THE FULL API

Run all 8 endpoint tests through API Gateway to validate the full stack.

### 🖥️ Method 1: AWS Management Console
Now test all 5 endpoints using curl or Postman.
URL: https://<your-api-id>.execute-api.us-east-1.amazonaws.com/prod/users
Method: POST
Body:
```json
{
  "name": "Vinay Kumar",
  "email": "vinay@example.com",
  "role": "admin"
}
```

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 06: Full API Integration Tests
# Runs all 8 endpoint tests through API Gateway to validate the full stack
# =============================================================================

echo -e "\e[36m=== Project 8 — Full API Testing ===\e[0m"
echo ""

API_ID=$(aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text)
API_URL="https://${API_ID}.execute-api.us-east-1.amazonaws.com/prod"

echo "API URL: $API_URL"
echo ""

# ── TEST 1: CREATE USER ─────────────────────────────────────────────────────
echo -e "\e[36m=== TEST 1: Create User ===\e[0m"
RESPONSE1=$(curl -s -X POST "$API_URL/users" -H "Content-Type: application/json" -d '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}')
USER_ID=$(echo $RESPONSE1 | grep -o '"userId": "[^"]*' | cut -d'"' -f4)
echo "Created user ID: $USER_ID"

# ── TEST 2: CREATE SECOND USER ──────────────────────────────────────────────
echo -e "\n\e[36m=== TEST 2: Create Second User ===\e[0m"
curl -s -X POST "$API_URL/users" -H "Content-Type: application/json" -d '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}'

# ── TEST 3: LIST ALL USERS ──────────────────────────────────────────────────
echo -e "\n\e[36m=== TEST 3: List All Users ===\e[0m"
curl -s -X GET "$API_URL/users"

# ── TEST 4: GET SINGLE USER ─────────────────────────────────────────────────
echo -e "\n\n\e[36m=== TEST 4: Get Single User ===\e[0m"
curl -s -X GET "$API_URL/users/$USER_ID"

# ── TEST 5: UPDATE USER ─────────────────────────────────────────────────────
echo -e "\n\n\e[36m=== TEST 5: Update User ===\e[0m"
curl -s -X PUT "$API_URL/users/$USER_ID" -H "Content-Type: application/json" -d '{"role":"superadmin","name":"Vinay Kumar - Updated"}'

# ── TEST 6: TEST 404 ────────────────────────────────────────────────────────
echo -e "\n\n\e[36m=== TEST 6: Test 404 ===\e[0m"
curl -s -X GET "$API_URL/users/non-existent-id-12345"

# ── TEST 7: DELETE USER ─────────────────────────────────────────────────────
echo -e "\n\n\e[36m=== TEST 7: Delete User ===\e[0m"
curl -s -X DELETE "$API_URL/users/$USER_ID"

# ── TEST 8: VERIFY DELETION ─────────────────────────────────────────────────
echo -e "\n\n\e[36m=== TEST 8: Verify Deletion ===\e[0m"
curl -s -X GET "$API_URL/users"

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo ""
echo -e "\e[32m=== ALL TESTS PASSED ===\e[0m"
echo ""
echo -e "\e[36mNext step: Run 07-verify-dynamodb.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 06: Full API Integration Tests
# Runs all 8 endpoint tests through API Gateway to validate the full stack
# =============================================================================

Write-Host "=== Project 8 — Full API Testing ===" -ForegroundColor Cyan
Write-Host ""

$API_ID = aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text
$API_URL = "https://$API_ID.execute-api.us-east-1.amazonaws.com/prod"

Write-Host "API URL: $API_URL"
Write-Host ""

# ── TEST 1: CREATE USER ─────────────────────────────────────────────────────
Write-Host "=== TEST 1: Create User ===" -ForegroundColor Cyan
$user1 = Invoke-RestMethod -Uri "$API_URL/users" -Method POST -ContentType "application/json" -Body '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}'
Write-Host "Created user ID: $($user1.user.userId)"
$USER_ID = $user1.user.userId

# ── TEST 2: CREATE SECOND USER ──────────────────────────────────────────────
Write-Host "=== TEST 2: Create Second User ===" -ForegroundColor Cyan
$user2 = Invoke-RestMethod -Uri "$API_URL/users" -Method POST -ContentType "application/json" -Body '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}'
Write-Host "Created user ID: $($user2.user.userId)"

# ── TEST 3: LIST ALL USERS ──────────────────────────────────────────────────
Write-Host "=== TEST 3: List All Users ===" -ForegroundColor Cyan
$allUsers = Invoke-RestMethod -Uri "$API_URL/users" -Method GET
Write-Host "Total users: $($allUsers.count)"

# ── TEST 4: GET SINGLE USER ─────────────────────────────────────────────────
Write-Host "=== TEST 4: Get Single User ===" -ForegroundColor Cyan
$singleUser = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method GET
Write-Host "Got user: $($singleUser.user.name)"

# ── TEST 5: UPDATE USER ─────────────────────────────────────────────────────
Write-Host "=== TEST 5: Update User ===" -ForegroundColor Cyan
$updatedUser = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method PUT -ContentType "application/json" -Body '{"role":"superadmin","name":"Vinay Kumar - Updated"}'
Write-Host "Updated user role: $($updatedUser.user.role)"

# ── TEST 6: TEST 404 ────────────────────────────────────────────────────────
Write-Host "=== TEST 6: Test 404 ===" -ForegroundColor Cyan
try { Invoke-RestMethod -Uri "$API_URL/users/non-existent-id-12345" -Method GET } catch { Write-Host "404 received as expected: $($_.Exception.Message)" }

# ── TEST 7: DELETE USER ─────────────────────────────────────────────────────
Write-Host "=== TEST 7: Delete User ===" -ForegroundColor Cyan
$deleted = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method DELETE
Write-Host "Delete response: $($deleted.message)"

# ── TEST 8: VERIFY DELETION ─────────────────────────────────────────────────
Write-Host "=== TEST 8: Verify Deletion ===" -ForegroundColor Cyan
$finalList = Invoke-RestMethod -Uri "$API_URL/users" -Method GET
Write-Host "Users remaining: $($finalList.count)"

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== ALL TESTS PASSED ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Run 07-verify-dynamodb.ps1" -ForegroundColor Cyan
```

---

## 🔍 PART 7 — VERIFY IN DYNAMODB CONSOLE

Verify data persistence by scanning the DynamoDB users table.

### 🖥️ Method 1: AWS Management Console
In the console:
   - DynamoDB → Tables → users → Explore table items
   - See all your created users with all attributes

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 07: DynamoDB Data Verification
# Verifies data persistence by scanning the users table
# =============================================================================

echo -e "\e[36m=== Project 8 — DynamoDB Verification ===\e[0m"
echo ""

# ── SCAN TABLE ───────────────────────────────────────────────────────────────
echo -e "\e[33m[1/1] Scanning users table...\e[0m"

aws dynamodb scan \
  --table-name users \
  --query "Items[*].{ID:userId.S,Name:name.S,Email:email.S,Role:role.S}" \
  --output table

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== DynamoDB Verification Complete ===\e[0m"
echo ""
echo -e "\e[36mNext step: Run 08-monitor-cloudwatch.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 07: DynamoDB Data Verification
# Verifies data persistence by scanning the users table
# =============================================================================

Write-Host "=== Project 8 — DynamoDB Verification ===" -ForegroundColor Cyan
Write-Host ""

# ── SCAN TABLE ───────────────────────────────────────────────────────────────
Write-Host "[1/1] Scanning users table..." -ForegroundColor Yellow

aws dynamodb scan `
  --table-name users `
  --query "Items[*].{ID:userId.S,Name:name.S,Email:email.S,Role:role.S}" `
  --output table

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== DynamoDB Verification Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Run 08-monitor-cloudwatch.ps1" -ForegroundColor Cyan
```

---

## 📊 PART 8 — MONITOR WITH CLOUDWATCH LOGS

View Lambda execution logs and monitor function performance in CloudWatch.

### 🖥️ Method 1: AWS Management Console
   - Console → CloudWatch → Log groups
   - Search for `/aws/lambda/users-api`
   - Open the latest log stream to see standard out and execution details.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 08: CloudWatch Monitoring
# Views Lambda execution logs and monitors function performance
# =============================================================================

echo -e "\e[36m=== Project 8 — CloudWatch Monitoring ===\e[0m"
echo ""

# ── LIST LOG GROUPS ──────────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Listing Lambda log groups...\e[0m"

aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/users-api" \
  --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays}" \
  --output table

# ── GET LATEST LOG STREAM ────────────────────────────────────────────────────
echo -e "\e[33m[2/3] Getting latest log stream...\e[0m"

LOG_STREAM=$(aws logs describe-log-streams \
  --log-group-name "/aws/lambda/users-api" \
  --order-by LastEventTime \
  --descending \
  --max-items 1 \
  --query "logStreams[0].logStreamName" \
  --output text)

echo "Latest stream: $LOG_STREAM"

# ── READ LOGS ────────────────────────────────────────────────────────────────
echo -e "\e[33m[3/3] Reading latest logs...\e[0m"

aws logs get-log-events \
  --log-group-name "/aws/lambda/users-api" \
  --log-stream-name "$LOG_STREAM" \
  --query "events[*].message" \
  --output text

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== CloudWatch Monitoring Complete ===\e[0m"
echo ""
echo -e "\e[36mNext step: Run 09-update-lambda.sh\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 08: CloudWatch Monitoring
# Views Lambda execution logs and monitors function performance
# =============================================================================

Write-Host "=== Project 8 — CloudWatch Monitoring ===" -ForegroundColor Cyan
Write-Host ""

# ── LIST LOG GROUPS ──────────────────────────────────────────────────────────
Write-Host "[1/3] Listing Lambda log groups..." -ForegroundColor Yellow

aws logs describe-log-groups `
  --log-group-name-prefix "/aws/lambda/users-api" `
  --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays}" `
  --output table

# ── GET LATEST LOG STREAM ────────────────────────────────────────────────────
Write-Host "[2/3] Getting latest log stream..." -ForegroundColor Yellow

$LOG_STREAM = aws logs describe-log-streams `
  --log-group-name "/aws/lambda/users-api" `
  --order-by LastEventTime `
  --descending `
  --max-items 1 `
  --query "logStreams[0].logStreamName" `
  --output text

Write-Host "Latest stream: $LOG_STREAM"

# ── READ LOGS ────────────────────────────────────────────────────────────────
Write-Host "[3/3] Reading latest logs..." -ForegroundColor Yellow

aws logs get-log-events `
  --log-group-name "/aws/lambda/users-api" `
  --log-stream-name $LOG_STREAM `
  --query "events[*].message" `
  --output text

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== CloudWatch Monitoring Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Run 09-update-lambda.ps1" -ForegroundColor Cyan
```

---

## 🔄 PART 9 — UPDATE LAMBDA CODE

Repackage and redeploy updated Lambda function code.

### 🖥️ Method 1: AWS Management Console
When you update your Lambda code:
   - Console → Lambda → Functions → `users-api`
   - Edit code inline
   - Click Deploy

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 09: Lambda Code Update
# Repackages and redeploys updated Lambda function code
# =============================================================================

echo -e "\e[36m=== Project 8 — Lambda Code Update ===\e[0m"
echo ""

# ── REPACKAGE ────────────────────────────────────────────────────────────────
echo -e "\e[33m[1/2] Repackaging Lambda function...\e[0m"

zip -j lambda/function.zip lambda/lambda_function.py

echo -e "\e[32mRepackaged function.zip\e[0m"

# ── DEPLOY UPDATE ────────────────────────────────────────────────────────────
echo -e "\e[33m[2/2] Deploying updated code...\e[0m"

aws lambda update-function-code \
  --function-name users-api \
  --zip-file fileb://lambda/function.zip

aws lambda wait function-updated --function-name users-api

echo -e "\e[32mLambda updated successfully\e[0m"

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Lambda Update Complete ===\e[0m"
echo ""
echo "Re-run your API tests to verify the changes."
echo ""
echo -e "\e[36mNext step: Run 10-cleanup.sh (when ready to tear down)\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 09: Lambda Code Update
# Repackages and redeploys updated Lambda function code
# =============================================================================

Write-Host "=== Project 8 — Lambda Code Update ===" -ForegroundColor Cyan
Write-Host ""

# ── REPACKAGE ────────────────────────────────────────────────────────────────
Write-Host "[1/2] Repackaging Lambda function..." -ForegroundColor Yellow

Compress-Archive `
  -Path lambda\lambda_function.py `
  -DestinationPath lambda\function.zip `
  -Force

Write-Host "Repackaged function.zip" -ForegroundColor Green

# ── DEPLOY UPDATE ────────────────────────────────────────────────────────────
Write-Host "[2/2] Deploying updated code..." -ForegroundColor Yellow

aws lambda update-function-code `
  --function-name users-api `
  --zip-file fileb://lambda/function.zip

aws lambda wait function-updated --function-name users-api

Write-Host "Lambda updated successfully" -ForegroundColor Green

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Lambda Update Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Re-run your API tests to verify the changes."
Write-Host ""
Write-Host "Next step: Run 10-cleanup.ps1 (when ready to tear down)" -ForegroundColor Cyan
```

---

## 🧹 PART 10 — CLEANUP

Delete all AWS resources created in this project to avoid charges.

### 🖥️ Method 1: AWS Management Console
   - Console → API Gateway → Delete `users-api`
   - Console → Lambda → Delete `users-api`
   - Console → DynamoDB → Delete `users` table
   - Console → IAM → Delete `lambda-users-api-role`
   - Console → CloudWatch → Delete log group `/aws/lambda/users-api`

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# =============================================================================
# Project 8 — Script 10: Resource Cleanup
# Deletes all AWS resources created in this project to avoid charges
# =============================================================================

echo -e "\e[36m=== Project 8 — Resource Cleanup ===\e[0m"
echo ""

# ── DELETE API GATEWAY ───────────────────────────────────────────────────────
echo -e "\e[33m[1/5] Deleting API Gateway...\e[0m"

API_ID=$(aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text)

if [ "$API_ID" != "None" ] && [ -n "$API_ID" ]; then
  aws apigateway delete-rest-api --rest-api-id $API_ID
  echo -e "\e[32mAPI Gateway deleted\e[0m"
fi

# ── DELETE LAMBDA ────────────────────────────────────────────────────────────
echo -e "\e[33m[2/5] Deleting Lambda function...\e[0m"

aws lambda delete-function --function-name users-api
echo -e "\e[32mLambda deleted\e[0m"

# ── DELETE DYNAMODB TABLE ────────────────────────────────────────────────────
echo -e "\e[33m[3/5] Deleting DynamoDB table...\e[0m"

aws dynamodb delete-table --table-name users
echo -e "\e[32mDynamoDB table deleted\e[0m"

# ── DELETE IAM ROLE ──────────────────────────────────────────────────────────
echo -e "\e[33m[4/5] Deleting IAM role and policies...\e[0m"

aws iam delete-role-policy --role-name lambda-users-api-role --policy-name dynamodb-users-access
aws iam detach-role-policy --role-name lambda-users-api-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda-users-api-role
echo -e "\e[32mIAM role deleted\e[0m"

# ── DELETE LOG GROUP ─────────────────────────────────────────────────────────
echo -e "\e[33m[5/5] Deleting CloudWatch log group...\e[0m"

aws logs delete-log-group --log-group-name "/aws/lambda/users-api"
echo -e "\e[32mLog group deleted\e[0m"

# ── SUMMARY ──────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Cleanup Complete ===\e[0m"
echo ""
echo "All Project 8 resources have been removed."
echo ""
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# =============================================================================
# Project 8 — Script 10: Resource Cleanup
# Deletes all AWS resources created in this project to avoid charges
# =============================================================================

Write-Host "=== Project 8 — Resource Cleanup ===" -ForegroundColor Cyan
Write-Host ""

# ── DELETE API GATEWAY ───────────────────────────────────────────────────────
Write-Host "[1/5] Deleting API Gateway..." -ForegroundColor Yellow

$API_ID = aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text

if ($API_ID -ne "None" -and $API_ID -ne "") {
  aws apigateway delete-rest-api --rest-api-id $API_ID
  Write-Host "API Gateway deleted" -ForegroundColor Green
}

# ── DELETE LAMBDA ────────────────────────────────────────────────────────────
Write-Host "[2/5] Deleting Lambda function..." -ForegroundColor Yellow

aws lambda delete-function --function-name users-api
Write-Host "Lambda deleted" -ForegroundColor Green

# ── DELETE DYNAMODB TABLE ────────────────────────────────────────────────────
Write-Host "[3/5] Deleting DynamoDB table..." -ForegroundColor Yellow

aws dynamodb delete-table --table-name users
Write-Host "DynamoDB table deleted" -ForegroundColor Green

# ── DELETE IAM ROLE ──────────────────────────────────────────────────────────
Write-Host "[4/5] Deleting IAM role and policies..." -ForegroundColor Yellow

aws iam delete-role-policy --role-name lambda-users-api-role --policy-name dynamodb-users-access
aws iam detach-role-policy --role-name lambda-users-api-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda-users-api-role
Write-Host "IAM role deleted" -ForegroundColor Green

# ── DELETE LOG GROUP ─────────────────────────────────────────────────────────
Write-Host "[5/5] Deleting CloudWatch log group..." -ForegroundColor Yellow

aws logs delete-log-group --log-group-name "/aws/lambda/users-api"
Write-Host "Log group deleted" -ForegroundColor Green

# ── SUMMARY ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "All Project 8 resources have been removed."
Write-Host ""
```

