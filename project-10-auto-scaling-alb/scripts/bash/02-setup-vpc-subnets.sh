#!/bin/bash

# =============================================================================
# Project 10 — Script 02: Setup VPC and Subnets
# Discovers default VPC and selects two subnets in different AZs for ALB
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Setup VPC and Subnets ===\e[0m"
echo ""

# ── GET DEFAULT VPC ───────────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Getting default VPC...\e[0m"
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query "Vpcs[0].VpcId" --output text)

echo -e "\e[32m  VPC ID: $VPC_ID\e[0m"

# ── GET DEFAULT SUBNETS ───────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/3] Getting default subnets (one per AZ)...\e[0m"
SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    "Name=defaultForAz,Values=true" \
    --query "Subnets[*].SubnetId" \
    --output text)

SUBNET_LIST=($SUBNETS)
SUBNET_A=${SUBNET_LIST[0]}
SUBNET_B=${SUBNET_LIST[1]}

echo -e "\e[32m  Subnet A: $SUBNET_A\e[0m"
echo -e "\e[32m  Subnet B: $SUBNET_B\e[0m"

# ── VERIFY DIFFERENT AZs ─────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/3] Verifying subnets are in different AZs...\e[0m"
aws ec2 describe-subnets \
    --subnet-ids $SUBNET_A $SUBNET_B \
    --query "Subnets[*].{SubnetId:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}" \
    --output table

# ── EXPORT VARIABLES ──────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== VPC Setup Complete ===\e[0m"
echo "  VPC_ID:   $VPC_ID"
echo "  SUBNET_A: $SUBNET_A"
echo "  SUBNET_B: $SUBNET_B"
echo ""
echo -e "\e[33m  ALB requires minimum 2 AZs for high availability.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 03-create-security-groups.sh\e[0m"
