# Architecture Details

## IAM (Identity and Access Management)
- **Root User:** The owner of the account. It is secured via a virtual MFA device (e.g., Google Authenticator).
- **Admin User:** A standard IAM user with the `AdministratorAccess` managed policy attached. This user is used for all CLI and Console access.

## CloudWatch & SNS (Billing Alerts)
- **CloudWatch Alarm:** Monitors the `EstimatedCharges` metric in the `us-east-1` region (where billing metrics are generated).
- **SNS Topic:** A Simple Notification Service topic that acts as a pub/sub channel. The CloudWatch alarm publishes to this topic, which then emails the subscribed address.
