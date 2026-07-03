
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">dashboards.md</text>
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

## Dashboard Overview

The dashboard consolidates 5–6 widgets into a single operational view. In production, dashboards like this are the first screen an on-call engineer opens when investigating an incident.

---

## Widget Layout

```
┌────────────────────────────┬────────────────────────────┐
│   EC2 CPU Utilization      │   EC2 Network Traffic       │
│   (Line — 12 wide)         │   (Line — 12 wide)          │
│                            │                             │
│   ── 70% threshold line    │   NetworkIn + NetworkOut    │
│                            │   dual-line with legend     │
├────────────────────────────┬──────────────┬─────────────┤
│   RDS CPU Utilization      │ RDS DB       │ Estimated   │
│   (Line — 12 wide)         │ Connections  │ Charges     │
│                            │ (Number — 6) │ (Number — 6)│
│   ── 80% threshold line    │              │             │
└────────────────────────────┴──────────────┴─────────────┘
```

Grid is 24 units wide. Widgets use x/y/width/height positioning.

---

## Widget Configurations

### Widget 1 — EC2 CPU Utilization
```json
{
  "type": "metric",
  "x": 0, "y": 0, "width": 12, "height": 6,
  "properties": {
    "title": "EC2 CPU Utilization",
    "metrics": [
      ["AWS/EC2", "CPUUtilization", "InstanceId", "<INSTANCE_ID>",
       {"stat": "Average", "period": 300, "color": "#2196F3"}]
    ],
    "view": "timeSeries",
    "annotations": {
      "horizontal": [{"value": 70, "color": "#f44336", "label": "Alarm threshold"}]
    },
    "yAxis": {"left": {"min": 0, "max": 100}},
    "period": 300
  }
}
```

The `annotations.horizontal` field draws the alarm threshold line directly on the graph — visual alignment between the dashboard and the alarm definition.

### Widget 2 — EC2 Network Traffic
```json
{
  "type": "metric",
  "x": 12, "y": 0, "width": 12, "height": 6,
  "properties": {
    "title": "EC2 Network Traffic",
    "metrics": [
      ["AWS/EC2", "NetworkIn", "InstanceId", "<INSTANCE_ID>",
       {"stat": "Average", "period": 300, "color": "#4CAF50", "label": "Network In"}],
      ["AWS/EC2", "NetworkOut", "InstanceId", "<INSTANCE_ID>",
       {"stat": "Average", "period": 300, "color": "#FF9800", "label": "Network Out"}]
    ],
    "view": "timeSeries"
  }
}
```

Combining NetworkIn and NetworkOut on one graph shows traffic asymmetry — a web server should have much more outbound than inbound traffic. Inbound spikes indicate unusual ingress.

### Widget 3 — RDS CPU Utilization
```json
{
  "type": "metric",
  "x": 0, "y": 6, "width": 12, "height": 6,
  "properties": {
    "title": "RDS CPU Utilization",
    "metrics": [
      ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "myapp-database",
       {"stat": "Average", "period": 300, "color": "#9C27B0"}]
    ],
    "view": "timeSeries",
    "annotations": {
      "horizontal": [{"value": 80, "color": "#f44336", "label": "Alarm threshold"}]
    }
  }
}
```

### Widget 4 — RDS Database Connections
```json
{
  "type": "metric",
  "x": 12, "y": 6, "width": 6, "height": 6,
  "properties": {
    "title": "RDS Database Connections",
    "metrics": [
      ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "myapp-database",
       {"stat": "Average", "period": 300, "color": "#E91E63"}]
    ],
    "view": "singleValue"
  }
}
```

`singleValue` view shows the latest data point as a large number — ideal for a metric you want at a glance rather than trending over time.

### Widget 5 — Estimated AWS Charges
```json
{
  "type": "metric",
  "x": 18, "y": 6, "width": 6, "height": 6,
  "properties": {
    "title": "Estimated AWS Charges (USD)",
    "metrics": [
      ["AWS/Billing", "EstimatedCharges", "Currency", "USD",
       {"stat": "Maximum", "period": 86400, "color": "#FF5722"}]
    ],
    "view": "singleValue",
    "region": "us-east-1"
  }
}
```

Billing widget must explicitly specify `"region": "us-east-1"` even if the dashboard is in another region, because billing metrics only exist in us-east-1.

---

## Dashboard JSON File

The complete dashboard definition is saved to `dashboard.json` by `07-create-dashboard.ps1` and uploaded via:

```powershell
aws cloudwatch put-dashboard \
  --dashboard-name "AWS-Bootcamp-Dashboard" \
  --dashboard-body file://dashboard.json
```

---

## Console Path

`CloudWatch → Dashboards → AWS-Bootcamp-Dashboard`

The dashboard is publicly viewable within your AWS account with appropriate IAM permissions. It auto-refreshes — set the interval in the top-right refresh dropdown (1 minute, 10 seconds, etc.).

---

## Dashboard Best Practices Applied

**Threshold lines on graphs**: The alarm threshold (70% CPU, 80% RDS CPU) is drawn directly on the graph using `annotations.horizontal`. This lets you see how close the current value is to the alarm line without opening the alarm configuration.

**Consistent colour coding**: Blue = EC2, Purple = RDS, Orange = Network, Red = threshold lines. Consistent colours reduce the time to identify the right line when graphs are glanced at under pressure.

**Single-value widgets for current state**: Connection count and billing amount don't need time-series history on the main dashboard — you want the current number. Use `singleValue` view for these.

**Separate widgets per concern**: One widget per metric group makes it easy to expand or reposition without affecting other graphs.

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

