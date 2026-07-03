# Deployment Guide

## Step 1: Create SNS Topic
1. Navigate to Amazon SNS > Topics. Create a Standard topic.
2. Create a Subscription. Protocol: Email. Enter your email address.
3. Check your email and click the confirmation link.

## Step 2: Create Alarms
1. Navigate to CloudWatch > Alarms.
2. **EC2 CPU Alarm:** Select `EC2 > Per-Instance Metrics > CPUUtilization`. Set threshold to > 70% for 2 evaluation periods. Action: Send to SNS topic.
3. **Billing Alarm:** Select `Billing > Total Estimated Charge`. Set threshold to > $5. Action: Send to SNS topic. *(Note: Must be created in the `us-east-1` region).*

## Step 3: Create Dashboard
1. Navigate to CloudWatch > Dashboards. Create Dashboard.
2. Add a Line widget for EC2 CPU Utilization.
3. Add a Number widget for Total Estimated Charges.
4. Save the dashboard.
