# Architecture Details: CloudWatch Monitoring & Alerts

## 🏗️ High-Level System Architecture

This project implements a multi-tiered monitoring stack collecting metrics from compute resources, database resources, billing systems, and application logs.

```text
┌─────────────────────────────────────────────────────────────┐
│                    MONITORING STACK                         │
│                                                             │
│  EC2 Instance          RDS MySQL         Billing            │
│  ├── CPUUtilization    ├── CPUUtilization ├── EstimatedCharge│
│  ├── NetworkIn/Out     ├── DBConnections  └── Alarm → SNS   │
│  ├── StatusCheckFailed └── FreeStorage                      │
│  └── DiskReadOps           │                                │
│         │                  │                                │
│         ▼                  ▼                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           CloudWatch Alarms                         │    │
│  │  EC2-CPU-High    RDS-CPU-High    Billing-Alert      │    │
│  │  EC2-StatusFail  RDS-Storage-Low                    │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │ ALARM state                       │
│                         ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              SNS Topic: monitoring-alerts            │   │
│  │              Subscribers: your@email.com             │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│              📧 Email Notification                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         CloudWatch Dashboard: AWS-Bootcamp           │   │
│  │  [EC2 CPU] [EC2 Network] [RDS CPU] [RDS Connections] │   │
│  │  [RDS Storage] [Billing] [Alarm Status]              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Analysis

1. **Metric Emission:** EC2 and RDS automatically emit standard metrics to CloudWatch every 1 to 5 minutes.
2. **Evaluation:** CloudWatch Alarms continuously evaluate incoming metric data against defined static thresholds (e.g., `> 70%` for 2 consecutive periods).
3. **Trigger:** If the threshold is breached, the alarm state transitions from `OK` to `ALARM`.
4. **Notification:** The alarm invokes the SNS Topic ARN configured in its actions.
5. **Delivery:** SNS fans out the message to all confirmed subscribers (Email).

## 🪵 Log Ingestion Workflow

1. Application logs are pushed to the CloudWatch Log Group `/aws/ec2/monitoring-test`.
2. A **Metric Filter** constantly scans incoming log streams for the specific keyword `ERROR`.
3. When matched, the filter increments a custom CloudWatch metric (`ApplicationErrors` in the `CustomMetrics` namespace).
4. A CloudWatch alarm monitors this custom metric and alerts if errors spike.
