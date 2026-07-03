#!/bin/bash
# Automates the creation of a billing alarm

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <email_address> [threshold_in_usd]"
  exit 1
fi

EMAIL=$1
THRESHOLD=${2:-5}
REGION="us-east-1"
TOPIC_NAME="billing-alert-topic"
ALARM_NAME="Monthly-Billing-Alert-${THRESHOLD}USD"

echo "Creating SNS Topic: $TOPIC_NAME..."
TOPIC_ARN=$(aws sns create-topic --name $TOPIC_NAME --region $REGION --query "TopicArn" --output text)

echo "Subscribing $EMAIL to $TOPIC_ARN..."
aws sns subscribe --topic-arn $TOPIC_ARN --protocol email --notification-endpoint $EMAIL --region $REGION

echo "Creating CloudWatch Billing Alarm for > \$$THRESHOLD..."
aws cloudwatch put-metric-alarm \
    --alarm-name "$ALARM_NAME" \
    --alarm-description "Alarm when AWS spending exceeds \$$THRESHOLD" \
    --metric-name "EstimatedCharges" \
    --namespace "AWS/Billing" \
    --statistic "Maximum" \
    --period 21600 \
    --evaluation-periods 1 \
    --threshold $THRESHOLD \
    --comparison-operator "GreaterThanThreshold" \
    --dimensions "Name=Currency,Value=USD" \
    --alarm-actions $TOPIC_ARN \
    --region $REGION

echo -e "\n--- Setup Complete ---"
echo "CloudWatch alarm '$ALARM_NAME' created."
echo "IMPORTANT: Please check your email ($EMAIL) and click the link to confirm the SNS subscription."
