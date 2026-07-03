#!/bin/bash

# Create the keys folder
mkdir -p ~/aws-keys

# Create key pair and save private key
aws ec2 create-key-pair \
  --key-name aws-ec2-keypair \
  --key-type RSA \
  --key-format ppk \
  --query "KeyMaterial" \
  --output text > ~/aws-keys/aws-ec2-keypair.ppk

# Verify it was created in AWS
aws ec2 describe-key-pairs --key-names aws-ec2-keypair \
  --query "KeyPairs[*].{Name:KeyName,ID:KeyPairId}" \
  --output table

echo -e "\e[32mCreated key pair: aws-ec2-keypair\e[0m"
