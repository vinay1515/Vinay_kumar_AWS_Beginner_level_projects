# Deployment Guide

## Step 1: Create the Subnet Group & Security Groups
1. Navigate to RDS > Subnet Groups. Create one utilizing your Private Subnets.
2. Create `Web-SG` (Port 80/22 inbound).
3. Create `DB-SG` (Port 3306 inbound from `Web-SG`).

## Step 2: Store Credentials
1. Navigate to Secrets Manager. Store a new secret (Other type).
2. Key/Value pairs: `username`, `password`, `port`, `dbname`. Name it `rds/myapp/credentials`.

## Step 3: Launch RDS
1. Create Database > MySQL.
2. Select Free Tier (db.t3.micro).
3. Set master username/password to match the Secrets Manager values.
4. Under Connectivity, select your VPC, the DB Subnet Group, and `DB-SG`. Ensure Public Access is **No**.

## Step 4: Launch EC2 App Server
1. Create an IAM Role granting access to Secrets Manager and attach it to an EC2 instance.
2. Launch the EC2 instance into a Public Subnet with `Web-SG`.
3. SSH into EC2, install the `mysql` client, retrieve the secret via AWS CLI, and connect to the RDS endpoint.
