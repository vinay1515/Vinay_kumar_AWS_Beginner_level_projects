# Security Protocols

- **SNS Access Policies:** By default, only the topic owner can publish to the SNS topic. When creating an alarm, CloudWatch modifies the resource policy of the SNS topic to allow the `cloudwatch.amazonaws.com` service principal to publish messages to it securely.
- **Monitoring for Security:** By creating alarms for metric filters on CloudWatch Logs (e.g. searching for "Authentication Failed"), you can use this exact architecture as a real-time security intrusion detection system.