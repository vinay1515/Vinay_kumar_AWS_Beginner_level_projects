# Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| MFA QR code won't scan | Screen glare or app issue | Try Authy instead of Google Authenticator; zoom into the QR |
| Billing metrics not showing | Wrong region | Switch CloudWatch to us-east-1 — billing metrics only exist there |
| `aws configure` not found | CLI not installed or PATH issue | Restart PowerShell after installing; or run from a new terminal window |
| InvalidClientTokenId error | Wrong Access Key ID | Re-check the .csv; make sure no extra spaces when pasting |
| SNS email not received | Check spam/junk folder | Also verify the email matches exactly what you entered. |