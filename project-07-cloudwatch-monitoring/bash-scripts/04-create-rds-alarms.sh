#!/bin/bash

# =============================================================================
# Project 7 — Script 04: RDS CloudWatch Alarms
# Creates CPU, storage, and connection alarms for myapp-database
# Note: Alarms stay INSUFFICIENT_DATA if RDS from Project 6 was deleted — this is normal
# =============================================================================

echo -e "\e[36m=== Project 7 — RDS CloudWatch Alarms ===\e[0m"
echo ""

if (-not $SNS_ARN) {
echo -e "\e[31mERROR: SNS_ARN not set. Run 01-sns-setup.ps1 first.\e[0m"
    exit 1
}

echo "Target RDS instance: myapp-database"
echo "SNS ARN: $SNS_ARN"
echo ""
echo "Note: Alarms will be INSUFFICIENT_DATA if myapp-database does not exist."
echo "This is expected if Project 6 was cleaned up. Alarms are still valid."
echo ""

# ── ALARM 4: RDS HIGH CPU ─────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Creating RDS-CPU-High alarm...\e[0m"

aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-CPU-High" \
  --alarm-description "RDS CPU utilization exceeded 80% for 10 minutes" \
  --namespace "AWS/RDS" \
  --metric-name "CPUUtilization" \
  --dimensions Name=DBInstanceIdentifier,Value=myapp-database \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions $SNS_ARN \
  --ok-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32m  RDS-CPU-High created (Average CPU > 80% for 2x5min)\e[0m"

# ── ALARM 5: RDS LOW FREE STORAGE ─────────────────────────────────────────────
echo -e "\e[33m[2/3] Creating RDS-Storage-Low alarm...\e[0m"

# Threshold: 2,000,000,000 bytes = ~2GB
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-Storage-Low" \
  --alarm-description "RDS free storage space below 2GB — action required before write failures" \
  --namespace "AWS/RDS" \
  --metric-name "FreeStorageSpace" \
  --dimensions Name=DBInstanceIdentifier,Value=myapp-database \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 2000000000 \
  --comparison-operator LessThanThreshold \
  --alarm-actions $SNS_ARN \
  --ok-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32m  RDS-Storage-Low created (FreeStorage < 2GB)\e[0m"

# ── ALARM 6: RDS HIGH CONNECTIONS ─────────────────────────────────────────────
echo -e "\e[33m[3/3] Creating RDS-Connections-High alarm...\e[0m"

# db.t3.micro max connections = 66; alert at 50 (76% of max)
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-Connections-High" \
  --alarm-description "RDS connection count exceeded 50 (db.t3.micro max: 66)" \
  --namespace "AWS/RDS" \
  --metric-name "DatabaseConnections" \
  --dimensions Name=DBInstanceIdentifier,Value=myapp-database \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 50 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32m  RDS-Connections-High created (DatabaseConnections > 50)\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying RDS alarms...\e[0m"

aws cloudwatch describe-alarms \
  --alarm-names "RDS-CPU-High" "RDS-Storage-Low" "RDS-Connections-High" \
  --query "MetricAlarms[*].{Name:AlarmName,State:StateValue,Metric:MetricName,Threshold:Threshold}" \
  --output table

echo ""
echo -e "\e[36m=== RDS Alarms Complete ===\e[0m"
echo ""
echo -e "\e[36mNext step: Run 05-create-billing-alarm.ps1\e[0m"