#!/bin/bash

# =============================================================================
# Project 10 — Script 09: Test Auto Scaling
# Generates CPU load to trigger scale-out, monitors instance count
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Test Auto Scaling ===\e[0m"
echo ""

# ── GET INSTANCE IDs ──────────────────────────────────────────────────────────
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names web-server-asg \
    --query "AutoScalingGroups[0].Instances[*].InstanceId" \
    --output text)

INSTANCE1=$(INSTANCE_IDS | awk '{print $1}')
echo -e "\e[32m  Target instance for stress test: $INSTANCE1\e[0m"
echo ""

# ── OPTION 1: SSH + STRESS ────────────────────────────────────────────────────
echo -e "\e[33m=== Option 1: SSH Stress Test ===\e[0m"
echo -e "\e[33m  Connect via SSM Session Manager:\e[0m"
echo -e "\e[97m    aws ssm start-session --target $INSTANCE1\e[0m"
echo ""
echo -e "\e[33m  Then run inside the session:\e[0m"
echo -e "\e[97m    sudo stress --cpu 1 --timeout 600 &\e[0m"
echo -e "\e[97m    top  (to verify stress is running)\e[0m"
echo ""

# ── OPTION 2: MANUAL SCALE ───────────────────────────────────────────────────
echo -e "\e[33m=== Option 2: Manual Scale Test ===\e[0m"
echo -e "\e[33m  Scale up to 3 instances:\e[0m"
echo -e "\e[97m    aws autoscaling set-desired-capacity --auto-scaling-group-name web-server-asg --desired-capacity 3\e[0m"
echo ""
echo -e "\e[33m  Scale back down:\e[0m"
echo -e "\e[97m    aws autoscaling set-desired-capacity --auto-scaling-group-name web-server-asg --desired-capacity 2\e[0m"
echo ""

# ── MONITOR ASG ───────────────────────────────────────────────────────────────
echo -e "\e[33m=== Monitoring ASG (Ctrl+C to stop) ===\e[0m"
echo ""

iterations=0
maxIterations=40  # Monitor for ~20 minutes

while [ $iterations -lt $maxIterations ]; do
    iterations=$((iterations + 1))

    asg=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names web-server-asg \
        --query "AutoScalingGroups[0].{Desired:DesiredCapacity,Instances:Instances[*].{ID:InstanceId,State:LifecycleState}}" \
        --output json)

    timestamp=$(date +"%T")
    instanceCount=$(echo "$asg" | jq ".Instances | length")
    desired=$(echo "$asg" | jq -r ".Desired")

    # Color based on change
    if [ "$instanceCount" -gt 2 ]; then
        color="\e[32m" # Green
    else
        color="\e[97m" # White
    fi

    echo -e "${color}${timestamp} — Instances: ${instanceCount} (Desired: ${desired})\e[0m"
    
    # Loop over instances in bash
    instance_ids=$(echo "$asg" | jq -r '.Instances[].ID')
    
    for id in $instance_ids; do
        state=$(echo "$asg" | jq -r ".Instances[] | select(.ID==\"$id\") | .State")
        if [ "$state" == "InService" ]; then
            stateColor="\e[32m" # Green
        elif [ "$state" == "Pending" ]; then
            stateColor="\e[33m" # Yellow
        else
            stateColor="\e[31m" # Red
        fi
        echo -e "  $id: ${stateColor}${state}\e[0m"
    done
    echo ""

    sleep 30
done

echo ""
echo -e "\e[36m=== Monitoring Complete ===\e[0m"
echo ""
echo -e "\e[33m  Check scaling history:\e[0m"
echo -e "\e[97m    aws autoscaling describe-scaling-activities --auto-scaling-group-name web-server-asg --query \"Activities[0:5].[StartTime,Cause,StatusCode]\" --output table\e[0m"
echo ""
echo -e "\e[36mNext step: Run 10-simulate-failure.sh OR 11-cleanup.sh\e[0m"
