#!/bin/bash

# =============================================================================
# Project 7 — Script 11: Verify All Alarms and Metrics
# Lists all alarms, queries metric data, and checks alarm history
# =============================================================================

echo -e "\e[36m=== Project 7 — Alarm Verification ===\e[0m"
echo ""

START_TIME=(Get-Date).AddHours(-2).ToString("yyyy-MM-ddTHH:mm:ssZ")
END_TIME=(Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

# ── ALL ALARMS OVERVIEW ───────────────────────────────────────────────────────
echo -e "\e[33m--- All Alarms (current state) ---\e[0m"
aws cloudwatch describe-alarms \
  --query "MetricAlarms[*].{Name:AlarmName,State:StateValue,Metric:MetricName,Threshold:Threshold,Namespace:Namespace}" \
  --output table

# ── ALARM COUNTS BY STATE ─────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Alarm State Summary ---\e[0m"
ALARMS=$(aws cloudwatch describe-alarms \
  --query "MetricAlarms[*].StateValue" --output text)

OK_COUNT=$(ALARMS  | Where-Object {$_ -eq "OK"}).Count
ALARM_COUNT=$(ALARMS  | Where-Object {$_ -eq "ALARM"}).Count
INSUFF=$(ALARMS  | Where-Object {$_ -eq "INSUFFICIENT_DATA"}).Count

echo "  OK:                 $OK_COUNT"
echo "  ALARM:              $ALARM_COUNT"
echo "  INSUFFICIENT_DATA:  $INSUFF"

# ── EC2 CPU METRIC DATA ───────────────────────────────────────────────────────
if ($MON_INSTANCE_ID) {
echo ""
echo -e "\e[33m--- EC2 CPU Utilization (last 2 hours) ---\e[0m"
    aws cloudwatch get-metric-statistics \
      --namespace AWS/EC2 \
      --metric-name CPUUtilization \
      --dimensions Name=InstanceId,Value=$MON_INSTANCE_ID \
      --start-time $START_TIME \
      --end-time $END_TIME \
      --period 300 \
      --statistics Average Maximum \
      --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Avg:Average,Max:Maximum}" \
      --output table
}

# ── EC2-CPU-HIGH ALARM HISTORY ────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- EC2-CPU-High Alarm History ---\e[0m"
aws cloudwatch describe-alarm-history \
  --alarm-name "EC2-CPU-High" \
  --query "AlarmHistoryItems[*].{Time:Timestamp,Type:HistoryItemType,Summary:HistorySummary}" \
  --output table

# ── APP-ERRORS-HIGH ALARM HISTORY ────────────────────────────────────────────
echo ""
echo -e "\e[33m--- App-Errors-High Alarm History ---\e[0m"
aws cloudwatch describe-alarm-history \
  --alarm-name "App-Errors-High" \
  --query "AlarmHistoryItems[*].{Time:Timestamp,Type:HistoryItemType,Summary:HistorySummary}" \
  --output table

# ── CUSTOM METRIC DATA ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- ApplicationErrors Custom Metric (last 2 hours) ---\e[0m"
aws cloudwatch get-metric-statistics \
  --namespace CustomMetrics \
  --metric-name ApplicationErrors \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --period 300 \
  --statistics Sum \
  --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Errors:Sum}" \
  --output table

# ── SNS TOPIC STATUS ──────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- SNS Subscription Status ---\e[0m"
if ($SNS_ARN) {
    aws sns list-subscriptions-by-topic \
      --topic-arn $SNS_ARN \
      --query "Subscriptions[*].{Protocol:Protocol,Endpoint:Endpoint,Status:SubscriptionArn}" \
      --output table
} else {
echo "SNS_ARN not set — skipping."
}

# ── DASHBOARD STATUS ──────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Dashboard Status ---\e[0m"
aws cloudwatch list-dashboards \
  --query "DashboardEntries[*].{Name:DashboardName,Modified:LastModified}" \
  --output table

echo ""
echo -e "\e[36m=== Verification Complete ===\e[0m"
echo ""
echo "Expected states after full project build:"
echo "  EC2-CPU-High             OK (or ALARM if stress test ran recently)"
echo "  EC2-StatusCheck-Failed   OK"
echo "  EC2-NetworkIn-High       OK"
echo "  RDS-CPU-High             INSUFFICIENT_DATA (no RDS)"
echo "  RDS-Storage-Low          INSUFFICIENT_DATA (no RDS)"
echo "  RDS-Connections-High     INSUFFICIENT_DATA (no RDS)"
echo "  Billing-Alert-5USD       OK"
echo "  App-Errors-High          ALARM (after test log events pushed)"