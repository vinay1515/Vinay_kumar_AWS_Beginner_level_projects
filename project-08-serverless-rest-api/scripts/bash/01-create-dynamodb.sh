#!/bin/bash
# Create DynamoDB table with on-demand billing
aws dynamodb create-table \
  --table-name users \
  --attribute-definitions AttributeName=userId,AttributeType=S \
  --key-schema AttributeName=userId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --tags Key=Project,Value=project-08-serverless

# Wait for table to become active
aws dynamodb wait table-exists --table-name users
echo "DynamoDB table created and active"

# Verify table
aws dynamodb describe-table \
  --table-name users \
  --query "Table.{Name:TableName,Status:TableStatus,BillingMode:BillingModeSummary.BillingMode}" \
  --output table