# Deployment Guide

This document provides the deployment steps for Project 06 in three formats: **AWS Management Console**, **Bash**, and **PowerShell**.

## Prerequisites
- AWS CLI
- Appropriate IAM permissions
- Checked Free Tier status for db.t3.micro, t2.micro, etc.

## PART 1 — REBUILD THE VPC

### 🖥️ Method 1: AWS Management Console

We need the same VPC structure from Project 5.

### 🐧 Method 2: AWS CLI (Bash)

```bash
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
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 01: VPC Setup
# Creates the full VPC infrastructure for the RDS + EC2 two-tier project
# =============================================================================

Write-Host "=== Project 6 — VPC Setup ===" -ForegroundColor Cyan
Write-Host ""

# Pre-flight check
Write-Host "Running pre-flight checks..." -ForegroundColor Yellow
aws sts get-caller-identity | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS CLI not configured. Run 'aws configure' first." -ForegroundColor Red
    exit 1
}

$REGION = aws configure get region
if ($REGION -ne "us-east-1") {
    Write-Host "WARNING: Region is $REGION — expected us-east-1" -ForegroundColor Yellow
    Write-Host "Set with: aws configure set region us-east-1"
}

Write-Host "Pre-flight OK — deploying in region: $REGION" -ForegroundColor Green
Write-Host ""

# ── VPC ───────────────────────────────────────────────────────────────────────
Write-Host "[1/9] Creating VPC..." -ForegroundColor Yellow

$VPC_ID = aws ec2 create-vpc `
    --cidr-block 10.0.0.0/16 `
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=my-custom-vpc}]" `
    --query "Vpc.VpcId" --output text

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

Write-Host "VPC created: $VPC_ID" -ForegroundColor Green

# ── SUBNETS ───────────────────────────────────────────────────────────────────
Write-Host "[2/9] Creating subnets..." -ForegroundColor Yellow

$PUB_SUBNET_A = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block 10.0.1.0/24 `
    --availability-zone us-east-1a `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-a}]" `
    --query "Subnet.SubnetId" --output text

$PUB_SUBNET_B = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block 10.0.2.0/24 `
    --availability-zone us-east-1b `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-b}]" `
    --query "Subnet.SubnetId" --output text

$PRI_SUBNET_A = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block 10.0.3.0/24 `
    --availability-zone us-east-1a `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-a}]" `
    --query "Subnet.SubnetId" --output text

$PRI_SUBNET_B = aws ec2 create-subnet `
    --vpc-id $VPC_ID `
    --cidr-block 10.0.4.0/24 `
    --availability-zone us-east-1b `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-b}]" `
    --query "Subnet.SubnetId" --output text

# Enable auto-assign public IP for public subnets
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_A --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_B --map-public-ip-on-launch

Write-Host "Subnets created:" -ForegroundColor Green
Write-Host "  public-subnet-a  (10.0.1.0/24 us-east-1a): $PUB_SUBNET_A"
Write-Host "  public-subnet-b  (10.0.2.0/24 us-east-1b): $PUB_SUBNET_B"
Write-Host "  private-subnet-a (10.0.3.0/24 us-east-1a): $PRI_SUBNET_A"
Write-Host "  private-subnet-b (10.0.4.0/24 us-east-1b): $PRI_SUBNET_B"

# ── INTERNET GATEWAY ──────────────────────────────────────────────────────────
Write-Host "[3/9] Creating Internet Gateway..." -ForegroundColor Yellow

$IGW_ID = aws ec2 create-internet-gateway `
    --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-vpc-igw}]" `
    --query "InternetGateway.InternetGatewayId" --output text

aws ec2 attach-internet-gateway `
    --internet-gateway-id $IGW_ID `
    --vpc-id $VPC_ID

Write-Host "Internet Gateway created and attached: $IGW_ID" -ForegroundColor Green

# ── PUBLIC ROUTE TABLE ────────────────────────────────────────────────────────
Write-Host "[4/9] Creating public route table..." -ForegroundColor Yellow

$PUB_RT_ID = aws ec2 create-route-table `
    --vpc-id $VPC_ID `
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-route-table}]" `
    --query "RouteTable.RouteTableId" --output text

aws ec2 create-route `
    --route-table-id $PUB_RT_ID `
    --destination-cidr-block 0.0.0.0/0 `
    --gateway-id $IGW_ID | Out-Null

aws ec2 associate-route-table `
    --route-table-id $PUB_RT_ID `
    --subnet-id $PUB_SUBNET_A | Out-Null

aws ec2 associate-route-table `
    --route-table-id $PUB_RT_ID `
    --subnet-id $PUB_SUBNET_B | Out-Null

Write-Host "Public route table created: $PUB_RT_ID" -ForegroundColor Green

# ── PRIVATE ROUTE TABLE ───────────────────────────────────────────────────────
Write-Host "[5/9] Creating private route table..." -ForegroundColor Yellow

$PRI_RT_ID = aws ec2 create-route-table `
    --vpc-id $VPC_ID `
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=private-route-table}]" `
    --query "RouteTable.RouteTableId" --output text

aws ec2 associate-route-table `
    --route-table-id $PRI_RT_ID `
    --subnet-id $PRI_SUBNET_A | Out-Null

aws ec2 associate-route-table `
    --route-table-id $PRI_RT_ID `
    --subnet-id $PRI_SUBNET_B | Out-Null

Write-Host "Private route table created: $PRI_RT_ID" -ForegroundColor Green

# ── SUMMARY ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== VPC Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resource IDs (save these for subsequent scripts):"
Write-Host "  VPC_ID        = $VPC_ID"
Write-Host "  PUB_SUBNET_A  = $PUB_SUBNET_A"
Write-Host "  PUB_SUBNET_B  = $PUB_SUBNET_B"
Write-Host "  PRI_SUBNET_A  = $PRI_SUBNET_A"
Write-Host "  PRI_SUBNET_B  = $PRI_SUBNET_B"
Write-Host "  IGW_ID        = $IGW_ID"
Write-Host "  PUB_RT_ID     = $PUB_RT_ID"
Write-Host "  PRI_RT_ID     = $PRI_RT_ID"
Write-Host ""
Write-Host "Next step: Run 02-security-groups.ps1" -ForegroundColor Cyan
```

## PART 2 — CREATE SECURITY GROUPS

### 🖥️ Method 1: AWS Management Console

We need three security groups for this project:
- `ec2-app-sg` → allows SSH from your IP + HTTP from internet
- `rds-sg` → allows MySQL (3306) ONLY from ec2-app-sg

**Step 1 — Create ec2-app-sg**
- EC2 → Security Groups → Create security group
- Name: ec2-app-sg
- Description: Allow SSH and HTTP for app server
- VPC: my-custom-vpc
- Inbound rules:
  - SSH (22) from My IP
  - HTTP (80) from Anywhere IPv4

**Step 2 — Create rds-sg**
- Create security group
- Name: rds-sg
- Description: Allow MySQL from EC2 app server only
- VPC: my-custom-vpc
- Inbound rules:
  - MySQL/Aurora (3306) from Custom → select ec2-app-sg

### 🐧 Method 2: AWS CLI (Bash)

```bash
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
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 02: Security Groups
# Creates ec2-app-sg and rds-sg with security group chaining
# =============================================================================

Write-Host "=== Project 6 — Security Groups ===" -ForegroundColor Cyan
Write-Host ""

# Verify VPC_ID is set
if (-not $VPC_ID) {
    Write-Host "ERROR: \$VPC_ID is not set. Run 01-vpc-setup.ps1 first." -ForegroundColor Red
    exit 1
}

# Detect current public IP
Write-Host "[1/3] Detecting your public IP..." -ForegroundColor Yellow
$MY_IP = (Invoke-WebRequest -Uri "https://checkip.amazonaws.com" -UseBasicParsing).Content.Trim()
Write-Host "Your IP: $MY_IP" -ForegroundColor Green

# ── EC2 APP SECURITY GROUP ────────────────────────────────────────────────────
Write-Host "[2/3] Creating ec2-app-sg..." -ForegroundColor Yellow

$EC2_SG = aws ec2 create-security-group `
    --group-name ec2-app-sg `
    --description "Allow SSH and HTTP for app server" `
    --vpc-id $VPC_ID `
    --query "GroupId" --output text

# SSH from your IP only
aws ec2 authorize-security-group-ingress `
    --group-id $EC2_SG `
    --protocol tcp `
    --port 22 `
    --cidr "$MY_IP/32"

# HTTP from anywhere
aws ec2 authorize-security-group-ingress `
    --group-id $EC2_SG `
    --protocol tcp `
    --port 80 `
    --cidr "0.0.0.0/0"

Write-Host "ec2-app-sg created: $EC2_SG" -ForegroundColor Green
Write-Host "  Inbound: SSH (22) from $MY_IP/32"
Write-Host "  Inbound: HTTP (80) from 0.0.0.0/0"

# ── RDS SECURITY GROUP ────────────────────────────────────────────────────────
Write-Host "[3/3] Creating rds-sg..." -ForegroundColor Yellow

$RDS_SG = aws ec2 create-security-group `
    --group-name rds-sg `
    --description "Allow MySQL from EC2 app server only" `
    --vpc-id $VPC_ID `
    --query "GroupId" --output text

# MySQL ONLY from the EC2 app security group — no CIDR rule
aws ec2 authorize-security-group-ingress `
    --group-id $RDS_SG `
    --protocol tcp `
    --port 3306 `
    --source-group $EC2_SG

Write-Host "rds-sg created: $RDS_SG" -ForegroundColor Green
Write-Host "  Inbound: MySQL (3306) from ec2-app-sg ($EC2_SG) only"

# ── VERIFY ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Verifying security groups..." -ForegroundColor Yellow

aws ec2 describe-security-groups `
    --group-ids $EC2_SG $RDS_SG `
    --query "SecurityGroups[*].{Name:GroupName,ID:GroupId,Rules:IpPermissions[*].{Port:FromPort,Source:join('',IpRanges[*].CidrIp)}}" `
    --output table

# ── SUMMARY ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Security Groups Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  EC2_SG = $EC2_SG  (ec2-app-sg)"
Write-Host "  RDS_SG = $RDS_SG  (rds-sg)"
Write-Host ""
Write-Host "Security group chaining summary:"
Write-Host "  Internet → EC2 (port 22/80) → RDS (port 3306) → nowhere else"
Write-Host ""
Write-Host "Next step: Run 03-rds-subnet-group.ps1" -ForegroundColor Cyan
```

## PART 3 — CREATE RDS SUBNET GROUP

### 🖥️ Method 1: AWS Management Console

An RDS subnet group tells RDS which subnets it can use. It must span at least two AZs — RDS requires this even for single-AZ instances.

**Step 3 — Create DB subnet group**
- Search bar → RDS → left panel → Subnet groups
- Click Create DB subnet group
- Name: rds-subnet-group
- Description: Private subnets for RDS across two AZs
- VPC: my-custom-vpc
- Under Add subnets:
  - Availability Zones: select us-east-1a and us-east-1b
  - Subnets: select private-subnet-a and private-subnet-b
- Click Create

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 — Script 03: RDS Subnet Group
# Creates the DB subnet group spanning both private subnets across two AZs
# =============================================================================

echo -e "\e[36m=== Project 6 — RDS Subnet Group ===\e[0m"
echo ""

if (-not $PRI_SUBNET_A -or -not $PRI_SUBNET_B) {
echo -e "\e[31mERROR: Private subnet IDs not set. Run 01-vpc-setup.ps1 first.\e[0m"
    exit 1
}

echo -e "\e[33mUsing private subnets:\e[0m"
echo "  private-subnet-a: $PRI_SUBNET_A (us-east-1a)"
echo "  private-subnet-b: $PRI_SUBNET_B (us-east-1b)"
echo ""

echo -e "\e[33mCreating rds-subnet-group...\e[0m"

aws rds create-db-subnet-group \
    --db-subnet-group-name rds-subnet-group \
    --db-subnet-group-description "Private subnets for RDS across two AZs" \
    --subnet-ids $PRI_SUBNET_A $PRI_SUBNET_B \
    --tags Key=Name,Value=rds-subnet-group | Out-Null

# Verify
echo -e "\e[33mVerifying subnet group...\e[0m"
aws rds describe-db-subnet-groups \
    --db-subnet-group-name rds-subnet-group \
    --query "DBSubnetGroups[0].{Name:DBSubnetGroupName,VPC:VpcId,Status:SubnetGroupStatus,Subnets:Subnets[*].SubnetIdentifier}" \
    --output table

echo ""
echo -e "\e[36m=== RDS Subnet Group Complete ===\e[0m"
echo "  Name:    rds-subnet-group"
echo "  Subnets: $PRI_SUBNET_A, $PRI_SUBNET_B"
echo "  AZs:     us-east-1a, us-east-1b"
echo ""
echo "Note: RDS requires subnet groups spanning 2+ AZs even for single-AZ instances."
echo ""
echo -e "\e[36mNext step: Run 04-secrets-manager.ps1\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 03: RDS Subnet Group
# Creates the DB subnet group spanning both private subnets across two AZs
# =============================================================================

Write-Host "=== Project 6 — RDS Subnet Group ===" -ForegroundColor Cyan
Write-Host ""

if (-not $PRI_SUBNET_A -or -not $PRI_SUBNET_B) {
    Write-Host "ERROR: Private subnet IDs not set. Run 01-vpc-setup.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "Using private subnets:" -ForegroundColor Yellow
Write-Host "  private-subnet-a: $PRI_SUBNET_A (us-east-1a)"
Write-Host "  private-subnet-b: $PRI_SUBNET_B (us-east-1b)"
Write-Host ""

Write-Host "Creating rds-subnet-group..." -ForegroundColor Yellow

aws rds create-db-subnet-group `
    --db-subnet-group-name rds-subnet-group `
    --db-subnet-group-description "Private subnets for RDS across two AZs" `
    --subnet-ids $PRI_SUBNET_A $PRI_SUBNET_B `
    --tags Key=Name,Value=rds-subnet-group | Out-Null

# Verify
Write-Host "Verifying subnet group..." -ForegroundColor Yellow
aws rds describe-db-subnet-groups `
    --db-subnet-group-name rds-subnet-group `
    --query "DBSubnetGroups[0].{Name:DBSubnetGroupName,VPC:VpcId,Status:SubnetGroupStatus,Subnets:Subnets[*].SubnetIdentifier}" `
    --output table

Write-Host ""
Write-Host "=== RDS Subnet Group Complete ===" -ForegroundColor Cyan
Write-Host "  Name:    rds-subnet-group"
Write-Host "  Subnets: $PRI_SUBNET_A, $PRI_SUBNET_B"
Write-Host "  AZs:     us-east-1a, us-east-1b"
Write-Host ""
Write-Host "Note: RDS requires subnet groups spanning 2+ AZs even for single-AZ instances."
Write-Host ""
Write-Host "Next step: Run 04-secrets-manager.ps1" -ForegroundColor Cyan
```

## PART 4 — STORE DB CREDENTIALS IN SECRETS MANAGER

### 🖥️ Method 1: AWS Management Console

Never hardcode database passwords. We store them in AWS Secrets Manager and retrieve them securely.

**Step 4 — Create a secret**
- Search bar → Secrets Manager → Store a new secret
- Secret type: Credentials for Amazon RDS database
- Username: admin
- Password: create a strong password (e.g. MyDB#Secure2024!)
- Click Next
- Secret name: rds/myapp/credentials
- Click Next → Next → Store
- Copy the Secret ARN — save it

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 - Script 04: Secrets Manager
# Stores RDS credentials securely - never hardcode passwords in scripts or code
# =============================================================================

echo -e "\e[36m=== Project 6 - Secrets Manager ===\e[0m"
echo ""

echo -e "\e[33mStoring RDS credentials in AWS Secrets Manager...\e[0m"
echo "Secret path: rds/myapp/credentials"
echo ""

# Store credentials as a JSON object
# NOTE: Update the password here if you used something different during RDS creation
SECRET_ARN=$(aws secretsmanager create-secret \
    --name "rds/myapp/credentials" \
    --description "RDS MySQL admin credentials for Project 6" \
    --secret-string '{)
    "username": "admin",
    "password": "<YOUR_RDS_PASSWORD>",
    "engine": "mysql",
    "port": 3306,
    "dbname": "appdb"
  }' \
    --query "ARN" --output text

if ($LASTEXITCODE -ne 0) {
echo -e "\e[33mSecret may already exist. Checking...\e[0m"

    SECRET_ARN=$(aws secretsmanager describe-secret \
        --secret-id "rds/myapp/credentials" \
        --query "ARN" --output text)

echo -e "\e[33mExisting secret found: $SECRET_ARN\e[0m"
}
else {
echo -e "\e[32mSecret created: $SECRET_ARN\e[0m"
}

# Verify
echo ""
echo -e "\e[33mVerifying secret...\e[0m"
aws secretsmanager describe-secret \
    --secret-id "rds/myapp/credentials" \
    --query '{Name:Name,ARN:ARN,Created:CreatedDate}' \
    --output table

echo ""
echo -e "\e[36m=== Secrets Manager Complete ===\e[0m"
echo ""
echo "  SECRET_ARN = $SECRET_ARN"
echo ""
echo "Password rules applied:"
echo "  8+ chars, uppercase + lowercase + numbers + special chars"
echo "  No special characters that break MySQL connection strings"
echo ""
echo "EC2 will retrieve this secret via IAM role in Part 7."
echo ""
echo -e "\e[36mNext step: Run 05-create-rds.ps1\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 - Script 04: Secrets Manager
# Stores RDS credentials securely - never hardcode passwords in scripts or code
# =============================================================================

Write-Host "=== Project 6 - Secrets Manager ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Storing RDS credentials in AWS Secrets Manager..." -ForegroundColor Yellow
Write-Host "Secret path: rds/myapp/credentials"
Write-Host ""

# Store credentials as a JSON object
# NOTE: Update the password here if you used something different during RDS creation
$SECRET_ARN = aws secretsmanager create-secret `
    --name "rds/myapp/credentials" `
    --description "RDS MySQL admin credentials for Project 6" `
    --secret-string '{
    "username": "admin",
    "password": "<YOUR_RDS_PASSWORD>",
    "engine": "mysql",
    "port": 3306,
    "dbname": "appdb"
  }' `
    --query "ARN" --output text

if ($LASTEXITCODE -ne 0) {
    Write-Host "Secret may already exist. Checking..." -ForegroundColor Yellow

    $SECRET_ARN = aws secretsmanager describe-secret `
        --secret-id "rds/myapp/credentials" `
        --query "ARN" --output text

    Write-Host "Existing secret found: $SECRET_ARN" -ForegroundColor Yellow
}
else {
    Write-Host "Secret created: $SECRET_ARN" -ForegroundColor Green
}

# Verify
Write-Host ""
Write-Host "Verifying secret..." -ForegroundColor Yellow
aws secretsmanager describe-secret `
    --secret-id "rds/myapp/credentials" `
    --query '{Name:Name,ARN:ARN,Created:CreatedDate}' `
    --output table

Write-Host ""
Write-Host "=== Secrets Manager Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  SECRET_ARN = $SECRET_ARN"
Write-Host ""
Write-Host "Password rules applied:"
Write-Host "  8+ chars, uppercase + lowercase + numbers + special chars"
Write-Host "  No special characters that break MySQL connection strings"
Write-Host ""
Write-Host "EC2 will retrieve this secret via IAM role in Part 7."
Write-Host ""
Write-Host "Next step: Run 05-create-rds.ps1" -ForegroundColor Cyan
```

## PART 5 — LAUNCH RDS MYSQL INSTANCE

### 🖥️ Method 1: AWS Management Console

**Step 5 — Create database**
- RDS → Create database
- Choose a database creation method: Standard create
- Engine type: MySQL
- Engine version: MySQL 8.0.x
- Template: Free tier
- DB instance identifier: myapp-database
- Master username: admin
- Master password: (same as Secrets Manager)
- DB instance class: db.t3.micro
- Storage type: gp2 (20 GiB)
- Storage autoscaling: Disable
- VPC: my-custom-vpc
- DB subnet group: rds-subnet-group
- Public access: No
- VPC security group: rds-sg
- Availability Zone: us-east-1a
- Initial database name: appdb
- Automated backups: Enable (1 day retention)
- Click Create database

**Step 6 — Copy the endpoint**
Once status shows Available:
- Click your database → Connectivity & security tab
- Copy the Endpoint and Port (3306)

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 — Script 05: Create RDS MySQL Instance
# Launches db.t3.micro MySQL 8.0 in private subnets — no public access
# =============================================================================

echo -e "\e[36m=== Project 6 — Launch RDS MySQL ===\e[0m"
echo ""

if (-not $RDS_SG) {
echo -e "\e[31mERROR: \$RDS_SG not set. Run 02-security-groups.ps1 first.\e[0m"
    exit 1
}

echo -e "\e[33mConfiguration:\e[0m"
echo "  Engine:         MySQL 8.0"
echo "  Instance class: db.t3.micro (Free Tier eligible)"
echo "  Storage:        20 GiB gp2"
echo "  Subnet group:   rds-subnet-group"
echo "  Security group: $RDS_SG (rds-sg)"
echo "  Public access:  No"
echo "  Initial DB:     appdb"
echo ""

echo -e "\e[33mLaunching RDS instance (this command returns immediately)...\e[0m"

aws rds create-db-instance \
    --db-instance-identifier myapp-database \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0 \
    --master-username admin \
    --master-user-password "MyDB#Secure2024!" \
    --db-name appdb \
    --vpc-security-group-ids $RDS_SG \
    --db-subnet-group-name rds-subnet-group \
    --allocated-storage 20 \
    --storage-type gp2 \
    --no-multi-az \
    --no-publicly-accessible \
    --backup-retention-period 1 \
    --no-deletion-protection \
    --tags Key=Name,Value=myapp-database | Out-Null

echo -e "\e[32mRDS creation initiated.\e[0m"
echo ""
echo -e "\e[33mWaiting for RDS to become available (typically 5-10 minutes)...\e[0m"
echo "You can monitor progress in: RDS console -> Databases -> myapp-database"
echo ""

# Block until available — this is the most reliable approach
aws rds wait db-instance-available \
    --db-instance-identifier myapp-database

echo -e "\e[32mRDS is available!\e[0m"
echo ""

# Fetch and display the endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier myapp-database \
    --query "DBInstances[0].Endpoint.Address" \
    --output text)

RDS_PORT=$(aws rds describe-db-instances \
    --db-instance-identifier myapp-database \
    --query "DBInstances[0].Endpoint.Port" \
    --output text)

echo -e "\e[36m=== RDS MySQL Ready ===\e[0m"
echo ""
echo "  Endpoint: $RDS_ENDPOINT"
echo "  Port:     $RDS_PORT"
echo ""
echo "IMPORTANT: Copy the endpoint above. You will need it in Part 7."
echo ""

# Describe the instance
aws rds describe-db-instances \
    --db-instance-identifier myapp-database \
    --query "DBInstances[0].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Engine:Engine,Status:DBInstanceStatus,Endpoint:Endpoint.Address,Storage:AllocatedStorage,Public:PubliclyAccessible}" \
    --output table

echo ""
echo -e "\e[36mNext step: Run 06-launch-ec2.ps1\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 05: Create RDS MySQL Instance
# Launches db.t3.micro MySQL 8.0 in private subnets — no public access
# =============================================================================

Write-Host "=== Project 6 — Launch RDS MySQL ===" -ForegroundColor Cyan
Write-Host ""

if (-not $RDS_SG) {
    Write-Host "ERROR: \$RDS_SG not set. Run 02-security-groups.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Engine:         MySQL 8.0"
Write-Host "  Instance class: db.t3.micro (Free Tier eligible)"
Write-Host "  Storage:        20 GiB gp2"
Write-Host "  Subnet group:   rds-subnet-group"
Write-Host "  Security group: $RDS_SG (rds-sg)"
Write-Host "  Public access:  No"
Write-Host "  Initial DB:     appdb"
Write-Host ""

Write-Host "Launching RDS instance (this command returns immediately)..." -ForegroundColor Yellow

aws rds create-db-instance `
    --db-instance-identifier myapp-database `
    --db-instance-class db.t3.micro `
    --engine mysql `
    --engine-version 8.0 `
    --master-username admin `
    --master-user-password "MyDB#Secure2024!" `
    --db-name appdb `
    --vpc-security-group-ids $RDS_SG `
    --db-subnet-group-name rds-subnet-group `
    --allocated-storage 20 `
    --storage-type gp2 `
    --no-multi-az `
    --no-publicly-accessible `
    --backup-retention-period 1 `
    --no-deletion-protection `
    --tags Key=Name,Value=myapp-database | Out-Null

Write-Host "RDS creation initiated." -ForegroundColor Green
Write-Host ""
Write-Host "Waiting for RDS to become available (typically 5-10 minutes)..." -ForegroundColor Yellow
Write-Host "You can monitor progress in: RDS console -> Databases -> myapp-database"
Write-Host ""

# Block until available — this is the most reliable approach
aws rds wait db-instance-available `
    --db-instance-identifier myapp-database

Write-Host "RDS is available!" -ForegroundColor Green
Write-Host ""

# Fetch and display the endpoint
$RDS_ENDPOINT = aws rds describe-db-instances `
    --db-instance-identifier myapp-database `
    --query "DBInstances[0].Endpoint.Address" `
    --output text

$RDS_PORT = aws rds describe-db-instances `
    --db-instance-identifier myapp-database `
    --query "DBInstances[0].Endpoint.Port" `
    --output text

Write-Host "=== RDS MySQL Ready ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Endpoint: $RDS_ENDPOINT"
Write-Host "  Port:     $RDS_PORT"
Write-Host ""
Write-Host "IMPORTANT: Copy the endpoint above. You will need it in Part 7."
Write-Host ""

# Describe the instance
aws rds describe-db-instances `
    --db-instance-identifier myapp-database `
    --query "DBInstances[0].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Engine:Engine,Status:DBInstanceStatus,Endpoint:Endpoint.Address,Storage:AllocatedStorage,Public:PubliclyAccessible}" `
    --output table

Write-Host ""
Write-Host "Next step: Run 06-launch-ec2.ps1" -ForegroundColor Cyan
```

## PART 6 — LAUNCH EC2 APP SERVER

### 🖥️ Method 1: AWS Management Console

**Step 7 — Launch EC2 instance**
- EC2 → Launch instances
- Name: app-server
- AMI: Amazon Linux 2023 (Free tier)
- Instance type: t2.micro
- Key pair: aws-ec2-keypair
- VPC: my-custom-vpc
- Subnet: public-subnet-a
- Auto-assign public IP: Enable
- Security group: ec2-app-sg
- Advanced details → User data: (Install httpd and mysql)
- Click Launch instance

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 — Script 06: Launch EC2 App Server + IAM Role
# Launches t2.micro in public subnet with MySQL client and Apache installed
# Also creates and attaches IAM role for Secrets Manager access
# =============================================================================

echo -e "\e[36m=== Project 6 — Launch EC2 App Server ===\e[0m"
echo ""

if (-not $EC2_SG -or -not $PUB_SUBNET_A) {
echo -e "\e[31mERROR: EC2_SG or PUB_SUBNET_A not set. Run earlier scripts first.\e[0m"
    exit 1
}

# ── FIND LATEST AMAZON LINUX 2023 AMI ─────────────────────────────────────────
echo -e "\e[33m[1/4] Finding latest Amazon Linux 2023 AMI...\e[0m"

AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
    --query "sort_by(Images,&CreationDate)[-1].ImageId" \
    --output text)

echo -e "\e[32mAMI: $AMI_ID\e[0m"

# ── USER DATA SCRIPT ──────────────────────────────────────────────────────────
echo -e "\e[33m[2/4] Preparing user data...\e[0m"

USER_DATA_CONTENT=@"
#!/bin/bash
yum update -y
yum install -y mysql httpd
systemctl start httpd
systemctl enable httpd

echo '<html>
<head><title>App Server - Project 6</title></head>
<body style="font-family:Arial,sans-serif;text-align:center;padding:60px;background:#f0f2f5">
  <h1 style="color:#232f3e">App Server Running</h1>
  <p style="color:#555;font-size:18px">EC2 + RDS Two-Tier Architecture — Project 6</p>
  <p style="color:#28a745;font-size:16px">MySQL client installed and ready to connect to RDS</p>
  <hr style="max-width:400px;margin:30px auto">
  <p style="color:#888;font-size:14px">Amazon Linux 2023 · t2.micro · public-subnet-a</p>
</body>
</html>' > /var/www/html/index.html
"@

$USER_DATA_CONTENT | Out-File -FilePath "userdata-app.sh" -Encoding ascii
echo -e "\e[32mUser data script written to userdata-app.sh\e[0m"

# ── LAUNCH EC2 INSTANCE ───────────────────────────────────────────────────────
echo -e "\e[33m[3/4] Launching EC2 instance...\e[0m"

APP_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name aws-ec2-keypair \
    --subnet-id $PUB_SUBNET_A \
    --security-group-ids $EC2_SG \
    --associate-public-ip-address \
    --user-data file://userdata-app.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=app-server}]" \
    --query "Instances[0].InstanceId" \
    --output text)

echo -e "\e[32mInstance launched: $APP_INSTANCE_ID\e[0m"
echo -e "\e[33mWaiting for instance to pass status checks (2-3 minutes)...\e[0m"

aws ec2 wait instance-status-ok --instance-ids $APP_INSTANCE_ID
echo -e "\e[32mInstance ready.\e[0m"

APP_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $APP_INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

echo -e "\e[32mPublic IP: $APP_PUBLIC_IP\e[0m"

# ── IAM ROLE FOR SECRETS MANAGER ─────────────────────────────────────────────
echo -e "\e[33m[4/4] Creating IAM role for Secrets Manager access...\e[0m"

ENHANCED_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:rds/myapp/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:*",
        "ec2messages:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters"
      ],
      "Resource": "*"
    }
  ]
}'

# Create IAM role
aws iam create-role \
    --role-name ec2-app-role \
    --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{
      "Effect":"Allow",
      "Principal":{"Service":"ec2.amazonaws.com"},
      "Action":"sts:AssumeRole"
    }]
  }' | Out-Null

# Attach AWS managed SSM policy
aws iam attach-role-policy \
    --role-name ec2-app-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# Add scoped Secrets Manager policy
aws iam put-role-policy \
    --role-name ec2-app-role \
    --policy-name secrets-manager-access \
    --policy-document $ENHANCED_POLICY

# Create instance profile and attach role
aws iam create-instance-profile \
    --instance-profile-name ec2-app-profile | Out-Null

aws iam add-role-to-instance-profile \
    --instance-profile-name ec2-app-profile \
    --role-name ec2-app-role

# Wait briefly for IAM to propagate
sleep 10

# Associate instance profile with EC2
aws ec2 associate-iam-instance-profile \
    --instance-id $APP_INSTANCE_ID \
    --iam-instance-profile Name=ec2-app-profile | Out-Null

echo -e "\e[32mIAM role created and attached.\e[0m"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== EC2 App Server Complete ===\e[0m"
echo ""
echo "  APP_INSTANCE_ID = $APP_INSTANCE_ID"
echo "  APP_PUBLIC_IP   = $APP_PUBLIC_IP"
echo ""
echo "Test the web server: http://$APP_PUBLIC_IP"
echo ""
echo "SSH command:"
echo "  ssh -i aws-ec2-keypair.pem ec2-user@$APP_PUBLIC_IP"
echo ""
echo "Wait 2 minutes before testing Secrets Manager from EC2"
echo "(IAM credentials need time to propagate to instance metadata)"
echo ""
echo -e "\e[36mNext step: SSH into the instance, then use 07-rds-connect.sql\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 06: Launch EC2 App Server + IAM Role
# Launches t2.micro in public subnet with MySQL client and Apache installed
# Also creates and attaches IAM role for Secrets Manager access
# =============================================================================

Write-Host "=== Project 6 — Launch EC2 App Server ===" -ForegroundColor Cyan
Write-Host ""

if (-not $EC2_SG -or -not $PUB_SUBNET_A) {
    Write-Host "ERROR: EC2_SG or PUB_SUBNET_A not set. Run earlier scripts first." -ForegroundColor Red
    exit 1
}

# ── FIND LATEST AMAZON LINUX 2023 AMI ─────────────────────────────────────────
Write-Host "[1/4] Finding latest Amazon Linux 2023 AMI..." -ForegroundColor Yellow

$AMI_ID = aws ec2 describe-images `
    --owners amazon `
    --filters "Name=name,Values=al2023-ami-*-x86_64" `
    "Name=state,Values=available" `
    --query "sort_by(Images,&CreationDate)[-1].ImageId" `
    --output text

Write-Host "AMI: $AMI_ID" -ForegroundColor Green

# ── USER DATA SCRIPT ──────────────────────────────────────────────────────────
Write-Host "[2/4] Preparing user data..." -ForegroundColor Yellow

$USER_DATA_CONTENT = @"
#!/bin/bash
yum update -y
yum install -y mysql httpd
systemctl start httpd
systemctl enable httpd

echo '<html>
<head><title>App Server - Project 6</title></head>
<body style="font-family:Arial,sans-serif;text-align:center;padding:60px;background:#f0f2f5">
  <h1 style="color:#232f3e">App Server Running</h1>
  <p style="color:#555;font-size:18px">EC2 + RDS Two-Tier Architecture — Project 6</p>
  <p style="color:#28a745;font-size:16px">MySQL client installed and ready to connect to RDS</p>
  <hr style="max-width:400px;margin:30px auto">
  <p style="color:#888;font-size:14px">Amazon Linux 2023 · t2.micro · public-subnet-a</p>
</body>
</html>' > /var/www/html/index.html
"@

$USER_DATA_CONTENT | Out-File -FilePath "userdata-app.sh" -Encoding ascii
Write-Host "User data script written to userdata-app.sh" -ForegroundColor Green

# ── LAUNCH EC2 INSTANCE ───────────────────────────────────────────────────────
Write-Host "[3/4] Launching EC2 instance..." -ForegroundColor Yellow

$APP_INSTANCE_ID = aws ec2 run-instances `
    --image-id $AMI_ID `
    --instance-type t2.micro `
    --key-name aws-ec2-keypair `
    --subnet-id $PUB_SUBNET_A `
    --security-group-ids $EC2_SG `
    --associate-public-ip-address `
    --user-data file://userdata-app.sh `
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=app-server}]" `
    --query "Instances[0].InstanceId" `
    --output text

Write-Host "Instance launched: $APP_INSTANCE_ID" -ForegroundColor Green
Write-Host "Waiting for instance to pass status checks (2-3 minutes)..." -ForegroundColor Yellow

aws ec2 wait instance-status-ok --instance-ids $APP_INSTANCE_ID
Write-Host "Instance ready." -ForegroundColor Green

$APP_PUBLIC_IP = aws ec2 describe-instances `
    --instance-ids $APP_INSTANCE_ID `
    --query "Reservations[0].Instances[0].PublicIpAddress" `
    --output text

Write-Host "Public IP: $APP_PUBLIC_IP" -ForegroundColor Green

# ── IAM ROLE FOR SECRETS MANAGER ─────────────────────────────────────────────
Write-Host "[4/4] Creating IAM role for Secrets Manager access..." -ForegroundColor Yellow

$ENHANCED_POLICY = '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:rds/myapp/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:*",
        "ec2messages:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters"
      ],
      "Resource": "*"
    }
  ]
}'

# Create IAM role
aws iam create-role `
    --role-name ec2-app-role `
    --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{
      "Effect":"Allow",
      "Principal":{"Service":"ec2.amazonaws.com"},
      "Action":"sts:AssumeRole"
    }]
  }' | Out-Null

# Attach AWS managed SSM policy
aws iam attach-role-policy `
    --role-name ec2-app-role `
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# Add scoped Secrets Manager policy
aws iam put-role-policy `
    --role-name ec2-app-role `
    --policy-name secrets-manager-access `
    --policy-document $ENHANCED_POLICY

# Create instance profile and attach role
aws iam create-instance-profile `
    --instance-profile-name ec2-app-profile | Out-Null

aws iam add-role-to-instance-profile `
    --instance-profile-name ec2-app-profile `
    --role-name ec2-app-role

# Wait briefly for IAM to propagate
Start-Sleep -Seconds 10

# Associate instance profile with EC2
aws ec2 associate-iam-instance-profile `
    --instance-id $APP_INSTANCE_ID `
    --iam-instance-profile Name=ec2-app-profile | Out-Null

Write-Host "IAM role created and attached." -ForegroundColor Green

# ── SUMMARY ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== EC2 App Server Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  APP_INSTANCE_ID = $APP_INSTANCE_ID"
Write-Host "  APP_PUBLIC_IP   = $APP_PUBLIC_IP"
Write-Host ""
Write-Host "Test the web server: http://$APP_PUBLIC_IP"
Write-Host ""
Write-Host "SSH command:"
Write-Host "  ssh -i aws-ec2-keypair.pem ec2-user@$APP_PUBLIC_IP"
Write-Host ""
Write-Host "Wait 2 minutes before testing Secrets Manager from EC2"
Write-Host "(IAM credentials need time to propagate to instance metadata)"
Write-Host ""
Write-Host "Next step: SSH into the instance, then use 07-rds-connect.sql" -ForegroundColor Cyan
```

## PART 7 — CLOUDWATCH MONITORING

### 🖥️ Method 1: AWS Management Console

In the console:
- RDS → Databases → click myapp-database
- Monitoring tab → see CPU, connections, storage, IOPS graphs

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 — Script 08: CloudWatch Monitoring
# Queries RDS metrics for the last hour — CPU, connections, storage
# =============================================================================

echo -e "\e[36m=== Project 6 — CloudWatch RDS Monitoring ===\e[0m"
echo ""

START_TIME=(Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")
END_TIME=(Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
DB_ID="myapp-database"

echo "Query window: $START_TIME → $END_TIME"
echo "DB Instance:  $DB_ID"
echo ""

# ── CPU UTILIZATION ───────────────────────────────────────────────────────────
echo -e "\e[33m--- CPU Utilization (%) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name CPUUtilization \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,CPU_Percent:Average}" \
    --output table

# ── DATABASE CONNECTIONS ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Database Connections (count) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Connections:Average}" \
    --output table

# ── FREE STORAGE SPACE ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Free Storage Space (bytes) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name FreeStorageSpace \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Free_Bytes:Average}" \
    --output table

# ── FREEABLE MEMORY ───────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Freeable Memory (bytes) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name FreeableMemory \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Free_Bytes:Average}" \
    --output table

# ── READ IOPS ─────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Read IOPS ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name ReadIOPS \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Read_IOPS:Average}" \
    --output table

# ── WRITE IOPS ────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Write IOPS ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name WriteIOPS \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Write_IOPS:Average}" \
    --output table

# ── CONSOLE SHORTCUT ──────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Monitoring Complete ===\e[0m"
echo ""
echo "Console path for visual graphs:"
echo "  RDS -> Databases -> myapp-database -> Monitoring tab"
echo ""
echo "Note: If datapoints are empty, the instance has been idle."
echo "Run a few queries via MySQL client to generate metrics."
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 08: CloudWatch Monitoring
# Queries RDS metrics for the last hour — CPU, connections, storage
# =============================================================================

Write-Host "=== Project 6 — CloudWatch RDS Monitoring ===" -ForegroundColor Cyan
Write-Host ""

$START_TIME = (Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")
$END_TIME = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
$DB_ID = "myapp-database"

Write-Host "Query window: $START_TIME → $END_TIME"
Write-Host "DB Instance:  $DB_ID"
Write-Host ""

# ── CPU UTILIZATION ───────────────────────────────────────────────────────────
Write-Host "--- CPU Utilization (%) ---" -ForegroundColor Yellow
aws cloudwatch get-metric-statistics `
    --namespace AWS/RDS `
    --metric-name CPUUtilization `
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID `
    --start-time $START_TIME `
    --end-time $END_TIME `
    --period 300 `
    --statistics Average `
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,CPU_Percent:Average}" `
    --output table

# ── DATABASE CONNECTIONS ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Database Connections (count) ---" -ForegroundColor Yellow
aws cloudwatch get-metric-statistics `
    --namespace AWS/RDS `
    --metric-name DatabaseConnections `
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID `
    --start-time $START_TIME `
    --end-time $END_TIME `
    --period 300 `
    --statistics Average `
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Connections:Average}" `
    --output table

# ── FREE STORAGE SPACE ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Free Storage Space (bytes) ---" -ForegroundColor Yellow
aws cloudwatch get-metric-statistics `
    --namespace AWS/RDS `
    --metric-name FreeStorageSpace `
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID `
    --start-time $START_TIME `
    --end-time $END_TIME `
    --period 300 `
    --statistics Average `
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Free_Bytes:Average}" `
    --output table

# ── FREEABLE MEMORY ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Freeable Memory (bytes) ---" -ForegroundColor Yellow
aws cloudwatch get-metric-statistics `
    --namespace AWS/RDS `
    --metric-name FreeableMemory `
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID `
    --start-time $START_TIME `
    --end-time $END_TIME `
    --period 300 `
    --statistics Average `
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Free_Bytes:Average}" `
    --output table

# ── READ IOPS ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Read IOPS ---" -ForegroundColor Yellow
aws cloudwatch get-metric-statistics `
    --namespace AWS/RDS `
    --metric-name ReadIOPS `
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID `
    --start-time $START_TIME `
    --end-time $END_TIME `
    --period 300 `
    --statistics Average `
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Read_IOPS:Average}" `
    --output table

# ── WRITE IOPS ────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Write IOPS ---" -ForegroundColor Yellow
aws cloudwatch get-metric-statistics `
    --namespace AWS/RDS `
    --metric-name WriteIOPS `
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID `
    --start-time $START_TIME `
    --end-time $END_TIME `
    --period 300 `
    --statistics Average `
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Write_IOPS:Average}" `
    --output table

# ── CONSOLE SHORTCUT ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Monitoring Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Console path for visual graphs:"
Write-Host "  RDS -> Databases -> myapp-database -> Monitoring tab"
Write-Host ""
Write-Host "Note: If datapoints are empty, the instance has been idle."
Write-Host "Run a few queries via MySQL client to generate metrics."
```

## PART 8 — RDS OPERATIONS

### 🖥️ Method 1: AWS Management Console

This section focuses on CLI operations for RDS, such as describing instances, creating snapshots, and starting/stopping the database.

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 — Script 09: RDS Operations
# Covers describe, snapshot, stop, start, and modify operations
# =============================================================================

echo -e "\e[36m=== Project 6 — RDS Operations ===\e[0m"
echo ""

DB_ID="myapp-database"

# ── DESCRIBE INSTANCE ─────────────────────────────────────────────────────────
echo -e "\e[33m--- Instance Details ---\e[0m"
aws rds describe-db-instances \
    --db-instance-identifier $DB_ID \
    --query "DBInstances[0].{
    ID:DBInstanceIdentifier,
    Class:DBInstanceClass,
    Engine:Engine,
    EngineVersion:EngineVersion,
    Status:DBInstanceStatus,
    Endpoint:Endpoint.Address,
    Port:Endpoint.Port,
    Storage_GiB:AllocatedStorage,
    StorageType:StorageType,
    PublicAccess:PubliclyAccessible,
    MultiAZ:MultiAZ,
    BackupRetentionDays:BackupRetentionPeriod,
    Encrypted:StorageEncrypted,
    AZ:AvailabilityZone
  }" \
    --output table

# ── CREATE MANUAL SNAPSHOT ────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Creating Manual Snapshot ---\e[0m"

$SNAPSHOT_ID = "myapp-manual-snapshot-$(date +"%T")"
echo "Snapshot ID: $SNAPSHOT_ID"

aws rds create-db-snapshot \
    --db-instance-identifier $DB_ID \
    --db-snapshot-identifier $SNAPSHOT_ID | Out-Null

echo -e "\e[32mSnapshot creation initiated.\e[0m"
echo "(Snapshot takes a few minutes — check status in RDS console)"

# ── LIST ALL SNAPSHOTS ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- All Snapshots for $DB_ID ---\e[0m"
aws rds describe-db-snapshots \
    --db-instance-identifier $DB_ID \
    --query "DBSnapshots[*].{ID:DBSnapshotIdentifier,Status:Status,Type:SnapshotType,Created:SnapshotCreateTime,Size_GiB:AllocatedStorage}" \
    --output table

# ── MODIFY BACKUP RETENTION ───────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Modifying Backup Retention to 3 days ---\e[0m"

aws rds modify-db-instance \
    --db-instance-identifier $DB_ID \
    --backup-retention-period 3 \
    --apply-immediately | Out-Null

echo -e "\e[32mBackup retention updated to 3 days.\e[0m"

# ── SHOW EVENTS ───────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Recent RDS Events ---\e[0m"
aws rds describe-events \
    --source-identifier $DB_ID \
    --source-type db-instance \
    --duration 60 \
    --query "Events[*].{Time:Date,Message:Message}" \
    --output table

# ── STOP INSTANCE (OPTIONAL / COST SAVING) ───────────────────────────────────
echo ""
echo -e "\e[33m--- Stop / Start Commands (for reference) ---\e[0m"
echo ""
echo "To STOP RDS (saves cost — max 7 days, then auto-starts):"
echo "  aws rds stop-db-instance --db-instance-identifier $DB_ID"
echo ""
echo "To START RDS after stopping:"
echo "  aws rds start-db-instance --db-instance-identifier $DB_ID"
echo ""
echo "NOTE: Do not stop if you plan to keep using it today."
echo "      For permanent removal, use the cleanup script instead."
echo ""
echo -e "\e[36m=== RDS Operations Complete ===\e[0m"
echo ""
echo -e "\e[36mNext step: When done with the project, run 10-cleanup.ps1\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 09: RDS Operations
# Covers describe, snapshot, stop, start, and modify operations
# =============================================================================

Write-Host "=== Project 6 — RDS Operations ===" -ForegroundColor Cyan
Write-Host ""

$DB_ID = "myapp-database"

# ── DESCRIBE INSTANCE ─────────────────────────────────────────────────────────
Write-Host "--- Instance Details ---" -ForegroundColor Yellow
aws rds describe-db-instances `
    --db-instance-identifier $DB_ID `
    --query "DBInstances[0].{
    ID:DBInstanceIdentifier,
    Class:DBInstanceClass,
    Engine:Engine,
    EngineVersion:EngineVersion,
    Status:DBInstanceStatus,
    Endpoint:Endpoint.Address,
    Port:Endpoint.Port,
    Storage_GiB:AllocatedStorage,
    StorageType:StorageType,
    PublicAccess:PubliclyAccessible,
    MultiAZ:MultiAZ,
    BackupRetentionDays:BackupRetentionPeriod,
    Encrypted:StorageEncrypted,
    AZ:AvailabilityZone
  }" `
    --output table

# ── CREATE MANUAL SNAPSHOT ────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Creating Manual Snapshot ---" -ForegroundColor Yellow

$SNAPSHOT_ID = "myapp-manual-snapshot-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Write-Host "Snapshot ID: $SNAPSHOT_ID"

aws rds create-db-snapshot `
    --db-instance-identifier $DB_ID `
    --db-snapshot-identifier $SNAPSHOT_ID | Out-Null

Write-Host "Snapshot creation initiated." -ForegroundColor Green
Write-Host "(Snapshot takes a few minutes — check status in RDS console)"

# ── LIST ALL SNAPSHOTS ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- All Snapshots for $DB_ID ---" -ForegroundColor Yellow
aws rds describe-db-snapshots `
    --db-instance-identifier $DB_ID `
    --query "DBSnapshots[*].{ID:DBSnapshotIdentifier,Status:Status,Type:SnapshotType,Created:SnapshotCreateTime,Size_GiB:AllocatedStorage}" `
    --output table

# ── MODIFY BACKUP RETENTION ───────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Modifying Backup Retention to 3 days ---" -ForegroundColor Yellow

aws rds modify-db-instance `
    --db-instance-identifier $DB_ID `
    --backup-retention-period 3 `
    --apply-immediately | Out-Null

Write-Host "Backup retention updated to 3 days." -ForegroundColor Green

# ── SHOW EVENTS ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Recent RDS Events ---" -ForegroundColor Yellow
aws rds describe-events `
    --source-identifier $DB_ID `
    --source-type db-instance `
    --duration 60 `
    --query "Events[*].{Time:Date,Message:Message}" `
    --output table

# ── STOP INSTANCE (OPTIONAL / COST SAVING) ───────────────────────────────────
Write-Host ""
Write-Host "--- Stop / Start Commands (for reference) ---" -ForegroundColor Yellow
Write-Host ""
Write-Host "To STOP RDS (saves cost — max 7 days, then auto-starts):"
Write-Host "  aws rds stop-db-instance --db-instance-identifier $DB_ID"
Write-Host ""
Write-Host "To START RDS after stopping:"
Write-Host "  aws rds start-db-instance --db-instance-identifier $DB_ID"
Write-Host ""
Write-Host "NOTE: Do not stop if you plan to keep using it today."
Write-Host "      For permanent removal, use the cleanup script instead."
Write-Host ""
Write-Host "=== RDS Operations Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: When done with the project, run 10-cleanup.ps1" -ForegroundColor Cyan
```

## PART 9 — CLEANUP

### 🖥️ Method 1: AWS Management Console

Follow the cleanup order strictly to avoid DependencyViolation errors.
1. Terminate EC2 instance
2. Delete RDS instance (skip final snapshot)
3. Delete RDS subnet group
4. Delete Secrets Manager secret
5. Delete Security Groups
6. Delete Subnets
7. Delete Route Tables
8. Detach and delete IGW
9. Delete VPC

### 🐧 Method 2: AWS CLI (Bash)

```bash
#!/bin/bash

# =============================================================================
# Project 6 — Script 10: Full Cleanup
# Deletes all resources in the correct dependency order
# =============================================================================

echo -e "\e[36m=== Project 6 — Full Cleanup ===\e[0m"
echo ""
echo -e "\e[31mWARNING: This will permanently delete all Project 6 resources.\e[0m"
echo -e "\e[31mRDS data, EC2 instance, VPC, secrets — all gone.\e[0m"
echo ""

# Re-fetch all IDs in case variables were lost between sessions
echo -e "\e[33mRe-fetching resource IDs...\e[0m"

VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=my-custom-vpc" \
    --query "Vpcs[0].VpcId" --output text)

if ($VPC_ID -eq "None" -or -not $VPC_ID) {
echo -e "\e[33mVPC not found — may already be deleted.\e[0m"
    exit 0
}

APP_INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=app-server" \
    "Name=instance-state-name,Values=running,stopped,pending" \
    --query "Reservations[0].Instances[0].InstanceId" --output text)

EC2_SG=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=ec2-app-sg" "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[0].GroupId" --output text)

RDS_SG=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=rds-sg" "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[0].GroupId" --output text)

IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=my-vpc-igw" \
    --query "InternetGateways[0].InternetGatewayId" --output text)

PUB_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=public-route-table" \
    --query "RouteTables[0].RouteTableId" --output text)

PRI_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=private-route-table" \
    --query "RouteTables[0].RouteTableId" --output text)

SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "Subnets[*].SubnetId" --output text)

echo -e "\e[32mIDs fetched. Proceeding with cleanup.\e[0m"
echo ""

# ── STEP 1: TERMINATE EC2 ─────────────────────────────────────────────────────
if ($APP_INSTANCE_ID -and $APP_INSTANCE_ID -ne "None") {
echo -e "\e[33m[1/10] Terminating EC2 instance $APP_INSTANCE_ID...\e[0m"
    aws ec2 terminate-instances --instance-ids $APP_INSTANCE_ID | Out-Null
    aws ec2 wait instance-terminated --instance-ids $APP_INSTANCE_ID
echo -e "\e[32mEC2 terminated.\e[0m"
}
else {
echo -e "\e[90m[1/10] EC2 instance not found — skipping.\e[0m"
}

# ── STEP 2: DELETE RDS ────────────────────────────────────────────────────────
echo -e "\e[33m[2/10] Deleting RDS instance (no final snapshot)...\e[0m"

RDS_STATUS=$(aws rds describe-db-instances \
    --db-instance-identifier myapp-database \
    --query "DBInstances[0].DBInstanceStatus" --output text 2>&1)

if ($LASTEXITCODE -eq 0 -and $RDS_STATUS -ne "deleting") {
    aws rds delete-db-instance \
        --db-instance-identifier myapp-database \
        --skip-final-snapshot \
        --delete-automated-backups | Out-Null

echo -e "\e[33mRDS deletion initiated. Waiting (3-5 minutes)...\e[0m"
    aws rds wait db-instance-deleted --db-instance-identifier myapp-database
echo -e "\e[32mRDS deleted.\e[0m"
}
else {
echo -e "\e[90m[2/10] RDS not found or already deleting — skipping.\e[0m"
}

# ── STEP 3: DELETE RDS SUBNET GROUP ──────────────────────────────────────────
echo -e "\e[33m[3/10] Deleting RDS subnet group...\e[0m"
aws rds delete-db-subnet-group --db-subnet-group-name rds-subnet-group 2>&1 | Out-Null
echo -e "\e[32mSubnet group deleted.\e[0m"

# ── STEP 4: DELETE SECRET ─────────────────────────────────────────────────────
echo -e "\e[33m[4/10] Deleting Secrets Manager secret...\e[0m"
aws secretsmanager delete-secret \
    --secret-id "rds/myapp/credentials" \
    --force-delete-without-recovery 2>&1 | Out-Null
echo -e "\e[32mSecret deleted.\e[0m"

# ── STEP 5: DELETE SECURITY GROUPS ───────────────────────────────────────────
echo -e "\e[33m[5/10] Deleting security groups...\e[0m"
if ($RDS_SG -and $RDS_SG -ne "None") {
    aws ec2 delete-security-group --group-id $RDS_SG 2>&1 | Out-Null
}
if ($EC2_SG -and $EC2_SG -ne "None") {
    aws ec2 delete-security-group --group-id $EC2_SG 2>&1 | Out-Null
}
echo -e "\e[32mSecurity groups deleted.\e[0m"

# ── STEP 6: DELETE IAM ROLE AND PROFILE ──────────────────────────────────────
echo -e "\e[33m[6/10] Deleting IAM role and instance profile...\e[0m"
aws iam remove-role-from-instance-profile \
    --instance-profile-name ec2-app-profile --role-name ec2-app-role 2>&1 | Out-Null
aws iam detach-role-policy \
    --role-name ec2-app-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore 2>&1 | Out-Null
aws iam delete-role-policy \
    --role-name ec2-app-role \
    --policy-name secrets-manager-access 2>&1 | Out-Null
aws iam delete-instance-profile \
    --instance-profile-name ec2-app-profile 2>&1 | Out-Null
aws iam delete-role \
    --role-name ec2-app-role 2>&1 | Out-Null
echo -e "\e[32mIAM role deleted.\e[0m"

# ── STEP 7: DELETE SUBNETS ────────────────────────────────────────────────────
echo -e "\e[33m[7/10] Deleting subnets...\e[0m"
foreach ($SUBNET_ID in $SUBNETS.Split()) {
    if ($SUBNET_ID -and $SUBNET_ID -ne "None") {
        aws ec2 delete-subnet --subnet-id $SUBNET_ID 2>&1 | Out-Null
    }
}
echo -e "\e[32mSubnets deleted.\e[0m"

# ── STEP 8: DELETE ROUTE TABLES ───────────────────────────────────────────────
echo -e "\e[33m[8/10] Deleting route tables...\e[0m"
if ($PUB_RT_ID -and $PUB_RT_ID -ne "None") {
    aws ec2 delete-route-table --route-table-id $PUB_RT_ID 2>&1 | Out-Null
}
if ($PRI_RT_ID -and $PRI_RT_ID -ne "None") {
    aws ec2 delete-route-table --route-table-id $PRI_RT_ID 2>&1 | Out-Null
}
echo -e "\e[32mRoute tables deleted.\e[0m"

# ── STEP 9: DETACH AND DELETE IGW ─────────────────────────────────────────────
echo -e "\e[33m[9/10] Removing Internet Gateway...\e[0m"
if ($IGW_ID -and $IGW_ID -ne "None") {
    aws ec2 detach-internet-gateway \
        --internet-gateway-id $IGW_ID --vpc-id $VPC_ID 2>&1 | Out-Null
    aws ec2 delete-internet-gateway \
        --internet-gateway-id $IGW_ID 2>&1 | Out-Null
}
echo -e "\e[32mIGW deleted.\e[0m"

# ── STEP 10: DELETE VPC ───────────────────────────────────────────────────────
echo -e "\e[33m[10/10] Deleting VPC...\e[0m"
aws ec2 delete-vpc --vpc-id $VPC_ID 2>&1 | Out-Null
echo -e "\e[32mVPC deleted.\e[0m"

# ── FINAL VERIFICATION ────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Cleanup Verification ===\e[0m"
echo ""

RDS_CHECK=$(aws rds describe-db-instances \
    --db-instance-identifier myapp-database 2>&1)
if ($RDS_CHECK -match "DBInstanceNotFound") {
echo -e "\e[32mRDS:    DELETED\e[0m"
}
else {
echo -e "\e[31mRDS:    Still present — check manually\e[0m"
}

VPC_CHECK=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID 2>&1)
if ($VPC_CHECK -match "InvalidVpcID") {
echo -e "\e[32mVPC:    DELETED\e[0m"
}
else {
echo -e "\e[31mVPC:    Still present — check manually\e[0m"
}

echo ""
echo -e "\e[36m=== Project 6 Cleanup Complete ===\e[0m"
echo ""
echo "Check AWS Billing -> Cost Explorer in 24 hours to confirm $0 charges."
```

### 🪟 Method 3: AWS CLI (PowerShell)

```powershell
# =============================================================================
# Project 6 — Script 10: Full Cleanup
# Deletes all resources in the correct dependency order
# =============================================================================

Write-Host "=== Project 6 — Full Cleanup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "WARNING: This will permanently delete all Project 6 resources." -ForegroundColor Red
Write-Host "RDS data, EC2 instance, VPC, secrets — all gone." -ForegroundColor Red
Write-Host ""

# Re-fetch all IDs in case variables were lost between sessions
Write-Host "Re-fetching resource IDs..." -ForegroundColor Yellow

$VPC_ID = aws ec2 describe-vpcs `
    --filters "Name=tag:Name,Values=my-custom-vpc" `
    --query "Vpcs[0].VpcId" --output text

if ($VPC_ID -eq "None" -or -not $VPC_ID) {
    Write-Host "VPC not found — may already be deleted." -ForegroundColor Yellow
    exit 0
}

$APP_INSTANCE_ID = aws ec2 describe-instances `
    --filters "Name=tag:Name,Values=app-server" `
    "Name=instance-state-name,Values=running,stopped,pending" `
    --query "Reservations[0].Instances[0].InstanceId" --output text

$EC2_SG = aws ec2 describe-security-groups `
    --filters "Name=group-name,Values=ec2-app-sg" "Name=vpc-id,Values=$VPC_ID" `
    --query "SecurityGroups[0].GroupId" --output text

$RDS_SG = aws ec2 describe-security-groups `
    --filters "Name=group-name,Values=rds-sg" "Name=vpc-id,Values=$VPC_ID" `
    --query "SecurityGroups[0].GroupId" --output text

$IGW_ID = aws ec2 describe-internet-gateways `
    --filters "Name=tag:Name,Values=my-vpc-igw" `
    --query "InternetGateways[0].InternetGatewayId" --output text

$PUB_RT_ID = aws ec2 describe-route-tables `
    --filters "Name=tag:Name,Values=public-route-table" `
    --query "RouteTables[0].RouteTableId" --output text

$PRI_RT_ID = aws ec2 describe-route-tables `
    --filters "Name=tag:Name,Values=private-route-table" `
    --query "RouteTables[0].RouteTableId" --output text

$SUBNETS = aws ec2 describe-subnets `
    --filters "Name=vpc-id,Values=$VPC_ID" `
    --query "Subnets[*].SubnetId" --output text

Write-Host "IDs fetched. Proceeding with cleanup." -ForegroundColor Green
Write-Host ""

# ── STEP 1: TERMINATE EC2 ─────────────────────────────────────────────────────
if ($APP_INSTANCE_ID -and $APP_INSTANCE_ID -ne "None") {
    Write-Host "[1/10] Terminating EC2 instance $APP_INSTANCE_ID..." -ForegroundColor Yellow
    aws ec2 terminate-instances --instance-ids $APP_INSTANCE_ID | Out-Null
    aws ec2 wait instance-terminated --instance-ids $APP_INSTANCE_ID
    Write-Host "EC2 terminated." -ForegroundColor Green
}
else {
    Write-Host "[1/10] EC2 instance not found — skipping." -ForegroundColor Gray
}

# ── STEP 2: DELETE RDS ────────────────────────────────────────────────────────
Write-Host "[2/10] Deleting RDS instance (no final snapshot)..." -ForegroundColor Yellow

$RDS_STATUS = aws rds describe-db-instances `
    --db-instance-identifier myapp-database `
    --query "DBInstances[0].DBInstanceStatus" --output text 2>&1

if ($LASTEXITCODE -eq 0 -and $RDS_STATUS -ne "deleting") {
    aws rds delete-db-instance `
        --db-instance-identifier myapp-database `
        --skip-final-snapshot `
        --delete-automated-backups | Out-Null

    Write-Host "RDS deletion initiated. Waiting (3-5 minutes)..." -ForegroundColor Yellow
    aws rds wait db-instance-deleted --db-instance-identifier myapp-database
    Write-Host "RDS deleted." -ForegroundColor Green
}
else {
    Write-Host "[2/10] RDS not found or already deleting — skipping." -ForegroundColor Gray
}

# ── STEP 3: DELETE RDS SUBNET GROUP ──────────────────────────────────────────
Write-Host "[3/10] Deleting RDS subnet group..." -ForegroundColor Yellow
aws rds delete-db-subnet-group --db-subnet-group-name rds-subnet-group 2>&1 | Out-Null
Write-Host "Subnet group deleted." -ForegroundColor Green

# ── STEP 4: DELETE SECRET ─────────────────────────────────────────────────────
Write-Host "[4/10] Deleting Secrets Manager secret..." -ForegroundColor Yellow
aws secretsmanager delete-secret `
    --secret-id "rds/myapp/credentials" `
    --force-delete-without-recovery 2>&1 | Out-Null
Write-Host "Secret deleted." -ForegroundColor Green

# ── STEP 5: DELETE SECURITY GROUPS ───────────────────────────────────────────
Write-Host "[5/10] Deleting security groups..." -ForegroundColor Yellow
if ($RDS_SG -and $RDS_SG -ne "None") {
    aws ec2 delete-security-group --group-id $RDS_SG 2>&1 | Out-Null
}
if ($EC2_SG -and $EC2_SG -ne "None") {
    aws ec2 delete-security-group --group-id $EC2_SG 2>&1 | Out-Null
}
Write-Host "Security groups deleted." -ForegroundColor Green

# ── STEP 6: DELETE IAM ROLE AND PROFILE ──────────────────────────────────────
Write-Host "[6/10] Deleting IAM role and instance profile..." -ForegroundColor Yellow
aws iam remove-role-from-instance-profile `
    --instance-profile-name ec2-app-profile --role-name ec2-app-role 2>&1 | Out-Null
aws iam detach-role-policy `
    --role-name ec2-app-role `
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore 2>&1 | Out-Null
aws iam delete-role-policy `
    --role-name ec2-app-role `
    --policy-name secrets-manager-access 2>&1 | Out-Null
aws iam delete-instance-profile `
    --instance-profile-name ec2-app-profile 2>&1 | Out-Null
aws iam delete-role `
    --role-name ec2-app-role 2>&1 | Out-Null
Write-Host "IAM role deleted." -ForegroundColor Green

# ── STEP 7: DELETE SUBNETS ────────────────────────────────────────────────────
Write-Host "[7/10] Deleting subnets..." -ForegroundColor Yellow
foreach ($SUBNET_ID in $SUBNETS.Split()) {
    if ($SUBNET_ID -and $SUBNET_ID -ne "None") {
        aws ec2 delete-subnet --subnet-id $SUBNET_ID 2>&1 | Out-Null
    }
}
Write-Host "Subnets deleted." -ForegroundColor Green

# ── STEP 8: DELETE ROUTE TABLES ───────────────────────────────────────────────
Write-Host "[8/10] Deleting route tables..." -ForegroundColor Yellow
if ($PUB_RT_ID -and $PUB_RT_ID -ne "None") {
    aws ec2 delete-route-table --route-table-id $PUB_RT_ID 2>&1 | Out-Null
}
if ($PRI_RT_ID -and $PRI_RT_ID -ne "None") {
    aws ec2 delete-route-table --route-table-id $PRI_RT_ID 2>&1 | Out-Null
}
Write-Host "Route tables deleted." -ForegroundColor Green

# ── STEP 9: DETACH AND DELETE IGW ─────────────────────────────────────────────
Write-Host "[9/10] Removing Internet Gateway..." -ForegroundColor Yellow
if ($IGW_ID -and $IGW_ID -ne "None") {
    aws ec2 detach-internet-gateway `
        --internet-gateway-id $IGW_ID --vpc-id $VPC_ID 2>&1 | Out-Null
    aws ec2 delete-internet-gateway `
        --internet-gateway-id $IGW_ID 2>&1 | Out-Null
}
Write-Host "IGW deleted." -ForegroundColor Green

# ── STEP 10: DELETE VPC ───────────────────────────────────────────────────────
Write-Host "[10/10] Deleting VPC..." -ForegroundColor Yellow
aws ec2 delete-vpc --vpc-id $VPC_ID 2>&1 | Out-Null
Write-Host "VPC deleted." -ForegroundColor Green

# ── FINAL VERIFICATION ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Cleanup Verification ===" -ForegroundColor Cyan
Write-Host ""

$RDS_CHECK = aws rds describe-db-instances `
    --db-instance-identifier myapp-database 2>&1
if ($RDS_CHECK -match "DBInstanceNotFound") {
    Write-Host "RDS:    DELETED" -ForegroundColor Green
}
else {
    Write-Host "RDS:    Still present — check manually" -ForegroundColor Red
}

$VPC_CHECK = aws ec2 describe-vpcs --vpc-ids $VPC_ID 2>&1
if ($VPC_CHECK -match "InvalidVpcID") {
    Write-Host "VPC:    DELETED" -ForegroundColor Green
}
else {
    Write-Host "VPC:    Still present — check manually" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Project 6 Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check AWS Billing -> Cost Explorer in 24 hours to confirm $0 charges."
```
