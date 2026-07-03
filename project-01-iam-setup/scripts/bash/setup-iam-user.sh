#!/bin/bash
# Automates the creation of an IAM Admin user

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME=$1

echo "Creating IAM User: $USERNAME..."
aws iam create-user --user-name $USERNAME

echo "Attaching AdministratorAccess policy..."
aws iam attach-user-policy --user-name $USERNAME --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "Enabling console access..."
# Generate random password
PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9_!@#$%^&*' </dev/urandom | head -c 16)
aws iam create-login-profile --user-name $USERNAME --password "$PASSWORD" --password-reset-required

echo "Creating access keys for programmatic access..."
ACCESS_KEY_JSON=$(aws iam create-access-key --user-name $USERNAME)

KEY_ID=$(echo $ACCESS_KEY_JSON | grep -o '"AccessKeyId": "[^"]*' | cut -d'"' -f4)
SECRET=$(echo $ACCESS_KEY_JSON | grep -o '"SecretAccessKey": "[^"]*' | cut -d'"' -f4)

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
LOGIN_LINK="https://$ACCOUNT_ID.signin.aws.amazon.com/console"

echo -e "\n--- Setup Complete ---"
echo "IAM User: $USERNAME"
echo "Console Password: $PASSWORD"
echo "Access Key ID: $KEY_ID"
echo "Secret Access Key: $SECRET"

CSV_PATH="./${USERNAME}-credentials.csv"
echo "User Name,Password,Access key ID,Secret access key,Console login link" > $CSV_PATH
echo "$USERNAME,$PASSWORD,$KEY_ID,$SECRET,$LOGIN_LINK" >> $CSV_PATH

echo -e "\nCredentials saved to $CSV_PATH"
echo "IMPORTANT: Keep this file secure or delete it after configuring AWS CLI."
