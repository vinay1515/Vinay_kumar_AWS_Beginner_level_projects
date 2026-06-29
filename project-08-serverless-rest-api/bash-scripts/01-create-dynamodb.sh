#!/bin/bash

# =============================================================================
# Project 8 — Script 01: Create DynamoDB Table
# Creates the 'users' table with on-demand billing and userId partition key
# =============================================================================

echo -e "\e[36m=== Project 8 — Create DynamoDB Table ===\e[0m"
echo ""

aws sts get-caller-identity | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: AWS CLI not configured." -ForegroundColor Red; exit 1 }

echo -e "\e[33mCreating DynamoDB table: users\e[0m"
echo "  Partition key: userId (String)"
echo "  Billing mode:  PAY_PER_REQUEST (on-demand)"
echo ""

aws dynamodb create-table \
  --table-name users \
  --attribute-definitions AttributeName=userId,AttributeType=S \
  --key-schema AttributeName=userId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --tags Key=Project,Value=project-08-serverless | Out-Null

echo -e "\e[33mTable creation initiated. Waiting for ACTIVE status...\e[0m"
aws dynamodb wait table-exists --table-name users
echo -e "\e[32mTable is ACTIVE.\e[0m"

# Verify
aws dynamodb describe-table \
  --table-name users \
  --query "Table.{Name:TableName,Status:TableStatus,Billing:BillingModeSummary.BillingMode,PK:KeySchema[0].AttributeName}" \
  --output table

echo ""
echo -e "\e[36m=== DynamoDB Complete ===\e[0m"
echo -e "\e[36mNext step: Run 02-create-lambda-role.ps1\e[0m"