# Security Protocols

This document outlines the security architecture, access controls, encryption standards, and compliance best practices for the CloudWatch Monitoring, Alarms & SNS Notifications infrastructure.

## 🔐 IAM & Access Control

### EC2 CloudWatch Agent Role
If an EC2 instance needs to push custom metrics or logs (as simulated in this project), it must assume an IAM role with the `CloudWatchAgentServerPolicy` attached.

**Required permissions:**
| Action | Service | Purpose |
|:---|:---|:---|
| `logs:CreateLogGroup` | CloudWatch Logs | Create new log groups |
| `logs:CreateLogStream` | CloudWatch Logs | Create log streams within groups |
| `logs:PutLogEvents` | CloudWatch Logs | Write log events to streams |
| `cloudwatch:PutMetricData` | CloudWatch | Publish custom metrics |
| `cloudwatch:GetMetricData` | CloudWatch | Read metrics for dashboard |
| `ssm:GetParameter` | Systems Manager | Retrieve CloudWatch agent config |

> [!IMPORTANT]
> **Never use `CloudWatchFullAccess`** in production. This managed policy grants `cloudwatch:*` and `logs:*` which includes destructive operations like `DeleteAlarms` and `DeleteLogGroup`. Always use `CloudWatchAgentServerPolicy` or a custom scoped policy.

### SNS Access Policies
The Simple Notification Service (SNS) topic uses an access policy that strictly governs who can publish to it.

**SNS Topic Policy:**
```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "cloudwatch.amazonaws.com"
  },
  "Action": "SNS:Publish",
  "Resource": "arn:aws:sns:ap-south-1:ACCOUNT_ID:monitoring-alerts",
  "Condition": {
    "ArnLike": {
      "aws:SourceArn": "arn:aws:cloudwatch:ap-south-1:ACCOUNT_ID:alarm:*"
    }
  }
}
```

This policy ensures that:
- Only CloudWatch Alarms can publish to the SNS topic
- Only alarms from your specific account and region can trigger notifications
- No external actors can send messages to your notification channel

### IAM Best Practices for Monitoring

| Principle | Implementation |
|:---|:---|
| **Least privilege** | EC2 role scoped to `logs:Put*` and `cloudwatch:PutMetricData` only |
| **Service principal restriction** | SNS topic policy restricts publishing to `cloudwatch.amazonaws.com` |
| **Resource-level permissions** | Log group ARN specified in IAM policy (not `*`) |
| **No hardcoded credentials** | EC2 instance profile provides temporary credentials automatically |

## 🛡️ Network Security

### CloudWatch Endpoints
CloudWatch, CloudWatch Logs, and SNS are all **regional AWS services** accessed via HTTPS endpoints:
- `monitoring.ap-south-1.amazonaws.com` (CloudWatch)
- `logs.ap-south-1.amazonaws.com` (CloudWatch Logs)
- `sns.ap-south-1.amazonaws.com` (SNS)

EC2 instances must have **outbound internet access** (or VPC endpoints) to reach these endpoints.

### VPC Endpoints (Production Recommendation)
For production workloads in private subnets, create Interface VPC Endpoints to avoid routing monitoring traffic through the public internet:

| Endpoint | Service |
|:---|:---|
| `com.amazonaws.ap-south-1.monitoring` | CloudWatch metrics |
| `com.amazonaws.ap-south-1.logs` | CloudWatch Logs |
| `com.amazonaws.ap-south-1.sns` | SNS notifications |

## 🔒 Encryption

### Data in Transit
- All API calls to CloudWatch, Logs, and SNS use **TLS 1.2+** (HTTPS)
- SNS email notifications are delivered over standard email protocols (not encrypted end-to-end)
- For sensitive alerts, use SNS → Lambda → encrypted delivery channel

### Data at Rest
- **CloudWatch Logs:** Encrypted by default with AWS-managed keys. For additional control, use a customer-managed KMS key:
  ```bash
  aws logs associate-kms-key \
    --log-group-name "/aws/ec2/monitoring-test" \
    --kms-key-id "arn:aws:kms:ap-south-1:ACCOUNT_ID:key/KEY_ID"
  ```
- **CloudWatch Metrics:** Stored in AWS-managed encrypted storage (not configurable)
- **SNS Messages:** Encrypted at rest using AWS-managed encryption. Enable SSE for additional protection:
  ```bash
  aws sns set-topic-attributes \
    --topic-arn "arn:aws:sns:ap-south-1:ACCOUNT_ID:monitoring-alerts" \
    --attribute-name KmsMasterKeyId \
    --attribute-value "alias/aws/sns"
  ```

## 🛡️ Data Privacy Considerations

When creating **Metric Filters** to parse application logs:
- Ensure that logs ingested into CloudWatch do **NOT** contain sensitive Personally Identifiable Information (PII) or plaintext passwords, as metric filters expose patterns that might be visible to operators
- Log retention is explicitly set to **7 days** to minimize storage footprint and comply with data minimization principles
- Use CloudWatch Logs data protection policies to automatically mask sensitive data patterns (SSN, credit cards, etc.)

## 📋 Compliance & Best Practices

### Alarm Hygiene
| Practice | Rationale |
|:---|:---|
| Use **evaluation periods ≥ 2** | Prevents false positives from momentary spikes |
| Set **actions for both ALARM and OK states** | Ensures operators know when issues resolve |
| Use **composite alarms** for complex conditions | Reduces alert noise from correlated issues |
| Tag all alarms with `Environment` and `Owner` | Enables filtering and ownership tracking |

### Log Retention Policy
| Log Group | Retention | Rationale |
|:---|:---|:---|
| `/aws/ec2/monitoring-test` | 7 days | Test environment — minimize costs |
| Production application logs | 30–90 days | Operational troubleshooting window |
| Security/audit logs | 365+ days | Compliance requirements |

### SNS Subscription Security
- **Always confirm email subscriptions** — unconfirmed subscriptions expire after 3 days
- **Do not publish to SNS topics with `*` principal** — restrict to specific service principals
- **Use subscription filter policies** to route specific alarm types to specific recipients

## 🚨 Incident Response

| Scenario | Indicator | Response |
|:---|:---|:---|
| Alarm fatigue | >50 notifications/day | Review thresholds; implement composite alarms |
| Missed alerts | SNS subscription unconfirmed | Re-subscribe and confirm; check spam filters |
| Log group cost spike | Unexpected log volume | Review log retention; check for noisy applications |
| Unauthorized dashboard access | CloudTrail `GetDashboard` events | Review IAM policies; restrict `cloudwatch:GetDashboard` |
