#!/bin/bash

# =============================================================================
# Project 6 — Script 08: CloudWatch Monitoring
# Queries RDS metrics for the last hour — CPU, connections, storage
# =============================================================================

echo -e "\e[36m=== Project 6 — CloudWatch RDS Monitoring ===\e[0m"
echo ""

START_TIME=(Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")
END_TIME=(Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
DB_ID="myapp-database"

echo "Query window: $START_TIME → $END_TIME"
echo "DB Instance:  $DB_ID"
echo ""

# ── CPU UTILIZATION ───────────────────────────────────────────────────────────
echo -e "\e[33m--- CPU Utilization (%) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name CPUUtilization \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,CPU_Percent:Average}" \
    --output table

# ── DATABASE CONNECTIONS ──────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Database Connections (count) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Connections:Average}" \
    --output table

# ── FREE STORAGE SPACE ────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Free Storage Space (bytes) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name FreeStorageSpace \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Free_Bytes:Average}" \
    --output table

# ── FREEABLE MEMORY ───────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Freeable Memory (bytes) ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name FreeableMemory \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Free_Bytes:Average}" \
    --output table

# ── READ IOPS ─────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Read IOPS ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name ReadIOPS \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Read_IOPS:Average}" \
    --output table

# ── WRITE IOPS ────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m--- Write IOPS ---\e[0m"
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name WriteIOPS \
    --dimensions Name=DBInstanceIdentifier, Value=$DB_ID \
    --start-time $START_TIME \
    --end-time $END_TIME \
    --period 300 \
    --statistics Average \
    --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp,Write_IOPS:Average}" \
    --output table

# ── CONSOLE SHORTCUT ──────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Monitoring Complete ===\e[0m"
echo ""
echo "Console path for visual graphs:"
echo "  RDS -> Databases -> myapp-database -> Monitoring tab"
echo ""
echo "Note: If datapoints are empty, the instance has been idle."
echo "Run a few queries via MySQL client to generate metrics."