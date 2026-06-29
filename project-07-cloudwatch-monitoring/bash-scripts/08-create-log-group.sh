#!/bin/bash

# =============================================================================
# Project 7 — Script 08: CloudWatch Log Group
# Creates log group with 7-day retention policy
# =============================================================================

echo -e "\e[36m=== Project 7 — CloudWatch Log Group ===\e[0m"
echo ""

LOG_GROUP="/aws/ec2/monitoring-test"

echo -e "\e[33m[1/3] Creating log group: $LOG_GROUP...\e[0m"

aws logs create-log-group \
  --log-group-name $LOG_GROUP

if ($LASTEXITCODE -eq 0) {
echo -e "\e[32mLog group created.\e[0m"
} else {
echo -e "\e[33mLog group may already exist — continuing.\e[0m"
}

# ── SET RETENTION ─────────────────────────────────────────────────────────────
echo -e "\e[33m[2/3] Setting 7-day retention policy...\e[0m"

aws logs put-retention-policy \
  --log-group-name $LOG_GROUP \
  --retention-in-days 7

echo -e "\e[32mRetention set to 7 days.\e[0m"

# ── CREATE LOG STREAM ─────────────────────────────────────────────────────────
echo -e "\e[33m[3/3] Creating log stream: app-server-1...\e[0m"

aws logs create-log-stream \
  --log-group-name $LOG_GROUP \
  --log-stream-name "app-server-1"

echo -e "\e[32mLog stream created.\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying log group...\e[0m"

aws logs describe-log-groups \
  --log-group-name-prefix "/aws/ec2" \
  --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays,StoredBytes:storedBytes}" \
  --output table

echo ""
echo -e "\e[36m=== Log Group Complete ===\e[0m"
echo ""
echo "  Log Group:   $LOG_GROUP"
echo "  Log Stream:  app-server-1"
echo "  Retention:   7 days"
echo ""
echo -e "\e[36mNext step: Run 09-create-metric-filter.ps1\e[0m"