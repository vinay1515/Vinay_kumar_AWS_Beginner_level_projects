# Troubleshooting Guide

Use this reference to resolve common issues encountered during the deployment of Project 07.

## 🚨 Common Issues & Resolutions

### Issue 1: Alarm stays in `INSUFFICIENT_DATA` state
- **Cause:** CloudWatch hasn't received enough data points yet to evaluate the metric, or the resource doesn't exist.
- **Fix:** Wait 5–10 minutes after launching an EC2 instance. For RDS alarms, this is completely normal if you deleted your RDS instance at the end of Project 6 (the alarms will remain in `INSUFFICIENT_DATA` until a database named `myapp-database` is recreated).

### Issue 2: SNS Email not received
- **Cause:** The email subscription was never confirmed.
- **Fix:** SNS requires explicit opt-in. Check your spam/junk folder for an email from "AWS Notifications" and click the **Confirm subscription** link. Verify the status in the SNS console.

### Issue 3: Billing alarm is not visible in the Console
- **Cause:** Billing metrics are processed exclusively in the `us-east-1` (N. Virginia) region.
- **Fix:** Use the region drop-down in the top right of the AWS Management Console to switch to `us-east-1`. Your `Billing-Alert-5USD` alarm will be there.

### Issue 4: CPU stress test is not triggering the alarm
- **Cause:** The `EC2-CPU-High` alarm requires TWO consecutive 5-minute periods of >70% utilization.
- **Fix:** Ensure you run the `stress` command for at least 10-12 minutes (`--timeout 720`). If you stop it early, the average utilization for the period will drop below the threshold and the alarm will reset to `OK`.

### Issue 5: Dashboard shows no data / blank charts
- **Cause:** The instance ID hardcoded in the dashboard widget does not match your currently running instance.
- **Fix:** Hover over the widget, click **Edit**, navigate to the metric selection, uncheck the dead instance ID, and check your new instance ID.

### Issue 6: Log metric filter is not counting errors
- **Cause:** Metric filter patterns are strictly case-sensitive.
- **Fix:** Ensure the log events being pushed contain the exact uppercase string `ERROR`. `error` or `Error` will not match the pattern.
