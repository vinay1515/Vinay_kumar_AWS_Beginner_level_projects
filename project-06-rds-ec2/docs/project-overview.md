# Project 06 Overview

## 🎯 Business Problem

As web applications mature, running the database on the same server as the application (a single-tier architecture) becomes a critical bottleneck and a severe security risk. If the web server is compromised, the database is fully exposed. Furthermore, self-managing a database on an EC2 instance means you are solely responsible for OS patching, database engine updates, setting up automated backups, and configuring complex Multi-AZ failovers.

Organizations need a robust, scalable, and secure architecture that distinctly separates the public-facing application layer from the sensitive data layer.

## 🚀 Solution

In this project, we implement a classic **Two-Tier Architecture** using Amazon EC2 and Amazon RDS. 

We launch an Amazon EC2 instance in a **Public Subnet** to serve as our application tier, allowing users to access the web application over the internet. Simultaneously, we deploy an Amazon RDS MySQL database into a **Private Subnet** (using a DB Subnet Group). 

By leveraging **Security Group Chaining**, we strictly configure the RDS security group to only accept incoming MySQL connections (port 3306) from the EC2 instance's security group. This ensures the database is physically impossible to reach from the open internet, providing enterprise-grade security.

## 🧠 Learning Objectives

Upon completing this project, you will:

- **Understand Database Managed Services:** Grasp the distinct differences and administrative advantages of using Amazon RDS over self-managed databases on EC2.
- **Master DB Subnet Groups:** Learn how to create a subnet group spanning multiple Availability Zones to satisfy RDS deployment requirements.
- **Implement Security Group Chaining:** Configure advanced security group rules where the source is another security group rather than an IP address.
- **Integrate Secrets Manager:** Securely store and retrieve database credentials using AWS Secrets Manager to eliminate hardcoded passwords.
- **Deploy RDS Instances:** Provision an RDS MySQL instance with custom parameters, automated backups, and specific storage configurations.
- **Validate End-to-End Connectivity:** Install a MySQL client on an Amazon Linux EC2 instance and successfully query the private RDS database via CLI.

## 🛠️ AWS Services Used

| Service | Role |
|:---|:---|
| **Amazon RDS** | Managed MySQL database securely isolated in private subnets. |
| **Amazon EC2** | Application server deployed in a public subnet to connect to RDS. |
| **Amazon VPC** | Custom network architecture providing logical isolation (reused from Project 5). |
| **Security Groups** | Layered, stateful access control enforcing the EC2 → RDS traffic path. |
| **Secrets Manager** | Centralized, secure storage for database credentials. |
| **CloudWatch** | Integrated monitoring for RDS performance metrics and alarms. |
| **IAM** | Instance profiles granting EC2 secure access to Secrets Manager and SSM. |