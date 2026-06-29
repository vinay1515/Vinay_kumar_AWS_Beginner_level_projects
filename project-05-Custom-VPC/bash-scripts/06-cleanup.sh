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