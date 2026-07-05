# Package Lambda into a ZIP file
Compress-Archive `
  -Path lambda\lambda_function.py `
  -DestinationPath lambdaunction.zip `
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
  --output table