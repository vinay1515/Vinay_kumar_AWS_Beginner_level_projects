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