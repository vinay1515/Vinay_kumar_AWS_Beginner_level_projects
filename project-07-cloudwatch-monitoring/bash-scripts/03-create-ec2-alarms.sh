#!/bin/bash

# =============================================================================
# Project 7 — Script 03: EC2 CloudWatch Alarms
# Creates CPU, StatusCheck, and NetworkIn alarms for the monitoring EC2 instance
# =============================================================================

echo -e "\e[36m=== Project 7 — EC2 CloudWatch Alarms ===\e[0m"
echo ""

if (-not $MON_INSTANCE_ID -or -not $SNS_ARN) {
echo -e "\e[31mERROR: MON_INSTANCE_ID or SNS_ARN not set.\e[0m"
echo "Run 01-sns-setup.ps1 and 02-launch-monitoring-ec2.ps1 first."
    exit 1
}

echo "Instance: $MON_INSTANCE_ID"
echo "SNS ARN:  $SNS_ARN"
echo ""

# ── ALARM 1: EC2 HIGH CPU ─────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Creating EC2-CPU-High alarm...\e[0m"

aws cloudwatch put-metric-alarm \
  --alarm-name "EC2-CPU-High" \
  --alarm-description "EC2 CPU utilization exceeded 70% for 10 minutes" \
  --namespace "AWS/EC2" \
  --metric-name "CPUUtilization" \
  --dimensions Name=InstanceId,Value=$MON_INSTANCE_ID \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions $SNS_ARN \
  --ok-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32m  EC2-CPU-High created (Average CPU > 70% for 2x5min)\e[0m"

# ── ALARM 2: STATUS CHECK FAILED ──────────────────────────────────────────────
echo -e "\e[33m[2/3] Creating EC2-StatusCheck-Failed alarm...\e[0m"

aws cloudwatch put-metric-alarm \
  --alarm-name "EC2-StatusCheck-Failed" \
  --alarm-description "EC2 instance failed status check — hardware or OS issue" \
  --namespace "AWS/EC2" \
  --metric-name "StatusCheckFailed" \
  --dimensions Name=InstanceId,Value=$MON_INSTANCE_ID \
  --statistic Maximum \
  --period 60 \
  --evaluation-periods 2 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32m  EC2-StatusCheck-Failed created (Maximum >= 1 for 2x1min)\e[0m"

# ── ALARM 3: HIGH NETWORK IN ──────────────────────────────────────────────────
echo -e "\e[33m[3/3] Creating EC2-NetworkIn-High alarm...\e[0m"

aws cloudwatch put-metric-alarm \
  --alarm-name "EC2-NetworkIn-High" \
  --alarm-description "EC2 inbound network traffic unusually high — potential anomaly" \
  --namespace "AWS/EC2" \
  --metric-name "NetworkIn" \
  --dimensions Name=InstanceId,Value=$MON_INSTANCE_ID \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 5000000 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32m  EC2-NetworkIn-High created (Average > 5MB per 5min)\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying EC2 alarms...\e[0m"

aws cloudwatch describe-alarms \
  --alarm-names "EC2-CPU-High" "EC2-StatusCheck-Failed" "EC2-NetworkIn-High" \
  --query "MetricAlarms[*].{Name:AlarmName,State:StateValue,Metric:MetricName,Threshold:Threshold}" \
  --output table

echo ""
echo -e "\e[36m=== EC2 Alarms Complete ===\e[0m"
echo ""
echo "Expected states: INSUFFICIENT_DATA (until first metric data points arrive)"
echo "States transition to OK within 5-10 minutes of instance running."
echo ""
echo -e "\e[36mNext step: Run 04-create-rds-alarms.ps1\e[0m"