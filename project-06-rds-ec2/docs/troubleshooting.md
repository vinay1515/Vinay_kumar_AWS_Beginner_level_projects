# Troubleshooting Guide

When building network boundaries and implementing layered security, several common misconfigurations can cause connectivity to fail. Use this guide to systematically diagnose and resolve issues encountered during the deployment or testing phases.

## 🛠️ Common Issues & Resolutions

| ❌ Problem | 🔍 Root Cause | 🔧 Resolution |
|:---|:---|:---|
| **MySQL Connection Refused** | The RDS instance is still initializing, or the Security Group rules are incorrectly bound. | 1. Wait for the RDS status to change to `Available`.<br>2. Verify `rds-sg` explicitly allows Port 3306 with the source set to `ec2-app-sg` (not an IP CIDR block). |
| **Access Denied for user 'admin'** | The password entered at the prompt does not exactly match the one created. | Double-check the password. Ensure no hidden trailing spaces exist. Watch for bash escaping issues if using special characters. |
| **RDS Endpoint Not Resolving** | The VPC does not have DNS resolution enabled. | Execute `aws ec2 modify-vpc-attribute --vpc-id <VPC_ID> --enable-dns-hostnames`. Without this, the long AWS endpoints cannot be resolved to private IPs. |
| **Cannot Delete RDS Instance** | Automated deletion protection was accidentally enabled during creation. | In the RDS Console, select the instance -> click **Modify** -> scroll to the bottom and uncheck **Enable deletion protection** -> Apply immediately. Then retry deletion. |
| **AWS RDS Wait Times Out** | The DB instance is taking significantly longer than usual to provision, or it failed. | Check the **Events** tab in the RDS console for specific backend errors (e.g., insufficient capacity in the selected AZ). |
| **Secrets Manager Access Denied** | The EC2 instance cannot assume the necessary IAM permissions. | Verify you attached `ec2-app-profile` to the instance (`aws ec2 associate-iam-instance-profile`). Ensure the secret's ARN perfectly matches the IAM Policy's resource block. |
| **RDS Creation Fails Instantly** | The Subnet Group is improperly configured or spans public subnets. | Verify that your `rds-subnet-group` only contains `private-subnet-a` and `private-subnet-b`, and that it spans exactly two different Availability Zones. |