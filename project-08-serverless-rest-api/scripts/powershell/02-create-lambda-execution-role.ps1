# Create Lambda execution role
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
Start-Sleep -Seconds 10