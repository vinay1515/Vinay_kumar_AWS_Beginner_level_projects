# Security Group Rules

This document outlines the purpose, configuration, and security rationale for the Security Group (`ec2-web-sg`) deployed in this project.

## 🛡️ Firewall Configuration

### `ec2-web-sg` (Web Server & Admin Access)

| Direction | Port | Protocol | Source / Destination | Purpose |
|:---|:---:|:---|:---|:---|
| Inbound | 22 | TCP | `<Your-IP>/32` | Administrative SSH access via PuTTY/Terminal |
| Inbound | 80 | TCP | `0.0.0.0/0` | Public HTTP access for the Apache web server |
| Outbound | All | All | `0.0.0.0/0` | Outbound internet access (default) |

## 🔑 Key Security Concepts

### 1. Security Groups are Stateful
Security groups automatically track connection state. Because they are stateful, **only inbound rules are needed** for incoming connections. Return traffic for established connections is automatically allowed back out, regardless of the outbound rules. This is fundamentally different from Network ACLs (NACLs), which are stateless and require explicit return rules.

### 2. The Danger of `0.0.0.0/0` on Port 22
Using `0.0.0.0/0` (Anywhere) for SSH (Port 22) exposes your instance to the entire internet. Automated bots constantly scan AWS IP ranges for open SSH ports to launch brute-force attacks.
- **Our Mitigation:** We explicitly restrict Port 22 to `Your IP /32`, creating a pinhole that only allows your current network to attempt connections.

### 3. Outbound Restriction Recommendations
By default, AWS creates an "Allow All" outbound rule. In a hardened production environment, this should be restricted:
- **Egress Filtering:** Only allow outbound connections to required services (e.g., Port 443 to AWS APIs, Port 80 to package managers).
- **Data Exfiltration:** Restricting outbound traffic prevents compromised instances from participating in botnets or exfiltrating stolen data.

## 🔒 Advanced Security: IMDSv2 and SSM

While security groups control network boundaries, instance-level security is also critical.

### Instance Metadata Service v2 (IMDSv2)
This project enforces IMDSv2 on the EC2 instance.
- **Why?** It requires a session token to access `169.254.169.254`.
- **Protection:** It mitigates Server-Side Request Forgery (SSRF) vulnerabilities where an attacker tricks a web application into fetching instance credentials from the metadata endpoint.

### Systems Manager (SSM) Session Manager
As an alternative to opening Port 22, this project demonstrates connecting via **Session Manager**.
- **Security Benefit:** Session Manager requires **NO open inbound ports**. It uses the outbound connection to the SSM service, meaning you can completely delete the Port 22 rule and still maintain shell access.
- **Auditability:** All Session Manager shell commands can be logged to CloudWatch or S3.