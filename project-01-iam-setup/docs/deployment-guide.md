# Deployment Guide

## Step 1: Secure the Root Account
1. Log into the AWS Console using the root email address.
2. Navigate to **IAM > Users > Security credentials**.
3. Assign an MFA device (Virtual MFA app).

## Step 2: Set up Billing Alerts
1. Go to the **Billing Dashboard > Billing Preferences**.
2. Enable "Receive Billing Alerts".
3. Go to **CloudWatch > Alarms > Create Alarm** (must be in `us-east-1`).
4. Select Metric: `Billing > Total Estimated Charge`.
5. Set condition to "Greater/Equal" to $5.
6. Configure actions to create a new SNS topic and enter your email address.
7. Confirm the subscription in your email inbox.

## Step 3: Create the Admin User
1. Go to **IAM > Users > Add users**.
2. Create `admin-yourname`. Check "Provide user access to the AWS Management Console".
3. Attach the `AdministratorAccess` policy directly.
4. Go to the new user's Security Credentials and generate an **Access Key** for CLI use.

## Step 4: Configure AWS CLI
Open your local terminal and run:
```bash
aws configure
```
Enter your Access Key, Secret Key, default region (e.g., `ap-south-1`), and default output format (`json`).
