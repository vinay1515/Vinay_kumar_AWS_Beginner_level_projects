#!/bin/bash

# ============================================================
# Project 8 - Part 7: Monitor with CloudWatch
# Description: View Lambda logs and metrics
# ============================================================

. "$PSScriptRoot\env.ps1"

echo -e "\e[36m========================================\e[0m"
echo -e "\e[36m  PART 7: MONITOR WITH CLOUDWATCH\e[0m"
echo -e "\e[36m========================================\e[0m"
echo ""

logGroupName="/aws/lambda/$LAMBDA_FUNCTION_NAME"

# ── 1. LIST LOG GROUPS ──────────────────────────────────────────
echo -e "\e[33m[1/6] Lambda Log Groups:\e[0m"
logGroups=$(aws logs describe-log-groups \
    --log-group-name-prefix "/aws/lambda/$LAMBDA_FUNCTION_NAME" \
    --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays,StoredBytes:storedBytes,CreationTime:creationTime}" \
    --output table)

if (-not $logGroups) {
echo -e "\e[33m  ⚠ No log groups found. Wait a few minutes after invoking Lambda.\e[0m"
}

# ── 2. GET LATEST LOG STREAM ────────────────────────────────────
echo -e "\e[33m[2/6] Getting latest log stream...\e[0m"
logStreams=$(aws logs describe-log-streams \
    --log-group-name $logGroupName \
    --order-by LastEventTime \
    --descending \
    --max-items 5 \
    --query "logStreams[*].{Name:logStreamName,LastEvent:lastEventTimestamp,FirstEvent:firstEventTimestamp}" \
    --output table)

if ($logStreams) {
    # Get the most recent log stream name
    latestStream=$(aws logs describe-log-streams \
        --log-group-name $logGroupName \
        --order-by LastEventTime \
        --descending \
        --max-items 1 \
        --query "logStreams[0].logStreamName" \
        --output text)
    
echo -e "\e[32m  ✓ Latest stream: $latestStream\e[0m"
}

# ── 3. VIEW RECENT LOGS ─────────────────────────────────────────
echo -e "\e[33m[3/6] Recent Log Events:\e[0m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ($latestStream) {
    logEvents=$(aws logs get-log-events \
        --log-group-name $logGroupName \
        --log-stream-name $latestStream \
        --limit 50 \
        --query "events[*].{Timestamp:timestamp,Message:message}" \
        --output json | jq .)
    
    if ($logEvents) {
        $logEvents | ForEach-Object {
            time=[DateTime]::new(1970, 1, 1, 0, 0, 0, 0).AddMilliseconds($_.Timestamp).ToString("HH:mm:ss")
echo "[$time]"
echo -e "\e[97m $($_.Message)\e[0m"
        }
    } else {
echo -e "\e[90m  No log events found\e[0m"
    }
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 4. INVOCATION METRICS ───────────────────────────────────────
echo -e "\e[33m[4/6] Lambda Invocation Metrics (Last Hour):\e[0m"

startTime=(Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")
endTime=(Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Invocations
invocations=$(aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Invocations \
    --dimensions Name=FunctionName,Value=$LAMBDA_FUNCTION_NAME \
    --start-time $startTime \
    --end-time $endTime \
    --period 300 \
    --statistics Sum \
    --query "Datapoints[*].{Time:Timestamp,Count:Sum}" \
    --output table)

echo -e "\e[90m  Invocations:\e[0m"
echo ""

# Errors
echo -e "\e[33m[5/6] Lambda Error Metrics (Last Hour):\e[0m"

errors=$(aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Errors \
    --dimensions Name=FunctionName,Value=$LAMBDA_FUNCTION_NAME \
    --start-time $startTime \
    --end-time $endTime \
    --period 300 \
    --statistics Sum \
    --query "Datapoints[*].{Time:Timestamp,Count:Sum}" \
    --output table)

echo -e "\e[90m  Errors:\e[0m"
echo ""

# Duration
echo -e "\e[33m[6/6] Lambda Duration Metrics (Last Hour):\e[0m"

duration=$(aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Duration \
    --dimensions Name=FunctionName,Value=$LAMBDA_FUNCTION_NAME \
    --start-time $startTime \
    --end-time $endTime \
    --period 300 \
    --statistics Average \
    --query "Datapoints[*].{Time:Timestamp,AvgDuration:Average}" \
    --output table)

echo -e "\e[90m  Duration (ms):\e[0m"
echo ""

# ── 7. API GATEWAY METRICS ──────────────────────────────────────
if ($API_ID) {
echo ""
echo -e "\e[33mAPI Gateway Metrics (Last Hour):\e[0m"
    
    # Count
    aws cloudwatch get-metric-statistics \
        --namespace AWS/ApiGateway \
        --metric-name Count \
        --dimensions Name=ApiName,Value=$API_NAME \
        --start-time $startTime \
        --end-time $endTime \
        --period 3600 \
        --statistics Sum \
        --query "Datapoints[0].Sum" \
        --output table
    
    # Latency
    aws cloudwatch get-metric-statistics \
        --namespace AWS/ApiGateway \
        --metric-name Latency \
        --dimensions Name=ApiName,Value=$API_NAME \
        --start-time $startTime \
        --end-time $endTime \
        --period 3600 \
        --statistics Average \
        --query "Datapoints[0].{AvgLatency:Average,Unit:Unit}" \
        --output table
}

# ── 8. DYNAMODB METRICS ─────────────────────────────────────────
echo -e "\e[33mDynamoDB Metrics (Last Hour):\e[0m"

aws cloudwatch get-metric-statistics \
    --namespace AWS/DynamoDB \
    --metric-name ConsumedReadCapacityUnits \
    --dimensions Name=TableName,Value=$TABLE_NAME \
    --start-time $startTime \
    --end-time $endTime \
    --period 3600 \
    --statistics Sum \
    --query "Datapoints[0].Sum" \
    --output table 2>/dev/null

echo ""

# ── SUMMARY ──────────────────────────────────────────────────────
echo -e "\e[36m========================================\e[0m"
echo -e "\e[36m  MONITORING SUMMARY\e[0m"
echo -e "\e[36m========================================\e[0m"
echo ""
echo -e "\e[97m  Log Group: $logGroupName\e[0m"
echo -e "\e[97m  Dashboard: https://console.aws.amazon.com/cloudwatch\e[0m"
echo ""
echo -e "\e[33mKey Links:\e[0m"
echo -e "\e[90m  • Lambda Console: https://console.aws.amazon.com/lambda/home?region=$REGION#/functions/$LAMBDA_FUNCTION_NAME\e[0m"
echo -e "\e[90m  • API Gateway: https://console.aws.amazon.com/apigateway/home?region=$REGION#/apis/$API_ID/resources\e[0m"
echo -e "\e[90m  • DynamoDB: https://console.aws.amazon.com/dynamodb/home?region=$REGION#tables:selected=$TABLE_NAME\e[0m"
echo -e "\e[90m  • CloudWatch: https://console.aws.amazon.com/cloudwatch/home?region=$REGION\e[0m"
echo ""