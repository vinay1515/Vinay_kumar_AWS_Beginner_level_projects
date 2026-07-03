# Cleanup Guide

To avoid exceeding the Free Tier limits for Alarms and Dashboards (10 alarms, 3 dashboards free):

1. **Delete Dashboards:** Navigate to CloudWatch > Dashboards. Select your dashboard and delete it.
2. **Delete Alarms:** Navigate to CloudWatch > Alarms. Select all custom alarms and delete them.
3. **Delete SNS Topic:** Navigate to Amazon SNS > Topics. Select your topic and delete it (this automatically deletes the subscriptions).