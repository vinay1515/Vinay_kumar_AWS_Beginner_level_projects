# Security Protocols

## 🔐 IAM Least Privilege Permissions

Monitoring and logging require specific, tightly-scoped IAM permissions. 

### EC2 CloudWatch Agent Role
If an EC2 instance needs to push custom metrics or logs (as simulated in this project), it must assume an IAM role with the `CloudWatchAgentServerPolicy` attached.
- **Allowed Actions:** `logs:CreateLogStream`, `logs:PutLogEvents`, `cloudwatch:PutMetricData`.

### SNS Access Policies
The Simple Notification Service (SNS) topic uses an access policy that strictly governs who can publish to it.
- In this architecture, we implicitly allow CloudWatch Alarms to publish to the SNS Topic via the `cloudwatch.amazonaws.com` service principal.

## 🛡️ Data Privacy Considerations

When creating **Metric Filters** to parse application logs:
- Ensure that logs ingested into CloudWatch do NOT contain sensitive Personally Identifiable Information (PII) or plaintext passwords, as metric filters expose patterns that might be visible to operators.
- Log retention is explicitly set to 7 days to minimize storage footprint and comply with data minimization principles.

