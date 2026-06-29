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