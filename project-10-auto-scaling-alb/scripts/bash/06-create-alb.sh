#!/bin/bash

# =============================================================================
# Project 10 — Script 06: Create Application Load Balancer
# Creates internet-facing ALB with HTTP listener forwarding to target group
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Create Application Load Balancer ===\e[0m"
echo ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query "Vpcs[0].VpcId" --output text)

SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    "Name=defaultForAz,Values=true" \
    --query "Subnets[*].SubnetId" \
    --output text)

SUBNET_LIST=$SUBNETS
SUBNET_A=$SUBNET_LIST[0]
SUBNET_B=$SUBNET_LIST[1]

ALB_SG=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=alb-sg" \
    "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[0].GroupId" --output text)

TG_ARN=$(aws elbv2 describe-target-groups \
    --names web-server-tg \
    --query "TargetGroups[0].TargetGroupArn" --output text)

echo -e "\e[32m  VPC:      $VPC_ID\e[0m"
echo -e "\e[32m  Subnet A: $SUBNET_A\e[0m"
echo -e "\e[32m  Subnet B: $SUBNET_B\e[0m"
echo -e "\e[32m  ALB SG:   $ALB_SG\e[0m"
echo -e "\e[32m  TG ARN:   $TG_ARN\e[0m"
echo ""

# ── CREATE ALB ────────────────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Creating Application Load Balancer...\e[0m"

ALB_ARN=$(aws elbv2 create-load-balancer \
    --name my-alb \
    --subnets $SUBNET_A $SUBNET_B \
    --security-groups $ALB_SG \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --query "LoadBalancers[0].LoadBalancerArn" \
    --output text)

echo -e "\e[32m  ALB ARN: $ALB_ARN\e[0m"

# ── GET DNS NAME ──────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/3] Getting ALB DNS name...\e[0m"

ALB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query "LoadBalancers[0].DNSName" \
    --output text)

echo -e "\e[32m  ALB DNS: $ALB_DNS\e[0m"

# ── CREATE HTTP LISTENER ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/3] Creating HTTP listener (port 80 → target group)...\e[0m"

LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions "Type=forward,TargetGroupArn=$TG_ARN" \
    --query "Listeners[0].ListenerArn" \
    --output text)

echo -e "\e[32m  Listener ARN: $LISTENER_ARN\e[0m"

# ── WAIT FOR ALB TO BE ACTIVE ─────────────────────────────────────────────────
echo ""
echo -e "\e[33mWaiting for ALB to become active (2-3 minutes)...\e[0m"
aws elbv2 wait load-balancer-available --load-balancer-arns $ALB_ARN
echo -e "\e[32m  ALB is active!\e[0m"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== ALB Complete ===\e[0m"
echo "  Name:      my-alb"
echo "  Scheme:    internet-facing"
echo "  Type:      application"
echo "  Listener:  HTTP:80 → web-server-tg"
echo ""
echo -e "\e[32m  URL: http://$ALB_DNS\e[0m"
echo ""
echo -e "\e[33m  The ALB is active but has no targets yet.\e[0m"
echo -e "\e[33m  ASG will register instances in the next step.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 07-create-auto-scaling-group.ps1\e[0m"
