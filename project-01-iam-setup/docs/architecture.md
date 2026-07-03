# Architecture & Component Details

This project establishes the foundational security architecture for an AWS environment. Because this is day-one account setup, the "architecture" focuses on identity management, access control, and cost monitoring rather than typical application infrastructure (like VPCs or EC2 instances).

## Core Components

### 1. Identity and Access Management (IAM)
IAM is the central nervous system for AWS security. In this project, it handles:
- **Root User Hardening:** Securing the overarching account owner with Multi-Factor Authentication (MFA).
- **IAM User Provisioning:** Creating a daily-driver admin user, allowing you to avoid using the root account for administrative tasks.
- **Policies:** Attaching the `AdministratorAccess` AWS managed policy to our new IAM user to grant full permissions securely.
- **Access Keys:** Generating long-term credentials for programmatic (CLI/SDK) access.

### 2. Amazon CloudWatch (Billing Metrics)
CloudWatch monitors AWS resources and applications. For this project, we specifically use the **Billing** namespace (which is only available in the `us-east-1` region) to monitor our estimated charges.
- **Metrics Evaluated:** `EstimatedCharges` in USD.
- **Alarms:** Configured to trigger when the metric exceeds our static threshold (e.g., $5.00).

### 3. Amazon Simple Notification Service (SNS)
SNS is a fully managed pub/sub messaging service.
- **Topics:** We create a `billing-alert-topic` to act as the communication channel for CloudWatch.
- **Subscriptions:** An email subscription is attached to the topic. When CloudWatch breaches the billing threshold, it publishes a message to SNS, which then pushes an email notification to the subscriber.

## Architecture Flow

1. **User Access:** The admin user interacts with the AWS environment via the Management Console (using a password) or the AWS CLI (using Access Keys).
2. **Cost Monitoring:** As AWS services are used over the month, cost data is sent to CloudWatch.
3. **Alert Trigger:** If CloudWatch detects that estimated charges > $5.00, it changes the alarm state to `ALARM`.
4. **Notification Routing:** CloudWatch triggers the linked SNS Topic.
5. **Delivery:** SNS dispatches an alert email to the configured email address, warning the administrator of the overage.