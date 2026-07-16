#!/bin/bash

# =============================================================================
# Project 10 — Script 10: Simulate Instance Failure
# Terminates an instance to demonstrate ASG self-healing
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Simulate Instance Failure ===\e[0m"
echo ""

# ── GET CURRENT INSTANCES ─────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Getting current ASG instances...\e[0m"

INSTANCES=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names web-server-asg \
    --query "AutoScalingGroups[0].Instances[*].InstanceId" \
    --output text 2>/dev/null)

if [ -z "$INSTANCES" ] || [ "$INSTANCES" == "None" ]; then
    echo -e "\e[31m  No instances found in ASG!\e[0m"
    exit 1
fi

echo -e "\e[32m  Current instances: ${INSTANCES//$'\t'/, }\e[0m"

FAILED_INSTANCE=$(echo "$INSTANCES" | awk '{print $1}')
echo -e "\e[31m  Instance to terminate (simulate failure): $FAILED_INSTANCE\e[0m"
echo ""

# ── SHOW BEFORE STATE ─────────────────────────────────────────────────────────
echo -e "\e[33m[2/3] Before failure — current state:\e[0m"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names web-server-asg \
    --query "AutoScalingGroups[0].Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus,AZ:AvailabilityZone}" \
    --output table

# ── TERMINATE INSTANCE ────────────────────────────────────────────────────────
echo ""
echo -e "\e[31m[3/3] Terminating instance: $FAILED_INSTANCE\e[0m"
echo -e "\e[33m  ASG will detect the failure and launch a replacement...\e[0m"

aws ec2 terminate-instances --instance-ids "$FAILED_INSTANCE" >/dev/null 2>&1

echo -e "\e[31m  Termination initiated!\e[0m"
echo ""

# ── MONITOR SELF-HEALING ──────────────────────────────────────────────────────
echo -e "\e[33m=== Monitoring Self-Healing (Ctrl+C to stop) ===\e[0m"
echo -e "\e[33m  Expected: ASG detects failure → launches new instance → registers in ALB\e[0m"
echo ""

iterations=0
maxIterations=20  # Monitor for ~10 minutes

while [ $iterations -lt $maxIterations ]; do
    iterations=$((iterations+1))
    timestamp=$(date +"%T")

    asg_json=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names web-server-asg \
        --query "AutoScalingGroups[0].Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus}" \
        --output json 2>/dev/null)

    if [ -n "$asg_json" ] && [ "$asg_json" != "null" ]; then
        instanceCount=$(echo "$asg_json" | jq 'length')
        echo -e "\e[97m$timestamp — Instance Count: $instanceCount\e[0m"
        
        healthyCount=0
        
        echo "$asg_json" | jq -c '.[]' 2>/dev/null | while read -r inst; do
            id=$(echo "$inst" | jq -r '.ID')
            state=$(echo "$inst" | jq -r '.State')
            health=$(echo "$inst" | jq -r '.Health')
            
            if [ "$state" == "InService" ]; then
                stateColor="\e[32m" # Green
            elif [ "$state" == "Pending" ]; then
                stateColor="\e[33m" # Yellow
            elif [ "$state" == "Terminating" ]; then
                stateColor="\e[31m" # Red
            else
                stateColor="\e[90m" # Gray
            fi
            
            isNew=""
            if [ "$id" != "$FAILED_INSTANCE" ] && [ "$state" == "Pending" ]; then
                isNew=" ← NEW"
            fi
            
            echo -e "  ${id}: ${stateColor}${state}\e[0m (${health})${isNew}"
        done
        echo ""

        # Need to re-evaluate healthyCount outside the pipe subshell
        healthyCount=$(echo "$asg_json" | jq '[.[] | select(.State == "InService")] | length')
        
        if [ "$healthyCount" -ge 2 ] && [ $iterations -gt 2 ]; then
            echo -e "\e[32m  Self-healing complete! All instances InService.\e[0m"
            break
        fi
    else
        echo -e "$timestamp — Could not fetch ASG status"
        echo ""
    fi

    sleep 30
done

# ── FINAL STATE ───────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Final State After Self-Healing ===\e[0m"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names web-server-asg \
    --query "AutoScalingGroups[0].Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus,AZ:AvailabilityZone}" \
    --output table

echo ""
echo -e "\e[33m  Key takeaway: ASG automatically replaced the failed instance.\e[0m"
echo -e "\e[33m  The ALB routed traffic to the healthy instance during replacement.\e[0m"
echo -e "\e[33m  Zero manual intervention required!\e[0m"
echo ""
echo -e "\e[36mNext step: Run 11-cleanup.sh\e[0m"
