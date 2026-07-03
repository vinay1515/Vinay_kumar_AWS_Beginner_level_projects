# Deployment Guide

## Step 1: Create Key Pair and Security Group
1. In the EC2 Console, create a new Key Pair (RSA, `.ppk` for PuTTY or `.pem` for OpenSSH).
2. Create a Security Group in the Default VPC. Add inbound rules:
   - HTTP (80) -> Source: Anywhere.
   - SSH (22) -> Source: My IP.

## Step 2: Create IAM Role for SSM
1. In IAM, create a Role for the EC2 use case.
2. Attach the `AmazonSSMManagedInstanceCore` policy.
3. Name it `ec2-ssm-role`.

## Step 3: Launch the EC2 Instance
1. Launch Instance, select Amazon Linux 2023 AMI, `t2.micro`.
2. Select the Key Pair and Security Group created in Step 1.
3. Under Advanced Details, select the IAM instance profile `ec2-ssm-role`.
4. Under User Data, paste the bash script (found in `scripts/userdata.sh`).
5. Launch the instance.
