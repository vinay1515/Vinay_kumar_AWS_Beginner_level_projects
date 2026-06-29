#!/bin/bash

# =============================================================================
# Project 7 — Script 12: Full Cleanup
# Deletes all monitoring project resources
# =============================================================================

echo -e "\e[36m=== Project 7 — Full Cleanup ===\e[0m"
echo ""
echo -e "\e[31mDeletes: all alarms, dashboard, log group, SNS, EC2\e[0m"
echo ""

# Re-fetch IDs in case session variables were lost
echo -e "\e[33mRe-fetching resource IDs...\e[0m"

if (-not $SNS_ARN) {
    SNS_ARN=$(aws sns list-topics \
      --query "Topics[?contains(TopicArn,'monitoring-alerts')].TopicArn | [0]" \
      --output text)
}

if (-not $MON_INSTANCE_ID) {
    MON_INSTANCE_ID=$(aws ec2 describe-instances \
      --filters "Name=tag:Name,Values=monitoring-test" \
      --query "Reservations[0].Instances[0].InstanceId" \
      --output text)
}

if (-not $MON_SG) {
    MON_SG=$(aws ec2 describe-security-groups \
      --filters "Name=group-name,Values=monitoring-test-sg" \
      --query "SecurityGroups[0].GroupId" \
      --output text)
}

echo "SNS:  $SNS_ARN"
echo "EC2:  $MON_INSTANCE_ID"
echo "SG:   $MON_SG"
echo ""

# ── STEP 1: DELETE ALL CLOUDWATCH ALARMS ─────────────────────────────────────
echo -e "\e[33m[1/5] Deleting CloudWatch alarms...\e[0m"

aws cloudwatch delete-alarms \
  --alarm-names \
    "EC2-CPU-High" \
    "EC2-StatusCheck-Failed" \
    "EC2-NetworkIn-High" \
    "RDS-CPU-High" \
    "RDS-Storage-Low" \
    "RDS-Connections-High" \
    "App-Errors-High"

# Billing alarm in us-east-1
aws cloudwatch delete-alarms \
  --alarm-names "Billing-Alert-5USD" \
  --region us-east-1

echo -e "\e[32mAll alarms deleted.\e[0m"

# ── STEP 2: DELETE DASHBOARD ──────────────────────────────────────────────────
echo -e "\e[33m[2/5] Deleting CloudWatch dashboard...\e[0m"

aws cloudwatch delete-dashboards \
  --dashboard-names "AWS-Bootcamp-Dashboard" 2>&1 | Out-Null

echo -e "\e[32mDashboard deleted.\e[0m"

# ── STEP 3: DELETE LOG GROUP ──────────────────────────────────────────────────
echo -e "\e[33m[3/5] Deleting CloudWatch log group...\e[0m"

aws logs delete-log-group \
  --log-group-name "/aws/ec2/monitoring-test" 2>&1 | Out-Null

echo -e "\e[32mLog group deleted.\e[0m"

# ── STEP 4: DELETE SNS ────────────────────────────────────────────────────────
echo -e "\e[33m[4/5] Deleting SNS topic and subscriptions...\e[0m"

if ($SNS_ARN -and $SNS_ARN -ne "None") {
    SUB_ARN=$(aws sns list-subscriptions-by-topic \
      --topic-arn $SNS_ARN \
      --query "Subscriptions[0].SubscriptionArn" \
      --output text)

    if ($SUB_ARN -and $SUB_ARN -ne "PendingConfirmation" -and $SUB_ARN -ne "None") {
        aws sns unsubscribe --subscription-arn $SUB_ARN 2>&1 | Out-Null
echo "  Subscription unsubscribed."
    }

    aws sns delete-topic --topic-arn $SNS_ARN 2>&1 | Out-Null
echo -e "\e[32mSNS topic deleted.\e[0m"
} else {
echo -e "\e[90mSNS topic not found — skipping.\e[0m"
}

# ── STEP 5: TERMINATE EC2 ─────────────────────────────────────────────────────
echo -e "\e[33m[5/5] Terminating EC2 instance and deleting security group...\e[0m"

if ($MON_INSTANCE_ID -and $MON_INSTANCE_ID -ne "None") {
    aws ec2 terminate-instances --instance-ids $MON_INSTANCE_ID | Out-Null
echo -e "\e[33m  Waiting for EC2 termination (~1-2 minutes)...\e[0m"
    aws ec2 wait instance-terminated --instance-ids $MON_INSTANCE_ID
echo "  EC2 terminated."
}

if ($MON_SG -and $MON_SG -ne "None") {
    aws ec2 delete-security-group --group-id $MON_SG 2>&1 | Out-Null
echo "  Security group deleted."
}

echo -e "\e[32mEC2 and security group deleted.\e[0m"

# ── VERIFICATION ──────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Cleanup Verification ===\e[0m"
echo ""

REMAINING=$(aws cloudwatch describe-alarms \
  --query "MetricAlarms[*].AlarmName" --output text)
if (-not $REMAINING) {
echo -e "\e[32mAlarms:    CLEARED\e[0m"
} else {
echo -e "\e[31mAlarms:    Still present — $REMAINING\e[0m"
}

DASH=$(aws cloudwatch list-dashboards \
  --query "DashboardEntries[*].DashboardName" --output text)
if (-not $DASH) {
echo -e "\e[32mDashboard: CLEARED\e[0m"
} else {
echo -e "\e[31mDashboard: Still present — $DASH\e[0m"
}

echo ""
echo -e "\e[36m=== Project 7 Cleanup Complete ===\e[0m"
echo ""
echo "Cost impact: $0.00 — all resources were within free tier."