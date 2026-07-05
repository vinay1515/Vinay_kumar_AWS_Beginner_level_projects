# Step 1 - Create REST API
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
Write-Host "API deployed at: $API_URL" 