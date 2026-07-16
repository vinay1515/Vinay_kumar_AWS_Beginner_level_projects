# Testing Procedures & Validation

This document outlines how to actively test and trigger the monitoring systems built in this project, verifying that alarms transition correctly and notifications are delivered.

## 🧪 1. Triggering the EC2 CPU Alarm (Functional Test)

To prove the alarm works, we must force the EC2 instance's CPU utilization above the 70% threshold for at least 10 minutes (two 5-minute evaluation periods).

1. SSH into the `monitoring-test` instance:
   ```bash
   ssh -i your-key.pem ec2-user@<instance-public-ip>
   ```
2. Install and run the `stress` utility:
   ```bash
   sudo yum install -y stress
   sudo stress --cpu 1 --timeout 600
   ```
3. Watch the `EC2-CPU-High` alarm state in the CloudWatch Console transition from `OK` → `ALARM`.
4. Verify receipt of the SNS alert in your email inbox.

## 🧪 2. Triggering the Log Metric Filter Alarm (Integration Test)

We can simulate application errors by pushing mock log events directly into our CloudWatch Log Group using the provided scripts.

1. Execute the mock log injection script:
   ```bash
   ./scripts/bash/10-test-log-events.sh
   # OR
   .\scripts\powershell\10-test-log-events.ps1
   ```
2. The script pushes 5 `ERROR` log messages into the `/aws/ec2/monitoring-test` log group with distinct timestamps.
3. The Metric Filter parses these logs and increments the `ApplicationErrors` metric to 5.
4. The `App-Errors-High` alarm immediately triggers because it evaluates on a 1-period (5-minute) sum.
5. Verify receipt of the second SNS alert in your email.

## 🧪 3. Validating the Dashboard

Open the CloudWatch Dashboard `AWS-Bootcamp-Dashboard`.
- Confirm all 6 widgets are rendering data
- Ensure the Alarm Status widget reflects the newly triggered ALARM states from your stress tests
- Check the `ApplicationErrors` custom metric graph for the spike you generated

## ✅ Verification Commands

Use the following CLI commands to programmatically verify the state of your monitoring infrastructure during and after testing:

| Component | Verification Command | Expected Result |
|:---|:---|:---|
| **SNS Topic** | `aws sns list-subscriptions-by-topic --topic-arn <YOUR_TOPIC_ARN>` | Should show your email with `SubscriptionArn` (not `PendingConfirmation`) |
| **Alarms** | `aws cloudwatch describe-alarms --state-value ALARM --query "MetricAlarms[].AlarmName"` | Should list `EC2-CPU-High` and `App-Errors-High` during tests |
| **Log Group** | `aws logs describe-log-streams --log-group-name "/aws/ec2/monitoring-test"` | Should show a log stream created by your test script |
| **Metrics** | `aws cloudwatch list-metrics --namespace "CustomMetrics"` | Should list the `ApplicationErrors` metric |

## 📸 Expected Results

During testing, you should receive SNS email notifications that look like this:

```text
You are receiving this email because your Amazon CloudWatch Alarm "EC2-CPU-High" in the ap-south-1 region has entered the ALARM state, because "Threshold Crossed: 2 out of the last 2 datapoints [75.5, 99.8] were greater than the threshold (70.0)" at "Thursday 14 March, 2024 14:30:00 UTC".
```
