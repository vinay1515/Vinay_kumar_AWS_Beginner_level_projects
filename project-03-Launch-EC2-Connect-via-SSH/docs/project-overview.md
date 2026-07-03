# Project Overview: Launch EC2 & Connect via SSH

## Purpose
Launch your first virtual Linux server on AWS, secure it with a key pair and security group, connect to it from Windows, and host a live Apache web server — the foundational skill behind every backend, DevOps, and cloud engineering role.

## Learning Objectives
- Understand EC2 instances, AMIs, and instance types
- Create and use a key pair for SSH authentication
- Configure security groups as a virtual firewall
- Connect from Windows using PuTTY and AWS Systems Manager Session Manager
- Install and run Apache web server on Linux
- Understand EC2 instance states and billing implications

## AWS Services Used
| Service | Role |
|---------|------|
| **EC2** | The virtual Linux server itself |
| **VPC + Security Group** | Network isolation and firewall rules |
| **Key Pair** | SSH authentication (your private key = your password) |
| **Systems Manager** | Browser-based terminal — no PuTTY needed |
| **CloudWatch** | Basic instance monitoring |

## ✅ Free Tier Status
100% Free if you use the right instance type and stop/terminate when done.

| Resource | Free Tier Allowance |
|----------|---------------------|
| **EC2 t2.micro or t3.micro** | 750 hours/month free for 12 months |
| **EBS storage (8 GB)** | 30 GB/month free for 12 months |
| **Data transfer out** | 1 GB/month free |

*Cost estimate: $0.00 best case · ~$0.02 worst case (if you forget to stop it)*

> [!WARNING]
> An EC2 instance costs money while running even if you are not using it. Always stop the instance when done for the day. We will cover this in cleanup.