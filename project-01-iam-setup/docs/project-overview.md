# Project 1 — AWS Account Setup & IAM Foundations

**Level:** Beginner | **Estimated Time:** 3–4 hours

## Purpose
Secure your AWS account from day one and create an IAM user you'll use for everything from here forward — the way every real cloud team operates (nobody uses root).

## Learning Objectives
- Understand the difference between the root user and IAM users
- Enable MFA (Multi-Factor Authentication) on the root account
- Set up billing alerts so you never get a surprise charge
- Create an IAM user with admin permissions and programmatic access
- Configure AWS CLI v2 on Windows
- Understand least-privilege as a security principle

## AWS Services Used
| Service | Role |
|---|---|
| IAM | Identity & Access Management — users, groups, policies, roles |
| CloudWatch + Billing | Alerting when spend exceeds a threshold |
| SNS | Sends the billing alert email |
| AWS CLI v2 | Command-line interface running on your Windows machine |

## Real-World Context
Every company that runs on AWS starts here. A Solutions Architect's first job on a new account is hardening root, setting up IAM, and establishing billing guardrails. This is Day 1 at any cloud job.

## ✅ Free Tier Status
100% Free. IAM has no cost. Billing alarms use CloudWatch (1 alarm free/month). SNS email notifications are free.
Cost estimate: $0.00 best case, $0.00 worst case.