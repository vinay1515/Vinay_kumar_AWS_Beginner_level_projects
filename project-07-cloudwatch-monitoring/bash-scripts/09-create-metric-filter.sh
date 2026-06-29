#!/bin/bash

# =============================================================================
# Project 7 — Script 09: Metric Filter + Custom Alarm
# Creates a metric filter that counts ERROR log lines, then alarms on it
# =============================================================================

echo -e "\e[36m=== Project 7 — Metric Filter and Custom Alarm ===\e[0m"
echo ""

if (-not $SNS_ARN) {
echo -e "\e[31mERROR: SNS_ARN not set. Run 01-sns-setup.ps1 first.\e[0m"
    exit 1
}

LOG_GROUP="/aws/ec2/monitoring-test"

# ── CREATE METRIC FILTER ──────────────────────────────────────────────────────
echo -e "\e[33m[1/2] Creating metric filter 'ErrorCount'...\e[0m"
echo "  Pattern:          ERROR (case-sensitive)"
echo "  Metric namespace: CustomMetrics"
echo "  Metric name:      ApplicationErrors"
echo "  On match:         increment by 1"
echo "  Default value:    0 (prevents INSUFFICIENT_DATA gaps)"
echo ""

aws logs put-metric-filter \
  --log-group-name $LOG_GROUP \
  --filter-name "ErrorCount" \
  --filter-pattern "ERROR" \
  --metric-transformations \
    metricName=ApplicationErrors,metricNamespace=CustomMetrics,metricValue=1,defaultValue=0

echo -e "\e[32mMetric filter created.\e[0m"

# ── CREATE ALARM ON CUSTOM METRIC ─────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/2] Creating App-Errors-High alarm on CustomMetrics/ApplicationErrors...\e[0m"

aws cloudwatch put-metric-alarm \
  --alarm-name "App-Errors-High" \
  --alarm-description "Application error rate exceeded 5 errors in a 5-minute window" \
  --namespace "CustomMetrics" \
  --metric-name "ApplicationErrors" \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions $SNS_ARN \
  --treat-missing-data notBreaching

echo -e "\e[32mApp-Errors-High alarm created.\e[0m"

# ── VERIFY FILTER ─────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying metric filter...\e[0m"

aws logs describe-metric-filters \
  --log-group-name $LOG_GROUP \
  --query "metricFilters[*].{Name:filterName,Pattern:filterPattern,Metric:metricTransformations[0].metricName}" \
  --output table

echo ""
echo -e "\e[36m=== Metric Filter and Alarm Complete ===\e[0m"
echo ""
echo "Pipeline:"
echo "  Log Group (/aws/ec2/monitoring-test)"
echo "    -> Metric Filter (ErrorCount, pattern: 'ERROR')"
echo "    -> Custom Metric (CustomMetrics/ApplicationErrors)"
echo "    -> Alarm (App-Errors-High, threshold: Sum > 5 per 5min)"
echo "    -> SNS -> Email"
echo ""
echo -e "\e[36mNext step: Run 10-test-log-events.ps1 to push test ERROR log lines\e[0m"