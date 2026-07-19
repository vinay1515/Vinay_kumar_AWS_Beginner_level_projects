# PRE-FLIGHT
# Confirm region
aws configure get region
# Expected: ap-south-1

aws configure set region ap-south-1

# Get account ID
$ACCOUNT_ID = aws sts get-caller-identity --query "Account" --output text
Write-Host "Account ID: $ACCOUNT_ID"

# Confirm key pair exists
aws ec2 describe-key-pairs --key-names aws-ec2-keypair --query "KeyPairs[0].KeyName" --output text

# Create project folder
mkdir C:\Users\$env:USERNAME\aws-cloud-projects\project-14-capstone
Set-Location C:\Users\$env:USERNAME\aws-cloud-projects\project-14-capstone
mkdir templates, scripts, docs, screenshots, diagrams
