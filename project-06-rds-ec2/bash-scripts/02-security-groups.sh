#!/bin/bash

# =============================================================================
# Project 6 — Script 02: Security Groups
# Creates ec2-app-sg and rds-sg with security group chaining
# =============================================================================

echo -e "\e[36m=== Project 6 — Security Groups ===\e[0m"
echo ""

# Verify VPC_ID is set
if (-not $VPC_ID) {
echo -e "\e[31mERROR: \$VPC_ID is not set. Run 01-vpc-setup.ps1 first.\e[0m"
    exit 1
}

# Detect current public IP
echo -e "\e[33m[1/3] Detecting your public IP...\e[0m"
MY_IP=(Invoke-WebRequest -Uri "https://checkip.amazonaws.com" -UseBasicParsing).Content.Trim()
echo -e "\e[32mYour IP: $MY_IP\e[0m"

# ── EC2 APP SECURITY GROUP ────────────────────────────────────────────────────
echo -e "\e[33m[2/3] Creating ec2-app-sg...\e[0m"

EC2_SG=$(aws ec2 create-security-group \
    --group-name ec2-app-sg \
    --description "Allow SSH and HTTP for app server" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

# SSH from your IP only
aws ec2 authorize-security-group-ingress \
    --group-id $EC2_SG \
    --protocol tcp \
    --port 22 \
    --cidr "$MY_IP/32"

# HTTP from anywhere
aws ec2 authorize-security-group-ingress \
    --group-id $EC2_SG \
    --protocol tcp \
    --port 80 \
    --cidr "0.0.0.0/0"

echo -e "\e[32mec2-app-sg created: $EC2_SG\e[0m"
echo "  Inbound: SSH (22) from $MY_IP/32"
echo "  Inbound: HTTP (80) from 0.0.0.0/0"

# ── RDS SECURITY GROUP ────────────────────────────────────────────────────────
echo -e "\e[33m[3/3] Creating rds-sg...\e[0m"

RDS_SG=$(aws ec2 create-security-group \
    --group-name rds-sg \
    --description "Allow MySQL from EC2 app server only" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

# MySQL ONLY from the EC2 app security group — no CIDR rule
aws ec2 authorize-security-group-ingress \
    --group-id $RDS_SG \
    --protocol tcp \
    --port 3306 \
    --source-group $EC2_SG

echo -e "\e[32mrds-sg created: $RDS_SG\e[0m"
echo "  Inbound: MySQL (3306) from ec2-app-sg ($EC2_SG) only"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying security groups...\e[0m"

aws ec2 describe-security-groups \
    --group-ids $EC2_SG $RDS_SG \
    --query "SecurityGroups[*].{Name:GroupName,ID:GroupId,Rules:IpPermissions[*].{Port:FromPort,Source:join('',IpRanges[*].CidrIp)}}" \
    --output table

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Security Groups Complete ===\e[0m"
echo ""
echo "  EC2_SG = $EC2_SG  (ec2-app-sg)"
echo "  RDS_SG = $RDS_SG  (rds-sg)"
echo ""
echo "Security group chaining summary:"
echo "  Internet → EC2 (port 22/80) → RDS (port 3306) → nowhere else"
echo ""
echo -e "\e[36mNext step: Run 03-rds-subnet-group.ps1\e[0m"