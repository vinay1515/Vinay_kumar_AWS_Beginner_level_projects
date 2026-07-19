# Security Protocols: 3-Tier HA Architecture

This document outlines the comprehensive security posture of the Capstone Architecture, adhering to the AWS Well-Architected Framework's Security Pillar.

## 🛡️ Network Security (Security Group Chaining)
The architecture employs a strict, multi-tiered security group setup to prevent unauthorized access. This is known as "Security Group Chaining":

1. **ALB Security Group (`capstone-alb-sg`)**
   - **Inbound:** Allows HTTP (80) and HTTPS (443) from `0.0.0.0/0`.
   - **Outbound:** Allows all traffic (necessary to reach the App SG).
2. **App Security Group (`capstone-app-sg`)**
   - **Inbound:** Allows HTTP (80) *only* from the `capstone-alb-sg` ID. It rejects all direct internet traffic.
   - **Outbound:** Allows all traffic (necessary to reach the DB SG and internet via NAT).
3. **DB Security Group (`capstone-db-sg`)**
   - **Inbound:** Allows MySQL (3306) *only* from the `capstone-app-sg` ID. The database is entirely isolated from the rest of the VPC and the internet.

## 🔐 IAM & Access Control (Least Privilege)
To adhere to the principle of least privilege, the application servers do not use long-term access keys (no IAM Users or Access Keys).

- **EC2 Instance Profile:** The ASG assigns the `capstone-ec2-profile` to all instances at launch.
- **Managed Policy - `AmazonSSMManagedInstanceCore`:** Grants permissions for AWS Systems Manager (SSM) Session Manager. This allows administrators to get a secure bash shell into the private instances without opening port 22 (SSH) or deploying a Bastion Host.
- **Inline Policy - `secrets-access`:** Grants `secretsmanager:GetSecretValue` explicitly and strictly limited to the exact ARN of the `capstone/db/credentials` secret.

## 🔒 Encryption & Credential Management
- **Secrets Manager:** Database credentials (username, complex password, port, engine) are generated and stored securely in AWS Secrets Manager. They are never hardcoded in scripts, user data, or source code.
- **Dynamic Retrieval:** During the EC2 bootstrapping process (User Data), the instance uses its IAM role to query Secrets Manager via the AWS API, retrieving the DB name to dynamically render the application UI.
- **Data at Rest:** While the basic automation scripts focus on architecture, a true production deployment of this stack must append `--storage-encrypted` to the RDS creation command to utilize AWS KMS for EBS volume encryption.

## 📋 Compliance & Best Practices
- **No Public IP Addressing for Compute:** Application servers are placed in private subnets and are not assigned public IP addresses, heavily reducing their attack surface.
- **Outbound Proxying:** The private instances use a NAT Gateway to access the internet. The NAT Gateway performs Network Address Translation, masking the private IPs and dropping any uninitiated inbound connections.
- **Audit Ready:** All AWS CLI commands used in deployment are strictly programmatic, ensuring the environment is perfectly reproducible and auditable for compliance standards like SOC2 or PCI-DSS.
