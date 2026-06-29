#!/bin/bash

# =============================================================================
# Project 6 — Script 06: Launch EC2 App Server + IAM Role
# Launches t2.micro in public subnet with MySQL client and Apache installed
# Also creates and attaches IAM role for Secrets Manager access
# =============================================================================

echo -e "\e[36m=== Project 6 — Launch EC2 App Server ===\e[0m"
echo ""

if (-not $EC2_SG -or -not $PUB_SUBNET_A) {
echo -e "\e[31mERROR: EC2_SG or PUB_SUBNET_A not set. Run earlier scripts first.\e[0m"
    exit 1
}

# ── FIND LATEST AMAZON LINUX 2023 AMI ─────────────────────────────────────────
echo -e "\e[33m[1/4] Finding latest Amazon Linux 2023 AMI...\e[0m"

AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
    --query "sort_by(Images,&CreationDate)[-1].ImageId" \
    --output text)

echo -e "\e[32mAMI: $AMI_ID\e[0m"

# ── USER DATA SCRIPT ──────────────────────────────────────────────────────────
echo -e "\e[33m[2/4] Preparing user data...\e[0m"

USER_DATA_CONTENT=@"
#!/bin/bash
yum update -y
yum install -y mysql httpd
systemctl start httpd
systemctl enable httpd

echo '<html>
<head><title>App Server - Project 6</title></head>
<body style="font-family:Arial,sans-serif;text-align:center;padding:60px;background:#f0f2f5">
  <h1 style="color:#232f3e">App Server Running</h1>
  <p style="color:#555;font-size:18px">EC2 + RDS Two-Tier Architecture — Project 6</p>
  <p style="color:#28a745;font-size:16px">MySQL client installed and ready to connect to RDS</p>
  <hr style="max-width:400px;margin:30px auto">
  <p style="color:#888;font-size:14px">Amazon Linux 2023 · t2.micro · public-subnet-a</p>
</body>
</html>' > /var/www/html/index.html
"@

$USER_DATA_CONTENT | Out-File -FilePath "userdata-app.sh" -Encoding ascii
echo -e "\e[32mUser data script written to userdata-app.sh\e[0m"

# ── LAUNCH EC2 INSTANCE ───────────────────────────────────────────────────────
echo -e "\e[33m[3/4] Launching EC2 instance...\e[0m"

APP_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name aws-ec2-keypair \
    --subnet-id $PUB_SUBNET_A \
    --security-group-ids $EC2_SG \
    --associate-public-ip-address \
    --user-data file://userdata-app.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=app-server}]" \
    --query "Instances[0].InstanceId" \
    --output text)

echo -e "\e[32mInstance launched: $APP_INSTANCE_ID\e[0m"
echo -e "\e[33mWaiting for instance to pass status checks (2-3 minutes)...\e[0m"

aws ec2 wait instance-status-ok --instance-ids $APP_INSTANCE_ID
echo -e "\e[32mInstance ready.\e[0m"

APP_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $APP_INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

echo -e "\e[32mPublic IP: $APP_PUBLIC_IP\e[0m"

# ── IAM ROLE FOR SECRETS MANAGER ─────────────────────────────────────────────
echo -e "\e[33m[4/4] Creating IAM role for Secrets Manager access...\e[0m"

ENHANCED_POLICY='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:rds/myapp/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:*",
        "ec2messages:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters"
      ],
      "Resource": "*"
    }
  ]
}'

# Create IAM role
aws iam create-role \
    --role-name ec2-app-role \
    --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{
      "Effect":"Allow",
      "Principal":{"Service":"ec2.amazonaws.com"},
      "Action":"sts:AssumeRole"
    }]
  }' | Out-Null

# Attach AWS managed SSM policy
aws iam attach-role-policy \
    --role-name ec2-app-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

# Add scoped Secrets Manager policy
aws iam put-role-policy \
    --role-name ec2-app-role \
    --policy-name secrets-manager-access \
    --policy-document $ENHANCED_POLICY

# Create instance profile and attach role
aws iam create-instance-profile \
    --instance-profile-name ec2-app-profile | Out-Null

aws iam add-role-to-instance-profile \
    --instance-profile-name ec2-app-profile \
    --role-name ec2-app-role

# Wait briefly for IAM to propagate
sleep 10

# Associate instance profile with EC2
aws ec2 associate-iam-instance-profile \
    --instance-id $APP_INSTANCE_ID \
    --iam-instance-profile Name=ec2-app-profile | Out-Null

echo -e "\e[32mIAM role created and attached.\e[0m"

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== EC2 App Server Complete ===\e[0m"
echo ""
echo "  APP_INSTANCE_ID = $APP_INSTANCE_ID"
echo "  APP_PUBLIC_IP   = $APP_PUBLIC_IP"
echo ""
echo "Test the web server: http://$APP_PUBLIC_IP"
echo ""
echo "SSH command:"
echo "  ssh -i aws-ec2-keypair.pem ec2-user@$APP_PUBLIC_IP"
echo ""
echo "Wait 2 minutes before testing Secrets Manager from EC2"
echo "(IAM credentials need time to propagate to instance metadata)"
echo ""
echo -e "\e[36mNext step: SSH into the instance, then use 07-rds-connect.sql\e[0m"