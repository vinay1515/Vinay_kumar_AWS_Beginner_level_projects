# Testing Procedures & Validation

This document outlines how to actively test and trigger the monitoring systems built in this project.

## 🧪 1. Triggering the EC2 CPU Alarm

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

## 🧪 2. Triggering the Log Metric Filter Alarm

We can simulate application errors by pushing mock log events directly into our CloudWatch Log Group.

1. Execute the mock log injection script (`10-test-log-events.ps1` or `bash` equivalent).
2. The script pushes 5 `ERROR` log messages into the `/aws/ec2/monitoring-test` log group with distinct timestamps.
3. The Metric Filter parses these logs and increments the `ApplicationErrors` metric to 5.
4. The `App-Errors-High` alarm immediately triggers because it evaluates on a 1-period (5-minute) sum.
5. Verify receipt of the second SNS alert.

## 🧪 3. Validating the Dashboard

Open the CloudWatch Dashboard `AWS-Bootcamp-Dashboard`.
- Confirm all 6 widgets are rendering data.
- Ensure the Alarm Status widget reflects the newly triggered ALARM states from your stress tests.

