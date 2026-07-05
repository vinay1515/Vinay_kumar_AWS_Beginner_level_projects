#!/bin/bash
# List Lambda log groups
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/users-api" \
  --query "logGroups[*].{Name:logGroupName,Retention:retentionInDays}" \
  --output table

# Get latest log stream
LOG_STREAM=$(aws logs describe-log-streams \
  --log-group-name "/aws/lambda/users-api" \
  --order-by LastEventTime \
  --descending \
  --max-items 1 \
  --query "logStreams[0].logStreamName" \
  --output text)

# Read the latest logs
aws logs get-log-events \
  --log-group-name "/aws/lambda/users-api" \
  --log-stream-name "$LOG_STREAM" \
  --query "events[*].message" \
  --output text