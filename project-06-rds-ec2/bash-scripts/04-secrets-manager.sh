#!/bin/bash

# =============================================================================
# Project 6 - Script 04: Secrets Manager
# Stores RDS credentials securely - never hardcode passwords in scripts or code
# =============================================================================

echo -e "\e[36m=== Project 6 - Secrets Manager ===\e[0m"
echo ""

echo -e "\e[33mStoring RDS credentials in AWS Secrets Manager...\e[0m"
echo "Secret path: rds/myapp/credentials"
echo ""

# Store credentials as a JSON object
# NOTE: Update the password here if you used something different during RDS creation
SECRET_ARN=$(aws secretsmanager create-secret \
    --name "rds/myapp/credentials" \
    --description "RDS MySQL admin credentials for Project 6" \
    --secret-string '{)
    "username": "admin",
    "password": "<YOUR_RDS_PASSWORD>",
    "engine": "mysql",
    "port": 3306,
    "dbname": "appdb"
  }' \
    --query "ARN" --output text

if ($LASTEXITCODE -ne 0) {
echo -e "\e[33mSecret may already exist. Checking...\e[0m"

    SECRET_ARN=$(aws secretsmanager describe-secret \
        --secret-id "rds/myapp/credentials" \
        --query "ARN" --output text)

echo -e "\e[33mExisting secret found: $SECRET_ARN\e[0m"
}
else {
echo -e "\e[32mSecret created: $SECRET_ARN\e[0m"
}

# Verify
echo ""
echo -e "\e[33mVerifying secret...\e[0m"
aws secretsmanager describe-secret \
    --secret-id "rds/myapp/credentials" \
    --query '{Name:Name,ARN:ARN,Created:CreatedDate}' \
    --output table

echo ""
echo -e "\e[36m=== Secrets Manager Complete ===\e[0m"
echo ""
echo "  SECRET_ARN = $SECRET_ARN"
echo ""
echo "Password rules applied:"
echo "  8+ chars, uppercase + lowercase + numbers + special chars"
echo "  No special characters that break MySQL connection strings"
echo ""
echo "EC2 will retrieve this secret via IAM role in Part 7."
echo ""
echo -e "\e[36mNext step: Run 05-create-rds.ps1\e[0m"