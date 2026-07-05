# Custom VPC Deployment Guide

This guide details the complete process for provisioning a production-grade AWS network from absolute scratch. Every intermediate and advanced project from here forward runs inside this VPC.

## 🚀 PRE-FLIGHT

Before starting, confirm your terminal session identity and regional configuration.

```powershell
# Confirm CLI working
aws sts get-caller-identity

# Confirm region
aws configure get region
# Expected: us-east-1

# Check your default VPC (we are building a CUSTOM VPC alongside it)
aws ec2 describe-vpcs `
  --query "Vpcs[*].{VpcId:VpcId,CIDR:CidrBlock,Default:IsDefault}" `
  --output table
```

---

## 🏗️ PART 1 — CREATE THE VPC

### 🖥️ Method 1: AWS Management Console

**Step 1 — Open VPC Dashboard**
* Console search bar → VPC → click VPC
* You land on the VPC Dashboard

**Step 2 — Create VPC**
* Left panel → Your VPCs → Create VPC
* Select **VPC only** (not VPC and more — we build each piece manually)
* Fill in:
  * Name tag: `my-custom-vpc`
  * IPv4 CIDR block: `10.0.0.0/16`
  * IPv6 CIDR block: `No IPv6 CIDR block`
  * Tenancy: `Default`
* Click **Create VPC**
* Copy the VPC ID (looks like `vpc-0abc123def456`) — save it

**Step 3 — Enable DNS hostnames**
* Click your new VPC → Actions → Edit VPC settings
* Check ✅ Enable DNS hostnames
* Check ✅ Enable DNS resolution
* Click **Save**

> 💡 **Note:** DNS hostnames lets EC2 instances get human-readable hostnames like `ec2-54-123-45-67.compute-1.amazonaws.com` instead of just an IP. Required for many AWS services.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=my-custom-vpc}]" \
  --query "Vpc.VpcId" --output text)

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

PUB_SUBNET_A=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-a}]" \
  --query "Subnet.SubnetId" --output text)

PUB_SUBNET_B=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1b \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-b}]" \
  --query "Subnet.SubnetId" --output text)

PRI_SUBNET_A=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block 10.0.3.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-a}]" \
  --query "Subnet.SubnetId" --output text)

PRI_SUBNET_B=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID --cidr-block 10.0.4.0/24 \
  --availability-zone us-east-1b \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-b}]" \
  --query "Subnet.SubnetId" --output text)

aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_A --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET_B --map-public-ip-on-launch

echo -e "\e[32m\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Create the VPC
$VPC_ID = aws ec2 create-vpc `
  --cidr-block 10.0.0.0/16 `
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=my-custom-vpc}]" `
  --query "Vpc.VpcId" `
  --output text

Write-Host "VPC ID: $VPC_ID"

# Enable DNS hostnames
aws ec2 modify-vpc-attribute `
  --vpc-id $VPC_ID `
  --enable-dns-hostnames

# Enable DNS resolution
aws ec2 modify-vpc-attribute `
  --vpc-id $VPC_ID `
  --enable-dns-support

# Verify
aws ec2 describe-vpcs --vpc-ids $VPC_ID `
  --query "Vpcs[0].{VpcId:VpcId,CIDR:CidrBlock,DNS:EnableDnsHostnames}" `
  --output table
# Expected: your VPC ID, 10.0.0.0/16, DNS = True
```
✅ **Checkpoint 1 complete** — VPC created.

---

## 🏗️ PART 2 — CREATE SUBNETS

### 🖥️ Method 1: AWS Management Console

**Step 4 — Create Public Subnet A**
* Left panel → Subnets → Create subnet
* VPC ID: select `my-custom-vpc`
* Click **Add new subnet** and fill in:
  * Subnet name: `public-subnet-a`
  * Availability Zone: `us-east-1a`
  * IPv4 CIDR block: `10.0.1.0/24`

**Step 5 — Add remaining subnets in the same screen**
Click **Add new subnet** three more times:
* `public-subnet-b` | `us-east-1b` | `10.0.2.0/24`
* `private-subnet-a` | `us-east-1a` | `10.0.3.0/24`
* `private-subnet-b` | `us-east-1b` | `10.0.4.0/24`
* Click **Create subnet**

**Step 6 — Enable auto-assign public IP on public subnets**
For EACH public subnet (`public-subnet-a` and `public-subnet-b`):
* Select the subnet → Actions → Edit subnet settings
* Check ✅ Enable auto-assign public IPv4 address
* Click **Save**

> 💡 **Note:** This ensures any EC2 instance launched into a public subnet automatically gets a public IP — essential for internet access.

### 🐧 Method 2: AWS CLI (Bash)
*(Included in 01-create-vpc.sh above)*

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Create all four subnets
$PUB_SUBNET_A = aws ec2 create-subnet `
  --vpc-id $VPC_ID `
  --cidr-block 10.0.1.0/24 `
  --availability-zone us-east-1a `
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-a}]" `
  --query "Subnet.SubnetId" `
  --output text

$PUB_SUBNET_B = aws ec2 create-subnet `
  --vpc-id $VPC_ID `
  --cidr-block 10.0.2.0/24 `
  --availability-zone us-east-1b `
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-b}]" `
  --query "Subnet.SubnetId" `
  --output text

$PRI_SUBNET_A = aws ec2 create-subnet `
  --vpc-id $VPC_ID `
  --cidr-block 10.0.3.0/24 `
  --availability-zone us-east-1a `
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-a}]" `
  --query "Subnet.SubnetId" `
  --output text

$PRI_SUBNET_B = aws ec2 create-subnet `
  --vpc-id $VPC_ID `
  --cidr-block 10.0.4.0/24 `
  --availability-zone us-east-1b `
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-b}]" `
  --query "Subnet.SubnetId" `
  --output text

Write-Host "Public Subnet A:  $PUB_SUBNET_A"
Write-Host "Public Subnet B:  $PUB_SUBNET_B"
Write-Host "Private Subnet A: $PRI_SUBNET_A"
Write-Host "Private Subnet B: $PRI_SUBNET_B"

# Enable auto-assign public IP on public subnets
aws ec2 modify-subnet-attribute `
  --subnet-id $PUB_SUBNET_A `
  --map-public-ip-on-launch

aws ec2 modify-subnet-attribute `
  --subnet-id $PUB_SUBNET_B `
  --map-public-ip-on-launch

# Verify all four subnets
aws ec2 describe-subnets `
  --filters "Name=vpc-id,Values=$VPC_ID" `
  --query "Subnets[*].{Name:Tags[?Key=='Name'].Value|[0],SubnetId:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,AutoPublicIP:MapPublicIpOnLaunch}" `
  --output table
```
✅ **Checkpoint 2 complete** — 4 subnets created across 2 AZs.

---

## 🌍 PART 3 — CREATE AND ATTACH INTERNET GATEWAY

The IGW is what connects your VPC to the public internet. Without it — nothing in your VPC can communicate externally.

### 🖥️ Method 1: AWS Management Console

**Step 7 — Create Internet Gateway**
* Left panel → Internet Gateways → Create internet gateway
* Name tag: `my-vpc-igw`
* Click **Create internet gateway**

**Step 8 — Attach to VPC**
* You are taken to the IGW detail page
* Click Actions → Attach to VPC
* Select `my-custom-vpc` → **Attach internet gateway**
* ✅ State changes from Detached to Attached

### 🐧 Method 2: AWS CLI (Bash)
*(Included in 02-create-route-tables.sh below)*

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Create Internet Gateway
$IGW_ID = aws ec2 create-internet-gateway `
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-vpc-igw}]" `
  --query "InternetGateway.InternetGatewayId" `
  --output text

Write-Host "IGW ID: $IGW_ID"

# Attach to VPC
aws ec2 attach-internet-gateway `
  --internet-gateway-id $IGW_ID `
  --vpc-id $VPC_ID

# Verify attachment
aws ec2 describe-internet-gateways --internet-gateway-ids $IGW_ID `
  --query "InternetGateways[0].{IGW:InternetGatewayId,State:Attachments[0].State,VPC:Attachments[0].VpcId}" `
  --output table
# Expected: State = attached, VPC = your VPC ID
```
✅ **Checkpoint 3 complete** — IGW created and attached.

---

## 🛣️ PART 4 — CREATE ROUTE TABLES

Route tables tell traffic WHERE to go. Public subnets need a route to the IGW. Private subnets need a route to the NAT Gateway.

### 🖥️ Method 1: AWS Management Console

**Step 9 — Create public route table**
* Left panel → Route Tables → Create route table
* Name: `public-route-table`
* VPC: `my-custom-vpc`
* Click **Create route table**

**Step 10 — Add internet route to public table**
* Click your new route table → Routes tab → Edit routes
* Click Add route:
  * Destination: `0.0.0.0/0`
  * Target: Internet Gateway → select `my-vpc-igw`
* Click **Save changes**

**Step 11 — Associate public subnets**
* Click Subnet associations tab → Edit subnet associations
* Check ✅ `public-subnet-a`
* Check ✅ `public-subnet-b`
* Click **Save associations**

**Step 12 — Create private route table**
* Create route table again:
  * Name: `private-route-table`
  * VPC: `my-custom-vpc`
* Click **Create route table**
* Click Subnet associations tab → Edit subnet associations
* Check ✅ `private-subnet-a`
* Check ✅ `private-subnet-b`
* Click **Save associations**

> 💡 **Note:** We will add the NAT Gateway route to this table in Part 5.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=my-custom-vpc" --query "Vpcs[0].VpcId" --output text)
PUB_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=public-subnet-a" --query "Subnets[0].SubnetId" --output text)
PUB_SUBNET_B=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=public-subnet-b" --query "Subnets[0].SubnetId" --output text)
PRI_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=private-subnet-a" --query "Subnets[0].SubnetId" --output text)
PRI_SUBNET_B=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=private-subnet-b" --query "Subnets[0].SubnetId" --output text)

IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-vpc-igw}]" \
  --query "InternetGateway.InternetGatewayId" --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

PUB_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-route-table}]" \
  --query "RouteTable.RouteTableId" --output text)

aws ec2 create-route \
  --route-table-id $PUB_RT_ID \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

aws ec2 associate-route-table --route-table-id $PUB_RT_ID --subnet-id $PUB_SUBNET_A
aws ec2 associate-route-table --route-table-id $PUB_RT_ID --subnet-id $PUB_SUBNET_B

PRI_RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=private-route-table}]" \
  --query "RouteTable.RouteTableId" --output text)

aws ec2 associate-route-table --route-table-id $PRI_RT_ID --subnet-id $PRI_SUBNET_A
aws ec2 associate-route-table --route-table-id $PRI_RT_ID --subnet-id $PRI_SUBNET_B

echo -e "\e[32m\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Create public route table
$PUB_RT_ID = aws ec2 create-route-table `
  --vpc-id $VPC_ID `
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=public-route-table}]" `
  --query "RouteTable.RouteTableId" `
  --output text

Write-Host "Public Route Table ID: $PUB_RT_ID"

# Add internet route (0.0.0.0/0 → IGW)
aws ec2 create-route `
  --route-table-id $PUB_RT_ID `
  --destination-cidr-block 0.0.0.0/0 `
  --gateway-id $IGW_ID

# Associate public subnets with public route table
aws ec2 associate-route-table `
  --route-table-id $PUB_RT_ID `
  --subnet-id $PUB_SUBNET_A

aws ec2 associate-route-table `
  --route-table-id $PUB_RT_ID `
  --subnet-id $PUB_SUBNET_B

# Create private route table
$PRI_RT_ID = aws ec2 create-route-table `
  --vpc-id $VPC_ID `
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=private-route-table}]" `
  --query "RouteTable.RouteTableId" `
  --output text

Write-Host "Private Route Table ID: $PRI_RT_ID"

# Associate private subnets with private route table
aws ec2 associate-route-table `
  --route-table-id $PRI_RT_ID `
  --subnet-id $PRI_SUBNET_A

aws ec2 associate-route-table `
  --route-table-id $PRI_RT_ID `
  --subnet-id $PRI_SUBNET_B

# Verify routes
aws ec2 describe-route-tables `
  --filters "Name=vpc-id,Values=$VPC_ID" `
  --query "RouteTables[*].{Name:Tags[?Key=='Name'].Value|[0],RouteTableId:RouteTableId,Routes:Routes[*].DestinationCidrBlock}" `
  --output table
```
✅ **Checkpoint 4 complete** — route tables created and associated.

---

## 🔒 PART 5 — CREATE NAT GATEWAY

The NAT Gateway sits in a public subnet and lets private instances reach the internet for updates, patches, and API calls — without exposing them to inbound internet traffic.

> ⚠️ **Warning:** This is the only resource in this project that costs money (~$0.045/hr). We test it and delete it within the same session.

### 🖥️ Method 1: AWS Management Console

**Step 13 — Create NAT Gateway**
* Left panel → NAT Gateways → Create NAT Gateway
* Name: `my-nat-gateway`
* Subnet: `public-subnet-a` (NAT always goes in a PUBLIC subnet)
* Connectivity type: `Public`
* Elastic IP allocation: Click **Allocate Elastic IP**
* Click **Create NAT Gateway**
* ⏳ Wait 1–2 minutes for status to change to Available
* Copy the NAT Gateway ID (looks like `nat-0abc123def456`)

**Step 14 — Add NAT route to private route table**
* Left panel → Route Tables → select `private-route-table`
* Routes tab → Edit routes → Add route:
  * Destination: `0.0.0.0/0`
  * Target: NAT Gateway → select `my-nat-gateway`
* Click **Save changes**

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

PUB_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=public-subnet-a" --query "Subnets[0].SubnetId" --output text)
PRI_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=private-route-table" --query "RouteTables[0].RouteTableId" --output text)

EIP_ALLOC=$(aws ec2 allocate-address \
  --domain vpc --query "AllocationId" --output text)

NAT_GW_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $PUB_SUBNET_A \
  --allocation-id $EIP_ALLOC \
  --tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=my-nat-gateway}]" \
  --query "NatGateway.NatGatewayId" --output text)

echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID

aws ec2 create-route \
  --route-table-id $PRI_RT_ID \
  --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_ID

echo -e "\e[32m\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Allocate an Elastic IP for the NAT Gateway
$EIP_ALLOC = aws ec2 allocate-address `
  --domain vpc `
  --query "AllocationId" `
  --output text

Write-Host "Elastic IP Allocation ID: $EIP_ALLOC"

# Create NAT Gateway in public-subnet-a
$NAT_GW_ID = aws ec2 create-nat-gateway `
  --subnet-id $PUB_SUBNET_A `
  --allocation-id $EIP_ALLOC `
  --tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=my-nat-gateway}]" `
  --query "NatGateway.NatGatewayId" `
  --output text

Write-Host "NAT Gateway ID: $NAT_GW_ID"
Write-Host "Waiting for NAT Gateway to become available..."

# Wait until available
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
Write-Host "NAT Gateway is available"

# Add NAT route to private route table
aws ec2 create-route `
  --route-table-id $PRI_RT_ID `
  --destination-cidr-block 0.0.0.0/0 `
  --nat-gateway-id $NAT_GW_ID

# Verify private route table now has NAT route
aws ec2 describe-route-tables `
  --route-table-ids $PRI_RT_ID `
  --query "RouteTables[0].Routes[*].{Destination:DestinationCidrBlock,Target:NatGatewayId}" `
  --output table
# Expected: 0.0.0.0/0 → your NAT Gateway ID
```
✅ **Checkpoint 5 complete** — NAT Gateway running and private route configured.

---

## 🛡️ PART 6 — CREATE SECURITY GROUPS

### 🖥️ Method 1: AWS Management Console

**Step 15 — Bastion host security group (public)**
* Left panel → Security Groups → Create security group
* Name: `bastion-sg`
* Description: `Allow SSH from my IP only`
* VPC: `my-custom-vpc`
* Inbound rules:
  * Type: `SSH` | Port: `22` | Source: `My IP`

**Step 16 — Private instance security group**
* Create security group again:
* Name: `private-sg`
* Description: `Allow SSH from bastion only`
* VPC: `my-custom-vpc`
* Inbound rules:
  * Type: `SSH` | Port: `22` | Source: `Custom` → select `bastion-sg`

> 💡 **Note:** This is the bastion host pattern — you SSH into the public bastion, then SSH from the bastion into private instances. Private instances never accept connections directly from the internet.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=my-custom-vpc" --query "Vpcs[0].VpcId" --output text)

MY_IP=(Invoke-WebRequest -Uri "https://checkip.amazonaws.com" \
  -UseBasicParsing).Content.Trim()

BASTION_SG=$(aws ec2 create-security-group \
  --group-name bastion-sg \
  --description "Allow SSH from my IP only" \
  --vpc-id $VPC_ID --query "GroupId" --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $BASTION_SG --protocol tcp --port 22 --cidr "$MY_IP/32"

PRIVATE_SG=$(aws ec2 create-security-group \
  --group-name private-sg \
  --description "Allow SSH from bastion only" \
  --vpc-id $VPC_ID --query "GroupId" --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $PRIVATE_SG --protocol tcp --port 22 \
  --source-group $BASTION_SG

echo -e "\e[32m\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Get your current public IP
$MY_IP = (Invoke-WebRequest -Uri "https://checkip.amazonaws.com" `
  -UseBasicParsing).Content.Trim()

# Create bastion security group
$BASTION_SG = aws ec2 create-security-group `
  --group-name bastion-sg `
  --description "Allow SSH from my IP only" `
  --vpc-id $VPC_ID `
  --query "GroupId" `
  --output text

# Allow SSH from your IP only
aws ec2 authorize-security-group-ingress `
  --group-id $BASTION_SG `
  --protocol tcp `
  --port 22 `
  --cidr "$MY_IP/32"

Write-Host "Bastion SG: $BASTION_SG"

# Create private instance security group
$PRIVATE_SG = aws ec2 create-security-group `
  --group-name private-sg `
  --description "Allow SSH from bastion only" `
  --vpc-id $VPC_ID `
  --query "GroupId" `
  --output text

# Allow SSH ONLY from the bastion security group
aws ec2 authorize-security-group-ingress `
  --group-id $PRIVATE_SG `
  --protocol tcp `
  --port 22 `
  --source-group $BASTION_SG

Write-Host "Private SG: $PRIVATE_SG"

# Verify both security groups
aws ec2 describe-security-groups `
  --group-ids $BASTION_SG $PRIVATE_SG `
  --query "SecurityGroups[*].{Name:GroupName,Rules:IpPermissions[*].{Port:FromPort,Source:IpRanges[0].CidrIp}}" `
  --output table
```

---

## 🖥️ PART 7 — LAUNCH TEST EC2 INSTANCES

### 🖥️ Method 1: AWS Management Console

**Step 17 — Launch bastion host in public subnet**
* EC2 → Launch instances
* Name: `bastion-host`
* AMI: Amazon Linux 2023 (Free tier)
* Instance type: `t2.micro`
* Key pair: `aws-ec2-keypair` (from Project 3)
* VPC: `my-custom-vpc`
* Subnet: `public-subnet-a`
* Auto-assign public IP: `Enable`
* Security group: `bastion-sg`
* Click **Launch instance**

**Step 18 — Launch private instance**
* EC2 → Launch instances
* Name: `private-instance`
* AMI: Amazon Linux 2023 (Free tier)
* Instance type: `t2.micro`
* Key pair: `aws-ec2-keypair`
* VPC: `my-custom-vpc`
* Subnet: `private-subnet-a`
* Auto-assign public IP: `Disable`
* Security group: `private-sg`
* Click **Launch instance**

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=my-custom-vpc" --query "Vpcs[0].VpcId" --output text)
PUB_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=public-subnet-a" --query "Subnets[0].SubnetId" --output text)
PRI_SUBNET_A=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=private-subnet-a" --query "Subnets[0].SubnetId" --output text)
BASTION_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=bastion-sg" "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text)
PRIVATE_SG=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=private-sg" "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text)

AMI_ID=$(aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" "Name=state,Values=available" \
  --query "sort_by(Images,&CreationDate)[-1].ImageId" --output text)

BASTION_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID --instance-type t2.micro \
  --key-name aws-ec2-keypair --subnet-id $PUB_SUBNET_A \
  --security-group-ids $BASTION_SG --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=bastion-host}]" \
  --query "Instances[0].InstanceId" --output text)

PRIVATE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID --instance-type t2.micro \
  --key-name aws-ec2-keypair --subnet-id $PRI_SUBNET_A \
  --security-group-ids $PRIVATE_SG --no-associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=private-instance}]" \
  --query "Instances[0].InstanceId" --output text)

echo "Waiting for instances to be running..."
aws ec2 wait instance-running --instance-ids $BASTION_ID $PRIVATE_ID
echo -e "\e[32m\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Get latest Amazon Linux 2023 AMI
$AMI_ID = aws ec2 describe-images `
  --owners amazon `
  --filters "Name=name,Values=al2023-ami-*-x86_64" `
    "Name=state,Values=available" `
  --query "sort_by(Images,&CreationDate)[-1].ImageId" `
  --output text

Write-Host "AMI ID: $AMI_ID"

# Launch bastion host in public subnet
$BASTION_ID = aws ec2 run-instances `
  --image-id $AMI_ID `
  --instance-type t2.micro `
  --key-name aws-ec2-keypair `
  --subnet-id $PUB_SUBNET_A `
  --security-group-ids $BASTION_SG `
  --associate-public-ip-address `
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=bastion-host}]" `
  --query "Instances[0].InstanceId" `
  --output text

Write-Host "Bastion Instance ID: $BASTION_ID"

# Launch private instance in private subnet
$PRIVATE_ID = aws ec2 run-instances `
  --image-id $AMI_ID `
  --instance-type t2.micro `
  --key-name aws-ec2-keypair `
  --subnet-id $PRI_SUBNET_A `
  --security-group-ids $PRIVATE_SG `
  --no-associate-public-ip-address `
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=private-instance}]" `
  --query "Instances[0].InstanceId" `
  --output text

Write-Host "Private Instance ID: $PRIVATE_ID"

# Wait for both to be running
Write-Host "Waiting for instances to start..."
aws ec2 wait instance-running `
  --instance-ids $BASTION_ID $PRIVATE_ID
Write-Host "Both instances running"

# Get bastion public IP and private instance private IP
$BASTION_PUBLIC_IP = aws ec2 describe-instances `
  --instance-ids $BASTION_ID `
  --query "Reservations[0].Instances[0].PublicIpAddress" `
  --output text

$PRIVATE_IP = aws ec2 describe-instances `
  --instance-ids $PRIVATE_ID `
  --query "Reservations[0].Instances[0].PrivateIpAddress" `
  --output text

Write-Host "Bastion Public IP:   $BASTION_PUBLIC_IP"
Write-Host "Private Instance IP: $PRIVATE_IP"
```

---

## 🔍 PART 8 — VERIFY CONNECTIVITY

### 🖥️ Method 1: AWS Management Console
*(Connectivity testing is performed via terminal. See Methods 2 and 3).*

### 🐧 Method 2: AWS CLI (Bash)
**Test 1 — SSH into bastion (public subnet)**
Open PuTTY (or terminal):
* Host: `ec2-user@YOUR_BASTION_PUBLIC_IP`
* Port: 22
* Key: `aws-ec2-keypair.ppk` (or `.pem`)

Once connected run:
```bash
# Confirm you are on the bastion
hostname
curl http://169.254.169.254/latest/meta-data/local-ipv4
# Expected: 10.0.1.x (public subnet A range)

# Confirm internet access from public subnet
curl -s https://checkip.amazonaws.com
# Expected: your EIP / public IP
```

**Test 2 — Verify private instance has NO public IP**
```powershell
# From your Windows PowerShell — try to ping the private IP
# This should NOT work (private IPs are not routable over internet)
aws ec2 describe-instances --instance-ids $PRIVATE_ID `
  --query "Reservations[0].Instances[0].{PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress}" `
  --output table
# Expected: PrivateIP = 10.0.3.x, PublicIP = None
```

**Test 3 — SSH from bastion into private instance**
On your bastion terminal:
```bash
# From bastion — try to reach private instance
ping -c 3 10.0.3.X
# Replace X with your private instance's last octet
# Expected: ping fails (ICMP not allowed by security group — that is correct)

# SSH into private instance from bastion
ssh -i /tmp/aws-ec2-keypair.pem ec2-user@10.0.3.X
```
> 💡 For the SSH hop to work you need to copy your `.pem` key to the bastion. In production teams use SSH agent forwarding (`ssh -A`) so the key never leaves your local machine.

**Test 4 — Verify private instance can reach internet via NAT**
Connect to your private instance via SSM Session Manager:
```powershell
# Attach SSM role to private instance first
aws ec2 associate-iam-instance-profile `
  --instance-id $PRIVATE_ID `
  --iam-instance-profile Name=ec2-ssm-profile

# Wait 2 minutes then connect
aws ssm start-session --target $PRIVATE_ID
```
Inside the private instance terminal:
```bash
# This is the critical test — private instance reaching internet via NAT
curl -s https://checkip.amazonaws.com
# Expected: returns the NAT Gateway's Elastic IP
# (NOT the private instance's IP — it is NATted)

# Test package manager reaches internet
sudo yum update -y
# Expected: downloads and installs updates successfully

# Confirm no public IP on this instance
curl http://169.254.169.254/latest/meta-data/public-ipv4
# Expected: 404 or empty — no public IP assigned
```
✅ If `curl https://checkip.amazonaws.com` returns the NAT Gateway's EIP — your entire VPC architecture is working correctly!

### 🪟 Method 3: AWS CLI (PowerShell)
*(Follow the exact same SSH test procedures listed in Method 2)*

---

## 🧹 PART 9 — CLEANUP

Run in this exact order — dependencies matter:

### 🖥️ Method 1: AWS Management Console
1. Go to **EC2** -> **Instances** and terminate both `bastion-host` and `private-instance`. Wait for termination.
2. Go to **VPC** -> **NAT Gateways**, select `my-nat-gateway`, and delete it. Wait until deleted.
3. Go to **VPC** -> **Elastic IPs**, select the EIP, click **Actions** -> **Release**.
4. Go to **EC2** -> **Security Groups** and delete `private-sg` and `bastion-sg`.
5. Go to **VPC** -> **Subnets** and delete all 4 subnets.
6. Go to **VPC** -> **Route Tables** and delete the public and private tables.
7. Go to **VPC** -> **Internet Gateways**, detach `my-vpc-igw` from the VPC, then delete it.
8. Go to **VPC** -> **Your VPCs**, select `my-custom-vpc` and delete it.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# cleanup.ps1 — Full Project 5 VPC Teardown
# Run this script to delete all resources in the correct order
# Usage: .\scripts\06-cleanup.ps1

# ============================================================
# SET YOUR RESOURCE IDs HERE BEFORE RUNNING
# ============================================================
BASTION_ID="i-XXXXXXXXXXXXXXXXX"   # Bastion instance ID
PRIVATE_ID="i-XXXXXXXXXXXXXXXXX"   # Private instance ID
NAT_GW_ID="nat-XXXXXXXXXXXXXXXXX" # NAT Gateway ID
EIP_ALLOC="eipalloc-XXXXXXXXXX"   # Elastic IP allocation ID
PRIVATE_SG="sg-XXXXXXXXXXXXXXXXX"  # private-sg ID
BASTION_SG="sg-XXXXXXXXXXXXXXXXX"  # bastion-sg ID
PUB_SUBNET_A="subnet-XXXXXXXXXX"    # Public Subnet A ID
PUB_SUBNET_B="subnet-XXXXXXXXXX"    # Public Subnet B ID
PRI_SUBNET_A="subnet-XXXXXXXXXX"    # Private Subnet A ID
PRI_SUBNET_B="subnet-XXXXXXXXXX"    # Private Subnet B ID
PUB_RT_ID="rtb-XXXXXXXXXXXXXXXXX" # Public Route Table ID
PRI_RT_ID="rtb-XXXXXXXXXXXXXXXXX" # Private Route Table ID
IGW_ID="igw-XXXXXXXXXXXXXXXXX" # Internet Gateway ID
VPC_ID="vpc-XXXXXXXXXXXXXXXXX" # VPC ID

echo "============================================"
echo "  Project 5 — VPC Cleanup Starting"
echo "============================================"
echo ""

# Step 1 — Terminate EC2 Instances
echo "[1/8] Terminating EC2 instances..."
aws ec2 terminate-instances \
  --instance-ids $BASTION_ID $PRIVATE_ID | Out-Null

echo "      Waiting for instances to terminate..."
aws ec2 wait instance-terminated \
  --instance-ids $BASTION_ID $PRIVATE_ID
echo "      Instances terminated ✅"
echo ""

# Step 2 — Delete NAT Gateway
echo "[2/8] Deleting NAT Gateway (stops billing immediately)..."
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID | Out-Null
echo "      NAT Gateway deletion initiated ✅"
echo "      Waiting 60 seconds for NAT Gateway to delete..."
sleep 60

# Verify NAT Gateway is deleted
NAT_STATE=$(aws ec2 describe-nat-gateways \
  --nat-gateway-ids $NAT_GW_ID \
  --query "NatGateways[0].State" --output text)
echo "      NAT Gateway state: $NAT_STATE"
while ($NAT_STATE -ne "deleted") {
echo "      Still deleting — waiting 30 more seconds..."
  sleep 30
  NAT_STATE=$(aws ec2 describe-nat-gateways \
    --nat-gateway-ids $NAT_GW_ID \
    --query "NatGateways[0].State" --output text)
}
echo "      NAT Gateway deleted ✅"
echo ""

# Step 3 — Release Elastic IP
echo "[3/8] Releasing Elastic IP..."
aws ec2 release-address --allocation-id $EIP_ALLOC | Out-Null
echo "      Elastic IP released ✅"
echo ""

# Step 4 — Delete Security Groups
echo "[4/8] Deleting Security Groups..."
aws ec2 delete-security-group --group-id $PRIVATE_SG | Out-Null
aws ec2 delete-security-group --group-id $BASTION_SG | Out-Null
echo "      Security Groups deleted ✅"
echo ""

# Step 5 — Delete Subnets
echo "[5/8] Deleting Subnets..."
aws ec2 delete-subnet --subnet-id $PUB_SUBNET_A | Out-Null
aws ec2 delete-subnet --subnet-id $PUB_SUBNET_B | Out-Null
aws ec2 delete-subnet --subnet-id $PRI_SUBNET_A | Out-Null
aws ec2 delete-subnet --subnet-id $PRI_SUBNET_B | Out-Null
echo "      Subnets deleted ✅"
echo ""

# Step 6 — Delete Route Tables
echo "[6/8] Deleting Route Tables..."
aws ec2 delete-route-table --route-table-id $PUB_RT_ID | Out-Null
aws ec2 delete-route-table --route-table-id $PRI_RT_ID | Out-Null
echo "      Route Tables deleted ✅"
echo ""

# Step 7 — Delete Internet Gateway
echo "[7/8] Detaching and Deleting Internet Gateway..."
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID | Out-Null
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID | Out-Null
echo "      Internet Gateway deleted ✅"
echo ""

# Step 8 — Delete VPC
echo "[8/8] Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID | Out-Null
echo "      VPC deleted ✅"
echo ""

echo "============================================"
echo "  Cleanup Complete! All resources destroyed."
echo "============================================"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Step 1 — Terminate both EC2 instances
aws ec2 terminate-instances `
  --instance-ids $BASTION_ID $PRIVATE_ID

aws ec2 wait instance-terminated `
  --instance-ids $BASTION_ID $PRIVATE_ID
Write-Host "Instances terminated"

# Step 2 — Delete NAT Gateway (stops the charge immediately)
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
Write-Host "NAT Gateway deletion initiated"

# Wait for NAT Gateway to be deleted
Start-Sleep -Seconds 60
aws ec2 describe-nat-gateways --nat-gateway-ids $NAT_GW_ID `
  --query "NatGateways[0].State" --output text
# Wait until: deleted

# Step 3 — Release Elastic IP (costs money if not released)
aws ec2 release-address --allocation-id $EIP_ALLOC
Write-Host "Elastic IP released"

# Step 4 — Delete security groups
aws ec2 delete-security-group --group-id $PRIVATE_SG
aws ec2 delete-security-group --group-id $BASTION_SG
Write-Host "Security groups deleted"

# Step 5 — Delete subnets
aws ec2 delete-subnet --subnet-id $PUB_SUBNET_A
aws ec2 delete-subnet --subnet-id $PUB_SUBNET_B
aws ec2 delete-subnet --subnet-id $PRI_SUBNET_A
aws ec2 delete-subnet --subnet-id $PRI_SUBNET_B
Write-Host "Subnets deleted"

# Step 6 — Delete route tables
aws ec2 delete-route-table --route-table-id $PUB_RT_ID
aws ec2 delete-route-table --route-table-id $PRI_RT_ID
Write-Host "Route tables deleted"

# Step 7 — Detach and delete Internet Gateway
aws ec2 detach-internet-gateway `
  --internet-gateway-id $IGW_ID `
  --vpc-id $VPC_ID

aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
Write-Host "IGW deleted"

# Step 8 — Delete VPC
aws ec2 delete-vpc --vpc-id $VPC_ID
Write-Host "VPC deleted"

# Step 9 — Final verification
aws ec2 describe-vpcs `
  --filters "Name=tag:Name,Values=my-custom-vpc" `
  --query "Vpcs[*].VpcId" --output text
# Expected: no output = fully cleaned up
```

---

## 🛠️ Troubleshooting

| Problem | Cause | Fix |
|:--------|:------|:----|
| **Cannot delete VPC** | Subnets, IGW, or instances still exist | Delete in order: instances → NAT GW → subnets → route tables → IGW → VPC |
| **NAT Gateway stuck in Pending** | Normal — takes 1–2 minutes | Run `aws ec2 describe-nat-gateways` and wait for Available |
| **Private instance cannot reach internet** | NAT route missing from private route table | Verify `0.0.0.0/0` → NAT GW in private route table |
| **Bastion SSH times out** | Security group missing port 22 or wrong IP | Re-check `bastion-sg` allows your current IP (IP may have changed) |
| **SSM Session Manager won't connect** | IAM profile not attached or agent not ready | Wait 3 minutes after attaching profile; verify `AmazonSSMManagedInstanceCore` policy |
| **delete-security-group fails** | Instance still using it | Terminate instances first and wait for terminated state |
| **EIP not releasing** | Still associated with NAT GW | Wait for NAT GW to fully delete then release EIP |