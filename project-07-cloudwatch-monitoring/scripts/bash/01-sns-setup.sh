#!/bin/bash

# =============================================================================
# Project 7 — Script 01: SNS Topic and Email Subscription
# Creates the notification hub — all alarms route through this topic
# =============================================================================

echo -e "\e[36m=== Project 7 — SNS Setup ===\e[0m"
echo ""

# Pre-flight
aws sts get-caller-identity | Out-Null
if ($LASTEXITCODE -ne 0) {
echo -e "\e[31mERROR: AWS CLI not configured.\e[0m"
    exit 1
}

REGION=$(aws configure get region)
echo "Region: $REGION"
echo ""

# ── CREATE SNS TOPIC ──────────────────────────────────────────────────────────
echo -e "\e[33m[1/3] Creating SNS topic: monitoring-alerts...\e[0m"

SNS_ARN=$(aws sns create-topic \
    --name monitoring-alerts \
    --attributes DisplayName="AWS Monitoring" \
    --query "TopicArn" --output text)

echo -e "\e[32mSNS Topic ARN: $SNS_ARN\e[0m"

# ── CREATE EMAIL SUBSCRIPTION ─────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/3] Creating email subscription...\e[0m"
echo "Update the email address below before running this script."
echo ""

# ⚠️ Replace this with your actual email address
EMAIL="your-email@gmail.com"

aws sns subscribe \
    --topic-arn $SNS_ARN \
    --protocol email \
    --notification-endpoint $EMAIL | Out-Null

echo -e "\e[32mSubscription created for: $EMAIL\e[0m"
echo ""
echo -e "\e[31mIMPORTANT: Check your inbox and click 'Confirm subscription\e[0m"
echo -e "\e[33mCheck spam/junk folder if not received within 2 minutes.\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/3] Verifying subscription status...\e[0m"

aws sns list-subscriptions-by-topic \
    --topic-arn $SNS_ARN \
    --query "Subscriptions[*].{Protocol:Protocol,Endpoint:Endpoint,Status:SubscriptionArn}" \
    --output table

echo ""
echo -e "\e[36m=== SNS Setup Complete ===\e[0m"
echo ""
echo "  SNS_ARN = $SNS_ARN"
echo ""
echo "Status will show 'PendingConfirmation' until you click the email link."
echo "Alarms cannot send email until the subscription is confirmed."
echo ""
echo -e "\e[36mNext step: Run 02-launch-monitoring-ec2.ps1\e[0m"