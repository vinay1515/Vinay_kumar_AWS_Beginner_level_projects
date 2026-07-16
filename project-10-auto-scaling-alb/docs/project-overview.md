# Project 10 Overview: Auto Scaling Group + Application Load Balancer

## 🎯 Business Problem

Modern enterprise applications require high availability, fault tolerance, and the ability to seamlessly handle sudden traffic spikes without manual intervention. Deploying applications on a single static EC2 instance introduces a single point of failure. If the instance goes down, the application is completely inaccessible. If traffic surges, a single instance will become overwhelmed and crash.

## 🚀 Solution

This project implements a highly available and elastic infrastructure on AWS. By leveraging an **Application Load Balancer (ALB)** and an **Auto Scaling Group (ASG)**, the application gains self-healing capabilities and dynamic scalability.

The ALB distributes incoming traffic across multiple instances in different Availability Zones. The ASG monitors instance health (via ALB health checks) and CPU utilization (via CloudWatch metrics). If an instance fails, the ASG terminates it and provisions a replacement. If CPU utilization exceeds 50%, the ASG automatically scales out by adding more instances. 

## 🏆 Learning Objectives

By completing this project, you will learn how to:
1. **Launch Templates**: Standardize EC2 instance configurations (AMI, instance type, security groups, and user data).
2. **Target Groups**: Route requests to registered targets (EC2 instances) and perform robust health checks.
3. **Application Load Balancers**: Distribute HTTP traffic securely and efficiently across instances in multiple Availability Zones.
4. **Auto Scaling Groups**: Dynamically adjust capacity based on CPU tracking metrics.
5. **Self-Healing Architecture**: Simulate instance failures to observe AWS automatically recovering the workload.
6. **Stress Testing**: Inject load using Linux `stress` utilities to observe scale-out and scale-in events.