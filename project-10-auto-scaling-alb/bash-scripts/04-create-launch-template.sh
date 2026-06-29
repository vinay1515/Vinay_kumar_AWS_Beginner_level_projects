#!/bin/bash

# =============================================================================
# Project 10 — Script 04: Create Launch Template
# Defines EC2 blueprint with Apache, stress tool, and custom HTML page
# Region: ap-south-1
# =============================================================================

echo -e "\e[36m=== Project 10 — Create Launch Template ===\e[0m"
echo ""

# ── PRE-REQUISITES ────────────────────────────────────────────────────────────
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)

EC2_SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=asg-ec2-sg" \
  "Name=vpc-id,Values=$VPC_ID" \
  --query "SecurityGroups[0].GroupId" --output text)

echo -e "\e[32m  EC2 SG: $EC2_SG\e[0m"

# ── GET LATEST AMAZON LINUX 2023 AMI ──────────────────────────────────────────
echo ""
echo -e "\e[33m[1/3] Finding latest Amazon Linux 2023 AMI...\e[0m"

AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
  "Name=state,Values=available" \
  --region ap-south-1 \
  --query "sort_by(Images,&CreationDate)[-1].ImageId" \
  --output text)

echo -e "\e[32m  AMI: $AMI_ID\e[0m"

# ── PREPARE USER DATA ─────────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[2/3] Preparing user data script...\e[0m"

USER_DATA=@'
#!/bin/bash
yum update -y
yum install -y httpd stress
systemctl start httpd
systemctl enable httpd
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
cat > /var/www/html/index.html << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>ASG Demo</title>
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:Arial,sans-serif;background:linear-gradient(135deg,#232f3e,#1a73e8);
    min-height:100vh;display:flex;align-items:center;justify-content:center}
    .card{background:white;border-radius:16px;padding:40px;max-width:500px;
    width:90%;text-align:center;box-shadow:0 20px 60px rgba(0,0,0,.3)}
    .badge{background:#ff9900;color:white;padding:6px 16px;border-radius:20px;
    font-size:13px;display:inline-block;margin-bottom:20px}
    h1{color:#232f3e;margin-bottom:20px;font-size:24px}
    .info{background:#f0f7ff;border-radius:8px;padding:16px;margin:10px 0;text-align:left}
    .label{font-size:12px;color:#888;text-transform:uppercase}
    .value{font-size:16px;font-weight:bold;color:#232f3e}
    .healthy{background:#d4edda;color:#155724;border-radius:8px;padding:10px;
    margin-top:16px;font-weight:bold}
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Auto Scaling Group - Project 10</span>
    <h1>Load Balanced Instance</h1>
    <div class="info"><div class="label">Instance ID</div><div class="value">$INSTANCE_ID</div></div>
    <div class="info"><div class="label">Availability Zone</div><div class="value">$AZ</div></div>
    <div class="info"><div class="label">Private IP</div><div class="value">$PRIVATE_IP</div></div>
    <div class="info"><div class="label">Region</div><div class="value">ap-south-1 (Mumbai)</div></div>
    <div class="healthy">Instance Healthy - Serving Traffic</div>
  </div>
</body>
</html>
HTMLEOF
echo "User data script completed" >> /tmp/setup.log
'@

# Encode user data to base64
USER_DATA_B64=[Convert]::ToBase64String(
  [System.Text.Encoding]::UTF8.GetBytes($USER_DATA)
)

echo -e "\e[32m  User data prepared and base64 encoded.\e[0m"

# ── CREATE LAUNCH TEMPLATE ────────────────────────────────────────────────────
echo ""
echo -e "\e[33m[3/3] Creating Launch Template...\e[0m"

LT_ID=$(aws ec2 create-launch-template \
  --launch-template-name web-server-lt \
  --version-description "v1 - Apache web server" \
  --launch-template-data "{)
      \"ImageId\":\"$AMI_ID\",
      \"InstanceType\":\"t2.micro\",
      \"KeyName\":\"aws-ec2-keypair\",
      \"SecurityGroupIds\":[\"$EC2_SG\"],
      \"UserData\":\"$USER_DATA_B64\",
      \"TagSpecifications\":[{
        \"ResourceType\":\"instance\",
        \"Tags\":[
          {\"Key\":\"Name\",\"Value\":\"asg-web-server\"},
          {\"Key\":\"Project\",\"Value\":\"project-10-asg-alb\"}
        ]
      }]
    }" \
  --query "LaunchTemplate.LaunchTemplateId" \
  --output text

echo -e "\e[32m  Launch Template ID: $LT_ID\e[0m"

# ── VERIFY ────────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[33mVerifying launch template...\e[0m"
aws ec2 describe-launch-templates \
  --launch-template-ids $LT_ID \
  --query "LaunchTemplates[0].{ID:LaunchTemplateId,Name:LaunchTemplateName,Version:LatestVersionNumber}" \
  --output table

# ── SUMMARY ───────────────────────────────────────────────────────────────────
echo ""
echo -e "\e[36m=== Launch Template Complete ===\e[0m"
echo "  Template ID:   $LT_ID"
echo "  Template Name: web-server-lt"
echo "  AMI:           $AMI_ID (Amazon Linux 2023)"
echo "  Instance Type: t2.micro"
echo "  Key Pair:      aws-ec2-keypair"
echo "  Security Group: $EC2_SG"
echo "  User Data:     Apache + stress tool + custom HTML"
echo ""
echo -e "\e[36mNext step: Run 05-create-target-group.ps1\e[0m"
