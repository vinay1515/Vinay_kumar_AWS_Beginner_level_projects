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