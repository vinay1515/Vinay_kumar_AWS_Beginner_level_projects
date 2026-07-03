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
