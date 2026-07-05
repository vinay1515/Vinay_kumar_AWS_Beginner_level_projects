import os
import re

base_dir = r"e:\AWS Hands-on Projects\project-08-serverless-rest-api"
docs_dir = os.path.join(base_dir, "docs")
scripts_bash = os.path.join(base_dir, "scripts", "bash")
scripts_ps1 = os.path.join(base_dir, "scripts", "powershell")
lambda_dir = os.path.join(base_dir, "lambda")

os.makedirs(scripts_bash, exist_ok=True)
os.makedirs(scripts_ps1, exist_ok=True)
os.makedirs(lambda_dir, exist_ok=True)

parts = [
    {
        "id": "01",
        "title": "CREATE DYNAMODB TABLE",
        "desc": "Create DynamoDB table",
        "console": """Step 1 — Create DynamoDB table
- Console search → DynamoDB → Create table
- Table name: users
- Partition key: userId (String)
- Read/write capacity: On-demand
- Click Create table
- Wait ~30 seconds for status to show Active""",
        "ps1": """# Create DynamoDB table with on-demand billing
aws dynamodb create-table `
  --table-name users `
  --attribute-definitions AttributeName=userId,AttributeType=S `
  --key-schema AttributeName=userId,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --tags Key=Project,Value=project-08-serverless

# Wait for table to become active
aws dynamodb wait table-exists --table-name users
Write-Host "DynamoDB table created and active"

# Verify table
aws dynamodb describe-table `
  --table-name users `
  --query "Table.{Name:TableName,Status:TableStatus,BillingMode:BillingModeSummary.BillingMode}" `
  --output table""",
        "sh": """#!/bin/bash
# Create DynamoDB table with on-demand billing
aws dynamodb create-table \\
  --table-name users \\
  --attribute-definitions AttributeName=userId,AttributeType=S \\
  --key-schema AttributeName=userId,KeyType=HASH \\
  --billing-mode PAY_PER_REQUEST \\
  --tags Key=Project,Value=project-08-serverless

# Wait for table to become active
aws dynamodb wait table-exists --table-name users
echo "DynamoDB table created and active"

# Verify table
aws dynamodb describe-table \\
  --table-name users \\
  --query "Table.{Name:TableName,Status:TableStatus,BillingMode:BillingModeSummary.BillingMode}" \\
  --output table"""
    },
    {
        "id": "02",
        "title": "CREATE LAMBDA EXECUTION ROLE",
        "desc": "Create IAM role for Lambda",
        "console": """Step 2 — Create Lambda IAM role
- Console → IAM → Roles → Create role
- Trusted entity: AWS service, Service: Lambda → Next
- Search and attach: AWSLambdaBasicExecutionRole → Next
- Role name: lambda-users-api-role → Create role

Step 3 — Add DynamoDB policy
- Click your new role → Add permissions → Create inline policy
- JSON tab → Allow dynamodb:GetItem/PutItem/UpdateItem/DeleteItem/Scan on table arn
- Policy name: dynamodb-users-access → Create policy""",
        "ps1": """# Create Lambda execution role
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

# Attach basic execution policy (CloudWatch Logs)
aws iam attach-role-policy `
  --role-name lambda-users-api-role `
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

$ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text

# Add DynamoDB inline policy
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

# Get role ARN for Lambda creation
$LAMBDA_ROLE_ARN = aws iam get-role `
  --role-name lambda-users-api-role `
  --query "Role.Arn" --output text

Write-Host "Lambda Role ARN: $LAMBDA_ROLE_ARN"

# Wait for role to propagate (IAM changes take ~10 seconds)
Start-Sleep -Seconds 10""",
        "sh": """#!/bin/bash
# Create Lambda execution role
aws iam create-role \\
  --role-name lambda-users-api-role \\
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach basic execution policy (CloudWatch Logs)
aws iam attach-role-policy \\
  --role-name lambda-users-api-role \\
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Add DynamoDB inline policy
aws iam put-role-policy \\
  --role-name lambda-users-api-role \\
  --policy-name dynamodb-users-access \\
  --policy-document "{
    \\"Version\\":\\"2012-10-17\\",
    \\"Statement\\":[{
      \\"Effect\\":\\"Allow\\",
      \\"Action\\":[
        \\"dynamodb:GetItem\\",
        \\"dynamodb:PutItem\\",
        \\"dynamodb:UpdateItem\\",
        \\"dynamodb:DeleteItem\\",
        \\"dynamodb:Scan\\",
        \\"dynamodb:Query\\"
      ],
      \\"Resource\\":\\"arn:aws:dynamodb:us-east-1:${ACCOUNT_ID}:table/users\\"
    }]
  }"

# Get role ARN for Lambda creation
LAMBDA_ROLE_ARN=$(aws iam get-role \\
  --role-name lambda-users-api-role \\
  --query "Role.Arn" --output text)

echo "Lambda Role ARN: $LAMBDA_ROLE_ARN"

# Wait for role to propagate (IAM changes take ~10 seconds)
sleep 10"""
    },
    {
        "id": "03",
        "title": "WRITE AND DEPLOY THE LAMBDA FUNCTION",
        "desc": "Write, package and deploy Lambda function",
        "console": """Step 4 — Create project folder and Lambda code
- Save python script in `lambda/lambda_function.py`.

Step 5 — Package and deploy Lambda
*Using the CLI is highly recommended for packaging and deploying.*
If you must use the console:
- Zip your `lambda_function.py` into a file `function.zip`
- Console → Lambda → Create function → Author from scratch
- Function name: users-api, Runtime: Python 3.12
- Change default execution role → Use an existing role → `lambda-users-api-role`
- Click Create function
- In the Code source section, click Upload from → .zip file → Upload `function.zip`
- Configuration tab → Environment variables → Add `TABLE_NAME`=`users`, `REGION`=`us-east-1`
- Configuration tab → General configuration → Edit → Timeout `30` seconds, Memory `128` MB""",
        "ps1": """# Package Lambda into a ZIP file
Compress-Archive `
  -Path lambda\lambda_function.py `
  -DestinationPath lambda\function.zip `
  -Force

Write-Host "Lambda packaged into function.zip"

$LAMBDA_ROLE_ARN = aws iam get-role --role-name lambda-users-api-role --query "Role.Arn" --output text

# Deploy Lambda function
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

Write-Host "Lambda ARN: $LAMBDA_ARN"

# Wait for Lambda to be active
aws lambda wait function-active --function-name users-api
Write-Host "Lambda function is active"

# Verify
aws lambda get-function `
  --function-name users-api `
  --query "Configuration.{Name:FunctionName,Runtime:Runtime,State:State,Memory:MemorySize,Timeout:Timeout}" `
  --output table""",
        "sh": """#!/bin/bash
# Package Lambda into a ZIP file
zip -j lambda/function.zip lambda/lambda_function.py

echo "Lambda packaged into function.zip"

LAMBDA_ROLE_ARN=$(aws iam get-role --role-name lambda-users-api-role --query "Role.Arn" --output text)

# Deploy Lambda function
LAMBDA_ARN=$(aws lambda create-function \\
  --function-name users-api \\
  --runtime python3.12 \\
  --role $LAMBDA_ROLE_ARN \\
  --handler lambda_function.lambda_handler \\
  --zip-file fileb://lambda/function.zip \\
  --timeout 30 \\
  --memory-size 128 \\
  --description "Serverless Users CRUD API - Project 8" \\
  --environment Variables="{TABLE_NAME=users,REGION=us-east-1}" \\
  --tags Project=project-08-serverless \\
  --query "FunctionArn" --output text)

echo "Lambda ARN: $LAMBDA_ARN"

# Wait for Lambda to be active
aws lambda wait function-active --function-name users-api
echo "Lambda function is active"

# Verify
aws lambda get-function \\
  --function-name users-api \\
  --query "Configuration.{Name:FunctionName,Runtime:Runtime,State:State,Memory:MemorySize,Timeout:Timeout}" \\
  --output table"""
    },
    {
        "id": "04",
        "title": "TEST LAMBDA DIRECTLY",
        "desc": "Test Lambda execution natively",
        "console": """Before wiring up API Gateway, test Lambda directly.
- Console → Lambda → Functions → `users-api`
- Test tab → Create new event
- Event JSON for POST /users:
```json
{
  "httpMethod": "POST",
  "path": "/users",
  "body": "{\\"name\\":\\"Vinay Kumar\\",\\"email\\":\\"vinay@example.com\\",\\"role\\":\\"admin\\"}"
}
```
- Click Test
- Expand Details and verify statusCode 201.""",
        "ps1": """# Test 1 - Create a user
$CREATE_PAYLOAD = '{"body":"{\"name\":\"Vinay Kumar\",\"email\":\"vinay@example.com\",\"role\":\"admin\"}","httpMethod":"POST","path":"/users"}'

aws lambda invoke `
  --function-name users-api `
  --payload $CREATE_PAYLOAD `
  --cli-binary-format raw-in-base64-out `
  response.json

cat response.json

# Test 2 - List all users
$LIST_PAYLOAD = '{"httpMethod":"GET","path":"/users"}'

aws lambda invoke `
  --function-name users-api `
  --payload $LIST_PAYLOAD `
  --cli-binary-format raw-in-base64-out `
  response-list.json

cat response-list.json""",
        "sh": """#!/bin/bash
# Test 1 - Create a user
CREATE_PAYLOAD='{"body":"{\\"name\\":\\"Vinay Kumar\\",\\"email\\":\\"vinay@example.com\\",\\"role\\":\\"admin\\"}","httpMethod":"POST","path":"/users"}'

aws lambda invoke \\
  --function-name users-api \\
  --payload "$CREATE_PAYLOAD" \\
  --cli-binary-format raw-in-base64-out \\
  response.json

cat response.json

# Test 2 - List all users
LIST_PAYLOAD='{"httpMethod":"GET","path":"/users"}'

aws lambda invoke \\
  --function-name users-api \\
  --payload "$LIST_PAYLOAD" \\
  --cli-binary-format raw-in-base64-out \\
  response-list.json

cat response-list.json"""
    },
    {
        "id": "05",
        "title": "CREATE API GATEWAY",
        "desc": "Create and configure API Gateway",
        "console": """Step 6 — Create REST API
- Console search → API Gateway → Create API
- Choose REST API → Build
- API name: `users-api`, Endpoint type: Regional → Create API

Step 7 — Create /users resource
- Left panel → Resources → Click / (root) → Create resource
- Resource name: `users`
- ✅ Enable API Gateway CORS → Create resource

Step 8 & 9 — Create POST and GET methods on /users
- Click /users resource → Create method
- Method type: POST (and then GET)
- Integration type: Lambda function, Lambda proxy integration: ✅ Enable
- Lambda function: `users-api`

Step 10 & 11 — Create /users/{userId} resource and methods
- Click /users → Create resource → Resource name: `{userId}`, Resource path: `{userId}`
- ✅ Enable API Gateway CORS → Create resource
- Create GET, PUT, DELETE methods on /{userId} pointing to `users-api` lambda.

Step 12 — Deploy the API
- Click Deploy API
- Stage: [New stage], Stage name: `prod`
- Copy the Invoke URL""",
        "ps1": """# Step 1 - Create REST API
$API_ID = aws apigateway create-rest-api `
  --name users-api `
  --description "Serverless Users REST API - Project 8" `
  --endpoint-configuration types=REGIONAL `
  --query "id" --output text

Write-Host "API ID: $API_ID"

# Step 2 - Get root resource ID
$ROOT_ID = aws apigateway get-resources `
  --rest-api-id $API_ID `
  --query "items[?path=='/'].id" `
  --output text

# Step 3 - Create /users resource
$USERS_RESOURCE_ID = aws apigateway create-resource `
  --rest-api-id $API_ID `
  --parent-id $ROOT_ID `
  --path-part users `
  --query "id" --output text

# Step 4 - Create /users/{userId} resource
$USER_ID_RESOURCE = aws apigateway create-resource `
  --rest-api-id $API_ID `
  --parent-id $USERS_RESOURCE_ID `
  --path-part "{userId}" `
  --query "id" --output text

# Get Lambda ARN
$LAMBDA_ARN = aws lambda get-function --function-name users-api --query "Configuration.FunctionArn" --output text

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

  Write-Host "Created: $HttpMethod on resource $ResourceId"
}

# Step 5 - Add methods
Add-ApiMethod -ResourceId $USERS_RESOURCE_ID -HttpMethod "POST"
Add-ApiMethod -ResourceId $USERS_RESOURCE_ID -HttpMethod "GET"
Add-ApiMethod -ResourceId $USER_ID_RESOURCE -HttpMethod "GET"
Add-ApiMethod -ResourceId $USER_ID_RESOURCE -HttpMethod "PUT"
Add-ApiMethod -ResourceId $USER_ID_RESOURCE -HttpMethod "DELETE"

# Step 7 - Grant API Gateway permission to invoke Lambda
$ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text

aws lambda add-permission `
  --function-name users-api `
  --statement-id apigateway-invoke `
  --action lambda:InvokeFunction `
  --principal apigateway.amazonaws.com `
  --source-arn "arn:aws:execute-api:us-east-1:${ACCOUNT_ID}:${API_ID}/*/*"

Write-Host "Lambda permission granted to API Gateway"

# Step 8 - Deploy to prod stage
aws apigateway create-deployment `
  --rest-api-id $API_ID `
  --stage-name prod `
  --description "Initial deployment - Project 8" | Out-Null

$API_URL = "https://$API_ID.execute-api.us-east-1.amazonaws.com/prod"
Write-Host "API deployed at: $API_URL" """,
        "sh": """#!/bin/bash
# Step 1 - Create REST API
API_ID=$(aws apigateway create-rest-api \\
  --name users-api \\
  --description "Serverless Users REST API - Project 8" \\
  --endpoint-configuration types=REGIONAL \\
  --query "id" --output text)

echo "API ID: $API_ID"

# Step 2 - Get root resource ID
ROOT_ID=$(aws apigateway get-resources \\
  --rest-api-id $API_ID \\
  --query "items[?path=='/'].id" \\
  --output text)

# Step 3 - Create /users resource
USERS_RESOURCE_ID=$(aws apigateway create-resource \\
  --rest-api-id $API_ID \\
  --parent-id $ROOT_ID \\
  --path-part users \\
  --query "id" --output text)

# Step 4 - Create /users/{userId} resource
USER_ID_RESOURCE=$(aws apigateway create-resource \\
  --rest-api-id $API_ID \\
  --parent-id $USERS_RESOURCE_ID \\
  --path-part "{userId}" \\
  --query "id" --output text)

# Get Lambda ARN
LAMBDA_ARN=$(aws lambda get-function --function-name users-api --query "Configuration.FunctionArn" --output text)

add_api_method() {
  local RESOURCE_ID=$1
  local HTTP_METHOD=$2

  aws apigateway put-method \\
    --rest-api-id $API_ID \\
    --resource-id $RESOURCE_ID \\
    --http-method $HTTP_METHOD \\
    --authorization-type NONE > /dev/null

  aws apigateway put-integration \\
    --rest-api-id $API_ID \\
    --resource-id $RESOURCE_ID \\
    --http-method $HTTP_METHOD \\
    --type AWS_PROXY \\
    --integration-http-method POST \\
    --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations" > /dev/null

  echo "Created: $HTTP_METHOD on resource $RESOURCE_ID"
}

# Step 5 - Add methods
add_api_method $USERS_RESOURCE_ID "POST"
add_api_method $USERS_RESOURCE_ID "GET"
add_api_method $USER_ID_RESOURCE "GET"
add_api_method $USER_ID_RESOURCE "PUT"
add_api_method $USER_ID_RESOURCE "DELETE"

# Step 7 - Grant API Gateway permission to invoke Lambda
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
TIMESTAMP=$(date +%s)

aws lambda add-permission \\
  --function-name users-api \\
  --statement-id "apigateway-invoke-$TIMESTAMP" \\
  --action lambda:InvokeFunction \\
  --principal apigateway.amazonaws.com \\
  --source-arn "arn:aws:execute-api:us-east-1:${ACCOUNT_ID}:${API_ID}/*/*"

echo "Lambda permission granted to API Gateway"

# Step 8 - Deploy to prod stage
aws apigateway create-deployment \\
  --rest-api-id $API_ID \\
  --stage-name prod \\
  --description "Initial deployment - Project 8" > /dev/null

API_URL="https://${API_ID}.execute-api.us-east-1.amazonaws.com/prod"
echo "API deployed at: $API_URL" """
    },
    {
        "id": "06",
        "title": "TEST THE FULL API",
        "desc": "Test the full API through API Gateway",
        "console": """Now test all 5 endpoints using curl or Postman.
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
""",
        "ps1": """# Set your API URL (retrieve if not set)
$API_ID = aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text
$API_URL = "https://$API_ID.execute-api.us-east-1.amazonaws.com/prod"

# TEST 1: Create User
Write-Host "=== TEST 1: Create User ===" -ForegroundColor Cyan
$user1 = Invoke-RestMethod -Uri "$API_URL/users" -Method POST -ContentType "application/json" -Body '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}'
Write-Host "Created user ID: $($user1.user.userId)"
$USER_ID = $user1.user.userId

# TEST 2: Create Second User
Write-Host "=== TEST 2: Create Second User ===" -ForegroundColor Cyan
$user2 = Invoke-RestMethod -Uri "$API_URL/users" -Method POST -ContentType "application/json" -Body '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}'
Write-Host "Created user ID: $($user2.user.userId)"

# TEST 3: List All Users
Write-Host "=== TEST 3: List All Users ===" -ForegroundColor Cyan
$allUsers = Invoke-RestMethod -Uri "$API_URL/users" -Method GET
Write-Host "Total users: $($allUsers.count)"

# TEST 4: Get Single User
Write-Host "=== TEST 4: Get Single User ===" -ForegroundColor Cyan
$singleUser = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method GET
Write-Host "Got user: $($singleUser.user.name)"

# TEST 5: Update User
Write-Host "=== TEST 5: Update User ===" -ForegroundColor Cyan
$updatedUser = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method PUT -ContentType "application/json" -Body '{"role":"superadmin","name":"Vinay Kumar - Updated"}'
Write-Host "Updated user role: $($updatedUser.user.role)"

# TEST 6: Get 404
Write-Host "=== TEST 6: Test 404 ===" -ForegroundColor Cyan
try { Invoke-RestMethod -Uri "$API_URL/users/non-existent-id-12345" -Method GET } catch { Write-Host "404 received as expected: $($_.Exception.Message)" }

# TEST 7: Delete User
Write-Host "=== TEST 7: Delete User ===" -ForegroundColor Cyan
$deleted = Invoke-RestMethod -Uri "$API_URL/users/$USER_ID" -Method DELETE
Write-Host "Delete response: $($deleted.message)"

# TEST 8: Verify Deletion
Write-Host "=== TEST 8: Verify Deletion ===" -ForegroundColor Cyan
$finalList = Invoke-RestMethod -Uri "$API_URL/users" -Method GET
Write-Host "Users remaining: $($finalList.count)"

Write-Host "`n=== ALL TESTS PASSED ===" -ForegroundColor Green""",
        "sh": """#!/bin/bash
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='users-api'].id | [0]" --output text)
API_URL="https://${API_ID}.execute-api.us-east-1.amazonaws.com/prod"

echo -e "\\e[36m=== TEST 1: Create User ===\\e[0m"
RESPONSE1=$(curl -s -X POST "$API_URL/users" -H "Content-Type: application/json" -d '{"name":"Vinay Kumar","email":"vinay@example.com","role":"admin"}')
USER_ID=$(echo $RESPONSE1 | grep -o '"userId": "[^"]*' | cut -d'"' -f4)
echo "Created user ID: $USER_ID"

echo -e "\\e[36m=== TEST 2: Create Second User ===\\e[0m"
curl -s -X POST "$API_URL/users" -H "Content-Type: application/json" -d '{"name":"AWS Engineer","email":"aws@example.com","role":"developer"}'

echo -e "\\n\\e[36m=== TEST 3: List All Users ===\\e[0m"
curl -s -X GET "$API_URL/users"

echo -e "\\n\\n\\e[36m=== TEST 4: Get Single User ===\\e[0m"
curl -s -X GET "$API_URL/users/$USER_ID"

echo -e "\\n\\n\\e[36m=== TEST 5: Update User ===\\e[0m"
curl -s -X PUT "$API_URL/users/$USER_ID" -H "Content-Type: application/json" -d '{"role":"superadmin","name":"Vinay Kumar - Updated"}'

echo -e "\\n\\n\\e[36m=== TEST 6: Test 404 ===\\e[0m"
curl -s -X GET "$API_URL/users/non-existent-id-12345"

echo -e "\\n\\n\\e[36m=== TEST 7: Delete User ===\\e[0m"
curl -s -X DELETE "$API_URL/users/$USER_ID"

echo -e "\\n\\n\\e[36m=== TEST 8: Verify Deletion ===\\e[0m"
curl -s -X GET "$API_URL/users"

echo -e "\\n\\n\\e[32m=== ALL TESTS PASSED ===\\e[0m" """
    },
    {
        "id": "07",
        "title": "VERIFY IN DYNAMODB CONSOLE",
        "desc": "Verify data persistence in DynamoDB",
        "console": """In the console:
- DynamoDB → Tables → users → Explore table items
- See all your created users with all attributes""",
        "ps1": """# Check items in DynamoDB via CLI
aws dynamodb scan `
  --table-name users `
  --query "Items[*].{ID:userId.S,Name:name.S,Email:email.S,Role:role.S}" `
  --output table""",
        "sh": """#!/bin/bash
# Check items in DynamoDB via CLI
aws dynamodb scan \\
  --table-name users \\
  --query "Items[*].{ID:userId.S,Name:name.S,Email:email.S,Role:role.S}" \\
  --output table"""
    },
    {
        "id": "08",
        "title": "MONITOR WITH CLOUDWATCH LOGS",
        "desc": "Monitor execution logs in CloudWatch",
        "console": """- Console → CloudWatch → Log groups
- Search for `/aws/lambda/users-api`
- Open the latest log stream to see standard out and execution details.""",
        "ps1": """# List Lambda log groups
aws logs describe-log-groups `
  --log-group-name-prefix "/aws/lambda/users-api" `
  --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays}" `
  --output table

# Get latest log stream
$LOG_STREAM = aws logs describe-log-streams `
  --log-group-name "/aws/lambda/users-api" `
  --order-by LastEventTime `
  --descending `
  --max-items 1 `
  --query "logStreams[0].logStreamName" `
  --output text

# Read the latest logs
aws logs get-log-events `
  --log-group-name "/aws/lambda/users-api" `
  --log-stream-name $LOG_STREAM `
  --query "events[*].message" `
  --output text""",
        "sh": """#!/bin/bash
# List Lambda log groups
aws logs describe-log-groups \\
  --log-group-name-prefix "/aws/lambda/users-api" \\
  --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays}" \\
  --output table

# Get latest log stream
LOG_STREAM=$(aws logs describe-log-streams \\
  --log-group-name "/aws/lambda/users-api" \\
  --order-by LastEventTime \\
  --descending \\
  --max-items 1 \\
  --query "logStreams[0].logStreamName" \\
  --output text)

# Read the latest logs
aws logs get-log-events \\
  --log-group-name "/aws/lambda/users-api" \\
  --log-stream-name "$LOG_STREAM" \\
  --query "events[*].message" \\
  --output text"""
    },
    {
        "id": "09",
        "title": "UPDATE LAMBDA CODE",
        "desc": "Update and redeploy Lambda function code",
        "console": """When you update your Lambda code:
- Console → Lambda → Functions → `users-api`
- Edit code inline
- Click Deploy""",
        "ps1": """# Repackage
Compress-Archive `
  -Path lambda\lambda_function.py `
  -DestinationPath lambda\function.zip `
  -Force

# Deploy update
aws lambda update-function-code `
  --function-name users-api `
  --zip-file fileb://lambda/function.zip

# Wait for update to complete
aws lambda wait function-updated --function-name users-api
Write-Host "Lambda updated successfully" """,
        "sh": """#!/bin/bash
# Repackage
zip -j lambda/function.zip lambda/lambda_function.py

# Deploy update
aws lambda update-function-code \\
  --function-name users-api \\
  --zip-file fileb://lambda/function.zip

# Wait for update to complete
aws lambda wait function-updated --function-name users-api
echo "Lambda updated successfully" """
    },
    {
        "id": "10",
        "title": "CLEANUP",
        "desc": "Clean up all AWS resources",
        "console": """- Console → API Gateway → Delete `users-api`
- Console → Lambda → Delete `users-api`
- Console → DynamoDB → Delete `users` table
- Console → IAM → Delete `lambda-users-api-role`
- Console → CloudWatch → Delete log group `/aws/lambda/users-api`""",
        "ps1": """# Get API ID
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
Write-Host "Log group deleted" """,
        "sh": """#!/bin/bash
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
echo "Log group deleted" """
    }
]

# 1. Update README table
readme_path = os.path.join(base_dir, "README.md")
with open(readme_path, "r", encoding="utf-8") as f:
    readme = f.read()

table_lines = [
    "| Step | Bash Script | PowerShell Script | Description |",
    "|:---:|:---|:---|:---|"
]
for p in parts:
    table_lines.append(f"| {int(p['id'])} | `scripts/bash/{p['id']}-{p['title'].lower().replace(' ', '-').replace('-table', '').replace('-the', '').replace('-function', '')}.sh` | `scripts/powershell/{p['id']}-{p['title'].lower().replace(' ', '-').replace('-table', '').replace('-the', '').replace('-function', '')}.ps1` | {p['desc']} |")

new_table = "\n".join(table_lines)
readme = re.sub(r'\| Step \| Bash Script.*?(?=\n\n### 📸)', new_table, readme, flags=re.DOTALL)
with open(readme_path, "w", encoding="utf-8") as f:
    f.write(readme)

# 2. Write scripts
for p in parts:
    base_name = f"{p['id']}-{p['title'].lower().replace(' ', '-').replace('-table', '').replace('-the', '').replace('-function', '')}"
    sh_path = os.path.join(scripts_bash, f"{base_name}.sh")
    ps_path = os.path.join(scripts_ps1, f"{base_name}.ps1")
    with open(sh_path, "w", encoding="utf-8") as f: f.write(p["sh"])
    with open(ps_path, "w", encoding="utf-8") as f: f.write(p["ps1"])

# 3. Rewrite Deployment Guide
guide_path = os.path.join(docs_dir, "deployment-guide.md")
content = """# Deployment Guide

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

"""
for p in parts:
    base_name = f"{p['id']}-{p['title'].lower().replace(' ', '-').replace('-table', '').replace('-the', '').replace('-function', '')}"
    
    # Format console steps
    console_text = p['console']
    # Replace "Step X — Y" with "X. **Y**"
    console_text = re.sub(r'Step (\d+) — (.*)', r'\1. **\2**', console_text)
    
    # Remove #!/bin/bash for the markdown blocks
    sh_text = p['sh'].replace("#!/bin/bash\n", "")
    
    content += f"## 🏗️ PART {int(p['id'])} — {p['title']}\n\n"
    content += f"{p['desc']}.\n\n"
    content += f"### 🖥️ Method 1: AWS Management Console\n"
    content += f"{console_text}\n\n"
    content += f"### 🐧 Method 2: AWS CLI (Bash)\n"
    content += f"```bash\n{sh_text}\n```\n\n"
    content += f"### 🪟 Method 3: AWS CLI (PowerShell)\n"
    content += f"```powershell\n{p['ps1']}\n```\n\n"
    content += "---\n\n"

content = content.rstrip("-\n ") + "\n"
with open(guide_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Generated scripts and documentation")
