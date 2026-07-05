# Comprehensive Deployment Guide

This guide details the complete process for provisioning a secure EC2 instance, attaching firewall rules, injecting bootstrap scripts, and connecting via SSH.

---

## 🚀 PRE-FLIGHT CHECKS

Run these commands in PowerShell to confirm your environment is ready:
```powershell
# Confirm you are authenticated
aws sts get-caller-identity

# Confirm your default region
aws configure get region

# Check for existing Key Pairs
aws ec2 describe-key-pairs
```

---

## 🔑 PART 1 — GENERATE THE SSH KEY PAIR

We must create the cryptographic keys before launching the server.

### 🖥️ Method 1: AWS Management Console

1. Navigate to the **EC2 Dashboard**.
2. In the left menu, scroll down to **Network & Security** → **Key Pairs**.
3. Click **Create key pair**.
4. **Name:** `my-web-key`
5. **Key pair type:** `RSA`
6. **Private key file format:** `.pem` (Choose `.ppk` *only* if you are using an older version of PuTTY on Windows).
7. Click **Create key pair**.
8. **CRITICAL:** Your browser will download `my-web-key.pem`. Move this file to a secure, permanent location on your hard drive (e.g., `~/.ssh/` on Mac/Linux or `C:\Users\YourName\.ssh\` on Windows). You cannot download this file a second time.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# Create the keys folder
mkdir -p ~/aws-keys

# Create key pair and save private key
aws ec2 create-key-pair \
  --key-name aws-ec2-keypair \
  --key-type RSA \
  --key-format ppk \
  --query "KeyMaterial" \
  --output text > ~/aws-keys/aws-ec2-keypair.ppk

# Verify it was created in AWS
aws ec2 describe-key-pairs --key-names aws-ec2-keypair \
  --query "KeyPairs[*].{Name:KeyName,ID:KeyPairId}" \
  --output table

echo -e "\e[32mCreated key pair: aws-ec2-keypair\e[0m"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Create the keys folder
mkdir C:\Users\$env:USERNAME\aws-keys -ErrorAction SilentlyContinue

# Create key pair and save private key
aws ec2 create-key-pair `
  --key-name aws-ec2-keypair `
  --key-type RSA `
  --key-format ppk `
  --query "KeyMaterial" `
  --output text | Out-File `
  -FilePath "C:\Users\$env:USERNAME\aws-keys\aws-ec2-keypair.ppk" `
  -Encoding ascii

# Verify it was created in AWS
aws ec2 describe-key-pairs --key-names aws-ec2-keypair `
  --query "KeyPairs[*].{Name:KeyName,ID:KeyPairId}" `
  --output table
```
---

## 🛡️ PART 2 — CONFIGURE THE SECURITY GROUP (FIREWALL)

We must define the network boundary before attaching it to the instance.

### 🖥️ Method 1: AWS Management Console

1. In the left menu, go to **Network & Security** → **Security Groups**.
2. Click **Create security group**.
3. **Security group name:** `web-server-sg`
4. **Description:** `Allow SSH from my IP and HTTP from anywhere`
5. **VPC:** Leave as the default VPC.
6. **Inbound rules:**
   - Click **Add rule**.
   - **Type:** `SSH` (Port 22).
   - **Source:** Select **My IP**. (AWS will automatically inject your current public IP address).
   - Click **Add rule** again.
   - **Type:** `HTTP` (Port 80).
   - **Source:** Select **Anywhere-IPv4** (`0.0.0.0/0`).
7. Click **Create security group**.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# Get your default VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" \
  --output text)

echo "Default VPC ID: $VPC_ID"

# Get your current public IP address
MY_IP=$(curl -s https://checkip.amazonaws.com)

echo "Your public IP: $MY_IP"

# Create the security group
SG_ID=$(aws ec2 create-security-group \
  --group-name ec2-web-sg \
  --description "Allow SSH and HTTP access" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

echo "Security Group ID: $SG_ID"

# Add SSH rule — only your IP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr "$MY_IP/32"

# Add HTTP rule — open to everyone
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr "0.0.0.0/0"

# Verify both rules were added
aws ec2 describe-security-groups --group-ids $SG_ID \
  --query "SecurityGroups[0].IpPermissions[*].{Port:FromPort,Protocol:IpProtocol,Source:IpRanges[0].CidrIp}" \
  --output table
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Get your default VPC ID
$VPC_ID = aws ec2 describe-vpcs `
  --filters "Name=isDefault,Values=true" `
  --query "Vpcs[0].VpcId" `
  --output text

Write-Host "Default VPC ID: $VPC_ID"

# Get your current public IP address
$MY_IP = (Invoke-WebRequest -Uri "https://checkip.amazonaws.com" `
  -UseBasicParsing).Content.Trim()

Write-Host "Your public IP: $MY_IP"

# Create the security group
$SG_ID = aws ec2 create-security-group `
  --group-name ec2-web-sg `
  --description "Allow SSH and HTTP access" `
  --vpc-id $VPC_ID `
  --query "GroupId" `
  --output text

Write-Host "Security Group ID: $SG_ID"

# Add SSH rule — only your IP
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 22 `
  --cidr "$MY_IP/32"

# Add HTTP rule — open to everyone
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 80 `
  --cidr "0.0.0.0/0"

# Verify both rules were added
aws ec2 describe-security-groups --group-ids $SG_ID `
  --query "SecurityGroups[0].IpPermissions[*].{Port:FromPort,Protocol:IpProtocol,Source:IpRanges[0].CidrIp}" `
  --output table
```
---

## 🏗️ PART 3 — LAUNCH THE EC2 INSTANCE

We will now combine the Key Pair, Security Group, and an AMI to spawn the virtual machine.

### 🖥️ Method 1: AWS Management Console

1. In the left menu, go to **Instances** → **Instances**.
2. Click **Launch instances**.
3. **Name and tags:** Type `My-First-Web-Server`.
4. **Application and OS Images (AMI):** Select the **Amazon Linux** tab. Ensure `Amazon Linux 2023 AMI` is selected and it says "Free tier eligible".
5. **Instance type:** Ensure `t2.micro` (or `t3.micro`) is selected.
6. **Key pair (login):** Select the `my-web-key` you created in Part 1 from the dropdown.
7. **Network settings:** 
   - Click **Edit**.
   - Ensure **Auto-assign public IP** is set to **Enable**.
   - Under Firewall, choose **Select existing security group**.
   - Check the box next to `web-server-sg`.
8. **Advanced details (User Data):**
   - Scroll all the way to the bottom and expand **Advanced details**.
   - Scroll to the bottom again to the **User data** text box.
   - Paste the following bash script exactly as shown:
```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from my first AWS EC2 Web Server!</h1><p>Bootstrapping successful.</p>" > /var/www/html/index.html
```
9. Click **Launch instance** on the right sidebar.
10. Click the instance ID link (e.g., `i-0abcd1234efgh5678`) to view it in the dashboard. Wait until the **Instance state** turns green (`Running`) and the **Status check** says `2/2 checks passed`.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# Get the latest Amazon Linux 2023 AMI ID for us-east-1
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
  --query "sort_by(Images,&CreationDate)[-1].ImageId" \
  --output text)

echo "AMI ID: $AMI_ID"

# Create a user-data script file
cat << 'EOF' > userdata.sh
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo '<html><body style="font-family:Arial;text-align:center;padding:60px">
<h1>EC2 Web Server Running</h1>
<p>Amazon Linux 2023 - Project 3</p>
</body></html>' > /var/www/html/index.html
EOF

# Get the security group ID (Assuming ec2-web-sg)
SG_ID=$(aws ec2 describe-security-groups --group-names ec2-web-sg --query "SecurityGroups[0].GroupId" --output text)

# Launch the instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name aws-ec2-keypair \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --user-data file://userdata.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=my-first-ec2}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "Instance ID: $INSTANCE_ID"

# Wait until the instance is running
echo "Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is running!"

# Get the public IP address
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Public IP: $PUBLIC_IP"

# Wait for status checks to pass (2/2)
echo "Waiting for status checks (takes 2-3 minutes)..."
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
echo "Instance passed all status checks - ready to connect!"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Get the latest Amazon Linux 2023 AMI ID for us-east-1
$AMI_ID = aws ec2 describe-images `
  --owners amazon `
  --filters `
    "Name=name,Values=al2023-ami-*-x86_64" `
    "Name=state,Values=available" `
  --query "sort_by(Images,&CreationDate)[-1].ImageId" `
  --output text

Write-Host "AMI ID: $AMI_ID"

# Create a user-data script file
$USER_DATA = @"
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo '<html><body style="font-family:Arial;text-align:center;padding:60px">
<h1>EC2 Web Server Running</h1>
<p>Amazon Linux 2023 - Project 3</p>
</body></html>' > /var/www/html/index.html
"@

$USER_DATA | Out-File -FilePath "userdata.sh" -Encoding ascii

# Get the security group ID (Assuming ec2-web-sg)
$SG_ID = aws ec2 describe-security-groups --group-names ec2-web-sg --query "SecurityGroups[0].GroupId" --output text

# Launch the instance
$INSTANCE_ID = aws ec2 run-instances `
  --image-id $AMI_ID `
  --instance-type t2.micro `
  --key-name aws-ec2-keypair `
  --security-group-ids $SG_ID `
  --associate-public-ip-address `
  --user-data file://userdata.sh `
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=my-first-ec2}]" `
  --query "Instances[0].InstanceId" `
  --output text

Write-Host "Instance ID: $INSTANCE_ID"

# Wait until the instance is running
Write-Host "Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
Write-Host "Instance is running!"

# Get the public IP address
$PUBLIC_IP = aws ec2 describe-instances `
  --instance-ids $INSTANCE_ID `
  --query "Reservations[0].Instances[0].PublicIpAddress" `
  --output text

Write-Host "Public IP: $PUBLIC_IP"

# Wait for status checks to pass (2/2)
Write-Host "Waiting for status checks (takes 2-3 minutes)..."
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
Write-Host "Instance passed all status checks - ready to connect!"
```
---

## 🌐 PART 4 — VALIDATE THE WEB SERVER

### 🖥️ Method 1: AWS Management Console
1. Select your running instance in the EC2 dashboard.
2. In the bottom details pane, copy the **Public IPv4 address** (e.g., `54.123.45.67`).
3. Open a new tab in your web browser.
4. Type `http://54.123.45.67` (ensure it is `http://` and not `https://`).
5. You should see your "Hello from my first AWS EC2 Web Server!" message. The User Data script worked!

### 🐧 Method 2: AWS CLI (Bash)
*(Validation is a visual check in the browser. See Method 1)*

### 🪟 Method 3: AWS CLI (PowerShell)
*(Validation is a visual check in the browser. See Method 1)*

---

## 💻 PART 5 — CONNECT VIA SSH (TERMINAL)

### 🖥️ Method 1: AWS Management Console

1. Open PowerShell or Terminal.
2. Navigate to the folder where you saved `my-web-key.pem`.
   ```powershell
   cd C:\Users\YourName\.ssh
   ```
3. Secure the key file (Mac/Linux only):
   ```bash
   chmod 400 my-web-key.pem
   ```
4. Run the SSH command. The default username for Amazon Linux is `ec2-user`. Replace the IP with your instance's Public IP.
   ```powershell
   ssh -i my-web-key.pem ec2-user@54.123.45.67
   ```
5. Type `yes` when prompted about the authenticity of the host.
6. You are now logged into the server! You will see the Amazon Linux ASCII art logo.

> [!TIP]
> **Enterprise Alternative:** In modern enterprise environments, opening Port 22 is often strictly prohibited. Instead, engineers use **AWS Systems Manager (SSM) Session Manager** to connect via the browser securely without keys or open ports. You can test this by selecting your instance in the console, clicking **Connect**, choosing the **Session Manager** tab, and clicking Connect.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# Create the IAM role with EC2 trust policy
aws iam create-role \
  --role-name ec2-ssm-role \
  --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{
      "Effect":"Allow",
      "Principal":{"Service":"ec2.amazonaws.com"},
      "Action":"sts:AssumeRole"
    }]
  }'

# Attach the SSM managed policy
aws iam attach-role-policy \
  --role-name ec2-ssm-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# Create instance profile and add role to it
aws iam create-instance-profile \
  --instance-profile-name ec2-ssm-profile

aws iam add-role-to-instance-profile \
  --instance-profile-name ec2-ssm-profile \
  --role-name ec2-ssm-role

# Get Instance ID (assuming one running instance for my-first-ec2)
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=my-first-ec2" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text)

# Attach the instance profile to your EC2 instance
aws ec2 associate-iam-instance-profile \
  --instance-id $INSTANCE_ID \
  --iam-instance-profile Name=ec2-ssm-profile

# Verify
aws ec2 describe-iam-instance-profile-associations \
  --query "IamInstanceProfileAssociations[*].{Instance:InstanceId,Profile:IamInstanceProfile.Arn,State:State}" \
  --output table

echo "Wait a few minutes, then connect via Session Manager (console) or CLI:"
echo "aws ssm start-session --target $INSTANCE_ID"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Create the IAM role with EC2 trust policy
aws iam create-role `
  --role-name ec2-ssm-role `
  --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{
      "Effect":"Allow",
      "Principal":{"Service":"ec2.amazonaws.com"},
      "Action":"sts:AssumeRole"
    }]
  }'

# Attach the SSM managed policy
aws iam attach-role-policy `
  --role-name ec2-ssm-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# Create instance profile and add role to it
aws iam create-instance-profile `
  --instance-profile-name ec2-ssm-profile

aws iam add-role-to-instance-profile `
  --instance-profile-name ec2-ssm-profile `
  --role-name ec2-ssm-role

# Get Instance ID (assuming one running instance for my-first-ec2)
$INSTANCE_ID = aws ec2 describe-instances --filters "Name=tag:Name,Values=my-first-ec2" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text

# Attach the instance profile to your EC2 instance
aws ec2 associate-iam-instance-profile `
  --instance-id $INSTANCE_ID `
  --iam-instance-profile Name=ec2-ssm-profile

# Verify
aws ec2 describe-iam-instance-profile-associations `
  --query "IamInstanceProfileAssociations[*].{Instance:InstanceId,Profile:IamInstanceProfile.Arn,State:State}" `
  --output table

Write-Host "Wait a few minutes, then connect via Session Manager (console) or CLI:"
Write-Host "aws ssm start-session --target $INSTANCE_ID"
```

---

## 🧹 PART 6 — CLEANUP

### 🖥️ Method 1: AWS Management Console
1. Go to **EC2 Dashboard**.
2. Select **Instances**, select `My-First-Web-Server`, click **Instance state** -> **Terminate instance**.
3. Wait for it to terminate.
4. Select **Security Groups**, select `web-server-sg`, click **Actions** -> **Delete security group**.
5. Select **Key Pairs**, select `my-web-key`, click **Actions** -> **Delete**.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# Get Instance ID
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=my-first-ec2" --query "Reservations[*].Instances[*].InstanceId" --output text)

# Step 1 — Terminate the instance (permanent deletion)
if [ -n "$INSTANCE_ID" ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
    echo "Waiting for instance to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
    echo "Instance terminated"
fi

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups --group-names ec2-web-sg --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

# Step 2 — Delete the security group (must wait for instance to terminate first)
if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
    aws ec2 delete-security-group --group-id $SG_ID
    echo "Security group deleted"
fi

# Step 3 — Delete the key pair from AWS
aws ec2 delete-key-pair --key-name aws-ec2-keypair
echo "Key pair deleted from AWS"

# Step 4 — Detach and delete IAM instance profile
aws iam remove-role-from-instance-profile \
  --instance-profile-name ec2-ssm-profile \
  --role-name ec2-ssm-role 2>/dev/null || true

aws iam detach-role-policy \
  --role-name ec2-ssm-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore 2>/dev/null || true

aws iam delete-instance-profile --instance-profile-name ec2-ssm-profile 2>/dev/null || true
aws iam delete-role --role-name ec2-ssm-role 2>/dev/null || true

echo "IAM role and profile deleted"

# Verify instance is gone
if [ -n "$INSTANCE_ID" ]; then
    aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query "Reservations[0].Instances[0].State.Name" \
      --output text
fi
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Get Instance ID
$INSTANCE_ID = aws ec2 describe-instances --filters "Name=tag:Name,Values=my-first-ec2" --query "Reservations[*].Instances[*].InstanceId" --output text

# Step 1 — Terminate the instance (permanent deletion)
if ($INSTANCE_ID) {
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
    Write-Host "Waiting for instance to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
    Write-Host "Instance terminated"
}

# Get Security Group ID
$SG_ID = aws ec2 describe-security-groups --group-names ec2-web-sg --query "SecurityGroups[0].GroupId" --output text

# Step 2 — Delete the security group (must wait for instance to terminate first)
if ($SG_ID) {
    aws ec2 delete-security-group --group-id $SG_ID
    Write-Host "Security group deleted"
}

# Step 3 — Delete the key pair from AWS
aws ec2 delete-key-pair --key-name aws-ec2-keypair
Write-Host "Key pair deleted from AWS"

# Step 4 — Detach and delete IAM instance profile
aws iam remove-role-from-instance-profile `
  --instance-profile-name ec2-ssm-profile `
  --role-name ec2-ssm-role -ErrorAction SilentlyContinue

aws iam detach-role-policy `
  --role-name ec2-ssm-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore -ErrorAction SilentlyContinue

aws iam delete-instance-profile --instance-profile-name ec2-ssm-profile -ErrorAction SilentlyContinue
aws iam delete-role --role-name ec2-ssm-role -ErrorAction SilentlyContinue

Write-Host "IAM role and profile deleted"

# Verify instance is gone
if ($INSTANCE_ID) {
    aws ec2 describe-instances `
      --instance-ids $INSTANCE_ID `
      --query "Reservations[0].Instances[0].State.Name" `
      --output text
}
```
