# Project Overview

## The Business Problem
If an EC2 instance hosts a critical web application and that instance crashes (or the Availability Zone goes down), the application goes offline. Furthermore, relying on a single instance means you must permanently over-provision large servers to handle occasional traffic spikes, wasting money.

## The Solution
This project implements the Auto Scaling Group (ASG) and Application Load Balancer (ALB) pattern. The ALB acts as a single point of contact for users, distributing traffic across a fleet of smaller EC2 instances. The ASG monitors CPU metrics and automatically adds or removes instances based on actual demand, creating a highly available, self-healing, and cost-efficient architecture.
