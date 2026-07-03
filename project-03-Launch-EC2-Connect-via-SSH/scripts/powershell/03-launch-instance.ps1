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
