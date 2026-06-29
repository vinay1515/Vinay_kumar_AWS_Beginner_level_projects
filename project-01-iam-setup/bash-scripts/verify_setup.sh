#!/bin/bash

#Requires -Version 5.1
<#
.SYNOPSIS
Verifies the AWS CLI installation and IAM user configuration.
#>

echo -e "\e[36mChecking AWS CLI version...\e[0m"
aws --version

if ($LASTEXITCODE -ne 0) {
echo -e "\e[31mAWS CLI is not installed or not in the system PATH.\e[0m"
    exit 1
}

echo -e "\e[36m\nFetching caller identity to verify IAM configuration...\e[0m"
identity=$(aws sts get-caller-identity | jq .)

if ($null -ne $identity) {
echo -e "\e[32mSuccess! You are authenticated.\e[0m"
echo "Account ID : $($identity.Account)"
echo "User ARN   : $($identity.Arn)"
} else {
echo -e "\e[31mFailed to authenticate. Run 'aws configure' to set up your credentials.\e[0m"
}
