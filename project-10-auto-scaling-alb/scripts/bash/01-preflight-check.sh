#!/bin/bash

# =============================================================================
# Project 10 — Script 01: Pre-Flight Check
# Verifies region, identity, and key pair before building infrastructure
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Pre-Flight Check ===\e[0m"
echo ""

# ── VERIFY REGION ─────────────────────────────────────────────────────────────
REGION=$(aws configure get region)
if ($REGION -ne "ap-south-1") {
echo -e "\e[33m  Region is '$REGION' — setting to ap-south-1...\e[0m"
    aws configure set region ap-south-1
    REGION="ap-south-1"
}
echo -e "\e[32m  Region: $REGION\e[0m"

# ── VERIFY IDENTITY ───────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[1/3] Verifying AWS identity...\e[0m"
IDENTITY=$(aws sts get-caller-identity | jq .)
ACCOUNT_ID=$IDENTITY.Account
echo -e "\e[32m  Account ID: $ACCOUNT_ID\e[0m"
echo -e "\e[32m  User ARN:   $($IDENTITY.Arn)\e[0m"

# ── VERIFY KEY PAIR ───────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/3] Verifying key pair...\e[0m"
KEY_NAME=$(aws ec2 describe-key-pairs \
    --key-names aws-ec2-keypair \
    --query "KeyPairs[0].KeyName" --output text 2>/dev/null)

if ($KEY_NAME -eq "aws-ec2-keypair") {
echo -e "\e[32m  Key pair: $KEY_NAME\e[0m"
}
else {
echo -e "\e[31m  Key pair 'aws-ec2-keypair' not found!\e[0m"
echo -e "\e[33m  Create one: EC2 > Key Pairs > Create key pair\e[0m"
    exit 1
}

# ── VERIFY DEFAULT VPC ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/3] Verifying default VPC...\e[0m"
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query "Vpcs[0].VpcId" --output text)

if ($VPC_ID -and $VPC_ID -ne "None") {
echo -e "\e[32m  Default VPC: $VPC_ID\e[0m"
}
else {
echo -e "\e[31m  No default VPC found in ap-south-1!\e[0m"
    exit 1
}

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Pre-Flight Complete ===\e[0m"
echo "  Region:     $REGION"
echo "  Account:    $ACCOUNT_ID"
echo "  Key Pair:   $KEY_NAME"
echo "  Default VPC: $VPC_ID"
echo ""
echo -e "\e[36mNext step: Run 02-setup-vpc-subnets.ps1\e[0m"
