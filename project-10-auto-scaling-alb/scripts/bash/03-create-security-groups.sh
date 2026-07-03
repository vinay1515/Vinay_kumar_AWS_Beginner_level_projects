#!/bin/bash

# =============================================================================
# Project 10 — Script 03: Create Security Groups
# Creates ALB SG (HTTP from internet) and EC2 SG (HTTP from ALB only)
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Create Security Groups ===\e[0m"
echo ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query "Vpcs[0].VpcId" --output text)

MY_IP=(Invoke-WebRequest -Uri "https://checkip.amazonaws.com" \
        -UseBasicParsing).Content.Trim()

echo -e "\e[32m  VPC: $VPC_ID\e[0m"
echo -e "\e[32m  My IP: $MY_IP\e[0m"
echo ""

# ── ALB SECURITY GROUP ────────────────────────────────────────────────────────
echo -e "\e[33m[1/2] Creating ALB Security Group...\e[0m"

ALB_SG=$(aws ec2 create-security-group \
    --group-name alb-sg \
    --description "ALB: allow HTTP from internet" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

# ALB accepts HTTP from anywhere
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG \
    --protocol tcp --port 80 --cidr "0.0.0.0/0" | Out-Null

# ALB accepts HTTPS from anywhere (for future SSL)
aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG \
    --protocol tcp --port 443 --cidr "0.0.0.0/0" | Out-Null

echo -e "\e[32m  ALB SG: $ALB_SG\e[0m"
echo -e "\e[32m  Rules: HTTP(80) from 0.0.0.0/0, HTTPS(443) from 0.0.0.0/0\e[0m"

# ── EC2 SECURITY GROUP ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/2] Creating EC2 Security Group...\e[0m"

EC2_SG=$(aws ec2 create-security-group \
    --group-name asg-ec2-sg \
    --description "EC2: allow HTTP from ALB only, SSH from My IP" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

# EC2 accepts HTTP only from ALB security group
aws ec2 authorize-security-group-ingress \
    --group-id $EC2_SG \
    --protocol tcp --port 80 \
    --source-group $ALB_SG | Out-Null

# EC2 accepts SSH from your IP for debugging
aws ec2 authorize-security-group-ingress \
    --group-id $EC2_SG \
    --protocol tcp --port 22 \
    --cidr "$MY_IP/32" | Out-Null

echo -e "\e[32m  EC2 SG: $EC2_SG\e[0m"
echo -e "\e[32m  Rules: HTTP(80) from ALB SG, SSH(22) from $MY_IP/32\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying security groups...\e[0m"
aws ec2 describe-security-groups \
    --group-ids $ALB_SG $EC2_SG \
    --query "SecurityGroups[*].{Name:GroupName,ID:GroupId,Description:Description}" \
    --output table

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Security Groups Complete ===\e[0m"
echo "  ALB_SG: $ALB_SG  (HTTP/HTTPS from internet)"
echo "  EC2_SG: $EC2_SG  (HTTP from ALB, SSH from your IP)"
echo ""
echo -e "\e[33m  Key: EC2 only accepts HTTP from ALB — not from the internet directly.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 04-create-launch-template.ps1\e[0m"
