#!/bin/bash

# =============================================================================
# Project 10 — Script 05: Create Target Group
# Creates ALB target group with HTTP health checks on port 80
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Create Target Group ===\e[0m"
echo ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=isDefault,Values=true" \
    --query "Vpcs[0].VpcId" --output text)

echo -e "\e[32m  VPC: $VPC_ID\e[0m"
echo ""

# ── CREATE TARGET GROUP ───────────────────────────────────────────────────────
echo -e "\e[33m[1/1] Creating Target Group with health checks...\e[0m"

TG_ARN=$(aws elbv2 create-target-group \
    --name web-server-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --health-check-protocol HTTP \
    --health-check-path "/" \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 2 \
    --matcher HttpCode=200 \
    --target-type instance \
    --query "TargetGroups[0].TargetGroupArn" \
    --output text)

echo -e "\e[32m  Target Group ARN: $TG_ARN\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying target group...\e[0m"
aws elbv2 describe-target-groups \
    --target-group-arns $TG_ARN \
    --query "TargetGroups[0].{Name:TargetGroupName,Protocol:Protocol,Port:Port,HealthPath:HealthCheckPath,HealthInterval:HealthCheckIntervalSeconds}" \
    --output table

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Target Group Complete ===\e[0m"
echo "  Name:           web-server-tg"
echo "  Protocol:       HTTP"
echo "  Port:           80"
echo "  Health Check:   HTTP GET / (every 30s, timeout 5s)"
echo "  Healthy After:  2 consecutive checks"
echo "  Unhealthy After: 2 consecutive failures"
echo "  Success Code:   200"
echo ""
echo -e "\e[33m  No targets registered yet — ASG will add instances automatically.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 06-create-alb.sh\e[0m"
