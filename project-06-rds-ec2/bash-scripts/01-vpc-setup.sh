#!/bin/bash

# =============================================================================
# Project 6 — Script 01: VPC Setup
# Creates the full VPC infrastructure for the RDS + EC2 two-tier project
# =============================================================================

echo -e "\e[36m=== Project 6 — VPC Setup ===\e[0m"
echo ""

# Pre-flight check
echo -e "\e[33mRunning pre-flight checks...\e[0m"
aws sts get-caller-identity | Out-Null
if ($LASTEXITCODE -ne 0) {
echo -e "\e[31mERROR: AWS CLI not configured. Run 'aws configure' first.\e[0m"
    exit 1
}

REGION=$(aws configure get region)
if ($REGION -ne "us-east-1") {
echo -e "\e[33mWARNING: Region is $REGION — expected us-east-1\e[0m"
echo "Set with: aws configure set region us-east-1"
}

echo -e "\e[32mPre-flight OK — deploying in region: $REGION\e[0m"
echo ""

# ── VPC ───────────────────────────────────────────────────────────────────────
echo -e "\e[33m[1/9] Creating VPC...\e[0m"

VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=my-custom-vpc}]" \
    --query "Vpc.VpcId" --output text)

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

echo -e "\e[32mVPC created: $VPC_ID\e[0m"

# ── SUBNETS ───────────────────────────────────────────────────────────────────
echo -e "\e[33m[2/9] Creating subnets...\e[0m"

PUB_SUBNET_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-a}]" \
    --query "Subnet.SubnetId" --output text)

PUB_SUBNET_B=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1b \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-b}]" \
    --query "Subnet.SubnetId" --output text)

PRI_SUBNET_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.3.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-a}]" \
    --query "Subnet.SubnetId" --output text)

PRI_SUBNET_B=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.4.0/24 \
    --availability-zone us-east-1b \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-b}]" \
    --query "Subnet.SubnetId" --output text)

# Enable auto-assign public IP for public subnets
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_A --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_B --map-public-ip-on-launch

echo -e "\e[32mSubnets created:\e[0m"
echo "  public-subnet-a  (10.0.1.0/24 us-east-1a): $PUB_SUBNET_A"
echo "  public-subnet-b  (10.0.2.0/24 us-east-1b): $PUB_SUBNET_B"
echo "  private-subnet-a (10.0.3.0/24 us-east-1a): $PRI_SUBNET_A"
echo "  private-subnet-b (10.0.4.0/24 us-east-1b): $PRI_SUBNET_B"

# ── INTERNET GATEWAY ──────────────────────────────────────────────────────────
echo -e "\e[33m[3/9] Creating Internet Gateway...\e[0m"

IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-vpc-igw}]" \
    --query "InternetGateway.InternetGatewayId" --output text)

aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

echo -e "\e[32mInternet Gateway created and attached: $IGW_ID\e[0m"

# ── PUBLIC ROUTE TABLE ────────────────────────────────────────────────────────
echo -e "\e[33m[4/9] Creating public route table...\e[0m"

PUB_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-route-table}]" \
    --query "RouteTable.RouteTableId" --output text)

aws ec2 create-route \
    --route-table-id $PUB_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID | Out-Null

aws ec2 associate-route-table \
    --route-table-id $PUB_RT_ID \
    --subnet-id $PUB_SUBNET_A | Out-Null

aws ec2 associate-route-table \
    --route-table-id $PUB_RT_ID \
    --subnet-id $PUB_SUBNET_B | Out-Null

echo -e "\e[32mPublic route table created: $PUB_RT_ID\e[0m"

# ── PRIVATE ROUTE TABLE ───────────────────────────────────────────────────────
echo -e "\e[33m[5/9] Creating private route table...\e[0m"

PRI_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=private-route-table}]" \
    --query "RouteTable.RouteTableId" --output text)

aws ec2 associate-route-table \
    --route-table-id $PRI_RT_ID \
    --subnet-id $PRI_SUBNET_A | Out-Null

aws ec2 associate-route-table \
    --route-table-id $PRI_RT_ID \
    --subnet-id $PRI_SUBNET_B | Out-Null

echo -e "\e[32mPrivate route table created: $PRI_RT_ID\e[0m"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== VPC Setup Complete ===\e[0m"
echo ""
echo "Resource IDs (save these for subsequent scripts):"
echo "  VPC_ID        = $VPC_ID"
echo "  PUB_SUBNET_A  = $PUB_SUBNET_A"
echo "  PUB_SUBNET_B  = $PUB_SUBNET_B"
echo "  PRI_SUBNET_A  = $PRI_SUBNET_A"
echo "  PRI_SUBNET_B  = $PRI_SUBNET_B"
echo "  IGW_ID        = $IGW_ID"
echo "  PUB_RT_ID     = $PUB_RT_ID"
echo "  PRI_RT_ID     = $PRI_RT_ID"
echo ""
echo -e "\e[36mNext step: Run 02-security-groups.ps1\e[0m"