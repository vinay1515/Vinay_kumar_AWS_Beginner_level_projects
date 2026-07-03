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
