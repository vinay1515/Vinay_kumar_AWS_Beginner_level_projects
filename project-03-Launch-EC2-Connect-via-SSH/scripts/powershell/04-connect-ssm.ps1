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
