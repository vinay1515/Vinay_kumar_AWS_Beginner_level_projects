#!/bin/bash
set -e
set -u

echo "=> PRE-FLIGHT"
echo "=> Confirming region"
aws configure get region

aws configure set region ap-south-1

echo "=> Getting account ID"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $ACCOUNT_ID"

echo "=> Confirming key pair exists"
aws ec2 describe-key-pairs --key-names aws-ec2-keypair --query "KeyPairs[0].KeyName" --output text

echo "=> Creating project folders"
mkdir -p "$HOME/aws-cloud-projects/project-14-capstone"
cd "$HOME/aws-cloud-projects/project-14-capstone"
mkdir -p templates scripts docs screenshots diagrams
