#!/bin/bash

# =============================================================================
# Project 7 — Script 07: CloudWatch Dashboard
# Creates AWS-Bootcamp-Dashboard with EC2, RDS, and billing widgets
# =============================================================================

echo -e "\e[36m=== Project 7 — CloudWatch Dashboard ===\e[0m"
echo ""

if (-not $MON_INSTANCE_ID) {
echo -e "\e[31mERROR: MON_INSTANCE_ID not set. Run 02-launch-monitoring-ec2.ps1 first.\e[0m"
    exit 1
}

echo -e "\e[33mBuilding dashboard for instance: $MON_INSTANCE_ID\e[0m"
echo ""

# ── BUILD DASHBOARD JSON ──────────────────────────────────────────────────────
DASHBOARD_BODY=@"
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 12, "height": 6,
      "properties": {
        "title": "EC2 CPU Utilization",
        "metrics": [
          ["AWS/EC2","CPUUtilization","InstanceId","$MON_INSTANCE_ID",
           {"stat":"Average","period":300,"color":"#2196F3","label":"CPU %"}]
        ],
        "view": "timeSeries",
        "annotations": {
          "horizontal": [{"value":70,"color":"#f44336","label":"Alarm threshold (70%)"}]
        },
        "period": 300,
        "yAxis": {"left":{"min":0,"max":100}},
        "region": "us-east-1",
        "legend": {"position":"bottom"}
      }
    },
    {
      "type": "metric",
      "x": 12, "y": 0, "width": 12, "height": 6,
      "properties": {
        "title": "EC2 Network Traffic",
        "metrics": [
          ["AWS/EC2","NetworkIn","InstanceId","$MON_INSTANCE_ID",
           {"stat":"Average","period":300,"color":"#4CAF50","label":"Network In (bytes)"}],
          ["AWS/EC2","NetworkOut","InstanceId","$MON_INSTANCE_ID",
           {"stat":"Average","period":300,"color":"#FF9800","label":"Network Out (bytes)"}]
        ],
        "view": "timeSeries",
        "region": "us-east-1",
        "legend": {"position":"bottom"}
      }
    },
    {
      "type": "metric",
      "x": 0, "y": 6, "width": 12, "height": 6,
      "properties": {
        "title": "RDS CPU Utilization",
        "metrics": [
          ["AWS/RDS","CPUUtilization","DBInstanceIdentifier","myapp-database",
           {"stat":"Average","period":300,"color":"#9C27B0","label":"RDS CPU %"}]
        ],
        "view": "timeSeries",
        "annotations": {
          "horizontal": [{"value":80,"color":"#f44336","label":"Alarm threshold (80%)"}]
        },
        "region": "us-east-1"
      }
    },
    {
      "type": "metric",
      "x": 12, "y": 6, "width": 6, "height": 6,
      "properties": {
        "title": "RDS Database Connections",
        "metrics": [
          ["AWS/RDS","DatabaseConnections","DBInstanceIdentifier","myapp-database",
           {"stat":"Average","period":300,"color":"#E91E63"}]
        ],
        "view": "singleValue",
        "region": "us-east-1"
      }
    },
    {
      "type": "metric",
      "x": 18, "y": 6, "width": 6, "height": 6,
      "properties": {
        "title": "Estimated AWS Charges (USD)",
        "metrics": [
          ["AWS/Billing","EstimatedCharges","Currency","USD",
           {"stat":"Maximum","period":86400,"color":"#FF5722"}]
        ],
        "view": "singleValue",
        "region": "us-east-1"
      }
    }
  ]
}
"@

# Save dashboard JSON
$DASHBOARD_BODY | Out-File -FilePath "dashboard.json" -Encoding utf8
echo -e "\e[32mDashboard JSON saved to dashboard.json\e[0m"

# ── UPLOAD DASHBOARD ──────────────────────────────────────────────────────────
echo -e "\e[33mUploading dashboard to CloudWatch...\e[0m"

aws cloudwatch put-dashboard \
  --dashboard-name "AWS-Bootcamp-Dashboard" \
  --dashboard-body file://dashboard.json

echo -e "\e[32mDashboard created.\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying dashboard...\e[0m"

aws cloudwatch list-dashboards \
  --query "DashboardEntries[?DashboardName=='AWS-Bootcamp-Dashboard'].{Name:DashboardName,Size:Size,Modified:LastModified}" \
  --output table

echo ""
echo -e "\e[36m=== Dashboard Complete ===\e[0m"
echo ""
echo "Console path: CloudWatch -> Dashboards -> AWS-Bootcamp-Dashboard"
echo ""
echo "Widgets created:"
echo "  1. EC2 CPU Utilization (line chart, 70% threshold line)"
echo "  2. EC2 Network Traffic (NetworkIn + NetworkOut dual line)"
echo "  3. RDS CPU Utilization (line chart, 80% threshold line)"
echo "  4. RDS Database Connections (single value)"
echo "  5. Estimated AWS Charges USD (single value)"
echo ""
echo -e "\e[36mNext step: Run 08-create-log-group.ps1\e[0m"