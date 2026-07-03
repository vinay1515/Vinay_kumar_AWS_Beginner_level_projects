# Deployment Guide

## Step 1: Core Networking
1. Create VPC `10.0.0.0/16`.
2. Create 2 Public Subnets and 2 Private Subnets across two AZs.
3. Create an Internet Gateway and attach it to the VPC.

## Step 2: NAT Gateway
1. Allocate an Elastic IP.
2. Create a NAT Gateway in `Public Subnet A` using the allocated EIP.

## Step 3: Routing
1. Create a **Public Route Table**. Add route `0.0.0.0/0` -> IGW. Associate with both Public Subnets.
2. Create a **Private Route Table**. Add route `0.0.0.0/0` -> NAT Gateway. Associate with both Private Subnets.

## Step 4: Security Groups
1. Create `Bastion-SG`: Allow Port 22 from your specific IP.
2. Create `Private-SG`: Allow Port 22 from the `Bastion-SG` ID.

## Step 5: Test Instances
1. Launch an EC2 instance in the Public Subnet using `Bastion-SG`.
2. Launch an EC2 instance in the Private Subnet using `Private-SG`.
