#!/bin/bash

# =============================================================================
# Project 10 — Script 08: Verify and Test
# Checks target health, tests load balancing, opens browser
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Verify and Test ===\e[0m"
echo ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
TG_ARN=$(aws elbv2 describe-target-groups \
    --names web-server-tg \
    --query "TargetGroups[0].TargetGroupArn" --output text 2>/dev/null)

ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names my-alb \
    --query "LoadBalancers[0].DNSName" --output text 2>/dev/null)

echo -e "\e[32m  Target Group: $TG_ARN\e[0m"
echo -e "\e[32m  ALB DNS:      $ALB_DNS\e[0m"
echo ""

# ── CHECK TARGET HEALTH ──────────────────────────────────────────────────────
echo -e "\e[33m[1/4] Checking target group health...\e[0m"
echo -e "\e[33m  Waiting for targets to become healthy (polling every 15s)...\e[0m"

maxAttempts=20
attempt=0
allHealthy="false"

while [ "$allHealthy" == "false" ] && [ $attempt -lt $maxAttempts ]; do
    attempt=$((attempt+1))
    
    healthData=$(aws elbv2 describe-target-health --target-group-arn "$TG_ARN" --output json 2>/dev/null)
    
    # Parse json to get counts
    healthyCount=$(echo "$healthData" | jq -r '[.TargetHealthDescriptions[] | select(.TargetHealth.State == "healthy")] | length' 2>/dev/null)
    totalCount=$(echo "$healthData" | jq -r '.TargetHealthDescriptions | length' 2>/dev/null)
    
    # Handle jq failures if no targets are registered yet
    if [ -z "$healthyCount" ]; then healthyCount=0; fi
    if [ -z "$totalCount" ]; then totalCount=0; fi

    echo "  Attempt $attempt: $healthyCount/$totalCount healthy"

    if [ "$healthyCount" -eq "$totalCount" ] && [ "$totalCount" -gt 0 ]; then
        allHealthy="true"
    else
        sleep 15
    fi
done

if [ "$allHealthy" == "true" ]; then
    echo -e "\e[32m  All targets healthy!\e[0m"
else
    echo -e "\e[31m  Timeout — some targets may still be initializing.\e[0m"
fi

# ── DISPLAY TARGET HEALTH TABLE ───────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/4] Target health status:\e[0m"
aws elbv2 describe-target-health \
    --target-group-arn "$TG_ARN" \
    --query "TargetHealthDescriptions[*].{Instance:Target.Id,Port:Target.Port,State:TargetHealth.State}" \
    --output table

# ── CHECK ASG INSTANCES ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/4] ASG instance status:\e[0m"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names web-server-asg \
    --query "AutoScalingGroups[0].Instances[*].{ID:InstanceId,AZ:AvailabilityZone,State:LifecycleState,Health:HealthStatus}" \
    --output table

# ── TEST LOAD BALANCING ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[4/4] Testing load balancing (5 requests)...\e[0m"
echo -e "\e[32m  URL: http://$ALB_DNS\e[0m"
echo ""

for i in {1..5}; do
    response=$(curl -s "http://$ALB_DNS" --max-time 10 || echo "FAILED")
    if [ "$response" == "FAILED" ]; then
        echo -e "\e[31m  Request $i: FAILED\e[0m"
    else
        instanceId=$(echo "$response" | grep -o 'i-[0-9a-f]\{8,17\}' | head -n 1)
        echo -e "\e[32m  Request $i: OK | Instance: $instanceId\e[0m"
    fi
    sleep 0.5
done

# ── OPEN BROWSER ──────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mOpening ALB in browser...\e[0m"
# Not opening browser in bash script automatically to avoid WSL issues
echo -e "Please open \e[36mhttp://$ALB_DNS\e[0m in your browser"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Verification Complete ===\e[0m"
echo "  ALB URL: http://$ALB_DNS"
echo ""
echo -e "\e[33m  Refresh the browser multiple times — you should see different\e[0m"
echo -e "\e[33m  Instance IDs and Availability Zones on each refresh.\e[0m"
echo -e "\e[33m  This proves the ALB is distributing traffic across instances.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 09-test-auto-scaling.sh\e[0m"
