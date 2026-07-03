# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **No Email Received** | Unconfirmed Subscription | You must click the confirmation link in the initial email AWS sends when you create the subscription, otherwise SNS will silently drop messages. |
| **Alarm stuck in INSUFFICIENT_DATA** | Instance Off / Wrong ID | Ensure the instance is running. Ensure you selected the exact Instance ID when creating the alarm. |
| **Can't find Billing Metrics** | Region | Billing metrics are *only* available in the `us-east-1` (N. Virginia) region in the CloudWatch console. |