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