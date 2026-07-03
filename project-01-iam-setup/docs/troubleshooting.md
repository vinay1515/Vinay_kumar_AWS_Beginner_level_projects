# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **`aws: command not found`** | AWS CLI is not installed or not in PATH | Download the AWS CLI v2 installer for your OS and restart your terminal. |
| **`AccessDenied` on `sts get-caller-identity`** | Incorrect Access Keys | Re-run `aws configure` and carefully paste the correct keys. |
| **Cannot find Billing Metrics in CloudWatch** | Wrong region | Billing metrics are global but only show up in the `us-east-1` (N. Virginia) CloudWatch dashboard. Switch regions in the top right. |