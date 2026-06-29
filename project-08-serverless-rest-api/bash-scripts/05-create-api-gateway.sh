#!/bin/bash

# =============================================================================
# Project 8 — Script 05: Create API Gateway REST API
# Creates resources, methods (Lambda proxy), and deploys to prod stage
# =============================================================================

echo -e "\e[36m=== Project 8 — Create API Gateway ===\e[0m"
echo ""

# Re-fetch IDs
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
LAMBDA_ARN=$(aws lambda get-function \
  --function-name users-api \
  --query "Configuration.FunctionArn" --output text)

echo "Account ID:  $ACCOUNT_ID"
echo "Lambda ARN:  $LAMBDA_ARN"
echo ""

# ── CREATE REST API ───────────────────────────────────────────────────────────
echo -e "\e[33m[1/8] Creating REST API: users-api...\e[0m"

API_ID=$(aws apigateway create-rest-api \
  --name users-api \
  --description "Serverless Users REST API — Project 8" \
  --endpoint-configuration types=REGIONAL \
  --query "id" --output text)

echo -e "\e[32mAPI ID: $API_ID\e[0m"

# ── GET ROOT RESOURCE ─────────────────────────────────────────────────────────
echo -e "\e[33m[2/8] Getting root resource ID...\e[0m"

ROOT_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --query "items[?path=='/'].id" \
  --output text)

echo "Root ID: $ROOT_ID"

# ── CREATE /users RESOURCE ────────────────────────────────────────────────────
echo -e "\e[33m[3/8] Creating /users resource...\e[0m"

USERS_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part users \
  --query "id" --output text)

echo "Users Resource ID: $USERS_ID"

# ── CREATE /users/{userId} RESOURCE ──────────────────────────────────────────
echo -e "\e[33m[4/8] Creating /users/{userId} resource...\e[0m"

USERID_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $USERS_ID \
  --path-part "{userId}" \
  --query "id" --output text)

echo "UserId Resource ID: $USERID_ID"

# ── HELPER: ADD METHOD + LAMBDA PROXY INTEGRATION ────────────────────────────
LAMBDA_URI="arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations"

function Add-Method {
    param([string]$ResourceId, [string]$HttpMethod)

    aws apigateway put-method \
      --rest-api-id $API_ID \
      --resource-id $ResourceId \
      --http-method $HttpMethod \
      --authorization-type NONE | Out-Null

    aws apigateway put-integration \
      --rest-api-id $API_ID \
      --resource-id $ResourceId \
      --http-method $HttpMethod \
      --type AWS_PROXY \
      --integration-http-method POST \
      --uri $LAMBDA_URI | Out-Null

echo "  Created: $HttpMethod on resource $ResourceId"
}

# ── ADD METHODS TO /users ─────────────────────────────────────────────────────
echo -e "\e[33m[5/8] Adding POST and GET to /users...\e[0m"
Add-Method -ResourceId $USERS_ID -HttpMethod "POST"
Add-Method -ResourceId $USERS_ID -HttpMethod "GET"

# ── ADD METHODS TO /users/{userId} ───────────────────────────────────────────
echo -e "\e[33m[6/8] Adding GET, PUT, DELETE to /users/{userId}...\e[0m"
Add-Method -ResourceId $USERID_ID -HttpMethod "GET"
Add-Method -ResourceId $USERID_ID -HttpMethod "PUT"
Add-Method -ResourceId $USERID_ID -HttpMethod "DELETE"

# ── GRANT API GATEWAY PERMISSION TO INVOKE LAMBDA ────────────────────────────
echo -e "\e[33m[7/8] Granting API Gateway permission to invoke Lambda...\e[0m"

aws lambda add-permission \
  --function-name users-api \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:${ACCOUNT_ID}:${API_ID}/*/*" | Out-Null

echo "Lambda permission granted."

# ── DEPLOY TO PROD ────────────────────────────────────────────────────────────
echo -e "\e[33m[8/8] Deploying API to prod stage...\e[0m"

aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name prod \
  --description "Initial deployment — Project 8" | Out-Null

API_URL="https://$API_ID.execute-api.us-east-1.amazonaws.com/prod"
echo -e "\e[32mAPI deployed.\e[0m"

# ── QUICK SMOKE TEST ──────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mSmoke test: GET /users...\e[0m"
sleep 3  # Brief pause for deployment propagation

try {
    test=Invoke-RestMethod -Uri "$API_URL/users" -Method GET
echo -e "\e[32mGET /users returned HTTP 200 — API is live!\e[0m"
echo "User count: $($test.count)"
} catch {
echo -e "\e[33mSmoke test failed: $($_.Exception.Message)\e[0m"
echo "Try again in 30 seconds — deployments take a moment to propagate."
}

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== API Gateway Complete ===\e[0m"
echo ""
echo "  API_ID  = $API_ID"
echo "  API_URL = $API_URL"
echo ""
echo "Endpoints:"
echo "  POST   $API_URL/users"
echo "  GET    $API_URL/users"
echo "  GET    $API_URL/users/{userId}"
echo "  PUT    $API_URL/users/{userId}"
echo "  DELETE $API_URL/users/{userId}"
echo ""
echo -e "\e[36mNext step: Set `$API_URL and run 06-test-api.ps1\e[0m"