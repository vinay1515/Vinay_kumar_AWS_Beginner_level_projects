# Deployment Guide

## Step 1: Create Launch Template
1. Navigate to EC2 > Launch Templates. Create a new template.
2. Select Amazon Linux 2023, `t2.micro`, and your `EC2-SG`.
3. Under Advanced > User Data, insert a bash script to install `httpd` and echo the Instance ID to `index.html`.

## Step 2: Create Target Group
1. Navigate to Target Groups. Create a new group (Instances, Port 80, HTTP).
2. Set Health Check path to `/`. Do not register any targets manually (the ASG will do this).

## Step 3: Create Application Load Balancer
1. Navigate to Load Balancers. Create an ALB.
2. Select Internet-facing. Select your VPC and at least two Public Subnets.
3. Attach `ALB-SG`. Add a listener for Port 80 forwarding to the Target Group from Step 2.

## Step 4: Create Auto Scaling Group
1. Navigate to Auto Scaling Groups.
2. Select your Launch Template. Select your VPC and the two Public Subnets.
3. Attach to an existing load balancer (choose the Target Group).
4. Turn on ELB Health Checks.
5. Set Min=2, Desired=2, Max=4. Add a Target Tracking Scaling Policy for CPU > 50%.
