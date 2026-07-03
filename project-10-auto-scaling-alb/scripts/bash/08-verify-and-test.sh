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
    --query "TargetGroups[0].TargetGroupArn" --output text)

ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names my-alb \
    --query "LoadBalancers[0].DNSName" --output text)

echo -e "\e[32m  Target Group: $TG_ARN\e[0m"
echo -e "\e[32m  ALB DNS:      $ALB_DNS\e[0m"
echo ""

# ── CHECK TARGET HEALTH ──────────────────────────────────────────────────────
echo -e "\e[33m[1/4] Checking target group health...\e[0m"
echo -e "\e[33m  Waiting for targets to become healthy (polling every 15s)...\e[0m"

maxAttempts=20
attempt=0
allHealthy=$false

while (-not $allHealthy -and $attempt -lt $maxAttempts) {
    $attempt++
    healthData=$(aws elbv2 describe-target-health \
        --target-group-arn $TG_ARN \
        --query "TargetHealthDescriptions[*].{Instance:Target.Id,State:TargetHealth.State}" \
        --output json | jq .)

    healthyCount=($healthData | Where-Object { $_.State -eq "healthy" }).Count
    totalCount=$healthData.Count

echo "  Attempt $attempt`: $healthyCount/$totalCount healthy"

    if ($healthyCount -eq $totalCount -and $totalCount -gt 0) {
        allHealthy=$true
    }
    else {
        sleep 15
    }
}

if ($allHealthy) {
echo -e "\e[32m  All targets healthy!\e[0m"
}
else {
echo -e "\e[31m  Timeout — some targets may still be initializing.\e[0m"
}

# ── DISPLAY TARGET HEALTH TABLE ───────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/4] Target health status:\e[0m"
aws elbv2 describe-target-health \
    --target-group-arn $TG_ARN \
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

1..5 | ForEach-Object {
    try {
        response=$(curl -s "http://$ALB_DNS"  -TimeoutSec 10)
        instanceId=[regex]::Match($response.Content, 'i-[0-9a-f]{8,17}').Value
        statusCode=$response.StatusCode
echo -e "\e[32m  Request $_`: Status $statusCode | Instance: $instanceId\e[0m"
    }
    catch {
echo -e "\e[31m  Request $_`: FAILED — $($_.Exception.Message)\e[0m"
    }
    Start-Sleep -Milliseconds 500
}

# ── OPEN BROWSER ──────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mOpening ALB in browser...\e[0m"
Start-Process "http://$ALB_DNS"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Verification Complete ===\e[0m"
echo "  ALB URL: http://$ALB_DNS"
echo ""
echo -e "\e[33m  Refresh the browser multiple times — you should see different\e[0m"
echo -e "\e[33m  Instance IDs and Availability Zones on each refresh.\e[0m"
echo -e "\e[33m  This proves the ALB is distributing traffic across instances.\e[0m"
echo ""
echo -e "\e[36mNext step: Run 09-test-auto-scaling.ps1\e[0m"
