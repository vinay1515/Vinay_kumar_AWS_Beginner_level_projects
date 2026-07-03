# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Website won't load (Connection Timed Out)** | Security Group / HTTPS | Ensure the SG allows inbound Port 80. Ensure you are navigating to `http://` and your browser didn't auto-upgrade to `https://`. |
| **PuTTY Connection Refused / Timed Out** | Security Group IP mismatch | Your ISP may have changed your public IP. Update the SG Port 22 rule to reflect your current IP address. |
| **Session Manager "Connect" button is greyed out** | IAM Role missing or booting | Ensure the `ec2-ssm-role` is attached. It can take 2-5 minutes after boot for the SSM Agent to register with the AWS API. |