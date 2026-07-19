# Project Overview: Highly Available 3-Tier Architecture

## 🏢 The Business Problem
Modern enterprises require web applications that are reliable, scalable, and secure. A single-server architecture is a single point of failure; if the server goes down, the business goes down. Furthermore, tightly coupling the web interface, application logic, and database layer leads to security vulnerabilities and makes scaling individual components impossible. Businesses need an architecture that can handle sudden traffic spikes, survive the loss of an entire data center without dropping user sessions, and securely isolate sensitive customer data from the public internet.

## 🚀 The Solution
This Capstone Project solves these challenges by implementing a **production-grade, Highly Available 3-Tier Architecture** on AWS. The solution decouples the application into three distinct layers:
1. **Web Tier (Presentation):** An Application Load Balancer (ALB) securely handles incoming public HTTP/HTTPS traffic and distributes it evenly.
2. **Application Tier (Logic):** A fleet of stateless EC2 instances running inside an Auto Scaling Group (ASG) dynamically scales in and out based on CPU demand.
3. **Database Tier (Data):** Amazon RDS running MySQL in a Multi-AZ configuration ensures synchronous replication, automatic failover, and high durability for stateful data.

By distributing these tiers across multiple Availability Zones, the architecture is immune to single-AZ failures, providing true High Availability (HA).

## 🎓 Learning Objectives
This project serves as the culmination of the AWS Hands-On Projects series. By executing this project, you will demonstrate the ability to:
- **Design for Failure:** Implement Multi-AZ deployments for RDS and Auto Scaling across subnets to survive localized outages.
- **Architect Secure Networks:** Build a custom Virtual Private Cloud (VPC) implementing strict subnet isolation and Security Group chaining.
- **Automate Infrastructure:** Use advanced Bash and PowerShell scripting to automate the provisioning, verification, and destruction of dozens of interdependent AWS resources.
- **Implement Observability:** Configure CloudWatch Dashboards, custom metric alarms, and SNS email alerts to proactively monitor system health.
- **Secure Credentials:** Dynamically inject database credentials into application instances using AWS Secrets Manager and IAM Instance Profiles, eliminating hardcoded passwords.

## ⚙️ Services Utilized
| AWS Service | Architectural Role | Value Add |
| :--- | :--- | :--- |
| **Amazon VPC** | Network Backbone | Provides network isolation, custom routing, and IP addressing (10.0.0.0/16). |
| **Application Load Balancer** | Web Tier | Terminates client connections and routes traffic to healthy application instances. |
| **EC2 Auto Scaling** | App Tier Compute | Provides elastic compute capacity, scaling from 2 to 4 instances automatically based on CPU load. |
| **Amazon RDS (Multi-AZ)** | Database Tier | Delivers a highly durable relational database with sub-minute automatic failover. |
| **AWS Secrets Manager** | Security | Centralizes and encrypts database credentials at rest. |
| **IAM** | Identity & Access | Grants EC2 instances secure permission to access SSM and Secrets Manager via Instance Profiles. |
| **CloudWatch & SNS** | Monitoring | Provides real-time visibility into system health and alerts administrators via email upon failure. |
| **NAT Gateway** | Outbound Routing | Allows private application servers to download security patches from the internet without exposing inbound access. |

## 💡 The Value Proposition
This architecture is the industry standard for traditional web applications. Building it proves you can bridge the gap between theoretical cloud concepts and practical, secure, production-ready engineering.
