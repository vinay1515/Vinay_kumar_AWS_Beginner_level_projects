
<div align="center">
  <svg width="800" height="150" xmlns="http://www.w3.org/2000/svg">
    <style>
      .bg { fill: url(#grad); stroke: #e1e4e8; stroke-width: 2px; rx: 12px; }
      .title { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 28px; font-weight: 800; fill: #ffffff; }
      .subtitle { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 500; fill: #e1e4e8; }
      .glow { animation: pulse 3s infinite alternate; }
      @keyframes pulse {
        0% { opacity: 0.8; filter: drop-shadow(0 0 4px rgba(255,153,0,0.4)); }
        100% { opacity: 1; filter: drop-shadow(0 0 12px rgba(255,153,0,0.9)); }
      }
      @media (prefers-color-scheme: dark) {
        .bg { stroke: #30363d; }
      }
    </style>
    <defs>
      <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#232f3e;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#ff9900;stop-opacity:1" />
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" class="bg" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">CloudWatch & SNS Alerts</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">cloudwatch-alarms.md</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Rds Ec2</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-08-serverless-rest-api/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Serverless Rest Api</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

All 8 alarms created in this project, with full configuration details.

---

## Alarm 1 — EC2-CPU-High

```
Namespace:          AWS/EC2
Metric:             CPUUtilization
Dimension:          InstanceId = monitoring-test instance ID
Statistic:          Average
Period:             300 seconds (5 minutes)
Evaluation Periods: 2
Threshold:          70
Operator:           GreaterThanThreshold
Alarm Actions:      SNS: monitoring-alerts
OK Actions:         SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: Average CPU > 70% for two consecutive 5-minute periods (10 minutes total).

**Why ok-actions**: Sends recovery email when CPU returns below threshold. Closes the incident loop.

---

## Alarm 2 — EC2-StatusCheck-Failed

```
Namespace:          AWS/EC2
Metric:             StatusCheckFailed
Dimension:          InstanceId = monitoring-test instance ID
Statistic:          Maximum
Period:             60 seconds (1 minute)
Evaluation Periods: 2
Threshold:          1
Operator:           GreaterThanOrEqualToThreshold
Alarm Actions:      SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: Any status check failure (value ≥ 1) in two consecutive 1-minute periods.

**Statistic rationale**: Maximum captures any failure during the period, even if other data points show 0.

---

## Alarm 3 — EC2-NetworkIn-High

```
Namespace:          AWS/EC2
Metric:             NetworkIn
Dimension:          InstanceId = monitoring-test instance ID
Statistic:          Average
Period:             300 seconds (5 minutes)
Evaluation Periods: 1
Threshold:          5000000 (bytes = 5MB)
Operator:           GreaterThanThreshold
Alarm Actions:      SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: Average inbound network traffic > 5MB in a 5-minute window.

**Units**: CloudWatch reports NetworkIn in bytes, not megabits. 5,000,000 bytes ≈ 5MB ≈ 40 Mbit.

---

## Alarm 4 — RDS-CPU-High

```
Namespace:          AWS/RDS
Metric:             CPUUtilization
Dimension:          DBInstanceIdentifier = myapp-database
Statistic:          Average
Period:             300 seconds (5 minutes)
Evaluation Periods: 2
Threshold:          80
Operator:           GreaterThanThreshold
Alarm Actions:      SNS: monitoring-alerts
OK Actions:         SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: Average RDS CPU > 80% for two consecutive 5-minute periods.

**State note**: Will show `INSUFFICIENT_DATA` if RDS instance `myapp-database` does not exist. This is expected after Project 6 cleanup.

---

## Alarm 5 — RDS-Storage-Low

```
Namespace:          AWS/RDS
Metric:             FreeStorageSpace
Dimension:          DBInstanceIdentifier = myapp-database
Statistic:          Average
Period:             300 seconds (5 minutes)
Evaluation Periods: 1
Threshold:          2000000000 (bytes = 2GB)
Operator:           LessThanThreshold
Alarm Actions:      SNS: monitoring-alerts
OK Actions:         SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: Free storage drops below 2GB.

**Units**: FreeStorageSpace is in bytes. 2,000,000,000 bytes = approximately 2GB. (Exact: 2GB = 2,147,483,648 bytes — the 2,000,000,000 value is a safe approximation that fires slightly early.)

---

## Alarm 6 — RDS-Connections-High

```
Namespace:          AWS/RDS
Metric:             DatabaseConnections
Dimension:          DBInstanceIdentifier = myapp-database
Statistic:          Average
Period:             300 seconds (5 minutes)
Evaluation Periods: 1
Threshold:          50
Operator:           GreaterThanThreshold
Alarm Actions:      SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: Active database connections > 50.

**Context**: db.t3.micro maximum connections = 66. Alert at 50 (76% of max) to allow investigation before exhaustion.

---

## Alarm 7 — Billing-Alert-5USD

```
Namespace:          AWS/Billing
Metric:             EstimatedCharges
Dimension:          Currency = USD
Statistic:          Maximum
Period:             86400 seconds (24 hours)
Evaluation Periods: 1
Threshold:          5
Operator:           GreaterThanThreshold
Alarm Actions:      SNS: monitoring-alerts
Missing Data:       notBreaching
Region:             us-east-1 (REQUIRED — billing metrics only here)
```

**Trigger condition**: Estimated monthly charges exceed $5.

**Important**: This alarm MUST be created in us-east-1. AWS Billing metrics are only published to us-east-1 regardless of which region your resources are in.

---

## Alarm 8 — App-Errors-High

```
Namespace:          CustomMetrics
Metric:             ApplicationErrors
Dimension:          (none — custom metric with no dimensions)
Statistic:          Sum
Period:             300 seconds (5 minutes)
Evaluation Periods: 1
Threshold:          5
Operator:           GreaterThanThreshold
Alarm Actions:      SNS: monitoring-alerts
Missing Data:       notBreaching
```

**Trigger condition**: More than 5 ERROR-pattern log entries in a 5-minute window.

**Source**: This metric does not come from AWS — it is created by the CloudWatch Logs metric filter on log group `/aws/ec2/monitoring-test`. Every log line matching the pattern `ERROR` increments this metric by 1.

**Verification**: After pushing test log events with 5 ERROR lines, this alarm transitions to ALARM state within one 5-minute evaluation period.

---

## Alarm States Summary (Post-Build)

| Alarm | Expected State | Notes |
|---|---|---|
| EC2-CPU-High | OK | CPU at idle baseline |
| EC2-StatusCheck-Failed | OK | Instance healthy |
| EC2-NetworkIn-High | OK | Minimal traffic |
| RDS-CPU-High | INSUFFICIENT_DATA | No RDS if Project 6 cleaned up |
| RDS-Storage-Low | INSUFFICIENT_DATA | No RDS if Project 6 cleaned up |
| RDS-Connections-High | INSUFFICIENT_DATA | No RDS if Project 6 cleaned up |
| Billing-Alert-5USD | OK | Within free tier |
| App-Errors-High | ALARM | After test log events pushed |

The INSUFFICIENT_DATA state for RDS alarms is normal — it means the alarm exists and is correctly configured, but there is no data source to evaluate against.

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-06-rds-ec2/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Rds Ec2</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-08-serverless-rest-api/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Serverless Rest Api</b> ⏩</a></td>
    </tr>
  </table>
</div>

