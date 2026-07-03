# Security Protocols & Best Practices

This project implements enterprise-standard security guardrails for a new AWS account. Establishing these protocols immediately prevents common exploits (like compromised root accounts and leaked access keys) that lead to massive unauthorized billing charges.

## 1. Root Account Protection
The AWS root user has unrestricted access to all resources and billing information. It cannot be restricted by IAM policies. 
- **Protocol:** Multi-Factor Authentication (MFA) must be enabled immediately. 
- **Protocol:** The root account should never be used for day-to-day administrative tasks, nor should Access Keys ever be generated for the root user.

## 2. Principle of Least Privilege (PoLP)
While our newly created IAM user receives `AdministratorAccess` (which is a broad permission set necessary for building future projects), the *principle* is established by migrating away from the root user. 
- In future projects, we will create specific IAM Roles and Policies scoped tightly to the exact actions required by individual services (e.g., an EC2 instance only having permission to read from a specific S3 bucket).

## 3. Programmatic Access Security
Access keys (Access Key ID and Secret Access Key) are essentially username/password equivalents for the AWS CLI and APIs.
- **Protocol:** Never hardcode access keys in scripts or application code.
- **Protocol:** Never commit access keys to version control (e.g., GitHub, GitLab). Use `.gitignore` to exclude credential files like `.csv` downloads.
- **Protocol:** Configure credentials locally using `aws configure`, which stores them securely in `~/.aws/credentials`.

## 4. Financial Security (Guardrails)
Billing alarms are a critical security mechanism. In the event that credentials are leaked and malicious actors spin up expensive resources (like Bitcoin miners on large EC2 instances), the billing alarm serves as an early warning system.
- **Protocol:** Always maintain an active CloudWatch Billing Alarm tied to an actively monitored email address via SNS.