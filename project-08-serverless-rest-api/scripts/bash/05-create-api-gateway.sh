#!/bin/bash
# Step 1 - Create REST API
API_ID=$(aws apigateway create-rest-api \
  --name users-api \
  --description "Serverless Users REST API - Project 8" \
  --endpoint-configuration types=REGIONAL \
  --query "id" --output text)

echo "API ID: $API_ID"

# Step 2 - Get root resource ID
ROOT_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --query "items[?path=='/'].id" \
  --output text)

# Step 3 - Create /users resource
USERS_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part users \
  --query "id" --output text)

# Step 4 - Create /users/{userId} resource
USER_ID_RESOURCE=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $USERS_RESOURCE_ID \
  --path-part "{userId}" \
  --query "id" --output text)

# Get Lambda ARN
LAMBDA_ARN=$(aws lambda get-function --function-name users-api --query "Configuration.FunctionArn" --output text)

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

aws lambda add-permission \
  --function-name users-api \
  --statement-id "apigateway-invoke-$TIMESTAMP" \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:${ACCOUNT_ID}:${API_ID}/*/*"

echo "Lambda permission granted to API Gateway"

# Step 8 - Deploy to prod stage
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name prod \
  --description "Initial deployment - Project 8" > /dev/null

API_URL="https://${API_ID}.execute-api.us-east-1.amazonaws.com/prod"
echo "API deployed at: $API_URL" 