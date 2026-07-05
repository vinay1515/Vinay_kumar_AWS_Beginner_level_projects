# Comprehensive Project Overview: CloudWatch Monitoring, Alarms & SNS Notifications

## 🎯 Executive Summary & Purpose
Build a complete AWS monitoring and alerting system. In a production environment, you cannot afford to manually check if your servers or databases are healthy. This project creates an automated observability layer that continuously monitors resources, detects anomalies, and sends real-time alerts.

The purpose of this project is to establish a robust monitoring foundation by:
- **Creating CloudWatch Alarms:** Setting up metric-based alarms for EC2 (CPU, Network, Status Checks) and RDS (CPU, Connections, Storage).
- **Routing Alerts via SNS:** Configuring Simple Notification Service (SNS) to push email notifications the moment an alarm is triggered.
- **Building CloudWatch Dashboards:** Creating a centralized, single-pane-of-glass dashboard to visualize critical infrastructure metrics simultaneously.
- **Log Monitoring & Metric Filters:** Ingesting application logs into CloudWatch Logs and parsing them dynamically with Metric Filters to generate custom metrics (e.g., counting 'ERROR' occurrences).
- **Financial Safeguards:** Deploying a $5 billing alarm specific to the `us-east-1` region to prevent unexpected cloud costs.

## 📚 Detailed Learning Objectives
Upon completing this module, you will be able to:
1. **Understand CloudWatch Dimensions:** Grasp the relationship between namespaces, metrics, and dimensions.
2. **Create Threshold Alarms:** Configure alarms with specific threshold types (Static vs Anomaly Detection) and evaluation periods.
3. **Configure SNS Topics:** Build publish/subscribe messaging topics and confirm email endpoints.
4. **Build Custom Dashboards:** Use the console and JSON configurations to deploy multi-widget dashboards.
5. **Parse Logs with Metric Filters:** Extract structured custom metrics from unstructured application logs.
6. **Understand Alarm States:** Differentiate between `OK`, `ALARM`, and `INSUFFICIENT_DATA`.

## 🛠️ AWS Services & Technologies Utilized
| Service | Primary Role in this Project |
|---------|------------------------------|
| **AWS CloudWatch** | Metrics collection, threshold alarms, dashboards, and log storage |
| **AWS SNS** | Simple Notification Service — sends fan-out email alerts |
| **Amazon EC2** | Source of compute metrics and target for stress testing |
| **Amazon RDS** | Source of managed database metrics (from Project 6) |
| **AWS IAM** | Permissions management for logging and monitoring access |

## ✅ Cost Control & Financial Governance
This project is designed to be entirely within the AWS Free Tier:
- **CloudWatch Metrics:** 10 custom metrics free.
- **CloudWatch Alarms:** 10 alarms free (we create ~8).
- **CloudWatch Dashboards:** 3 dashboards free (we create 1).
- **CloudWatch Logs:** 5 GB ingestion free.
- **SNS Notifications:** 1,000 free email deliveries per month.
**Total Cost:** $0.00.
