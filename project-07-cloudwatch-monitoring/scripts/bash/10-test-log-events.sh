#!/bin/bash

# =============================================================================
# Project 7 — Script 10: Push Test Log Events
# Simulates application logs with INFO and ERROR lines to trigger metric filter
# =============================================================================

echo -e "\e[36m=== Project 7 — Push Test Log Events ===\e[0m"
echo ""
echo "Pushing 8 log events (3 INFO + 5 ERROR) to simulate an error spike."
echo "The metric filter will count the 5 ERROR lines."
echo "App-Errors-High alarm threshold is > 5, so this tests near-threshold."
echo ""
echo "To guarantee the alarm fires: add more ERROR lines or lower threshold to >= 5."
echo ""

LOG_GROUP="/aws/ec2/monitoring-test"
LOG_STREAM="app-server-1"

# Timestamps in milliseconds — each event 1 second apart
BASE_TIME=[int64](Get-Date -UFormat %s) * 1000

# ── PUSH LOG EVENTS ───────────────────────────────────────────────────────────
echo -e "\e[33mPushing log events to: $LOG_GROUP / $LOG_STREAM\e[0m"
echo ""

aws logs put-log-events \
    --log-group-name $LOG_GROUP \
    --log-stream-name $LOG_STREAM \
    --log-events \
    "timestamp=$($BASE_TIME),message=\"INFO: Application started successfully\"" \
    "timestamp=$($BASE_TIME+1000),message=\"INFO: User login successful - user_id=1042\"" \
    "timestamp=$($BASE_TIME+2000),message=\"ERROR: Database connection timeout after 30s - host=rds-endpoint\"" \
    "timestamp=$($BASE_TIME+3000),message=\"ERROR: Failed to process payment - transaction_id=TXN9981\"" \
    "timestamp=$($BASE_TIME+4000),message=\"ERROR: Null pointer exception in OrderService.processOrder()\"" \
    "timestamp=$($BASE_TIME+5000),message=\"ERROR: Authentication service unavailable - retrying\"" \
    "timestamp=$($BASE_TIME+6000),message=\"ERROR: Rate limit exceeded - IP=203.0.113.45\"" \
    "timestamp=$($BASE_TIME+7000),message=\"INFO: Retry attempt 1 of 3 - backoff 2s\""

echo -e "\e[32mLog events pushed successfully.\e[0m"
echo ""
echo "Events sent:"
echo "  INFO:  Application started successfully"
echo "  INFO:  User login successful"
echo "  ERROR: Database connection timeout"
echo "  ERROR: Failed to process payment"
echo "  ERROR: Null pointer exception"
echo "  ERROR: Authentication service unavailable"
echo "  ERROR: Rate limit exceeded"
echo "  INFO:  Retry attempt 1 of 3"
echo ""
echo -e "\e[33mMetric filter will count: 5 ERROR events\e[0m"
echo ""

# Push 2 more ERROR events to guarantee alarm fires (total = 7 > threshold of 5)
echo -e "\e[33mPushing 2 additional ERROR events to guarantee alarm threshold breach (7 > 5)...\e[0m"

BASE_TIME2=$BASE_TIME + 10000

aws logs put-log-events \
    --log-group-name $LOG_GROUP \
    --log-stream-name $LOG_STREAM \
    --log-events \
    "timestamp=$($BASE_TIME2),message=\"ERROR: Memory allocation failed - heap exhausted\"" \
    "timestamp=$($BASE_TIME2+1000),message=\"ERROR: Disk I/O error on /var/app/data\""

echo -e "\e[32mAdditional ERROR events pushed. Total: 7 ERROR events\e[0m"
echo ""
echo -e "\e[36m=== Log Events Complete ===\e[0m"
echo ""
echo "Wait 5 minutes for the App-Errors-High alarm to evaluate."
echo "Check alarm state:"
echo "  aws cloudwatch describe-alarms --alarm-names App-Errors-High --query "
echo ""
echo "Console path: CloudWatch -> Alarms -> App-Errors-High"
echo ""
echo -e "\e[36mNext step: Run 11-verify-alarms.ps1\e[0m"