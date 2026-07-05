# Security Protocols

This project strictly adheres to the **Principle of Least Privilege (PoLP)** and defense-in-depth methodologies. Security is applied in overlapping layers (Network, Identity, and Application).

## 🔒 Network Layer: Security Group Chaining

Security Group Chaining is an advanced networking pattern used to lock down database access without relying on static IP addresses.

We use two distinct, tightly-scoped security groups to enforce isolation:
1. **`ec2-app-sg` (The Web Tier)**: Attached to the EC2 Application Server.
   - Allows inbound SSH (22) strictly from your personal IP address.
   - Allows inbound HTTP (80) from anywhere (`0.0.0.0/0`) so users can access the web app.
2. **`rds-sg` (The Data Tier)**: Attached to the RDS instance.
   - Allows inbound MySQL (3306) **only** if the traffic originates from an instance bearing the `ec2-app-sg` security group.
   - **Why this matters:** The database is completely unreachable from the internet, from other instances in the public subnet, or even from other instances in the private subnet that do not have the `ec2-app-sg` attached.

## 🔐 Identity Layer: AWS Secrets Manager

Hardcoding database passwords in application source code or environment variables is a major anti-pattern that leads to severe security breaches.

Instead, we utilize **AWS Secrets Manager**:
- The secret (e.g. `rds/myapp/credentials`) holds the admin username, password, engine type, port, and database name.
- Passwords are auto-generated or strictly formulated (8+ characters, mixed case, numbers, special chars, explicitly excluding `@`, `/`, `"`, `\`).
- At runtime, the EC2 application queries Secrets Manager via the AWS SDK. The password is never stored in plain text on the server's disk.

## 🛡️ Application Layer: IAM Instance Profiles

To allow the EC2 instance to query Secrets Manager securely, we do not provide it with permanent IAM User Access Keys. That would pose a credential leakage risk.

Instead, we attach an **IAM Instance Profile (`ec2-app-profile`)** containing short-lived, automatically rotated credentials:
- **`AmazonSSMManagedInstanceCore`**: Allows secure, audited shell access via AWS Systems Manager Session Manager (SSM) as a modern alternative to SSH.
- **Custom Secrets Manager Policy**: Contains a carefully scoped policy that grants `secretsmanager:GetSecretValue` specifically (and only) for the `arn:aws:secretsmanager:us-east-1:*:secret:rds/myapp/*` resource ARN. The instance is physically blocked from reading any other secrets in the AWS account.