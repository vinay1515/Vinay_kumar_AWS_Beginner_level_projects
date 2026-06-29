#!/bin/bash

# =============================================================================
# Project 7 — Script 05: Billing Alarm
# MUST run in us-east-1 — billing metrics are only in this region
# =============================================================================

echo -e "\e[36m=== Project 7 — Billing Alarm ===\e[0m"
echo ""
echo -e "\e[31mIMPORTANT: Billing metrics are only available in us-east-1\e[0m"
echo -e "\e[33mThis script forces us-east-1 regardless of your configured region.\e[0m"
echo ""

if (-not $SNS_ARN) {
echo -e "\e[31mERROR: SNS_ARN not set. Run 01-sns-setup.ps1 first.\e[0m"
    exit 1
}

# Force us-east-1 for billing metrics
$env:AWS_DEFAULT_REGION = "us-east-1"
echo -e "\e[32mRegion forced to: us-east-1\e[0m"
echo ""

# ── BILLING ALARM ─────────────────────────────────────────────────────────────
echo -e "\e[33mCreating Billing-Alert-5USD alarm...\e[0m"
echo "Threshold: EstimatedCharges > USD 5.00 (daily evaluation)"
echo ""

aws cloudwatch put-metric-alarm \
  --alarm-name "Billing-Alert-5USD" \
  --alarm-description "AWS monthly estimated charges exceeded USD 5 — check for unintended resources" \
  --namespace "AWS/Billing" \
  --metric-name "EstimatedCharges" \
  --dimensions Name=Currency,Value=USD \
  --statistic Maximum \
  --period 86400 \
  --evaluation-periods 1 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions $SNS_ARN \
  --treat-missing-data notBreaching \
  --region us-east-1

echo -e "\e[32mBilling-Alert-5USD created.\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying billing alarm (us-east-1)...\e[0m"

aws cloudwatch describe-alarms \
  --alarm-names "Billing-Alert-5USD" \
  --region us-east-1 \
  --query "MetricAlarms[0].{Name:AlarmName,State:StateValue,Threshold:Threshold,Namespace:Namespace}" \
  --output table

echo ""
echo -e "\e[36m=== Billing Alarm Complete ===\e[0m"
echo ""
echo "Note: Billing metrics update once per day."
echo "The alarm may show INSUFFICIENT_DATA until the next daily metric update."
echo ""
echo "Console path: CloudWatch (us-east-1) -> Alarms -> Billing-Alert-5USD"
echo ""
echo -e "\e[36mNext step: Run 06-generate-cpu-load.sh on the EC2 instance (via SSH)\e[0m"