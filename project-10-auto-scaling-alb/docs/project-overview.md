# Project 10 Overview: Auto Scaling Group + Application Load Balancer

## 🎯 Business Problem

Modern enterprise applications require high availability, fault tolerance, and the ability to seamlessly handle sudden traffic spikes without manual intervention. 

Deploying applications on a single static EC2 instance introduces a single point of failure. If the instance goes down, the application is completely inaccessible. Conversely, if traffic surges unexpectedly (e.g., a viral marketing campaign), a single instance will quickly exhaust its CPU and memory, causing the application to crash. Manually provisioning new servers during an outage is too slow and results in poor user experience and lost revenue.

## 🚀 Solution

This project implements a highly available and elastic infrastructure on AWS. By leveraging an **Application Load Balancer (ALB)** and an **Auto Scaling Group (ASG)**, the application gains self-healing capabilities and dynamic scalability.

The ALB acts as the single point of contact for users and distributes incoming traffic evenly across multiple instances in different Availability Zones. The ASG constantly monitors instance health (via ALB health checks) and CPU utilization (via CloudWatch metrics). 
- **Self-Healing:** If an instance fails a health check, the ASG terminates it and provisions a replacement. 
- **Elasticity:** If average CPU utilization exceeds 50%, the ASG automatically scales out by adding more instances to handle the load. When traffic subsides, it scales in to save costs.

## 🏆 Learning Objectives

By completing this project, you will learn how to:
1. **Create Launch Templates** to standardize EC2 configurations (AMI, type, SG, user data).
2. **Configure Target Groups** to route requests to registered targets and perform robust HTTP health checks.
3. **Deploy Application Load Balancers** to distribute traffic securely across Availability Zones.
4. **Implement Auto Scaling Groups** to dynamically adjust capacity based on target tracking policies (CPU utilization).
5. **Validate Self-Healing** by intentionally terminating instances and observing automated recovery.
6. **Perform Stress Testing** using Linux utilities (`stress`) to trigger scale-out and scale-in events.

## 🛠️ AWS Services Used

| Service | Role in Architecture |
|:---|:---|
| **Application Load Balancer (ALB)** | Layer 7 load balancer routing HTTP traffic to healthy instances |
| **Auto Scaling Group (ASG)** | Manages the lifecycle and quantity of EC2 instances dynamically |
| **EC2 Launch Template** | The immutable blueprint used to stamp out new instances |
| **Amazon EC2** | Compute instances running the Apache web server |
| **Amazon VPC** | Networking foundation (subnets, route tables, internet gateway) |
| **Amazon CloudWatch** | Monitors CPU metrics and triggers ASG scaling policies |

## ✅ Free Tier Status

| Resource | Cost |
|:---------|:-----|
| **EC2 t2.micro** (ASG instances, 750 hrs/month total) | Free (12 months) |
| **ALB** | ⚠️ ~$0.0225/hr + LCU charges |
| **EBS gp3** (up to 30 GB total) | Free (12 months) |

> [!WARNING]
> **ALB is NOT included in the AWS Free Tier.** It costs approximately $0.0225/hour (~$16/month if left running). We create it, test scaling behavior, then tear it down immediately using the provided cleanup scripts. Total cost exposure for this lab is typically **under $0.50**.

## 🔗 Related Projects
- **Project 05**: Demonstrates how to build the custom VPC this architecture typically runs in.
- **Project 07**: Explores the CloudWatch metrics and alarms that power the Auto Scaling policies used here.