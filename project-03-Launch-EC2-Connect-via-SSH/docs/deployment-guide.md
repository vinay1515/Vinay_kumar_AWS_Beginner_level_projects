# Deployment Guide

This guide covers the end-to-end setup of your first EC2 instance, securing it, and testing the web server.

## PRE-FLIGHT — Before You Start

Confirm your environment is ready before proceeding. Run these commands in PowerShell:

```powershell
# Confirm CLI is working
aws sts get-caller-identity
# Expected: your Account ID and IAM user ARN

# Confirm region
aws configure get region
# Expected: us-east-1 (or your configured region)

# Check your default VPC exists
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" `
  --query "Vpcs[*].{VpcId:VpcId,CIDR:CidrBlock}" `
  --output table
# Expected: one row showing your default VPC ID and 172.31.0.0/16
```

> [!NOTE]
> If the default VPC query returns empty, you will need to recreate it before proceeding.

---

## PART 1 — CREATE A KEY PAIR

A key pair is how you prove your identity to the EC2 instance. AWS stores the public key on the server. You keep the private key on your PC.

### Console Steps
1. Navigate to **EC2 Dashboard** in AWS Console.
2. Under **Network & Security** (left panel) → **Key Pairs**.
3. Click **Create key pair**.
   - **Name**: `aws-ec2-keypair`
   - **Type**: RSA
   - **Format**: `.ppk` (for PuTTY on Windows)
4. Click **Create key pair**. Move the downloaded `.ppk` file to a safe location (e.g., `C:\Users\YourName\aws-keys\aws-ec2-keypair.ppk`).

> [!WARNING]
> This is the only time AWS gives you this file. Do not lose it. Do not upload it to GitHub.

---

## PART 2 — CREATE A SECURITY GROUP

A security group is a virtual firewall. We will allow SSH (port 22) and HTTP (port 80).

### Console Steps
1. Go to **Network & Security** → **Security Groups**.
2. Click **Create security group**.
   - **Name**: `ec2-web-sg`
   - **Description**: Allow SSH and HTTP access
   - **VPC**: Select your default VPC
3. **Inbound rules** (Add two rules):
   - **SSH | TCP | 22 | My IP** (Auto-detects your IP)
   - **HTTP | TCP | 80 | Anywhere IPv4 (0.0.0.0/0)**
4. Click **Create security group**. Copy the Security Group ID (`sg-...`).

---

## PART 3 — LAUNCH THE EC2 INSTANCE

### Console Steps
1. Go to **Instances** → **Launch instances**.
2. **Name**: `my-first-ec2`
3. **AMI**: Amazon Linux 2023 AMI (Free tier eligible, 64-bit x86)
4. **Instance type**: `t2.micro`
5. **Key pair**: Select `aws-ec2-keypair`
6. **Network settings** (Edit):
   - **VPC**: Default VPC
   - **Subnet**: No preference
   - **Auto-assign public IP**: Enable
   - **Firewall**: Select existing security group → `ec2-web-sg`
7. **Storage**: 8 GiB gp3
8. **Advanced details** → **User data**:
   ```bash
   #!/bin/bash
   # This runs automatically when the instance first starts
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   echo "<html>
   <head><title>My EC2 Web Server</title></head>
   <body style='font-family:Arial;text-align:center;padding:60px;background:#f0f2f5'>
   <h1 style='color:#232f3e'>&#x2705; EC2 Web Server is Running!</h1>
   <p style='color:#555'>Hosted on Amazon EC2 t2.micro &bull; Amazon Linux 2023</p>
   <p style='color:#555'>Instance launched as part of AWS Cloud Engineering bootcamp &bull; Project 3</p>
   </body>
   </html>" > /var/www/html/index.html
   ```
9. Click **Launch instance**. Wait for `2/2 checks passed` and copy the **Public IPv4 address**.

---

## PART 4 — CONNECT VIA PUTTY (SSH)

1. Download and install [PuTTY](https://www.putty.org) (64-bit MSI installer).
2. Open PuTTY.
   - **Host Name**: `ec2-user@<YOUR_PUBLIC_IP>`
   - **Port**: 22
   - **Connection type**: SSH
3. Navigate to **Connection → SSH → Auth → Credentials** (left panel).
   - Browse for your `aws-ec2-keypair.ppk` file.
4. Go back to **Session**, save it as `my-first-ec2`, and click **Open**.
5. Click **Accept** on the security alert. You are now connected!

---

## PART 5 — CONNECT VIA SESSION MANAGER (No PuTTY needed)

### Console Steps
1. Go to **IAM → Roles → Create role**.
2. **Trusted entity**: AWS service (EC2).
3. Search and select policy: `AmazonSSMManagedInstanceCore`.
4. **Role name**: `ec2-ssm-role`. Create the role.
5. Go to **EC2 → Instances**, select your instance.
6. **Actions → Security → Modify IAM role**. Select `ec2-ssm-role` and update.
7. Wait 2-3 minutes, select the instance, click **Connect** → **Session Manager** tab → **Connect**.

---

## PART 6 — EXPLORE YOUR SERVER AND VERIFY APACHE

Run these inside your SSH or Session Manager terminal:
```bash
whoami                    # ec2-user
hostname                  # ip-172-31-XX-XX.ec2.internal
cat /etc/os-release       # Amazon Linux 2023
sudo systemctl status httpd # active (running)
cat /var/www/html/index.html
df -h                     # check disk space
free -h                   # check memory
nproc                     # check CPU info
sudo ss -tlnp | grep :80  # check what is listening on port 80
sudo tail -10 /var/log/httpd/access_log
```
**Test Web Server:** Open `http://<YOUR_PUBLIC_IP>` in your browser.

---

## PART 7 — KEY EC2 OPERATIONS VIA CLI

```powershell
# Stop instance
aws ec2 stop-instances --instance-ids $INSTANCE_ID

# Start instance
aws ec2 start-instances --instance-ids $INSTANCE_ID

# Reboot instance
aws ec2 reboot-instances --instance-ids $INSTANCE_ID
```
> [!TIP]
> Stop = pause (no compute charge). Terminate = permanent deletion.

---

## PART 8 — CLOUDWATCH MONITORING

View CPU Utilization using CLI or via the **Monitoring** tab in the EC2 Console.
```powershell
aws cloudwatch get-metric-statistics `
  --namespace AWS/EC2 `
  --metric-name CPUUtilization `
  --dimensions Name=InstanceId,Value=$INSTANCE_ID `
  --start-time (Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ") `
  --end-time (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ") `
  --period 300 `
  --statistics Average
```

---

## PART 9 — CLEANUP

Terminate your instance to avoid charges.

### CLI
```powershell
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 delete-security-group --group-id $SG_ID
aws ec2 delete-key-pair --key-name aws-ec2-keypair
# Note: Keep your local .ppk file!
```