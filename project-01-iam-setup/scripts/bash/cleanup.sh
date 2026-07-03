#!/bin/bash
# Load environment variables
if [ -f "../../.env" ]; then
    source ../../.env
elif [ -f "../.env" ]; then
    source ../.env
elif [ -f ".env" ]; then
    source .env
else
    echo -e "\e[31mError: .env file not found.\e[0m"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "\e[36mDeleting CloudWatch Alarm...\e[0m"
aws cloudwatch delete-alarms --alarm-names "AccountBillingAlarm"

echo -e "\e[36mDeleting SNS Topic...\e[0m"
aws sns delete-topic --topic-arn "arn:aws:sns:$AWS_REGION:$ACCOUNT_ID:billing-alerts"

echo -e "\e[33mNOTE: For IAM User Cleanup, please manually detach policies, delete access keys, and then delete the user.\e[0m"
echo -e "\e[33mExample:\e[0m"
echo -e "aws iam detach-user-policy --user-name <YourUserName> --policy-arn arn:aws:iam::aws:policy/AdministratorAccess"
echo -e "aws iam delete-login-profile --user-name <YourUserName>"
echo -e "aws iam delete-access-key --user-name <YourUserName> --access-key-id <YourAccessKeyId>"
echo -e "aws iam delete-user --user-name <YourUserName>"

echo -e "\e[32mInitial Cleanup complete.\e[0m"
