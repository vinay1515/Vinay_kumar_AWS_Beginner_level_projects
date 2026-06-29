#!/bin/bash

# =============================================================================
# Project 7 — Script 02: Launch EC2 for Monitoring
# Launches a t2.micro in the default VPC to generate CloudWatch metrics
# =============================================================================

echo -e "\e[36m=== Project 7 — Launch Monitoring EC2 ===\e[0m"
echo ""

if (-not $SNS_ARN) {
echo -e "\e[33mWARNING: SNS_ARN not set. Run 01-sns-setup.ps1 first.\e[0m"
}

# ── GET DEFAULT VPC ───────────────────────────────────────────────────────────
echo -e "\e[33m[1/4] Getting default VPC and subnet...\e[0m"

VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query "Vpcs[0].VpcId" --output text)

SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=defaultForAz,Values=true" \
    --query "Subnets[0].SubnetId" --output text)

echo "Default VPC:    $VPC_ID"
echo "Default Subnet: $SUBNET_ID"

# ── SECURITY GROUP ────────────────────────────────────────────────────────────
echo -e "\e[33m[2/4] Creating security group...\e[0m"

MY_IP=(Invoke-WebRequest -Uri "https://checkip.amazonaws.com" \
        -UseBasicParsing).Content.Trim()

MON_SG=$(aws ec2 create-security-group \
    --group-name monitoring-test-sg \
    --description "SG for CloudWatch monitoring test" \
    --vpc-id $VPC_ID \
    --query "GroupId" --output text)

aws ec2 authorize-security-group-ingress \
    --group-id $MON_SG \
    --protocol tcp --port 22 --cidr "$MY_IP/32"

echo "Security group: $MON_SG (SSH from $MY_IP only)"

# ── FIND AMI ──────────────────────────────────────────────────────────────────
echo -e "\e[33m[3/4] Finding latest Amazon Linux 2023 AMI...\e[0m"

AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
    --query "sort_by(Images,&CreationDate)[-1].ImageId" \
    --output text)

echo "AMI: $AMI_ID"

# ── LAUNCH INSTANCE ───────────────────────────────────────────────────────────
echo -e "\e[33m[4/4] Launching instance...\e[0m"

MON_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name aws-ec2-keypair \
    --subnet-id $SUBNET_ID \
    --security-group-ids $MON_SG \
    --associate-public-ip-address \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=monitoring-test}]" \
    --query "Instances[0].InstanceId" \
    --output text)

echo -e "\e[32mInstance ID: $MON_INSTANCE_ID\e[0m"
echo -e "\e[33mWaiting for instance to enter running state...\e[0m"

aws ec2 wait instance-running --instance-ids $MON_INSTANCE_ID

MON_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $MON_INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

echo -e "\e[32mInstance running. Public IP: $MON_PUBLIC_IP\e[0m"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== EC2 Launch Complete ===\e[0m"
echo ""
echo "  MON_INSTANCE_ID = $MON_INSTANCE_ID"
echo "  MON_PUBLIC_IP   = $MON_PUBLIC_IP"
echo "  MON_SG          = $MON_SG"
echo ""
echo "Wait 5 minutes for CloudWatch metrics to start publishing."
echo "SSH command: ssh -i aws-ec2-keypair.pem ec2-user@$MON_PUBLIC_IP"
echo ""
echo -e "\e[36mNext step: Run 03-create-ec2-alarms.ps1\e[0m"